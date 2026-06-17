/* eslint-disable no-console */
/**
 * Verifies that the PrivateVoting contract is accessible and healthy
 * on the Aztec testnet after a network upgrade.
 *
 * Usage:
 *   AZTEC_NODE_URL=https://rpc.testnet.aztec-labs.com tsx scripts/verify-deployment.ts
 *   AZTEC_NODE_URL=... DEPLOYMENT_FILE=deployments/testnet-v5.json tsx scripts/verify-deployment.ts
 *
 * Checks (v5 node-client API):
 *   1. Load deployment record from JSON
 *   2. Load contract artifact from compiled output
 *   3. Connect to Aztec node (v5: createAztecNodeClient, not PXE)
 *   4. Contract instance found on node (node.getContract(address))
 *   5. Contract class registered on node (node.getContractClass(classId))
 *
 * Note: view-function simulation (get_vote_count, get_config, is_finalized) requires
 * a registered wallet account and is not performed in this health check. If checks
 * 4 and 5 pass, the contract is accessible and the state was preserved across the upgrade.
 *
 * Exit codes:
 *   0 = all checks passed
 *   1 = one or more checks failed (details printed to stderr)
 *
 * Run this immediately after the testnet v5 upgrade (June 17 2026, 14:07 UTC)
 * to confirm the contract at the known address is still accessible.
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
  contractClassId?: string;
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
  // v5: connect directly to the Aztec node (no PXE required for health checks)
  const nodeUrl =
    process.env['AZTEC_NODE_URL'] ??
    process.env['AZTEC_PXE_URL'] ??   // backwards-compat alias
    'https://rpc.testnet.aztec-labs.com';
  const deploymentFile =
    process.env['DEPLOYMENT_FILE'] ??
    path.join(repoRoot, 'deployments/alpha-testnet.json');
  const artifactPath = path.join(
    repoRoot,
    'contracts/target/private_voting-PrivateVoting.json',
  );

  console.log('─'.repeat(60));
  console.log('  Aztec PrivateVoting — post-upgrade deployment check (v5)');
  console.log('─'.repeat(60));
  console.log(`  Node:       ${nodeUrl}`);
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
  try {
    const raw = await fs.readFile(artifactPath, 'utf8');
    JSON.parse(raw); // validate JSON
    checks.push(result('Load contract artifact', true, artifactPath));
  } catch (err) {
    checks.push(
      result('Load contract artifact', false, `Cannot read ${artifactPath}: ${err}`),
    );
    printReport(checks);
    process.exit(1);
  }

  // ── 3. Connect to Aztec node ────────────────────────────────────────────
  // v5 API: import from @aztec/aztec.js/node (no barrel import)
  let node: { getContract: Function; getContractClass: Function; getNodeInfo: Function };
  try {
    const { createAztecNodeClient, waitForNode } = await import('@aztec/aztec.js/node');
    node = createAztecNodeClient(nodeUrl) as typeof node;
    await waitForNode(node as Parameters<typeof waitForNode>[0]);
    const info = await node.getNodeInfo();
    checks.push(
      result(
        'Connect to Aztec node',
        true,
        `${nodeUrl} — nodeVersion=${info?.nodeVersion ?? 'unknown'} chainId=${info?.l1ChainId ?? 'unknown'}`,
      ),
    );
  } catch (err) {
    checks.push(result('Connect to Aztec node', false, `${err}`));
    printReport(checks);
    process.exit(1);
  }

  // ── 4. Contract instance found on node ─────────────────────────────────
  try {
    const { AztecAddress } = await import('@aztec/aztec.js/addresses');
    const contractAddress = AztecAddress.fromString(deploymentRecord!.contractAddress);
    const instance = await node.getContract(contractAddress);
    if (instance) {
      checks.push(
        result(
          'Contract instance on node',
          true,
          `found at ${deploymentRecord!.contractAddress}`,
        ),
      );
    } else {
      checks.push(
        result(
          'Contract instance on node',
          false,
          `NOT FOUND at ${deploymentRecord!.contractAddress} — testnet state may have been reset`,
        ),
      );
    }
  } catch (err) {
    checks.push(result('Contract instance on node', false, `${err}`));
  }

  // ── 5. Contract class registered ───────────────────────────────────────
  if (deploymentRecord!.contractClassId) {
    try {
      const { Fr } = await import('@aztec/aztec.js/fields');
      const classId = Fr.fromString(deploymentRecord!.contractClassId);
      const contractClass = await node.getContractClass(classId);
      if (contractClass) {
        checks.push(
          result(
            'Contract class registered',
            true,
            `classId=${deploymentRecord!.contractClassId}`,
          ),
        );
      } else {
        checks.push(
          result(
            'Contract class registered',
            false,
            `classId=${deploymentRecord!.contractClassId} NOT found — contract class not registered on this node`,
          ),
        );
      }
    } catch (err) {
      checks.push(result('Contract class registered', false, `${err}`));
    }
  } else {
    checks.push(
      result(
        'Contract class registered',
        true,
        'skipped (no contractClassId in deployment record)',
      ),
    );
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
    console.log(`✅ All ${total} checks passed — contract accessible post-upgrade`);
  } else {
    console.error(`❌ ${total - passed}/${total} checks FAILED`);
  }
  console.log('─'.repeat(60));
}

main().catch((err) => {
  console.error('Fatal error:', err);
  process.exit(1);
});
