# PIUP Study 3 - Analysis Readiness Report

**Date:** 2026-07-01 (tick-4407)
**Reviewed:** `analysis/piup-study3-analysis.R`, `analysis/piup-study3-drycheck.R`
**Against:** `docs/piup-study3-osf-prereg-2026-07-01.md`, `docs/piup-study3-prereg-quality-check-2026-07-01.md`, `docs/piup-study3-social-verification-2026-06-29.md`
**Study type:** Two-arm between-subjects field experiment (SEPARATE live election from Study 2 — not concurrent; Study 2 uses a controlled Vercel prototype with Prolific participants, Study 3 uses a live Aztec contract with real DAO voters; paradigm corrected tick-4427/4429/4445)
**Reviewer:** Autonomous quality pass - not a substitute for Jony's review before OSF filing
**Status:** ✅ Counter floor resolved (tick-4408). ⚠️ Three pending Jony decisions before OSF filing: (1) DV3-3 item wording [tick-4437: Option DV3-3A vs. DV3-3B]; (2) DV3 scoring rule [tick-4437: Option A all-4-correct vs. Option B ≥3/4]; (3) M1-3 item wording [tick-4438: keep current vs. M1-3R refinement]. DV3 scoring block in analysis script ready but commented pending decisions. Paradigm corrected tick-4427/4439: Study 3 runs in a SEPARATE live election from Study 2 (not concurrent). Pre-reg §1 + §3.1 stale embedding language also fixed tick-4445 (see crosscheck Gaps 5+6).

---

## ✅ RESOLVED (tick-4408): Counter floor mismatch - pre-reg vs. analysis script

**Option A applied.** Pre-reg updated to floor=5 in §3.2, §7.7, and registration checklist. Analysis script already uses floor=5. No script change needed. Pre-reg commit: see tick-4408.

| Document | Counter floor (PRE-fix) | Counter floor (POST-fix tick-4408) | Location |
|---|---|---|---|
| `piup-study3-osf-prereg-2026-07-01.md` | ≥10 | **≥5** ✅ aligned | §3.2 and §7.7 |
| `piup-study3-analysis.R` | ≥5 | **≥5** ✅ (unchanged) | Lines 119, 124, 431-438 |
| `piup-study3-drycheck.R` | ≥5 | **≥5** ✅ (unchanged) | - |

### Why this happened

The pre-reg was drafted (tick-4400) with floor=10. The quality check (tick-4401, `docs/piup-study3-prereg-quality-check-2026-07-01.md`) found that at the conservative baseline (p1=0.10, N=80), expected verifications = 8 - below the floor. The check recommended lowering to ≥5 (Option A) or keeping 10 with explicit disclosure (Option C). The analysis script (tick-4405) was subsequently written with floor=5 (incorporating Option A), but the pre-reg was not updated to match.

### Consequence if left unresolved

If Jony files the pre-reg with floor=10, then runs the analysis script with floor=5, the deployment check message will say "≥5 verifications" while the filed pre-reg says "≥10." An OSF reviewer or IRB reviewer inspecting the script would notice the mismatch.

### Required Jony action - choose one:

**Option A - Lower pre-reg floor to ≥5 (matches analysis script; recommended by quality check)**
Update §3.2 and §7.7 in `piup-study3-osf-prereg-2026-07-01.md`. File with floor=5. No script change needed. Registration checklist item (line 240) update: "Counter floor value confirmed as **5**."

Pre-reg replacement text for §3.2 (floor paragraph):
> **Counter floor (pre-registered):** ... the social proof counter activates only after **≥5 participants have verified their receipt**. This threshold (rather than the originally considered ≥10) was chosen because at the expected pilot sample size (N = 80), a floor of 10 would not be reached at the conservative baseline verification rate (10% × 80 = 8 verifications). A floor of 5 avoids negative social proof from a "0 verified" display while remaining reachable at the conservative baseline. The floor value (5) is the pre-registered design parameter; it will not be changed after registration.

**Option B - Revert analysis script floor to ≥10 (matches pre-reg; simple but riskier)**
Keep pre-reg floor=10. Revert the three occurrences in `piup-study3-analysis.R` (lines 119, 124, 431-438) from `≥5` to `≥10`. Note: at p1=0.10, N=80, this means manipulation failure is the modal outcome (~65% probability). Add explicit disclosure (Option C wording) to §3.2.

