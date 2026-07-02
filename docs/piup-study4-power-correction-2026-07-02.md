# PIUP Study 4 — H4.1 Power Calculation Correction

**Date:** 2026-07-02 (tick-4506)
**Author:** OpenClaw Agent
**Status:** Applied — `piup-study4-osf-prereg-2026-07-01.md` corrected before OSF filing
**Severity:** Moderate (power overstated in Rationale; sample size unaffected)

---

## Finding

Pre-reg Rationale for H4.1 stated:

> "Power at f = 0.25, α = .05, N = 80 per group: >99% for a main effect."

**This is incorrect.** The correct power for a one-tailed independent-samples t-test with d = 0.50 (equivalent to Cohen's f = 0.25 in a two-group comparison), n = 80 per group, one-tailed α = .05 is:

**≈93.4%** — not ">99%".

---

## Calculation (verified with scipy.stats.nct)

| Parameter | Value |
|-----------|-------|
| Cohen's d | 0.50 |
| n per group | 80 |
| df | 158 |
| Non-centrality (ncp = d × √(n/2)) | 3.162 |
| t_crit (one-tailed α = .05) | 1.655 |
| Power = P(t(158, ncp=3.162) > 1.655) | **93.4%** |

To achieve >99% power with n = 80/group and one-tailed α = .05, Cohen's d ≥ 0.70 (f ≥ 0.35) is required.

---

## H4.2 power check (unchanged)

| Parameter | Value |
|-----------|-------|
| Cohen's f (interaction) | 0.25 |
| N total | 160 |
| ncp_F = N × f² | 10.0 |
| df_num | 1 |
| df_err | 156 |
| F_crit (α = .05) | 3.902 |
| Power (via ncf) | **88.2%** |

Pre-reg states ≈86% — within 2pp rounding. Unchanged.

---

## Root cause (likely)

The ">99%" was likely written without recomputing for the specific t-test parameters. The effect size notation was also inconsistent: `f` (ANOVA effect size) was used in a t-test context; the correct notation for a t-test is Cohen's d = 0.50.

---

## What was changed

In `piup-study4-osf-prereg-2026-07-01.md`, H4.1 Rationale updated:

- **Before:** "Power at f = 0.25, α = .05, N = 80 per group: >99% for a main effect."
- **After:** "Power at d = 0.50 (f = 0.25), α = .05, N = 80 per group, one-tailed: ≈93% (confirmed via scipy.stats.nct; ncp = d × √(n/2) = 3.16, t_crit = 1.655, df = 158). H4.1 is secondary to H4.2; sample size was determined from H4.2's interaction power requirement (≈86–88%, N = 160)."

---

## Impact

- **Study design unchanged** — N = 160 was set by H4.2's interaction power requirement, not H4.1.
- **93.4% power for H4.1 is still high** — adequate for the secondary main effect test.
- **Pre-reg not yet filed on OSF** — correction applied pre-filing. No amendment required.
- **Jony action needed:** Review correction and confirm before OSF filing.
