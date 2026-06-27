# Pre-Registration: PIUP Study 1 — Receipt Identifier Label Comprehension

**Pre-registration date:** 2026-06-22  
**Author:** Jony Bursztyn  
**Study status at pre-registration:** Stimuli complete; pilot not yet run. This document locks endpoints and analysis plan before any participant data is collected.  
**OSF template version:** AsPredicted v6 (adapted)  
**Companion documents:**
- [`docs/piup-study-protocol-2026-06-22.md`](piup-study-protocol-2026-06-22.md) — full protocol
- [`docs/adr-037-piup-study1-label-rationale.md`](adr-037-piup-study1-label-rationale.md) — hypothesis rationale + prior literature
- [`docs/h2-analysis-fingerprint-vs-confirmation-code.md`](h2-analysis-fingerprint-vs-confirmation-code.md) — H2 mechanism analysis

---

## 1. Title

**"Does the receipt identifier label affect comprehension of what private voting receipts prove? A between-subjects experiment on ZK receipt UX."**

---

## 2. Study overview

### 2.1 Research questions

**RQ1 (Label comprehension).** Which receipt identifier label — *vote fingerprint*, *confirmation code*, *nullifier*, or *receipt ID* — produces the most accurate comprehension of what the identifier proves and what it does not prove?

**RQ3 (Privacy mental model).** Does the current receipt UI cause users to correctly infer that their vote choice is hidden from the system?

(RQ numbering follows the parent protocol. RQ2 and RQ4 are addressed in Study 2.)

### 2.2 Study design

Between-subjects, 4 × 1 factorial experiment. Single manipulated factor: receipt identifier label.

| Condition | Label | Category |
|-----------|-------|----------|
| A | vote fingerprint | Metaphor-activating (current production) |
| B | confirmation code | eCommerce convention |
| C | nullifier | Cryptographically correct |
| D | receipt ID | Generic / neutral |

The remainder of the receipt UI (privacy copy, layout, download prompt, verification instructions) is held constant across all conditions. See `study-stimuli/condition-a-fingerprint.html`, `condition-b-confirmation-code.html`, `condition-c-nullifier.html`, `condition-d-receipt-id.html` for the exact stimuli used.

### 2.3 Platform

Prolific (online panel). Participants are anonymous and not connected to any real election.

---

## 3. Hypotheses

### H1 — "vote fingerprint" > "receipt ID" on privacy mental model

**Directional prediction:** Condition A will outperform Condition D on Q2 and Q3 (privacy-mental-model items) by ≥ 10 percentage points.

**Mechanism:** "Fingerprint" carries the opacity affordance (uniqueness without disclosure); "receipt ID" carries no affordance about what the identifier does or does not reveal. See ADR-037 §H1.

**Pre-registered test:** Q2 accuracy, A vs. D, one-tailed (A > D), α = 0.05. Q3 accuracy, A vs. D, one-tailed, α = 0.05. Both tests are required to support H1.

---

### H2 — "vote fingerprint" and "confirmation code" dissociate across question type

**Directional prediction:** A and B will be within 10 percentage points on composite accuracy (Q1–Q4), but A will outperform B specifically on Q2 (≥ 10 pp advantage) and Q3 (≥ 8 pp advantage). B may equal or edge A on Q1 (0–10 pp, non-directional).

**Mechanism:** "Confirmation code" activates the correct *behavioral* schema (save it to verify later) but the wrong *representational* schema (the system has a record of my specific choice, as in eCommerce). "Vote fingerprint" activates the opacity metaphor (uniqueness without content) needed for correct privacy mental model. This produces a predicted *dissociation within the question set*, not a global accuracy difference. Full mechanism analysis in `docs/h2-analysis-fingerprint-vs-confirmation-code.md`.

**This is the pivot hypothesis.** All three outcome patterns (supported / null / reversed) produce actionable production decisions. See §6 (Decision Framework) below.

**Pre-registered tests for H2 (in priority order):**

1. **H2-primary:** Q2 accuracy, A vs. B, one-tailed (A > B), α = 0.05. This is the single pre-specified primary endpoint for H2.
2. **H2-secondary:** Q3 accuracy, A vs. B, one-tailed (A > B), α = 0.05.
3. **H2-tertiary (equivalence):** Composite accuracy (Q1–Q4), A vs. B, two-tailed equivalence test using two one-sided tests (TOST), equivalence bounds ±10 percentage points, α = 0.05 per side.

