# Security Review: `PrivateVoting` Noir Circuit (Generic Paths)
**Date:** 2026-06-22  
**Author:** Jony Burshtyn  
**Scope:** `main.nr`, `eligibility.nr` — generic Aztec voting paths only  
**Excluded:** Babylon governance paths (`cast_vote_babylon`, `merkle.nr`)  
**Method:** Static circuit analysis, trust-boundary audit, Aztec protocol reasoning  

---

## Executive Summary

The `PrivateVoting` contract is structurally sound for the prototype stage. The core
privacy invariant — wallet identity is not linkable to a ballot — is correctly implemented
via `SingleUseClaim`, whose nullifier is derived from the caller's keys inside the private
kernel. Five original findings (F1–F5) are documented below: one **HIGH** severity
(placeholder eligibility — **fully resolved**), two **LOW** (quorum boundary — resolved;
zero receipt_id — resolved), and two **DESIGN** (no emergency stop, protocol trust
boundary). A §8 extended review of `cast_vote_token` and `cast_vote_allowlist` added
seven additional observations (N-F1–N-F7): four confirmed sound, three DESIGN items
(**all addressed in documentation**). No critical privacy breaks were found in any
generic paths.

**Resolution summary:**
- **F1-HIGH ALLOWLIST** resolved (tick-3610, commit 1d55025): `cast_vote_allowlist` with real in-circuit SHA-256 Merkle membership proof.
- **F1-HIGH TOKEN** resolved (tick-3611): `cast_vote_token` with real in-circuit SHA-256 Merkle balance proof. New leaf: `sha256(address_bytes[32] || balance_be[8])`.
- **F2 LOW** resolved (commit b3c7ac1): `assert(config.quorum > 0)` in constructor.
- **F3 LOW** resolved (commit b3c7ac1): `assert(receipt_id != 0)` in `cast_vote`.
- **F1-RESIDUAL HIGH** resolved (tick-3643): `cast_vote` now asserts `eligibility_mode == OPEN`; gated contracts cannot be called via the generic entrypoint. See §7 amendment below.
- **N-F3 DESIGN** addressed (tick-3648, commit 3884195): `docs/deployment.md` — deploy-time warning, `tokenAddress` encodes 248-bit SHA-256 Merkle root via `encode_root_as_field`, top-byte-drop encoding documented.
- **N-F4 DESIGN** addressed (tick-3648, commit 3884195): constructor `assert(min_token_balance > 0)` added for TOKEN mode contracts.
- **N-F6 DESIGN** addressed (tick-3649, commit 0252056): `docs/deployment.md` — explicit ⚠️ deployer warning on multi-wallet sybil in allowlist mode; three mitigation strategies documented.

---

## 1. Findings

### F1 — HIGH: Eligibility check is a placeholder (token + allowlist modes)

**Location:** `eligibility.nr` — `verify_eligibility`, lines 15–29

```noir
} else if config.eligibility_mode == ELIGIBILITY_MODE_TOKEN {
    assert(proof != 0, "missing token proof");
} else if config.eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST {
    assert(proof != 0, "missing allowlist proof");
```

**Finding:** In `TOKEN` and `ALLOWLIST` modes, the only constraint on the caller is
`proof != 0`. Any caller who passes `eligibility_proof = 1` (or any non-zero field)
will pass the eligibility check regardless of whether they hold the required token or
appear on the allowlist. The comment in the source correctly labels these as
"placeholder checks," but the severity in a production deployment is high: all
eligibility guarantees collapse.

**Impact (production):** An ineligible voter can cast a valid ballot in any gated vote by
supplying `eligibility_proof = 1`.

**Recommendation:**
Replace each placeholder block with a constraint that verifies a ZK membership proof
against the committed eligibility commitment (e.g., a Merkle root of eligible addresses,
or a token balance commitment). For token-gated votes, this is the primary M2 target.
Add a `TODO(M2-eligibility)` marker in the source so the open work is visible.

**Status:** ✅ **RESOLVED** — 2026-06-22

- **ALLOWLIST** (tick-3610, commit 1d55025): `cast_vote_allowlist` — in-circuit SHA-256 Merkle membership proof against committed allowlist root. Leaf = `sha256([0x00] || address_field_bytes[31])`. Depth-20 tree. 4 unit tests.
- **TOKEN** (tick-3611): `cast_vote_token` — in-circuit SHA-256 Merkle balance proof against committed token snapshot root. Leaf = `sha256(address_bytes[32] || balance_be[8])`. Balance threshold enforced inside circuit (`balance >= min_token_balance`) before Merkle verification. 5 unit tests.

Both entrypoints use the same `verify_merkle_path` primitive and `encode_field_as_root` encoding. `eligibility.nr` stubs now serve only as a guard on the generic `cast_vote` path; the domain-specific entrypoints are the canonical paths for gated votes.

---

### F2 — LOW: `quorum = 0` allows vacuous finalization

**Location:** `main.nr` — `constructor` (~line 53), `finalize_vote` (~line 128)

```noir
// constructor — no quorum lower bound:
assert(config.options_count > 1, "need at least 2 options");
assert(config.end_time > config.start_time, "end before start");
// (no assert on config.quorum)

// finalize_vote:
assert(self.storage.vote_count.read() >= config.quorum, "quorum not met");
```

**Finding:** The constructor validates `options_count > 1` and timing, but does not
validate `config.quorum > 0`. When `quorum = 0`, the expression
`vote_count >= 0` is always true, so a vote can be finalized immediately after
`end_time` with zero participants.

**Impact:** An admin who deploys with `quorum = 0` (accidentally or intentionally)
can run a vacuously legitimising vote — one that produces a binding final tally from
zero ballots.

