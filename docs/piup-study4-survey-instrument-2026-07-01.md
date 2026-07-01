# Survey Instrument: PIUP Study 4 — Temporal UI-Lock and Social Deniability Under Coercion Pressure

**Date:** 2026-07-01 (tick-4433)
**Author:** Jony Bursztyn
**Status:** Pre-pilot draft — to be uploaded to OSF alongside pre-registration before any data collection
**Companion documents:**
- [`docs/piup-study4-osf-prereg-2026-07-01.md`](piup-study4-osf-prereg-2026-07-01.md) — pre-registration (locks hypotheses and endpoints)
- [`docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`](piup-study4-temporal-coercion-vignette-2026-07-01.md) — full design rationale
- [`docs/qualtrics-setup-guide-study4-2026-07-01.md`](qualtrics-setup-guide-study4-2026-07-01.md) — click-by-click Qualtrics implementation guide
- [`docs/piup-study4-debrief-script-2026-07-01.md`](piup-study4-debrief-script-2026-07-01.md) — full debrief script (verbatim text for all screens)
- [`docs/prolific-setup-guide-study4-2026-07-01.md`](prolific-setup-guide-study4-2026-07-01.md) — Prolific configuration
- [`analysis/piup-study4-analysis.R`](../analysis/piup-study4-analysis.R) — pre-registered analysis script (variable names must match §10 codebook)

This document specifies the **exact question wording, answer options, scoring rubrics, and implementation notes** for Study 4. Study 4 is a **2×2 between-subjects vignette experiment** testing whether a temporal UI-lock on a vote receipt reduces coercion compliance. It is a single-session study with no follow-up.

Any change to pre-registered question wording, answer options, or scoring rubrics after OSF registration constitutes an amendment and must be logged in the pre-registration amendments table.

---

## §1 Overview

Participants are recruited through Prolific (US adults, English fluency, approval rate ≥ 95%) and randomly assigned to one of four between-subjects conditions via a Qualtrics Randomizer:

| Condition | UI condition | Pressure level |
|-----------|-------------|----------------|
| **D0P1** | Option D — countdown-only, download enabled | Moderate (colleague curiosity request) |
| **D0P2** | Option D — countdown-only, download enabled | High (manager job-threat) |
| **D1P1** | Option B — UI-lock, download disabled with padlock | Moderate (colleague curiosity request) |
| **D1P2** | Option B — UI-lock, download disabled with padlock | High (manager job-threat) |

**Procedure summary:**
1. Consent
2. Cover story + receipt display (static screenshot, ≥ 30 s enforced)
3. Comprehension check (DV3)
4. Vignette scenario (condition-branched)
5. Primary outcomes (DV1 → DV2, fixed order)
6. Moderator, covariates, attention check (randomised order within block)
7. Debrief (IRB-required; includes withdrawal option)

**Target N:** 160 (40 per cell; exclusions and replacements per pre-reg §4). Single Prolific study.
**Estimated time:** 8–10 minutes.

---

## §2 Survey Flow (Block-by-Block)

```
[Embedded Data — top-level]
  PROLIFIC_PID = ${e://Field/PROLIFIC_PID}
  attention_fail = 0
  receipt_label = ""
  pressure_label = ""
  withdrawn = FALSE

[Randomizer — evenly present one of 4 branches]
  Branch A: condition=D0P1, ui_cond=D0, pressure_cond=P1
             receipt_label="Countdown-only (Option D)"
             pressure_label="Moderate pressure (a colleague asking out of curiosity)"
  Branch B: condition=D0P2, ui_cond=D0, pressure_cond=P2
             receipt_label="Countdown-only (Option D)"
             pressure_label="High pressure (a manager threatening consequences)"
  Branch C: condition=D1P1, ui_cond=D1, pressure_cond=P1
             receipt_label="UI-lock (Option B)"
             pressure_label="Moderate pressure (a colleague asking out of curiosity)"
  Branch D: condition=D1P2, ui_cond=D1, pressure_cond=P2
             receipt_label="UI-lock (Option B)"
             pressure_label="High pressure (a manager threatening consequences)"

[Block 1: Consent]
[Block 2: Cover story + receipt display]       ← JavaScript page timer (min 30s, hard-blocks Next)
[Block 3: Comprehension check (DV3)]
[Block 4: Vignette scenario (condition-branched text)]
[Block 5: Primary outcomes — DV1 then DV2, fixed order]
[Block 6: Moderator + covariates + attention check — randomised order within block]

[Branch: QR6_ATTN ≠ 7 → attention_fail = 1 → Screen-Out block]
[Branch: Q_TotalDuration < 180 AND attention_fail = 0 → Screen-Out block]

[Block 7: Debrief (Screen 1 → Screen 2 → Screen 3 → Screen 4 withdrawal → Completion code)]
[End of Survey]
```