H2 is considered **supported** if H2-primary is significant (A > B on Q2) AND H2-tertiary equivalence is established (composite ≈ equal).  
H2 is considered **null** if H2-primary is not significant AND H2-tertiary equivalence is established.  
H2 is considered **reversed** if H2-primary favours B (B > A on Q2 at α = 0.05, tested post-hoc).

---

### H3 — "nullifier" underperforms all other conditions on Q1 and composite accuracy

**Directional prediction:** Condition C will score lowest on Q1 (vote-counted inference) and on composite accuracy (Q1–Q4). Predicted < 45% accuracy on Q1 vs. ≥ 65% for Condition A.

**Mechanism:** The string "null-" in "nullifier" is lexically adjacent to "void" and "cancel" in most English-language mental models; users may interpret "nullifier" as evidence their vote was nullified. See ADR-037 §H3 for Helios/STAR-Vote precedent.

**Pre-registered tests:**
- Q1 accuracy, C vs. {A, B, D} (each), one-tailed (C < each), α = 0.05.
- Composite accuracy, omnibus chi-squared across all 4 conditions; if significant, Holm-corrected pairwise comparisons with C vs. each other condition extracted.

**Ethics clause:** If the pilot (n = 10/cell) shows < 30% Q1 accuracy in Condition C (active vote-cancellation misreading), the full study may substitute a fifth label for Condition C. This is an ethics decision, not a data-driven stopping rule; it does not affect the alpha level for H3 in the full study.

---

### H4 — "confirmation code" produces highest confidence regardless of accuracy

**Directional prediction:** Condition B will have the highest mean confidence rating (7-point Likert) across Q1–Q4, but will not rank first on composite accuracy.

**Mechanism:** Familiarity with eCommerce "confirmation codes" produces high self-assessed competence (calibration failure) even when it produces the wrong representational schema for Q2/Q3. See ADR-037 §H4; Das, Dabbish, and Hong (2014) on security confidence vs. behaviour.

**Pre-registered tests:**
- Mean confidence, B vs. {A, C, D} (each), one-tailed (B > each), one-way ANOVA + pre-specified Tukey HSD comparisons.
- Accuracy × confidence calibration analysis: Spearman rank correlation between mean confidence and composite accuracy, computed per condition. H4 predicts B will be an outlier (high confidence, moderate accuracy).

---

## 4. Sampling plan

### 4.1 Target sample

**Full study:** n = 70 per condition (N = 280 total). *(Corrected from n = 50 before OSF upload — see §4.2 power analysis note.)*  
**Pilot:** n = 10 per condition (N = 40 total).

**Inclusion criteria:**
- US-resident adults, age 18+
- English-speaking (Prolific: English as first language or fluent)
- Completed at least one online vote, poll, or election in the past 12 months
- No prior participation in this study (Prolific deduplication)

**Exclusion criteria (pre-specified):**
- Self-reported software engineering professionals (computer science / software dev / cryptography as primary occupation) — to prevent domain-expert contamination of mental model measures
- Failing both attention checks (not just one)
- Response time < 90 seconds (indicates non-serious completion; too fast to have read the mockup and answered questions)

### 4.2 Power analysis

**H2 primary endpoint (Q2 accuracy, A vs. B, one-tailed):** For a 15 pp difference (A: 65%, B: 50%) on Q2 specifically, G\*Power 3.1.9.7, test: "Proportion: Inequality of two independent proportions", Cohen's h = 0.30, one-tailed, α = 0.05, power = 0.80: required n = 67 per cell. Target n = 70 per cell (N = 280) provides approximately 82% power.

*Correction note (pre-OSF):* The original power calculation used "Proportion: Inequality of two dependent proportions" (McNemar test, a within-subjects test), which does not apply to this between-subjects design. The original figure of n = 49 per cell was therefore incorrect. This is corrected to n = 67 (target n = 70) before OSF upload. No data have been collected under the original n = 50 target.

**Primary omnibus (composite accuracy, binary):** Chi-squared test of proportions, 4 conditions (df = 3, effect size w ≈ 0.18). At n = 70 per cell the omnibus power is approximately 0.67; 80% power for the omnibus would require n ≈ 82 per cell. The omnibus is a secondary descriptive test; the H2 pairwise endpoint is the primary confirmatory test. If pilot data suggests the Q2 effect is substantially smaller than 15 pp, n will be expanded to n = 75/cell (N = 300) before full launch.

