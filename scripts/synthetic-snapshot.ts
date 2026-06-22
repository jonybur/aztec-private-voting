/**
 * synthetic-snapshot.ts
 *
 * Generates a fully synthetic eligibility set for the Babylon-style demo:
 * deterministic fake bbn1... addresses with pseudo-random balances. No data
 * is fetched from Babylon Genesis and no real holder appears anywhere.
 *
 * Builds the same SHA-256 Merkle tree as the Noir circuit (depth 20) and
 * outputs:
 * - merkle-root.json: the root hash (32 bytes) + metadata
 * - prover-synthetic.json: one synthetic holder's Merkle path
 * - baby-proof/Prover.toml: witness for the standalone proof circuit
 *
 * Usage:
 *   npx tsx scripts/synthetic-snapshot.ts \
 *     --holders 10000 \
 *     --min-balance 1000000  # in ubbn (1 BABY = 1,000,000 ubbn)
 */

import { createHash } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

interface SyntheticHolder {
  address: string;    // bbn1... cosmos address (synthetic, deterministic)
  balance: bigint;    // in ubbn
}

interface SyntheticHolderV2 {
  pubkeyX: Buffer;    // secp256k1 x-coordinate (32 bytes, synthetic)
  pubkeyY: Buffer;    // secp256k1 y-coordinate (32 bytes, synthetic)
  hash160: Buffer;    // SHA-256d address: sha256(sha256(x||y))[12..32] (20 bytes)
  balance: bigint;    // in ubbn
}

interface MerklePath {
  address: string;
  balance: string;
  leaf: string;       // hex
  path: string[];     // sibling hashes
  indices: number[];  // 0=left, 1=right at each level
  root: string;
}

interface MerklePathV2 {
  pubkeyX: string;    // hex (32 bytes)
  pubkeyY: string;    // hex (32 bytes)
  hash160: string;    // hex (20 bytes)
  balance: string;
  leaf: string;       // hex
  path: string[];     // sibling hashes
  indices: number[];  // 0=left, 1=right at each level
  root: string;
}

const MERKLE_DEPTH = 20;
const TREE_SIZE = 2 ** MERKLE_DEPTH;

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

function buildMerkleTree(leaves: Buffer[], size: number): Buffer[] {
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

function verifyMerklePath(leaf: Buffer, siblings: string[], indices: number[], root: Buffer): boolean {
  let current = leaf;
  for (let i = 0; i < siblings.length; i++) {
    const sibling = Buffer.from(siblings[i], 'hex');
    current = indices[i] === 1 ? hashPair(sibling, current) : hashPair(current, sibling);
  }
  return current.equals(root);
}

// ── Bech32 encoding (BIP-173) ─────────────────────────────────────────────────
// Produces structurally valid bbn1... addresses from synthetic key material.
// These addresses do not correspond to any real keypair or holder.

const BECH32_CHARSET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const BECH32_GEN = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];

function bech32Polymod(values: number[]): number {
  let chk = 1;
  for (const v of values) {
    const top = chk >> 25;
    chk = ((chk & 0x1ffffff) << 5) ^ v;
    for (let i = 0; i < 5; i++) {
      if ((top >> i) & 1) chk ^= BECH32_GEN[i];
    }
  }
  return chk;
}

function bech32HrpExpand(hrp: string): number[] {
  const out: number[] = [];
  for (const c of hrp) out.push(c.charCodeAt(0) >> 5);
  out.push(0);
  for (const c of hrp) out.push(c.charCodeAt(0) & 31);
  return out;
}

function bech32CreateChecksum(hrp: string, data: number[]): number[] {
  const values = [...bech32HrpExpand(hrp), ...data, 0, 0, 0, 0, 0, 0];
  const polymod = bech32Polymod(values) ^ 1;
  const out: number[] = [];
  for (let i = 0; i < 6; i++) out.push((polymod >> (5 * (5 - i))) & 31);
  return out;
}

function convertBits(data: Buffer, fromBits: number, toBits: number): number[] {
  let acc = 0;
  let bits = 0;
  const out: number[] = [];
  const maxv = (1 << toBits) - 1;
  for (const value of data) {
    acc = (acc << fromBits) | value;
    bits += fromBits;
    while (bits >= toBits) {
      bits -= toBits;
      out.push((acc >> bits) & maxv);
    }
  }
  if (bits > 0) out.push((acc << (toBits - bits)) & maxv);
  return out;
}

function bech32Encode(hrp: string, payload: Buffer): string {
  const data = convertBits(payload, 8, 5);
  const checksum = bech32CreateChecksum(hrp, data);
  return `${hrp}1${[...data, ...checksum].map(d => BECH32_CHARSET[d]).join('')}`;
}

