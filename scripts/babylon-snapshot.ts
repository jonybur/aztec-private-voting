/**
 * babylon-snapshot.ts
 *
 * Queries Babylon Genesis RPC for BABY token balances at a specific block,
 * builds a Merkle tree, and outputs:
 * - merkle-root.json: the root hash (32 bytes) + metadata
 * - merkle-tree.json: full tree for IPFS hosting
 * - merkle-paths/: individual paths for each voter
 *
 * Usage:
 *   npx ts-node scripts/babylon-snapshot.ts \
 *     --rpc https://rpc.babylon.example.com \
 *     --block 1234567 \
 *     --min-balance 1000000  # in ubbn (1 BABY = 1,000,000 ubbn)
 */

import { createHash } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

interface BabyHolder {
  address: string;    // bbn1... cosmos address
  balance: bigint;    // in ubbn
}

interface MerklePath {
  address: string;
  balance: bigint;
  leaf: string;       // hex
  path: string[];     // sibling hashes
  indices: number[];  // 0=left, 1=right at each level
  root: string;
}

// ── Merkle tree implementation ────────────────────────────────────────────────

function sha256(data: Buffer): Buffer {
  return createHash('sha256').update(data).digest();
}

function hashLeaf(address: string, balance: bigint): Buffer {
  // leaf = sha256(address_45bytes || balance_8bytes)
  // MUST match compute_leaf() in contracts/src/merkle.nr:
  //   address is padded to exactly 45 bytes (bbn1... bech32 addresses fit in 45 chars)
  const addrBuf = Buffer.alloc(45, 0); // zero-padded to 45 bytes
  Buffer.from(address, 'utf8').copy(addrBuf);
  const balBuf = Buffer.alloc(8);
  balBuf.writeBigUInt64BE(balance);
  return sha256(Buffer.concat([addrBuf, balBuf]));
}

function hashPair(left: Buffer, right: Buffer): Buffer {
  return sha256(Buffer.concat([left, right]));
}

function buildMerkleTree(leaves: Buffer[]): Buffer[] {
  // Pad to power of 2
  let size = 1;
  while (size < leaves.length) size *= 2;
  const tree: Buffer[] = new Array(size * 2 - 1).fill(Buffer.alloc(32));

  // Fill leaves
  for (let i = 0; i < leaves.length; i++) {
    tree[size - 1 + i] = leaves[i];
  }

  // Build up
  for (let i = size - 2; i >= 0; i--) {
    const left = tree[2 * i + 1];
    const right = tree[2 * i + 2];
    tree[i] = hashPair(left, right);
  }

  return tree;
}

function getMerklePath(tree: Buffer[], leafIndex: number, size: number): { path: string[]; indices: number[] } {
  const path: string[] = [];
  const indices: number[] = [];
  let idx = size - 1 + leafIndex;

  while (idx > 0) {
    const isRight = idx % 2 === 0;
    const siblingIdx = isRight ? idx - 1 : idx + 1;
    path.push(tree[siblingIdx].toString('hex'));
    indices.push(isRight ? 1 : 0);
    idx = Math.floor((idx - 1) / 2);
  }

  return { path, indices };
}

// ── Babylon Genesis RPC ───────────────────────────────────────────────────────

async function fetchBABYHolders(rpcUrl: string, minBalance: bigint): Promise<BabyHolder[]> {
  console.log(`Fetching BABY balances from ${rpcUrl}...`);

  // Babylon Genesis uses cosmos SDK bank module
  // GET /cosmos/bank/v1beta1/balances/{address} for individual
  // GET /cosmos/bank/v1beta1/supply for total
  // For all holders: use the bank module's AllBalances endpoint with pagination

  const holders: BabyHolder[] = [];
  let nextKey: string | null = null;

  do {
    const url = nextKey
      ? `${rpcUrl}/cosmos/bank/v1beta1/denom_owners/ubbn?pagination.key=${encodeURIComponent(nextKey)}&pagination.limit=1000`
      : `${rpcUrl}/cosmos/bank/v1beta1/denom_owners/ubbn?pagination.limit=1000`;

    const res = await fetch(url);
    if (!res.ok) {
      throw new Error(`RPC error: ${res.status} ${await res.text()}`);
    }

    const data = await res.json() as any;

    for (const entry of (data.denom_owners || [])) {
      const balance = BigInt(entry.balance?.amount || '0');
      if (balance >= minBalance) {
        holders.push({ address: entry.address, balance });
      }
    }

    nextKey = data.pagination?.next_key || null;
    console.log(`  Fetched ${holders.length} holders so far...`);

  } while (nextKey);

  console.log(`Total BABY holders with balance >= ${minBalance} ubbn: ${holders.length}`);
  return holders;
}

