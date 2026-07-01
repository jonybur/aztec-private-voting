# PIUP Study 3 — Pre-Registration Quality Check

**Date:** 2026-07-01 (tick-4401)
**Reviewed:** `docs/piup-study3-osf-prereg-2026-07-01.md` (251 lines, drafted tick-4400)
**Against:** `docs/piup-study3-social-verification-2026-06-29.md`, `docs/piup-study3-power-analysis-2026-06-29.md`, `docs/piup-study3-preIRB-critique-2026-06-30.md`
**Reviewer:** Autonomous quality pass — not a substitute for Jony's review before OSF filing
**Status:** ✅ ALL ISSUES RESOLVED (tick-4408/4409/4410). Pre-reg OSF-ready pending Jony's OSF filing.

---

## Summary

The pre-reg is structurally solid — all pre-IRB H/M/L items are addressed, the pilot framing is consistent, and the 90% CI inferential framework is correct. Two issues were identified and resolved (ticks 4408-4410); the pre-reg is now OSF-ready.

---

## ✅ Issue 1 (RESOLVED tick-4408): Counter floor vs. expected baseline — manipulation failure is the likely outcome, not an edge case

### The problem

§3.2 specifies a counter floor of **≥10 verifications** before the social proof counter activates. The purpose is to avoid negative social proof at very low counts (Cialdini, 1984). This is correct in principle.

However, the floor is poorly calibrated relative to the pilot sample size:

| Baseline p₁ (control) | N = 80 | Expected verifications | Floor reached? |
|---|---|---|---|
| 0.10 (conservative ZK estimate) | 80 | **8** | ❌ No — 2 short |
| 0.15 (PIUP-optimistic) | 80 | **12** | ✅ Marginally yes |
| 0.20 (upper bound) | 80 | 16 | ✅ Yes |

At the conservative baseline (p₁ = 0.10), the expected number of verifications is 8, which is **below the floor of 10**. In this scenario, the social proof counter never activates in the treatment condition. The treatment group sees the same receipt as control for the entire 14-day window. The study would measure the effect of a manipulation that was never delivered.

§7.7 pre-specifies a response to this as "manipulation failure" — which is correct and well-specified. But the pre-reg treats manipulation failure as an edge case ("if the counter floor is not reached"). At the conservative baseline, it is the **expected outcome**, not an edge case.

This matters because the pre-reg will be evaluated by OSF reviewers and eventual IRB reviewers who will notice that the floor threshold and expected n are nearly identical.

### Fix options

**Option A — Lower the floor (simplest, pre-registerable)**
Change the floor from ≥10 to **≥5**. At p₁ = 0.10 and N = 80, expected verifications = 8, which clears a floor of 5. Rationale: the negative social proof effect from Cialdini (1984) is strongest when the count signals "nobody is doing this"; a count of 5–9 still signals a minority but avoids the "zero" effect.

**Option B — Make the floor proportional (more principled)**
Specify: "The social proof counter activates after ≥ max(5, 10% of total election participants) verifications." This scales appropriately to smaller elections without introducing a rigid floor that may be unreachable.

**Option C — Document explicitly, don't lower the floor**
Keep the floor at 10 but add explicit language: "At the conservative baseline (p₁ = 0.10, N = 80), there is a >50% probability that the floor is not reached and the manipulation is never delivered. Manipulation failure probability is documented in the power analysis document. The pilot is designed to test logistical feasibility and provide OR estimates in the scenario where the floor IS reached; if the floor is not reached, the trial is retrospectively classified as an implementation feasibility check and the design is revised before replication."

**Resolution (tick-4408):** Option A applied — counter floor changed from ≥10 to **≥5** in pre-reg §3.2 and §7.7. Rationale text added explaining the calibration choice. `analysis/piup-study3-analysis.R` drycheck floor parameter confirmed ≥5 (consistent). Supporting docs synced in tick-4409 (pre-IRB critique + analysis-readiness). Analysis-readiness gate table updated tick-4410 to mark floor RESOLVED.

---

## ✅ Issue 2 (RESOLVED tick-4408): DV2 timing heterogeneity — post-treatment for late voters

### The problem

