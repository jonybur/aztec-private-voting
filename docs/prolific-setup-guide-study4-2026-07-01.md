# Prolific Study Setup Guide — PIUP Study 4

**Author:** Jony Bursztyn  
**Date:** 2026-07-01 (tick-4392)  
**Design doc:** [`docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`](piup-study4-temporal-coercion-vignette-2026-07-01.md)  
**Pre-registration:** [`docs/piup-study4-osf-prereg-2026-07-01.md`](piup-study4-osf-prereg-2026-07-01.md)  
**Qualtrics setup:** [`docs/qualtrics-setup-guide-study4-2026-07-01.md`](qualtrics-setup-guide-study4-2026-07-01.md)

---

## ⛔ Prerequisites — MUST complete before creating any Prolific study

- [ ] **OSF pre-registration filed and live.** File the pre-registration text from `piup-study4-osf-prereg-2026-07-01.md` as a new OSF component before launching any data collection. The timestamp must precede the first data point.
- [ ] **IRB exemption or approval confirmed.** Study 4 is a vignette experiment — minimal risk, no deception about real harm, no identifying data. Likely Category 4 exempt (benign behavior interventions). Confirm with your institutional review process before launching.
- [ ] **Qualtrics survey fully built and tested** (all 4 conditions; attention check; completion redirect; screen-out routing confirmed). Follow `qualtrics-setup-guide-study4-2026-07-01.md` first. The survey must correctly set the `condition` embedded data field from the URL parameter.
- [ ] **Four stimulus screenshots prepared** as inline images in Qualtrics:
  - `D0P1.png` — countdown-only + social request scenario
  - `D0P2.png` — countdown-only + job threat scenario
  - `D1P1.png` — UI-lock + social request scenario
  - `D1P2.png` — UI-lock + job threat scenario
- [ ] **Prolific account with funded balance.** For the pilot (N=40): budget ≈ £88 (40 × £1.80 + 33% Prolific fee ≈ £96 gross). For full study (N=160): budget ≈ £352 + fee ≈ £384 gross.

---

## Overview — 4 Separate Prolific Studies

You will create **four separate Prolific studies** (one per cell: D0P1, D0P2, D1P1, D1P2). This mirrors the Study 1 approach:

- Each cell fills its quota independently.
- You can pause, monitor, or close each cell separately.
- Clean audit trail: each Prolific study maps to exactly one experimental cell.
- Qualtrics receives the cell code via URL parameter (`condition=D0P1` etc.) and routes to the correct stimulus + vignette without any randomization logic in Qualtrics — Prolific controls the assignment.

Run all four simultaneously. Stimulus is fully inline in Qualtrics (no external host needed). The only difference between URLs is the `condition` parameter.

**Pilot configuration:** n = 10 per cell (total N = 40). Launch all 4 studies simultaneously; close each when its 10-participant quota is met.

**Full study configuration:** n = 40 per cell (total N = 160).

---

## Cell Reference

| Cell | UI condition | Pressure | Description |
|------|-------------|----------|-------------|
| D0P1 | No lock (countdown only) | Moderate (social request) | Colleague asks to see receipt |
| D0P2 | No lock (countdown only) | High (job threat) | Manager threatens job |
| D1P1 | UI-lock + countdown | Moderate (social request) | Colleague asks; app locked |
| D1P2 | UI-lock + countdown | High (job threat) | Manager threatens; app locked |

---

## Step 1 — Create the First Study (Cell D0P1)

1. Log in to **Prolific** → click **New Study**.
2. Select **Survey** as the study type.
3. Fill in the study details below.
4. After creating Cell D0P1, duplicate it three times and change only the condition code in the URL.

---

## Study Details

### Study name (internal — only you see this)

```
PIUP Study 4 — Cell D0P1 (no lock / social request)
PIUP Study 4 — Cell D0P2 (no lock / job threat)
PIUP Study 4 — Cell D1P1 (UI-lock / social request)
PIUP Study 4 — Cell D1P2 (UI-lock / job threat)
```

