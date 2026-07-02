# ADR-038: M2 RIPEMD-160 Upgrade — Real Cosmos hash160

**Date:** 2026-07-02 (tick-4460)  
**Status:** Decision memo — **Jony must approve and coordinate testnet redeploy**  
**Author:** OpenClaw Agent  
**Resolves:** M2 design spec Risk 1 (`docs/m2-secp256k1-ownership-proof-design.md §9`)  
**Supersedes:** SHA-256d fallback (Fallback B) in `contracts/src/merkle.nr::derive_hash160_sha256d`  
**Relates to:** `docs/adr-036-m2-wallet-signing-path.md`, `docs/m2-benchmark-2026-06-27.md`

---

## 1. Status update — Risk 1 is now unblocked

The M2 design spec §9 Risk 1 flagged RIPEMD-160 availability in Noir as the blocker:

> _"Fallback B (SHA-256d) uses `sha256(sha256(pk_x || pk_y))[12..32]` which produces different addresses from real Cosmos bbn1… addresses. Replace with ripemd160(sha256(compressed_pubkey)) once noir-ripemd160 crate compatibility is confirmed for nargo >=0.30."_

**The blocker is resolved.** As of 2025-11-11, `distributed-lab/noir-ripemd160` released **v0.0.4** with a clean `pub fn ripemd160<let N: u32>(message: [u8; N]) -> [u8; 20]` interface. No `nargo` version pin in its `Nargo.toml` — compatible with all nargo ≥ 0.30.

```toml
[dependencies]
ripemd160 = { tag = "v0.0.4", git = "https://github.com/distributed-lab/noir-ripemd160" }
```

Library interface (confirmed from source):
```noir
use ripemd160::ripemd160;

// Accepts a fixed-size byte array; returns 20-byte RIPEMD-160 hash
pub fn ripemd160<let N: u32>(message: [u8; N]) -> [u8; 20] { ... }
```

---

## 2. What changes and why it matters

### 2a. Current state (Fallback B — PROTOTYPE)

```noir
// merkle.nr::derive_hash160_sha256d
// hash160 = sha256(sha256(pubkey_x[32] || pubkey_y[32]))[12..32]
let hash160 = derive_hash160_sha256d(pubkey_x, pubkey_y);
```

This produces **different addresses from real Cosmos (Babylon) addresses.** The real Cosmos derivation is:

```
hash160 = ripemd160( sha256( compressed_pubkey[33] ) )
```

where `compressed_pubkey[0] = 0x02 if pubkey_y is even, else 0x03`, followed by `pubkey_x[32]`.

**Practical consequence:** The current M2 deployment cannot verify ownership against the **real** Babylon (BABY) snapshot, only against a synthetic snapshot generated with the same SHA-256d scheme. This means the ownership proof loop is incomplete — a real Babylon holder's Merkle path would fail to verify because the leaf was built with a different address derivation.

### 2b. Target state (Production Cosmos hash160)

```noir
// Derive Cosmos-standard hash160 from secp256k1 public key
// Inputs: raw uncompressed point coordinates (circuit already receives these for EIP-191)
// Output: 20-byte address commitment matching bbn1… decoded hash
fn derive_hash160_cosmos(pubkey_x: [u8; 32], pubkey_y: [u8; 32]) -> [u8; 20] {
    // 1. Build compressed pubkey: prefix (02/03) + x (32 bytes)
    //    Cosmos uses SEC1 compressed form; prefix is 0x02 if y is even, 0x03 if odd.
    //    "Even" = low bit of y's least significant byte = 0.
    let prefix: u8 = if (pubkey_y[31] & 1) == 0 { 0x02 } else { 0x03 };
    let mut compressed = [0u8; 33];
    compressed[0] = prefix;
    for i in 0..32 { compressed[i + 1] = pubkey_x[i]; }

    // 2. SHA-256(compressed_pubkey[33]) — compatible with sha256_var
    let sha256_output = sha256_var(compressed, 33);

    // 3. RIPEMD-160(sha256_output[32]) — now available via distributed-lab/noir-ripemd160
    ripemd160(sha256_output)
}
```

This matches the standard Bitcoin/Cosmos address derivation exactly.