**Recommendation (two options):**

*Option A — Prohibit zero quorum:*
```noir
assert(config.quorum > 0, "quorum must be at least 1");
```

*Option B — Document zero-quorum as "no quorum required" mode:*
Add a comment in the constructor and in `finalize_vote` so the semantics are explicit
for deployors.

Recommendation: Option A unless a use case explicitly requires quorum-free finalization.

---

### F3 — LOW: `receipt_id = 0` is accepted; clients must generate non-zero

**Location:** `main.nr` — `cast_vote` (~line 71), `record_vote` (~line 97)

```noir
fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    self.storage.vote_claims.at(self.msg_sender()).claim();
    self.enqueue_self.record_vote(vote_choice, eligibility_proof, receipt_id);
}

// in record_vote:
let already_used = self.storage.receipts.at(receipt_id).read();
assert(already_used == false, "receipt already used");
self.storage.receipts.at(receipt_id).write(true);
```

**Finding:** The contract does not validate that `receipt_id != 0`. Voter A and Voter B
are independent wallets whose double-vote protection comes from `SingleUseClaim`, not
from `receipt_id`. However, if both Voter A and Voter B pass `receipt_id = 0`, the
following sequence occurs:

1. Voter A's `record_vote(choice_a, _, 0)` succeeds; `receipts[0] = true`.
2. Voter B's `record_vote(choice_b, _, 0)` **fails** — "receipt already used" — even
   though Voter B has not previously voted.

The result: Voter B's ballot is silently rejected (the private kernel consumed the
`vote_claims` nullifier), and they cannot retry with a different `receipt_id`. Voter B
has voted (nullifier spent) but holds no verifiable receipt.

**Impact:** Voter B loses both their vote and their receipt, with no on-chain explanation.
If a wallet library defaults to `receipt_id = 0`, all concurrent voters from that library
would collide.

**This does not break privacy** (the nullifier is spent; Voter B is already "committed").
But it is a correctness and UX failure: the vote is silently lost.

**Recommendation:**
```noir
fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    assert(receipt_id != 0, "receipt_id must be non-zero");
    self.storage.vote_claims.at(self.msg_sender()).claim();
    self.enqueue_self.record_vote(vote_choice, eligibility_proof, receipt_id);
}
```

Also add a client-side assertion in the wallet/frontend layer before submitting, since
the `cast_vote` private execution happens client-side and catching it early avoids
wasting a `vote_claims` nullifier.

---

### F4 — DESIGN: No emergency stop mechanism

**Location:** `main.nr` — overall contract architecture

**Finding:** Once deployed, the vote runs to completion. The `admin` is a
`PublicImmutable`, meaning it is set once and cannot change. There is no `pause_vote`,
`cancel_vote`, or admin-override function.

**Analysis:** This is architecturally intentional — removing admin power over an
in-progress vote is a key trustlessness property. Voters can commit without fear that
the admin will alter the vote after ballots are cast. The trade-off is that a discovered
bug (e.g., in eligibility logic) cannot be patched mid-vote.

**Impact:** If a critical vulnerability is discovered after vote deployment, there is no
recovery path. The vote must run to completion or be abandoned by convention.

**Recommendation for V2:** Consider an `admin_cancel` function callable only before
`start_time` (not after), which sets `is_finalized = true` and emits a cancellation event
but does not write a tally. This preserves trustlessness during the live window while
allowing pre-start correction.

**This is a design trade-off, not a security flaw.** The current choice is defensible
and should be made explicit in the documentation.

---

### F5 — DESIGN: `SingleUseClaim` soundness is a protocol trust assumption

**Location:** `main.nr` — `vote_claims` storage, `cast_vote`

```noir
vote_claims: Owned<SingleUseClaim<Context>, Context>,

fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    self.storage.vote_claims.at(self.msg_sender()).claim();
    ...
}
```

**Finding:** The entire double-vote prevention property rests on the correctness of
Aztec's `SingleUseClaim` primitive. The nullifier preventing a second vote is derived
from the caller's keys **inside the private kernel**, which is Aztec infrastructure —
not Noir code written in this contract.

**Analysis:** This is not a flaw in the contract, but a trust boundary that must be
explicitly acknowledged. The contract delegates the critical soundness property to the
Aztec protocol's proven kernel circuits. If the private kernel has a bug in nullifier
derivation, an attacker could vote twice. The contract cannot independently verify
this property in-circuit.

**The claim is sound under the assumption:** "Aztec's private kernel correctly derives
and commits to unique nullifiers from each wallet's spending keys for `SingleUseClaim`."

This assumption is reasonable — Aztec's kernel is the most audited component of the
protocol — but it is the protocol's trust, not the contract's.

**Recommendation:** Add a comment in the storage declaration and in `cast_vote` noting
this trust boundary explicitly, so future security reviews and grant reviewers understand
the full trust model.

---

## 2. Confirmed Sound Properties

The following were audited and found correct:

| Property | How Enforced | Status |
|---|---|---|
| Wallet-to-ballot unlinkability | `SingleUseClaim` nullifier in private kernel | ✅ Sound (F5 assumption) |
| No vote after end_time | `assert(now < config.end_time)` in `record_vote` | ✅ |
| No finalization before end_time | `assert(now >= config.end_time)` in `finalize_vote` | ✅ |
| Tally only shown post-finalization | `assert(is_finalized)` in `get_final_tally` | ✅ |
| `record_vote` not callable externally | `#[only_self]` decorator | ✅ |
| `options_count` bounds | `> 1` and `<= MAX_OPTIONS (8)` in constructor | ✅ |
| No `is_finalized` bypass | separate check in `record_vote` prevents post-finalize votes | ✅ |
| Timing boundary (end_time=1) | At `t == end_time`: cast fails (`< end_time`), finalize succeeds (`>= end_time`) | ✅ Correct |

