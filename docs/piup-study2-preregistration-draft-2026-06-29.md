# Pre-Registration DRAFT: PIUP Study 2 — Absent-Choice Interpretation, Trust Calibration, and Save Behavior

**Status: DRAFT — DO NOT UPLOAD TO OSF YET**  
**Finalize after:** Study 1 pilot (N=40) complete + Study 1 H4 outcome confirmed  
**H2.3 contingency:** If Study 1 H4 is NOT supported, drop H2.3 from this pre-registration and reduce N from 240 to 160 (4 cells × 40/cell). Update §4, §9, and §10 before OSF upload.

**Draft date:** 2026-06-29  
**Author:** Jony Bursztyn  
**OSF template version:** AsPredicted v6 (adapted)  
**Companion documents:**
- [`docs/piup-study2-design-note-2026-06-22.md`](piup-study2-design-note-2026-06-22.md) — full working design note (master source for design rationale)
- [`docs/piup-study2-survey-instrument-2026-06-28.md`](piup-study2-survey-instrument-2026-06-28.md) — survey instrument (master source for question wording)
- [`docs/qualtrics-setup-guide-study2-2026-06-28.md`](qualtrics-setup-guide-study2-2026-06-28.md) — Qualtrics + prototype setup
- [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) — Study 1 pre-registration

---

## 1. Title

**"Does explaining absent vote choice improve trust and save behavior? A 2×2×2 experiment on ZK receipt UX."**

---

## 2. Study overview

### 2.1 Research questions

**RQ1 (Explanation effect).** Does explicit absent-choice explanation in a private voting receipt increase (a) correct absent-content interpretation, (b) trust in the receipt, and (c) self-reported save intention, compared to a receipt with no explanation?

**RQ2 (Label × Explanation interaction).** Is the explanation effect moderated by receipt identifier label? Specifically, does the "confirmation code" label produce lower absent-content accuracy in the no-explanation condition — because it activates the wrong eCommerce schema — while closing the gap to "vote fingerprint" when explanation is added?

**RQ3 (Calibration intervention).** Does an accuracy-feedback intervention — two comprehension questions with immediate correct-answer feedback displayed before the receipt — (a) increase correct absent-content interpretation, and (b) reduce confidence miscalibration without reducing save intention?

**RQ4 (Save behavior).** Does correct absent-content interpretation predict save intention? Is this relationship moderated by confidence calibration?

(RQ numbering follows the parent protocol. RQ1, RQ2, RQ4 are addressed in Study 1.)

### 2.2 Study design

2×2×2 between-subjects factorial experiment (L × E × I; 8 cells).

**Factor L (Label):** 2 levels
| Level | Label |
|-------|-------|
| L1 | "vote fingerprint" — metaphor-activating, current production default |
| L2 | "confirmation code" — eCommerce convention; activates wrong representational schema without explanation |

**Factor E (Explanation):** 2 levels
| Level | Explanation |
|-------|-------------|
| E1 | Present — "Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [vote fingerprint / confirmation code] is the only thing you need — matching it later proves your ballot was counted, nothing more." |
| E2 | Absent — receipt shows identifier, download prompt, and verification instructions only; privacy copy limited to "Your vote is private and verifiable." |

**Factor I (Calibration Intervention):** 2 levels
| Level | Intervention |
|-------|-------------|
| I1 | No intervention — participant sees the receipt directly |
| I2 | Calibration intervention — two comprehension questions (CAL1/CAL2) with immediate correct-answer feedback, displayed before the receipt |

With n = 30 per cell, total N = 240.

### 2.3 Platform

Interactive prototype: the `VoteReceipt.tsx` component from the Aztec Private Voting React package, hosted on Vercel in study mode (`studyMode=true`, `explanationVariant` prop set per condition). Study architecture: Prolific-embedded Qualtrics URL with condition randomization, prototype iframe embed, and postMessage event logging. See `docs/qualtrics-setup-guide-study2-2026-06-28.md` for full setup.

### 2.4 Position in the research arc

| Study | Central question | Status |
|-------|-----------------|--------|
| 1 | Does label choice affect privacy mental model? | Pre-registered; pending pilot launch |
| **2** | **Does absent-choice explanation affect trust and save behavior? Can calibration reduce over-confidence?** | **This document (DRAFT)** |
| 3 | Do users actually return to verify? What predicts verification behavior? | Deferred (see docs/piup-study3-social-verification-2026-06-29.md) |

---

## 3. Hypotheses

### H2.1 — Explanation increases absent-content accuracy (PRIMARY endpoint)

**Directional prediction:** E1 conditions will produce higher Q-AC accuracy than E2 conditions (main effect of E; E1 > E2).

