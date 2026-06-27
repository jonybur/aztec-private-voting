# PIUP User Study Protocol

_Author: Jony Bursztyn · 2026-06-22_  
_Related: [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md), [`docs/receipt-design.md`](receipt-design.md)_

---

## Overview

This document is a study protocol for empirically testing the design hypotheses in Aztec Private Voting's receipt UX. It is written to be directly usable for a pilot or full study, and to support the grant application (Section 3.2: "UX Research Methodology").

The receipt design makes several claims that are currently design hypotheses, not studied results:
- That "vote fingerprint" produces better comprehension than "nullifier" or "confirmation code"
- That download-only (no email) increases user sense of control without critically reducing save rates
- That users can correctly form a mental model of why the receipt does not contain their vote choice
- That users given a PIUP receipt are less susceptible to receipt-based coercion than users given a choice-linked receipt

Each of these claims is testable. This protocol is designed to test all four across two connected studies.

---

## Research questions

**RQ1 (Label comprehension).** Which receipt identifier label — "vote fingerprint", "confirmation code", "nullifier", or "receipt ID" — produces the most accurate comprehension of what the identifier proves and what it does not prove?

**RQ2 (Verification behavior).** What fraction of users who download a PIUP receipt return to verify it, and what predicts whether they do? Does behavioral intent (stated at download) predict actual verification?

**RQ3 (Privacy mental model).** Does the current receipt UI cause users to correctly infer that their vote choice is hidden from the system? Can users reliably distinguish between a receipt that "proves I voted" and a receipt that "proves how I voted"?

**RQ4 (Coercion surface).** When presented with a PIUP receipt (no choice visible) vs. a choice-linked receipt (choice visible), are users less likely to comply with a simulated coercion demand?

RQ1 and RQ3 are addressed in **Study 1** (synchronous, lab or online). RQ2 and parts of RQ4 are addressed in **Study 2** (longitudinal, deployed system).

---

## Study 1: Label comprehension and privacy mental model

### Design

Between-subjects, 4 × 1 factorial, with a constant receipt UI and one manipulated factor: the label applied to the receipt identifier.

| Condition | Label shown | Rationale |
|-----------|-------------|-----------|
| A | "vote fingerprint" | Current implementation |
| B | "confirmation code" | Common ecommerce convention |
| C | "nullifier" | Cryptographic correct term |
| D | "receipt ID" | Generic, neutral |

Choice: "confirmation code" is the strongest plausible alternative (familiar, implies the submission was confirmed, no scary prefix). "Nullifier" is the worst-case baseline from the literature (Helios-style systems, known to confuse). "Receipt ID" is a neutral control.

The rest of the receipt UI (layout, privacy copy, download button, verification instructions) is held constant across conditions.

### Stimuli

A static HTML mockup of the receipt screen, deployed at a unique URL per condition. The mockup does not require an Aztec wallet or live contract. It shows:
- "Your vote has been cast privately."
- The receipt identifier, labelled according to condition.
- Privacy copy: "This receipt does not contain your vote choice. It proves your ballot was counted."
- Download button (simulated).
- Verification instructions (collapsed by default).

The mockup is self-contained JavaScript; no server required. A working prototype exists at `packages/react/src/components/VoteReceipt.tsx`.

### Participants

Target: **n = 70 per condition** (N = 280 total), recruited via Prolific. *(Corrected from n = 50 before OSF upload — see pre-registration §4.2 power analysis note.)* Inclusion criteria: US-resident adults, age 18+, English-speaking, completed at least one online vote or poll in the past 12 months. Exclusion: self-reported software engineering professionals (to avoid domain-expert contamination).

**Power analysis:** For the primary RQ1 measure (comprehension accuracy, binary), assuming a 20-percentage-point difference between the best and worst conditions (70% vs. 50%), and using a chi-squared test of proportions, α = 0.05, power = 0.80: required n = 49 per cell (G*Power 3.1). n = 50 gives adequate power with a small margin.