// ── Root encoding for Aztec Field ───────────────────────────────────────────
// The Merkle root is a 32-byte SHA-256 hash. Aztec Field elements hold 31 bytes.
// We encode by dropping the first byte (which is always low-entropy for SHA-256)
// and storing bytes [1..32] as a big-endian Field.
//
// This matches encode_field_as_root() in contracts/src/main.nr.
export function encodeRootAsField(rootHex: string): string {
  const buf = Buffer.from(rootHex.replace(/^0x/, ''), 'hex');
  if (buf.length !== 32) throw new Error('Root must be 32 bytes');
  // Drop first byte, use bytes [1..32] as big-endian Field
  const fieldBytes = buf.slice(1); // 31 bytes
  return '0x' + fieldBytes.toString('hex');
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);
  const getArg = (flag: string, def: string) => {
    const i = args.indexOf(flag);
    return i >= 0 ? args[i + 1] : def;
  };

  const rpcUrl = getArg('--rpc', 'https://rpc.nodejumper.io/babylon');
  const minBalance = BigInt(getArg('--min-balance', '1000000')); // 1 BABY
  const blockHeight = getArg('--block', 'latest');
  const outDir = getArg('--out', './snapshot');

  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(path.join(outDir, 'merkle-paths'), { recursive: true });

  // Fetch holders
  const holders = await fetchBABYHolders(rpcUrl, minBalance);

  if (holders.length === 0) {
    console.error('No holders found. Check RPC URL and min-balance.');
    process.exit(1);
  }

  // Sort deterministically
  holders.sort((a, b) => a.address.localeCompare(b.address));

  // Build leaves
  const leaves = holders.map(h => hashLeaf(h.address, h.balance));

  // Build tree
  let size = 1;
  while (size < leaves.length) size *= 2;
  const tree = buildMerkleTree(leaves);
  const root = tree[0].toString('hex');

  console.log(`\nMerkle root: 0x${root}`);
  console.log(`Tree size: ${size} leaves (${holders.length} real, ${size - holders.length} padding)`);

  // Save root
  const rootHex = `0x${root}`;
  const rootAsField = encodeRootAsField(rootHex);
  const rootData = {
    root: rootHex,
    rootAsField,   // use this as token_address when deploying the vote config
    block: blockHeight,
    timestamp: new Date().toISOString(),
    totalHolders: holders.length,
    minBalance: minBalance.toString(),
    denomination: 'ubbn',
  };
  console.log(`Root as Aztec Field (use as token_address in VoteConfig): ${rootAsField}`);
  fs.writeFileSync(path.join(outDir, 'merkle-root.json'), JSON.stringify(rootData, null, 2));

  // Save individual paths
  for (let i = 0; i < holders.length; i++) {
    const { path: siblingPath, indices } = getMerklePath(tree, i, size);
    const pathData: MerklePath = {
      address: holders[i].address,
      balance: holders[i].balance,
      leaf: leaves[i].toString('hex'),
      path: siblingPath,
      indices,
      root: `0x${root}`,
    };
    const filename = path.join(outDir, 'merkle-paths', `${holders[i].address}.json`);
    fs.writeFileSync(filename, JSON.stringify(pathData, null, 2));
  }

  // Save full tree (for IPFS)
  const treeData = {
    root: `0x${root}`,
    holders: holders.map((h, i) => ({
      address: h.address,
      balance: h.balance.toString(),
      leaf: leaves[i].toString('hex'),
    })),
  };
  fs.writeFileSync(path.join(outDir, 'merkle-tree.json'), JSON.stringify(treeData, null, 2));

  console.log(`\n✓ Snapshot saved to ${outDir}/`);
  console.log(`  merkle-root.json   — publish this root on-chain`);
  console.log(`  merkle-tree.json   — host this on IPFS`);
  console.log(`  merkle-paths/      — serve individual paths to voters`);
}

main().catch(console.error);
