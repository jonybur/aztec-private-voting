# Security Review: Babylon M2 Paths (`cast_vote_babylon`, `cast_vote_babylon_v2`, `merkle.nr`)
**Date:** 2026-06-24  
**Author:** @jonybur-oc  
**Scope:** `cast_vote_babylon` (v1), `cast_vote_babylon_v2` (M2), and all Babylon-related functions in `merkle.nr`  
**Excluded:** Generic Aztec voting paths (reviewed separately in `security-review-2026-06-22.md`)  
**Method:** Static circuit analysis, trust-boundary audit, secp256k1 ownership-proof reasoning, Merkle commitment analysis  

---

## Executive Summary

The M2 Babylon circuit (`cast_vote_babylon_v2`) correctly closes the snapshot-forwarding
attack present in v1. The secp256k1 ownership proof is sound: an attacker with only the
public snapshot cannot produce a valid proof without the holder's Cosmos private key. The
nullifier is non-predictable, the challenge construction prevents cross-vote replay, and
the EIP-191 prefix encoding is byte-correct.

Five findings are documented below. **One MEDIUM finding (M2-F1)** concerns an implicit
deployment dependency: the contract exposes both M1 and M2 entrypoints without a
runtime version guard, relying on the deployer to commit the correct Merkle root format.
Three DESIGN findings (M2-F2, M2-F3, M2-F4) document documented architectural choices
appropriate for the prototype stage. One SOUND confirmation (M2-F5) validates the
EIP-191 byte encoding against the specification.

No critical privacy breaks were found in the M2 path.

---

## Findings Summary

| ID | Severity | Title | Status |
|----|----------|-------|--------|
| M2-F1 | MEDIUM | No runtime `snapshot_version` guard — M1/M2 dispatch is implicit | Documented; mitigation below |
| M2-F2 | DESIGN | EIP-191 path requires EVM wallet — Cosmos/Keplr not natively supported | Documented (ADR-036) |
| M2-F3 | DESIGN | `SingleUseClaim` not used — vote uniqueness per Cosmos address, not Aztec wallet | Correct by design |
| M2-F4 | DESIGN | `hash_bytes_as_field` drops top byte of SHA-256 — nullifier has 248-bit entropy | Negligible; sound |
| M2-F5 | SOUND | EIP-191 prefix bytes verified correct against MetaMask `personal_sign` spec | Confirmed ✓ |

---

## 1. Reviewed code

### `cast_vote_babylon_v2` (main.nr, steps 1–7)

1. Reconstruct Merkle root from `config.token_address` field.
2. Build vote-specific challenge: `sha256(title_hash_encoded[32] || root_bytes[32])`.
3. EIP-191 wrap: `msg_hash = keccak256("\x19Ethereum Signed Message:\n32" || challenge)`.
4. Verify secp256k1 signature: `assert(ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, msg_hash))`.
5. Derive 20-byte address commitment: `hash160 = derive_hash160_sha256d(pubkey_x, pubkey_y)`.
6. Verify Merkle membership: `verify_baby_eligibility_v2(hash160, balance, min_token_balance, path, indices, root_bytes)`.
7. Derive nullifier: `hash_bytes_as_field(sha256_var(sig, 64))`.

### `merkle.nr` Babylon functions reviewed

- `derive_hash160_sha256d`: SHA-256d fallback for address commitment from pubkey.
- `compute_leaf_v2`: `sha256(hash160[20] || balance_be[8])`.
- `verify_baby_eligibility_v2`: balance threshold check + Merkle membership.
- `compute_leaf` (v1): `sha256(address_bytes_bech32[45] || balance_be[8])`.
- `verify_baby_eligibility` (v1): bech32 path, used by `cast_vote_babylon`.

---

## 2. M2-F1 — MEDIUM: No runtime `snapshot_version` guard; M1/M2 dispatch is implicit

**Location:** `main.nr` — both `cast_vote_babylon` and `cast_vote_babylon_v2` are private entrypoints on the same contract.

**Background:**  
The design specification (`docs/m2-secp256k1-ownership-proof-design.md` §3) calls for a
`snapshot_version: u8` field in `VoteConfig` that would gate which Babylon entrypoint is
valid. This field was **not implemented**. `VoteConfig` has no version discriminant.

**Technical analysis:**  
The two Babylon entrypoints use incompatible Merkle leaf formats:
- **v1 leaf:** `sha256(address_bytes_bech32[45] || balance_be[8])` — 45-byte bech32 string
- **v2 leaf:** `sha256(hash160[20] || balance_be[8])` — 20-byte SHA-256d address commitment

A v2 Merkle root (hash160-format leaves) will not verify against any v1 Merkle proof
(bech32-format leaves), and vice versa. This creates an **implicit version gate**:
- Deployer commits v2 snapshot root → only v2 proofs verify → v1 attacks fail automatically.
- Deployer commits v1 snapshot root → only v1 proofs verify → v2 path is unusable.