**Confidence (Likert) secondary measure:** Cohen's d = 0.5, one-way ANOVA, α = 0.05, power = 0.80: required n ≈ 52 per cell. Same note applies.

**Stopping rule:** No interim stopping for efficacy or futility. The pilot (N = 40) is for instrument validation only (floor/ceiling check, timing validation), not hypothesis testing. Pilot data will not be used to adjust alpha levels, power, or the primary endpoint.

---

## 5. Measured variables

### 5.1 Stimuli

Four HTML mockups (condition-a-fingerprint.html, condition-b-confirmation-code.html, condition-c-nullifier.html, condition-d-receipt-id.html), identical except for the receipt identifier label, its ARIA label, and two label-name references in the collapsed verification panel. Commit `fb710f5` contains the exact stimuli as pre-registered. Any change to stimuli after this pre-registration constitutes an amendment; amended stimuli are not covered by this pre-registration.

### 5.2 Primary measures

**Comprehension accuracy (per question, binary: correct/incorrect):**

- **Q1:** "Does this value prove that your vote was counted?" Correct answer: **Yes**. Foil: No / Unsure.  
  *(Tests: was the ballot inclusion event correctly understood?)*

- **Q2:** "Does this value prove which option you chose?" Correct answer: **No**. Foil: Yes / Unsure.  
  *(Tests: representational schema — does the user understand the identifier is choice-blind?)*

- **Q3:** "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?" Correct answer: **No**. Foil: Yes / Unsure.  
  *(Tests: privacy model applied to a real-world coercion scenario. Clarification appended: "Assume they can only see what is on this screen." This wording is in the stimuli and cannot be changed post-registration without amendment.)*

- **Q4:** "What would happen if you lost this value?" Correct answer: **(b) You could still verify that your vote was counted, but you would not have proof that the receipt is yours.** Foils: (a) you would lose your vote; (c) the system keeps a backup; (d) your vote would be reversed.  
  *(Tests: behavioral consequence of losing the receipt — understanding that the vote is not rescindable.)*

- **Q5 (open-ended, scored separately):** "Why might the system choose not to show you your vote choice on this screen?"  
  Scored on a 3-point scale: 0 = no correct privacy concept (technical error attribution, storage explanation, or expressed confusion); 1 = references privacy, anonymity, ballot secrecy, or coercion/surveillance protection without explaining why the system does not record or reveal the vote choice; 2 = explains that the system does not store or reveal the voter’s specific choice (mechanism explanation), with or without explicit coercion framing. Full rubric in survey instrument §11.  
  Scored by 2 independent raters; inter-rater reliability required: Cohen's κ ≥ 0.70. Q5 is not included in composite accuracy.

**Composite accuracy:** Proportion correct on Q1–Q4 (range: 0–4, treated as proportion 0–1.0). This is the primary RQ1 measure.

### 5.3 Secondary measures

**Confidence:** After each comprehension question (Q1–Q4), participants rate their confidence on a 7-point Likert scale (1 = not at all confident, 7 = completely confident). Mean across Q1–Q4 = confidence composite. Q5 is open-ended and receives no confidence rating.

**Mental model quality (RQ3, open text):** After Q1–Q4, participants answer: "In your own words, what does this value prove about your vote?" Free text, scored 0–2 (0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states choice is hidden from system). Two raters; κ ≥ 0.70 required.

**Behavioral intent (RQ2 proxy):** "If this screen appeared after a real vote, would you download this file?" (5-point: Definitely yes → Definitely no.)

**Label affect:** "What is your first reaction to the label [LABEL]?" (Valence slider: −3 to +3.) Asked after all comprehension questions.

### 5.4 Covariates (collected but not pre-specified as primary analyses)

- Age (categorical: 18–24, 25–34, 35–44, 45–54, 55+)
- Prior voting experience (online poll only vs. official election)
- Technology self-efficacy (3-item scale, Hargittai 2009: "How would you rate your own level of internet skills?")
- Prolific attention checks: 2 items ("Which of the following is a fruit? / Please select 'strongly agree' for this item.")

---

## 6. Analysis plan

### 6.1 Pre-processing

1. Exclude participants failing both attention checks. Record n excluded.
2. Exclude participants with response time < 90 seconds total. Record n excluded.
3. Exclude self-reported software engineers. Record n excluded.
4. Verify condition assignment balance; report any imbalance.
5. Code Q5 open text by 2 raters before merging with quantitative data; confirm κ ≥ 0.70 before analysis.
6. Code mental model open text by 2 raters; confirm κ ≥ 0.70.
7. No imputation of missing responses; missing answers treated as incorrect.

