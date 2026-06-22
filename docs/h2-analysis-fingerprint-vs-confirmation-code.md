# H2 Analysis: The Fingerprint / Confirmation-Code Tension

**Date:** 2026-06-22  
**Status:** Pre-study analysis — pre-registered reasoning  
**Author:** @jonybur-oc  
**For:** ADR-037, grant application §3.2, Jony's review before pilot

---

## Why H2 is structurally different from H1, H3, H4

H1, H3, and H4 each predict that a single condition is clearly better or worse than the field.
H1: A > D. H3: C << everything. H4: B is overconfident. None of these require real tension between
two viable labels.

H2 is the only hypothesis that puts two genuinely competitive labels in contest: it predicts
that A and B are roughly equivalent across most measures, but diverge specifically on the
privacy mental model items (Q2, Q3). That means H2 can be supported, null, or reversed in a
way that creates real design consequences — whereas H1 and H3 are mostly about confirming or
refuting directional bets.

If H2 is confirmed: there's a real design tradeoff, and "vote fingerprint" is the right choice
specifically because the voting domain is privacy-critical.

If H2 is null (A ≈ B on everything): confirmation-code is an equally safe label, and using
production-familiar terminology is fine. The codebase default should probably switch to B.

If H2 is reversed (B > A on accuracy AND on privacy items): the eCommerce priming transfers
successfully to the voting domain and "confirmation code" is the superior label. This is the
outcome the team currently least expects and would be the most publishable.

All three outcomes produce actionable design decisions. This is what makes H2 the pivot
hypothesis of the study.

---

## The "confirmation of what?" problem

The case for H2 rests on a semantic distinction that is not immediately obvious but is, once
seen, quite sharp.

**In eCommerce**, "confirmation code" means: *your order was confirmed*. The system received
your specific selection (item X, qty Y, shipping address Z) and acknowledges it. The confirmation
code is linked to a record that *includes* your choice. You can call the 1-800 number, give the
code, and they will read back exactly what you ordered. The code is retrievable evidence of
what you chose.

**In voting**, the correct semantics for the same phrase would need to be: *your vote was
confirmed as counted, but the system does not know what you chose*. The receipt identifier is
linked to a Merkle proof that shows *the existence* of a ballot without revealing its content.
It is precisely the opposite representational structure: not retrievable evidence of your choice,
but evidence of choice-free inclusion.

