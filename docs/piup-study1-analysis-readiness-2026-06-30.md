# PIUP Study 1 — Analysis Pipeline Readiness Validation

**Date:** 2026-06-30 (tick-4319)  
**Status:** PASS — ready for data collection  
**Relates to:** `analysis/piup-study1-analysis.R`, `analysis/piup-study1-drycheck.R`  
**Connects to:** `docs/piup-study1-preregistration-2026-06-22.md`, `docs/chi-paper-s1-results-fill-template-2026-06-30.md`

---

## Purpose

This document records the pre-data validation run of the Study 1 analysis pipeline, executed before OSF upload and pilot data collection. Running the analysis script against synthetic pilot data and confirming it executes cleanly is a standard pre-registration hygiene step.

**This document is internal only.** It is not an OSF filing. It should be referenced in the amendment log if the analysis script is changed after OSF upload.

---

## Validation runs

### Run 1: Drycheck (N=40 synthetic, instrument checks only)

```
Rscript analysis/piup-study1-drycheck.R
```

**Result: PASS**

| Check | Outcome |
|---|---|
| Required columns (23) | All present ✓ |
| Exclusion logic (attn checks, RT, occupation) | OK ✓ |
| Pilot floor/ceiling check | 1 synthetic ceiling (Cond A, q4 = 100%) — synthetic artefact |
| Task time descriptives | 314–712s (5–12 min) — within expected range |
| Attention check pass rate | 100% ✓ |
| Package availability: PropCIs | ✓ |
| Package availability: irr | ✓ |
| Package availability: dunn.test | ✓ |

**Kappa (synthetic):** Q5 κ = 0.030, MQ1 κ = 0.065 — expected below threshold with random synthetic rater assignments; not a concern for real data.

---

### Run 2: Full pilot mode (N=40 synthetic, PILOT=TRUE)

```
Rscript -e "PILOT <- TRUE; source('analysis/piup-study1-analysis.R')"
```

**Result: PASS — no errors, 16 warnings all expected**

| Stage | Outcome |
|---|---|
| Data load + exclusions | N=38 after 2 excluded (SW engineers) ✓ |
| Balance check (condition assignment) | A=10, B=10, C=8, D=10 ✓ |
| IRR (kappa) | κ < 0.70 — expected with random synthetic raters; warning correctly issued ✓ |
| Descriptives | Printed + written to `analysis/results/descriptives.csv` ✓ |
| Omnibus chi-squared | Executed correctly ✓ |
| H1–H4 hypothesis families (all 14 tests) | Executed and output to `analysis/results/confirmatory_tests_summary.csv` ✓ |
| Holm correction | Applied correctly per pre-reg family structure ✓ |
| TOST equivalence test (H2-tertiary) | Executed with correct z-test on proportions ✓ |
| H2 verdict logic (supported/null/reversed/inconclusive) | Executed correctly ✓ |
| Q5 Kruskal-Wallis + Dunn | Executed ✓ |
| Sensitivity analyses (browser-fallback, prior-study) | Skipped appropriately (no fallback/prior participants in synthetic data) ✓ |
| Session info | R 4.3.3, platform x86_64-linux ✓ |

**Output files written:**
- `analysis/results/clean_data.csv` (N=38 after exclusions)
- `analysis/results/descriptives.csv`
- `analysis/results/confirmatory_tests_summary.csv`

**Note on results/ files:** These files are generated from synthetic data and should not be committed to version control. Add `analysis/results/` to `.gitignore` if not already present before OSF upload.

---

## Warning analysis (16 warnings)

All 16 warnings are expected and non-blocking:

| Warning type | Count | Cause | Status at N=280 |
|---|---|---|---|
| IRR below threshold (kappa) | 2 | Random synthetic rater scores | Will not occur with real raters who achieve κ ≥ 0.70 |
| Chi-squared approximation may be incorrect | 14 | Expected cell count < 5 in small pilot N | Will not occur at N=70/condition (min expected cell count ≈ 14 at 20% proportions) |

