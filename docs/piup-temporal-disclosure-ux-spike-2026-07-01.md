# PIUP Temporal Disclosure UX — Design Spike

**Date:** 2026-07-01 (tick-4382)
**Status:** Design spike — open question for future empirical work
**Author:** @jonybur-oc
**Connects to:** `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` (Invariant 2), `docs/receipt.md` §(e), `docs/piup-receipt-freeness-theory-2026-06-30.md` (Q4)

---

## Problem

PIUP Invariant 2 states:

> The surrogate must be treated as private until the submission is definitionally public (vote is closed, auction is revealed, etc.).

The current `VoteReceipt.tsx` implementation enforces this through copy only:
> "Don't share your vote fingerprint until the vote closes — sharing it lets someone link it to your vote choice."

**The question:** Is copy sufficient? Or does the UI need a structural mechanism to reinforce or enforce the temporal constraint?

This spike analyzes four design approaches, evaluates the tradeoffs, and identifies which approach best balances privacy robustness against usability — and what empirical question the recommendation leaves open.

---

## The failure mode copy-only addresses (and doesn't)

The copy-only approach assumes that:
1. The user reads and retains the instruction.
2. The user understands what "linking it to your vote choice" means.
3. The user acts on this understanding when a coercer (or vote buyer) asks to see the fingerprint.

Assumption 3 is the fragile one. A user under social pressure ("show me your vote") has the copy instruction available in memory but faces a competing incentive. Copy is a reminder, not a barrier. If the adversarial scenario is coercion (someone with power over the voter demands the fingerprint), copy does not provide a socially deniable exit.

**What the copy cannot provide:** the voter cannot say "I can't share it yet" if sharing is technically possible at any time. Social deniability — the ability to truthfully claim that sharing is not possible — requires a UI-level constraint, not just a copy-level instruction.

---

## Four design approaches

### Option A: Copy-only (current)

**Mechanism:** Plain-language instruction on the receipt screen and in the downloaded JSON.

**Strengths:**
- Zero friction for non-adversarial use
- Does not require the UI to know the vote close time
- Works even if the user exports the receipt to a different device

**Weaknesses:**
- Provides no social deniability under coercion
- Requires the user to act against an active instruction from an adversary
- No measurable enforcement (copy can be ignored)

**When this is acceptable:** When the coercion model is passive (vote buyer, not employer-with-power). When the voting population is self-selected for security awareness.

---

### Option B: Deferred share UI (unlock post-close)

**Mechanism:** The share / export buttons are locked until a configurable `voteCloseTimestamp` passes. Before close: the download button produces the full receipt JSON but the "Share / Copy fingerprint" action is disabled with an inline message: *"Sharing is enabled after the vote closes on [date]."* After close: both buttons unlock.

**Strengths:**
- Provides a technically-grounded deniability claim: *"The app won't let me share it yet."*
- Makes the temporal constraint visible at the moment of decision
- Consistent with Invariant 2 at the UI layer

**Weaknesses:**
- Does not prevent the user from opening the downloaded JSON and copying the fingerprint manually — the constraint is UI-level, not enforcement-level
- Requires the receipt to be seeded with `voteCloseTimestamp` at generation time; if the timestamp changes (vote extended), stale receipts have wrong lock dates
- Adversary can instruct the user to use the JSON directly; the lock provides deniability only for the default user who takes the path of least resistance

**When this is the right choice:** When the adversarial model is primarily vote-buyer-under-social-pressure (not technical attacker), and when voters need a socially deniable exit. The key insight: the person least likely to be coerced is the person who can point to a concrete UI constraint.

---

### Option C: Two-phase receipt (stub → full)

**Mechanism:** The receipt screen displays immediately on vote submission, but the fingerprint itself is delivered in two phases:
1. **Phase 1 (pre-close):** The receipt shows a transaction hash (proof the ballot landed) but the fingerprint is replaced by a placeholder: *"Your vote fingerprint will appear here after the vote closes on [date]. It is stored securely on your device."* The fingerprint value is stored in browser local storage, inaccessible via the visible UI.
2. **Phase 2 (post-close):** The voter returns to the receipt URL; the fingerprint is revealed from local storage and the full receipt is available for export.