§5 specifies DV2 (stated intent to verify) as: "Administered at T0 immediately after receipt display, before condition assignment is apparent."

The phrase "before condition assignment is apparent" is intended to mean "before participants realize there are two conditions" — consistent with the partial-disclosure design. However, the social proof counter IS displayed at T0 for participants who vote after the counter floor is reached. For these participants, DV2 is a **post-treatment measurement** (they've already seen the social proof counter before answering "How likely are you to return to verify?").

This creates **heterogeneity in DV2's causal position**:
- **Early voters** (vote before floor is reached): DV2 is pre-treatment (not exposed to counter at T0)
- **Late voters** (vote after floor is reached): DV2 is post-treatment (have already seen counter)

Including DV2 as a covariate in the primary logistic regression (§7.1: `DV1 ~ Condition + T0_intent (DV2) + self_efficacy (M1)`) introduces post-treatment bias for late voters. The condition effect would be attenuated by conditioning on a post-treatment mediator. This is a variant of the Lord's Paradox / post-treatment covariate problem.

Note: If Issue 1 is resolved with Option C (keeping floor at 10, N = 80, expected = 8), the floor is rarely reached at T0, and DV2 is almost always pre-treatment. The issue is less severe in that scenario.

### Fix

Add a pre-specified sensitivity analysis and flag the heterogeneity:

**In §5 (DV2 description)**, add:
> *Note: For participants who vote after the counter floor is reached, DV2 is administered after exposure to the social proof counter and therefore constitutes a post-treatment measurement. The heterogeneity in DV2's causal timing is pre-registered; see §7.8 Sensitivity analysis 3.*

**Add §7.8 — Sensitivity analysis 3: DV2 timing heterogeneity**

> For participants who voted after the counter floor was reached (and thus saw the counter before answering DV2), DV2 may be a post-treatment variable, introducing bias if used as a covariate. Sensitivity analysis 3: re-run the primary logistic regression (§7.1) excluding DV2 as a covariate (i.e., `DV1 ~ Condition + self_efficacy (M1)` only). Compare condition OR estimates with and without DV2. If OR estimates differ by >10%, report both and note the post-treatment bias.

**Resolution (tick-4408):** Full fix applied:
- Pre-reg §5 DV2 description updated: phrasing changed to "while participants are unaware that a two-condition design is in operation" + post-treatment subgroup note added ("DV2 is post-treatment for this subgroup (see §7.8)")
- §7.8 Sensitivity analysis 3 (DV2 timing heterogeneity) added to pre-reg with full specification
- §7.1 primary analysis cross-reference to §7.8 confirmed present

---

## ✅ Minor (RESOLVED tick-4408): "Before condition assignment is apparent" — ambiguous phrasing

§5 DV2 phrasing updated from "before condition assignment is apparent" to "while participants are unaware that a two-condition design is in operation." Verified present in current pre-reg §5 DV2 description.

---

## ✅ Items confirmed correct (no issues)

- Pre-reg pilot framing consistent throughout (90% CI, no NHST threshold, calibrate powered replication)
- Counter floor logic and Cialdini (1984) rationale correctly cited
- Das et al. (CCS '14) citation correct: Kramer, not Kim (verified tick-4340)
- Nissen et al. (2025) correctly cited and used in §8
- Lakens (2021) reference correct and consistent with 90% CI choice
- §7.7 manipulation failure protocol is well-specified
- §9 Relation to Study 2 correctly describes the embedded design
- Registration checklist is complete and sequenced correctly (Study 2 pre-reg first)
- Amendment protocol is appropriate
- All pre-IRB H/M/L items (from `piup-study3-preIRB-critique-2026-06-30.md`) addressed

---

## ✅ Current state (tick-4421)

All three issues resolved. Pre-reg is OSF-ready from an internal-consistency standpoint.

**Remaining blockers before OSF filing (Jony-only):**
1. Study 2 pre-reg must be filed on OSF first (per Registration Checklist)
2. Study 1 pilot data (N=40) needed to calibrate Study 2 power estimates before Study 2 pre-reg can be filed
3. OSF Amendments O+T must be filed for Study 1 (critical path blocker — see heartbeat preSendChecklist)