**Mechanism:** Without explanation, absent vote choice is ambiguous — it could be a privacy feature or a display failure. The explanation copy eliminates this ambiguity by naming the design intent explicitly. The "confirmation code" label (L2) makes the ambiguity worse (eCommerce schema predicts confirmation content); the "vote fingerprint" label (L1) partly mitigates it.

**Predicted Q-AC accuracy rank:** L1E1 ≥ L2E1 > L1E2 ≥ L2E2.

**Pre-registered test:** Chi-squared (E1 pooled vs. E2 pooled × Q-AC correct/incorrect), one-tailed (E1 > E2), α = 0.05. Report OR + 95% CI (Wilson method).

This is the single pre-specified primary endpoint for Study 2. It runs regardless of Study 1 outcomes.

---

### H2.2 — Explanation × Label interaction on trust (SECONDARY)

**Directional prediction:** The increase in trust (M2 composite) produced by adding explanation (E1 vs. E2) will be larger for L2 ("confirmation code") than for L1 ("vote fingerprint").

**Mechanism:** "Vote fingerprint" is partly self-explanatory (a fingerprint is not expected to contain full transaction content). "Confirmation code" sets an eCommerce expectation (confirmation = content) that the explanation must actively correct. The explanation does more work in L2 than L1, producing a larger L2 × E effect on trust.