---

## 3. Required code changes

### 3a. `contracts/Nargo.toml`

Add the RIPEMD-160 dependency:

```toml
[dependencies]
aztec    = { git = "https://github.com/AztecProtocol/aztec-packages", tag = "v5.0.0-rc.1", directory = "noir-projects/aztec-nr/aztec" }
sha256   = { tag = "v0.3.0", git = "https://github.com/noir-lang/sha256" }
keccak256 = { tag = "v0.1.3", git = "https://github.com/noir-lang/keccak256" }
ripemd160 = { tag = "v0.0.4", git = "https://github.com/distributed-lab/noir-ripemd160" }  # NEW
```

### 3b. `contracts/src/merkle.nr`

Replace `derive_hash160_sha256d` with `derive_hash160_cosmos`:

```noir
// ADD at top of file:
use ripemd160::ripemd160;

// REPLACE derive_hash160_sha256d with:
/// Derive Cosmos-standard 20-byte hash160 from secp256k1 public key.
/// Implements: hash160 = ripemd160( sha256( SEC1_compressed_pubkey[33] ) )
/// This is the standard Bitcoin/Cosmos address derivation and produces addresses
/// that match real bbn1… decoded witnesses.
///
/// Both this function AND the snapshot generator (scripts/generate-m2-snapshot.ts)
/// MUST use this derivation. A coordinated upgrade is required (see ADR-038).
pub fn derive_hash160_cosmos(pubkey_x: [u8; 32], pubkey_y: [u8; 32]) -> [u8; 20] {
    // SEC1 compressed: 0x02 if y even, 0x03 if y odd
    let prefix: u8 = if (pubkey_y[31] & 1) == 0 { 0x02 } else { 0x03 };
    let mut compressed = [0u8; 33];
    compressed[0] = prefix;
    for i in 0..32 { compressed[i + 1] = pubkey_x[i]; }

    let sha256_of_pk = sha256_var(compressed, 33);
    ripemd160(sha256_of_pk)
}
```

Update call site in `main.nr` line 416:

```noir
// BEFORE:
let hash160 = derive_hash160_sha256d(pubkey_x, pubkey_y);
// AFTER:
let hash160 = derive_hash160_cosmos(pubkey_x, pubkey_y);
```

Update imports in `main.nr` line 28:

```noir
// BEFORE:
    derive_hash160_sha256d,
// AFTER:
    derive_hash160_cosmos,
```

### 3c. `scripts/synthetic-snapshot.ts`

The TypeScript snapshot generator must use the matching Cosmos derivation. Add `@noble/hashes` (already a standard crypto dependency):

```typescript
import { ripemd160 } from '@noble/hashes/ripemd160';
import { sha256 }    from '@noble/hashes/sha256';

// Replace deriveHash160V2 (SHA-256d) with:
function deriveHash160Cosmos(pubkeyX: Uint8Array, pubkeyY: Uint8Array): Uint8Array {
  // SEC1 compressed pubkey
  const prefix = (pubkeyY[31] & 1) === 0 ? 0x02 : 0x03;
  const compressed = new Uint8Array(33);
  compressed[0] = prefix;
  compressed.set(pubkeyX, 1);
  // hash160 = RIPEMD-160(SHA-256(compressed))
  return ripemd160(sha256(compressed));
}
```

Update `hashLeafV2` to call `deriveHash160Cosmos` and bump snapshot version to `3` (or keep `2` if snapshot format is otherwise unchanged — recommend bumping to distinguish from SHA-256d snapshots).

### 3d. `GRANT.md` update

Remove the SHA-256d deviation note. Replace with:

> _"Address commitment uses the standard Cosmos hash160 derivation (`ripemd160(sha256(compressed_pubkey))`) implemented via `distributed-lab/noir-ripemd160 v0.0.4` in the Noir circuit and `@noble/hashes` in the TypeScript snapshot generator. The derivation produces addresses that match real Babylon (BBN) bbn1… holders."_

---

## 4. Coordination requirements

This upgrade requires **three changes in lockstep**, all before testnet redeployment:

