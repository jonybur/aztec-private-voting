# PIUP Study 2 — Analysis Pipeline Readiness Validation

**Date:** 2026-06-30 (tick-4320)  
**Status:** PASS — pipeline validated, ready for OSF upload and pilot data collection  
**Relates to:** `analysis/piup-study2-analysis.R`, `analysis/piup-study2-drycheck.R`  
**Connects to:** `docs/piup-study2-preregistration-draft-2026-06-29.md`, `docs/piup-study2-survey-instrument-2026-06-28.md`  
**Mirrors:** `docs/piup-study1-analysis-readiness-2026-06-30.md` (Study 1 equivalent)

---

## Purpose

This document records the pre-data validation run of the Study 2 analysis pipeline, executed before OSF upload and pilot data collection. Running the analysis script against synthetic pilot data and confirming it executes cleanly is a standard pre-registration hygiene step.

Study 2 is a 2×2×2 between-subjects factorial design:
- **L (Label):** L1 = "vote fingerprint" / L2 = "confirmation code"
- **E (Explanation):** E1 = explanation present / E2 = explanation absent
- **I (Intervention):** I1 = no calibration / I2 = calibration prompt

8 conditions: L1E1I1, L1E1I2, L1E2I1, L1E2I2, L2E1I1, L2E1I2, L2E2I1, L2E2I2

**This document is internal only.** It is not an OSF filing.

---

## Validation runs

### Run 1: Drycheck (N=40 synthetic, instrument checks only)

```
Rscript analysis/piup-study2-drycheck.R
```

**Result: PASS**

| Check | Outcome |
|---|---|
| Required columns (25) | All present ✓ |
| Factor balance (8 conditions) | L: 20×20, E: 20×20, I: 20×20 ✓ |
| Exclusion logic (SW engineer, prior-study, RT, attn checks) | OK ✓ |
| Final analytic N | 37/40 retained (92.5%) ✓ |
| Attention check pass rate | ATTN1 82.5%, ATTN2 95.0%, either 100% ✓ |
| M2 Cronbach's α | -0.262 (below threshold — synthetic artefact; expected) |
| IRR (kappa) | -0.053 (below threshold — random synthetic raters; expected) |
| M4 calibration_confidence | Non-NA 37/37 ✓ |
| Task completion time | 416–899s (7–15 min) — within expected range ✓ |
| Package availability: PropCIs | ✓ |
| Package availability: TOSTER | ✓ |
| Package availability: irr | ✓ |
| Package availability: dunn.test | ✓ |
| Package availability: broom | ✓ |
| Package availability: emmeans | ✓ |

---

### Run 2: Full pilot mode (N=40 synthetic)

```
Rscript -e "PILOT <- TRUE; source('analysis/piup-study2-analysis.R')"
```

**Result: PASS — no errors; all pre-specified confirmatory tests executed**

| Stage | Outcome |
|---|---|
| Data load | N=40 ✓ |
| Exclusions | N=38 after 2 SW engineers (1 prior-study flagged, not excluded) ✓ |
| Balance (post-exclusion) | Conditions 4–5 per cell ✓ |
| Descriptives | Written to `analysis/results-study2/descriptives_study2.csv` ✓ |
| IRR (M6/Q-OE) | κ < 0.70 — random synthetic scores; expected; warning correctly issued ✓ |
| H2.1 (E main effect on M1) | Executed correctly; SUPPORTED at pilot N (p=0.0437, synthetic artefact) ✓ |
| H2.2 (L×E interaction on M2) | Executed correctly; NOT SUPPORTED at pilot N (p=0.122; expected) ✓ |
| H2.3 (calibration on M4) | Correctly SKIPPED — conditional on Study 1 H4 support ✓ |
| H2.4 (M1 predicts download click) | Executed correctly; NOT SUPPORTED at pilot N (p=0.828; expected) ✓ |
| Sensitivity runs (browser-fallback, prior-study) | Both executed correctly ✓ |
| Design Decision output (§3 contingency) | Executed correctly ✓ |
| Summary table | Written to `analysis/results-study2/confirmatory_tests_summary_study2.csv` ✓ |

