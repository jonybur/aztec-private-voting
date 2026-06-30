# §4.6 Results Fill-In Template — PIUP Study 1

**Created:** 2026-06-30 (tick-4285)  
**Purpose:** Slot-based template for writing §4.6 once Study 1 data is collected.
Each `[SLOT]` maps to a specific analysis output from `analysis/piup-study1-analysis.R`.
Analysis column/variable names in `monospace` match the script's output object names.
Follow this template in order; do not reorder hypothesis families.

---

## HOW TO USE

1. Run `piup-study1-analysis.R` on the cleaned Qualtrics export.
2. Run `piup-study1-drycheck.R` first to confirm the script parses correctly.
3. Copy the template below into the CHI paper §4.6.
4. Replace each `[SLOT: ...]` with the value from the script output.
5. Delete all `[SLOT]` markers and this header before CHI submission.
6. Add `[Compressed tick-NNNN]` markers if you trim the results section later.

---

## §4.6 Results

**Participants.** We recruited [SLOT: n_recruited] participants via Prolific. After applying pre-registered exclusions — [SLOT: n_excluded_sc2] excluded for CS/SE background (SC2), [SLOT: n_excluded_attn] excluded for failing both attention checks, [SLOT: n_excluded_rt] excluded for response time < 90 s — the analytic sample comprised [SLOT: n_final] participants ([SLOT: n_A]/[SLOT: n_B]/[SLOT: n_C]/[SLOT: n_D] per condition; target n = 70/cell). [SLOT: n_browser_fallback] participants were flagged as browser-fallback (`browser_fallback = 1`) and retained in the primary analytic sample; sensitivity analyses excluding them are reported below where pre-specified. [SLOT: n_prior_study] participants self-reported prior voting receipt study participation (`prior_receipt_study = 1`); retained in the primary sample, excluded in a pre-specified sensitivity check. Demographics: median age [SLOT: age_median] ([SLOT: age_iqr]); [SLOT: pct_tech_bg]% coded technology background (DM2); [SLOT: pct_prior_vote]% reported prior online election participation. Condition assignment was balanced (quota enforcement: n = [SLOT: n_quota_cell]/cell; any imbalance reported here: [SLOT: balance_note_or_"balanced"]).

