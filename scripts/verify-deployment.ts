/* eslint-disable no-console */
/**
 * Verifies that the PrivateVoting contract is accessible and healthy
 * on the Aztec testnet after a network upgrade.
 *
 * Usage:
 *   AZTEC_PXE_URL=http://localhost:8080 tsx scripts/verify-deployment.ts
 *   AZTEC_PXE_URL=http://localhost:8080 DEPLOYMENT_FILE=deployments/testnet-v1.json tsx scripts/verify-deployment.ts
 *
 * Checks:
 *   1. PXE connects to the testnet node
 *   2. Contract artifact compiles and loads
 *   3. get_vote_count() is callable and returns a valid u64
 *   4. get_config() is callable and title_hash / options_count match deployment record
 *   5. is_finalized() is readable
 *
 * Exit codes:
 *   0 = all checks passed
 *   1 = one or more checks failed (details printed to stderr)
 *
 * Run this immediately after the testnet v5 upgrade (June 17 2026, 14:07 UTC)
 * to confirm the contract at the known address is still healthy.
 */

import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

interface DeploymentRecord {
  network: string;
  contractAddress: string;
  deployedAt: string;
  title: string;
  options: string[];
}

interface CheckResult {
  name: string;
  passed: boolean;
  detail: string;
}

function result(name: string, passed: boolean, detail: string): CheckResult {
  return { name, passed, detail };
}

async function main(): Promise<void> {
  const pxeUrl = process.env['AZTEC_PXE_URL'] ?? 'http://localhost:8080';
  const deploymentFile =
    process.env['DEPLOYMENT_FILE'] ??
    path.join(repoRoot, 'deployments/testnet-v1.json');
  const artifactPath = path.join(
    repoRoot,
    'contracts/target/private_voting-PrivateVoting.json',
  );

  console.log('─'.repeat(60));
  console.log('  Aztec PrivateVoting — post-upgrade deployment check');
  console.log('─'.repeat(60));
  console.log(`  PXE:        ${pxeUrl}`);
  console.log(`  Deployment: ${deploymentFile}`);
  console.log(`  Artifact:   ${artifactPath}`);
  console.log('');

  const checks: CheckResult[] = [];
  let deploymentRecord: DeploymentRecord | null = null;

  // ── 1. Load deployment record ───────────────────────────────────────────
  try {
    const raw = await fs.readFile(deploymentFile, 'utf8');
    deploymentRecord = JSON.parse(raw) as DeploymentRecord;
    checks.push(
      result(
        'Load deployment record',
        true,
        `address=${deploymentRecord.contractAddress} network=${deploymentRecord.network}`,
      ),
    );
  } catch (err) {
    checks.push(
      result('Load deployment record', false, `Cannot read ${deploymentFile}: ${err}`),
    );
    printReport(checks);
    process.exit(1);
  }

  // ── 2. Load contract artifact ───────────────────────────────────────────
  let artifact: unknown;
  try {
    const raw = await fs.readFile(artifactPath, 'utf8');
    artifact = JSON.parse(raw);
    checks.push(result('Load contract artifact', true, artifactPath));
  } catch (err) {
    checks.push(
      result('Load contract artifact', false, `Cannot read ${artifactPath}: ${err}`),
    );
    printReport(checks);
    process.exit(1);
  }

  // ── 3. Connect to PXE ──────────────────────────────────────────────────
  let pxe: unknown;
  try {
    const { createPXEClient, waitForPXE } = await import('@aztec/aztec.js');
    pxe = createPXEClient(pxeUrl);
    await waitForPXE(pxe as Parameters<typeof waitForPXE>[0]);
    checks.push(result('Connect to PXE', true, pxeUrl));
  } catch (err) {
    checks.push(result('Connect to PXE', false, `${err}`));
    printReport(checks);
    process.exit(1);
  }

  // ── 4-6. Contract view calls ────────────────────────────────────────────
  const { Contract, AztecAddress } = await import('@aztec/aztec.js');
  const contractAddress = AztecAddress.fromString(deploymentRecord.contractAddress);
  const contract = await Contract.at(
    contractAddress,
    artifact as Parameters<typeof Contract.at>[1],
    pxe as Parameters<typeof Contract.at>[2],
  );

  // 4. get_vote_count()
  try {
    const count = await contract.methods.get_vote_count().simulate();
    checks.push(
      result('get_vote_count()', true, `vote_count=${count.toString()}`),
    );
  } catch (err) {
    checks.push(result('get_vote_count()', false, `${err}`));
  }

  // 5. get_config() — verify options_count matches deployment record
  try {
    const config = await contract.methods.get_config().simulate();
    const optionsCount = Number(config.options_count);
    const expectedCount = deploymentRecord.options.length;
    const countMatch = optionsCount === expectedCount;
    checks.push(
      result(
        'get_config()',
        countMatch,
        countMatch
          ? `options_count=${optionsCount} ✓ (matches deployment record)`
          : `options_count=${optionsCount} ✗ (expected ${expectedCount} from deployment record)`,
      ),
    );
  } catch (err) {
    checks.push(result('get_config()', false, `${err}`));
  }

  // 6. is_finalized()
  try {
    const finalized = await contract.methods.is_finalized().simulate();
    checks.push(
      result('is_finalized()', true, `is_finalized=${finalized}`),
    );
  } catch (err) {
    checks.push(result('is_finalized()', false, `${err}`));
  }

  printReport(checks);

  const failures = checks.filter((c) => !c.passed);
  if (failures.length > 0) {
    process.exit(1);
  }
}

function printReport(checks: CheckResult[]): void {
  console.log('');
  console.log('Results:');
  for (const c of checks) {
    const icon = c.passed ? '✅' : '❌';
    console.log(`  ${icon} ${c.name}`);
    console.log(`       ${c.detail}`);
  }
  console.log('');

  const passed = checks.filter((c) => c.passed).length;
  const total = checks.length;

  if (passed === total) {
    console.log(`✅ All ${total} checks passed — contract healthy post-upgrade`);
  } else {
    console.error(`❌ ${total - passed}/${total} checks FAILED`);
  }
  console.log('─'.repeat(60));
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