**Pre-registered test:** Two-way ANOVA (L × E, between-subjects) on M2 composite. If interaction F significant (α = 0.05): simple effects of E within L1 and L2 separately (Welch's t-test, `var.equal = FALSE`). If not significant: report null with 90% CI on interaction term.

---

### H2.3 — Calibration intervention reduces confidence miscalibration in L2 (CONDITIONAL SECONDARY)

**Condition for running this test:** H4 must be supported in Study 1 (i.e., "confirmation code" produced highest confidence rating while not ranking first on accuracy — confirming calibration failure in the familiar-label condition).

**If H4 NOT supported in Study 1:** H2.3 is dropped from this pre-registration. N is reduced from 240 to 160 (4 cells × 40/cell; I factor dropped). Update §4, §9, and §10 accordingly before OSF upload.

**Directional prediction (if run):** In L2 conditions, I2 will reduce the M4 confidence miscalibration residual compared to I1, without reducing save intention (M3).

**Mechanism:** Showing users that their initial mental model was incorrect — before the receipt is shown — aligns schema and expectation before the receipt is encountered. Users who receive correct feedback are less likely to hold falsely high confidence in their understanding of the receipt.

**Pre-registered tests:**
- M4 residual: two-sample t-test (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05.
- M3 save intention: TOST equivalence test (I1-L2 vs. I2-L2), bounds ±0.5 SD, α = 0.05 per one-sided test.

**Note on M4 scope:** M4 (confidence rating for Q-AC) is collected from ALL conditions (N=240), placed immediately after Q-AC and before the trust scale. This ensures M4 exists for both I1 and I2 cells, making the I1-L2 vs. I2-L2 t-test (above) feasible. Without all-conditions M4, the H2.3 t-test would have df_L2_I1 = 0 rows and be silently untestable. See design note §7.2 M4 (tick-4246 fix) and instrument §11.

---

### H2.4 — Correct absent-content interpretation predicts save intention (SECONDARY)

**Directional prediction:** Q-AC accuracy (M1 = 1) will predict higher download-click rate (M3 behavioral proxy) within participants, controlling for condition.

**Mechanism:** A user who understands that the receipt does not contain their vote choice is more likely to recognize it as auditable evidence (rather than a meaningless opaque string), which motivates saving it.

**Pre-registered test:** Logistic regression: download_clicked ~ M1 + L + E + I (main effects). Report OR for M1 + 95% CI.

**Secondary:** M1 × L interaction (exploratory; does the effect depend on label?). Reported as exploratory if added post-OSF.

---

## 4. Sampling plan

### 4.1 Target sample

**Full study:** n = 30 per cell (N = 240 total; 8 cells: L × E × I).  
**Pilot:** n = 10 per cell (N = 80 total; same 8 conditions). Pilot data not combined with full-study data.

**Reduction if H2.3 dropped:** n = 40 per cell (N = 160; 4 cells: L × E, I dropped).

**Inclusion criteria:**
- US-resident adults, age 18+
- English-speaking (Prolific: English as first language or fluent)
- Completed at least one online election, poll, or survey in the past 12 months (SC1)
- No prior participation in this study (Prolific deduplication)
- No prior participation in Study 1 of this series (Prolific "previous studies" filter on Study 1 Prolific ID; see also DM4)

**Exclusion criteria (pre-specified):**
- Self-reported software engineers or CS/SE students (SC2: "Software engineer, developer, or programmer as primary occupation" OR "Student in computer science or software engineering") — domain-expert contamination concern; parallel to Study 1 Amendment 5
- Failing both attention checks (AC1 and AC2; failing one alone is not an exclusion criterion)
- Response time < 90 seconds total study time (indicates non-serious completion; prototype auto-timestamps)
- Browser-fallback participants are **NOT excluded** (see §9.3): they are retained in the primary analytic sample and flagged (`browser_fallback = 1`); pre-specified sensitivity checks exclude them from H2.1 and H2.4

**Prior-study sensitivity flag (not an exclusion):** DM4 = "Yes" (self-reported prior voting receipt study participation) → flagged as `prior_receipt_study = 1`; retained in primary analysis, excluded from pre-specified sensitivity check.

### 4.2 Power analysis

**H2.1 (E main effect, Q-AC, chi-squared):**

Using conservative baseline estimates in absence of Study 1 pilot data (to be updated from pilot):
- Q-AC accuracy in E2 conditions: 50% (comparable to Study 1 Q2 accuracy in worst-label condition)
- Q-AC accuracy in E1 conditions: 70% (OR ≈ 2.3)
- α = 0.05, one-tailed, power = 0.80

Required n per E level: ~52 → ~26 per L × E cell. Target n = 30/cell provides ≈ 0.84 power on H2.1 with headroom for 20–25% exclusion rate.

_This estimate will be revised from Study 1 pilot data before OSF upload. If pilot E2 baseline diverges substantially from 50%, recalculate n and update this section as an amendment._

**H2.2 (L × E interaction on M2, ANOVA):**

Estimated interaction effect size f ≈ 0.22 (medium-small; based on H2 dissociation mechanism — effect expected stronger for L2). For f = 0.22, α = 0.05, df_interaction = 1, N = 240: power ≈ 0.80.

**H2.3 (M4 calibration, conditional; t-test in L2 only):**

If run: L2 conditions only, n = 60 per I level (N_L2 = 120; each I level pools E1 + E2 within L2: L2E1I1 + L2E2I1 = 60 for I1, L2E1I2 + L2E2I2 = 60 for I2). For d = 0.50 (medium), α = 0.05, one-tailed: power ≈ 0.86. Adequately powered (≥ 0.80). [Fixed Amendment 11 (tick-4261): prior wording stated n = 30 per I level (N = 60) and power ≈ 0.72, which conflated per-cell n with per-I-level n. Each I level pools across the two E conditions within L2 (E1 + E2), giving n = 60 per group, not 30. Power is ≈ 0.86, not 0.72. No design or analysis logic changed; only the documentation of sample size and power for H2.3 was wrong.]

**H2.4 (logistic regression):**

Full N = 240 provides adequate power for OR detection at logistic regression (OR ≥ 1.5, binary predictor, α = 0.05: power > 0.80 at N = 200+).

### 4.3 Stopping rule

No interim stopping for efficacy or futility. The pilot (N = 80) is for instrument validation only. Pilot data will not be used to adjust alpha levels, power, or primary endpoint.

---

## 5. Measured variables

### 5.1 Stimuli

Interactive prototype: `VoteReceipt.tsx` component with `studyMode=true` and condition-specific props:

| Condition | `labelVariant` | `explanationVariant` | Pre-receipt calibration (I2 only) |
|-----------|---------------|---------------------|---------------------------------|
| L1E1I1 | `"fingerprint"` | `"explained"` | None |
| L1E1I2 | `"fingerprint"` | `"explained"` | CAL1 + CAL2 + CAL-FEEDBACK |
| L1E2I1 | `"fingerprint"` | `"unexplained"` | None |
| L1E2I2 | `"fingerprint"` | `"unexplained"` | CAL1 + CAL2 + CAL-FEEDBACK |
| L2E1I1 | `"confirmation-code"` | `"explained"` | None |
| L2E1I2 | `"confirmation-code"` | `"explained"` | CAL1 + CAL2 + CAL-FEEDBACK |
| L2E2I1 | `"confirmation-code"` | `"unexplained"` | None |
| L2E2I2 | `"confirmation-code"` | `"unexplained"` | CAL1 + CAL2 + CAL-FEEDBACK |

Commit `039633f` contains the exact `studyMode` / `explanationVariant` / `onDownloadClick` / `onVerifyExpanded` prototype implementation. Any change to the prototype after this pre-registration constitutes an amendment.

### 5.2 Primary measure (M1)

**M1 — Absent-content accuracy (Q-AC):** Binary (1 = correct, 0 = incorrect/unsure).

Q-AC wording (exact; from instrument §8):
> "Looking at that receipt: does it show which voting option you chose?"  
> ○ Yes, my vote choice is shown  
> ○ No, my vote choice is not shown ← correct  
> ○ It's not clear from what I see

The receipt is hidden via a transition screen before Q-AC is asked ("The receipt screen is now hidden. Please answer the following questions from memory."). "That receipt" signals retrospective reference. Scored binary; "No" = 1.

### 5.3 Secondary measures

**M2 — Trust-in-receipt composite (McKnight-adapted, 4-item, 7-point Likert):**

| Item | Text |
|------|------|
| TI1 | "I believe this receipt accurately reflects what happened with my vote." |
| TI2 | "I trust that the [vote fingerprint / confirmation code] is unique to my ballot." |
| TC1 | "I feel confident I could use this receipt to prove my ballot was counted." |
| TC2 | "I understand what this receipt is for." |

All items: 1 (Strongly Disagree) to 7 (Strongly Agree). M2 = mean(TI1, TI2, TC1, TC2). α ≥ 0.70 required; if not met, items reported individually.

**M3 — Save intention:**
- Self-report: "How likely are you to save or screenshot this receipt before closing this page?" (1 = Definitely not → 7 = Definitely will)
- Behavioral proxy: download button click (yes/no), logged via `piup-download-click` postMessage event from prototype → `download_clicked` Embedded Data field

**M4 — Confidence miscalibration residual (all conditions; instrument §11):**

Post-receipt Q-AC confidence: "How confident are you in your answer above?" (1 = Not at all confident → 7 = Completely confident), placed immediately after Q-AC (before trust scale).

Miscalibration residual = (confidence_rating − 1) / 6 − Q-AC_accuracy. Positive = over-confidence; negative = under-confidence.

M4 is collected from ALL N = 240 participants (not I2 only). This ensures the H2.3 conditional t-test (I1-L2 vs. I2-L2) is feasible. See §3 H2.3 note.

**M5 — Verification instruction engagement:**
Binary: did the participant expand the "how to verify" accordion? Logged via `piup-verify-expanded` postMessage event → `verify_expanded` Embedded Data field. Exploratory; no pre-specified test.

**M6 — Open-text absent-choice explanation (Q-OE):**

Q-OE wording (exact; from instrument §16):
> "In your own words, why doesn't this receipt show which voting option you chose?"

Scored 0–2 by two independent raters:

| Score | Criteria |
|-------|----------|
| 2 | Correctly identifies privacy or ballot secrecy as a **deliberate design feature**. Must include: (1) something equivalent to "to protect privacy / anonymity / secrecy" AND (2) either that it was intentional/designed, OR a concrete consequence (coercion risk, traceability). Example: "Because showing my vote would let others see how I voted and might pressure me to vote differently next time." |
| 1 | Mentions one correct element (privacy, secrecy, "so others can't see") without explicitly framing it as a design decision or naming a concrete consequence. "For privacy" alone = 1. Responses that recognise absence as a feature but cannot articulate why = 1. |
| 0 | No correct element: "I don't know," technical error attribution ("it didn't save," "it was encrypted"), confusion, or claims vote IS shown somewhere. |

**Tie-breaking:** Raters discuss until consensus; if no consensus, lower score used.  
**Analysis column:** `qoe_final = round((r1 + r2) / 2)`.  
κ ≥ 0.70 required before including Q-OE in any analysis.

### 5.4 Covariates

- Age (categorical: 18–24, 25–34, 35–44, 45–54, 55+)
- Voting experience (online poll only vs. official election vs. organizational/DAO)
- Coding background (DM2: single binary item — "Have you ever written code professionally or as part of a degree?"; sensitivity flag, not a validated scale)
- DM4: prior voting receipt study (self-report; `prior_receipt_study` flag)
- `browser_fallback`: 1 if prototype did not render within 8-second timeout (static screenshot shown as fallback); 0 otherwise

---

## 6. Analysis plan

### 6.1 Pre-processing

1. Exclude participants failing both attention checks (AC1 and AC2). Record n excluded.
2. Exclude participants with total response time < 90 seconds. Record n excluded.
3. Exclude self-reported software engineers / CS/SE students (SC2). Record n excluded.
4. Flag `browser_fallback = 1` participants (do NOT exclude from primary analysis). Record n flagged.
5. Flag `prior_receipt_study = 1` participants. Record n flagged.
6. Verify 8-condition assignment balance (Qualtrics randomizer quotas, n = 30/cell); report any imbalance.
7. Score Q-OE (M6) by 2 raters before merging with quantitative data; confirm κ ≥ 0.70.
8. Compute M2 composite; confirm α ≥ 0.70. If α < 0.70, report items individually.
9. Compute M4 residual: (confidence_rating − 1) / 6 − Q-AC_accuracy.
10. No imputation of missing responses; missing Q-AC treated as incorrect (= 0).

### 6.2 Primary analysis — H2.1

**Test:** Chi-squared, 2 × 2 table (E1 pooled vs. E2 pooled × Q-AC correct/incorrect), one-tailed (E1 > E2), α = 0.05.  
**Effect size:** OR + 95% CI (Wilson method on proportions).  
**Reporting:** Proportion correct per E level (pooled); proportion correct per L × E cell (descriptive).

**Ceiling check:** If Q-AC accuracy in I2E1 cells exceeds 90% in both L conditions, report ceiling effect and treat I1E1 vs. I1E2 as the primary E-effect estimate (I factor parcelled out).

### 6.3 Secondary analysis — H2.2

**Test:** Two-way ANOVA (L × E, between-subjects; I **pooled/collapsed** — I is not included in the H2.2 model; all 8 cells contribute to L and E estimates with I treated as a nuisance factor by pooling across I levels) on M2 composite. [Fixed tick-4249: prior wording "I collapsed or as covariate" was ambiguous. The analysis script uses `aov(m2_trust ~ L * E, ...)` with no I term, confirming I is pooled/collapsed, consistent with CHI paper §5.5 "pooling across I".]  
- If F_interaction significant (α = 0.05): simple effects of E within L1 and within L2 (Welch's t-test, `var.equal = FALSE`).  
- If F_interaction not significant: report null with 90% CI on interaction term; report E main effect and L main effect descriptively.

### 6.4 Conditional secondary analysis — H2.3

**Condition:** Run only if H4 was supported in Study 1.  
**Subset:** L2 conditions only (L2E1I1, L2E1I2, L2E2I1, L2E2I2 → I1 vs. I2 within L2; N_L2 = 120 if H4 supported and N = 240 design retained; n = 60 per I level, E pooled within each).

1. **M4 residual (miscalibration):** Two-sample t-test (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05. Report Cohen's d + 95% CI.
2. **M3 save intention (equivalence):** TOST on self-report M3 (I1-L2 vs. I2-L2), equivalence bounds ±0.5 SD in raw Likert units (bounds = 0.5 × observed M3 SD computed from pooled L2 data), α = 0.05 per one-sided test. **Method: Welch two one-sided t-tests (TOSTER::tsum_TOST, `var.equal = FALSE`; Lakens, 2017 TOST framework for means).** Equivalence established if max(p_lower, p_upper) < 0.05. If equivalence not established, report M3 Cohen's d and 90% CI. [Fixed tick-4249: prior wording "Lakens, 2017 z-test on proportions adapted for Likert" was methodologically incorrect. M3 is a 7-point Likert scale (continuous); the correct TOST uses the t-distribution based `tsum_TOST`, not a z-test for proportions. Contrast with Study 1 H2-tertiary which used a custom z-test for accuracy *proportions* — that is a different scale type requiring a different TOST implementation. Analysis script (piup-study2-analysis.R H2.3) confirmed: `TOSTER::tsum_TOST(..., var.equal = FALSE)`. No protocol impact — only the method description was wrong; bounds, alpha, and verdict logic are unchanged.]

### 6.5 Secondary analysis — H2.4

**Test:** Logistic regression: `download_clicked ~ M1 + L + E + I` (main effects, no interactions, between-subjects). Report OR for M1 + 95% CI (log-scale).  
**Exploratory extension:** Add M1 × L interaction term. Reported as exploratory.

**H2.4 browser-fallback sensitivity check (pre-specified):** Re-run H2.4 excluding `browser_fallback = 1` participants. Fallback participants cannot click the download button (artefact); their `download_clicked = 0` contaminates M3 behavioral proxy. Report both the primary and sensitivity-check ORs.

### 6.6 Multiple comparisons policy

H2.1, H2.2, H2.3, and H2.4 constitute four independent pre-specified hypothesis families. No cross-family correction applied. Within each family, only one confirmatory test is specified, so no within-family correction is needed either. Any additional comparisons (e.g., simple effects of L across all E × I combinations; M5 engagement exploratory analysis; Q-OE Kruskal-Wallis) are **exploratory** and reported as such.

### 6.7 Q-OE (M6) analysis

Not part of M1 primary analysis. Pre-specified supplementary:
- Kruskal-Wallis test across 8 conditions on `qoe_final`.
- If significant (α = 0.05): Dunn's pairwise post-hoc (Holm correction).
- 15 randomly sampled Q-OE responses per condition published as illustrative examples (random sample drawn before hypothesis testing).

### 6.8 Prior-study sensitivity check (pre-specified)

Re-run H2.1 and H2.4 excluding `prior_receipt_study = 1` participants. Report both primary and sensitivity-check results.

### 6.9 Confidence interval standard

All proportions: Wilson 95% CI. All means: 95% CI from t-distribution. All ORs: log-scale 95% CI.

### 6.10 Software

R (v ≥ 4.3). Planned packages: `stats`, `PropCIs` (Wilson CIs), `irr` (Cohen's κ), `dunn.test` (Kruskal-Wallis post-hoc), `TOSTER` (TOST equivalence tests for means), `emmeans` (simple-effects contrasts from ANOVA models), `broom` (tidy model output). **TOST for H2.3 M3 equivalence:** `TOSTER::tsum_TOST` (Welch-based two one-sided t-tests on group means and SDs; Lakens 2017). Note: Study 1 uses a custom `tost_prop()` z-test for Q-AC *proportion* equivalence — a different measure type requiring a different TOST implementation. [Fixed tick-4249: §6.10 previously said "custom z-test (tost_prop()) — not TOSTER"; that described the wrong test. H2.3 M3 is a 7-point Likert scale (continuous mean), correctly tested with `tsum_TOST`, not a z-test for proportions. Analysis script confirmed: `TOSTER::tsum_TOST(..., var.equal = FALSE)`. Prior wording resolved by §6.4 fix same tick; §6.10 now consistent.] Full analysis script: `analysis/piup-study2-analysis.R`. Dry-run with synthetic data: `analysis/piup-study2-drycheck.R`.

---

## 7. Pilot protocol

### 7.1 Purpose of the pilot

The pilot (n = 10/cell, N = 80 across 8 conditions) is for instrument validation only. It is NOT used for hypothesis testing. Pilot data will not be combined with full-study data.

**Pilot goals:**
1. Verify Q-AC has no floor (< 20% correct in E1 conditions) or ceiling (> 90% in any condition) effects.
2. Validate estimated task completion time (target 8–12 min).
3. Confirm Q2 attention check pass rate > 85%.
4. Check κ on Q-OE pilot responses (10/condition × 8 conditions = 80 responses); adjust rubric if κ < 0.70.
5. Verify prototype renders in ≥ 95% of participants (browser_fallback rate); flag if < 90%.
6. Confirm download click event and verify-expanded event reach Qualtrics Embedded Data in exports.
7. **Update power analysis:** Revise Q-AC E2 baseline estimate from pilot L×E cells. Recalculate N if pilot E2 accuracy diverges substantially from 50% (pre-specified: if pilot E2 < 35% or > 65%, recalculate and amend).

### 7.2 Amendments before full study

Permitted without new pre-registration (document in amendments log):
- Wording clarifications to Q-AC stem (if pilot shows systematic misreading)
- N adjustment (per §7.1 item 7 power revision)
- Q-OE rubric revision if κ < 0.70 on pilot data

Require a new pre-registration:
- Changing primary endpoint (H2.1)
- Adding or removing conditions
- Changing prototype props that alter the explanation copy or label in ways not covered by the L/E factor specification

---

## 8. Deviations policy

Any deviation from this pre-registration during data collection or analysis will be noted in the published paper/report under "Deviations from pre-registration."

- **Type I (minor):** Software version mismatch, minor n variation (within ±10% of target), post-hoc exploratory additions. Does not affect confirmatory claim status.
- **Type II (substantive):** Change to primary endpoint, condition, or prototype. All analyses after a Type II deviation are treated as exploratory.

---

## 9. Open science commitments

- Study materials (prototype code, survey instrument): published on OSF at registration.
- Analysis script (`piup-study2-analysis.R`) and dry-run script (`piup-study2-drycheck.R`): uploaded before pilot launch.
- Pre-processed data (no identifiers): published with final report.
- Raw Prolific completion data: not published (Prolific terms); aggregate demographics reported.
- Pre-registration DOI to be included in CHI paper submission.

---

## 10. Ethical considerations

**Risk level:** Minimal. Participants interact with a static/interactive mockup of a post-vote receipt. No real election, no personal voting data, no sensitive personal information collected.

**Deception:** None. Cover scenario: "You have just voted in a simulated election. Take a moment to review your receipt."

**Coercion scenario (calibration questions, I2 conditions):** CAL1 asks about an employer verification scenario (same as Study 1 Q3). Described as hypothetical. Handled identically to Study 1.

**IRB expectation:** Exempt under 45 CFR 46.104(d)(2) — survey/interaction research, no more than minimal risk.

---

## 11. Timeline

| Milestone | Target |
|-----------|--------|
| Study 1 pilot complete + H4 status known | Before finalizing this pre-registration |
| Study 2 pre-registration finalized (N and H2.3 resolved) | Within 2 weeks of Study 1 H4 outcome |
| OSF upload | Before Study 2 pilot launch |
| Study 2 pilot (N = 80) | Within 2 weeks of OSF upload |
| Instrument amendments from pilot (if needed) | Within 1 week of pilot completion |
| Full study launch | Within 4 weeks of OSF registration |
| Data collection complete | Within 6 weeks of full study launch |
| Analysis + report | Within 8 weeks of data collection |

---

## 12. Budget

| Item | Cost (USD) |
|------|------------|
| Pilot (N = 80, ~10 min, ~$2.50/participant Prolific) | ~$200 |
| Full study (N = 240, ~10 min, ~$2.50/participant) | ~$600 |
| Platform fee (33%) | ~$264 |
| **Total** | **~$1,064** |

Reduction if H2.3 dropped (N = 160): full study ~$400; total ~$730.

---

## 13. Decision framework: what Study 2 results imply for production

| Study 2 outcome | Production decision |
|----------------|---------------------|
| H2.1 supported (E1 > E2 on Q-AC, significant) | Explanation copy is load-bearing. Keep E1 as default in production receipt. |
| H2.1 null (E1 ≈ E2 on Q-AC) | Label is the active ingredient, not explanation. Revisit E1 copy design. |
| H2.2 supported (L × E interaction; explanation helps L2 more than L1) | "Confirmation code" is worse without explanation but recovers with it. Confirms fingerprint as more robust default. |
| H2.2 null (no interaction) | Explanation works equally for both labels — or neither label is a meaningful moderator. |
| H2.3 supported (I2 reduces M4 residual in L2, no M3 cost) | Pre-receipt calibration works. Consider adding two-question pre-prompt to production receipt for high-stakes elections. |
| H2.4 supported (M1 predicts download click) | Correct comprehension drives save behavior. Implies improving comprehension is sufficient to improve save rates — no separate engagement design needed. |
| H2.4 null (M1 does not predict download click) | Behavioral intention is driven by something other than comprehension (general engagement, trust, aesthetics). Study 3 ecological validity becomes more important. |

---

## 14. Amendments log

*This is a DRAFT pre-registration. Entries below record design decisions incorporated before OSF upload. All are pre-data; no participants have been recruited for Study 2 at draft date.*

| Date | Amendment # | Type | Description | Authorized by |
|------|-------------|------|-------------|---------------|
| 2026-06-22 | 1 | Initial design note | `docs/piup-study2-design-note-2026-06-22.md` established as master design document. Not a pre-registration. | Jony Bursztyn |
| 2026-06-27 | 2 | Prototype implementation complete | `studyMode`, `explanationVariant`, `onDownloadClick`, `onVerifyExpanded` props implemented in `VoteReceipt.tsx` (commit 039633f). 70 VoteReceipt tests pass. No further engineering needed for prototype before Study 2. | OpenClaw Agent |
| 2026-06-28 | 3 | Browser-fallback sensitivity pre-specified | §9.3 and §9.3.2 of design note: `browser_fallback` detection mechanism specified; fallback participants retained in primary analysis, excluded from pre-specified H2.1 + H2.4 sensitivity checks. H2.4 download_clicked contamination for fallback participants identified and documented. | OpenClaw Agent |
| 2026-06-28 | 4 | Qualtrics setup guide created | `docs/qualtrics-setup-guide-study2-2026-06-28.md` created. `labelVariant` prop error (`label` → `labelVariant`) corrected before any participant data collected. | OpenClaw Agent |
| 2026-06-28 | 5 | Survey instrument finalized | `docs/piup-study2-survey-instrument-2026-06-28.md` created. 25-field variable codebook; all COL_* constants confirmed against analysis script. | OpenClaw Agent |
| 2026-06-28 | 6 | M6/Q-OE rubric expanded | §7.2 M6 rubric expanded to full two-part score-2 criterion, score-1 feature-recognition clause, score-0 examples, tie-breaking rule, and `qoe_final` formula. Matches instrument §16 exactly. | OpenClaw Agent |
| 2026-06-29 | 7 | M4 scope: I2-only → all-conditions (JONY-ACTION FF resolved) | M4 confidence rating changed from I2-only retrospective CAL-probe to all-conditions post-receipt Q-AC confidence (placed immediately after Q-AC, before trust scale). Rationale: H2.3 t-test (I1-L2 vs. I2-L2 on M4 residual) requires M4 for both I1 and I2 cells; I2-only M4 made H2.3 silently untestable. Analysis script updated: synthetic data covers all N=240; H2.3 df_L2 filter fixed. Commit 5304b3f. | OpenClaw Agent |
| 2026-06-29 | 8 | Pre-registration DRAFT written | `docs/piup-study2-preregistration-draft-2026-06-29.md` created (this document). DRAFT status; not for OSF upload until Study 1 H4 resolved. | OpenClaw Agent |
| 2026-06-29 | 9 | §6.10 Software — TOST method corrected, packages list updated | §6.10 previously said "custom z-test (tost_prop()) — not TOSTER"; now correctly states `TOSTER::tsum_TOST` for H2.3 M3 equivalence (Likert scale = continuous means test, not proportion z-test). Packages list expanded: added `TOSTER`, `emmeans`, `broom` (all used in analysis script). Consistent with §6.4 fix from tick-4249 and analysis script `TOSTER::tsum_TOST(..., var.equal = FALSE)`. No hypothesis, bound, alpha, or verdict changes. Commit tick-4250. | OpenClaw Agent |
| 2026-06-30 | 10 | Dry-check script: M4 I2-only → all-conditions (bug fix, not design change) | `analysis/piup-study2-drycheck.R` was never updated when Amendment 7 changed M4 from I2-only to all-conditions. Three bugs: (1) synthetic data generated `NA` for I1 M4 rows, (2) validation check asserted `all(is.na(I1 M4))` — the old wrong design, (3) label said "I2 conditions only". The dry-check was passing silently (synthetic I1 data was NA, matching the stale expectation), but real all-conditions pilot data would have triggered a false warning. Fixed: synthetic generator now produces `sample(3:7,1)` for all conditions; validation now asserts `m4_missing==0`; label updated to "all conditions — Amendment 7". Dry-check: Non-NA rows 37/37 ✓. No analysis logic, hypothesis, bound, or verdict change. Commit a995927 (tick-4259). | OpenClaw Agent |
| 2026-06-30 | 11 | H2.3 power documentation: n=30→60 per I level, power 0.72→0.86 | §4.2 stated "n = 30 per I level (N = 60), power ≈ 0.72" for the H2.3 t-test, and §6.4 stated "N_L2 = 60". Both are wrong. The H2.3 t-test compares I1 vs. I2 within L2, pooling across E. Each I level contains all L2 rows with that I flag: n = L2E1I1 + L2E2I1 = 30 + 30 = 60 (I1), and n = L2E1I2 + L2E2I2 = 30 + 30 = 60 (I2). N_L2 = 120, not 60. Correct power for d = 0.50, n = 60/group, α = 0.05, one-tailed: power ≈ 0.86 (adequately powered). Analysis script comment at line 698–699 also corrected ("n=30 target" → "n=60 target"). No design, hypothesis, bound, alpha, or verdict change — only documentation of sample size and power was wrong. Commit tick-4261. | OpenClaw Agent |
| 2026-06-30 | 12 | Power simulation script + CSV: H2.3 n=30→60 per group (Amendment 11 propagation) | `analysis/piup-study2-power-simulation.R` SECTION 4 used `n_h23 <- n_per_cell` (= 30) for H2.3, which contradicts the corrected design (Amendment 11) where each I level pools E1+E2 giving n = 60. Amendment 11 fixed the pre-reg documentation and analysis-script comment but NOT the simulation. Fixed: `n_h23 <- n_per_cell * 2L` (= 60); comment updated to "60 per I level (pools E1+E2 within L2: 30+30=60)"; `N = n_per_cell * 4` in CSV summary (N_L2 = 120); design-note analytic estimate updated ~0.72→~0.86; printf n_per_cell→n_per_cell*2L. Regenerated: `results-study2/power-sim/h23_power_curve.csv` (n_per_group: 30→60; d=0.50 power: 0.615→0.867 [sim], 0.72→0.86 [analytical]); `results-study2/power-sim/power_summary.csv` (H2.3 N: 60→120, power_sim: 0.615→0.867, gpower_analytical: 0.72→0.86). Also: §14 amendment table rows 10+11 re-ordered chronologically (11 was listed before 10 — cosmetic error from insertion order). No hypothesis, endpoint, alpha, bound, or verdict change. Commit tick-4262. | OpenClaw Agent |

---

## References

- Whitten, A., and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." *USENIX Security 1999.*
- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." *EVT/WOTE 2009.*
- Bell, S., et al. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." *EVT/WOTE 2013.*
- Das, S., Kim, T.H.-J., Dabbish, L.A., and Hong, J.I. (2014). "The Effect of Social Influence on Security Sensitivity." *SOUPS 2014*, pp. 143–157. USENIX.
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." *SOUPS 2012.*
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." *Social Psychological and Personality Science* 8(4):355–362.
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." *Information Systems Research 13(3).*
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." *Human Factors 46(1).*
- Norman, D.A. (1988). *The Design of Everyday Things.* Basic Books.

---

*Author: Jony Bursztyn · Draft prepared 2026-06-29*  
*DRAFT — not yet submitted to OSF. Finalize after Study 1 pilot + H4 outcome. See §3 H2.3 contingency and §4.1 N contingency before upload.*