> **⚠ Randomiser order note:** The Randomizer must use **"Evenly Present Elements"** (not weighted randomisation) to ensure balanced cell assignment. The attention-fail branch **must appear after Block 6**; placing it before Block 6 means the flag is always 0 at that point and the branch never fires.

There are no in-survey screener questions for Study 4. Prolific handles screening at the platform level (approval rate ≥ 95%, US adults, English fluency). Participants who fail the attention check or timing criterion are excluded via screen-out redirect (not an in-survey screener).

---

## §3 Block 1: Consent (QR1)

*Displayed as a single scrolling page.*

**Question QR1_CONSENT (Descriptive Text + Button):**

---

**Consent to Participate in Research**

You are invited to participate in a research study about how people interact with digital voting systems. This study is conducted by [PI name and institution].

**What you will do:** You will be shown a screenshot of a digital voting confirmation screen and asked to read a short workplace scenario. The study takes approximately 8–10 minutes.

**Risks and benefits:** This research involves no more than minimal risk. You may withdraw at any time without penalty to your Prolific payment.

**Confidentiality:** Your Prolific ID is stored separately from your survey responses and will not appear in any publication. Results are reported in aggregate only.

**Payment:** You receive payment through Prolific at the rate shown on the study listing, regardless of your answers.

**Contact:** [IRB contact name and email]. For questions about your rights as a research participant, contact [University IRB email / phone].

By clicking **"I agree"** below, you confirm that you are at least 18 years old and consent to participate.

> ▶ Button: **"I agree — start the study"**
> ▶ Non-consent: redirect to Prolific Screen-Out URL via end-of-survey redirect.

---

> **Implementation note:** Qualtrics does not natively support a labelled "I do not consent" path on a consent button. Implement using a Multiple Choice question with one forced-response answer ("I agree to participate"). If the participant exits without selecting the answer, they do not proceed; the end-of-survey branch for non-consent catches any completion with QR1 unanswered. See `qualtrics-setup-guide-study4-2026-07-01.md §4` for implementation detail.

---

## §4 Block 2: Cover Story + Receipt Display (QR2)

### Page timing

A JavaScript page timer enforces a **hard minimum of 30 seconds** on this block: the Next button is disabled on page load and re-enabled only after the timer expires. Participants cannot advance until 30 seconds have elapsed. See `qualtrics-setup-guide-study4-2026-07-01.md §5` for the JavaScript implementation. The Qualtrics built-in Page Timer is not used here (it does not block advancement without scripting).

### Question QR2_COVER (Descriptive Text / Instructions)

*No response required — instruction block only.*

> Imagine you just finished voting in an online election run through a company governance platform. After submitting your vote, you were shown the following confirmation screen on your computer.
>
> **Please read the confirmation screen carefully.**

### Question QR2_STIMULUS (Image Display — condition-branched)

Display the appropriate static stimulus PNG using Display Logic:

| Display Logic | Image | Alt text |
|---------------|-------|---------|
| `ui_cond = D0` AND `pressure_cond = P1` | `cell-D0P1.png` | "Screenshot of a vote confirmation screen. A countdown reads 'Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes.' The download button is visible and enabled." |
| `ui_cond = D0` AND `pressure_cond = P2` | `cell-D0P2.png` | (same as D0P1) |
| `ui_cond = D1` AND `pressure_cond = P1` | `cell-D1P1.png` | "Screenshot of a vote confirmation screen. A padlock icon appears on the download button, labelled 'Locked until vote closes in 5d 3h 12m. After the vote closes you can download and share your receipt safely.'" |
| `ui_cond = D1` AND `pressure_cond = P2` | `cell-D1P2.png` | (same as D1P1) |

