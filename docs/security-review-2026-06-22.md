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
kernel. Five findings are documented below: one **HIGH** severity (placeholder eligibility),
two **LOW** (quorum boundary, zero receipt_id), and two **DESIGN** (no emergency stop,
protocol trust boundary). No critical privacy breaks were found in the generic paths.

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

**Status:** Known, explicitly deferred to M2. No untracked risk.

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
| HIGH | 1 | F1 (eligibility placeholder — known, deferred) |
| MEDIUM | 0 | — |
| LOW | 2 | F2 (quorum=0), F3 (receipt_id=0) |
| DESIGN | 2 | F4 (no emergency stop), F5 (protocol trust) |

The two LOW findings (F2, F3) are each one-line fixes. They should be addressed before
the grant forum post to show the project is production-aware, not just prototype-quality.

The HIGH finding (F1) is correctly deferred to M2 and clearly documented — this is an
acceptable research prototype posture if the grant submission frames the token/allowlist
paths as "future work" rather than "current capability."