> Keep the cell description in the internal name so you can distinguish studies at a glance on the Prolific dashboard. The cell code (D0P1 etc.) matches the `condition` column in the Qualtrics export and the R analysis script.

---

### Study title (external — participants see this on the Prolific browse page)

```
Short Study: Decision-Making in a Workplace Scenario (8–10 min)
```

> Do **not** mention voting, receipts, UI-lock, coercion, or privacy in the external title. These words would prime participants before they read the vignette.

---

### Study description (participants see this)

Copy this text exactly:

```
In this short study, you will read a brief workplace scenario and answer questions 
about what you would do. No technical knowledge is required.

The study takes approximately 8–10 minutes and involves reading a scenario and 
answering multiple-choice questions. There are no right or wrong answers — we are 
interested in what feels realistic to you.

This study is part of research on how people make decisions in digitally-mediated 
workplace situations.
```

> This description is accurate and non-deceptive. It mentions decision-making in a workplace scenario (correct), does not reveal the voting/coercion context or the UI manipulation (acceptable for between-subjects design), and commits to the time estimate.

---

### Estimated time

```
10 minutes
```

> The Qualtrics guide estimates 8–10 min for the full flow (cover story + 30s page timer + 3 comprehension items + 2 primary DVs + moderator/covariate block + attention check + debrief). Use 10 minutes as the external estimate to avoid rushing.

---

### Reward per participant

```
£1.80
```

> At £1.80 for 10 minutes, the effective rate is £10.80/hr — above Prolific's £9/hr minimum. If median completion time in the pilot is consistently under 8 minutes, consider increasing to £2.00 to maintain ≥ £9/hr (paid on actual time, not estimated). If completion time is > 12 min, increase to £2.20.

---

## Step 2 — Eligibility Filters

### Language

```
English (fluent)
```

> All vignette text is in English; fluency is required to interpret the scenario correctly.

---

### Country

```
United States only
```

> Study 4 uses a job-threat vignette framed around US workplace norms (employment at will, HR dynamics). The scenario wording is calibrated for a US context. Pre-registration specifies US adults.

---

### Age

```
18 and above (no upper limit)
```

> No upper age bound in the pre-registration.

---

### Approval rate

```
≥ 95%
```

> Standard inattention screen. In Prolific: **Eligibility → Custom screeners → "Approvals" ≥ 95**.

---

### Other filters

**Do NOT set any additional filters:**

- **No employment sector filter** — Study 4 has no CS/SE exclusion criterion. The technical-background screener (SC2) from Studies 1 and 2 does not apply here: Study 4 tests coercion behavior under social pressure, not receipt-comprehension accuracy. Technical background is captured as covariate C1 (prior voting app experience), not as an exclusion.
- **No voting experience filter** — Unlike Study 1, Study 4 does not require prior online voting experience. Natural variation in voting familiarity is a covariate (C1) in the moderator analysis.
- **No occupation filters** — Prolific's occupation categories are too coarse for any useful pre-filtering here.

---

## Step 3 — Collect the Completion Code and Screen-Out Code

1. After creating the study, go to **Study settings → Completion**.
2. Copy the **completion URL**:
   ```
   https://app.prolific.com/submissions/complete?cc=XXXXXXXX
   ```
3. Prolific also provides a **screen-out code** for participants who are excluded mid-survey. Obtain the screen-out URL for each of the 4 studies:
   ```
   https://app.prolific.com/submissions/complete?cc=SCREENOUT_CODE
   ```
4. Enter both URLs into Qualtrics per `qualtrics-setup-guide-study4-2026-07-01.md` — the screen-out URL goes into the Screen-Out block; the completion URL goes into the end-of-survey redirect.

> **Codes differ per study.** Each duplicated study gets new completion and screen-out codes. Update Qualtrics accordingly (or use a single Qualtrics survey that reads the Prolific STUDY_ID to dispatch to the correct completion URL — see note below).

