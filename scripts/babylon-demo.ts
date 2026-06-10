/**
 * babylon-demo.ts
 *
 * Self-contained end-to-end demo of the BABY token governance voting flow.
 *
 * Runs without a live Babylon RPC — uses a synthetic 5-holder snapshot to
 * demonstrate the full circuit path:
 *
 *   1. Build a Merkle tree over synthetic BABY holders
 *   2. Derive a Merkle path for a test voter
 *   3. Verify the path locally (TypeScript, mirrors the Noir circuit logic)
 *   4. Print the witness inputs ready for the Noir prover
 *
 * For a live demo against the Aztec testnet, run with --live after generating
 * a snapshot with synthetic-snapshot.ts.
 *
 * Usage:
 *   npx ts-node scripts/babylon-demo.ts
 *   npx ts-node scripts/babylon-demo.ts --voter bbn1abc...
 */

import { createHash } from 'crypto';

// ── Types ─────────────────────────────────────────────────────────────────────

interface Holder {
  address: string;
  balance: bigint; // ubbn
}

interface VoteWitness {
  address_bytes: number[];   // 45 bytes
  balance: bigint;
  min_balance: bigint;
  merkle_path: string[][];   // 20 x 32 bytes (hex strings)
  merkle_indices: number[];  // 20 bits
  root: number[];            // 32 bytes
  root_as_field: string;     // hex Field element (31 bytes) for VoteConfig
}

// ── Merkle tree (SHA-256, matches merkle.nr) ───────────────────────────────────

function sha256(data: Buffer): Buffer {
  return createHash('sha256').update(data).digest();
}

function hashLeaf(address: string, balance: bigint): Buffer {
  // Pad address to 45 bytes — MUST match compute_leaf() in contracts/src/merkle.nr
  // The circuit takes [u8; 45] and hashes sha256(address_45 || balance_8)
  const addrBuf = Buffer.alloc(45, 0); // zero-padded to 45 bytes
  Buffer.from(address, 'utf8').copy(addrBuf);
  const balBuf = Buffer.alloc(8);
  balBuf.writeBigUInt64BE(balance);
  return sha256(Buffer.concat([addrBuf, balBuf]));
}

function hashPair(left: Buffer, right: Buffer): Buffer {
  return sha256(Buffer.concat([left, right]));
}

function buildMerkleTree(leaves: Buffer[]): { tree: Buffer[]; size: number } {
  let size = 1;
  while (size < leaves.length) size *= 2;

  const tree: Buffer[] = new Array(size * 2 - 1).fill(null).map(() => Buffer.alloc(32));

  for (let i = 0; i < leaves.length; i++) {
    tree[size - 1 + i] = leaves[i];
  }
  // Pad remaining leaves with zeros (empty leaf hash)
  for (let i = leaves.length; i < size; i++) {
    tree[size - 1 + i] = Buffer.alloc(32);
  }

  for (let i = size - 2; i >= 0; i--) {
    tree[i] = hashPair(tree[2 * i + 1], tree[2 * i + 2]);
  }

  return { tree, size };
}

function getMerklePath(
  tree: Buffer[],
  leafIndex: number,
  size: number,
  depth: number = 20,
): { path: Buffer[]; indices: number[] } {
  const path: Buffer[] = [];
  const indices: number[] = [];
  let idx = size - 1 + leafIndex;

  while (idx > 0 && path.length < depth) {
    const isRight = idx % 2 === 0;
    const siblingIdx = isRight ? idx - 1 : idx + 1;
    path.push(tree[siblingIdx]);
    indices.push(isRight ? 1 : 0);
    idx = Math.floor((idx - 1) / 2);
  }

  // Pad remaining levels with zero-sibling hashes and index=0.
  // IMPORTANT: the Noir circuit iterates all MERKLE_DEPTH levels unconditionally,
  // so the committed root must be the hash after ALL depth levels — including
  // the zero-padded ones. Use computeEffectiveRoot() to derive the correct root.
  while (path.length < depth) {
    path.push(Buffer.alloc(32));
    indices.push(0);
  }

  return { path, indices };
}

// Compute the root that the Noir circuit will arrive at after hashing all DEPTH
// levels (including zero-padded ones). This is what must be committed on-chain.
function computeEffectiveRoot(leaf: Buffer, path: Buffer[], indices: number[]): Buffer {
  let current = leaf;
  for (let i = 0; i < path.length; i++) {
    const s = path[i];
    if (indices[i] === 1) current = hashPair(s, current);
    else current = hashPair(current, s);
  }
  return current;
}

// ── Root encoding (matches encode_field_as_root in main.nr) ──────────────────

function encodeRootAsField(root: Buffer): string {
  // Drop first byte (always low-entropy for SHA-256), encode 31 bytes as Field
  return '0x' + root.slice(1).toString('hex');
}

function encodeFieldAsRoot(fieldHex: string): number[] {
  const buf = Buffer.from(fieldHex.replace(/^0x/, ''), 'hex');
  const root = new Array(32).fill(0);
  root[0] = 0;
  for (let i = 0; i < 31; i++) root[i + 1] = buf[i];
  return root;
}