**Inter-rater reliability.** Q5 (open-ended): κ = [SLOT: kappa_Q5] ([SLOT: kappa_Q5_verdict: ≥0.70 required; report raw value]). MQ1 (mental model): κ = [SLOT: kappa_MQ1]. [If either κ < 0.70: "Raters adjudicated disagreements and rescored before analysis; post-adjudication κ = [SLOT: kappa_post_adj]."

---

### Composite accuracy

Overall Q1–Q4 accuracy by condition (Table 3): [SLOT: pct_acc_A]% (A: fingerprint), [SLOT: pct_acc_B]% (B: confirmation code), [SLOT: pct_acc_C]% (C: nullifier), [SLOT: pct_acc_D]% (D: receipt ID). The omnibus 4-condition chi-squared test on composite accuracy was [SLOT: omnibus_sig_or_ns]: χ²([SLOT: omnibus_df]) = [SLOT: omnibus_stat], p = [SLOT: omnibus_p] (w = [SLOT: omnibus_w], [SLOT: omnibus_power_note]).

> **Script output:** `omnibus_result` object — `$chi_stat`, `$df`, `$p`, `$w`.  
> **Note:** Omnibus at 80% power requires n ≈ 82/cell; at n = 70 power ≈ 0.67 (pre-registered; paper §4.2). If omnibus is non-significant, note this does not affect the H2-primary or H3 pairwise Holm families.

---

### H1 — Fingerprint vs. receipt ID on privacy items (m = 2)

Q2 accuracy (choice-blindness): [SLOT: pct_Q2_A]% (A) vs. [SLOT: pct_Q2_D]% (D); χ²(1) = [SLOT: h1_q2_stat], p(one-tailed) = [SLOT: h1_q2_p_one]; OR = [SLOT: h1_q2_or] [SLOT: h1_q2_ci_95]. Q3 accuracy (coercion scenario): [SLOT: pct_Q3_A]% (A) vs. [SLOT: pct_Q3_D]% (D); χ²(1) = [SLOT: h1_q3_stat], p(one-tailed) = [SLOT: h1_q3_p_one]; OR = [SLOT: h1_q3_or] [SLOT: h1_q3_ci_95]. After Holm-Bonferroni correction (m = 2): [SLOT: H1_verdict: "both survive (H1 supported)" | "H1-Q2 survives, H1-Q3 does not (H1 partial)" | "neither survives (H1 null)" | "H1-reversed on Q2/Q3 (post-hoc two-tailed B > A, p < .05)"].

> **Script output:** `h1_results` — `$q2_stat`, `$q2_p_one`, `$q2_or`, `$q3_stat`, `$q3_p_one`, `$h1_holm_verdict`.

---

### H2 — Fingerprint vs. confirmation code dissociation (m = 3; primary endpoint)

**H2-primary (Q2).** [SLOT: pct_Q2_A]% (A: fingerprint) vs. [SLOT: pct_Q2_B]% (B: confirmation code); difference [SLOT: h2_q2_diff] pp; χ²(1) = [SLOT: h2_q2_stat], p(one-tailed) = [SLOT: h2_q2_p_one]; OR = [SLOT: h2_q2_or] [SLOT: h2_q2_ci_95].

**H2-secondary (Q3).** [SLOT: pct_Q3_A]% (A) vs. [SLOT: pct_Q3_B]% (B); difference [SLOT: h2_q3_diff] pp; χ²(1) = [SLOT: h2_q3_stat], p(one-tailed) = [SLOT: h2_q3_p_one]; OR = [SLOT: h2_q3_or] [SLOT: h2_q3_ci_95].

**H2-tertiary (TOST, composite accuracy).** Composite A: [SLOT: pct_acc_A]%; composite B: [SLOT: pct_acc_B]%; difference [SLOT: h2_tost_diff] pp (equivalence bounds: ±10 pp). TOST result: p_lower = [SLOT: h2_tost_p_lower], p_upper = [SLOT: h2_tost_p_upper]; equivalence [SLOT: h2_tost_verdict: "established (both p < .05)" | "not established (report Cohen's h)"]. [If not established: Cohen's h = [SLOT: h2_cohen_h], 90% CI of (p_A − p_B): [SLOT: h2_ci_90_lo] to [SLOT: h2_ci_90_hi].]

After Holm-Bonferroni correction (m = 3): **H2 outcome: [SLOT: H2_outcome: "supported (Q2 A>B significant AND composite equivalent)" | "null (Q2 non-significant AND equivalent)" | "reversed (Q2 non-significant AND post-hoc B>A two-tailed p<.05 AND equivalent/B>A composite)" | "inconclusive (report Cohen's h and 90% CI)"]**. See §6.2 for production implications.

> **Script output:** `h2_results` — `$q2_stat`, `$q2_or`, `$q3_stat`, `$tost_p_lower`, `$tost_p_upper`, `$equivalence_verdict`, `$h2_outcome`.  
> **Production note (pre-reg §13):** H2-supported → fingerprint confirmed superior; retain as default. H2-null → both labels equivalent; either label acceptable. H2-reversed → confirmation code superior; swap fingerprint for confirmation code. All three are actionable without redesign.

---

### H3 — Nullifier underperforms on inclusion inference (m = 6)

Q1 accuracy by condition: A [SLOT: pct_Q1_A]%, B [SLOT: pct_Q1_B]%, C [SLOT: pct_Q1_C]%, D [SLOT: pct_Q1_D]%. H3 unconditional pairwise tests (Q1 accuracy, C vs. A, B, D; one-tailed):

| Comparison | χ²(1) | p(one-tailed) | OR [95% CI] | Holm corrected |
|---|---|---|---|---|
| C < A | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |
| C < B | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |
| C < D | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |

[If omnibus significant (§4.5 conditional trigger):] Composite accuracy pairings (C vs. A, B, D; conditional on omnibus; Holm within m = 6 family):

| Comparison | χ²(1) | p(one-tailed) | OR [95% CI] | Holm corrected |
|---|---|---|---|---|
| composite C < A | [SLOT] | [SLOT] | [SLOT] | [SLOT] |
| composite C < B | [SLOT] | [SLOT] | [SLOT] | [SLOT] |
| composite C < D | [SLOT] | [SLOT] | [SLOT] | [SLOT] |

**H3 outcome: [SLOT: "supported (C lower than ≥ 2 of {A, B, D} on Q1 after Holm)" | "partial (C lower than 1 of {A, B, D})" | "null (C not lower than any after Holm)"]**. [Ethics-clause check: Q1 accuracy in Condition C = [SLOT: pct_Q1_C]%; if < 30%, label substitution note here.]

> **Script output:** `h3_results` — `$q1_pairwise_table`, `$composite_pairwise_table` (conditional), `$h3_outcome`.  
> **Design implication:** H3-supported → "nullifier" label suppresses inclusion inference (schema interference from "nullified = invalid"). Confirms PIUP Invariant 3 (label must not interfere with inclusion interpretation). Use to motivate label design constraints in §6.

---

### H4 — Confirmation code produces overconfidence (m = 3)

One-way ANOVA on confidence composite across 4 conditions: F([SLOT: df_between], [SLOT: df_within]) = [SLOT: h4_F], p = [SLOT: h4_p] (η² = [SLOT: h4_eta2]). [If ANOVA significant:] Tukey HSD post-hoc comparisons (B vs. A, C, D):

| Comparison | Mean diff | 95% CI | p (Tukey) | Holm corrected |
|---|---|---|---|---|
| B > A | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |
| B > C | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |
| B > D | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig/ns] |

**H4 outcome: [SLOT: "supported (ANOVA sig AND all 3 Tukey survive Holm)" | "partial (ANOVA sig, ≤ 2 Tukey survive)" | "null (ANOVA non-significant)"]**. Mean confidence composite per condition: A [SLOT: conf_mean_A] (SD [SLOT]), B [SLOT: conf_mean_B] (SD [SLOT]), C [SLOT: conf_mean_C] (SD [SLOT]), D [SLOT: conf_mean_D] (SD [SLOT]).

**Calibration analysis (pre-registered secondary; not in Holm family).** Per-condition Spearman ρ (accuracy score 0–4 vs. confidence composite): A ρ = [SLOT: rho_A], B ρ = [SLOT: rho_B], C ρ = [SLOT: rho_C], D ρ = [SLOT: rho_D]. [Expected: ρ_B < ρ_A — confirmation code produces high confidence not tracking accuracy.] This is a descriptive secondary analysis; no NHST verdict.

> **Script output:** `h4_results` — `$anova_F`, `$anova_p`, `$eta2`, `$tukey_table`, `$h4_outcome`; `h4_calibration` — `$spearman_by_cond`.  
> **Study 2 link:** If H4 is **supported**, the I-factor (calibration intervention) in Study 2 is live (H2.3 conditional; §5.5). If H4 is **null**, H2.3 is dropped and Study 2 reduces to N = 160.

---

### Q5 — Open-ended reasoning (pre-registered secondary)

[If κ ≥ 0.70:] Q5 mean scores by condition (0–2 rubric): A [SLOT: Q5_mean_A] (SD [SLOT]), B [SLOT: Q5_mean_B] (SD [SLOT]), C [SLOT: Q5_mean_C] (SD [SLOT]), D [SLOT: Q5_mean_D] (SD [SLOT]). Kruskal-Wallis: H([SLOT: df]) = [SLOT: KW_stat], p = [SLOT: KW_p]. [If significant:] Dunn's post-hoc (Holm correction): [SLOT: Dunn_pairs_surviving]. [If non-significant:] No condition differences in open-ended reasoning scores. A random 25-response sample per condition is included in the OSF supplementary materials.

> **Cross-study comparison note:** Q5 (Study 1) and M6 (Study 2) share the 0–2 scale structure but differ in Part 2 criterion at score-2 (Q5 Part 2 = mechanism reason; M6 Part 2 = intentional-design OR harmful consequence). Apply approximate-comparison qualifier per §4.5 when writing any cross-study Q5/M6 comparison in §6.

---

### Exploratory analyses

**MQ1 — Mental model quality.** Mean score per condition: A [SLOT: MQ1_mean_A], B [SLOT: MQ1_mean_B], C [SLOT: MQ1_mean_C], D [SLOT: MQ1_mean_D]. Distribution of 0/1/2 per condition: [SLOT: MQ1_dist_table]. κ = [SLOT: kappa_MQ1]. All cross-condition comparisons exploratory; reported descriptively without NHST.

**BI1 — Save intention.** Mean BI1 score (1–5) per condition: A [SLOT: BI1_mean_A], B [SLOT: BI1_mean_B], C [SLOT: BI1_mean_C], D [SLOT: BI1_mean_D]. This item previews Study 2 RQ4; no pre-registered test in Study 1. [Note: higher score = stronger save intention; 1 = Definitely would not save, 5 = Definitely would save.]

**Label affect.** Mean valence (−3 to +3) per condition: A [SLOT: affect_A], B [SLOT: affect_B], C [SLOT: affect_C], D [SLOT: affect_D]. All comparisons exploratory.

**Sensitivity analyses.** [If browser_fallback > 0:] Primary H2-primary result excluding browser-fallback participants (n = [SLOT: n_fallback_excluded]): χ²(1) = [SLOT: h2_q2_stat_no_fallback], p(one-tailed) = [SLOT: h2_q2_p_no_fallback]; verdict [SLOT: same/changed]. [If prior_receipt_study > 0:] Primary H2-primary result excluding prior-study participants (n = [SLOT: n_prior_excluded]): χ²(1) = [SLOT], p = [SLOT]; verdict [SLOT].

---

## Post-fill checklist

Before adding §4.6 to the CHI submission:

- [ ] All `[SLOT]` markers replaced
- [ ] Table 3 (accuracy by condition) added above this section
- [ ] κ values confirmed ≥ 0.70 (or adjudication documented)
- [ ] H4 outcome confirmed — study2 pre-reg updated if H4 null (drop H2.3, reduce N to 160)
- [ ] Q5/MQ1 approximate-comparison qualifier applied in §6.6 if cross-study comparison made
- [ ] OSF DOI inserted at top of §4.6 placeholder
- [ ] Word count checked after fill-in: §4.6 estimated 800–1,200w; total target ≤ 10,500w
- [ ] apply-o.py run (requires OSF Amendment 5 first)
- [ ] apply-t.py run (requires OSF Amendments 12+13+14 first)
- [ ] §6.6 written/updated from the H1/H2/H3/H4 verdict combination
- [ ] §7 conclusion checked for any data-dependent claims that need updating
