# PIUP Study 3 — Pre-Registration Quality Check

**Date:** 2026-07-01 (tick-4401)
**Reviewed:** `docs/piup-study3-osf-prereg-2026-07-01.md` (251 lines, drafted tick-4400)
**Against:** `docs/piup-study3-social-verification-2026-06-29.md`, `docs/piup-study3-power-analysis-2026-06-29.md`, `docs/piup-study3-preIRB-critique-2026-06-30.md`
**Reviewer:** Autonomous quality pass — not a substitute for Jony's review before OSF filing
**Status:** 2 issues flagged + 1 minor. Fixes proposed below.

---

## Summary

The pre-reg is structurally solid — all pre-IRB H/M/L items are addressed, the pilot framing is consistent, and the 90% CI inferential framework is correct. Two issues require attention before OSF submission.

---

## 🔴 Issue 1: Counter floor vs. expected baseline — manipulation failure is the likely outcome, not an edge case

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

**Recommendation:** Option A (floor → 5) or Option C (explicit disclosure). Option B is more principled but harder to pre-register cleanly.

**Required change to pre-reg:** Update §3.2 counter floor language. If choosing Option A:

> **Counter floor (pre-registered):** ... the social proof counter activates only after **≥ 5 participants have verified their receipt**. This floor was chosen over higher thresholds (e.g., ≥10) because at the expected pilot sample size (N = 80), a floor of 10 would not be reached at the conservative baseline verification rate (10% × 80 = 8 verifications). A floor of 5 avoids negative social proof from "0 verified" while remaining reachable in a pilot. The floor value (5) is the pre-registered design parameter; it will not be changed after registration.

---

## 🟡 Issue 2: DV2 timing heterogeneity — post-treatment for late voters

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

This pre-specifies the comparison rather than leaving it to post-hoc analysis.

### Minimal fix (if no text space available)

Revise §5 DV2 description to:

> "Administered at T0 immediately after receipt display. Note: participants who vote after the counter floor is reached will have already seen the social proof counter when DV2 is measured; DV2 is post-treatment for this subgroup."

And add a one-line note to §7.1:

> "Sensitivity: re-run excluding DV2 as covariate (see §7.8)."

---

## ⚪ Minor: "Before condition assignment is apparent" — ambiguous phrasing

§5 DV2: "Administered at T0 immediately after receipt display, before condition assignment is apparent."

This is ambiguous. It could mean:
1. Before participants realize two conditions exist (partial disclosure context) — intended meaning
2. Before the condition-specific manipulation is delivered — unintended implication

Clearer phrasing: "Administered at T0 immediately after receipt display, while participants are unaware that a two-condition design is in operation."

No structural change needed — just a phrasing fix.

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

## Recommended action before OSF filing

1. **Decide on Issue 1 fix** (lower floor to 5, OR add explicit manipulation-probability disclosure) — Jony to choose
2. **Apply Issue 2 fix** (add sensitivity analysis §7.8, update DV2 description) — can be done autonomously
3. **Apply minor phrasing fix** in §5 DV2 — can be done autonomously
4. Pre-reg filing is contingent on Study 2 pre-reg being filed first (per Registration Checklist)

Issue 2 and the minor fix can be applied to the pre-reg file directly. Issue 1 requires Jony's design decision on the floor threshold.