**Option A is preferred**: it matches what the analysis script already implements, is pre-registerable as the design floor, and the quality check recommended it.

---

## ✅ Drycheck status

| Section | Content | Status |
|---|---|---|
| 1 | §7.1 Primary logistic regression (DV1 ~ Condition + DV2 + M1) | ✅ PASS |
| 2 | §7.2 SA-1: Partial-verifier sensitivity (exclude partial verify failures) | ✅ PASS |
| 3 | §7.3 SA-2: Per-protocol opt-in log subsample | ✅ PASS |
| 4 | (drycheck §4 - intermediate bookkeeping) | ✅ PASS |
| 5 | §7.8 SA-3: DV2 timing heterogeneity (drop DV2 covariate) | ✅ PASS |
| 6 | §7.4 Exploratory: self-efficacy moderation + tertile stratification | ✅ PASS |
| 7 | §7.5 Exploratory: comprehension by condition (DV3 χ2) | ✅ PASS |
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

## ⚠️ Pending Jony decisions (added tick-4444)

These items were identified in subsequent quality passes (ticks 4431, 4437, 4438) and must be resolved before OSF filing.

### DV3 scoring block — UNCOMMENT BLOCKED on two Jony decisions

The DV3 scoring block was added to `piup-study3-analysis.R` at tick-4431 (lines ~115–155). It is commented out pending:

**Decision 1: DV3-3 item wording (tick-4437, `docs/piup-study3-dv3-specification-2026-07-02.md`)**
- Option DV3-3A (recommended): *"If you verified your vote in front of another person, could they learn which option you voted for?"*
- Option DV3-3B (original): *"If you showed your receipt link to another person, could they learn which option you chose?"*

**Decision 2: DV3 scoring rule (tick-4437)**
- Option A (recommended): all-4-correct binary composite (`dv3_comprehension = q1 & q2 & q3 & q4`)
- Option B: majority-rule ≥3/4 correct (requires an additional SA sensitivity run)

**Decision 3: M1-3 item wording (tick-4438, `docs/piup-study3-m1-item-review-2026-07-02.md`)**
- Current: *"I could use the receipt verification link if I had brief written instructions available."*
- Refined M1-3R (recommended): *"I could use the receipt verification link if I had a short step-by-step guide to follow."*
- Issue with current: "brief written instructions" describes what the PIUP receipt already displays, potentially producing trivial endorsement rather than measuring self-efficacy under instructional scaffolding.

**Once all three decisions are confirmed by Jony:**
1. Update verbatim DV3-3 wording in `docs/piup-study3-survey-instrument-2026-07-01.md §5.2`
2. Update M1-3 (if M1-3R chosen) in `docs/piup-study3-survey-instrument-2026-07-01.md §3.3`
3. Uncomment lines ~143–155 of `piup-study3-analysis.R` (DV3 scoring block)
4. If Option B chosen: add SA block per script comment
5. File single OSF amendment: DV3 items + scoring rule + M1-3 wording

_Added: tick-4444 (2026-07-02)_

---

## Pre-pilot gate status (Study 3)