**Stimulus construction parameters** (held constant across all 4 stimuli):
- Countdown value: **"5 days 3 hours 12 minutes"**
- Receipt identifier: **fixed value** (same across all conditions)
- D0 stimuli: `<VoteReceipt voteCloseTimestamp={ts} />` — default Option D, download button enabled
- D1 stimuli: `<VoteReceipt temporalLock="lock" voteCloseTimestamp={ts} />` — Option B, download disabled + padlock icon

The P1/P2 split does not affect the receipt screenshot; the same D0 PNG is used for both D0P1 and D0P2. Separate files are listed only so that Qualtrics Display Logic can target each cell uniquely if needed.

> **Stimulus status (as of 2026-07-01):** VoteReceipt.tsx with `temporalLock="lock"` prop is implemented and TypeScript-clean (tick-4387). Static PNGs have not yet been exported. Use `<VoteReceipt temporalLock="lock" voteCloseTimestamp={ts} />` to render the D1 stimulus; export at 1280×720 or 800×600 viewport. See `docs/piup-study4-temporal-coercion-vignette-2026-07-01.md §13` for the stimulus construction checklist.

---

## §5 Block 3: Comprehension Check (QR3 / DV3)

*New page. No timer. Single question.*

### Question QR3_DV3 (Multiple Choice — Single Answer)

**Question text:**
> Based on what you saw, did the receipt you received tell you or anyone else how you voted?

**Answer options:**
| Option text | Code | Correct? |
|-------------|------|----------|
| Yes — the receipt showed how I voted | `yes` | ❌ |
| No — the receipt did not show how I voted | `no` | ✅ |
| I'm not sure | `not_sure` | ❌ |

**Scoring (Qualtrics Embedded Data):** After QR3_DV3:
- If QR3_DV3 = "No" → `comprehension_check_correct = 1`
- Else → `comprehension_check_correct = 0`

**Exclusion policy (pre-registered):** DV3 incorrect answers do **not** trigger screen-out. Participants who answer "Yes" or "Not sure" are retained in the intent-to-treat (ITT) primary analysis. They are flagged (`comprehension_check_correct = 0`) for a pre-registered sensitivity analysis (pre-reg §7.2). Only the attention check in Block 6 triggers hard exclusion.

**Pre-registered amendment trigger:** If DV3 incorrect-Yes rate exceeds 40% in any condition (indicating stimulus failure — participants believe the receipt reveals their choice), the pre-registration must be amended before unblinding condition assignments. Monitor aggregate DV3 counts during data collection.

---

## §6 Block 4: Vignette Scenario (QR4)

*New page. Receipt screenshot repeated at thumbnail size (≤ 400px width). Scenario text displayed below.*

### Question QR4_SCENARIO_INTRO (Descriptive Text)

> Now please re-read the confirmation screen below — you still have it open on your computer — and imagine the following situation:

### Question QR4_STIMULUS_REPEAT (Image Display)

Same Display Logic as Block 2. Use a reduced display size (max-width: 400px via Custom CSS or Qualtrics inline image size option) so the image and scenario text are both visible without scrolling.

### Question QR4_SCENARIO (Descriptive Text — pressure-branched)

Show the appropriate scenario using Display Logic on `pressure_cond`:

---

**P1 — Moderate pressure (show if `pressure_cond = P1`):**

> A colleague at work mentions they're trying to understand how the new voting system works. They ask: *"Hey, can you show me your vote receipt? I'm curious what it looks like."* You still have the vote receipt screen open on your computer.

---

**P2 — High pressure (show if `pressure_cond = P2`):**

> Your manager calls you in and says: *"We need to verify how our team voted on this issue. If you can't show me your vote receipt right now, I'll need to question your commitment to the team."* You still have the vote receipt screen open on your computer.