// ── Local verification (mirrors Noir circuit) ─────────────────────────────────

function verifyMerklePath(
  leaf: Buffer,
  path: Buffer[],
  indices: number[],
  root: Buffer,
): boolean {
  let current = leaf;

  for (let i = 0; i < path.length; i++) {
    const sibling = path[i];
    const isRight = indices[i] === 1;

    if (isRight) {
      // current is right child — sibling goes left
      current = hashPair(sibling, current);
    } else {
      // current is left child — sibling goes right
      current = hashPair(current, sibling);
    }
  }

  return current.equals(root);
}

function verifyBABYEligibility(
  holder: Holder,
  path: Buffer[],
  indices: number[],
  root: Buffer,
  minBalance: bigint,
): void {
  if (holder.balance < minBalance) {
    throw new Error(
      `Balance too low: ${holder.balance} ubbn < ${minBalance} ubbn minimum`
    );
  }

  const leaf = hashLeaf(holder.address, holder.balance);
  const valid = verifyMerklePath(leaf, path, indices, root);

  if (!valid) {
    throw new Error('Merkle proof invalid — computed root does not match');
  }
}

// ── Synthetic snapshot ─────────────────────────────────────────────────────────

const SYNTHETIC_HOLDERS: Holder[] = [
  { address: 'bbn1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqhx5fp4', balance: 5_000_000_000n },  // 5,000 BABY
  { address: 'bbn1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq7v3kwf', balance: 2_500_000_000n },  // 2,500 BABY
  { address: 'bbn1demo_voter_alice_000000000000000000xyz', balance: 50_000_000n },     //    50 BABY
  { address: 'bbn1demo_voter_bob_000000000000000000000ab', balance: 1_000_000n },      //     1 BABY
  { address: 'bbn1demo_voter_carol_00000000000000000cde', balance: 10_000_000n },      //    10 BABY
];

// ── Main ──────────────────────────────────────────────────────────────────────

function buildWitness(
  holders: Holder[],
  voterAddress: string,
  minBalance: bigint,
): VoteWitness {
  const sorted = [...holders].sort((a, b) => a.address.localeCompare(b.address));
  const leaves = sorted.map(h => hashLeaf(h.address, h.balance));

  const { tree, size } = buildMerkleTree(leaves);

  const voterIdx = sorted.findIndex(h => h.address === voterAddress);
  if (voterIdx === -1) {
    throw new Error(`Voter ${voterAddress} not found in snapshot`);
  }

  const voter = sorted[voterIdx];
  const { path, indices } = getMerklePath(tree, voterIdx, size);

  // The Noir circuit hashes all MERKLE_DEPTH levels unconditionally, including
  // zero-padded ones. The committed root must be the effective 20-level hash,
  // not the tree root (which is only 3 levels deep for an 8-leaf tree).
  const root = computeEffectiveRoot(hashLeaf(voter.address, voter.balance), path, indices);

  // Verify: all leaves should produce the same effective root
  const leaf0 = hashLeaf(sorted[0].address, sorted[0].balance);
  const { path: p0, indices: i0 } = getMerklePath(tree, 0, size);
  const root0 = computeEffectiveRoot(leaf0, p0, i0);
  if (!root.equals(root0)) {
    throw new Error('Effective root mismatch across leaves — tree build error');
  }

  // Verify locally before generating witness
  verifyBABYEligibility(voter, path, indices, root, minBalance);

  const addrBytes = Array.from(Buffer.from(voter.address, 'utf8'));
  // Pad to exactly 45 bytes (Noir circuit expects fixed size)
  while (addrBytes.length < 45) addrBytes.push(0);
  if (addrBytes.length > 45) {
    throw new Error(`Address ${voter.address} is ${voter.address.length} chars — must be ≤ 45`);
  }

  return {
    address_bytes: addrBytes,
    balance: voter.balance,
    min_balance: minBalance,
    merkle_path: path.map(p => Array.from(p).map(b => b.toString(16).padStart(2, '0'))),
    merkle_indices: indices,
    root: Array.from(root),
    root_as_field: encodeRootAsField(root),
  };
}

function printWitness(witness: VoteWitness): void {
  console.log('\n┌─ Noir Prover Witness ─────────────────────────────────────────────┐');
  console.log('│ Input to: verify_baby_eligibility(...)                            │');
  console.log('└───────────────────────────────────────────────────────────────────┘\n');

  console.log('address_bytes = [');
  console.log(' ', witness.address_bytes.join(', '));
  console.log(']');

  console.log(`\nbalance       = ${witness.balance}  (${Number(witness.balance) / 1_000_000} BABY)`);
  console.log(`min_balance   = ${witness.min_balance}  (${Number(witness.min_balance) / 1_000_000} BABY)`);

  console.log('\nmerkle_path = [');
  for (const level of witness.merkle_path) {
    console.log(`  [${level.map(b => `0x${b}`).join(', ')}],`);
  }
  console.log(']');

  console.log('\nmerkle_indices = [');
  console.log(' ', witness.merkle_indices.join(', '));
  console.log(']');

  console.log('\nroot = [');
  console.log(' ', witness.root.map(b => `0x${b.toString(16).padStart(2, '0')}`).join(', '));
  console.log(']');

  console.log('\n\n┌─ VoteConfig fields ───────────────────────────────────────────────┐');
  console.log('│ Use when deploying the Babylon governance vote:                   │');
  console.log('└───────────────────────────────────────────────────────────────────┘');
  console.log(`\n  token_address (Merkle root encoded as Field):`);
  console.log(`    ${witness.root_as_field}`);
  console.log(`\n  min_token_balance: ${witness.min_balance} (ubbn)`);
  console.log(`  eligibility_mode: 1  (ELIGIBILITY_MODE_TOKEN)`);
}