---

## 3. Known Limitations (Previously Documented, Not New)

These are correctly annotated in the source and are on the M2 roadmap:

- **L1 privacy gap**: `vote_choice` and `receipt_id` are plaintext public arguments in
  `record_vote`. Choices are anonymous but not secret. → M2 Architecture A resolves this
  via encrypted ballots (see `docs/m2-tally-privacy-design-spike-2026-06-22.md`).

- **Receipt-freeness is partial**: a voter can "prove" their choice to a coercer by
  sharing their `receipt_id` (which links to the on-chain `vote_choice`). The commitment
  not to use the word "coercion-resistant" until a re-encryption mix is shipped stands.

---

## 4. Recommended Immediate Code Changes

In priority order:

1. **Add `assert(receipt_id != 0)` in `cast_vote`** — prevents silent vote loss, 1 line. (F3)
2. **Add `assert(config.quorum > 0)` in `constructor`** — prevents vacuous finalization, 1 line. (F2)
3. **Add `TODO(M2-eligibility)` comment** in eligibility.nr placeholder blocks — tracks
   open security debt clearly. (F1)
4. **Document `SingleUseClaim` trust boundary** — comment in storage + cast_vote. (F5)
5. **Document no-emergency-stop as a design choice** in `docs/deployment.md`. (F4)

Changes 1–2 are appropriate now (pre-grant). Changes 3–5 are documentation-only.

---

## 5. Scope Exclusions

The following were **not** reviewed in this audit:
- `cast_vote_babylon` and all Babylon governance paths
- `merkle.nr` Merkle membership circuit  
- TypeScript scripts (`scripts/`)
- Deployment and configuration security

A separate review of the Babylon paths would be required before production deployment
of Babylon-gated votes.

---

## 6. Overall Risk Assessment

| Severity | Count | Items |
|---|---|---|
| CRITICAL | 0 | — |
| HIGH | 0 | F1 and F1-RESIDUAL both resolved (see §1 and §7) |
| MEDIUM | 0 | — |
| LOW | 0 | F2 (quorum=0) and F3 (receipt_id=0) both resolved |
| DESIGN | 2 | F4 (no emergency stop), F5 (protocol trust) — architectural constraints, no fix needed |

All severity findings in scope are resolved. The two DESIGN findings (F4, F5) are
known architectural constraints, not bugs. All seven §8 observations (N-F1–N-F7)
are either confirmed sound or addressed in documentation (N-F3 tick-3648,
N-F4 tick-3648, N-F6 tick-3649). The contract is in a sound state for the
prototype / grant demo stage. See §9 for final close-out summary.

---

## 7. Amendment: F1-RESIDUAL — `cast_vote` mode restriction (2026-06-22, tick-3643)

**Finding:** After F1-HIGH was resolved by adding `cast_vote_token` and
`cast_vote_allowlist`, the generic `cast_vote` entrypoint remained callable on TOKEN and
ALLOWLIST mode contracts. The `verify_eligibility` stub in `eligibility.nr` only checks
`proof != 0`; an attacker could bypass all gating by calling
`cast_vote(choice, 1, receipt_id)` directly, supplying `proof = 1`.

**Attack path:**
1. A TOKEN-gated or ALLOWLIST-gated `PrivateVoting` contract is deployed.
2. An ineligible voter calls `cast_vote(vote_choice, 1, receipt_id)` — the generic
   entrypoint that has no Merkle proof requirement.
3. `record_vote` calls `verify_eligibility(1, config)`. For TOKEN or ALLOWLIST mode,
   the stub asserts `proof != 0` — `proof = 1` passes.
4. The vote is counted without any eligibility verification. All token-gating and
   allowlist restrictions are bypassed.

**Impact:** HIGH. Any ineligible address can cast valid ballots on any gated vote.

**Fix (tick-3643):** `cast_vote` now reads the contract's `eligibility_mode` from
`config` before consuming the single-use claim and asserts:

```noir
assert(
    config.eligibility_mode == ELIGIBILITY_MODE_OPEN,
    "cast_vote: gated votes require cast_vote_token or cast_vote_allowlist",
);
```

This assertion fires before the `SingleUseClaim` is consumed, so the gas cost of a
rejected attempt is minimal. The `ELIGIBILITY_MODE_OPEN` constant is now imported
alongside `ELIGIBILITY_MODE_TOKEN` and `ELIGIBILITY_MODE_ALLOWLIST` in `main.nr`.

**Why this was missed in the original F1 resolution:** The original fix correctly
identified that the generic `cast_vote` path had stub eligibility, and added mode-specific
entrypoints with real in-circuit proofs. The assumption was that callers would use the
correct entrypoint. This is a protocol-layer assumption without a contract-layer
enforcement. The amendment adds the enforcement.

**Relationship to F2-atomicity analysis:** The F2 analysis (`docs/f2-atomicity-analysis-
2026-06-22.md`) analysed receipt-collision blocking on `cast_vote` and `cast_vote_babylon`.
This amendment does not affect the F2 analysis — the atomicity properties of `record_vote`
are unchanged.

**Status:** ✅ **RESOLVED** — contracts/src/main.nr, tick-3643.

---

## 8. Amendment: Security Review of New Eligibility Entrypoints (2026-06-22, tick-3647)

**Scope extension:** Section 5 of the original review listed `cast_vote_token` and
`cast_vote_allowlist` as unreviewed because they did not exist at the time. Both were
shipped as the F1-HIGH resolution (tick-3610 / tick-3611). This amendment formally
reviews their security properties.

