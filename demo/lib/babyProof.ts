/**
 * Browser-side prover for the baby_proof Noir circuit (Merkle eligibility +
 * balance check). Loads the precompiled circuit JSON from /baby_proof.json,
 * generates a witness with @noir-lang/noir_js, and produces an UltraHonk proof
 * with @aztec/bb.js.
 *
 * This proves, in zero knowledge:
 *   "I know an address + balance whose SHA-256 leaf is in the Merkle tree with
 *    the given root, and balance >= min_balance."
 *
 * Public inputs: root (32 bytes), min_balance (u64).
 * Private witnesses: address_bytes (45 bytes), balance (u64), path (20 × 32 bytes),
 * indices (20 bools).
 */

export interface BabyProofInputs {
  /** bbn1... cosmos address (will be zero-padded to 45 bytes UTF-8). */
  address: string;
  /** Holder balance in ubbn. */
  balance: bigint;
  /** Minimum required balance in ubbn (public). */
  minBalance: bigint;
  /** Merkle sibling hashes bottom-to-top, hex strings of 32 bytes each. */
  path: string[];
  /** Path direction bits, length must equal `path`. */
  indices: boolean[];
  /** Merkle root, 32 bytes hex (with or without 0x prefix). */
  root: string;
}

export interface BabyProofResult {
  /** Raw proof bytes (UltraHonk). */
  proof: Uint8Array;
  /** Public inputs as decimal field strings, in declaration order. */
  publicInputs: string[];
  /** Wall-clock duration of proving, in milliseconds. */
  durationMs: number;
}

const CIRCUIT_URL = '/baby_proof.json';

function stripHex(s: string): string {
  return s.startsWith('0x') ? s.slice(2) : s;
}

function hexToBytes(hex: string): number[] {
  const s = stripHex(hex);
  if (s.length % 2 !== 0) throw new Error(`hex length not even: ${hex}`);
  const out: number[] = [];
  for (let i = 0; i < s.length; i += 2) {
    out.push(parseInt(s.slice(i, i + 2), 16));
  }
  return out;
}

function paddedAddressBytes(address: string, len = 45): number[] {
  const enc = new TextEncoder().encode(address);
  if (enc.length > len) throw new Error(`address too long for ${len} bytes`);
  const out = new Array(len).fill(0);
  for (let i = 0; i < enc.length; i++) out[i] = enc[i];
  return out;
}

let cachedCircuit: unknown | null = null;
async function loadCircuit(): Promise<unknown> {
  if (cachedCircuit) return cachedCircuit;
  const r = await fetch(CIRCUIT_URL);
  if (!r.ok) throw new Error(`failed to load circuit: HTTP ${r.status}`);
  cachedCircuit = await r.json();
  return cachedCircuit;
}

/**
 * Generate a real ZK proof of BABY eligibility in the browser.
 *
 * Heavy operation (~5–15s on a modern laptop). Show UI progress.
 *
 * Throws on:
 *   - balance < minBalance,
 *   - path length != circuit depth,
 *   - witness mismatch (path/leaf doesn't hash to root),
 *   - bb.js / noir_js initialisation errors.
 */
export async function generateBabyProof(inputs: BabyProofInputs): Promise<BabyProofResult> {
  if (inputs.balance < inputs.minBalance) {
    throw new Error('balance below minimum');
  }
  if (inputs.path.length !== inputs.indices.length) {
    throw new Error('path and indices length mismatch');
  }

  const circuit = await loadCircuit();

  // Lazy dynamic imports — these pull WASM and must run only client-side.
  const [{ Noir }, { UltraHonkBackend }] = await Promise.all([
    import('@noir-lang/noir_js'),
    import('@aztec/bb.js'),
  ]);

  // The runtime constructors accept a single `CompiledCircuit`; the typed
  // signatures differ between published nightly/beta builds, so we go through
  // `any` to keep the binding stable across version bumps.
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const NoirCtor = Noir as unknown as new (c: any) => any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const BackendCtor = UltraHonkBackend as unknown as new (c: any) => any;
  const noir = new NoirCtor(circuit);
  const backend = new BackendCtor(circuit);

  const addressBytes = paddedAddressBytes(inputs.address);
  const rootBytes = hexToBytes(inputs.root);
  if (rootBytes.length !== 32) throw new Error('root must be 32 bytes');

  const pathBytes = inputs.path.map((p) => {
    const bs = hexToBytes(p);
    if (bs.length !== 32) throw new Error('sibling not 32 bytes');
    return bs;
  });

  const witnessInputs = {
    address_bytes: addressBytes,
    balance: inputs.balance.toString(),
    path: pathBytes,
    indices: inputs.indices,
    root: rootBytes,
    min_balance: inputs.minBalance.toString(),
  };

  const t0 = performance.now();
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { witness } = await (noir as any).execute(witnessInputs);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const proof = await (backend as any).generateProof(witness);
  const durationMs = performance.now() - t0;

  return {
    proof: proof.proof as Uint8Array,
    publicInputs: (proof.publicInputs ?? []) as string[],
    durationMs,
  };
}

/**
 * Convenience formatter for the receipt "fingerprint": a short, human-readable
 * hash of the proof bytes (not the same as a real ballot receipt id — that is
 * generated by the L1 contract on tally; this is purely a UX placeholder for
 * the offline demo).
 */
export async function proofFingerprint(proof: Uint8Array): Promise<string> {
  // Copy into a fresh ArrayBuffer so subtle.digest accepts it even if the
  // proof bytes are backed by a SharedArrayBuffer (bb.js worker output).
  const safe = new Uint8Array(proof.length);
  safe.set(proof);
  const digest = await crypto.subtle.digest('SHA-256', safe.buffer);
  const hex = Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return hex.slice(0, 16).match(/.{4}/g)!.join('-').toUpperCase();
}
