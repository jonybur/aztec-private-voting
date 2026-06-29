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

**Mechanism:** Familiarity with eCommerce "confirmation codes" produces high self-assessed competence (calibration failure) even when it produces the wrong representational schema for Q2/Q3. See ADR-037 §H4; Das et al. (2014) on security confidence vs. behaviour.

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
- Completed at least one online vote, poll, or election in the past 12 months [Amendment 17 (pre-data): instrument §SC1 question text says 'Have you voted in an online election, poll, or survey in the past 12 months?' — 'survey' added as an eligible activity type not in this pre-reg line. The instrument is the deployed master source. This pre-reg line should be corrected to 'Completed at least one online election, poll, or survey in the past 12 months.' No protocol or analysis impact; correction to pre-reg text only. See osf-amendment-filing-2026-06-24.md Amendment 17.]
- No prior participation in this study (Prolific deduplication)

**Exclusion criteria (pre-specified):**
- Self-reported software engineering professionals (computer science / software dev / cryptography as primary occupation) — to prevent domain-expert contamination of mental model measures [Amendment 5 (pre-data): SC2 screener extended to also exclude CS/SE students: 'Student in computer science or software engineering' added to this criterion. Rationale: same domain-expert contamination concern as professional exclusion. Paper §4.2 correctly describes the deployed screener (both professionals and students excluded). See §14 Amendment 5 and osf-amendment-filing-2026-06-24.md.] [Amendment 17 (pre-data): 'cryptography as primary occupation' is NOT a distinct SC2 screen-out option — the SC2 instrument question screens 'Software engineer, developer, or programmer' (and CS/SE students); cryptography is not listed separately. Cryptography professionals selecting 'Other technology professional' would not be screened. The analysis script uses COL_OCCUPATION = 'occupation_sw_eng' confirming this. This pre-reg line should be corrected to 'Self-reported software engineering professionals (software developer, engineer, or programmer as primary occupation).' No protocol or analysis impact (instrument SC2 is the deployed master). See osf-amendment-filing-2026-06-24.md Amendment 17.]
- Failing both attention checks (not just one)
- Response time < 90 seconds (indicates non-serious completion; too fast to have read the mockup and answered questions)

### 4.2 Power analysis

**H2 primary endpoint (Q2 accuracy, A vs. B, one-tailed):** For a 15 pp difference (A: 65%, B: 50%) on Q2 specifically, G\*Power 3.1.9.7 (Faul et al., 2009), test: "Proportion: Inequality of two independent proportions", Cohen's h = 0.30, one-tailed, α = 0.05, power = 0.80: required n = 67 per cell. Target n = 70 per cell (N = 280) provides approximately 82% power. [Fixed tick-4045: added '(Faul et al., 2009)' inline — pre-reg named the G*Power software version but omitted the paper citation. CHI paper §4.2 consistently writes 'G*Power 3.1.9.7, Faul et al., 2009'; the pre-reg had only the version number. Faul et al. (2009) reference entry added to References section.]

*Correction note (pre-OSF):* The original power calculation used "Proportion: Inequality of two dependent proportions" (McNemar test, a within-subjects test), which does not apply to this between-subjects design. The original figure of n = 49 per cell was therefore incorrect. This is corrected to n = 67 (target n = 70) before OSF upload. No data have been collected under the original n = 50 target. [Amendment 1 (pre-OSF): G\*Power test type corrected from McNemar ('dependent proportions') to independent proportions; n = 49/cell (original) → n = 67/cell (corrected), rounded to n = 70/cell (N = 280); ~69% → ~82% power for H2 primary endpoint. All 14 confirmatory hypotheses and analysis procedures unchanged. See §14 Amendment 1 and osf-amendment-filing-2026-06-24.md.]

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
  *(Tests: was the ballot inclusion event correctly understood?)* [Amendment 6 (pre-data): wording updated to 'After voting, the system showed you your [LABEL]. Does having this [LABEL] prove that your vote was counted?' — condition-specific label substituted for 'this value'; preamble added. Correct answer, foils, and binary scoring unchanged. Construct-validity note: in Condition C, 'nullifier' appearing in the stem may prime the incorrect cancelled/void schema independently; disclosed as demand characteristic in §6.5 and in Amendment 6 deviation log. See §14 and osf-amendment-filing-2026-06-24.md.]