// ── M2: SHA-256d address derivation ─────────────────────────────────────────
// Matches derive_hash160_sha256d() in contracts/src/merkle.nr:
//   hash160 = sha256(sha256(pubkey_x[32] || pubkey_y[32]))[12..32]
// This is Fallback B — a research-only deviation from standard Cosmos address
// derivation (which uses RIPEMD-160). Both the circuit and this generator must
// use the same scheme. Documented in docs/m2-secp256k1-ownership-proof-design.md §9.

function deriveHash160V2(pubkeyX: Buffer, pubkeyY: Buffer): Buffer {
  const combined = Buffer.concat([pubkeyX, pubkeyY]); // 64 bytes
  const inner = sha256(combined);                      // SHA-256(x || y)
  const outer = sha256(inner);                         // SHA-256(SHA-256(x || y))
  return outer.subarray(12); // last 20 bytes
}

// M2 leaf: sha256(hash160[20] || balance_be8)
// Matches compute_leaf_v2() in contracts/src/merkle.nr.
function hashLeafV2(hash160: Buffer, balance: bigint): Buffer {
  const buf = Buffer.alloc(28);
  hash160.copy(buf, 0, 0, 20);
  buf.writeBigUInt64BE(balance, 20);
  return sha256(buf);
}

// ── Synthetic holder generation ───────────────────────────────────────────────

function generateSyntheticHolders(count: number, minBalance: bigint): SyntheticHolder[] {
  const holders: SyntheticHolder[] = [];
  for (let i = 0; i < count; i++) {
    const seed = sha256(Buffer.from(`umbra-synthetic-holder-${i}`, 'utf8'));
    const address = bech32Encode('bbn', seed.subarray(0, 20));
    // Balance in [minBalance, minBalance + 999 BABY), deterministic from the seed
    const balance = minBalance + BigInt(seed.readUInt32BE(20) % 999_000_000);
    holders.push({ address, balance });
  }
  return holders;
}

// ── M2: Synthetic V2 holder generation ──────────────────────────────────────
// Generates deterministic synthetic secp256k1 public key coordinates.
// These are NOT valid secp256k1 points — they are raw byte seeds for the
// SHA-256d derivation chain. For a valid secp256k1 proof, real keypairs are
// required (see wallet.signArbitrary() in the React layer).

function generateSyntheticHoldersV2(count: number, minBalance: bigint): SyntheticHolderV2[] {
  const holders: SyntheticHolderV2[] = [];
  for (let i = 0; i < count; i++) {
    // Deterministic seed → synthetic "public key" bytes
    const seedX = sha256(Buffer.from(`umbra-synthetic-v2-x-${i}`, 'utf8'));
    const seedY = sha256(Buffer.from(`umbra-synthetic-v2-y-${i}`, 'utf8'));
    const pubkeyX = Buffer.from(seedX); // 32 bytes
    const pubkeyY = Buffer.from(seedY); // 32 bytes
    const hash160 = deriveHash160V2(pubkeyX, pubkeyY);
    // Balance in [minBalance, minBalance + 999 BABY), deterministic from seed
    const balanceSeed = sha256(Buffer.from(`umbra-synthetic-v2-bal-${i}`, 'utf8'));
    const balance = minBalance + BigInt(balanceSeed.readUInt32BE(0) % 999_000_000);
    holders.push({ pubkeyX, pubkeyY, hash160, balance });
  }
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
  const fieldBytes = buf.subarray(1); // 31 bytes
  return '0x' + fieldBytes.toString('hex');
}

// ── Prover.toml generation ────────────────────────────────────────────────────

function toByteArrayLiteral(buf: Buffer): string {
  return `[${Array.from(buf).join(', ')}]`;
}

function buildProverToml(holder: SyntheticHolder, leaf: Buffer, siblings: string[], indices: number[], root: Buffer, minBalance: bigint, generatedAt: string): string {
  const addrBuf = Buffer.alloc(45, 0);
  Buffer.from(holder.address, 'utf8').copy(addrBuf);
  const pathRows = siblings
    .map(s => `    ${toByteArrayLiteral(Buffer.from(s, 'hex'))}`)
    .join(',\n');

  return `# Prover.toml - baby-proof Noir circuit (SYNTHETIC SNAPSHOT)
# Voter:   ${holder.address} (synthetic, not a real holder)
# Balance: ${(Number(holder.balance) / 1_000_000).toFixed(6)} BABY (${holder.balance} ubbn)
# Min bal: ${(Number(minBalance) / 1_000_000).toFixed(1)} BABY
# Root:    0x${root.toString('hex')}
# Source:  Synthetic eligibility set (scripts/synthetic-snapshot.ts)
# Generated: ${generatedAt}
#
# Run: cd baby-proof && nargo prove
# Run: cd baby-proof && nargo verify

address_bytes = ${toByteArrayLiteral(addrBuf)}
balance = "${holder.balance}"
path = [
${pathRows}
]
indices = [${indices.join(', ')}]

# Public inputs
root = ${toByteArrayLiteral(root)}
min_balance = "${minBalance}"
`;
}

