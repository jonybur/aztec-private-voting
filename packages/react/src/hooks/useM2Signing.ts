import { useCallback, useState } from 'react';

import type { VoteConfig } from '../types';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN NOTE — ADR-036 vs. raw signing
//
// Keplr's window.keplr.signArbitrary(chainId, signer, data) wraps the payload
// in an ADR-036 SignDoc before signing. The secp256k1 signature it returns is
// therefore over sha256(protobuf(ADR-036-envelope(data))), NOT over sha256(data).
//
// The cast_vote_babylon_v2 Noir circuit verifies:
//   ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, r||s, challenge)
// where:
//   challenge = sha256(encode_field(title_hash) || encode_field(root_field))
//
// These are INCOMPATIBLE: Keplr signs a different message than the circuit
// expects. Using signArbitrary output directly with the current circuit will
// always fail proof generation.
//
// Paths forward (pick one before production):
//
//   A. Update the Noir circuit to verify the ADR-036 wrapped message.
//      Circuit receives the signer address as a private witness; constructs
//      the ADR-036 SignDoc; hashes it with sha256; verifies ecdsa.
//      Downside: adds ~50–100 constraint-equivalent lines to the circuit.
//
//   B. Use a wallet that supports raw secp256k1 signing (no wrapping).
//      Some hardware wallets and custom signers can sign a raw 32-byte digest.
//      The `mode: 'raw'` path in this hook uses @noble/curves/secp256k1 to
//      do exactly this — suitable for CLI tooling and integration tests.
//
//   C. Use EIP-191 personal_sign (MetaMask / EVM wallets).
//      personal_sign prepends "\x19Ethereum Signed Message:\n32" + keccak256.
//      Simpler to replicate in-circuit than ADR-036. Suitable if the voter
//      population is EVM-native rather than Cosmos-native.
//      Requires circuit change: swap sha256(challenge) for keccak256(eip191(challenge)).
//
// Current implementation: mode='raw' (for testing/CLI). The keplr stub is
// provided to document the interface but will throw until the circuit is
// updated to handle ADR-036.
// ─────────────────────────────────────────────────────────────────────────────

export type M2SignMode = 'raw' | 'keplr';

export interface M2SigningInput {
  /**
   * mode='raw': 64-char hex private key (for testing and CLI workflows only).
   *   Never collect this in a production UI.
   * mode='keplr': not yet supported (see ADR-036 note above).
   */
  mode: M2SignMode;
  privateKeyHex?: string;  // mode='raw' only
  keplrChainId?: string;   // mode='keplr' only (future)
  /**
   * Merkle root committed in VoteConfig, as an AztecField bigint.
   * From merkle-root-v2.json: rootAsField (lower 31 bytes of SHA-256 root).
   */
  merkleRootField: bigint;
  /**
   * The vote title_hash as a bigint (poseidon2Hash of the title bytes).
   * Compute this with the same hashTitle() helper used in useDeployVote.
   * This matches VoteConfig.title_hash stored in the deployed contract.
   */
  titleHash: bigint;
}

export interface M2SigningOutput {
  /** secp256k1 public key x-coordinate, 32 bytes big-endian */
  pubkey_x: number[];
  /** secp256k1 public key y-coordinate, 32 bytes big-endian */
  pubkey_y: number[];
  /** ECDSA signature R, 32 bytes big-endian (low-S normalised) */
  sig_r: number[];
  /** ECDSA signature S, 32 bytes big-endian (low-S normalised) */
  sig_s: number[];
  /** The 32-byte challenge that was signed (for circuit witness verification) */
  challenge: number[];
}

export type M2SignStatus = 'idle' | 'signing' | 'signed' | 'error';

export interface UseM2SigningResult {
  sign: (input: M2SigningInput) => Promise<M2SigningOutput | null>;
  status: M2SignStatus;
  output: M2SigningOutput | null;
  error: string | null;
  reset: () => void;
}