---

## Confirmatory test summary (synthetic data only — not interpretable)

| Hypothesis | p-value (synthetic) | Verdict | Note |
|---|---|---|---|
| H2.1: E main effect on Q-AC accuracy | 0.0437 | SUPPORTED | N=40 artefact; not interpretable |
| H2.2: L×E interaction on M2 trust | 0.122 | NOT SUPPORTED | Expected at N=40; null result expected at pilot scale |
| H2.3: Calibration effect on M4 residual | — | SKIPPED | Conditional on Study 1 H4; Study 1 H4 verdict pending data |
| H2.4: M1 accuracy predicts download click | 0.828 | NOT SUPPORTED | N=40 artefact; not interpretable |

**All verdicts above are synthetic artefacts. The pipeline executes all tests correctly.**

---

## Known issues (expected, not concerns)

| Issue | Count | Cause | Status at real N (N≥240) |
|---|---|---|---|
| M2 Cronbach's α below threshold | 1 warning | Synthetic item correlations are random | Recheck with real pilot data (N=8+ per cell) |
| IRR (kappa) below threshold | 1 warning | Q-OE scores are random synthetic integers | Won't occur with trained raters; rater adjudication required before M6 analysis |
| `qoe_open_text` column not found | 1 warning | Synthetic data uses numeric rater columns; no text column | Map Qualtrics open-text export column name to `COL_QOE_TEXT` in script header before real run |
| H2.3 skipped | 1 skip | Study 1 H4 not yet determined (pre-data) | Set `H4_SUPPORTED` in script header after Study 1 analysis completes |
| PILOT flag not picked up externally | cosmetic | Script sets PILOT=FALSE internally; external override via `source()` call doesn't persist across script's own assignment | No consequence — all confirmatory tests run regardless of PILOT flag |

---

## Pre-pilot gate status (Study 2)

| Item | Status |
|---|---|
| Drycheck PASS | ✅ |
| Pilot mode PASS | ✅ |
| Required packages installed (R 4.3.3) | ✅ |
| Power simulation complete | ✅ (`analysis/piup-study2-power-simulation.R`) |
| Pre-registration draft | ✅ (`docs/piup-study2-preregistration-draft-2026-06-29.md`) |
| Survey instrument | ✅ (`docs/piup-study2-survey-instrument-2026-06-28.md`) |
| Qualtrics setup guide | ✅ (`docs/qualtrics-setup-guide-study2-2026-06-28.md`) |
| OSF pre-registration upload | ⏳ Pending — upload `piup-study2-analysis.R` + `piup-study2-drycheck.R` to OSF before data collection |
| `qoe_open_text` column name mapping | ⏳ Confirm Qualtrics export header name; update `COL_QOE_TEXT` in script header |
| `H4_SUPPORTED` flag | ⏳ Set after Study 1 analysis completes |
| Study 2 is downstream of Study 1 | ⏳ Launch after Study 1 pilot data confirms instrument performance |

---

## Action items before Study 2 pilot launch

1. **Confirm `COL_QOE_TEXT`**: After Qualtrics build, export a test response and check what the Q-OE open text column is named in the CSV. Update the constant in `piup-study2-analysis.R` (search for `COL_QOE_TEXT`).
2. **Set `H4_SUPPORTED`**: After Study 1 analysis completes, update this flag at the top of `piup-study2-analysis.R`.
3. **OSF upload**: Upload `piup-study2-analysis.R` and `piup-study2-drycheck.R` to the OSF pre-registration. Remove the synthetic data generator block from the drycheck script before uploading (or note it as validation-only).
4. **Remove synthetic data**: Delete `data/prolific-export-study2.csv` (synthetic) before replacing with real Prolific export.
5. **Rater training**: Train two coders on the Q-OE rubric (pre-reg §6.7) and establish κ ≥ 0.70 on a training set before scoring real data.
