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
kernel. Five findings are documented below: one **HIGH** severity (placeholder eligibility —
**fully resolved 2026-06-22**), two **LOW** (quorum boundary — resolved; zero receipt_id —
resolved), and two **DESIGN** (no emergency stop, protocol trust boundary). No critical
privacy breaks were found in the generic paths.

**Resolution summary (2026-06-22):**
- **F1-HIGH ALLOWLIST** resolved (tick-3610, commit 1d55025): `cast_vote_allowlist` with real in-circuit SHA-256 Merkle membership proof.
- **F1-HIGH TOKEN** resolved (tick-3611): `cast_vote_token` with real in-circuit SHA-256 Merkle balance proof. New leaf: `sha256(address_bytes[32] || balance_be[8])`.
- **F2 LOW** resolved (commit b3c7ac1): `assert(config.quorum > 0)` in constructor.
- **F3 LOW** resolved (commit b3c7ac1): `assert(receipt_id != 0)` in `cast_vote`.
- **F1-RESIDUAL HIGH** resolved (tick-3643): `cast_vote` now asserts `eligibility_mode == OPEN`; gated contracts cannot be called via the generic entrypoint. See §7 amendment below.

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
| DESIGN | 2 | F4 (no emergency stop), F5 (protocol trust) |

All severity findings in scope are resolved. The two DESIGN findings (F4, F5) are
known architectural constraints, not bugs. The contract is in a sound state for the
prototype / grant demo stage.

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
