# PIUP Study 4 — Analysis Readiness Report

**Date:** 2026-07-01 (tick-4416)
**Reviewed:** `analysis/piup-study4-drycheck.R`, `analysis/piup-study4-analysis.R`
**Against:** `docs/piup-study4-osf-prereg-2026-07-01.md`, `docs/piup-study4-crosscheck-2026-07-01.md`, `docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`
**Study type:** 2×2 between-subjects vignette experiment (D = UI-lock, P = coercion pressure)
**Reviewer:** Autonomous quality pass — not a substitute for Jony's review before IRB submission
**Status:** ✅ All 10 dry-check sections PASS. Analysis script structurally valid. Ready for IRB submission once Jony completes Fix 2 (IRB contact fields) and Fix 10 (OSF Amendment 4-A).

---

## Dry-check execution summary

Run: `Rscript analysis/piup-study4-drycheck.R` — 2026-07-01 (tick-4416)

| Section | Content | Status |
|---------|---------|--------|
| 1 | Synthetic data generation — N=200 (50/condition); all 12 required columns | ✅ PASS |
| 2 | Required column check — types, ranges, factor levels | ✅ PASS |
| 3 | Exclusion derivation — attention fail + speed-through; ITT N=160 | ✅ PASS |
| 4 | H4.2 — D×P ANOVA + interaction simple effects branch | ✅ PASS |
| 5 | H4.1 — D main effect on DV1 (sharing intent), Cohen's d | ✅ PASS |
| 6 | H4.3 — D effect on DV2 (perceived deniability), Cohen's d | ✅ PASS |
| 7 | H4.4 — D×P×M1 three-way moderated regression, ΔR² F-test | ✅ PASS |
| 8 | SA-1 through SA-4 sensitivity analyses | ✅ PASS |
| 9 | TOST null result protocol (equivalence bounds ±1 pooled SD) | ✅ PASS |
| 10 | Descriptives summary — cell Ns, DV1/DV2/DV3 by condition | ✅ PASS |

**Overall: ALL SECTIONS PASSED** — analysis/piup-study4-analysis.R executes without errors on structured synthetic data.

---

## Key design parameters verified by dry-check

| Parameter | Value | Source |
|-----------|-------|--------|
| Study design | 2×2 between-subjects (D × P) | Pre-reg §2 |
| Conditions | D0P1, D0P2, D1P1, D1P2 | Pre-reg §2 |
| Target N | 200 (50/condition before exclusions) | Pre-reg §4 |
| ITT N (synthetic) | 160 after ~12% attrition (attention fail + speed-through) | Drycheck §3 |
| Primary DV | DV1: sharing intent (1–7 Likert) | Pre-reg §3.3 |
| Secondary DV | DV2: perceived deniability (1–7 Likert) | Pre-reg §3.4 |
| Comprehension | DV3: binary (vote-choice display recall) | Pre-reg §3.4 |
| Attention check | Single Likert with correct = 7 | Pre-reg §5 |
| Speed-through cutoff | < 180s AND attention_fail = 0 | Pre-reg §6 |
| Primary test H4.1 | One-tailed t-test (D0 > D1 on DV1), Cohen's d | Pre-reg §7 |
| Primary test H4.2 | 2×2 ANOVA + simple effects if interaction p < .05 | Pre-reg §7 |
| TOST bounds | ±1 pooled SD on DV1 scale | Pre-reg §7.5 |
| Sensitivity analyses | SA-1 (DV3 filter), SA-2 (M1 covariate), SA-3 (C1 covariate), SA-4 (ANCOVA) | Pre-reg §8 |

---

## Comparison with Study 3 dry-check (tick-4406)

Study 3 dry-check (8 sections) passed 2026-07-01. Study 4 dry-check (10 sections) now also passes. Key differences:

| Aspect | Study 3 | Study 4 |
|--------|---------|---------|
| Design | Two-arm field experiment (binary) | 2×2 vignette (factorial) |
| Primary test | Logistic regression | ANOVA + simple effects |
| Additional tests | KM survival (time-to-verify), SA-1/2/3 | SA-1/2/3/4, TOST null |
| Dry-check sections | 8 | 10 |
| Status | ✅ All pass | ✅ All pass |

---

## Remaining blockers before Study 4 launch

All remaining items are **Jony-only** (agent-fixable items fully resolved in ticks 4390–4415):

| Item | Description | Who |
|------|-------------|-----|
| Fix 2 | IRB contact fields (Qualtrics + consent form — actual names/emails needed) | Jony |
| Fix 10 | File OSF Amendment 4-A (wording deviation: "Imagine" prefix dropped from vignette) | Jony |

No analysis script changes required. No pre-registration changes required (post tick-4415 audit confirmed Issues 5+6 were pre-existing in §9).

---

## Pre-registration alignment (key checks)

1. **Column names:** Analysis script uses `DV1_share`, `DV2_deniability`, `DV3_label`, `ui_cond`, `pressure_cond`, `M1_efficacy`, `C1_familiarity`, `QR6_ATTN`, `Q_TotalDuration`, `QR6_C1`, `participant_id`, `condition` — matches expected Qualtrics export variable names.

2. **Factor levels:** `ui_cond` = {D0, D1} (D0 = reference, countdown-only); `pressure_cond` = {P1, P2} (P1 = reference, moderate) — matches pre-reg §2 and Qualtrics randomizer.

3. **Exclusion sequence:** Attention fail applied first (requires QR6_ATTN ≠ 7), then speed-through (duration < 180s, but only if not already excluded) — matches pre-reg §6 and corrected survey flow (Fix 1, tick-4390).

4. **H4.2 branching:** ANOVA interaction p < .05 → simple effects within P1 and P2 separately, then report interaction contrast. If interaction p ≥ .05 → report D main effect only. This matches pre-reg §7.2 decision tree.

5. **TOST trigger:** TOST runs only if H4.1 one-tailed t-test p ≥ .05 (null result path). If H4.1 is significant, TOST is skipped and labelled "not required." Bounds ±1 pooled SD are pre-registered.

---

*End of analysis readiness report.*