The word "confirmation" sits upstream of this distinction. Users who bring eCommerce priming
will apply the correct behavioral schema (save this, you'll need it later to verify) while
applying the wrong representational schema (the system knows what I specifically chose, this
code connects to that record).

Importantly, this transfer is not irrational. It is the correct interpretation *in every other
domain where confirmation codes appear* — airline tickets, hotel bookings, food delivery,
Ticketmaster. The policy of keeping choice invisible to the system is the unusual case.
Ecommerce familiarity is useful precisely because it accurately describes the norm. PIUP is
the norm-violation, and the label needs to signal that.

---

## Why "vote fingerprint" carries the right affordance

The metaphor in "fingerprint" pulls in two directions simultaneously:

1. **Uniqueness**: a fingerprint is unique to you and cannot be faked or forged. → The receipt
   is authentically yours, not a fabrication.

2. **Opacity**: a fingerprint tells you *who*, not *what they did*. A fingerprint at a crime
   scene confirms presence, not action. → The receipt confirms your ballot was present in the
   count without describing what the ballot contained.

Direction (2) is the one that matters for Q2 and Q3. The metaphor does not carry it explicitly —
it requires a small inferential step — but the direction is the right one. A fingerprint does
not reveal the content of a letter you wrote; it only shows the letter is yours.

"Confirmation code" carries only direction (1): authenticity of submission. It carries nothing
about opacity, because opacity is not the norm in the contexts where confirmation codes appear.

This is the exact mechanism H2 relies on. It predicts that participants in Condition A will
score better on Q2/Q3 specifically because "fingerprint" primes a partial-information metaphor
(uniqueness without description), while participants in Condition B will score better on Q1
(was the vote counted?) because "confirmation" directly names the confirmation-of-submission
schema.

---

## Predicted outcome, stated more precisely than ADR-037

ADR-037 states: "Conditions A and B will be within 5 percentage points on composite comprehension
accuracy, but Condition B will underperform A specifically on Q2/Q3 (privacy mental model items)."

A more precise statement: **H2 predicts a dissociation within the question set**.

- Q1 ("does this prove the vote was counted?"): B ≥ A. "Confirmation" directly activates the
  submission-confirmed schema. Both should score high (>= 75% correct), with B possibly edging
  ahead.

- Q2 ("does this prove which option I chose?" correct: No): A > B. Fingerprint cues partial
  information; confirmation activates the "system has my specific record" model → B participants
  are more likely to incorrectly answer Yes.

- Q3 (coercion vignette: "could they learn how you voted?" correct: No): A > B for the same
  reason. If users in Condition B believe the system stores their choice-linked record, they may
  believe a screenshot reveals how they voted.

- Q4 ("what happens if you lose this?": correct: option b): roughly equal across A and B, maybe
  both above D (which provides no affordance at all for what the code is for).

- Q5 (open-ended: "why might the system not show you your vote choice?"): A > B, because the
  fingerprint/opacity metaphor nudges participants toward the correct model (the system
  deliberately does not know). Condition B participants may instead reason: "the system does
  know but just doesn't show me on this screen" — which is a coherent interpretation of how
  eCommerce systems handle order details.

The composite score (ADR-037's "within 5 percentage points") is expected to be approximately
equal only because the Q1 advantage for B cancels the Q2/Q3 disadvantage. The aggregate
conceals a structured crossover.

**Analytic implication**: analyzing H2 requires pre-specified question-level comparisons, not
just composite scores. If the analysis collapses across questions, the crossover is invisible
and H2 appears null. This is a methodological decision that should be recorded in the pre-
registration before data collection.

---

## Three outcomes and what they mean for production

### Outcome 1 (H2 supported): A ≈ B composite, but A > B on Q2/Q3

Production decision: keep "vote fingerprint" as the default. The domain-specific opacity
affordance is doing work that "confirmation code" fails to carry. The cost of confirmation-code
familiarity is a specific, measurable degradation in privacy mental model.

Grant/paper implication: publishable as a case study in domain transfer failure — familiar
conventions from one context (eCommerce) actively harm comprehension in a different context
(privacy-critical voting) despite preserving other comprehension measures. This parallels the
Whitten/Tygar (1999) "Why Johnny Can't Encrypt" finding at the label level: technically
meaningful text does not automatically produce correct mental models.

### Outcome 2 (H2 null): A ≈ B on all measures

Production decision: consider switching to "confirmation code" for the mass-market version.
The familiarity advantage (lower learning cost, cross-domain recognition) is real and costs
nothing in privacy comprehension.

Grant/paper implication: the null is still interesting, because it would mean the privacy
explainer copy ("This receipt does not contain your vote choice") is doing the heavy lifting
for privacy comprehension regardless of label. If that's true, copy is the real intervention
lever, not labeling. Study 2 and Study 3 become comparatively more important.

### Outcome 3 (H2 reversed): B > A on accuracy AND B ≥ A on Q2/Q3

Production decision: switch to "confirmation code" immediately. If eCommerce priming transfers
correctly to voting (high familiarity + no privacy model degradation), it's simply the better
label.

Grant/paper implication: most surprising, most publishable. Would mean that the team's
intuition about domain transfer danger was wrong, and that privacy-copy framing (the constant
explainer) is strong enough to override label schema. The team was over-engineering the label
metaphor.

---

## What "within 5 percentage points" actually means for H2

ADR-037 uses 5 pp as the boundary for "approximately equal" on composite accuracy. This is a
reasonable tolerance for a study with n = 50/cell (power was calculated for 20 pp differences;
5 pp differences are underpowered and should not drive production decisions).

But the claim of H2 is not really about the composite. The structure of the prediction is:
- A small advantage to B on Q1 (maybe 5–10 pp)
- A larger advantage to A on Q2/Q3 (maybe 10–20 pp each)
- The composite cancels to approximately equal (within 5–10 pp)

This means the 5 pp composite tolerance in ADR-037 is consistent with a very large Q2/Q3
divergence. The study is powered to detect the Q2/Q3 differences if they're 15+ pp; it is not
powered to precisely estimate the composite.

**Pre-registration note**: the primary endpoint for H2 should be Q2 accuracy in condition A
vs. condition B (one-tailed: A > B), not composite accuracy. The composite is a secondary
check on whether the overall accuracy gap is large enough to matter practically.

---

## The strategic reason H2 matters for the CMU HCII application

Sauvik Das's SPUD Lab works on social-proof interventions in security — the gap between stated
security behavior and actual behavior, and how context (social cues, interface framing) shapes
that gap. H4 (overconfidence on B) connects most directly to his work.

But H2 connects to something just as relevant: **the mechanism by which familiar interface
conventions produce incorrect mental models in security-critical contexts**. This is the same
transfer problem that runs through Cranor's privacy nutrition label research — users apply the
right cognitive tools (I know how to read a nutrition label / I know what a confirmation code
is) but those tools are calibrated for a non-privacy context and fail when privacy properties
are the key outcome.

H2 is, in the language Das uses, a *context violation* problem: the conventional cue (confirmation
code) activates the correct behavioral schema but the wrong representational schema. The study
can measure exactly this dissociation because the question set separates behavioral comprehension
(Q1: did I vote? Q4: what happens if I lose this?) from representational comprehension (Q2: what
does this prove? Q3: what can it reveal?).

Mentioning this mechanism specifically — "H2 tests whether a familiar interface convention
transfers its representational schema as well as its behavioral schema across domain contexts"
— in the email to Das before applying would connect the work to his research vocabulary.

---

## One issue worth fixing before pilot

The Q3 question ("If a coercive employer asked you to send them a screenshot of this screen as
proof of your vote, could they learn how you voted?") tests the coercion-surface understanding
but introduces a second cognitive operation: imagining a social scenario while holding the
privacy model. A participant who correctly understands that the receipt is privacy-preserving
might still answer "yes" if they (incorrectly) assume that a screenshot reveals metadata beyond
the receipt itself — browser URL, timestamp, system state.

Consider adding a clarification: "Assume they can only see what is on this screen." This removes
the screenshot-metadata ambiguity without changing what the question tests (whether the user
believes the on-screen information reveals their choice).

This is a one-sentence change and should be confirmed in the pilot (n = 10/condition) before
full launch. If 20%+ of pilot participants ask about screenshot metadata, add the clarification.
If < 5% do, leave it as-is (the ambiguity may itself be ecologically valid — coercive screenshot
requests in the real world do include device state).

---

## Summary

H2 is the most interesting hypothesis in Study 1 because:

1. It pits two genuinely viable labels against each other, creating a real production decision
   regardless of which direction the data falls.

2. The predicted mechanism — that "confirmation" activates the correct behavioral schema but
   the wrong representational schema — is theoretically motivated, falsifiable at the question
   level, and connected to both the Whitten/Tygar 1999 tradition and the Cranor/Das research
   programs.

3. Analyzing it correctly requires pre-specifying question-level comparisons (Q2/Q3 in A vs. B)
   as the primary endpoint, not composite accuracy. If this is not in the pre-registration,
   any Q2/Q3 divergence found in the data could be treated as exploratory.

**Before the pilot runs**, the pre-registration should include:
- Primary endpoint for H2: Q2 accuracy, A vs. B, one-tailed (A > B)
- Secondary endpoint: Q3 accuracy, A vs. B
- Tertiary: composite accuracy, A vs. B, equivalence bounds ±10 pp
- Pre-specified question-level analysis plan with Bonferroni correction for 5 questions × 3
  planned comparisons = 15 tests

**Jony-actions from this document:**
1. Confirm the Q2-primary / Q3-secondary / composite-tertiary endpoint structure for the
   pre-registration (or revise if H2 is not the priority)
2. Review the Q3 clarification suggestion — pilot data will help decide
3. Consider adding the "behavioral schema vs. representational schema" framing to the
   CMU email to Sauvik Das
