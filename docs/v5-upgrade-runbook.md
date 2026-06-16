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

### 3b. Retry fee juice claim (v5 CLI)

The L1→L2 bridge bug is fixed in v5. Retry the claim from `memory/umbra-claim-pending.md`:

```bash
# Install v5 CLI (update version as needed)
export AZTEC_VERSION=5.0.0-rc.1
curl -fsSL https://install.aztec.network | bash
# OR: npx @aztec/aztec@latest

export AZTEC_NODE_URL=https://rpc.testnet.aztec-labs.com

# Claim fee juice for deployer2 (params in memory/umbra-claim-pending.md)
aztec-cli faucet claim \
  --secret 0x0276531fcb42a3097b3d13cc21ce65ab96cc7aae57c336f0bdb6b1328eb3f3f7 \
  --claim-amount 100000000000000000000 \
  --claim-secret 0x0b7a37023821edc35df3ce5bc85eaf5e24318e49f3299f0ac35e1af5d4ae9f4d \
  --message-leaf-index 81928192
```

### 3c. Deploy contract

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

_Created: 2026-06-16 (tick-3043)_