For the secondary measure (comprehension confidence, 7-point Likert), assuming a medium effect size (Cohen's d = 0.5, based on the Whitten/Tygar 1999 and Helios usability literature), one-way ANOVA, α = 0.05, power = 0.80: required n ≈ 52 per cell. n = 50 is marginally underpowered on this measure; consider n = 55 per cell (N = 220) for the full study.

**Pilot:** Run n = 10 per condition (N = 40) before full recruitment to validate task clarity and check for floor/ceiling effects on the comprehension questions.

### Procedure

Each participant:
1. Reads a brief cover scenario: "You have just cast a private vote in an online election. The following screen appeared after your vote was submitted."
2. Views the receipt mockup (assigned condition) for up to 2 minutes.
3. Answers comprehension questions (see below) without being able to return to the mockup.
4. Rates confidence on each answer (7-point Likert).
5. Answers demographic items and attention checks.

Total estimated time: 8–12 minutes.

### Measures

**Primary:**

- **Comprehension accuracy (RQ1):** 5 multiple-choice questions presented after the mockup is hidden. Each question tests a specific inference:
  1. Does this value (shown) prove that the vote was counted? (Yes/No/Unsure)
  2. Does this value prove which option the voter chose? (Yes/No/Unsure — correct: No)
  3. If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted? (Yes/No/Unsure — correct: No)
  4. What would happen if you lost this value? (a) You would lose your vote / (b) You could still verify but would not have proof / (c) The system keeps a backup / (d) Your vote would be reversed
  5. Why might the system choose not to show you your vote choice on this screen? (open-ended, scored by two raters)

  Composite accuracy = proportion correct on Q1–Q4; Q5 scored separately.

- **Confidence** (mean across Q1–Q4, 7-point Likert, 1 = not at all confident, 7 = completely confident). Q5 confidence is collected but excluded from the composite because Q5 is open-ended and scored separately. _Pre-registered composite: Q1–Q4 only (pre-registration §5.3)._

**Secondary:**

- **Behavioral intent** (RQ2 proxy): "If this screen appeared after a real vote, would you download this file?" (Definitely yes / Probably yes / Unsure / Probably no / Definitely no)
- **Mental model quality** (RQ3): Asked after Q1–Q4: "In your own words, what does this value prove about your vote?" (Free text, scored for presence of inclusion concept, absence of choice-leakage concept; inter-rater reliability via Cohen's κ)
- **Label affect**: "What is your first reaction to the label [LABEL]?" (valence slider: -3 = negative, +3 = positive)

**Attention checks:** 2 standard Prolific-style items (follow-instruction checks); participants failing both are excluded.

### Analysis

This section summarises the pre-registered analysis plan. The binding specification is in `docs/piup-study1-preregistration-2026-06-22.md` §6; the pre-registration governs in any conflict.

**Omnibus (RQ1):** Chi-squared test of homogeneity across 4 conditions on composite accuracy (Q1–Q4). Effect size: Cramér's V. Proceed to pre-specified pairwise comparisons if omnibus is significant; H2-primary and H3 Q1 tests are conducted regardless of omnibus outcome.

**Four confirmatory hypothesis families (14 pre-specified tests total), each family Holm-corrected independently:**

| Family | Tests | # |
|--------|-------|---|
| H1 (vote fingerprint > receipt ID on privacy items) | Q2(A>D), Q3(A>D) one-tailed | 2 |
| H2 (dissociation: vote fingerprint vs. confirmation code) | Q2(A>B) one-tailed [**primary endpoint**], Q3(A>B) one-tailed, TOST composite A≈B ±10pp | 3 |
| H3 (nullifier underperforms all others) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<each of A,B,D) | 6 |
| H4 (confirmation code overconfidence) | confidence-composite(B>A), (B>C), (B>D) one-tailed ANOVA/Tukey | 3 |

**H2 outcome classification (pre-specified):**
- *Supported:* H2-primary significant (A > B on Q2) AND H2-tertiary equivalence established.
- *Null:* H2-primary non-significant AND equivalence established.
- *Reversed:* post-hoc B > A on Q2 significant AND equivalence or B advantage on composite.
- *Inconclusive:* none of the above.

**H4 calibration:** Spearman ρ between per-participant composite accuracy (Q1–Q4) and per-participant confidence composite (Q1–Q4), computed per condition. H4 predicts Condition B will have the lowest calibration (high confidence, not highest accuracy).

**Q5 (open-text mental model):** Kruskal-Wallis across 4 conditions; Dunn's pairwise post-hoc (Holm). Scored 0–2 by 2 raters; κ ≥ 0.70 required before analysis.

**RQ3 (mental model quality, open text):** Chi-squared on 0/1/2 rubric score; Cohen's κ ≥ 0.70 required. (Distinct from Q5; see pre-registration §5.2 and §5.3.)

**Confidence intervals:** Wilson 95% CI for all proportions; t-based 95% CI for all means.

**Software:** R ≥ 4.3. Packages: `stats`, `PropCIs`, `TOSTER`, `multcomp`, `irr`. Pre-registered analysis script: `analysis/piup-study1-analysis.R`.

_Any analysis not listed above is exploratory and will be reported as such._

Expected primary finding: "vote fingerprint" and "confirmation code" both outperform "nullifier" on composite accuracy (replicating Helios UX findings). Critically, H2 predicts a *dissociation* between these two top conditions — not a global accuracy difference. "vote fingerprint" is expected to outperform "confirmation code" specifically on Q2 (does this prove which option I chose?) and Q3 (coercion scenario), while both conditions remain within 10 percentage points on composite accuracy (Q1–Q4). "confirmation code" may edge "vote fingerprint" on Q1 (vote-counted inference) because the eCommerce behavioral schema is correct even where the representational schema is not. If H2 is reversed (B > A on Q2), the finding is still actionable and arguably more novel. Full mechanism analysis: `docs/h2-analysis-fingerprint-vs-confirmation-code.md`.

---

## Study 2: Verification behavior (longitudinal)

### Design

Observational within-subjects, deployed in a real or realistic election context. Participants cast a vote, receive a PIUP receipt, and are contacted 2 weeks later to check whether they verified their vote.

Study 2 cannot be run on the aztec-private-voting testnet alone (limited participant pool, no real stakes). Two deployment contexts:
1. A simulated student election, run with a partner university department. Stakes are real (outcome matters to participants) but low-risk.
2. A series of public community polls run on the deployed contract, with recruited participants.

Context (1) is preferred: natural motivation to verify, real deadlines, lower demand effects.

### Participants

Target: **n = 80** (estimate; see power note). Inclusion: any voter in the partner election. No exclusion criteria beyond consent.

**Power note:** RQ2 is exploratory; no strong prior for expected verification rate. If baseline verification is ~30% (analogous to receipt-checking behavior in e-commerce, Adida et al. 2009 participant behavior) [Fixed tick-4048: year 2008→2009; ADR-037/tick-4046 + pre-reg/tick-4040 propagation], and we expect behavioral intent to predict actual verification with an odds ratio of ~2.5, logistic regression power = 0.80 at n ≈ 65. n = 80 provides a buffer.

### Procedure

1. **T0 (election day):** Participants vote using the standard interface. After voting, they see the PIUP receipt with the download prompt. We record: (a) whether they downloaded, (b) their stated behavioral intent ("will you try to verify this?"), (c) their stated privacy confidence.
2. **T+3 days:** Short email follow-up. No prompting to verify. Ask: "Did you look at your receipt after the election?" (Yes/No/Don't remember)
3. **T+14 days:** Full follow-up survey. Measures:
   - Verification: "Did you try to verify your vote? If yes, describe what you did."
   - Outcome: "If you tried, were you able to verify successfully?"
   - Barrier: For non-verifiers — "What stopped you?" (open multi-select + free text)
   - Comprehension at T+14: same Q1–Q4 from Study 1, to measure retention decay.

4. **Passive measurement (where ethically and technically possible):** Log `verify_vote_counted()` calls from unique receipt IDs. This gives ground-truth verification behavior without relying on self-report. Only possible if participants opt into logging; default off.

### Measures

**Primary (RQ2):**
- Verification rate at T+14 (binary: tried or not tried, regardless of success)
- Successful verification rate at T+14

**Secondary:**
- T0 stated intent vs. T+14 actual behavior (intention-behavior gap)
- Predictors: downloaded (vs. not), stated intent, privacy confidence, technology self-efficacy (3-item scale from Hargittai 2009)
- Barrier taxonomy from open-coded free text (2 raters; κ ≥ 0.70)
- Comprehension retention (T+14 accuracy vs. Study 1 baseline)

### Analysis

- Verification rate: descriptive proportions with 95% CI; binomial test against 50% null.
- Predictors: binary logistic regression with download, intent, self-efficacy as predictors; report odds ratios + 95% CI.
- Intention-behavior gap: McNemar test (paired binary: stated intent at T0 vs. verified at T+14).
- Barriers: frequency table + χ² to test whether barriers differ by download behavior.

---

## Study 3 (optional, if time and IRB permit): Coercion surface

### Design

Between-subjects vignette study. Participants are shown either a PIUP receipt (condition A) or a choice-visible receipt (condition B), then presented with a coercion vignette: an authority figure (employer, family member) demands the receipt as proof of voting behavior. Dependent variable: stated compliance with the demand.

This study does not require a real election. It uses a scenario-based design (Green and Gerber 2002, Knox et al. 2019 for vignette methods in political behavior research).

A single coercion demand vignette has been used in voting UX studies (Kulyk et al. 2017 on coercibility perception in remote electronic voting) [CONFIRMED NOT IN DBLP tick-4054. CANDIDATE REPLACEMENT VERIFIED tick-4056: Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). 'Voting Under Pressure: Perceptions of Counter-Strategies in Internet Voting.' E-VOTE-ID 2025. DOI: 10.1007/978-3-032-05036-6_10 — DBLP-verified (dblp.org/rec/conf/evoteid/NissenHBVK25). This paper (a) is by the same Kulyk research group, (b) is directly about coercion perception in internet voting, matching the body description. Jony must choose before submission: (a) replace with Nissen et al. 2025 (recommended — best match for coercion-vignette precedent), (b) supply the original DOI/page-range if 'Kulyk 2017 INTERACT' exists as an unindexed workshop paper, or (c) remove and rephrase as protocol design rationale. Do NOT submit with the current Kulyk 2017 INTERACT reference.]; the current protocol adapts that design to the private-voting receipt context.

**Note on ethics:** The coercion scenario is described as hypothetical and involves no real coercive pressure on participants. IRB review should confirm that the vignette design does not itself constitute a coercive act.

---

## IRB considerations

Studies 1 and 3 (online, no live election, no real stakes): likely exempt under 45 CFR 46.104(d)(2) (survey/interview research with no more than minimal risk and no identifiable sensitive information). Standard Prolific terms apply.

Study 2 (real election, longitudinal follow-up, possible log data): not exempt. Key considerations:
- Consent: two-stage consent (initial at T0, re-consent for T+14 follow-up)
- Data minimization: receipt IDs in logs are pseudonyms; no wallet addresses stored server-side
- Right to withdraw: participants may withdraw at T+3 follow-up without loss of their vote
- Log data: opt-in only; raw logs deleted after aggregation

Anticipated IRB category: expedited review (survey-based research with minor deception risk in Study 3 vignette).

---

## Expected outcomes and implications for design

**If "vote fingerprint" outperforms alternatives on both accuracy and privacy mental model (RQ1, RQ3):** The current label is justified. Document as an evidence-based design decision in the grant application and PIUP pattern writeup.

**If "confirmation code" matches "vote fingerprint" on accuracy but outperforms on behavioral intent (RQ2 proxy):** Consider a hybrid: "Your vote fingerprint" as the heading, "confirmation code" as the sublabel. Tests whether label hierarchy can split the difference.

**If verification rates are low despite positive stated intent (RQ2):** The barrier analysis determines the fix — most likely a reminder mechanism (e.g., calendar link at T0) rather than a UI redesign.

**If mental model quality is poor across all conditions (RQ3):** The copy, not the label, is the problem. Qualitative analysis of Q5 (open-ended: "what does this prove?") will surface the misunderstanding. Most likely cause: users are forming a "confirmed action" model (the fingerprint proves I did the thing) rather than an "inclusion verification" model (the fingerprint lets me check the thing was processed). The fix is an animated or progressive disclosure version of the verification flow.

**PIUP generalisation (beyond voting):** If Study 1 results replicate across a non-voting PIUP scenario (e.g., anonymous whistleblower submission), the pattern can be formalized in the design literature without dependence on the voting context. A two-scenario within-subjects version of Study 1 (half see voting, half see whistleblowing, counterbalanced) would test this at minimal additional cost.

---

## Timeline and resource estimate

| Phase | Duration | Cost estimate (Prolific) |
|-------|----------|--------------------------|
| Stimuli + mockup (already exists, needs parameterization) | 1 week | — |
| IRB submission (Study 1) | 4–6 weeks | — |
| Study 1 pilot | 1 week | ~$120 (n=40 × $3/participant) |
| Study 1 full | 2 weeks | ~$600 (n=200 × $3/participant) |
| Analysis + writeup | 2 weeks | — |
| Study 2 deployment setup | 4 weeks (parallel with Study 1 analysis) | — |
| Study 2 data collection | 3 weeks (T0 + T+14) | ~$240 (n=80 × $3/participant) |
| Study 2 analysis + writeup | 2 weeks | — |
| **Total** | **~5 months concurrent** | **~$960** |

Study 3 adds ~4 weeks and ~$300.

This is a feasible single-researcher thesis chapter, or a strong conference submission (CHI / UIST / SOUPS) with 2–3 months runway.

---

## References

- Adida, B., de Marneffe, O., Pereira, O., & Quisquater, J.-J. (2009). Electing a university president using open-audit voting: Analysis of real-world use of Helios. *EVT/WOTE 2009*. [Fixed tick-4048: year 2008→2009, venue 2008→2009; same correction as pre-reg tick-4040 and ADR-037 tick-4046]
- Bell, S., et al. (2013). STAR-Vote: A secure, transparent, auditable, and reliable voting system. *EVT/WOTE 2013*.
- Benaloh, J., & Tuinstra, D. (1994). Receipt-free secret-ballot elections. *STOC 1994*.
- Das, S., et al. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. *SOUPS 2014*. [Fixed tick-4048: venue CCS→SOUPS; same correction as pre-reg tick-4042 and ADR-037 tick-4046]
- Green, D. P., & Gerber, A. S. (2002). Reclaiming the experimental tradition in political science. *Political Science: The State of the Discipline*.
- Hargittai, E. (2009). An update on survey measures of web-oriented digital literacy. *Social Science Computer Review*.
- Kulyk, O., et al. (2017). Does my vote count? Voter experience with verifiability in internet voting. *INTERACT 2017*. [CONFIRMED NOT IN DBLP tick-4054 (2026-06-27). CANDIDATE REPLACEMENT VERIFIED tick-4056: Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). 'Voting Under Pressure: Perceptions of Counter-Strategies in Internet Voting.' *E-VOTE-ID 2025*. DOI: 10.1007/978-3-032-05036-6_10 (DBLP-verified: dblp.org/rec/conf/evoteid/NissenHBVK25). This 2025 paper is by the same Kulyk group and matches the body description ('coercibility perception in remote electronic voting'). Recommendation: replace this entry with the Nissen et al. 2025 citation. Body text cross-ref should change from 'Kulyk et al. 2017' to 'Nissen et al. 2025'. Do NOT submit the current entry — it does not exist. Action required before submission (Jony confirmation of option (a), (b), or (c) as noted in §3.3 body note).]
- Whitten, A., & Tygar, J. D. (1999). Why Johnny can't encrypt: A usability evaluation of PGP 5.0. *USENIX Security 1999*.
