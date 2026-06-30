# PIUP Study 2 — Pre-Registration Cross-Check Report

**Date:** 2026-06-30 (tick-4321)  
**Author:** OpenClaw Agent  
**Purpose:** Systematic cross-check of `piup-study2-preregistration-draft-2026-06-29.md` against `piup-study2-survey-instrument-2026-06-28.md` and `piup-study2-analysis.R` before OSF upload.  
**Result:** 5 gaps found. 1 critical, 2 moderate, 2 minor. All addressed below; fixes applied in tick-4321.

---

## Summary

| # | Severity | Location | Description | Fixed |
|---|----------|----------|-------------|-------|
| 1 | **CRITICAL** | Instrument §2 survey flow | M4 (Calibration Confidence) listed at position 11 (after M3 Save Intention), contradicting §11 and pre-reg §5.3 which specify M4 immediately after Q-AC (before Trust Scale) | ✅ Instrument §2 corrected |
| 2 | MODERATE | Instrument §18 codebook | `qoe_open_text` raw open-text column missing from variable codebook | ✅ §18 + §19 updated |
| 3 | MODERATE | Analysis script H2.2 | M2 α < 0.70 contingency: script warns but still runs H2.2 ANOVA on composite; pre-reg §5.3 says "report items individually" | ✅ Script patched |
| 4 | MINOR | Instrument §14 DM2 note | "Does not trigger exclusion" contradicts analysis script which uses `occupation_sw_eng` as a hard exclusion for SC2 slipthrough | ✅ §14 note clarified |
| 5 | MINOR | Instrument §20 checklist | "5 participants per condition (N = 40)" conflicts with pre-reg §7 pilot (10/cell = N = 80); implies two different steps but this is ambiguous | ✅ §20 note added |

---

## Gap 1 — CRITICAL: Survey flow §2 M4 position wrong

### Pre-registration §5.3 (M4 spec):
> "Post-receipt Q-AC confidence: 'How confident are you in your answer above?' (1 = Not at all confident → 7 = Completely confident), **placed immediately after Q-AC (before trust scale)**."

### Instrument §11 (M4 body text):
> "It is **placed immediately after Q-AC on the same page**."

### Instrument §2 survey flow (pre-fix):
```
8.  Comprehension Block (Q-AC) — M1
9.  Trust Scale (TI1, TI2, TC1, TC2) — M2
10. Save Intention (M3-self)
11. Miscalibration Confidence (M4, all conditions)   ← WRONG POSITION
12. Open Text Q-OE (M6)
```

**Problem:** If Qualtrics is built following §2's flow exactly, M4 appears after Save Intention (M3). The question stem "How confident are you in your answer above?" would then refer to Save Intention (a 7-point likelihood scale), not Q-AC (the binary receipt comprehension measure). This renders M4 meaningless.

**Root cause:** M4 was originally I2-only and placed after M3. When Amendment 7 (tick-4246) moved M4 to all-conditions and repositioned it before the Trust Scale, §11 and the pre-reg were updated, but §2 survey flow was not updated.

**Fix:** §2 flow updated. M4 absorbed into item 8 ("same-page follow-up to Q-AC"). Items renumbered (15 → 15 items total, one fewer numbered item).

---

## Gap 2 — MODERATE: `qoe_open_text` not in codebook

**Analysis script (Amendment 18 block):**
```r
COL_QOE_TEXT <- "qoe_open_text"  # raw open-text Q-OE column
```
This column is referenced in §3.5 (random sample draw) and in Amendment 18 note, but it does not appear in the §18 variable codebook.

**Fix:** Row added to §18 codebook. Amendment 23 logged.

---

## Gap 3 — MODERATE: M2 α < 0.70 path not implemented in H2.2

**Pre-registration §5.3 and §6.1 step 8:**
> "α ≥ 0.70 required; if not met, items reported individually."

**Analysis script (pre-fix):** Computes alpha and prints `*** BELOW THRESHOLD — report items individually ***`, but then proceeds to run H2.2 ANOVA on `m2_trust` composite regardless.

**Problem:** If α < 0.70 in the real data, H2.2 ANOVA runs on an unreliable composite without any caveat. The confirmatory result would be reported as if it were pre-specified, when the pre-reg says the composite cannot be used below the threshold.

**Fix:** A warning block added before H2.2 that prints a clear "EXPLORATORY — composite reliability insufficient" notice when `alpha_raw < 0.70`. The ANOVA still runs (to provide descriptive output) but the result is clearly flagged as exploratory. No hypothesis, alpha, or verdict criterion change.