**Method:** Static circuit analysis of `contracts/src/main.nr`, `merkle.nr`, and
`eligibility.nr`. All Babylon governance paths (`cast_vote_babylon`, `cast_vote_babylon_v2`)
remain out of scope.

---

### 8.1 `cast_vote_token` Security Analysis

**Entrypoint:**
```noir
fn cast_vote_token(vote_choice, receipt_id, token_balance, merkle_path, merkle_indices)
```

**Property-by-property audit:**

| Property | Mechanism | Verdict |
|---|---|---|
| Mode guard | `assert(eligibility_mode == ELIGIBILITY_MODE_TOKEN)` before any work | ✅ Sound |
| receipt_id ≠ 0 | `assert(receipt_id != 0)` at entry | ✅ Sound |
| Balance threshold | `assert(balance >= min_balance)` inside `verify_token_eligibility` | ✅ Sound |
| Balance commitment | Leaf = `sha256(address[32] \| balance_be[8])` — inflation fails Merkle proof | ✅ Sound |
| Address binding | `caller_field = self.msg_sender().to_field()` used in leaf computation | ✅ Sound |
| Double-vote prevention | `SingleUseClaim.claim()` on caller's Aztec wallet — protocol nullifier | ✅ Sound |
| Receipt collision | `receipts` map in `record_vote` prevents reuse of the same receipt_id | ✅ Sound |

**Balance inflation attack (N-F1 CONFIRMED SOUND):**
A voter who passes `token_balance = 999999` (much higher than their actual snapshot
balance) produces leaf `sha256(address, 999999)`. The snapshot committed the actual
leaf `sha256(address, actual_balance)`. These differ; the Merkle proof fails at
`verify_merkle_path`. There is no circuit path that accepts an unmatched leaf.

**Cross-wallet Merkle reuse (N-F2 CONFIRMED SOUND):**
`compute_token_leaf` uses `self.msg_sender().to_field()` as the address component.
A voter cannot take another wallet's Merkle path (address B, balance B) and use it
from wallet A — the leaf computed in-circuit uses `msg_sender()` (wallet A), so the
leaf does not match address B's snapshot entry.

**Observation: `token_address` field repurposed as Merkle root store (N-F3 DESIGN):**
`config.token_address` (an `AztecAddress`) encodes the SHA-256 Merkle root via
`encode_field_as_root`. This is a semantic mismatch (address field storing a hash root)
but not a security flaw — the encoding is consistent between the deployer
(`encode_root_as_field` in `synthetic-snapshot.ts`) and the circuit (`encode_field_as_root`
in `merkle.nr`). A Field is 31 bytes, so the top byte of the 32-byte SHA-256 root
is dropped (zero-padded back to 32 bytes). This reduces the effective commitment to
248 bits — adequate for a Merkle root commitment. Source and docs are annotated with
this encoding scheme.

**Recommendation (N-F3):** No code change required. Add a deploy-time note in
`docs/deployment.md` warning that `config.token_address` must be set to the encoded
Merkle root (not a real token contract address) for TOKEN and ALLOWLIST mode votes.

**Observation: zero `min_token_balance` admits any snapshot entry (N-F4 DESIGN):**
If a deployer sets `min_token_balance = 0`, any address present in the snapshot with
balance 0 would satisfy `balance >= 0`. In practice, zero-balance addresses are not
included in token snapshots. There is no circuit-level guard against this edge case;
it is a deployer invariant. The circuit's job is to enforce the threshold, not to
constrain the threshold to a minimum.

**Recommendation (N-F4):** Add a constructor-level check in a future hardening pass:
`assert(config.min_token_balance > 0, "token mode requires positive min balance")`. This
is low priority — the deployer controls the threshold and the grant demo uses a
non-zero threshold.

---

### 8.2 `cast_vote_allowlist` Security Analysis

**Entrypoint:**
```noir
fn cast_vote_allowlist(vote_choice, receipt_id, merkle_path, merkle_indices)
```

**Property-by-property audit:**

| Property | Mechanism | Verdict |
|---|---|---|
| Mode guard | `assert(eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST)` at entry | ✅ Sound |
| receipt_id ≠ 0 | `assert(receipt_id != 0)` at entry | ✅ Sound |
| Membership proof | Leaf = `sha256([0x00] \| address_field[31])` — `verify_aztec_allowlist` | ✅ Sound |
| Address binding | `caller_field = self.msg_sender().to_field()` used in leaf computation | ✅ Sound |
| Double-vote prevention | `SingleUseClaim.claim()` on caller's Aztec wallet — protocol nullifier | ✅ Sound |
| Receipt collision | `receipts` map in `record_vote` prevents reuse of the same receipt_id | ✅ Sound |

**Address binding (N-F5 CONFIRMED SOUND):**
`compute_aztec_leaf` hashes the caller's Aztec address field. An attacker who somehow
obtains another wallet's Merkle proof cannot use it from their own wallet — the leaf
computed in-circuit uses `msg_sender()`, not a supplied address. No impersonation path
exists at the circuit level.

**Sybil via allowlist composition (N-F6 DESIGN):**
A person controlling multiple Aztec wallets (A, B, C) can vote once per wallet if each
address appears in the allowlist. This is a deployer concern (constructing the allowlist
correctly to include only intended voters) rather than a circuit vulnerability. The circuit
correctly enforces: each listed address may vote at most once. The allowlist composition
is out of scope for this circuit review.

---

### 8.3 Cross-Entrypoint Security Analysis