| Gate item | Status | Notes |
|---|---|---|
| Analysis script drycheck | ✅ PASS (all 8 sections) | Re-verified tick-4444 (2026-07-02) |
| Required packages installed | ✅ (dplyr, broom, survival) | R 4.3.3 |
| Pre-reg quality check | ✅ Run (tick-4401); 2 issues found | Issue 2 + minor applied autonomously |
| DV2 timing note (§5) + SA-3 (§7.8) | ✅ Applied in pre-reg + analysis script | Tick-4401/4405 |
| **Counter floor (pre-reg vs. script)** | **✅ RESOLVED (tick-4408)** | **Option A applied: floor=5 in pre-reg §3.2, §7.7, checklist + analysis script** |
| Issue 1 counter floor calibration | ✅ RESOLVED (tick-4408) | Option A chosen: floor=5 everywhere; docs synced tick-4409 |
| **DV3-3 item wording** | **⏳ JONY DECISION (tick-4437)** | **Option DV3-3A vs. DV3-3B; see `docs/piup-study3-dv3-specification-2026-07-02.md`** |
| **DV3 scoring rule** | **⏳ JONY DECISION (tick-4437)** | **Option A (all-4) vs. Option B (≥3/4); blocks DV3 scoring block uncomment** |
| **M1-3 item wording** | **⏳ JONY DECISION (tick-4438)** | **Current vs. M1-3R refinement; see `docs/piup-study3-m1-item-review-2026-07-02.md`** |
| Study 3 election paradigm | ✅ CORRECTED (tick-4427/4439) | Separate live election from Study 2 (not concurrent) |
| OSF pre-registration upload | ⏳ Pending | Must be done AFTER counter floor resolved |
| Study 2 pre-registration filed first | ⏳ Pending | Study 3 registration checklist requires Study 2 pre-reg first |
| JONY-ACTION O (OSF Amendment 5) | ⏳ Pending | Shared prerequisite with Study 1; required before data collection |
| JONY-ACTION T (OSF Amendments 12-14) | ⏳ Pending | Shared prerequisite with Study 1; required before data collection |
| Deployment integration | ⏳ Pre-launch | Server-side randomisation, on-chain log opt-in, counter endpoint |
| Merged data format verified | ⏳ Pre-analysis | Confirm CSV column names match script header (`participant_id`, `condition`, `dv1_verified`, ...) |
| `late_voter` flag derivation | ⏳ Pre-analysis | Must be derived from deployment logs before running script; documents which participants saw counter |
| DV5 opt-in CSV path | ⏳ Pre-analysis | Deployment system must export timestamped `verify_vote_counted()` calls per opt-in participant |

---

## Study 3 is a SEPARATE live election from Study 2 [corrected tick-4427/4439]

Study 3 is NOT embedded in the same election as Study 2 — they run in **separate live elections**:

- Study 2 is a controlled single-session Prolific experiment (T0 only; no live contract required; VoteReceipt.tsx hosted in study mode)
- Study 3 is a two-arm field pilot requiring a real Aztec election with on-chain logs
- Condition assignment for Study 3 happens at T0 (server-side) for each voter in the Study 3 election
- The social proof counter is a live endpoint updated every 15 minutes from on-chain logs for the Study 3 election
- DV1, DV2, and DV5 all require coordination between the Aztec contract deployment and the receipt interface
- **Study 3 cannot run until the Aztec v5 contract is deployed and the receipt interface is live** (see VON-121: Umbra testnet deploy)

Study 3 adds beyond Study 2 deployment:
1. The server-side randomisation layer (condition token in receipt session)
2. The social proof counter endpoint (reads on-chain logs every 15 min)
3. The `late_voter` flag derivation (requires timestamp comparison: voter T0 vs. counter floor reached time)

---

## Action items before Study 3 pilot launch

1. ~~**[JONY-CRITICAL] Resolve counter floor discrepancy**~~ - ✅ **DONE (tick-4408, Option A, floor=5).** Pre-reg §3.2+§7.7+checklist and analysis script all aligned at floor=5 (committed 7476a6f).
1a. **[JONY-DECISION] DV3-3 item wording** - choose Option DV3-3A or DV3-3B (tick-4437 decision memo). Needed before OSF filing.
1b. **[JONY-DECISION] DV3 scoring rule** - choose Option A (all-4) or Option B (≥3/4) (tick-4437). Needed before OSF filing.
1c. **[JONY-DECISION] M1-3 item wording** - confirm current or accept M1-3R refinement (tick-4438 decision memo). Needed before OSF filing.
2. **File OSF amendments O + T** - shared prerequisite with Study 1; must precede data collection.
3. **File Study 2 pre-reg first** - Study 3 registration checklist requires Study 2 pre-reg to be on file.
4. **File Study 3 pre-reg** - after counter floor resolved and Study 2 pre-reg is filed.
5. **Deploy Aztec v5 contract** (VON-121) - shared prerequisite with Studies 2 and 3.
6. **Build condition assignment layer** - server-side coin flip at T0; condition encoded in receipt session token.
7. **Build social proof counter endpoint** - reads public `verify_vote_counted()` logs; updates every 15 min; activates after floor reached.
8. **Confirm merged data CSV schema** - ensure column names in the Prolific/on-chain merge match the script header (lines 27-41 of `piup-study3-analysis.R`).
9. **Confirm `late_voter` flag** - derive before analysis run using deployment log timestamps.
10. **Remove synthetic data stub** - lines 61-102 of `piup-study3-analysis.R` (the `df_raw <- data.frame(...)` block) must be replaced with the real data load path before running on real data.