// ── V2 Prover.toml builder ────────────────────────────────────────────────────
// Produces witness file for the cast_vote_babylon_v2 circuit.
// NOTE: sig_r and sig_s are zero-filled placeholders — a valid signature
// requires the holder's real secp256k1 private key. The Merkle path fields
// are real and self-consistent with the generated M2 snapshot.
function buildProverTomlV2(
  holder: SyntheticHolderV2,
  leaf: Buffer,
  siblings: string[],
  indices: number[],
  root: Buffer,
  minBalance: bigint,
  generatedAt: string,
): string {
  const pathRows = siblings
    .map(s => `    ${toByteArrayLiteral(Buffer.from(s, 'hex'))}`)
    .join(',\n');

  const zeroes32 = toByteArrayLiteral(Buffer.alloc(32, 0));

  return `# Prover.toml - cast_vote_babylon_v2 (M2 SYNTHETIC SNAPSHOT)
# PROTOTYPE DEVIATION: SHA-256d address derivation (not standard Cosmos RIPEMD-160)
# hash160 = sha256(sha256(pubkey_x || pubkey_y))[12..32]
#
# hash160: 0x${holder.hash160.toString('hex')}
# Balance: ${(Number(holder.balance) / 1_000_000).toFixed(6)} BABY (${holder.balance} ubbn)
# Min bal: ${(Number(minBalance) / 1_000_000).toFixed(1)} BABY
# Root:    0x${root.toString('hex')}
# Source:  Synthetic M2 snapshot (scripts/synthetic-snapshot.ts --version 2)
# Generated: ${generatedAt}
#
# ⚠️  sig_r and sig_s are ZERO PLACEHOLDERS — real secp256k1 signature required.
#     Use wallet.signArbitrary(challenge) to obtain valid (sig_r, sig_s) values.
#     Challenge = sha256(encode_field(title_hash) || encode_field(root_field))
#
# Run once real sig is populated:
#   cd baby-proof && nargo prove
#   cd baby-proof && nargo verify

vote_choice = "0"
balance = "${holder.balance}"

pubkey_x = ${toByteArrayLiteral(holder.pubkeyX)}
pubkey_y = ${toByteArrayLiteral(holder.pubkeyY)}

# PLACEHOLDER: replace with real secp256k1 signature
sig_r = ${zeroes32}
sig_s = ${zeroes32}

path = [
${pathRows}
]
indices = [${indices.join(', ')}]

# Public inputs
root = ${toByteArrayLiteral(root)}
min_balance = "${minBalance}"
`;
}

