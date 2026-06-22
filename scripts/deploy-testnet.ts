/* eslint-disable no-console */
/**
 * Deploys the PrivateVoting contract to Aztec Alpha testnet using a config from
 * scripts/deploy.config.json. Run with:
 *
 *   AZTEC_PXE_URL=http://localhost:8080 \
 *   DEPLOYER_SECRET_KEY=0x... \
 *   DEPLOYER_SIGNING_KEY=0x... \
 *   tsx scripts/deploy-testnet.ts
 *
 * Prerequisites:
 *   1. `nargo compile` has produced contracts/target/private_voting-PrivateVoting.json
 *   2. A PXE is running and pointed at the testnet node
 *      (https://v5.testnet.rpc.aztec-labs.com)
 *   3. The deployer wallet is funded with testnet fee tokens
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

interface DeployConfig {
  title: string;
  description: string;
  options: string[];
  startTimeOffsetSeconds: number;
  durationSeconds: number;
  quorum: number;
  /**
   * Eligibility modes:
   *   'open'       — no eligibility check (anyone can vote)
   *   'token'      — AztecAddress holds >= minTokenBalance of tokenAddress ERC-20
   *   'allowlist'  — AztecAddress is in committed SHA-256 Merkle allowlist tree
   *   'babylon-v2' — secp256k1 key owner committed in M2 SHA-256d hash160 Merkle tree
   *                  Auto-reads snapshot/merkle-root-v2.json (or snapshotRootPath)
   */
  eligibilityMode: 'open' | 'token' | 'allowlist' | 'babylon-v2';
  tokenAddress?: string;
  minTokenBalance?: string;
  allowlistRoot?: string;
  /**
   * babylon-v2 only: path to merkle-root-v2.json produced by
   * `synthetic-snapshot.ts --version 2`.  Defaults to snapshot/merkle-root-v2.json.
   */
  snapshotRootPath?: string;
}

interface SnapshotRootV2 {
  version: number;
  root: string;
  rootAsField: string;
  minBalance: string;
  treeDepth: number;
  treeSize: number;
}

