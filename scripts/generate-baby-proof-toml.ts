/**
 * generate-baby-proof-toml.ts
 *
 * Generates Prover.toml for the standalone baby-proof Noir circuit.
 * The baby-proof circuit is nargo 0.36.x compatible (uses sha256_var).
 *
 * Usage:
 *   npx ts-node scripts/generate-baby-proof-toml.ts
 *   npx ts-node scripts/generate-baby-proof-toml.ts --voter bbn1demo_voter_alice_000000000000000000xyz
 *
 * Output: baby-proof/Prover.toml
 */

import { createHash } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

const MERKLE_DEPTH = 20;

const DEMO_HOLDERS: { address: string; balance: bigint }[] = [
  { address: 'bbn1demo_voter_alice_000000000000000000xyz', balance: 50_000_000n },
  { address: 'bbn1demo_voter_bob_000000000000000000000ab', balance: 1_000_000n },
  { address: 'bbn1demo_voter_carol_00000000000000000cde', balance: 10_000_000n },
  { address: 'bbn1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq7v3kwf', balance: 2_500_000_000n },
  { address: 'bbn1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqhx5fp4', balance: 5_000_000_000n },
];

const DEFAULT_VOTER = 'bbn1demo_voter_alice_000000000000000000xyz';
const DEFAULT_MIN_BALANCE = 1_000_000n;

function sha256(data: Buffer): Buffer {
  return createHash('sha256').update(data).digest();
}

function hashLeaf(address: string, balance: bigint): Buffer {
  const addrBuf = Buffer.alloc(45, 0);
  Buffer.from(address, 'utf8').copy(addrBuf);
  const balBuf = Buffer.alloc(8);
  balBuf.writeBigUInt64BE(balance);
  // sha256_var with message_size=53 matches sha256 of exactly 53 bytes
  return sha256(Buffer.concat([addrBuf, balBuf]));
}

function hashPair(left: Buffer, right: Buffer): Buffer {
  return sha256(Buffer.concat([left, right]));
}

function buildMerkleTree(holders: { address: string; balance: bigint }[]): {
  tree: Buffer[];
  size: number;
} {
  const leaves = holders.map(h => hashLeaf(h.address, h.balance));
  let size = 1;
  while (size < leaves.length) size *= 2;

  const tree: Buffer[] = new Array(size * 2 - 1)
    .fill(null)
    .map(() => Buffer.alloc(32));

  for (let i = 0; i < leaves.length; i++) {
    tree[size - 1 + i] = leaves[i];
  }
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
  size: number,
  leafIndex: number,
): { path: Buffer[]; indices: number[] } {
  const pathBufs: Buffer[] = [];
  const indices: number[] = [];
  let idx = size - 1 + leafIndex;

  while (idx > 0) {
    const isRightChild = idx % 2 === 0;
    const siblingIdx = isRightChild ? idx - 1 : idx + 1;
    pathBufs.push(tree[siblingIdx]);
    indices.push(isRightChild ? 1 : 0);
    idx = Math.floor((idx - 1) / 2);
  }

  return { path: pathBufs, indices };
}

function computeEffectiveRoot(leaf: Buffer, pathBufs: Buffer[], indices: number[]): Buffer {
  let current = leaf;
  for (let i = 0; i < MERKLE_DEPTH; i++) {
    const sibling = i < pathBufs.length ? pathBufs[i] : Buffer.alloc(32);
    const idx = i < indices.length ? indices[i] : 0;
    current = idx === 1
      ? hashPair(sibling, current)
      : hashPair(current, sibling);
  }
  return current;
}

function bufTo32Array(buf: Buffer): number[] {
  const arr: number[] = Array(32).fill(0);
  for (let i = 0; i < Math.min(buf.length, 32); i++) {
    arr[i] = buf[i];
  }
  return arr;
}

function generateProverToml(
  voter: { address: string; balance: bigint },
  pathBufs: Buffer[],
  pathIndices: number[],
  root: Buffer,
  minBalance: bigint,
): string {
  const addrBytes = Array(45).fill(0);
  const utf8 = Buffer.from(voter.address, 'utf8');
  for (let i = 0; i < Math.min(utf8.length, 45); i++) {
    addrBytes[i] = utf8[i];
  }

  // Pad path to MERKLE_DEPTH
  while (pathBufs.length < MERKLE_DEPTH) {
    pathBufs.push(Buffer.alloc(32));
    pathIndices.push(0);
  }

  const pathArrays = pathBufs.map(b => `[${bufTo32Array(b).join(', ')}]`);
  const rootArray = bufTo32Array(root).join(', ');

  return `# Prover.toml - baby-proof Noir circuit
# Voter: ${voter.address}
# Balance: ${Number(voter.balance) / 1_000_000} BABY (${voter.balance} ubbn)
# Min balance: ${Number(minBalance) / 1_000_000} BABY
# Root: 0x${root.toString('hex')}
# Generated: ${new Date().toISOString()}
#
# Run: nargo prove   (in baby-proof/)
# Run: nargo verify (in baby-proof/)

address_bytes = [${addrBytes.join(', ')}]
balance = "${voter.balance}"
path = [
${pathArrays.map(p => `    ${p}`).join(',\n')}
]
indices = [${pathIndices.join(', ')}]

# Public inputs
root = [${rootArray}]
min_balance = "${minBalance}"
`;
}

function main() {
  const args = process.argv.slice(2);
  const voterArg = args[args.indexOf('--voter') + 1] as string | undefined;
  const minBalanceArg = args[args.indexOf('--min-balance') + 1] as string | undefined;
  const minBalance = minBalanceArg ? BigInt(minBalanceArg) : DEFAULT_MIN_BALANCE;

  const address = voterArg ?? DEFAULT_VOTER;
  const holderIdx = DEMO_HOLDERS.findIndex(h => h.address === address);

  if (holderIdx === -1) {
    console.error(`Voter not in demo snapshot: ${address}`);
    console.error('Available:', DEMO_HOLDERS.map(h => h.address).join('\n  '));
    process.exit(1);
  }

  const voter = DEMO_HOLDERS[holderIdx];
  const { tree, size } = buildMerkleTree(DEMO_HOLDERS);
  const { path: merklePath, indices } = getMerklePath(tree, size, holderIdx);

  const leaf = hashLeaf(voter.address, voter.balance);
  const root = computeEffectiveRoot(leaf, [...merklePath], [...indices]);

  const toml = generateProverToml(voter, merklePath, indices, root, minBalance);

  const realOut = path.join(process.cwd(), 'baby-proof', 'Prover.toml');
  fs.writeFileSync(realOut, toml);

  console.log(`Prover.toml written to ${realOut}`);
  console.log(`  Voter:    ${voter.address}`);
  console.log(`  Balance:  ${Number(voter.balance) / 1_000_000} BABY`);
  console.log(`  Root:     0x${root.toString('hex')}`);
  console.log('');
  console.log('Next steps:');
  console.log('  cd baby-proof && nargo prove');
  console.log('  nargo verify');
}

main();