### 6.2 Primary analysis — RQ1 (omnibus)

**Test:** Chi-squared test of homogeneity across 4 conditions on composite accuracy.  
**Coding:** Composite accuracy dichotomised at median correct responses of the distribution (post-hoc median split) for the chi-squared test. Report both binary and continuous (proportion) results.  
**Significance:** α = 0.05, two-tailed.  
**Effect size:** Cramér's V.  
**Reporting:** Report counts + proportions per condition + confidence intervals (Wilson method).

If the omnibus test is significant, proceed to pre-specified pairwise comparisons (§6.3). If non-significant, report null result without pairwise comparisons (except H2-primary and H3 Q1 tests, which are pre-specified regardless of omnibus outcome).

### 6.3 Planned pairwise comparisons and family-wise correction

**Multiple comparisons policy:** All pre-specified confirmatory tests (H1–H4) are conducted at α = 0.05 before correction. Holm-Bonferroni sequential correction is applied within each hypothesis family separately. Families are defined as:

| Family | Tests | # tests |
|--------|-------|---------|
| H1 (fingerprint > receipt ID on privacy) | Q2(A>D), Q3(A>D) | 2 |
| H2 (dissociation: fingerprint vs. confirmation code) | Q2(A>B) one-tailed, Q3(A>B) one-tailed, TOST composite A≈B | 3 |
| H3 (nullifier underperforms) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<each) | 6 |
| H4 (confirmation code overconfidence) | confidence(B>A), confidence(B>C), confidence(B>D) | 3 |

Holm correction is applied within each family. Cross-family corrections are not applied (each hypothesis is a pre-specified, independent prediction).

**Total pre-specified confirmatory tests: 14.**

Any additional pairwise comparisons (e.g. A vs. D on composite, B vs. C on Q2) are **exploratory** and reported as such with a note that they were not pre-registered.

### 6.4 H1 tests

**H1-Q2:** Chi-squared (2 × 2: conditions A and D × Q2 correct/incorrect), one-tailed, α = 0.05. Report OR (odds ratio) + 95% CI.  
**H1-Q3:** Same structure for Q3.  
**Support criterion:** Both H1-Q2 and H1-Q3 must be significant (Holm-corrected within H1 family, m = 2).

### 6.5 H2 tests

**H2-primary (Q2, A vs. B):**  
Chi-squared (2 × 2: conditions A and B × Q2 correct/incorrect), one-tailed, α = 0.05.  
This is the single pre-specified primary endpoint for H2. A significant result here with A > B supports the representational schema dissociation claim.

**H2-secondary (Q3, A vs. B):**  
Chi-squared (2 × 2: conditions A and B × Q3 correct/incorrect), one-tailed, α = 0.05.