> **Single-survey approach (simpler):** Use a single Qualtrics survey with the condition code in the URL parameter. The completion redirect at the end of the survey can be a static Prolific completion URL shared across all 4 cells (Prolific accepts any valid completion code from any of its studies). Alternatively, route via embedded data: Store the Prolific completion URL as an embedded data field populated from the URL parameter, then redirect to it. This avoids managing 4 separate end-of-survey redirect URLs.

---

## Step 4 — Compose the Survey Link

For each cell, the Qualtrics survey link must include the condition parameter and Prolific URL variables:

**Template:**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=[CELLCODE]&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Cell D0P1 (no lock / social request):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=D0P1&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Cell D0P2 (no lock / job threat):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=D0P2&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Cell D1P1 (UI-lock / social request):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=D1P1&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Cell D1P2 (UI-lock / job threat):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=D1P2&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

> Replace `[YOUR_QUALTRICS_SURVEY_URL]` with the actual Qualtrics **anonymous survey link** (not the preview link): **Distributions → Anonymous Link**, e.g. `https://[org].qualtrics.com/jfe/form/SV_XXXXXXXXXX`.

> **`{{%PROLIFIC_PID%}}`** is replaced automatically by Prolific when a participant clicks through. Do not change this syntax.

---

## Step 5 — Enter the Survey Link in Prolific

1. On **Study → Survey link**, paste the full URL (with cell code and Prolific variables).
2. Prolific shows a preview with a test PID substituted. Verify it looks correct.
3. If Prolific warns that `{{%PROLIFIC_PID%}}` is not found, check the URL syntax.

---

## Step 6 — Create Studies D0P2, D1P1, D1P2 (Duplicate D0P1)

1. On the Prolific dashboard, open Cell D0P1.
2. Click **Duplicate study**.
3. In the duplicate, change only:
   - Internal name (e.g. "Cell D0P2 (no lock / job threat)")
   - Survey URL — change `condition=D0P1` to `condition=D0P2`
   - Places (n=10 pilot, n=40 full)
4. Repeat for D1P1 and D1P2.

> Each duplicated study gets a new Prolific completion code. If you are using cell-specific completion URLs in Qualtrics, update the redirect URL for each study. If using a shared completion URL approach, no change needed.

---

## Step 7 — Cross-Study Deduplication

For each study:

1. Go to **Study → Eligibility → Additional filters**.
2. Enable **"Exclude participants who have taken part in any of my other studies"** and select all 4 PIUP Study 4 studies (D0P1, D0P2, D1P1, D1P2).

> This ensures no participant can take more than one cell. Between-subjects contamination (a participant taking both the UI-lock and no-lock conditions) would invalidate the primary ANOVA.

> Prolific enforces deduplication at participant selection time, not just at completion. A participant in-progress on D0P1 cannot start D1P1.

> **Optionally** also exclude participants from Studies 1 and 2 (if running them concurrently). Study 4's coercion vignette and Study 1's receipt comprehension task test different constructs — cross-contamination risk is low — but exclusion is cleaner if your budget allows.

---

## Step 8 — Pre-Launch Checklist

### Qualtrics (complete first)