// ─────────────────────────────────────────────────────────────────────────────
// Challenge construction
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Build the vote-specific 32-byte challenge for cast_vote_babylon_v2.
 *
 * Matches the Noir circuit:
 *   challenge = sha256(encode_field(title_hash) || encode_field(root_field))
 *
 * Both title_hash and merkleRootField are Aztec Fields: to_be_bytes(32).
 *
 * @param titleHash     VoteConfig.title_hash as bigint (poseidon2 hash of title)
 * @param rootField     Merkle root lower-31-bytes field (from merkle-root-v2.json rootAsField)
 */
export async function buildM2Challenge(
  titleHash: bigint,
  rootField: bigint,
): Promise<Uint8Array> {
  const { sha256 } = await import('@noble/hashes/sha256');
  const combined = new Uint8Array(64);
  combined.set(fieldToBytes32(titleHash), 0);
  combined.set(fieldToBytes32(rootField), 32);
  return sha256(combined);
}

/**
 * Encode an Aztec Field (bigint, < 2^254) as 32 big-endian bytes.
 * Matches Noir's `field.to_be_bytes(32)`.
 */
export function fieldToBytes32(field: bigint): Uint8Array {
  const bytes = new Uint8Array(32);
  let remaining = field;
  for (let i = 31; i >= 0; i--) {
    bytes[i] = Number(remaining & 0xffn);
    remaining >>= 8n;
  }
  return bytes;
}

// ─────────────────────────────────────────────────────────────────────────────
// secp256k1 helpers (raw mode, uses @noble/curves via @aztec/foundation deps)
// ─────────────────────────────────────────────────────────────────────────────

// secp256k1 curve order n (BIP-62 low-S bound is n/2)
const SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141n;
const SECP256K1_N_HALF = SECP256K1_N >> 1n;

function bigintToBytes32(n: bigint): number[] {
  const out: number[] = new Array(32).fill(0);
  let remaining = n;
  for (let i = 31; i >= 0; i--) {
    out[i] = Number(remaining & 0xffn);
    remaining >>= 8n;
  }
  return out;
}

function hexToBytes(hex: string): Uint8Array {
  const clean = hex.replace(/^0x/, '');
  if (clean.length !== 64) {
    throw new Error(`Private key must be 32 bytes (64 hex chars), got ${clean.length}`);
  }
  return Uint8Array.from(Buffer.from(clean, 'hex'));
}

/**
 * Sign a 32-byte digest with a raw secp256k1 private key.
 * Returns (r, s, pubkey_x, pubkey_y) with BIP-62 low-S normalisation.
 *
 * Uses @noble/curves/secp256k1 (available as a transitive dependency via
 * @aztec/foundation). Does NOT add any prefix — matches the circuit.
 */