**H2-tertiary (composite equivalence, A vs. B):**  
Two one-sided tests (TOST) on composite proportion. Equivalence bounds: [−0.10, +0.10] (10 percentage points). α = 0.05 per one-sided test.  
Equivalence is established if both one-sided p-values are < 0.05. If equivalence cannot be established, report the composite effect size (Cohen's h) and its CI.

**H2 outcome classification (reported in discussion):**
- **Supported:** H2-primary significant (A > B on Q2) AND H2-tertiary establishes equivalence.
- **Null:** H2-primary non-significant AND H2-tertiary establishes equivalence.
- **Reversed:** H2-primary non-significant; post-hoc test Q2(B > A) significant at α = 0.05 (two-tailed). AND H2-tertiary establishes equivalence or B > A on composite.
- **Inconclusive:** Does not fall into any of the above categories. Report effect sizes; expand n or revise design.

Note: The Q1 analysis (B ≥ A on vote-counted inference) is **not** pre-specified as a confirmatory test for H2 because the prediction is non-directional ("B may equal or edge A"). It will be reported descriptively as a check on the proposed mechanism (H2 predicts a crossover, with B edging A on Q1 and A edging B on Q2/Q3).

### 6.6 H3 tests

**H3-Q1 (per pair):** Three one-tailed chi-squared tests: Q1 accuracy, C vs. A (C < A); C vs. B (C < B); C vs. D (C < D). Holm correction within H3 family (m = 6).  
**H3-composite:** One-way ANOVA-equivalent for proportions; if omnibus significant, Holm-corrected pairwise extractions for C vs. each other condition.  
**Support criterion:** C must be significantly lower than at least 2 of the 3 other conditions on Q1 (after Holm correction).

### 6.7 H4 tests

**H4-confidence:** One-way ANOVA on confidence composite (mean Q1–Q4). If significant (F test α = 0.05), Tukey HSD post-hoc for B vs. A, B vs. C, B vs. D.  
**H4-calibration:** For each condition, compute Spearman rank correlation between per-participant Q1–Q4 accuracy score (0–4) and per-participant confidence composite. Report by condition. H4 predicts the B correlation will be smaller (lower calibration) than the A correlation — this is the over-confidence claim stated as a calibration residual.

### 6.8 Q5 (open-text mental model) analysis

Q5 is not part of composite accuracy. Scored by 2 raters (0–2 scale; see §5.2). If κ < 0.70, raters adjudicate disagreements and rescore before analysis.  
**Analysis:** Kruskal-Wallis test across 4 conditions; Dunn's pairwise post-hoc (Holm correction).  
**Supplementary:** 25 randomly sampled responses per condition included in the published write-up to illustrate mental model range; sampling is random and performed before hypothesis testing.

### 6.9 Confidence interval standard

All proportions: Wilson 95% CI (appropriate for binary outcomes near 0.5 with n = 70). All means: standard 95% CI from t-distribution. All ORs: log-scale 95% CI. [Fixed tick-4028: 'n = 50' updated to 'n = 70' — stale reference to the pre-correction sample size (n = 50 was the original McNemar-based target; corrected to n = 70 per cell before OSF upload per §4.1/§4.2 power analysis note). Wilson CIs remain appropriate at n = 70; the parenthetical now reflects the actual target.]

### 6.10 Software

R (v ≥ 4.3). Planned packages: `stats`, `PropCIs` (Wilson CIs), `TOSTER` (equivalence tests), `multcomp` (Holm corrections), `irr` (Cohen's κ). Analysis script to be written before pilot data collection; will be uploaded to OSF alongside this pre-registration.

---

## 7. Pilot protocol

### 7.1 Purpose of the pilot

The pilot (n = 10/cell, N = 40) is for instrument validation only. It is not used for hypothesis testing. Pilot data will not be combined with full-study data.

**Pilot goals:**
1. Verify that comprehension questions have no floor (< 20% correct on any question in Conditions A/B) or ceiling (> 90% correct) effects.
2. Validate estimated task completion time (target 8–12 min).
3. Check that attention check pass rate is > 85% (if < 80%, revise checks before full study).
4. Check whether the Q3 "screenshot metadata" ambiguity described in `docs/h2-analysis-fingerprint-vs-confirmation-code.md` §6 is triggered by > 20% of participants. If so, add the clarification wording.
5. Check for any distributional anomalies in Q5 open text (e.g. near-zero variance in one condition).

### 7.2 Amendments before full study

If the pilot reveals instrument problems (floor/ceiling, widespread confusion in Q3), the following amendments are permitted without a new pre-registration, provided they are documented in the published amendment log:
- Wording changes to Q3 (adding the "assume only what is on screen" clarification)
- Adjusting n/cell to 55 based on pilot effect size estimates

The following require a new pre-registration:
- Changing primary endpoints
- Adding or removing conditions
- Changing the stimuli HTML in ways that alter the receipt label or privacy copy

---

## 8. Deviations policy

Any deviation from this pre-registration during data collection or analysis will be noted in the published paper/report under a "Deviations from pre-registration" section. Deviations will be classified as:
- **Type I (minor):** Software version mismatch, minor n variation (within ±10% of target), post-hoc inclusion of exploratory tests. Does not affect confirmatory claim status.
- **Type II (substantive):** Change to primary endpoint, condition, or stimulus. All analyses after a Type II deviation are treated as exploratory.

---

## 9. Open science commitments

- Study materials (stimuli HTML files, comprehension questions, consent form): published on OSF at registration.
- Analysis script: uploaded before pilot launch.
- Pre-processed data (no identifiers): published with the final report.
- Raw Prolific completion data: not published (Prolific terms); aggregate demographics reported.
- Pre-registration DOI to be included in grant application Section 3.2 when available.

---

## 10. Ethical considerations

**Risk level:** Minimal. Participants view a static mockup of a voting receipt confirmation screen. No real election, no personal voting data, no sensitive personal information collected.

**Deception:** None. Participants are told they are evaluating a prototype voting interface. Cover scenario (see protocol §Procedure) is accurate.

**IRB expectation:** Exempt under 45 CFR 46.104(d)(2) — survey research, no more than minimal risk. Standard Prolific terms apply.

**Coercion scenario (Q3):** The question asks participants to imagine a hypothetical workplace coercion scenario. This is described in the task instructions as hypothetical and does not simulate a real coercive act. If any participant indicates distress (Prolific free-text completion comment), the response will be excluded from analysis and Prolific researcher support notified.

---

## 11. Timeline

| Milestone | Target date |
|-----------|-------------|
| Pre-registration uploaded to OSF | Before pilot launch |
| Stimuli live on static host | Before pilot launch |
| Pilot (N = 40) | Within 2 weeks of OSF registration |
| Instrument amendments (if needed) | Within 1 week of pilot completion |
| Full study launch | Within 4 weeks of OSF registration |
| Data collection complete | Within 6 weeks of full study launch |
| Analysis + report | Within 8 weeks of data collection completion |

---

## 12. Budget

| Item | Cost (USD) |
|------|------------|
| Pilot (N = 40, ~10 min, ~$2.50/participant Prolific) | ~$100 |
| Full study (N = 280, ~10 min, ~$2.50/participant) | ~$700 |
| Platform fee (33%) | ~$264 |
| **Total** | **~$1,064** |

Note: Pilot cost is not included in the Wave 3 grant application budget request, as it will be self-funded from personal research allocation. Full study cost is covered by the grant application research budget.

---

## 13. Decision framework for production label

Independent of statistical significance thresholds, the following pre-specified production decisions apply:

| Study 1 outcome | Production decision |
|----------------|---------------------|
| H1 supported; H2 supported (A > B on Q2/Q3, A ≈ B composite) | Keep "vote fingerprint" default. |
| H2 null (A ≈ B on all measures, composite equivalence established) | Consider switching to "confirmation code." Familiarity benefit with no privacy cost. |
| H2 reversed (B > A on Q2 accuracy AND B ≥ A composite) | Switch to "confirmation code" immediately. Update VoteReceipt.tsx default labelVariant. |
| H3 supported (C << all others on Q1) | Confirm "nullifier" excluded from production. No codebase change required. |
| H4 supported (B highest confidence, not highest accuracy) | Add confidence calibration note to PIUP documentation. Flag for Study 2 trust/over-trust analysis. |
| No significant differences (all conditions ≈ 55%) | Comprehension failure is label-independent. Redesign privacy copy, not the label. Study 2 and 3 become relatively more important. |
| H2 reversed AND H4 supported simultaneously | Most important finding: familiarity (B) beats metaphor (A) even on privacy items, but produces calibration failure. Decision: use B in default; add trust-calibration intervention for privacy-critical deployments. Publish immediately — this is the novel result. |

---

## 14. Amendments log

| Date | Amendment type | Description | Authorized by |
|------|---------------|-------------|---------------|
| (none at pre-registration) | — | — | — |

---

## References

- Whitten, A. and Tygar, J.D. (1999). "Why Johnny Can't Encrypt." *USENIX Security.*
- Adida, B., et al. (2008). "Electing a University President Using Open-Source Software: The Helios Voting System." *USENIX EVT.*
- Bell, S., et al. (2013). "STAR-Vote." *USENIX EVT/WOTE.*
- Cranor, L.F. and Garfinkel, S. (eds.) (2005). *Security and Usability.* O'Reilly.
- Felt, A.P., et al. (2012). "How to Ask for Permission." *USENIX HotSec.*
- Das, S., Dabbish, L. and Hong, J. (2014). "The Effect of Social Influence on Security Sensitivity." *ACM CCS 2014.*
- Hargittai, E. (2009). "An Update on Survey Measures of Web-Oriented Digital Literacy." *Social Science Computer Review 27(1).*
- Kulyk, O., et al. (2017). "Coercion-Resistant and Receipt-Free Voting." *USENIX Security.*
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." *SPSS* 8(4).
- Norman, D.A. (1988). *The Design of Everyday Things.* Basic Books.

---

*Author: Jony Bursztyn · 2026-06-22*  
*This document was prepared before any participant data collection. It constitutes the binding pre-registration for PIUP Study 1. All analyses departing from this document are exploratory.*