async function main() {
  const args = process.argv.slice(2);
  const getArg = (flag: string, def: string) => {
    const i = args.indexOf(flag);
    return i >= 0 ? args[i + 1] : def;
  };

  const voterAddress = getArg('--voter', 'bbn1demo_voter_alice_000000000000000000xyz');
  const MIN_BALANCE = 1_000_000n; // 1 BABY

  console.log('═══════════════════════════════════════════════════════════════════');
  console.log('  Umbra × Babylon — Private Governance Demo');
  console.log('  BABY token ZK eligibility proof — local verification');
  console.log('═══════════════════════════════════════════════════════════════════');
  console.log(`\nVote: "Babylon Genesis — Treasury Allocation Q3 2026"`);
  console.log(`Min balance: ${Number(MIN_BALANCE) / 1_000_000} BABY\n`);

  console.log('Snapshot holders (synthetic — 5 addresses):');
  const sorted = [...SYNTHETIC_HOLDERS].sort((a, b) => a.address.localeCompare(b.address));
  for (const h of sorted) {
    const marker = h.address === voterAddress ? ' ← voter' : '';
    console.log(`  ${h.address}  ${(Number(h.balance) / 1_000_000).toFixed(2)} BABY${marker}`);
  }

  const leaves = sorted.map(h => hashLeaf(h.address, h.balance));
  const { tree, size } = buildMerkleTree(leaves);
  // Compute the effective 20-level root (what the Noir circuit commits to)
  const { path: p0, indices: i0 } = getMerklePath(tree, 0, size);
  const effectiveRoot = computeEffectiveRoot(leaves[0], p0, i0);
  console.log(`\nMerkle tree root (3 levels): 0x${tree[0].toString('hex')}`);
  console.log(`Effective root (20 levels, committed on-chain): 0x${effectiveRoot.toString('hex')}`);
  console.log(`Tree depth:  20 (supports up to ${2**20} holders)`);
  console.log(`Root as Field: ${encodeRootAsField(effectiveRoot)}`);
  console.log(`  (Note: effective root accounts for zero-padded path levels in the Noir circuit)`);

  console.log('\n── Building witness for voter ─────────────────────────────────────');
  console.log(`Voter: ${voterAddress}`);

  let witness: VoteWitness;
  try {
    witness = buildWitness(SYNTHETIC_HOLDERS, voterAddress, MIN_BALANCE);
  } catch (e) {
    console.error(`\n✗ ${(e as Error).message}`);
    process.exit(1);
  }

  console.log(`Balance: ${(Number(witness.balance) / 1_000_000).toFixed(2)} BABY ✓`);
  console.log(`Merkle path depth: ${witness.merkle_path.length}`);

  // Local verification (mirrors Noir circuit)
  const { path, indices } = {
    path: witness.merkle_path.map(level =>
      Buffer.from(level.map(h => parseInt(h, 16)))
    ),
    indices: witness.merkle_indices,
  };
  const leaf = hashLeaf(voterAddress, witness.balance);
  const rootBuf = Buffer.from(witness.root);
  const valid = verifyMerklePath(leaf, path, indices, rootBuf);

  if (!valid) {
    console.error('\n✗ Local verification FAILED — Merkle path is invalid');
    process.exit(1);
  }

  console.log(`\n✓ Local Merkle verification PASSED`);
  console.log(`  (Mirrors Noir circuit: verify_baby_eligibility in contracts/src/merkle.nr)`);

  printWitness(witness);

  console.log('\n\n── Next steps ─────────────────────────────────────────────────────');
  console.log('1. Generate the synthetic snapshot:');
  console.log('   npx tsx scripts/synthetic-snapshot.ts --holders 10000');
  console.log('');
  console.log('2. Deploy the vote contract with the Merkle root as token_address:');
  console.log('   export MERKLE_ROOT_FIELD=<rootAsField from snapshot/merkle-root.json>');
  console.log('   bash scripts/bridge-and-deploy.sh --babylon');
  console.log('');
  console.log('3. Open the Babylon demo frontend:');
  console.log('   cd demo && npm run dev');
  console.log('   Navigate to http://localhost:3000/babylon');
  console.log('');
  console.log('4. For Noir proof generation (requires nargo v5+):');
  console.log('   nargo prove --package private_voting');
  console.log('');
  console.log('See BABYLON-DEMO.md for the full walkthrough.');
}

main().catch(console.error);