**Mode confusion between entrypoints:**
- Calling `cast_vote_token` on an ALLOWLIST-mode contract: fails at
  `assert(eligibility_mode == ELIGIBILITY_MODE_TOKEN)`. ✅
- Calling `cast_vote_allowlist` on a TOKEN-mode contract: fails at
  `assert(eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST)`. ✅
- Calling `cast_vote` on either gated contract: fails at
  `assert(eligibility_mode == ELIGIBILITY_MODE_OPEN)` (F1-RESIDUAL fix, §7). ✅

No cross-mode call succeeds. All entrypoint/mode pairs are guarded.

**Nullifier scheme differs from Babylon entrypoints (N-F7 CONFIRMED SOUND):**
`cast_vote_token` and `cast_vote_allowlist` use Aztec's `SingleUseClaim` (protocol-key
nullifier, unlinkable). `cast_vote_babylon` uses a nullifier derived from the snapshot
leaf hash (address + balance — publicly computable). This difference is correct and
expected: generic Aztec-mode voters use Aztec wallets (protocol keys available);
Babylon-mode voters are Cosmos holders (no Aztec keys, hence leaf-derived nullifier).
The two schemes are not interchangeable and are not used on the same contract instance.

**Receipt collision across entrypoints on the same contract:**
`receipt_id` collisions are prevented by the shared `receipts` map in `record_vote`,
guarded by `assert(already_used == false)`. This holds regardless of which entrypoint
originated the call. No double-counting is possible through receipt_id reuse. ✅

---

### 8.4 New Findings Summary

| ID | Severity | Description | Recommendation | Status |
|---|---|---|---|---|
| N-F1 | SOUND | Balance inflation attack: impossible (leaf commits address + balance) | None | ✅ CONFIRMED SOUND |
| N-F2 | SOUND | Cross-wallet Merkle reuse: impossible (leaf uses msg_sender()) | None | ✅ CONFIRMED SOUND |
| N-F3 | DESIGN | `token_address` field repurposed as Merkle root store (248-bit root) | Add deployment.md note | ✅ ADDRESSED (tick-3648) |
| N-F4 | DESIGN | Zero `min_token_balance` admits zero-balance snapshot entries | Add constructor guard in future hardening | ✅ ADDRESSED (tick-3648) |
| N-F5 | SOUND | Address binding in allowlist prevents impersonation | None | ✅ CONFIRMED SOUND |
| N-F6 | DESIGN | Multi-wallet sybil in allowlist mode: deployer concern, not circuit flaw | Add deployment.md deployer guidance | ✅ ADDRESSED (tick-3649) |
| N-F7 | SOUND | Nullifier scheme difference (Aztec vs. Babylon): correct and expected | None | ✅ CONFIRMED SOUND |

**Updated overall risk table (post §8):**

| Severity | Count | Items |
|---|---|---|
| CRITICAL | 0 | — |
| HIGH | 0 | F1 and F1-RESIDUAL both resolved (§1, §7) |
| MEDIUM | 0 | — |
| LOW | 0 | F2 (quorum=0) and F3 (receipt_id=0) both resolved |
| DESIGN | 2 | F4, F5 (original); N-F6 addressed tick-3649 — N-F3/N-F4 addressed tick-3648 |

No new security vulnerabilities were found in `cast_vote_token` or `cast_vote_allowlist`.
Both entrypoints are sound for the prototype / grant demo stage. The two remaining DESIGN
observations (F4, F5) are architectural constraints with no circuit fix required.
N-F3 (deployment.md Merkle root encoding warning), N-F4 (constructor balance guard), and
N-F6 (allowlist sybil deployer guidance) were all addressed in ticks 3648–3649.

**Status:** ✅ **REVIEWED** — tick-3647. N-F3/N-F4 hardening tick-3648. N-F6 deployer guidance tick-3649.

---

## 9. Audit Close-Out (2026-06-22, tick-3650)

**Status: COMPLETE — ready for grant submission**

This section closes the audit record for the `PrivateVoting` Noir circuit (generic
paths). All actionable findings from the original review (§1–§6) and the extended §8
review of `cast_vote_token` / `cast_vote_allowlist` have been either resolved in code
or addressed in documentation.

### 9.1 Full Finding Disposition

| ID | Type | Description | Disposition |
|---|---|---|---|
| F1-HIGH | Critical | Placeholder eligibility (TOKEN + ALLOWLIST) | ✅ Resolved in code (tick-3610/3611) |
| F1-RESIDUAL | Critical | Generic `cast_vote` callable on gated contracts | ✅ Resolved in code (tick-3643) |
| F2-LOW | Bug | `quorum = 0` allows vacuous finalization | ✅ Resolved in code (b3c7ac1) |
| F3-LOW | Bug | `receipt_id = 0` accepted, risks silent vote loss | ✅ Resolved in code (b3c7ac1) |
| F4-DESIGN | Architecture | No emergency stop mechanism | ✅ Accepted — intentional trustlessness. Documented in `docs/deployment.md`. V2 recommendation noted (admin_cancel pre-start). |
| F5-DESIGN | Architecture | `SingleUseClaim` soundness is protocol trust | ✅ Accepted — trust boundary explicit. Comment in `cast_vote`. |
| N-F1 | Sound | Balance inflation attack impossible | ✅ Confirmed sound (§8.1) |
| N-F2 | Sound | Cross-wallet Merkle reuse impossible | ✅ Confirmed sound (§8.1) |
| N-F3-DESIGN | Documentation | `tokenAddress` repurposed as Merkle root store | ✅ Documented in `deployment.md` (tick-3648) |
| N-F4-DESIGN | Hardening | Zero `min_token_balance` admits any snapshot entry | ✅ Constructor assert added (tick-3648) |
| N-F5 | Sound | Address binding prevents impersonation in allowlist | ✅ Confirmed sound (§8.2) |
| N-F6-DESIGN | Documentation | Multi-wallet sybil in allowlist mode | ✅ Deployer guidance added to `deployment.md` (tick-3649) |
| N-F7 | Sound | Nullifier scheme divergence (Aztec vs. Babylon) is correct | ✅ Confirmed sound (§8.3) |