The implicit gate is cryptographically sound (SHA-256 collision resistance guarantees
distinct leaf hashes for distinct formats). However:

1. **No feedback on misconfiguration.** A deployer who accidentally commits a v1
   (bech32) root to a contract intended for M2 silently falls back to v1 security
   properties — with no in-contract error. The v1 entrypoint has no ownership proof,
   so an attacker with the snapshot can cast ballots on behalf of any holder.

2. **No enforcement of "M2 only" intent.** A deployer who intends M2 has no way to
   mark the contract to reject v1 calls. Any Aztec user can call `cast_vote_babylon`
   (v1) at any time. If the deployer committed the v2 root, the v1 call fails during
   Merkle proof verification — but this relies on the Merkle root being correct, which
   is an off-chain guaranteee.

**Impact level:**  
MEDIUM — The implicit gate is sufficient IF the deployer commits the correct root format.
The risk is deployment error, not circuit unsoundness. An attacker who uses the v1
entrypoint against a v2-root contract will fail to generate a valid Merkle proof. No
privacy break occurs assuming the deployer correctly uses `synthetic-snapshot.ts
--version 2` to generate the root.

**Recommendation:**  
Add `pub snapshot_version: u8` to `VoteConfig` per the design spec. Add the following
assert at the top of `cast_vote_babylon`:

```noir
assert(config.snapshot_version == 0, "v1 snapshot: use cast_vote_babylon");
```

And at the top of `cast_vote_babylon_v2`:

```noir
assert(config.snapshot_version == 1, "v2 snapshot: use cast_vote_babylon_v2");
```

This converts a silent deployment risk to a contract-level runtime assertion, eliminates
the wrong-entrypoint ambiguity, and makes the intent explicit in the deployed VoteConfig.

**Grant blocker?** No — the implicit gate is sufficient for the demo + grant application.
Add `snapshot_version` before any production governance deployment.

---

## 3. M2-F2 — DESIGN: EIP-191 path requires EVM wallet; Cosmos/Keplr not natively supported

**Location:** `cast_vote_babylon_v2`, step 3 — EIP-191 wrapping hardcoded.

**Background:**  
ADR-036 (Path C) chose EIP-191 `personal_sign` for wallet compatibility with MetaMask,
Ledger, and WalletConnect. The Cosmos-native path (Keplr ADR-036 sign) was deferred as
a named extension.

**Analysis:**  
The Babylon governance use case involves Cosmos holders (bbn1… addresses) who typically
use Keplr or Leap, not MetaMask. Keplr's `signArbitrary` uses ADR-036 Cosmos signing,
not EIP-191. The current circuit is incompatible with Keplr out of the box.

**Current state:**  
The design spec (`docs/m2-secp256k1-ownership-proof-design.md` §7 Path A) documents
Keplr support as a future extension. ADR-036 explicitly defers Path A. This is an
appropriate prototype-stage trade-off.

**For production:** A second circuit variant or a configurable signing path is needed
before this can serve real Cosmos governance. The secp256k1 math is the same; only the
message prehashing differs (EIP-191 keccak256 vs. ADR-036 sha256).

**No action required for grant.** Document in grant application limitations section.

---

## 4. M2-F3 — DESIGN: `SingleUseClaim` not used — "one vote per Cosmos address," not "one vote per Aztec wallet"

**Location:** `cast_vote_babylon_v2` — no call to `self.storage.vote_claims.at(self.msg_sender()).claim()`.

**Analysis:**  
Generic paths (`cast_vote`, `cast_vote_allowlist`, `cast_vote_token`) use `SingleUseClaim`
to prevent one Aztec wallet from voting twice. For Babylon paths, this mechanism is
intentionally absent — Babylon voters are Cosmos holders who may not have Aztec keys,
and the per-holder uniqueness is enforced by the `holder_nullifier` stored in `receipts`.

The `holder_nullifier` in v2 is derived from `sha256(sig)`, where `sig` is the
secp256k1 signature over a vote-specific challenge. Under RFC 6979, `sig` is deterministic
given `(privkey, challenge)`. So for a fixed Cosmos key voting in a fixed vote:
- `sig` is deterministic → `nullifier` is deterministic.
- `receipts[nullifier]` is set to `true` on first use.
- Second attempt for the same Cosmos key produces the same `nullifier` → `assert(already_used == false)` fails.

This means each distinct Cosmos private key can vote at most once per vote.

**Implication for governance deployments:** An entity controlling N Cosmos addresses (N
snapshot leaves) can cast N votes — each from a different Aztec wallet. This is the
intended semantics for token-weighted governance. Deployers should be aware that "one
vote per entity" is NOT enforced; only "one vote per Cosmos address in the snapshot" is.

**No circuit change needed.** Add deployment guidance to `docs/deployment.md`.

---

## 5. M2-F4 — DESIGN: `hash_bytes_as_field` drops top SHA-256 byte — nullifier has 248-bit entropy

**Location:** `main.nr` line: `let holder_nullifier = hash_bytes_as_field(sha256_var(sig, 64));`

