# PIUP Study 3 — Analysis Readiness Report

**Date:** 2026-07-01 (tick-4407)  
**Reviewed:** `analysis/piup-study3-analysis.R`, `analysis/piup-study3-drycheck.R`  
**Against:** `docs/piup-study3-osf-prereg-2026-07-01.md`, `docs/piup-study3-prereg-quality-check-2026-07-01.md`, `docs/piup-study3-social-verification-2026-06-29.md`  
**Study type:** Two-arm between-subjects field experiment (embedded in same live election as Study 2)  
**Reviewer:** Autonomous quality pass — not a substitute for Jony's review before OSF filing  
**Status:** ✅ Critical discrepancy resolved in tick-4408 (Option A applied — pre-reg floor updated to ≥5 to match analysis script). Pre-reg ready for Jony’s OSF filing review.

---

## ✅ RESOLVED (tick-4408): Counter floor mismatch — pre-reg vs. analysis script

**Option A applied.** Pre-reg updated to floor=5 in §3.2, §7.7, and registration checklist. Analysis script already uses floor=5. No script change needed. Pre-reg commit: see tick-4408.

| Document | Counter floor (PRE-fix) | Counter floor (POST-fix tick-4408) | Location |
|---|---|---|---|
| `piup-study3-osf-prereg-2026-07-01.md` | ≥10 | **≥5** ✅ aligned | §3.2 and §7.7 |
| `piup-study3-analysis.R` | ≥5 | **≥5** ✅ (unchanged) | Lines 119, 124, 431–438 |
| `piup-study3-drycheck.R` | ≥5 | **≥5** ✅ (unchanged) | — |

### Why this happened

The pre-reg was drafted (tick-4400) with floor=10. The quality check (tick-4401, `docs/piup-study3-prereg-quality-check-2026-07-01.md`) found that at the conservative baseline (p₁=0.10, N=80), expected verifications = 8 — below the floor. The check recommended lowering to ≥5 (Option A) or keeping 10 with explicit disclosure (Option C). The analysis script (tick-4405) was subsequently written with floor=5 (incorporating Option A), but the pre-reg was not updated to match.

### Consequence if left unresolved

If Jony files the pre-reg with floor=10, then runs the analysis script with floor=5, the deployment check message will say "≥5 verifications" while the filed pre-reg says "≥10." An OSF reviewer or IRB reviewer inspecting the script would notice the mismatch.

### Required Jony action — choose one:

**Option A — Lower pre-reg floor to ≥5 (matches analysis script; recommended by quality check)**  
Update §3.2 and §7.7 in `piup-study3-osf-prereg-2026-07-01.md`. File with floor=5. No script change needed. Registration checklist item (line 240) update: "Counter floor value confirmed as **5**."

Pre-reg replacement text for §3.2 (floor paragraph):
> **Counter floor (pre-registered):** ... the social proof counter activates only after **≥5 participants have verified their receipt**. This threshold (rather than the originally considered ≥10) was chosen because at the expected pilot sample size (N = 80), a floor of 10 would not be reached at the conservative baseline verification rate (10% × 80 = 8 verifications). A floor of 5 avoids negative social proof from a "0 verified" display while remaining reachable at the conservative baseline. The floor value (5) is the pre-registered design parameter; it will not be changed after registration.

**Option B — Revert analysis script floor to ≥10 (matches pre-reg; simple but riskier)**  
Keep pre-reg floor=10. Revert the three occurrences in `piup-study3-analysis.R` (lines 119, 124, 431–438) from `≥5` to `≥10`. Note: at p₁=0.10, N=80, this means manipulation failure is the modal outcome (~65% probability). Add explicit disclosure (Option C wording) to §3.2.

**Option A is preferred**: it matches what the analysis script already implements, is pre-registerable as the design floor, and the quality check recommended it.

---

## ✅ Drycheck status

| Section | Content | Status |
|---|---|---|
| 1 | §7.1 Primary logistic regression (DV1 ~ Condition + DV2 + M1) | ✅ PASS |
| 2 | §7.2 SA-1: Partial-verifier sensitivity (exclude partial verify failures) | ✅ PASS |
| 3 | §7.3 SA-2: Per-protocol opt-in log subsample | ✅ PASS |
| 4 | (drycheck §4 — intermediate bookkeeping) | ✅ PASS |
| 5 | §7.8 SA-3: DV2 timing heterogeneity (drop DV2 covariate) | ✅ PASS |
| 6 | §7.4 Exploratory: self-efficacy moderation + tertile stratification | ✅ PASS |
| 7 | §7.5 Exploratory: comprehension by condition (DV3 χ²) | ✅ PASS |
| 8 | §7.6 Descriptive: Kaplan-Meier survival (time-to-verify; 45 log opt-in events) | ✅ PASS |

**All 8 sections PASS. Drycheck committed at:** `624d92e` (tick-4406)  
**Drycheck data design:** N=140 block structure (not purely random); guarantees all code paths exercised regardless of seed. SA-1 path exercised with 5 synthetic partial-verifier failures; SA-2 log-opt-in subsample run; SA-3 DV2 exclusion comparison run; §7.6 KM threshold (≥40 events) met with 45 synthetic log opt-ins.

---

## 🛠️ Script version (pinned)

| File | Commit | Tick |
|---|---|---|
| `analysis/piup-study3-analysis.R` | `b9cdb3f` (analysis.R creation) | tick-4405 |
| `analysis/piup-study3-drycheck.R` | `624d92e` (drycheck creation + PASS) | tick-4406 |
| `docs/piup-study3-osf-prereg-2026-07-01.md` | `624d92e` (most recent tag) | tick-4406 |