- **Q2:** "Does this value prove which option you chose?" Correct answer: **No**. Foil: Yes / Unsure.  
  *(Tests: representational schema — does the user understand the identifier is choice-blind?)* [Amendment 7 (pre-data): wording updated to 'The [LABEL] is a string of numbers and letters that is unique to your vote. Does having this [LABEL] prove which voting option you chose?' — condition-specific label substituted; preamble describing the token's structural properties added; 'which option you chose' → 'which voting option you chose'. Correct answer, foils, and binary scoring unchanged. No analogous demand-characteristic concern for Q2. See §14 and osf-amendment-filing-2026-06-24.md.]

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

**Mental model quality (RQ3, open text):** After Q1–Q4, participants answer: "In your own words, what does this value prove about your vote?" Free text, scored 0–2 (0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states choice is hidden from system). Two raters; κ ≥ 0.70 required. [Amendment 8 (pre-data): wording updated to 'In your own words: what does your [LABEL] prove about your vote?' — 'this value' replaced with 'your [LABEL]'; colon added. Two-rater scoring construct (0–2; κ ≥ 0.70) unchanged. Parallel to Amendments 6 (Q1) and 7 (Q2). Note: Amendment 2 (VOID) addressed a separate two-part form reversion; this amendment documents the independent '[LABEL]' substitution deviation. See §14 and osf-amendment-filing-2026-06-24.md.]

**Behavioral intent (RQ2 proxy):** "If this screen appeared after a real vote, would you download this file?" (5-point: Definitely yes → Definitely no.) [Amendment 3 (pre-data): wording updated to 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save this code for future reference?' (5-point: Definitely would save it → Definitely would not save it.) Rationale: (a) 'save for future reference' makes the verification purpose explicit, better operationalising behavioral intent to preserve the receipt; (b) 'this code' replaces '[LABEL]' to remove label-name demand from the behavioral intent measure — BI1 should measure save intention, not label-schema association; (c) response scale direction preserved. See §14 and osf-amendment-filing-2026-06-24.md §Item E.]

**Label affect:** "What is your first reaction to the label [LABEL]?" (Valence slider: −3 to +3.) Asked after all comprehension questions.

### 5.4 Covariates (collected but not pre-specified as primary analyses)

- Age (categorical: 18–24, 25–34, 35–44, 45–54, 55+)
- Prior voting experience (online poll only vs. official election)
- Technology background (DM2: single binary item — "Have you ever written code professionally or as part of a degree?"; used as a sensitivity analysis flag, not a validated scale; does not trigger exclusion — SC2 screener handles professional/student exclusion before survey entry) [Fixed tick-4044: pre-reg had incorrectly described DM2 as a '3-item scale, Hargittai 2009' — the actual survey instrument (piup-study1-survey-instrument-2026-06-22.md §DM2) uses a single binary yes/no coding-background question, not a validated Hargittai internet-skills scale. CHI paper §6 note explicitly documents this: 'the survey instrument §9 does not include a multi-item technology self-efficacy scale (e.g., Hargittai); DM2 is a screener-adjacent binary check.' The Hargittai reference has been removed from pre-reg References as it is now orphaned.]
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
| H3 (nullifier underperforms) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<A), composite(C<B), composite(C<D) [composite pairings conditional on omnibus significance; §6.6] | 6 | [Fixed tick-4047: expanded 'composite(C<each)' abbreviation to list all 3 composite pairwise tests explicitly; the previous entry looked like 4 items but m=6 requires 6 — the abbreviation obscured that composite(C<each) represents 3 separate tests (C<A, C<B, C<D on composite accuracy). No change to analysis; count remains 3 Q1 pairwise + 3 composite pairwise = 6.]
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
Equivalence is established if both one-sided p-values are < 0.05. If equivalence cannot be established, report the composite effect size (Cohen's h) and its CI. [Amendment 9 (pre-data): tost_prop() lower.tail flags corrected in the analysis script before OSF upload. Original implementation had p_lo = pnorm(z_lo, lower.tail=TRUE), p_hi = pnorm(z_hi, lower.tail=FALSE) — flags were inverted, making p_tost > 0.50 whenever the observed difference fell within the equivalence bounds and making the equivalence criterion (p_tost < 0.05) impossible to satisfy. Corrected: p_lo = pnorm(z_lo, lower.tail=FALSE) [reject H0a: diff ≤ −δ when z_lo large]; p_hi = pnorm(z_hi, lower.tail=TRUE) [reject H0b: diff ≥ +δ when z_hi small]. Equivalence bounds (±0.10), α (0.05), and the equivalence_established criterion are unchanged; 90% CI and Cohen's h are unaffected. See §14 Amendment 9 and osf-amendment-filing-2026-06-24.md.]

**H2 outcome classification (reported in discussion):**
- **Supported:** H2-primary significant (A > B on Q2) AND H2-tertiary establishes equivalence.
- **Null:** H2-primary non-significant AND H2-tertiary establishes equivalence.
- **Reversed:** H2-primary non-significant; post-hoc test Q2(B > A) significant at α = 0.05 (two-tailed). AND H2-tertiary establishes equivalence or B > A on composite.
- **Inconclusive:** Does not fall into any of the above categories. Report effect sizes; expand n or revise design.

Note: The Q1 analysis (B ≥ A on vote-counted inference) is **not** pre-specified as a confirmatory test for H2 because the prediction is non-directional ("B may equal or edge A"). It will be reported descriptively as a check on the proposed mechanism (H2 predicts a crossover, with B edging A on Q1 and A edging B on Q2/Q3).

### 6.6 H3 tests

**H3-Q1 (per pair):** Three one-tailed chi-squared tests: Q1 accuracy, C vs. A (C < A); C vs. B (C < B); C vs. D (C < D). Holm correction within H3 family (m = 6).  
**H3-composite:** One-way ANOVA-equivalent for proportions; if omnibus significant, Holm-corrected pairwise extractions for C vs. each other condition — that is, 3 pairwise tests: composite(C<A), composite(C<B), composite(C<D). These 3 composite pairings are the remaining 3 tests in the H3 Holm family (m = 6 = 3 Q1 pairwise + 3 composite pairwise); they proceed only when the omnibus is significant. If the omnibus is non-significant, composite pairwise extractions are not performed, a null result for the composite is reported without further decomposition, and only the 3 Q1 pairwise tests are conducted (still corrected at m = 6 for conservatism). [Fixed tick-4047: added explicit enumeration of the 3 composite pairings and the omnibus-conditional non-performance clause; clarifies the m=6 decomposition for the pre-reg table.]  
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

R (v ≥ 4.3). Planned packages: `stats`, `PropCIs` (Wilson CIs), `irr` (Cohen's κ), `dunn.test` (Kruskal-Wallis post-hoc, H3 secondary). [Amendment 4: DescTools removed — CramerV/OddsRatio replaced with base-R.] [Amendment 10: TOSTER removed — TOSTER::tsum\_TOST is for means (t-distribution), not proportions; H2-tertiary TOST implemented as custom z-test (tost\_prop()) per Lakens (2017); TOSTER was never called in the script.] [Amendment 11 (pre-data): multcomp removed — Holm corrections implemented via base-R `p.adjust()`; multcomp appeared in the original install.packages() comment but was never loaded (no `library(multcomp)`) or called anywhere in the script. `dunn.test` added — loaded and called for H3 secondary Q5 Kruskal-Wallis post-hoc analysis (`dunn.test::dunn.test()`); present in the script from tick-3636 but absent from this §6.10 entry. No statistical result affected.] Analysis script uploaded to OSF alongside this pre-registration.

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

_All entries below are pre-data amendments (no participant data had been collected at the time of each change). Full ready-to-file text for each amendment is in `docs/osf-amendment-filing-2026-06-24.md`. Amendment 2 (VOID) is omitted — the two-part MQ1 form change was reverted before data collection; no deviation from the pre-registration occurred._

| Date | Amendment # | Type | Description | Authorized by |
|------|-------------|------|-------------|---------------|
| 2026-06-22 | 1 | Power analysis / sample size | G\*Power test type corrected: McNemar ('dependent proportions') → independent proportions (between-subjects design). Corrected power target: Cohen's h = 0.30, one-tailed, α = 0.05 → n = 67/cell, rounded to n = 70/cell (N = 280). Original n = 50/cell provided ~69% power; corrected target provides ~82%. All 14 confirmatory hypotheses and analysis procedures unchanged. Paper §4.2 and §6.5 updated. (Pre-OSF deviation, pre-data.) | Jony Bursztyn |
| 2026-06-22 | 5 | Exclusion criteria | SC2 screener extended to CS/SE students: 'Student in computer science or software engineering' added to the professional exclusion criterion (§3). Rationale: same domain-expert contamination concern as professional exclusion. Paper §4.2 correctly describes deployed screener. (Pre-data, pre-pilot.) | Jony Bursztyn |
| 2026-06-22 | 6 | Instrument wording — Q1 | Q1 wording updated from 'Does this value prove that your vote was counted?' to 'After voting, the system showed you your [LABEL]. Does having this [LABEL] prove that your vote was counted?' Changes: preamble added; 'this value' → 'your [LABEL]'. Correct answer (Yes) and binary scoring unchanged. Construct-validity note: Condition C stem includes the word 'nullifier', which may prime an 'invalidated' schema; disclosed in paper §6.5. (Pre-data.) | Jony Bursztyn |
| 2026-06-22 | 7 | Instrument wording — Q2 | Q2 wording updated from 'Does this value prove which option you chose?' to 'The [LABEL] is a string of numbers and letters that is unique to your vote. Does having this [LABEL] prove which voting option you chose?' Changes: preamble added; 'this value' → 'this [LABEL]'; 'option' → 'voting option'. Correct answer (No), foils, and binary scoring unchanged. No demand-characteristic concern (no condition label hints at choice-revealing/hiding). (Pre-data.) | Jony Bursztyn |
| 2026-06-24 | 4 | Analysis script — software dependency | DescTools::CramerV and DescTools::OddsRatio replaced with base-R equivalents (cramer_v_base() and odds_ratio_base()). Statistical results identical. DescTools removed from required packages list. Rationale: DescTools requires 'fs' C++ dependency unavailable in sandboxed environments. No confirmatory hypothesis test affected. (Pre-data.) | Jony Bursztyn |
| 2026-06-25 | 3 | Instrument wording — BI1 | BI1 wording updated from 'If this screen appeared after a real vote, would you download this file?' to 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save this code for future reference?' 'This code' used (not '[LABEL]') to remove label-name demand from the behavioral intent measure. Response scale direction preserved. (Pre-data.) | Jony Bursztyn |
| 2026-06-27 | 8 | Instrument wording — MQ1 | MQ1 wording updated from 'In your own words, what does this value prove about your vote?' to 'In your own words: what does your [LABEL] prove about your vote?' Changes: 'this value' → 'your [LABEL]'; colon added. Two-rater scoring construct unchanged. Parallel to Amendments 6 (Q1) and 7 (Q2). (Pre-data. Note: Amendment 2 VOID — separate two-part form reversion required no deviation filing.) | Jony Bursztyn |
| 2026-06-27 | 10 | Analysis script — software dependency | TOSTER removed from required packages. TOSTER::tsum\_TOST operates on means (t-distribution); H2-tertiary requires a proportion z-test (Lakens 2017 TOST framework). The custom tost\_prop() function already implements the correct two-sided z-test on the raw probability scale. TOSTER was loaded (library(TOSTER)) but never called anywhere in the script; removing it eliminates a spurious dependency parallel to the DescTools removal (Amendment 4). Statistical results unchanged. (Pre-data.) | Jony Bursztyn |
| 2026-06-27 | 9 | Analysis script — bug fix | tost_prop() lower.tail flags corrected. Original script: p\_lo = pnorm(z\_lo, lower.tail=TRUE), p\_hi = pnorm(z\_hi, lower.tail=FALSE) — inverted, making p\_tost > 0.50 whenever the observed difference was within the equivalence bounds and making the equivalence criterion (p\_tost < 0.05) impossible to satisfy. Corrected: p\_lo = pnorm(z\_lo, lower.tail=FALSE) [reject H0a: diff ≤ −δ when z\_lo large]; p\_hi = pnorm(z\_hi, lower.tail=TRUE) [reject H0b: diff ≥ +δ when z\_hi small]. Equivalence bounds (±0.10), α (0.05), and equivalence\_established criterion unchanged. 90% CI and Cohen's h unaffected. (Pre-data.) | Jony Bursztyn |
| 2026-06-27 | 11 | Analysis script — software dependency | multcomp removed from planned packages list: Holm multiple-comparison corrections implemented via base-R `p.adjust()`; multcomp appeared in the original install.packages() comment (tick-3636) but was never loaded (no `library(multcomp)`) or called anywhere in the script. `dunn.test` added to planned packages list: loaded and called for H3 secondary Q5 Kruskal-Wallis post-hoc analysis (`dunn.test::dunn.test()`); in script from tick-3636 but absent from §6.10. No statistical result affected. Parallel to Amendments 4 and 10. (Pre-data.) | Jony Bursztyn |

---

## References

- Whitten, A. and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." *USENIX Security 1999.* [Fixed tick-4041: title was truncated — missing subtitle 'A Usability Evaluation of PGP 5.0'; venue was 'USENIX Security' without year. CHI paper bibliography (line 490) has 'Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0. USENIX Security 1999.' — both errors corrected to match.]
- Adida, B., et al. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." *EVT/WOTE 2009.* [Fixed tick-4040: three errors corrected: (1) year 2008→2009; (2) title 'Using Open-Source Software: The Helios Voting System' → 'Using Open-Audit Voting: Analysis of Real-World Use of Helios'; (3) venue 'USENIX EVT' → 'EVT/WOTE 2009'. CHI paper references (line 475) have the correct citation; pre-reg had a corrupted version — 'Open-Source Software' is not in the actual title and 'Open-Audit Voting' is the correct Helios mechanism descriptor. Full authors: Adida, de Marneffe, Pereira, Quisquater. Year and venue confirmed against CHI paper (which was verified when added tick-3876 per JONY-K resolution).]
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., Fisher, G., Kortum, P., McBurnett, N., Montoya, J., Parker, M., Perez, O., Stark, P., Wallach, D., and Winn, M. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." *EVT/WOTE 2013.* [Fixed tick-4041: (1) title was truncated — missing subtitle 'A Secure, Transparent, Auditable, and Reliable Voting System'; (2) venue was 'USENIX EVT/WOTE' without year and with incorrect 'USENIX' prefix — CHI paper (line 476) uses 'EVT/WOTE 2013'; (3) expanded 'Bell, S., et al.' to full 14-author list matching CHI paper line 476.]
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." *SOUPS 2012.* [Fixed tick-4041: citation mismatch — pre-reg body (line 49) cites 'Felt et al.'s work on Android permissions (2012)', which corresponds to the SOUPS 2012 Android Permissions study (user attention, comprehension, and behaviour of Android permission dialogs). The References section had 'How to Ask for Permission' (USENIX HotSec 2012), a different Felt et al. 2012 paper about a framework for designing permission requests. CHI paper bibliography (line 481) has the correct SOUPS 2012 Android Permissions paper with full author list; pre-reg reference updated to match body text and CHI paper entry. Note: 'Ha, E.' (Erika Ha) IS a correct author of this 2012 SOUPS paper (she is NOT an author of the 2016 Felt et al. HTTPS indicators paper — that error was fixed in the CHI paper tick-3861).]
- Das, S., Kim, T.H.-J., Dabbish, L.A., and Hong, J.I. (2014). "The Effect of Social Influence on Security Sensitivity." *SOUPS 2014*, pp. 143–157. USENIX. [Fixed tick-4042: two errors corrected. (1) Venue: 'ACM CCS 2014' → 'SOUPS 2014' — the paper appeared at the 10th Symposium on Usable Privacy and Security (SOUPS 2014), a USENIX-sponsored venue, not ACM CCS. CCS is a cryptography/systems security conference; SOUPS is the usable security/privacy venue this paper belongs to. Confirmed via USENIX proceedings (https://www.usenix.org/conference/soups2014/proceedings/presentation/das). (2) Author list: 'Das, S., Dabbish, L. and Hong, J.' → 'Das, S., Kim, T.H.-J., Dabbish, L.A., and Hong, J.I.' — Tiffany Hyun-Jin Kim is the second author and was omitted. Full 4-author list confirmed via USENIX BibTeX entry. In-text citation at line 99 also corrected from 'Das, Dabbish, and Hong (2014)' to 'Das et al. (2014)' — with 4 authors, et al. abbreviation is appropriate.]
- Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." *VoteID 2015*, LNCS vol. 9269, pp. 57–73. Springer. [Fixed tick-4038: year corrected 2017→2015; title corrected from 'Coercion-Resistant and Receipt-Free Voting'; venue corrected from 'USENIX Security' to VoteID 2015 LNCS Springer. Parallel to CHI paper correction tick-3765 (where [VERIFIED tick-3765] note was added). The paper is Kulyk, Teague, Volkamer 2015 — private eligibility verifiability by hiding voter participation via null votes from other eligible voters (crowd-anonymity mechanism cited in CHI paper §1.4).]
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." *Social Psychological and Personality Science* 8(4):355–362. [Fixed tick-4038: journal corrected from 'SPSS' (IBM statistics software acronym) to full journal name 'Social Psychological and Personality Science'. CHI paper bibliography entry uses the full journal name. Note: correct abbreviation is SPPS not SPSS; 'SPSS' here was almost certainly a typo for the journal's colloquial abbreviation.]
- Faul, F., Erdfelder, E., Buchner, A., and Lang, A.-G. (2009). "Statistical power analyses using G\*Power 3.1: Tests for correlation and regression analyses." *Behavior Research Methods*, 41(4), 1149–1160. [Added tick-4045: G\*Power 3.1 is cited at §4.2 power analysis; Faul et al. (2009) is the publication describing G\*Power 3.1 and its statistical tests. Pre-reg §4.2 named the software version but lacked the paper citation — this is the missing reference. Correct 4-author list (Faul, Erdfelder, Buchner, Lang) matches CHI paper entry (tick-4039 removed spurious 'Abt, A.-G.' author). Parallel to CHI paper citation at line 478.]
- Norman, D.A. (1988). *The Design of Everyday Things.* Basic Books.

---

*Author: Jony Bursztyn · 2026-06-22*  
*This document was prepared before any participant data collection. It constitutes the binding pre-registration for PIUP Study 1. All analyses departing from this document are exploratory.*
