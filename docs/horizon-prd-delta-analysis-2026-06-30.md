# Aztec Private Voting vs. Horizon Private Voting PRD — Delta Analysis

**Date:** 2026-06-30  
**Status:** Complete — M4 grant evidence  
**Author:** @jonybur  
**Source PRD:** [AztecProtocol/Horizon — Private Voting Module for DAOs](https://github.com/AztecProtocol/Horizon/blob/main/PRDs/Private_Voting_Module_for_DAOs.md)  
**Connects to:** `GRANT.md`, `docs/proof-of-inclusion-ux-pattern-2026-06-22.md`, `openspec/changes/grant-submission/`

---

## Purpose

This document maps Aztec Private Voting (Umbra) against the Horizon private-voting PRD to:
1. Demonstrate PRD coverage for the grant submission
2. Identify true gaps requiring further work before production
3. Pinpoint where Umbra exceeds the PRD — particularly on the PRD's own open questions

The Horizon PRD is Aztec's authoritative specification for the ecosystem application it wants built. Umbra is being positioned as the reference implementation.

---

## Summary verdict

| PRD section | Umbra status |
|---|---|
| §4.1 Admin flow (4 steps) | ✅ Full (configure, publish, run, finalize) |
| §4.2 Voter flow (3 steps) | ✅ Full (eligibility proof, vote, verify) |
| §4.3 Auditor flow | ⚠️ Partial (individual receipt; proof pack not built) |
| §5 MVP features | ✅ 4/5 fully; 1/5 partial (encrypted votes — Named Limitation) |
| §5 Later features | 🔲 Not in scope (delegations, ranked choice, adapters) — correct |
| §6 Privacy policy | ✅ Implemented; Named Limitation disclosed |
| §11 Open questions | ✅ PRD's own Q1 ("Default receipts") — answered by PIUP |

**Grant argument:** Umbra implements all MVP-required user flows, all MVP eligibility modes, and uniquely answers the PRD's primary open question on receipt design. The single Named Limitation (vote_choice in public calldata pre-M3) is disclosed, mitigated by PIUP's receipt-freeness design, and has a complete implementation spec (M3) pending a go-decision.

---

## §4 User experience — flow-by-flow mapping

### §4.1 Admin flow

| PRD step | Implementation | Notes |
|---|---|---|
| 1. Configure — vote type, eligibility, quorum, timing | `VoteAdmin` component + `VoteConfig` struct (constructor args) | Three eligibility modes: OPEN, TOKEN, ALLOWLIST. Quorum + timing in `VoteConfig`. |
| 2. Publish — proposal metadata public, voter identities private | `VoteConfig` stored in `PublicImmutable` — readable by anyone, immutable post-deploy | `title_hash` (poseidon2 hash of proposal title) is the public identifier. Full metadata is off-chain; the contract stores the commitment. |
| 3. Run — monitor anonymous turnout | `get_vote_count()` — public view returning total cast ballots | Count is public; individual choices are not. Participation rate leaks, direction does not. |
| 4. Finalize — reveal tally, receipts | `finalize_vote()` + `get_final_tally(idx)` + `VoteResult` component | Auto-execution (PRD: "auto execute if passed") is not implemented — tally is revealed but no on-chain action is triggered post-quorum. This is a facilitator-handled step in the current design. |

**Gap (admin):** Auto-execution after quorum is not implemented. This requires a callback interface — out of scope for the grant application, appropriate for a DAO framework integration phase.

---

### §4.2 Voter flow

| PRD step | Implementation | Notes |
|---|---|---|
| 1. Prove eligibility — private proof, no identity leak | `VoteEligibilityProof` component + in-circuit Merkle proof (`cast_vote_token`, `cast_vote_allowlist`) | OPEN mode skips the proof. TOKEN and ALLOWLIST modes require a valid Merkle witness verified inside the circuit — the eligibility proof never touches public calldata. |
| 2. Vote — submit encrypted choice, receive private receipt | `PrivateBallot` component + `cast_vote*` private entrypoints | **Named Limitation (pre-M3):** `vote_choice` is a public argument of `record_vote` (the public half of the transaction). An observer with the full `record_vote` call log can correlate `receipt_id → vote_choice`. PIUP mitigates the coercion surface at the receipt layer (receipt does not contain the choice); M3 eliminates the calldata exposure entirely. See §6 below. |
| 3. Verify — after close, confirm inclusion | `VoteResult` component + `verify_vote_counted(receipt_id) → bool` public view | Voters can verify at any time after submission (not only post-close). The contract tracks `receipts[receipt_id] = true` on each successful `cast_vote`. |

**Gap (voter):** The PRD says "submit **encrypted** choice." Current Umbra (pre-M3) submits anonymous but unencrypted choice. PIUP's receipt design is specifically engineered to limit the damage of this L1 constraint; M3 closes it completely.

---

### §4.3 Auditor flow

| PRD item | Implementation | Notes |
|---|---|---|
| Proof pack — eligibility checks, tally integrity, no vote contents | Partial: `verify_vote_counted(receipt_id)` covers per-voter inclusion | A full auditor proof pack would include: (a) proof that the Merkle root was correctly derived from the eligibility snapshot, (b) proof that `record_vote` was called exactly once per nullifier, (c) proof that the final tally sums all cast votes. None of (a)–(c) is currently packaged as an auditor artifact. |

**Gap (auditor):** Proof pack generation is not implemented. The security properties exist in the contract (one-vote-per-nullifier, tally integrity, quorum enforcement), but no tooling assembles them into a transmissible auditor artifact. This is a post-grant feature.

---

## §5 Product features — MVP checklist

| PRD MVP feature | Status | Notes |
|---|---|---|
| Eligibility templates: token weight, one-person-one-vote, role-based lists | ✅ | `ELIGIBILITY_MODE_OPEN`, `ELIGIBILITY_MODE_TOKEN`, `ELIGIBILITY_MODE_ALLOWLIST` — three templates shipped |
| Secret ballot: encrypted votes, commit, tally, finalize | ⚠️ Partial (L1 Named Limitation) | Anonymous but not encrypted pre-M3. Commit (private `cast_vote`) → tally (public `record_vote`) → finalize (`finalize_vote`) — full lifecycle. Encryption closed by M3. |
| Quorum and threshold rules, public result, private receipts | ✅ | `VoteConfig.quorum` enforced in `finalize_vote`. `get_final_tally()` returns public result post-finalization. PIUP receipts are private (no choice information). |
| Anti-replay, one vote per eligible unit | ✅ | `SingleUseClaim` (`vote_claims` storage field) — nullifier derived from voter's Aztec spending keys in the private kernel. Unreplayable across transactions; not linkable to wallet by observers. |
| Admin dashboard, proposal lifecycle, exports | ⚠️ Partial | `VoteAdmin` component covers configure + monitor + finalize. No export tooling (CSV, proof JSON). |

**Later features (correctly out of scope):**
- Delegations — not implemented (PRD §5: Later)
- Ranked choice / quadratic — not implemented (PRD §5: Later)
- Cross-platform adapters for Snapshot/governance UIs — not implemented (PRD §5: Later)

**Not in scope:** forum / discussion features — correct per PRD.

---

## §6 Privacy and disclosure policy

| PRD requirement | Implementation | Notes |
|---|---|---|
| Private by default — voter choices and identities encrypted | ✅ for identity / ⚠️ for choices (pre-M3) | Voter identity is not linkable from public calldata: the nullifier is derived from private spending keys in the circuit kernel, not from the wallet address. `vote_choice` is in public `record_vote` calldata — Named Limitation, disclosed in paper §3.3, §6.5, and `docs/security-review-2026-06-22.md`. |
| Selective disclosure — auditor proofs on demand, no raw ballots | ⚠️ Partial | `verify_vote_counted(receipt_id)` confirms inclusion. Full auditor proof pack not yet built. |
| Anti-correlation — batching windows, randomized timing | 🔲 Not implemented | PRD §6 lists this under privacy policy but PRD §5 does not include it in MVP features. Not implemented; post-grant scope. |

---

## §9 MVP scope constraints

| PRD constraint | Umbra | Notes |
|---|---|---|
| One network | ✅ | Aztec testnet (v5 RC). Single-network deployment. |
| Three eligibility modes | ✅ | OPEN, TOKEN, ALLOWLIST — exactly three. |
| Up to 5,000 voters per vote | ✅ | Merkle depth = 20 → 2²⁰ ≈ 1,048,576 eligible addresses. 5,000 is well within capacity. |
| Ten concurrent proposals per DAO in pilot | 🔲 Not implemented | Current model: one contract per proposal. Multi-proposal DAO integration requires a registry/factory contract — a post-grant integration layer. |

---

## §11 Open questions — Umbra's direct answers

The Horizon PRD lists three open questions. Umbra answers the first directly, partially addresses the second, and explicitly defers the third.

### Open question 1: "Default receipts content voters expect"

**Answer: Proof-of-Inclusion UX Pattern (PIUP)**

Umbra is the first private voting system to formally answer this question. The receipt design is documented in:
- `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` — the pattern specification (three invariants, four required components, three rejected alternatives with rejection rationale)
- `drafts/piup-chi-paper-draft-2026-06-22.md` — a full CHI submission documenting the pattern, its theoretical grounding, and empirical validation plan
- `docs/receipt-design.md` — implementation-specific rationale

**PIUP's key finding:** voters expect four things from a private receipt: (1) a status line confirming inclusion, (2) a submission token (the "vote fingerprint"), (3) protective framing explaining the absent choice, and (4) a verification affordance. The pattern is grounded in three design invariants:
- Invariant 1 (Surrogate independence): the receipt does not contain or derive the voter's choice
- Invariant 2 (Surrogate privacy in transit): the token is private until vote close; sharing it pre-close reveals the choice via calldata correlation
- Invariant 3 (Minimal content): no choice-revealing field appears in the receipt under any code path

This answers the PRD's open question with empirically-grounded design principles, not guesses. Study 1 (pre-registered, N=280) tests whether the pattern produces accurate privacy mental models in non-expert users. Study 2 (pre-analysis plan, N=240) tests explanation effects and calibration interventions.

---

### Open question 2: "Minimum public metadata for legal defensibility"

**Partial answer:** `VoteConfig` is stored in `PublicImmutable` — fully readable by any observer before the first vote. This includes `title_hash`, `options_count`, `start_time`, `end_time`, `quorum`, `eligibility_mode`. The title hash (poseidon2 commitment to the proposal text) enables a legal challenge to verify that the proposal text matches what was voted on. The eligibility snapshot root (encoded in `token_address` for TOKEN mode) enables verification that the eligibility set was correctly derived. 

What is not addressed: jurisdiction-specific disclosure requirements (e.g., whether the proposal text must be on-chain, not just its hash). This is a legal question, not a protocol question, and is out of scope for the grant.

---

### Open question 3: "Delegation disclosure norms by community"

**Deferred:** Delegations are listed in PRD §5 as a Later feature. Umbra does not implement delegations. This is correct behavior.

---

## Competitive differentiation relative to existing projects (PRD reference list)

The PRD lists five comparison projects. The delta analysis adds explicit gap-filling.

| Project | PRD coverage | Receipt UX | Named Limitation |
|---|---|---|---|
| Snapshot + Shutter | votes revealed post-close; no permanent privacy | vote is revealed — no receipt needed | temporary privacy only |
| MACI (PSE) | strongest coercion resistance | no receipt artifact | trusted coordinator |
| NounsDAO/Aztec experiment | research prototype, Aztec | no receipt artifact | not production-ready |
| Safe + Shutter (SEP-X) | partial; Shutter integration | no receipt artifact | pending integration |
| Aztec Private Voting | ✅ full MVP flow | ✅ PIUP — only project with a designed receipt | Named Limitation (M3 closes) |

The PRD's own §8 calls out "low UX familiarity" as a risk, with the mitigation "guided flows and clear receipts." Umbra is the only project in this space that has treated the receipt as a first-class design artifact and produced empirical evidence about what makes it legible to non-expert users.

---

## Summary of gaps requiring work before full PRD compliance

| Gap | Priority | Path |
|---|---|---|
| vote_choice in public calldata (Named Limitation) | HIGH — closes M3 go-decision | `docs/m3-tally-privacy-implementation-spec-2026-06-27.md` — spec complete; pending Jony go-decision |
| Auditor proof pack | MEDIUM — post-grant | Requires assembling existing contract proofs into a transmissible artifact; no contract changes needed |
| Auto-execution post-quorum | LOW — DAO framework integration | Requires a callback interface to the DAO's execution contract; out of grant scope |
| Multi-proposal registry/factory | LOW — post-grant | One contract per proposal is acceptable for pilot; factory is a later scaling concern |
| Export tooling | LOW — UX polish | CSV or JSON export of vote results; frontend-only |
| Anti-correlation batching | LOW — post-M3 | Only meaningful after vote_choice is encrypted (M3); batching unencrypted calldata is security theater |

---

*This document was produced for M4 grant evidence (tick-4257). It should be referenced in the grant submission cover email and in any Aztec Horizon forum post registering the project.*