---

> **Implementation note:** Use two separate Descriptive Text questions, each with Display Logic gating on `pressure_cond`. Do not use Skip Logic — both questions should exist in the survey flow; only one renders per participant. This preserves data integrity for post-hoc auditing.

---

## §7 Block 5: Primary Outcomes (QR5)

*New page. DV1 presented first, DV2 second. Fixed order — do not randomise. Both items on the same page.*

**Pre-registration rationale for ordering:** DV1 (sharing intent) must be collected before DV2 (perceived deniability) to prevent the deniability framing in DV2 from priming DV1 responses. This ordering is locked and cannot be changed after OSF registration.

### Question QR5_DV1 — Sharing Intent (Primary Outcome)

**Question text:**
> If you were in this situation, how likely would you be to share the vote receipt screen with the person asking?

**Scale:** 1–7 Likert  
**Anchor 1:** Very unlikely  
**Anchor 7:** Very likely  
**Force response:** Yes

**Scoring:** Higher score = greater sharing intent = worse coercion resistance from the receipt design.

**Variable name (analysis script):** `dv1_sharing_intent` (integer 1–7, continuous in primary analysis)

**Hypothesis:** H4.1 (main effect D1 < D0), H4.2 (D × P interaction).

---

### Question QR5_DV2 — Perceived Deniability (Secondary Outcome)

**Question text:**
> If you were in this situation, how convincing do you think it would be to say *"I can't share this — my voting app won't let me until the vote closes"*?

**Scale:** 1–7 Likert  
**Anchor 1:** Not at all convincing  
**Anchor 7:** Very convincing  
**Force response:** Yes

**Scoring:** Higher score = greater perceived deniability = stronger structural excuse.

**Variable name (analysis script):** `dv2_perceived_deniability` (integer 1–7)