**Total: 13 findings. 5 resolved in code. 4 confirmed sound (no action). 4 addressed in documentation.**

### 9.2 What the Audit Covers

The audit covers all **generic Aztec voting paths**:
- `cast_vote` (OPEN mode only, post F1-RESIDUAL fix)
- `cast_vote_token` (TOKEN mode)
- `cast_vote_allowlist` (ALLOWLIST mode)
- `record_vote`, `finalize_vote`, `get_final_tally`
- `eligibility.nr`, `merkle.nr` (the `verify_merkle_path` primitive)
- Constructor validation

### 9.3 What the Audit Does NOT Cover

The following remain out of scope and require a separate review before any
production deployment of those paths:
- **Babylon governance paths**: `cast_vote_babylon`, `cast_vote_babylon_v2`
- **TypeScript scripts**: `scripts/synthetic-snapshot.ts`, deployment tooling
- **Aztec private kernel internals**: `SingleUseClaim` implementation (audited by Aztec)
- **Frontend / wallet integration**: receipt_id generation, client-side validation

### 9.4 Privacy Guarantee Summary

The core privacy claim — that a voter's wallet address is not linkable to their ballot
choice — holds under the following explicitly-stated trust model:

1. **Aztec private kernel correctness**: `SingleUseClaim` nullifiers are derived from
   and committed to the caller's spending keys inside the private kernel. A bug in the
   kernel nullifier derivation would break double-vote prevention. This is Aztec
   protocol risk, not contract risk.

2. **SHA-256 collision resistance**: The Merkle leaf computation
   (`sha256(address || balance)` or `sha256([0x00] || address)`) relies on SHA-256
   preimage resistance. Under standard cryptographic assumptions this is sound.

3. **Deployer allowlist/snapshot integrity**: For gated votes, the deployer is solely
   responsible for the correctness of the committed Merkle root. The circuit cannot
   verify that the root correctly represents the intended eligible set.

### 9.5 Grant Submission Statement

This security review, together with the `GRANT.md` application, the PIUP Study 1
pre-registration, and the forum post draft in `docs/forum-post-grant-application.md`,
constitutes the submitted evidence of research-quality methodology for the Aztec
Privacy Fund application.

**For grant reviewers:** All HIGH-severity vulnerabilities found by static analysis
have been resolved in the committed code. The two remaining DESIGN observations (F4,
F5) are standard trade-offs in on-chain voting system design, documented deliberately.
The circuit has been reviewed across three audit passes: original five-finding review,
F1-RESIDUAL cross-entrypoint analysis, and full §8 review of the token and allowlist
entrypoints. No critical or medium findings remain open.

**Commit trail:**
- `1d55025` — `cast_vote_allowlist` with in-circuit Merkle proof
- `b3c7ac1` — F2 quorum guard + F3 receipt_id guard
- `39ca9a3` — §8 extended review committed to docs
- `1d55025`, `tick-3611` — `cast_vote_token` with in-circuit balance proof
- `tick-3643` — F1-RESIDUAL mode restriction
- `3884195` — N-F3 deployment note + N-F4 constructor guard
- `0252056` — N-F6 deployer guidance (multi-wallet sybil)

**Review closed:** 2026-06-22, tick-3650.
**Reviewer:** Jony Burshtyn / OpenClaw agent working on `aztec-private-voting`.

---

## 10. Amendment: M2/M3 Milestone Terminology for L1 Resolution Path (tick-4181)

**Context:** §3 (Known Limitations) originally stated that the L1 privacy gap is "on
the M2 roadmap" and that "M2 Architecture A resolves this." The M2 milestone has since
been disambiguated: **M2 is the EIP-191 secp256k1 ownership proof** (shipped; §3.5 of
the CHI paper draft); the tally-privacy resolution path is **M3**.

**Correction to §3:**

_Original:_
> These are correctly annotated in the source and are on the M2 roadmap:
> - **L1 privacy gap**: ... → M2 Architecture A resolves this via encrypted ballots
>   (see `docs/m2-tally-privacy-design-spike-2026-06-22.md`).

_Corrected reading:_
> These are correctly annotated in the source. The L1 privacy gap is on the **M3
> roadmap** (tally-privacy milestone):
> - **L1 privacy gap**: ... → **M3 tally-privacy architecture** resolves this via
>   coordinator-encrypted BallotNote (design spike: `docs/m2-tally-privacy-design-spike-2026-06-22.md`
>   §Architecture A; implementation spec: `docs/m3-tally-privacy-implementation-spec-2026-06-27.md`
>   §5.3; pending go-decision).

**Note:** The design spike file is named `m2-tally-privacy-design-spike-2026-06-22.md`
because it was written under the old milestone naming. The file name is unchanged; only
the milestone designation changed. The CHI paper body consistently uses "M3" for
tally-privacy (§1.1, §3.3, §6.5 [Note tick-4013]).

This amendment does not affect any security finding classifications. The L1 privacy gap
remains an open design limitation of the pre-M3 instantiation. No code changes.

---

## 11. Amendment: Babylon entrypoint audit + cross-path analysis (tick-4272, 2026-06-30)