async function rawSign(
  privateKeyHex: string,
  digest: Uint8Array,
): Promise<Pick<M2SigningOutput, 'pubkey_x' | 'pubkey_y' | 'sig_r' | 'sig_s'>> {
  const { secp256k1 } = await import('@noble/curves/secp256k1');

  const privKeyBytes = hexToBytes(privateKeyHex);
  const pubKeyUncompressed = secp256k1.getPublicKey(privKeyBytes, false); // 65 bytes, 04|x|y

  if (pubKeyUncompressed.length !== 65 || pubKeyUncompressed[0] !== 0x04) {
    throw new Error('Unexpected public key format from @noble/curves/secp256k1');
  }

  const pubkey_x = Array.from(pubKeyUncompressed.slice(1, 33));
  const pubkey_y = Array.from(pubKeyUncompressed.slice(33, 65));

  // Sign the raw digest (no prefix — matches circuit's ecdsa_secp256k1::verify_signature)
  const sig = secp256k1.sign(digest, privKeyBytes, { lowS: true });

  const r = sig.r;
  const s = sig.s;

  // BIP-62 low-S: if s > n/2, use n - s. @noble/curves lowS option handles this,
  // but we assert here as a belt-and-suspenders check.
  if (s > SECP256K1_N_HALF) {
    throw new Error(
      'BIP-62 low-S violation: s > n/2 after signing. This should not happen with lowS:true.',
    );
  }

  return {
    pubkey_x,
    pubkey_y,
    sig_r: bigintToBytes32(r),
    sig_s: bigintToBytes32(s),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Keplr stub (documents interface; incompatible with current circuit — see note)
// ─────────────────────────────────────────────────────────────────────────────

async function keplrSign(
  _chainId: string,
  _challenge: Uint8Array,
): Promise<Pick<M2SigningOutput, 'pubkey_x' | 'pubkey_y' | 'sig_r' | 'sig_s'>> {
  // The interface Keplr exposes:
  //
  //   const { pub_key, signature } = await window.keplr.signArbitrary(
  //     chainId,
  //     signerAddress,       // bech32 signer; the circuit must accept this as a witness
  //     Buffer.from(challenge).toString('base64'),
  //   );
  //   // pub_key.value is base64(compressed 33-byte pubkey)
  //   // signature is base64(r||s, 64 bytes) over ADR-036 wrapped bytes — NOT over challenge
  //
  // BLOCKED: The signature is over the ADR-036 SignDoc hash, not over `challenge`.
  // The Noir circuit must be updated to verify the ADR-036 wrapped message before
  // this path is usable. See the design note at the top of this file.
  //
  // When that circuit update lands, this stub becomes:
  //   1. Derive signer address from pubkey (or accept it as input)
  //   2. Call signArbitrary(chainId, signerAddress, base64(challenge))
  //   3. Decode pub_key.value and signature from base64
  //   4. Split signature into r (bytes 0–31) and s (bytes 32–63)
  //   5. Assert low-S; if s > n/2, normalize

  throw new Error(
    'Keplr signing is not yet supported: the circuit must be updated to verify ' +
    'ADR-036 wrapped messages before this mode is usable. ' +
    'Use mode="raw" for testing, or see docs/m2-secp256k1-ownership-proof-design.md ' +
    'for the circuit update required.',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hook
// ─────────────────────────────────────────────────────────────────────────────

export function useM2Signing(_config: VoteConfig): UseM2SigningResult {
  const [status, setStatus] = useState<M2SignStatus>('idle');
  const [output, setOutput] = useState<M2SigningOutput | null>(null);
  const [error, setError] = useState<string | null>(null);

  const sign = useCallback(
    async (input: M2SigningInput): Promise<M2SigningOutput | null> => {
      setStatus('signing');
      setError(null);
      setOutput(null);

      try {
        // titleHash is provided by the caller (use the same hashTitle() helper
        // from useDeployVote.ts so both use the same poseidon2Hash computation).
        const challenge = await buildM2Challenge(input.titleHash, input.merkleRootField);

        let sigParts: Pick<M2SigningOutput, 'pubkey_x' | 'pubkey_y' | 'sig_r' | 'sig_s'>;

        if (input.mode === 'raw') {
          if (!input.privateKeyHex) {
            throw new Error("mode='raw' requires privateKeyHex");
          }
          sigParts = await rawSign(input.privateKeyHex, challenge);
        } else if (input.mode === 'keplr') {
          if (!input.keplrChainId) {
            throw new Error("mode='keplr' requires keplrChainId");
          }
          sigParts = await keplrSign(input.keplrChainId, challenge);
        } else {
          throw new Error(`Unknown M2 sign mode: ${input.mode as string}`);
        }

        const result: M2SigningOutput = {
          ...sigParts,
          challenge: Array.from(challenge),
        };

        setOutput(result);
        setStatus('signed');
        return result;
      } catch (err) {
        const msg = err instanceof Error ? err.message : 'M2 signing failed';
        setError(msg);
        setStatus('error');
        return null;
      }
    },
    [],
  );

  const reset = useCallback(() => {
    setStatus('idle');
    setOutput(null);
    setError(null);
  }, []);

  return { sign, status, output, error, reset };
}