**Asymmetry note (pre-registered):** In D0 (countdown-only) cells, the download button is enabled — the claim "the app won't let me" is not literally true. DV2 in D0 cells measures *counterfactual* deniability (participants' imagined effectiveness of the excuse if the UI were locked). In D1 cells, DV2 measures *actual* deniability. This asymmetry is inherent to the design and will be acknowledged in the analysis (pre-reg §5).

**Hypothesis:** H4.3 (exploratory; D1 > D0 on DV2, one-tailed).

---

## §8 Block 6: Moderator, Covariates, Attention Check (QR6)

*New page. All three items presented in **randomised order** within this block (Qualtrics: enable question randomisation for Block 6). Randomisation ensures the attention check is not predictably positioned.*

### Question QR6_ATTN — Attention Check

**Question text:**
> For quality purposes, please select **Strongly agree** for this item.

**Scale:** 1–7 Likert  
**Anchor 1:** Strongly disagree  
**Anchor 7:** Strongly agree  
**Force response:** Yes

**Correct response:** 7 (Strongly agree).

**Exclusion logic (post-Block 6):** After Block 6, Qualtrics Survey Flow branch:
```
IF QR6_ATTN ≠ 7
  → Set attention_fail = 1
  → Jump to Screen-Out block (redirect to Prolific Screen-Out URL)
```
This participant is replaced until n = 40 per cell. The attention-fail branch **must** be placed after Block 6 in Survey Flow (not before), because `attention_fail` is initialised to 0 and only updated in post-Block-6 logic.

**Variable name:** `attention_fail` (0 = pass, 1 = fail; from Embedded Data)

---

### Question QR6_M1 — Technology Self-Efficacy (Moderator)

**Question text:**
> I am confident in my ability to troubleshoot technical problems with apps and websites.

**Scale:** 1–7 Likert  
**Anchor 1:** Strongly disagree  
**Anchor 7:** Strongly agree  
**Force response:** Yes

**Scoring:** Higher score = higher technology self-efficacy.

**Variable name (analysis script):** `m1_self_efficacy` (integer 1–7, continuous)

**Use:** Pre-registered moderator (H4.4 exploratory): high self-efficacy participants may imagine workarounds (e.g. screenshotting the receipt), attenuating the UI-lock's social-deniability advantage. Tested as a three-way D × P × M1 moderated regression; exploratory, no pre-specified α.

---

### Question QR6_C1 — Prior Voting App Experience (Covariate)

**Question text:**
> Have you ever used a digital voting platform (other than standard government voting — for example, for workplace decisions, a community group, or an online community)?

**Answer options:**
| Option | Code |
|--------|------|
| Yes | 1 |
| No | 0 |

**Force response:** Yes

**Variable name (analysis script):** `c1_prior_voting_exp` (binary 0/1)

**Use:** Covariate in pre-registered sensitivity analyses only. Not predicted to moderate primary outcomes. Rationale: familiarity with digital voting apps may reduce novelty-driven confusion about what a vote receipt is, potentially influencing DV3 comprehension rates.

---

## §9 Block 7: Debrief (QR7)

*IRB-required. No timer. Participants cannot go back after the debrief begins.*

This block appears in Survey Flow **after** the two exclusion branches (attention-fail and timing screen-out). Excluded participants are redirected to the Prolific Screen-Out URL and do not see the debrief.

**Full debrief text:** See `docs/piup-study4-debrief-script-2026-07-01.md` for the complete verbatim text of all screens. This document provides a structural summary only.

| Screen | Content | Response |
|--------|---------|----------|
| **Screen 1** | What this study was really about (cover story disclosure: social deniability + UI-lock design) | Descriptive text only; page break |
| **Screen 2** | Participant's assigned condition (receipt type and pressure level; pulled from Embedded Data `receipt_label` / `pressure_label`) | Descriptive text only; page break |
| **Screen 3** | Scenarios were hypothetical; reassurance about employer relationship; study does not imply participant is at risk of real coercion | Descriptive text only; page break |
| **Screen 4** | Data withdrawal option — participant can choose to have their data deleted | Yes / No withdrawal choice (QR7_WITHDRAW) |
| **Screen 5** | Thank you + Prolific completion code | Completion code displayed; survey ends |

### Question QR7_WITHDRAW — Data Withdrawal

*Displayed on Screen 4, after Screens 1–3.*

**Question text:**
> Now that you know the full study purpose, do you want your data to remain in the study?

**Answer options:**
| Option | Code | Action |
|--------|------|--------|
| Yes, I am happy for my data to be used | `keep` | Survey ends normally; completion code shown |
| No, I would like my data to be withdrawn | `withdraw` | Set `withdrawn = TRUE`; completion code still shown (payment unaffected) |

**Force response:** Yes

**Post-withdrawal action:** If `withdrawn = TRUE`, the participant's data is excluded from analysis. Payment is not withheld. Withdrawn responses are stored but flagged and not analysed. See `piup-study4-debrief-script-2026-07-01.md` Screen 4 for the full withdrawal UI text.

---

## §10 Codebook — Variable Names and Analysis Script Mapping

All variable names must match exactly to `analysis/piup-study4-analysis.R`.

| Variable | Type | Source | Range | Description |
|----------|------|--------|-------|-------------|
| `PROLIFIC_PID` | string | Embedded Data | — | Prolific participant ID (pseudonymous) |
| `condition` | factor | Embedded Data (Randomizer) | D0P1, D0P2, D1P1, D1P2 | Full condition cell |
| `ui_cond` | factor | Embedded Data (Randomizer) | D0, D1 | UI factor (D0=countdown-only, D1=UI-lock) |
| `pressure_cond` | factor | Embedded Data (Randomizer) | P1, P2 | Pressure factor (P1=moderate, P2=high) |
| `dv1_sharing_intent` | integer | QR5_DV1 | 1–7 | Primary outcome: sharing intent (lower = better coercion resistance) |
| `dv2_perceived_deniability` | integer | QR5_DV2 | 1–7 | Secondary outcome: perceived deniability of UI-lock excuse |
| `comprehension_check_correct` | binary | QR3_DV3 (derived) | 0, 1 | 1 if DV3 = "No" (correct); 0 otherwise |
| `m1_self_efficacy` | integer | QR6_M1 | 1–7 | Technology self-efficacy moderator |
| `c1_prior_voting_exp` | binary | QR6_C1 | 0, 1 | Prior digital voting experience (1=yes) |
| `attention_fail` | binary | QR6_ATTN (derived) | 0, 1 | 1 if attention check failed → exclusion |
| `withdrawn` | binary | QR7_WITHDRAW (derived) | FALSE, TRUE | Data withdrawn at debrief → exclude |
| `Q_TotalDuration` | integer | Qualtrics metadata | seconds | Total survey time; < 180 → exclusion |

**Exclusion derivation (pre-registered, matches analysis script §3):**

```r
excluded <- data %>%
  mutate(
    exclude = (attention_fail == 1) |
              (Q_TotalDuration < 180 & attention_fail == 0) |
              (withdrawn == TRUE)
  )
itt_data <- excluded %>% filter(!exclude)
```

DV3-incorrect participants (`comprehension_check_correct == 0`) are **retained** in `itt_data`. They are removed only in the pre-registered sensitivity analysis (SA-1).

---

## §11 Screen-Out Block

Excluded participants (attention fail or timing) are redirected to the Prolific Screen-Out URL. The screen-out block should display:

> **We are unable to include your response in this study.** This sometimes happens due to the time taken or a response pattern. Your participation is appreciated. You will be redirected shortly.

Followed by an automatic redirect to the Prolific Screen-Out URL. Timing screen-out redirects should fire after a 3-second delay.

---

## §12 Amendments

Any change to question wording, answer options, or scoring rules after OSF registration requires an amendment. Log amendments here and in the pre-registration amendments table (`piup-study4-osf-prereg-2026-07-01.md`).

| Amendment # | Date | Item changed | Change | Reason |
|-------------|------|-------------|--------|--------|
| — | — | — | — | No amendments at time of drafting |

---

## §13 Pre-OSF Checklist

Before uploading this instrument to OSF alongside the pre-registration:

- [ ] **IRB approval confirmed.** Do not collect data without IRB clearance. Study 4 is minimal risk; expedited review is likely feasible.
- [ ] **Stimulus PNGs exported.** Four files: `cell-D0P1.png`, `cell-D0P2.png`, `cell-D1P1.png`, `cell-D1P2.png`. See design doc §13 for construction parameters. Upload to Qualtrics Library before survey build.
- [ ] **[PI name / institution]** placeholder replaced in consent block (§3) and debrief script.
- [ ] **[IRB contact name and email]** placeholder replaced in consent block.
- [ ] **Qualtrics survey built and tested.** Follow `qualtrics-setup-guide-study4-2026-07-01.md` end-to-end. Test all 4 condition paths (D0P1, D0P2, D1P1, D1P2) including: page timer blocks Next before 30s; attention-fail branch fires; screen-out redirect works; debrief withdrawal records `withdrawn = TRUE`; completion code displays for non-withdrawn participants.
- [ ] **Prolific study created.** Follow `prolific-setup-guide-study4-2026-07-01.md`. Note the Screen-Out URL and Completion Code URL before Qualtrics build.
- [ ] **Analysis script dry-check passed.** Run `Rscript analysis/piup-study4-drycheck.R` — all sections must PASS. (Already confirmed: tick-4416, all 10 sections pass.)
- [ ] **OSF pre-registration filed.** `piup-study4-osf-prereg-2026-07-01.md` uploaded and registration locked (not just a draft) before any data collection begins.

---

_Created: 2026-07-01 (tick-4433). Synthesised from: `piup-study4-temporal-coercion-vignette-2026-07-01.md` (design + questions), `piup-study4-osf-prereg-2026-07-01.md` (pre-reg §§1–8), `qualtrics-setup-guide-study4-2026-07-01.md` (blocks 1–7), `piup-study4-debrief-script-2026-07-01.md` (Screen 1–5 structure), `piup-study4-analysis-readiness-2026-07-01.md` (codebook verification). Parallels: `piup-study1-survey-instrument-2026-06-22.md`, `piup-study2-survey-instrument-2026-06-28.md`, `piup-study3-survey-instrument-2026-07-01.md`._