| Step | File | Who | Blocking |
|------|------|-----|---------|
| 1 | `contracts/Nargo.toml` — add ripemd160 dep | Agent (can do autonomously) | Circuit compilation |
| 2 | `contracts/src/merkle.nr` — replace derive_hash160 | Agent (can do autonomously) | Circuit correctness |
| 3 | `contracts/src/main.nr` — update import + call site | Agent (can do autonomously) | Circuit correctness |
| 4 | `scripts/synthetic-snapshot.ts` — use Cosmos derivation | Agent (can do autonomously) | Snapshot/Merkle root match |
| 5 | Regenerate real M2 snapshot from BABY snapshot | Jony — needs BABY holder data | Deployment |
| 6 | Run `nargo test` to verify all M2 tests pass | Jony — needs nargo installed | Correctness gate |
| 7 | Redeploy testnet with new Merkle root | Jony — needs Aztec sandbox | Testnet validity |

Steps 1–4 can be applied by the agent in a single commit. Steps 5–7 require Jony.

---

## 5. Gate cost estimate for ripemd160

Current M2 benchmark (SHA-256d path, from `docs/m2-benchmark-2026-06-27.md`):

```
ACIR: 339 opcodes | Brillig: 348 opcodes
(sha256 challenge + EIP-191 keccak256 + secp256k1 verify)
```

Adding the Cosmos hash160 path replaces the two `sha256_var` calls in `derive_hash160_sha256d` with one `sha256_var(compressed, 33)` + one `ripemd160(sha256_output)`. Net change:

| Operation | Δ ACIR | Δ Brillig (est.) |
|-----------|--------|-----------------|
| Remove sha256_var(pk_bytes, 64) | –N | –N |
| Remove sha256_var(inner, 32) | –N | –N |
| Add sha256_var(compressed, 33) | ≈+same | ≈+same |
| Add ripemd160([u8; 32]) | +small | +200–400 |

**Net estimate: +0 to +50 ACIR, +150–350 Brillig opcodes.** RIPEMD-160 is a pure Brillig function (no circuit constraints). This should not meaningfully affect total proving time.

> Note: Accurate gate count requires `nargo info` on the upgraded circuit. Run as step 6 above.

---

## 6. Compatibility risks

### Risk A: `WrappingAdd` availability
The library uses `use std::ops::WrappingAdd`. This trait was added to the Noir stdlib in ~v0.30. Our contract requires `compiler_version = ">=0.30.0"` — **compatible**.

### Risk B: Slice API
The library uses `message.as_slice().push_back(...)` for padding. The slice API is stable in Noir ≥ 0.27. **Compatible** with nargo 0.30+.

### Risk C: Existing tests break
All existing M2 tests (in `m2-sig-tests/` and `contracts/src/merkle.nr`) use the SHA-256d derivation. After the upgrade, test vectors must be regenerated with the Cosmos derivation. The test harness structure is unchanged; only the expected hash160 values change. The 4 secp256k1 signature tests in `m2-sig-tests/` test the signing path only (not address derivation) — those continue to pass unchanged.

### Risk D: Snapshot incompatibility
Any existing M2 Merkle snapshot (files in `scripts/` or `snapshot/`) generated with SHA-256d is **invalid** after this upgrade. The upgrade effectively requires a fresh snapshot from the BABY holder data. This is expected — document in the commit message.

---

## 7. Summary / recommended action

**This is a security improvement** — the SHA-256d fallback is explicitly a prototype deviation that prevents M2 from verifying against real Cosmos addresses. Now that `distributed-lab/noir-ripemd160 v0.0.4` is available, Fallback B should be replaced with the production Cosmos derivation.

**Agent can apply steps 1–4 in a single commit** (code changes only; no testnet impact until redeployment).

**Jony must:**
1. Review this ADR and confirm the approach
2. Run `nargo test` after the commit to verify all tests pass
3. Regenerate the M2 snapshot from real BABY holder data
4. Redeploy testnet with the new Merkle root (follow `docs/v5-upgrade-runbook.md`)
5. Update `GRANT.md` M2 section to remove SHA-256d deviation note

**Proceed with code changes (steps 1–4)?** → If yes, agent applies in next tick. If no, current SHA-256d fallback remains documented as a named deviation.