- [ ] Survey flow: Embedded Data (top) → Randomizer (4 cells) → [Block 1: Consent] → [Block 2: Receipt stimulus + 30s timer] → [Block 3: DV3 comprehension] → [Block 4: Vignette] → [Block 5: DV1 + DV2] → [Block 6: M1 + C1 + attention check] → [Branch: attention fail routing] → [Branch: completion time < 180s routing] → [Block 7: Debrief] → End
- [ ] `condition` embedded data set from URL parameter (`condition` field in Embedded Data block)
- [ ] Four stimulus images uploaded and Display-Logicked correctly (D0 stimulus for D0P1 and D0P2; D1 stimulus for D1P1 and D1P2)
- [ ] Vignette text Display-Logicked correctly (P1 text for D0P1 and D1P1; P2 text for D0P2 and D1P2)
- [ ] 30-second page timer JavaScript active on Block 2
- [ ] Attention check present in Block 6 (7-point Likert; correct = 7)
- [ ] Screen-out routing: attention fail branch and completion time < 180s branch both go to Prolific screen-out URL
- [ ] Completion redirect at end of survey goes to Prolific completion URL
- [ ] `PROLIFIC_PID`, `STUDY_ID`, `SESSION_ID` captured via embedded data from URL parameters
- [ ] `piup-study4-drycheck.R` PASS on synthetic data (N=200 confirmed passing — tick-4391)
- [ ] `piup-study4-analysis.R` ready in `analysis/` directory

### Prolific (from this guide)

- [ ] OSF pre-registration **live** (pre-reg text from `piup-study4-osf-prereg-2026-07-01.md` filed; OSF URL recorded)
- [ ] IRB exemption or approval confirmed in writing
- [ ] 4 studies created (D0P1, D0P2, D1P1, D1P2), each with correct condition URL
- [ ] Estimated time: 10 minutes
- [ ] Reward: ≥ £1.80 per participant
- [ ] English-fluent filter active
- [ ] US-only filter active
- [ ] Approval rate ≥ 95% filter active
- [ ] Cross-study deduplication enabled across all 4 studies
- [ ] Pilot quota: n=10 per study
- [ ] Completion URL and screen-out URL from Prolific entered into Qualtrics

### End-to-end test

1. Create a test Prolific submission in **test mode** (Prolific provides a dummy participant link).
2. Click through the survey as a participant in Cell D0P1.
   - Confirm the countdown-only stimulus appears.
   - Confirm the **social request** vignette appears below the receipt.
   - Confirm DV1 and DV2 scales appear on Block 5.
   - Confirm the attention check appears in Block 6.
   - Complete the survey → confirm redirect to Prolific completion URL.
3. Check the Qualtrics response: confirm `condition = D0P1`, `PROLIFIC_PID` populated, all DVs recorded.
4. Repeat for Cell D1P2 (UI-lock + job threat — the furthest cell from D0P1 in both factors).
5. Test a screen-out path: give an incorrect attention check response → confirm redirect to screen-out URL.

---

## Step 9 — After Pilot Launch: Monitoring

After launching the pilot (N=40, n=10 per cell):

1. **Check response rate at 24 hrs.** If < 50% of places filled in 48 hrs, increase reward to £2.00 or confirm the external title is appearing correctly (not showing "voting" or "coercion" in the description).
2. **Check median completion time** in Prolific submissions. Target: 8–12 min. If median > 15 min: the vignette or DV block has a usability issue. If median < 5 min: participants are rushing; check attention check failure rate.
3. **Check screen-out rate** in Qualtrics. Target: ≤ 15% (Study 4 has no SC1/SC2 screeners; screen-outs come only from attention check failure and time-based exclusion). If screen-out rate > 25%, investigate the attention check logic — confirm the Branch is placed **after** Block 6, not before.
4. **Check DV3 pattern** (comprehension check). In the pilot, if incorrect-Yes rate (participants believe the receipt shows their vote) exceeds 40% in any condition, the stimulus may be misleading. Per the pre-registration, flag this before unblinding condition assignments and file an amendment if needed.
5. **Download Qualtrics data** → run `piup-study4-drycheck.R` to confirm the column names and exclusion logic work on real data.
6. **Do not analyse H4 hypotheses on pilot data.** Pilot is for instrument validation only.

---

## Step 10 — Data Export Naming Convention

After closing the pilot or full study, export Qualtrics data as CSV and name the file:

```
piup-study4-raw-pilot-YYYY-MM-DD.csv      (pilot data)
piup-study4-raw-full-YYYY-MM-DD.csv       (full study data)
```