**Scope:** `cast_vote_babylon`, `cast_vote_babylon_v2`, `get_final_tally` view —
not covered by the original §8 extended review (which covered generic paths + TOKEN +
ALLOWLIST). Babylon paths excluded from original scope per CLAUDE.md (separate
review scope). This amendment covers the structural/design observations only; the
EIP-191 signature scheme and secp256k1 circuit correctness were reviewed separately
in `docs/m2-front-running-security-analysis-2026-06-27.md`.

**Status note:** This amendment does NOT cover Babylon governance deployment specifics
(no live Babylon holder data; CLAUDE.md Frozen Decisions). Findings are generic circuit
structure observations valid for any deployment using the Babylon entrypoints.

---

### N-F8 — DESIGN: No `ELIGIBILITY_MODE_BABYLON` constant; Babylon votes deploy as TOKEN mode

**Location:** `eligibility.nr` (global constants), `main.nr` (all Babylon entrypoints)

**Finding:** Three eligibility mode constants are defined:

```rust
pub global ELIGIBILITY_MODE_OPEN: u8 = 0;
pub global ELIGIBILITY_MODE_TOKEN: u8 = 1;
pub global ELIGIBILITY_MODE_ALLOWLIST: u8 = 2;
```

There is no `ELIGIBILITY_MODE_BABYLON = 3`. Babylon governance votes
(`cast_vote_babylon`, `cast_vote_babylon_v2`) are deployed with
`eligibility_mode = ELIGIBILITY_MODE_TOKEN = 1`. The `eligibility_mode` field therefore
does not distinguish between:

- An **Aztec token snapshot** vote (TOKEN mode, intended entrypoint: `cast_vote_token`,
  leaf format: `sha256(address_bytes[32] || balance_be[8])`)
- A **Cosmos BABY snapshot** vote (TOKEN mode, intended entrypoints:
  `cast_vote_babylon`/`cast_vote_babylon_v2`, leaf formats:
  `sha256(address_bytes[45] || balance_be[8])` v1 /
  `sha256(hash160_bytes[20] || balance_be[8])` v2)

An off-chain deployer who inspects `config.eligibility_mode` cannot determine which
entrypoint the vote was intended to use. There is no on-chain assertion that prevents
a caller from trying `cast_vote_token` on a BABY-snapshot contract (the Merkle
verification fails at the circuit layer, but no mode assertion fires first).

**Impact:** DESIGN — no exploitable vulnerability. The distinct leaf formats prevent
cross-path forgery (see N-F10 cross-path analysis below). The missing constant is a
code quality and deployability concern: tooling, UIs, and indexers that inspect
`eligibility_mode` cannot distinguish BABY votes from Aztec token votes without
out-of-band knowledge.

**Recommendation:** Add `pub global ELIGIBILITY_MODE_BABYLON: u8 = 3;` and guard both
Babylon entrypoints with:

```rust
assert(
    config.eligibility_mode == ELIGIBILITY_MODE_BABYLON,
    "cast_vote_babylon: contract not in babylon mode",
);
```

Mirror the pattern from `cast_vote_token` (asserts `ELIGIBILITY_MODE_TOKEN`) and
`cast_vote_allowlist` (asserts `ELIGIBILITY_MODE_ALLOWLIST`).

**Status:** RESOLVED — tick-4485 (2026-07-02). `pub global ELIGIBILITY_MODE_BABYLON: u8 = 3;`
added to `eligibility.nr`. `verify_eligibility` updated to handle mode 3 with a
non-zero proof. 2 new Noir tests added (`babylon_proof_rejects_zero`,
`babylon_proof_accepts_nonzero`). All 22 tests pass.

---

### N-F9 — DESIGN: Babylon entrypoints lack eligibility mode guards

**Location:** `main.nr` — `cast_vote_babylon` (~line 278), `cast_vote_babylon_v2` (~line 310)

**Finding:** `cast_vote_token` and `cast_vote_allowlist` both open with an eligibility
mode assertion:

```rust
// cast_vote_token:
assert(
    config.eligibility_mode == ELIGIBILITY_MODE_TOKEN,
    "cast_vote_token: contract not in token mode",
);

// cast_vote_allowlist:
assert(
    config.eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST,
    "cast_vote_allowlist: contract not in allowlist mode",
);
```

Neither `cast_vote_babylon` nor `cast_vote_babylon_v2` contains an equivalent
assertion. Both proceed directly to Merkle verification (and signature verification
for v2) without first asserting the contract's eligibility mode.

**Impact:** DESIGN. In practice, the Merkle verification provides the gatekeeping:
the distinct leaf formats (see N-F10) make cross-path forgery infeasible.
However, the absence of explicit mode guards:

1. Violates the established pattern (generic-path guard → Merkle proof → enqueue);
2. Means that on a correctly deployed BABYLON contract, a caller can invoke
   `cast_vote_token` (which does assert TOKEN mode → will fail) but not have
   `cast_vote_babylon` fail-fast on an incorrectly typed contract;
3. Slightly increases circuit analysis complexity for future reviewers who expect
   the mode assertion at the entrypoint boundary.

**Recommendation:** Add mode assertion at the top of both Babylon entrypoints,
consistent with N-F8 (once `ELIGIBILITY_MODE_BABYLON` is defined):

```rust
assert(
    config.eligibility_mode == ELIGIBILITY_MODE_BABYLON,
    "cast_vote_babylon: contract not in babylon mode",
);
```

**Status:** RESOLVED — tick-4485 (2026-07-02). `ELIGIBILITY_MODE_BABYLON` imported in
`main.nr`. Both `cast_vote_babylon` and `cast_vote_babylon_v2` now assert
`config.eligibility_mode == ELIGIBILITY_MODE_BABYLON` as their first guard after
reading config, before the snapshot_version guard. N-F8 unblocked this.