Any changes to `piup-study3-analysis.R` after OSF upload must be logged in the amendments section of the pre-registration.

---

## Required packages

| Package | Version tested | Purpose |
|---|---|---|
| `dplyr` | R 4.3.3 | Data wrangling |
| `broom` | R 4.3.3 | `tidy()` on `glm` objects |
| `survival` | R 4.3.3 | `survfit`, `Surv` (§7.6 KM) |

Optional (not required for core analysis):
- `survminer`: ggsurvplot (KM visualisation only)

All required packages confirmed installed at drycheck (R 4.3.3).

---

## Known issues (expected at real N)

| Issue | Cause | Status at real N |
|---|---|---|
| M1 Cronbach's α at pilot N | Synthetic item correlations random | Recheck after pilot; α should improve with real responses |
| IRR (Cohen's κ) N/A for Study 3 | No open-text coding DV in Study 3 (no Q-OE) | Not a concern; Study 3 uses quantitative DVs only |
| Late-voter DV2 post-treatment | Participants who vote after counter floor is reached see counter before DV2 | Pre-registered in §5 + §7.8 SA-3; handled |
| KM threshold not met at pilot N | At N=80 with 10% verification rate, 8 log opt-ins < 40 threshold | Expected at pilot; survival analysis will not run; descriptives only |

---

## Pre-pilot gate status (Study 3)

| Gate item | Status | Notes |
|---|---|---|
| Analysis script drycheck | ✅ PASS (all 8 sections) | Commit 624d92e, tick-4406 |
| Required packages installed | ✅ (dplyr, broom, survival) | R 4.3.3 |
| Pre-reg quality check | ✅ Run (tick-4401); 2 issues found | Issue 2 + minor applied autonomously |
| DV2 timing note (§5) + SA-3 (§7.8) | ✅ Applied in pre-reg + analysis script | Tick-4401/4405 |
| **Counter floor (pre-reg vs. script)** | **✅ RESOLVED (tick-4408)** | **Option A applied: floor=5 in pre-reg §3.2, §7.7, checklist + analysis script** |
| Issue 1 counter floor calibration | ✅ RESOLVED (tick-4408) | Option A chosen: floor=5 everywhere; docs synced tick-4409 |
| OSF pre-registration upload | ⏳ Pending | Must be done AFTER counter floor resolved |
| Study 2 pre-registration filed first | ⏳ Pending | Study 3 registration checklist requires Study 2 pre-reg first |
| JONY-ACTION O (OSF Amendment 5) | ⏳ Pending | Shared prerequisite with Study 1; required before data collection |
| JONY-ACTION T (OSF Amendments 12–14) | ⏳ Pending | Shared prerequisite with Study 1; required before data collection |
| Deployment integration | ⏳ Pre-launch | Server-side randomisation, on-chain log opt-in, counter endpoint |
| Merged data format verified | ⏳ Pre-analysis | Confirm CSV column names match script header (`participant_id`, `condition`, `dv1_verified`, …) |
| `late_voter` flag derivation | ⏳ Pre-analysis | Must be derived from deployment logs before running script; documents which participants saw counter |
| DV5 opt-in CSV path | ⏳ Pre-analysis | Deployment system must export timestamped `verify_vote_counted()` calls per opt-in participant |

---

## Study 3 is embedded in the same election as Study 2

Study 3 is NOT a standalone study — it runs concurrently within the same real election deployment as Study 2:

- Condition assignment happens at T0 (server-side) for each voter
- The social proof counter is a live endpoint updated every 15 minutes from on-chain logs
- DV1, DV2, and DV5 all require coordination between the Aztec contract deployment and the receipt interface
- **Study 3 cannot run until the Aztec v5 contract is deployed and the receipt interface is live** (see VON-121: Umbra testnet deploy)

This means Study 3 shares all deployment prerequisites with Study 2 and adds:
1. The server-side randomisation layer (condition token in receipt session)
2. The social proof counter endpoint (reads on-chain logs every 15 min)
3. The `late_voter` flag derivation (requires timestamp comparison: voter T0 vs. counter floor reached time)

---

## Action items before Study 3 pilot launch

1. ~~**[JONY-CRITICAL] Resolve counter floor discrepancy**~~ — ✅ **DONE (tick-4408, Option A, floor=5).** Pre-reg §3.2+§7.7+checklist and analysis script all aligned at floor=5 (committed 7476a6f).
2. **File OSF amendments O + T** — shared prerequisite with Study 1; must precede data collection.
3. **File Study 2 pre-reg first** — Study 3 registration checklist requires Study 2 pre-reg to be on file.
4. **File Study 3 pre-reg** — after counter floor resolved and Study 2 pre-reg is filed.
5. **Deploy Aztec v5 contract** (VON-121) — shared prerequisite with Studies 2 and 3.
6. **Build condition assignment layer** — server-side coin flip at T0; condition encoded in receipt session token.
7. **Build social proof counter endpoint** — reads public `verify_vote_counted()` logs; updates every 15 min; activates after floor reached.
8. **Confirm merged data CSV schema** — ensure column names in the Prolific/on-chain merge match the script header (lines 27–41 of `piup-study3-analysis.R`).
9. **Confirm `late_voter` flag** — derive before analysis run using deployment log timestamps.
10. **Remove synthetic data stub** — lines 61–102 of `piup-study3-analysis.R` (the `df_raw <- data.frame(...)` block) must be replaced with the real data load path before running on real data.