At the full study N=280 (70/condition), all chi-squared cells will have expected counts well above 5 across all plausible true proportions (the most extreme prediction is Q1 for Condition C at ~40%, which gives expected counts of 28 and 42 — both far above 5). No Fisher's exact test fallback is needed.

---

## Pre-registered hypothesis map (all 14 tests)

| Family | Test | Comparison | Script function |
|---|---|---|---|
| H1 (m=2) | H1-Q2 | A > D, one-tailed χ² | `two_by_two_chisq(..., direction="greater")` |
| H1 (m=2) | H1-Q3 | A > D, one-tailed χ² | `two_by_two_chisq(..., direction="greater")` |
| H2 (m=3) | H2-primary | A > B on Q2, one-tailed χ² | `two_by_two_chisq(h2_primary)` |
| H2 (m=3) | H2-secondary | A > B on Q3, one-tailed χ² | `two_by_two_chisq(h2_secondary)` |
| H2 (m=3) | H2-tertiary | TOST equivalence, composite, ±10pp | `tost_prop(...)` |
| H3 (m=6) | H3-Q1(C<A) | C < A, one-tailed χ² | `two_by_two_chisq(h3_q1_ca, direction="less")` |
| H3 (m=6) | H3-Q1(C<B) | C < B, one-tailed χ² | `two_by_two_chisq(h3_q1_cb, direction="less")` |
| H3 (m=6) | H3-Q1(C<D) | C < D, one-tailed χ² | `two_by_two_chisq(h3_q1_cd, direction="less")` |
| H3 (m=6) | H3-comp(C<A) | C < A, composite, conditional | Conditional on omnibus p < .05 |
| H3 (m=6) | H3-comp(C<B) | C < B, composite, conditional | Conditional on omnibus p < .05 |
| H3 (m=6) | H3-comp(C<D) | C < D, composite, conditional | Conditional on omnibus p < .05 |
| H4 (m=3) | H4-conf(B>A) | B > A, Tukey HSD confidence | ANOVA → `TukeyHSD` |
| H4 (m=3) | H4-conf(B>C) | B > C, Tukey HSD confidence | ANOVA → `TukeyHSD` |
| H4 (m=3) | H4-conf(B>D) | B > D, Tukey HSD confidence | ANOVA → `TukeyHSD` |

All 14 tests executed correctly in pilot run. Holm correction applied within-family. Summary table verified against pre-registration §6.3–6.6.

---

## Anomaly: no prior_receipt_study column in synthetic data

The synthetic data generator in `piup-study1-drycheck.R` does not generate the `prior_receipt_study` column (pre-registered SC1 screener, §3). The main analysis script handles this gracefully — the sensitivity analysis that would exclude prior-study participants is skipped when no participants carry `prior_receipt_study = 1`. This is correct behaviour. When real Prolific data is loaded, the column must be present.

**Action:** Before loading real data, verify the Qualtrics export includes the `prior_receipt_study` screener variable (mapped from SC1). Check `docs/qualtrics-setup-guide-2026-06-22.md` §Column map for the exact variable name.

---

## Pre-pilot gate status

| Gate item | Status |
|---|---|
| Analysis script drycheck | ✅ PASS |
| Analysis script pilot mode | ✅ PASS (PILOT=TRUE) |
| Required packages installed | ✅ PropCIs, irr, dunn.test |
| R version compatible | ✅ R 4.3.3 |
| OSF pre-registration | ⏳ Pending Jony action (JONY-ACTION O + T must precede upload) |
| Survey instrument (Qualtrics) | ⏳ Pending OSF upload |
| Prolific launch | ⏳ Pending Qualtrics setup |

**Next action (Jony):** File OSF Amendment 5 (JONY-ACTION O) and Amendment 14 (JONY-ACTION T), then upload pre-registration files. Pipeline is ready.

---

## Script version pinned

Analysis script committed at: `282670e` (most recent CHI paper annotation strip)  
Drycheck committed at: same  
This readiness doc reflects script state as of tick-4319 (2026-06-30 17:28 UTC).

Any changes to `piup-study1-analysis.R` after OSF upload must be documented in §14 (Amendments log) of the pre-registration.