// ── Main ──────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  const getArg = (flag: string, def: string) => {
    const i = args.indexOf(flag);
    return i >= 0 ? args[i + 1] : def;
  };

  const holderCount = parseInt(getArg('--holders', '10000'), 10);
  const minBalance = BigInt(getArg('--min-balance', '1000000')); // 1 BABY
  const outDir = getArg('--out', './snapshot');
  const version = parseInt(getArg('--version', '1'), 10);

  if (version !== 1 && version !== 2) {
    console.error('--version must be 1 (M1 bech32 leaves) or 2 (M2 SHA-256d hash160 leaves)');
    process.exit(1);
  }

  fs.mkdirSync(outDir, { recursive: true });

  const generatedAt = new Date().toISOString();

  if (version === 2) {
    // ── M2 mode ──────────────────────────────────────────────────────────────
    console.log(`Generating ${holderCount} synthetic M2 holders (SHA-256d hash160 leaves)...`);
    const holdersV2 = generateSyntheticHoldersV2(holderCount, minBalance);

    // Sort deterministically by hash160 hex
    holdersV2.sort((a, b) => a.hash160.toString('hex').localeCompare(b.hash160.toString('hex')));

    const leavesV2 = holdersV2.map(h => hashLeafV2(h.hash160, h.balance));
    console.log(`Building depth-${MERKLE_DEPTH} Merkle tree (${TREE_SIZE} leaves)...`);
    const treeV2 = buildMerkleTree(leavesV2, TREE_SIZE);
    const rootV2 = treeV2[0];
    const rootHexV2 = `0x${rootV2.toString('hex')}`;
    const rootAsFieldV2 = encodeRootAsField(rootHexV2);

    console.log(`\nMerkle root (M2): ${rootHexV2}`);
    console.log(`Root as Aztec Field (use as token_address in VoteConfig): ${rootAsFieldV2}`);

    // Self-check the first holder's path
    const sampleIndexV2 = 0;
    const { path: siblingPathV2, indices: indicesV2 } = getMerklePath(treeV2, sampleIndexV2, TREE_SIZE);
    if (!verifyMerklePath(leavesV2[sampleIndexV2], siblingPathV2, indicesV2, rootV2)) {
      throw new Error('Self-check failed: M2 Merkle path does not verify against root');
    }

    const rootDataV2 = {
      version: 2,
      snapshotFormat: 'SHA-256d hash160 (PROTOTYPE DEVIATION from standard Cosmos RIPEMD-160)',
      root: rootHexV2,
      rootAsField: rootAsFieldV2,
      timestamp: generatedAt,
      totalHolders: holdersV2.length,
      minBalance: minBalance.toString(),
      denomination: 'ubbn',
      treeSize: TREE_SIZE,
      treeDepth: MERKLE_DEPTH,
      note: 'Synthetic M2 eligibility set. Public key bytes are deterministic seeds — not real secp256k1 points. For production, regenerate from real holder keypairs.',
      sample: {
        pubkeyX: holdersV2[0].pubkeyX.toString('hex'),
        hash160: holdersV2[0].hash160.toString('hex'),
        balance: holdersV2[0].balance.toString(),
        balanceBABY: Number(holdersV2[0].balance) / 1_000_000,
      },
    };
    fs.writeFileSync(path.join(outDir, 'merkle-root-v2.json'), JSON.stringify(rootDataV2, null, 2));

    const pathDataV2: MerklePathV2 = {
      pubkeyX: holdersV2[sampleIndexV2].pubkeyX.toString('hex'),
      pubkeyY: holdersV2[sampleIndexV2].pubkeyY.toString('hex'),
      hash160: holdersV2[sampleIndexV2].hash160.toString('hex'),
      balance: holdersV2[sampleIndexV2].balance.toString(),
      leaf: leavesV2[sampleIndexV2].toString('hex'),
      path: siblingPathV2,
      indices: indicesV2,
      root: rootHexV2,
    };
    fs.writeFileSync(path.join(outDir, 'prover-synthetic-v2.json'), JSON.stringify(pathDataV2, null, 2));

    const proverTomlV2 = buildProverTomlV2(
      holdersV2[sampleIndexV2], leavesV2[sampleIndexV2],
      siblingPathV2, indicesV2, rootV2, minBalance, generatedAt,
    );
    fs.writeFileSync(path.join('baby-proof', 'Prover-v2.toml'), proverTomlV2);

    const allHoldersV2 = holdersV2.map((h, i) => {
      const mp = getMerklePath(treeV2, i, TREE_SIZE);
      return {
        pubkeyX: h.pubkeyX.toString('hex'),
        pubkeyY: h.pubkeyY.toString('hex'),
        hash160: h.hash160.toString('hex'),
        balance: h.balance.toString(),
        leaf: leavesV2[i].toString('hex'),
        path: mp.path,
        indices: mp.indices,
      };
    });
    const allDataV2 = {
      version: 2,
      snapshotFormat: 'SHA-256d hash160 (PROTOTYPE DEVIATION from standard Cosmos RIPEMD-160)',
      note: 'Synthetic M2 eligibility set. Public key bytes are deterministic seeds.',
      root: rootHexV2,
      rootAsField: rootAsFieldV2,
      minBalance: minBalance.toString(),
      treeDepth: MERKLE_DEPTH,
      treeSize: TREE_SIZE,
      timestamp: generatedAt,
      holders: allHoldersV2,
    };
    fs.writeFileSync(path.join(outDir, 'synthetic-holders-v2.json'), JSON.stringify(allDataV2));

    console.log(`\n✓ Synthetic M2 snapshot saved`);
    console.log(`  ${outDir}/merkle-root-v2.json       — M2 root + metadata`);
    console.log(`  ${outDir}/prover-synthetic-v2.json  — sample holder M2 Merkle path`);
    console.log(`  ${outDir}/synthetic-holders-v2.json — all ${holdersV2.length} M2 holders + paths`);
    console.log(`  baby-proof/Prover-v2.toml           — M2 circuit witness (sig placeholders)`);
    console.log(`\nTo use with cast_vote_babylon_v2:`);
    console.log(`  Deploy vote with token_address = ${rootAsFieldV2}`);
    console.log(`  Voter signs: sha256(encode_field(title_hash) || encode_field(root_field))`);
    console.log(`  Pass pubkey_x, pubkey_y, sig_r, sig_s as private witnesses.`);

  } else {
    // ── M1 mode (default) ─────────────────────────────────────────────────────
    console.log(`Generating ${holderCount} synthetic holders...`);
    const holders = generateSyntheticHolders(holderCount, minBalance);

    // Sort deterministically
    holders.sort((a, b) => a.address.localeCompare(b.address));

    // Build leaves and tree at the fixed circuit depth
    const leaves = holders.map(h => hashLeaf(h.address, h.balance));
    console.log(`Building depth-${MERKLE_DEPTH} Merkle tree (${TREE_SIZE} leaves)...`);
    const tree = buildMerkleTree(leaves, TREE_SIZE);
    const root = tree[0];
    const rootHex = `0x${root.toString('hex')}`;

    console.log(`\nMerkle root: ${rootHex}`);

    // Save root
    const rootAsField = encodeRootAsField(rootHex);
    const rootData = {
      version: 1,
      root: rootHex,
      rootAsField,   // use this as token_address when deploying the vote config
      timestamp: generatedAt,
      totalHolders: holders.length,
      minBalance: minBalance.toString(),
      denomination: 'ubbn',
      treeSize: TREE_SIZE,
      treeDepth: MERKLE_DEPTH,
      note: 'Synthetic eligibility set. Addresses are deterministically generated and do not correspond to real Babylon Genesis holders.',
      sample: {
        address: holders[0].address,
        balance: holders[0].balance.toString(),
        balanceBABY: Number(holders[0].balance) / 1_000_000,
      },
    };
    console.log(`Root as Aztec Field (use as token_address in VoteConfig): ${rootAsField}`);
    fs.writeFileSync(path.join(outDir, 'merkle-root.json'), JSON.stringify(rootData, null, 2));

    // Save one synthetic holder's path + Prover.toml witness
    const sampleIndex = 0;
    const { path: siblingPath, indices } = getMerklePath(tree, sampleIndex, TREE_SIZE);
    if (!verifyMerklePath(leaves[sampleIndex], siblingPath, indices, root)) {
      throw new Error('Self-check failed: Merkle path does not verify against root');
    }
    const pathData: MerklePath = {
      address: holders[sampleIndex].address,
      balance: holders[sampleIndex].balance.toString(),
      leaf: leaves[sampleIndex].toString('hex'),
      path: siblingPath,
      indices,
      root: rootHex,
    };
    fs.writeFileSync(path.join(outDir, 'prover-synthetic.json'), JSON.stringify(pathData, null, 2));

    const proverToml = buildProverToml(holders[sampleIndex], leaves[sampleIndex], siblingPath, indices, root, minBalance, generatedAt);
    fs.writeFileSync(path.join('baby-proof', 'Prover.toml'), proverToml);

    // Dump ALL synthetic holder paths so the demo can serve `path(address)` lookups
    // without a live fetcher. The eligibility set is synthetic; the file is safe
    // to ship with the demo bundle.
    const allHolders = holders.map((h, i) => {
      const mp = getMerklePath(tree, i, TREE_SIZE);
      return {
        address: h.address,
        balance: h.balance.toString(),
        leaf: leaves[i].toString('hex'),
        path: mp.path,
        indices: mp.indices,
      };
    });
    const allData = {
      version: 1,
      note: 'Synthetic eligibility set. Addresses are deterministically generated and do not correspond to real Babylon Genesis holders.',
      root: rootHex,
      rootAsField,
      minBalance: minBalance.toString(),
      treeDepth: MERKLE_DEPTH,
      treeSize: TREE_SIZE,
      timestamp: generatedAt,
      holders: allHolders,
    };
    fs.writeFileSync(path.join(outDir, 'synthetic-holders.json'), JSON.stringify(allData));

    console.log(`\n✓ Synthetic snapshot saved`);
    console.log(`  ${outDir}/merkle-root.json       — synthetic root + metadata`);
    console.log(`  ${outDir}/prover-synthetic.json  — sample holder Merkle path`);
    console.log(`  ${outDir}/synthetic-holders.json — all ${holders.length} synthetic holders + paths`);
    console.log(`  baby-proof/Prover.toml           — circuit witness (synthetic voter)`);
  }
}

main();