Save to `analysis/data/` (this directory is in `.gitignore` — raw participant data is never committed to the repo).

Run `piup-study4-drycheck.R` first, then `piup-study4-analysis.R`.

---

## Appendix — Prolific Study Configuration Summary (Pilot)

| Parameter | Value |
|-----------|-------|
| Study type | Survey |
| Number of studies | 4 (one per cell) |
| Internal names | PIUP Study 4 — Cell D0P1 / D0P2 / D1P1 / D1P2 |
| External title | "Short Study: Decision-Making in a Workplace Scenario (8–10 min)" |
| Estimated time | 10 minutes |
| Reward | £1.80 per participant (≥ £10.80/hr) |
| Places per study (pilot) | 10 |
| Places per study (full) | 40 |
| Language filter | English (fluent) |
| Country filter | United States only |
| Age filter | 18+ no upper bound |
| Approval rate filter | ≥ 95% |
| CS/SE exclusion | None (not applicable — Study 4 tests coercion behavior, not technical comprehension) |
| Voting experience filter | None (C1 covariate captures this in-survey) |
| Cross-study dedup | Enabled across all 4 cells |
| OSF pre-reg required | Yes — must be live before any data collection |
| IRB | Confirm exemption or approval before launch |

---

## Appendix — Design Notes for Study Setup Decisions

### Why no CS/SE exclusion (unlike Studies 1 and 2)?

Studies 1 and 2 use an SC2 screener to exclude CS/SE professionals because technical background predicts ceiling effects on Q4 (nullifier comprehension) — the specialist label "nullifier" may be correctly interpreted by programmers for domain-specific reasons rather than due to the PIUP framing. This creates a construct validity threat for Studies 1 and 2.

Study 4 does not have this problem. The outcome variables (DV1: sharing intent; DV2: perceived deniability) test social compliance behavior under adversarial pressure, not cryptographic comprehension. Technical self-efficacy (M1) is a pre-registered moderator — programmers may be *less* susceptible to the UI-lock excuse ("I can just screenshot it"). Including CS/SE participants in the full sample and testing M1 × D as a moderator is scientifically superior to excluding them.

### Why no voting experience filter?

Study 1 requires SC1 (prior online voting) because the study uses a real-looking vote receipt stimulus — unfamiliarity with voting receipts is a confound for receipt comprehension. Study 4 shows the same receipt type, but the primary outcome is behavioral (sharing intent), not comprehension. Prior voting experience is less likely to confound the sharing-intent response. It is captured as covariate C1 and its interaction with D is exploratory (pre-registered). Excluding non-voters would reduce ecological validity (non-voters facing coercion in a governance system are exactly the target population).

### Why US-only?

The job-threat vignette uses an employer-mandate framing that maps to US employment-at-will norms. In the UK and EU, employees have stronger legal protections against retaliation — the P2 vignette ("I'll need to question your commitment to the team") may not carry the same coercive force cross-culturally. US-only recruitment ensures the pressure manipulation is calibrated to the intended threat model.

---

## Appendix — Description for IRB/Ethics File (if needed)

> Participants will be recruited online via Prolific Academic. Eligible participants are English-speaking US adults (18+) with a Prolific approval rate of ≥ 95%. Participants will read a brief vignette about a workplace scenario involving a digital voting system and answer questions about their intentions and perceptions. No real vote is cast; the receipt is a static screenshot. Estimated time: 8–10 minutes. Compensation: £1.80 per participant (approximately £10.80/hour). No identifying information is collected beyond the pseudonymous Prolific participant ID. Risk level: minimal. The scenario involves a hypothetical workplace coercion situation; no real employer-employee relationship is involved. A full debrief is provided at the end of the survey, including the true purpose of the study and the nature of the UI manipulation.

---

*Created tick-4392. Companion to `qualtrics-setup-guide-study4-2026-07-01.md` and `piup-study4-osf-prereg-2026-07-01.md`.*