async function main(): Promise<void> {
  const pxeUrl = required('AZTEC_PXE_URL');
  const deployerSecret = required('DEPLOYER_SECRET_KEY');
  const deployerSigning = required('DEPLOYER_SIGNING_KEY');

  const configPath = path.join(repoRoot, 'scripts/deploy.config.json');
  const artifactPath = path.join(
    repoRoot,
    'contracts/target/private_voting-PrivateVoting.json',
  );

  const [configRaw, artifactRaw] = await Promise.all([
    fs.readFile(configPath, 'utf8'),
    fs.readFile(artifactPath, 'utf8'),
  ]);
  const config = JSON.parse(configRaw) as DeployConfig;
  const artifact = JSON.parse(artifactRaw);

  const { Contract, Fr, GrumpkinScalar, AztecAddress, createPXEClient, waitForPXE } =
    await import('@aztec/aztec.js');
  const { poseidon2Hash } = await import('@aztec/foundation/crypto');
  const { getSchnorrAccount } = await import('@aztec/accounts/schnorr');

  console.log(`Connecting to PXE at ${pxeUrl}`);
  const pxe = createPXEClient(pxeUrl);
  await waitForPXE(pxe);

  const account = await getSchnorrAccount(
    pxe,
    Fr.fromString(deployerSecret),
    GrumpkinScalar.fromString(deployerSigning),
  );
  const deployedAccount = await account.deploy().wait();
  const wallet = await account.getWallet();
  console.log(`Deployer wallet ready: ${deployedAccount.address.toString()}`);

  const titleHash = await hashTitle(config.title, Fr, poseidon2Hash);
  const startTime = BigInt(
    Math.floor(Date.now() / 1000) + config.startTimeOffsetSeconds,
  );
  const endTime = startTime + BigInt(config.durationSeconds);

  // ── babylon-v2: load M2 snapshot root and encode as token_address ──────────
  let resolvedTokenAddress = config.tokenAddress;
  let resolvedMinTokenBalance = config.minTokenBalance;

  if (config.eligibilityMode === 'babylon-v2') {
    const rootPath = config.snapshotRootPath
      ? path.resolve(repoRoot, config.snapshotRootPath)
      : path.join(repoRoot, 'snapshot/merkle-root-v2.json');

    let snapshotRaw: string;
    try {
      snapshotRaw = await fs.readFile(rootPath, 'utf8');
    } catch {
      console.error(
        `babylon-v2 requires snapshot/merkle-root-v2.json. Generate it with:\n` +
        `  npx tsx scripts/synthetic-snapshot.ts --version 2\n` +
        `or set snapshotRootPath in deploy.config.json.`,
      );
      process.exit(1);
    }
    const snap = JSON.parse(snapshotRaw) as SnapshotRootV2;

    if (snap.version !== 2) {
      console.error(`Expected snapshot version 2, got ${snap.version}. Run synthetic-snapshot.ts --version 2.`);
      process.exit(1);
    }

    // rootAsField is the lower 31 bytes of the SHA-256 root, encoded as a hex
    // field element. It is stored in VoteConfig.token_address so that
    // cast_vote_babylon_v2 can recover root_bytes via encode_field_as_root().
    resolvedTokenAddress = snap.rootAsField;
    resolvedMinTokenBalance = resolvedMinTokenBalance ?? snap.minBalance;

    console.log('babylon-v2 snapshot root loaded:');
    console.log(`  root (SHA-256):     ${snap.root}`);
    console.log(`  root (Field/addr):  ${snap.rootAsField}`);
    console.log(`  min balance:        ${resolvedMinTokenBalance} ubbn`);
    console.log(`  tree size:          ${snap.treeSize} leaves (depth ${snap.treeDepth})`);
  }

  const tokenAddress = resolvedTokenAddress
    ? AztecAddress.fromString(resolvedTokenAddress)
    : AztecAddress.ZERO;
  const minTokenBalance = resolvedMinTokenBalance ? BigInt(resolvedMinTokenBalance) : 0n;

  const voteConfig = {
    title_hash: new Fr(titleHash),
    options_count: config.options.length,
    start_time: startTime,
    end_time: endTime,
    quorum: BigInt(config.quorum),
    eligibility_mode: eligibilityModeToCode(config.eligibilityMode),
    token_address: tokenAddress,
    min_token_balance: minTokenBalance,
  };

  console.log('Deploying PrivateVoting contract with config:', {
    title: config.title,
    options: config.options,
    startTime: new Date(Number(startTime) * 1000).toISOString(),
    endTime: new Date(Number(endTime) * 1000).toISOString(),
    quorum: config.quorum,
    eligibilityMode: config.eligibilityMode,
  });

  const deployment = await Contract.deploy(
    wallet,
    artifact,
    [wallet.getAddress(), voteConfig],
    'constructor',
  )
    .send()
    .deployed();

  const address = deployment.address.toString();
  console.log('\nDeployed PrivateVoting contract:');
  console.log(`  address: ${address}`);

  const out = {
    network: 'aztec-alpha-testnet',
    contractAddress: address,
    deployedAt: new Date().toISOString(),
    title: config.title,
    description: config.description,
    options: config.options,
    startTime: Number(startTime) * 1000,
    endTime: Number(endTime) * 1000,
    quorum: config.quorum,
    eligibilityMode: config.eligibilityMode,
    // token / babylon-v2
    ...(resolvedTokenAddress ? { tokenAddress: resolvedTokenAddress } : {}),
    ...(resolvedMinTokenBalance ? { minTokenBalance: resolvedMinTokenBalance } : {}),
    // allowlist
    ...(config.allowlistRoot ? { allowlistRoot: config.allowlistRoot } : {}),
    // babylon-v2 snapshot provenance
    ...(config.eligibilityMode === 'babylon-v2'
      ? { snapshotRootPath: config.snapshotRootPath ?? 'snapshot/merkle-root-v2.json' }
      : {}),
  };

  const outPath = path.join(repoRoot, 'deployments/alpha-testnet.json');
  await fs.mkdir(path.dirname(outPath), { recursive: true });
  await fs.writeFile(outPath, `${JSON.stringify(out, null, 2)}\n`);
  console.log(`\nWrote deployment metadata to ${path.relative(repoRoot, outPath)}`);
  console.log(
    '\nNext: paste the contract address into demo/.env.local as NEXT_PUBLIC_VOTE_CONTRACT_ADDRESS',
  );
}

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    console.error(`Missing required environment variable: ${name}`);
    process.exit(1);
  }
  return value;
}

function eligibilityModeToCode(mode: DeployConfig['eligibilityMode']): number {
  switch (mode) {
    case 'open':
      return 0;
    case 'token':
      return 1;
    case 'allowlist':
      return 2;
    case 'babylon-v2':
      // Circuit uses TOKEN mode (1); root is stored in token_address.
      // Callers use cast_vote_babylon_v2() rather than cast_vote_token().
      return 1;
  }
}

interface FrCtor {
  new (value: bigint): { toBigInt: () => bigint };
}

interface PoseidonHash {
  (input: Array<{ toBigInt: () => bigint }>): Promise<{ toBigInt: () => bigint }>;
}

async function hashTitle(
  title: string,
  Fr: FrCtor,
  poseidon2Hash: PoseidonHash,
): Promise<bigint> {
  const encoder = new TextEncoder();
  const bytes = encoder.encode(title);
  const fields: Array<{ toBigInt: () => bigint }> = [];
  for (let i = 0; i < bytes.length; i += 31) {
    const chunk = bytes.slice(i, i + 31);
    let value = 0n;
    for (const byte of chunk) {
      value = (value << 8n) | BigInt(byte);
    }
    fields.push(new Fr(value));
  }
  if (fields.length === 0) {
    fields.push(new Fr(0n));
  }
  const hash = await poseidon2Hash(fields);
  return hash.toBigInt();
}

main().catch((err) => {
  console.error('Deployment failed:', err);
  process.exit(1);
});
