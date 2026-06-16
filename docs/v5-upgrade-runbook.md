# Aztec v5 Testnet Upgrade — Post-Upgrade Runbook

**Upgrade scheduled:** June 17, 2026 at 14:07 UTC  
**v4 software retires** after the upgrade. v5.0.0-rc.1 is the first testnet RC.

---

## Step 1: Confirm upgrade is live (~14:15 UTC)

```bash
curl -s -X POST https://rpc.testnet.aztec-labs.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"node_getVersion","params":[],"id":1}' | python3 -m json.tool
```

Expected: `block_number` should be moving and version string should reference v5.

---

## Step 2: Run the deployment health check

```bash
cd /root/.openclaw/workspace/aztec-private-voting

# Requires a local PXE connected to testnet (start first if not running):
# aztec start --node --pxe --node.l1Contracts.rollupAddress=<v5-rollup-addr>

AZTEC_PXE_URL=http://localhost:8080 npx tsx scripts/verify-deployment.ts
```

**What it checks:**
- Loads `deployments/alpha-testnet.json` (contract at `0x1a8efeffe...`)
- Connects to PXE → testnet node
- Calls `get_vote_count()`, `get_config()`, `is_finalized()` as view calls
- Exit 0 = healthy, exit 1 = one or more checks failed

**If it passes:** Contract is live on v5. Grant post remains accurate. ✅

**If it fails:** The alpha-testnet contract may not survive the v5 migration (expected — testnet state resets are possible). See Step 3 for fresh deploy.

---

## Step 3: Fresh deploy on v5 (if needed / for M1 milestone)

### 3a. Check testnet RPC health

```bash
curl -s -X POST https://rpc.testnet.aztec-labs.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"node_getBlockNumber","params":[],"id":1}'
```

Block number should be > 0 and incrementing.

### 3b. Install v5 CLI

```bash
export AZTEC_VERSION=5.0.0-rc.1
curl -fsSL https://install.aztec.network | bash
# Adds ~/.aztec/bin to PATH; may need to restart shell
export PATH="$HOME/.aztec/bin:$PATH"
```

### 3c. Check fee juice balance for deployer2

The L1→L2 bridge bug is fixed in v5. The pending L1 message may have been processed automatically by the new sequencer. Check first:

```bash
export AZTEC_NODE_URL=https://rpc.testnet.aztec-labs.com

aztec-wallet get-fee-juice-balance \
  0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343 \
  --node-url $AZTEC_NODE_URL
```

**If balance > 0:** Pending claim was processed. Skip to Step 3d.  
**If balance = 0 (or testnet state reset):** Bridge fresh fee juice:

```bash
# Bridge 1 ETH of fee juice for deployer2 (requires Sepolia ETH in wallet)
# Note: if testnet resets, the Nethermind faucet at aztec-faucet.nethermind.io
# will dispense test ETH directly — no Sepolia needed.
aztec-wallet bridge-fee-juice 1000000000000000000 \
  0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343 \
  --node-url $AZTEC_NODE_URL

# Wait ~2-5 min for L1→L2 message to be processed, then re-check balance.
```

### 3d. Deploy contract

```bash
aztec-wallet deploy contracts/target/private_voting-PrivateVoting.json \
  --from accounts:deployer2 \
  --node-url https://rpc.testnet.aztec-labs.com
```

Save the new address to `deployments/alpha-testnet-v5.json` (keep `alpha-testnet.json` for grant reference).

---

## Step 4: Submit the grant

The grant post is already correct and references the live alpha-testnet contract. If the contract survives the v5 upgrade (Step 2 passes), submit immediately:

**Forum post:** `drafts/aztec-grant-forum-post.md`  
**URL:** https://forum.aztec.network → Applications category  
**Title:** `[Grant Application] Aztec Private Voting — private ballot infrastructure for DAOs ($25K)`

After posting, drop the forum link in Aztec Discord `#grants` channel.

If a fresh v5 deploy completes (Step 3), update the forum post contract address before submitting.

---

## Reference

- Live contract: `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981`
- Deploy tx: `0x095bfd5cf1fe53fd2b55f2896124ef3f8b43ffd7f70a688bb967d6998e2e1dc5`
- Deployer1: `0x065824b54ec4c5a14de7c38e7e47aa05da6604809bb4959664e737b3e42fe238`
- Deployer2 (pending claim): `0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343`
- Grant post: `drafts/aztec-grant-forum-post.md`
- Verify script: `scripts/verify-deployment.ts`

---

_Created: 2026-06-16 (tick-3043). Corrected: tick-3044 — replaced non-existent `aztec-cli faucet claim` with `aztec-wallet get-fee-juice-balance` + `bridge-fee-juice` (correct v4/v5 CLI). Added balance-check step before fresh bridge._