**Strengths:**
- The coercion attack surface is maximal only during Phase 2, when Invariant 2's constraint has already lifted (the vote is closed, `vote_choice → fingerprint` map is now irrelevant because the tally is public)
- Strong social deniability in Phase 1: *"I genuinely can't show you the fingerprint right now"*

**Weaknesses:**
- High UX complexity: Phase 2 requires the voter to return, which introduces verification-intent decay (users who forget, or whose devices reset)
- Local storage dependency: fingerprint loss if browser data is cleared
- Fundamentally changes the "save it now" UX (currently download-as-primary). The Phase 1 → Phase 2 transition is a new behavioral ask with no prior mental model.
- Incomplete enforcement: the transaction hash (Phase 1 visible) plus the choice (voter's memory) gives an attacker enough for a coercion proof; hiding the fingerprint does not prevent "I watched you click 'Yes'" attacks

**When this is the right choice:** When the key threat is vote buying (not observation during the vote), and when the designer can accept higher drop-off on verification (voters who don't return).

---

### Option D: Non-exportable window with explicit countdown

**Mechanism:** Copy-only, but with a countdown UI: *"Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes."* The countdown clock is the primary visual treatment, and the copy explains why. No technical lock; the download still works.

**Strengths:**
- Makes the temporal constraint concrete and countdown-driven (more salient than static text)
- No new behavioral ask (download still works, fingerprint is always accessible)
- Pairs with Option B without requiring a technical lock (add the lock later if needed)
- The countdown may produce a natural sense of "not yet" that reduces impulsive sharing in mild-pressure situations

**Weaknesses:**
- Still copy-only in the adversarial sense: determined adversary can instruct user to download and copy manually
- Clock staleness if `voteCloseTimestamp` changes

---

## Recommendation

**Ship Option D now; add Option B lock when the adversarial model warrants it.**

Rationale:

1. The current copy-only approach has no temporal salience. A voter who received the receipt 3 days ago will not remember the sharing constraint when someone asks to see the fingerprint. A countdown makes the constraint immediately visible at any point during Phase 1.

2. Option B (the UI lock) provides genuine social deniability for adversarial contexts, but requires engineering (knowing `voteCloseTimestamp` at generation time; handling timestamp changes). It is the right upgrade once the adversarial model is confirmed by data.

3. Option C (two-phase receipt) introduces a new behavioral pattern that increases verification drop-off. This conflicts with the primary PIUP goal of increasing individual verifiability. Option C is the right design only if the threat model shifts to assume that the adversary watches the voting session itself (in which case fingerprint visibility is not the binding constraint anyway).

4. Option A remains acceptable for contexts where the voting population is self-selected for security awareness — e.g., developer-led DAO votes, validator set elections. For consumer-facing deployments, Option D is the minimum.

**Implementation cost:** Option D requires `voteCloseTimestamp` in `VoteConfig` (already there for `finalize_vote()` eligibility) and a countdown component in `VoteReceipt.tsx`. Estimated: 2–3 hours.

---

## Open empirical question

The deniability hypothesis (Option B users are more resistant to coercion pressure because they can truthfully say "the app won't let me share it") is untested. This is a candidate for a Study 4 factorial:

- **Factor D:** UI-lock present vs. absent
- **Factor P:** Pressure scenario (vote buyer with moderate incentive vs. high-power employer-equivalent)
- **Outcome:** Sharing rate (behavioral); perceived deniability (self-report)

Hypothesis: UI-lock reduces sharing rate under high-pressure more than under low-pressure (D × P interaction). Study 4 would be a vignette experiment, not a field deployment — appropriate as a confirmatory test of the social deniability claim before deploying Option B at scale.

---

## Related documents

- `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` — Invariant 2 definition
- `docs/receipt.md` — §(e) threat model; current copy-only treatment
- `docs/receipt-design.md` — original UX rationale
- `docs/piup-receipt-freeness-theory-2026-06-30.md` — Q4 (temporal constraint UX)
- `docs/piup-study3-social-verification-2026-06-29.md` — Study 3 design (social proof + verification behavior)