---

### N-F10 — DESIGN: `get_final_tally` does not validate `option_index < options_count`

**Location:** `main.nr` — `get_final_tally` (~line 490)

```rust
#[external("public")]
#[view]
fn get_final_tally(option_index: u8) -> pub u64 {
    assert(self.storage.is_finalized.read(), "not finalized");
    self.storage.tally.at(option_index).read()
}
```

**Finding:** The function asserts `is_finalized` but does not validate
`option_index < config.options_count`. For `option_index >= options_count`,
the storage map returns the default value (0 in PublicMutable<u64>), silently
returning a zero tally.

**Impact:** DESIGN — view function, no state changes. An off-chain client that
iterates `for i in 0..8` (using `MAX_OPTIONS`) rather than
`for i in 0..config.options_count` receives zero tally values for unused option
slots with no error indication. This could produce misleading tally summaries
(e.g., "3 options with non-zero tallies; 5 options with zero tallies" rather than
"3 options total").

**Recommendation:** Add a bounds assertion:

```rust
assert(
    (option_index as u32) < (config.options_count as u32),
    "option_index out of range",
);
```

This mirrors the bounds check in `record_vote`:
`assert((vote_choice as u32) < (config.options_count as u32), "invalid choice");`

**Status:** RESOLVED — tick-4485 (2026-07-02). `get_final_tally` now reads config and
asserts `(option_index as u32) < (config.options_count as u32)` after the finalized
check. Mirrors the identical guard in `record_vote`.

---

### Cross-path double-vote analysis — confirmed NOT exploitable

**Question:** Can a voter cast two valid ballots in the same vote by using different
entrypoints (e.g., once via `cast_vote_token` and once via `cast_vote_babylon`)?

**Analysis:**

Both `cast_vote_token` and `cast_vote_babylon` verify Merkle membership against
`config.token_address` (the same field). However, their leaf hash preimages are
structurally distinct:

| Entrypoint | Leaf preimage | Size |
|---|---|---|
| `cast_vote_token` (TOKEN mode) | `sha256(address_bytes[32] ‖ balance_be[8])` | 40 bytes |
| `cast_vote_babylon` v1 | `sha256(address_bytes[45] ‖ balance_be[8])` | 53 bytes |
| `cast_vote_babylon_v2` | `sha256(hash160_bytes[20] ‖ balance_be[8])` | 28 bytes |

A single SHA-256 Merkle tree cannot simultaneously satisfy all three leaf schemes with
the same root (the distinct preimage sizes prevent collision by construction). A
cross-path Merkle proof using one leaf format against a root built with a different
format will fail at `verify_merkle_path`.

Additionally:
- On a **TOKEN mode contract** (Aztec token snapshot): `cast_vote_token` uses
  `SingleUseClaim` (one vote per wallet); `cast_vote_babylon` would fail the Merkle
  proof (wrong leaf format); `cast_vote_allowlist` fails the mode assertion.
- On a **BABYLON contract** (TOKEN mode, BABY snapshot): `cast_vote_babylon` uses a
  deterministic leaf-derived nullifier (v1) or signature-derived nullifier (v2);
  `cast_vote_token` would fail the Merkle proof; `cast_vote_allowlist` fails mode
  assertion.

**Verdict:** Cross-path double-vote is not exploitable. Leaf format specialisation is
the correct separation mechanism. The recommended N-F8/N-F9 mode guards would make
this defense explicit at the assertion layer rather than relying on Merkle proof failure.

---

### Zero-nullifier in `cast_vote_babylon_v2` — negligible risk, consistency gap

**Finding:** `cast_vote_babylon_v2` derives the holder nullifier as:

```rust
let holder_nullifier = hash_bytes_as_field(sha256_var(sig, 64));
```

No assertion `holder_nullifier != 0` is present. Compare `cast_vote`, `cast_vote_token`,
and `cast_vote_allowlist`, which all assert `receipt_id != 0` on the client-supplied field.

**Analysis:** The field value is zero only if `sha256_var(sig, 64)` is the field's zero
element. The BN254 scalar field has order `r ≈ 2^254`; the probability that a random
32-byte value falls in `{0}` mod r is ≈ 2^-254 — negligible in practice.

However, the absence breaks the pattern established by the three other guarded
entrypoints. A future maintainer may not notice the missing assertion.

**Recommendation:** Add `assert(holder_nullifier != 0, "nullifier must be non-zero");`
after the nullifier derivation, for consistency and defence against any future
`hash_bytes_as_field` implementation that might behave unexpectedly.

**Status:** RESOLVED — tick-4485 (2026-07-02). `assert(holder_nullifier != 0,
"nullifier must be non-zero")` added after nullifier derivation in
`cast_vote_babylon_v2`. Consistent with the `assert(receipt_id != 0)` pattern in
the three other voting entrypoints.

---

**Summary of N-F8–N-F10:**

| Finding | Severity | Status |
|---|---|---|
| N-F8: No `ELIGIBILITY_MODE_BABYLON` constant | DESIGN | RESOLVED (tick-4485) |
| N-F9: Babylon entrypoints lack mode guards | DESIGN | RESOLVED (tick-4485) |
| N-F10: `get_final_tally` no bounds check | DESIGN | RESOLVED (tick-4485) |
| Cross-path double-vote | — | NOT exploitable (confirmed) |
| Zero-nullifier in v2 | LOW | RESOLVED (tick-4485) |

No critical or high findings in this amendment. All prior findings (F1–F5, N-F1–N-F7)
remain resolved as documented in §1–§10.
