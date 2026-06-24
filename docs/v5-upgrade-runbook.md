# Aztec v5 Testnet Upgrade — Post-Upgrade Runbook

**Upgrade completed:** June 17–18, 2026. **State reset confirmed June 18, 2026.**  
v4 contract `0x1a8efeffe...` is gone. v5.0.0-rc.1 is the live testnet RC.  
**v5 endpoint confirmed live 2026-06-22 (block 5620):** `https://v5.testnet.rpc.aztec-labs.com`  

> **Status as of 2026-06-22:** Skip Step 1 (upgrade already done) and Step 2 (old contract confirmed gone). Go directly to **Step 3** to deploy fresh on v5.

---

## Step 1: Confirm upgrade is live ✅ DONE

Upgrade completed 2026-06-18. v5 endpoint is live.

```bash
# Endpoint: https://v5.testnet.rpc.aztec-labs.com  (NOT the old rpc.testnet.aztec-labs.com)
curl -s -X POST https://v5.testnet.rpc.aztec-labs.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"node_getBlockNumber","params":[],"id":1}'
```

Confirmed response 2026-06-22: `{"result":5620}` (block advancing). ✅

---

## Step 2: Run the deployment health check ⚠️ SKIP — v4 contract gone

The v4 contract `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981` was wiped
by the state reset on 2026-06-18. `verify-deployment.ts` will return an error — that is expected.

Skip to **Step 3** for the fresh v5 deploy.

---

## Step 3: Fresh deploy on v5 (if needed / for M1 milestone)

### 3a. Check testnet RPC health ✅ CONFIRMED LIVE

```bash
curl -s -X POST https://v5.testnet.rpc.aztec-labs.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"node_getBlockNumber","params":[],"id":1}'
```

Confirmed live 2026-06-22 at block 5620. Block number should be > 5620 and incrementing.

### 3b. Install v5 CLI

```bash
export AZTEC_VERSION=5.0.0-rc.1
curl -fsSL https://install.aztec.network | bash
# Adds ~/.aztec/bin to PATH; may need to restart shell
export PATH="$HOME/.aztec/bin:$PATH"
```

### 3b-compile. Recompile contract ✅ DONE (tick-3812, 2026-06-24)

> **Artifact freshly compiled 2026-06-24** with nargo 1.0.0-beta.22. Now includes all June 22
> security patches: F1-RESIDUAL cast_vote mode restriction, EIP-191 circuit (ADR-036 Path C),
> N-F4 constructor guard. 17 functions, 512,340 chars bytecode.

> **Note:** nargo beta.22 removed `std::hash::keccak256`. Fixed in this commit:
> - `contracts/Nargo.toml`: added `keccak256 = { tag = "v0.1.3", git = "https://github.com/noir-lang/keccak256" }`
> - `contracts/src/main.nr`: changed `use std::hash::keccak256` → `keccak256::keccak256(...)` call directly

If you need to recompile manually:
```bash
export PATH="$HOME/.nargo/bin:$PATH"
cd contracts
nargo compile
# Should produce: contracts/target/private_voting-PrivateVoting.json
# Verify no compile errors before proceeding to 3d.
```

### 3c. Check fee juice balance for deployer2

The L1→L2 bridge bug is fixed in v5. The pending L1 message may have been processed automatically by the new sequencer. Check first:

```bash
export AZTEC_NODE_URL=https://v5.testnet.rpc.aztec-labs.com

aztec-wallet get-fee-juice-balance \
  0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343 \
  --node-url $AZTEC_NODE_URL
```

**State reset means:** old fee juice claim is gone. You will likely need to bridge fresh:

```bash
# Bridge 1 ETH of fee juice — use Nethermind faucet (aztec-faucet.nethermind.io)
# if you need test ETH first. Then:
aztec-wallet bridge-fee-juice 1000000000000000000 \
  0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343 \
  --node-url $AZTEC_NODE_URL

# Wait ~2-5 min for L1→L2 message to be processed, then re-check balance.
```

### 3d. Deploy contract

The repo's deploy script (`scripts/deploy-testnet.ts`) is the preferred path — it reads
`scripts/deploy.config.json`, hashes the title, and writes the deployment record.

```bash
export AZTEC_PXE_URL=https://v5.testnet.rpc.aztec-labs.com
export DEPLOYER_SECRET_KEY=0x<your-deployer-secret-key>
export DEPLOYER_SIGNING_KEY=0x<your-deployer-signing-key>

npx tsx scripts/deploy-testnet.ts
```

Alternatively, with aztec-wallet:

```bash
aztec-wallet deploy contracts/target/private_voting-PrivateVoting.json \
  --from accounts:deployer2 \
  --node-url https://v5.testnet.rpc.aztec-labs.com
```

Save the new address to `deployments/alpha-testnet-v5.json` (keep `alpha-testnet.json` for grant reference).

**After deploy:** Update `GRANT.md` §2 with the new contract address and replace
`deployments/alpha-testnet.json` address field — then update the forum post before submitting.

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

- **v4 contract (GONE — state reset 2026-06-18):** `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981`
- **v5 contract address:** TBD after Step 3d redeploy
- v4 Deploy tx (historical): `0x095bfd5cf1fe53fd2b55f2896124ef3f8b43ffd7f70a688bb967d6998e2e1dc5`
- Deployer1: `0x065824b54ec4c5a14de7c38e7e47aa05da6604809bb4959664e737b3e42fe238`
- Deployer2 (fee juice needs re-bridging after reset): `0x270bf32fab16dae45123d09cfc69882117ee0a48c9cc54e51c757fdb8ea48343`
- v5 endpoint: `https://v5.testnet.rpc.aztec-labs.com` (confirmed live 2026-06-22, block 5620)
- Deploy script: `scripts/deploy-testnet.ts` (needs DEPLOYER_SECRET_KEY + DEPLOYER_SIGNING_KEY)
- Grant post: `docs/forum-post-grant-application.md`
- Verify script: `scripts/verify-deployment.ts`

---

_Created: 2026-06-16 (tick-3043). Corrected: tick-3044 — replaced non-existent `aztec-cli faucet claim` with `aztec-wallet get-fee-juice-balance` + `bridge-fee-juice` (correct v4/v5 CLI). Added balance-check step before fresh bridge. Updated tick-3646 (2026-06-22): fixed all endpoint URLs to v5 (`https://v5.testnet.rpc.aztec-labs.com`); old `https://rpc.testnet.aztec-labs.com` is unreachable. Confirmed v5 live at block 5620. Noted state reset — Step 2 (verify old contract) now skipped; Step 3 is the required path. Added DEPLOYER_SECRET_KEY/DEPLOYER_SIGNING_KEY env vars to Step 3d. Updated tick-3805 (2026-06-24): added Step 3b-compile — artifact stale since May 25; three June 22 security changes (F1-RESIDUAL, EIP-191, N-F4) require fresh nargo compile before deploy._