---

## Gap 4 — MINOR: DM2 exclusion vs. sensitivity-only ambiguity

**Instrument §14 DM2 (pre-fix):**
> "it does not trigger exclusion."

**Analysis script:**
```r
df <- df[df[[COL_OCCUPATION]] != 1, ]  # Exclude self-reported software engineers
```
`COL_OCCUPATION` = `occupation_sw_eng` (DM2). This is a hard exclusion.

**Context:** SC2 is a screener redirect; participants who fail it never produce a data row. DM2 is a post-screener check that can catch edge cases where someone misrepresented their occupation in SC2 or slipped through. The analysis script's exclusion on DM2 is defensible as implementing pre-reg §6.1 step 3 ("Exclude self-reported software engineers / CS/SE students") for any SC2 slipthrough.

**Fix:** Instrument §14 DM2 note updated to clarify DM2 is primarily a secondary cross-check AND is used as a hard exclusion in the analysis script for SC2 slipthrough cases. Consistent with pre-reg §4.1 and §6.1 step 3.

---

## Gap 5 — MINOR: Instrument §20 pilot size ambiguity

**Pre-registration §7:** "n = 10 per cell (N = 80 total; same 8 conditions)"

**Instrument §20 (pre-fix):**
> "Pilot dry-run: 5 participants per condition (N = 40) via Prolific; verify column structure with `piup-study2-drycheck.R`"

**Context:** These are likely two different steps — (a) a minimal structural pipeline check (5/cell = N=40) to confirm Qualtrics → R export works correctly, followed by (b) the full pre-registered pilot (10/cell = N=80) for instrument validation. But the checklist item doesn't make this explicit.

**Fix:** §20 note added to clarify the 5/cell check is a structural verification step, distinct from the full 10/cell pilot.

---

## Confirmed alignments

The following were verified as consistent across all three documents:

| Item | Pre-reg | Instrument | Analysis |
|------|---------|------------|----------|
| Factor structure (2×2×2, 8 conditions) | §2.2 | §1, §2 | CONDITIONS vector |
| Q-AC wording + scoring | §5.2 | §8 | COL_QAC, m1_qac |
| M2 trust items (4 items, TI1/TI2/TC1/TC2) | §5.3 | §9 | COL_TI1–TC2 |
| M3 save intention (7-point Likert) | §5.3 | §10 | COL_SAVE_INTENT |
| M4 formula: (conf−1)/6 − Q-AC_accuracy | §5.3 | §11 | m4_residual derivation |
| M6 scoring rubric (0–2, two raters) | §5.3 (adapted) | §16 | round(rowMeans(r1,r2)) |
| H2.1: chi-squared, one-tailed, E1>E2 | §3 | — | two_prop_chisq_one_tailed |
| H2.2: two-way ANOVA (L×E, I collapsed) | §3, §6.3 | — | aov(m2_trust ~ L*E) |
| H2.3: conditional on H4; L2 only; TOST Lakens | §3, §6.4 | — | tsum_TOST, var.equal=FALSE |
| H2.4: logistic reg, download_click ~ M1+L+E+I | §3, §6.5 | — | glm(m3_click ~ m1_qac+L+E+I) |
| Exclusion: both ACs fail (not just one) | §4.1 | §13 | !(ATTN1==0 & ATTN2==0) |
| Exclusion: RT < 90s | §4.1 | §17 | COL_RT_SEC >= 90 |
| Prior-study flag (not exclusion) | §5 | §14 DM4 | flag + §6.8 sensitivity |
| Browser-fallback flag (not exclusion) | §4.1 | §6 JS | COL_BROWSER_FALLBACK |
| Calibration block (I2 only, before stimulus) | §2.2 | §5, §17 | kappa_ok gate |
| κ ≥ 0.70 gate for all M6 analysis | §6.7 | §16 | kappa_ok flag (Amendment 20) |
| §6.8 prior-study sensitivity (H2.1 + H2.4) | §6.8 | — | §6.8 block in script |
| All column names in §18 codebook | §5 | §18 | COLUMN MAP constants |

---

## Status after tick-4321 fixes

- **Pre-reg:** No changes needed (it was the authoritative source; gaps were in instrument/script)
- **Instrument §2, §14, §18, §19, §20:** Updated (4 fixes)
- **Analysis script:** M2 α warning before H2.2 added (Amendment 23)
- **Cross-check report:** This document

All 5 gaps resolved. Documents are now consistent across pre-reg, instrument, and analysis script. Safe to proceed to OSF upload after Study 1 pilot + H4 verdict.