**Analysis:**  
`hash_bytes_as_field` encodes bytes [1..32] of the SHA-256 output as a Field (drops byte
0). This discards 8 bits, leaving a 248-bit field value. The probability of two distinct
signatures producing the same nullifier is 1/2^248, which is negligible in any
threat model.

The nullifier collision space is also bounded by the number of holders in the snapshot
(108,637 for Babylon Genesis). With 248 bits of entropy and ~10^5 users, the birthday
collision probability is approximately (10^5)² / 2^249 ≈ 10^10 / 10^74 ≈ 10^-64.
No practical issue.

**Sound.** No action required.

---

## 6. M2-F5 — SOUND: EIP-191 prefix bytes verified correct

**Location:** `cast_vote_babylon_v2`, step 3 — `eip191_prefix: [u8; 28]`.

**Verification:**  
`personal_sign` in MetaMask prepends `"\x19Ethereum Signed Message:\n32"` for a 32-byte
payload (the `32` is the ASCII decimal length of the payload). The prefix is:

```
\x19  E    t    h    e    r    e    u    m    (sp) S    i    g    n    e    d   (sp) M    e    s    s    a    g    e    :   \n   3    2
0x19 0x45 0x74 0x68 0x65 0x72 0x65 0x75 0x6d 0x20 0x53 0x69 0x67 0x6e 0x65 0x64 0x20 0x4d 0x65 0x73 0x73 0x61 0x67 0x65 0x3a 0x0a 0x33 0x32
```

Circuit prefix array (28 bytes):
```
0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
0x3a, 0x0a, 0x33, 0x32
```

**Byte-by-byte match confirmed.** ✓

The circuit then builds a 60-byte input (`prefix[28] || challenge[32]`) and computes
`keccak256(input)`. This is the exact computation MetaMask performs internally. Any
wallet that implements `personal_sign` (EIP-191 type 0x45) over a 32-byte payload will
produce a signature that passes this circuit.

---

## 7. Sound properties confirmed

| Property | Finding | Verdict |
|----------|---------|---------|
| Ownership proof closes snapshot-forwarding attack | Signature over vote-specific challenge; attacker without privkey cannot generate valid proof | ✅ SOUND |
| Cross-vote replay prevention | Challenge = sha256(title_hash || root); unique per vote config | ✅ SOUND |
| Balance witness binding | Leaf = sha256(hash160 \|\| balance_be); wrong balance → wrong leaf → Merkle fail | ✅ SOUND |
| Nullifier non-predictability | Derived from sig, not from public snapshot data | ✅ SOUND |
| Double-vote prevention | Nullifier is deterministic per (privkey, challenge); receipts map enforces single-use | ✅ SOUND |
| EIP-191 encoding | Prefix bytes correct; 60-byte msg matches MetaMask personal_sign spec | ✅ SOUND |
| secp256k1 low-S normalization | Requirement documented in circuit comments + ADR-036; Ethers v6 normalises automatically | ✅ DOCUMENTED |
| SHA-256d hash160 derivation | Test vectors verified; deterministic; differs by key | ✅ SOUND |

---

## 8. Pre-production checklist (Babylon M2 paths)

Before `cast_vote_babylon_v2` is used in a production governance deployment:

- [ ] **Implement `snapshot_version: u8` in `VoteConfig`** and add entrypoint guards (M2-F1).
- [ ] **Add Cosmos/Keplr signing path** or document that EVM wallet is required (M2-F2).
- [ ] **Deploy `docs/deployment.md` warning** about "one vote per Cosmos address" semantics (M2-F3).
- [ ] **Replace `derive_hash160_sha256d` with `ripemd160(sha256(compressed_pubkey))`** once
  `noir-ripemd160` compatibility is confirmed with `nargo >= 0.30`. Both snapshot generator
  and circuit must use the same scheme.
- [ ] **Professional audit** of both generic and Babylon paths before mainnet.

For the grant application and demo, the current implementation is appropriate. The
snapshot-forwarding vulnerability is closed by the M2 circuit, and the implicit Merkle
root version gate is sufficient for the prototype deployment.

---

## 9. Scope not covered

- `record_vote` public function called from Babylon paths: passes `eligibility_proof = 1`.
  This is acceptable because `record_vote` is `#[only_self]` (Aztec protocol enforces
  that only the contract's own private circuits can enqueue it). No external actor can
  call `record_vote` directly. The `1` is a protocol-layer "eligibility verified in
  circuit" token. See `security-review-2026-06-22.md` §8.3 for the `only_self` analysis.
- Performance/gate-count analysis: `std::ecdsa_secp256k1` ~100k gates + keccak256 ~5k
  gates + 20-level SHA-256 Merkle tree. Within Aztec's per-function ceiling. No full
  benchmark run conducted (see GRANT.md — proving-time benchmark deferred).
- TypeScript snapshot generator and `useM2Signing` React hook: out of scope for circuit
  review.
