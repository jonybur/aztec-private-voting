# Qualtrics Setup Guide — PIUP Study 3 (T+14 Follow-Up Survey)

**Author:** Jony Bursztyn  
**Date:** 2026-07-01 (tick-4435)  
**Instrument spec:** [`docs/piup-study3-survey-instrument-2026-07-01.md`](piup-study3-survey-instrument-2026-07-01.md)  
**Debrief script:** [`docs/piup-study3-debrief-script-2026-06-30.md`](piup-study3-debrief-script-2026-06-30.md)  
**Pre-registration:** [`docs/piup-study3-osf-prereg-2026-07-01.md`](piup-study3-osf-prereg-2026-07-01.md)

This is a click-by-click implementation guide for building the **Study 3 T+14 follow-up survey** in Qualtrics. The T+14 survey is delivered 14 days after ballot submission via a parameterised link sent through the DAO platform's native messaging. It is **not** a Prolific study — participants are real DAO voters who consented at T0.

**Key differences from Studies 1, 2, and 4:**
- No Prolific integration; no randomiser in Survey Flow. Condition is passed as a URL parameter at link delivery time.
- No stimulus images. Participants already voted 14 days ago; the focus is debrief and follow-up questions.
- No attention check (real voters — attention-check exclusion would be inappropriate; see pre-reg §6).
- Survey flow has a mandatory debrief and a withdrawal fork **before** any measures are collected.
- Estimated build time: 60–90 minutes.

---

## Prerequisites

Before starting the Qualtrics build:

- [ ] **Study 3 OSF pre-registration filed and live.** Do not run T+14 without a timestamped pre-registration.
- [ ] **IRB approval or exemption confirmed.** T+14 includes debrief of incomplete disclosure — confirm with IRB that the debrief procedure meets ethics requirements.
- [ ] **DV3 item wording confirmed by Jony.** The four DV3 items in `piup-study3-survey-instrument-2026-07-01.md §5.2` are a recommended draft — Jony must confirm before this survey is launched. Do not build the DV3 block until confirmed.
- [ ] **T0 data pipeline operational.** The T+14 survey must receive `participant_id` and `condition` from the receipt server's T0 record. Confirm the delivery mechanism before building the link.
- [ ] **Data deletion pipeline ready.** Screen 3 withdrawal triggers data deletion. The pipeline must be in place before any participant reaches T+14.
- [ ] **PI name / email / IRB details filled in.** Debrief Screen 4 has `[PI name]`, `[PI email]`, `[Institution]`, `[IRB protocol number]`, `[IRB contact]` placeholder fields that must be completed before the survey goes live.

---

## Overview — Survey Flow

The T+14 survey has **one branch point** (the withdrawal fork at Screen 3). All participants see the debrief first:

```
[Embedded Data block — top of Survey Flow]
  participant_id = from URL param
  condition = from URL param (A or B)
  condition_label = set by branch logic from condition

[Block 1 — Debrief Screen 1: Study Purpose]
[Block 2 — Debrief Screen 2: Why We Didn't Tell You Earlier]
[Block 3 — Debrief Screen 3: Withdrawal Decision]

[Branch: if withdrawal == "yes"]
  → [Block 4b — Withdrawal Confirmation Screen]
  → End of Survey (survey exit)

[Branch: if withdrawal == "no" OR unanswered]
  → [Block 4a — Transition screen]
  → [Block 5 — DV3: Verification Comprehension (4 items)]
  → [Block 6 — DV4: Receipt Trust/Affect (2 items)]
  → [Block 7 — C1: Open-ended reason]
  → [Block 8 — Debrief Screen 4: Contact + Privacy Reminder]
  → [Block 9 — Closing Screen]
```

---

## §1 — Survey Settings

In Qualtrics: **Survey Options → General:**
- Anonymous link: Yes. Identifying data is not collected; `participant_id` is a pseudonymous receipt ID, not the participant's name or email.
- Survey expiration: Set to day 21 post-election (i.e., 7 days after T+14). Responses received after day 21 are excluded per pre-reg §6.

**Survey Options → Security:**
- Prevent ballot box stuffing: Yes (prevents one participant from completing twice using the same link).
- Bot detection / reCAPTCHA: optional (participants are real DAO voters following a personalised link; bot risk is lower than a Prolific study).

**Survey Options → Responses:**
- Record timing: Yes (useful for quality inspection, though no timing-based exclusion is pre-registered for T+14).
- Save incomplete responses: Yes.

**Survey Options → Texts:**
- Back button: Disabled. Once a participant selects withdrawal on Screen 3, they should not be able to navigate back to re-answer it.

---

## §2 — Embedded Data (Survey Flow, top)

In Survey Flow, add an **Embedded Data** element at the very top (before any blocks):

| Field name | Set to | Notes |
|------------|--------|-------|
| `participant_id` | `${e://Field/participant_id}` | Passed as URL parameter by link delivery system |
| `condition` | `${e://Field/condition}` | `A` or `B`, passed as URL parameter |
| `condition_label` | (set by branch logic below) | Human-readable: "Group A" or "Group B" |
| `withdrawal` | `0` | Default = 0 (not withdrawn); set to `1` if participant selects withdrawal |

**Setting `condition_label` from `condition`:**

In Survey Flow, after the Embedded Data block, add a **Branch** element:

```
IF condition = "A"
  → Set condition_label = "Group A (standard receipt)"

IF condition = "B"
  → Set condition_label = "Group B (receipt with verification count)"
```

`condition_label` is used by Qualtrics piped text in Debrief Screen 1.

**T+14 survey link format:**

```
https://[your-qualtrics-domain]/jfe/form/[SurveyID]?participant_id=[RECEIPT_ID]&condition=[A_or_B]
```

Prepare one personalised link per participant at the time of T+14 delivery. If using a mail-merge or platform notification system, the `participant_id` and `condition` fields are populated from the T0 consent record.

---

## §3 — Debrief Screen 1 (Block 1)

**Block type:** Text/Graphic (no response required — static text)

**Block name:** `Debrief_Screen1_Purpose`

**Text to enter in Qualtrics rich-text editor:**

*(Use the verbatim text from `piup-study3-debrief-script-2026-06-30.md §Screen 1`. Key implementation notes below.)*

> **Thank you for participating in this research.**
>
> Before we ask you a few final questions, we want to tell you more about the study you have been part of.
>
> **What this study is about:**
>
> This study is examining how voters decide whether to verify that their vote was counted after an election. One of the questions researchers find interesting is: does it matter to people to know that *other voters* are also verifying? Could seeing that others have verified encourage someone who might not have thought to do it themselves?
>
> **What we were actually studying:**
>
> When you cast your vote in this election, you were randomly assigned to one of two groups:
>
> - **Group A (about half of participants):** Your vote receipt showed the standard receipt with no additional information.
> - **Group B (about half of participants):** Your vote receipt included a line showing how many voters in this election had already attempted to verify their vote.
>
> **You were in ${e://Field/condition_label}.**
>
> The two receipts were otherwise identical: both contained the same verification information, both linked to the same verification page, and both were privacy-preserving.

**Qualtrics implementation:**

- In the rich-text editor, insert the piped text for condition: click **Piped Text → Embedded Data → condition_label**. This renders as `${e://Field/condition_label}` in source and shows "Group A (standard receipt)" or "Group B (receipt with verification count)" to the participant.
- No question, no response options. This is a text block with a **Next** button only.
- Add a **Page Break** after this block.

---

## §4 — Debrief Screen 2 (Block 2)

**Block type:** Text/Graphic (no response required — static text)

**Block name:** `Debrief_Screen2_WhyNotTold`

**Text to enter verbatim:**

> **Why we didn't tell you about the two groups at the start:**
>
> We didn't mention the two-group design at the time of your vote because knowing about it might have changed how you behaved. If you had known we were studying whether the "other voters have verified" display affects behavior, you might have verified (or not verified) differently — not because of the display itself, but because of your awareness of being in a study. Researchers call this a *demand effect*, and it can make study results difficult to interpret.
>
> This kind of incomplete disclosure is common in behavioural research when the act of explaining the study would change the behavior being studied. Your consent form accurately described the study as research on how voters use their receipts; the specific detail of the two-group design was withheld temporarily to protect the integrity of the findings.
>
> **The count was real:**
>
> If you were in Group B, the counter you saw showed the actual number of voters who had attempted verification — not a simulated or inflated number. Showing a genuine social signal (rather than a fabricated one) was important both ethically and scientifically.

**Qualtrics implementation:**
- Text block only. **Next** button.
- Page Break after.

---

## §5 — Debrief Screen 3: Withdrawal Decision (Block 3)

**Block type:** Multiple Choice — single answer, vertical layout

**Block name:** `Debrief_Screen3_Withdrawal`

**Question text (displayed above options):**

> **You have the right to withdraw your data.**
>
> Now that you know the full nature of the study, you can choose to withdraw your participation data entirely. If you withdraw, all responses you have provided (T0 and T+14) will be deleted from our dataset and will not appear in any analysis or publication.
>
> Withdrawing will not affect you in any way. There are no penalties for withdrawing.
>
> **Do you wish to withdraw your data from this study?**

**Answer options:**

| Option text | Qualtrics recode value | Variable |
|-------------|----------------------|---------|
| No — I'm happy for my responses to be used. Continue to the final questions. | 1 | `withdrawal = 0` |
| Yes — Please delete my data. My responses will not be used. | 2 | `withdrawal = 1` |

**Settings:**
- Force response: Yes (participants must select one option to proceed).
- Display order: Fixed (not randomised).

**Back button:** Disable for this question only (**Question Settings → Prevent Back Button**). Participants who choose withdrawal should not be able to reverse it via the back button.

**After this block — set Embedded Data from response:**

In Survey Flow, add an **Embedded Data** set block immediately after Block 3:

```
withdrawal = ${q://QID_withdrawal/ChoiceNumericEntryValue}
```

Where `QID_withdrawal` is the internal Qualtrics question ID for the Screen 3 withdrawal question. Check the actual question ID in the Survey Flow after saving Block 3.

---

## §6 — Survey Flow Branch: Withdrawal Fork

After Block 3 (Debrief Screen 3) and the withdrawal embedded data set, add a **Branch** in Survey Flow:

**Branch logic:**

```
IF withdrawal == 2 (i.e., participant selected "Yes — withdraw my data")
  → Display Block 4b: Withdrawal Confirmation Screen
  → End of Survey (use "End Survey" element in Survey Flow)

ELSE (withdrawal == 1 or missing — default to continue)
  → Continue to Block 4a: Transition Screen
  → Continue through remaining blocks
```

**Survey Flow excerpt:**

```
[Embedded Data] participant_id, condition, condition_label, withdrawal=0

[Branch] condition == "A" → set condition_label = "Group A (standard receipt)"
[Branch] condition == "B" → set condition_label = "Group B (receipt with verification count)"

[Block 1] Debrief_Screen1_Purpose
[Block 2] Debrief_Screen2_WhyNotTold
[Block 3] Debrief_Screen3_Withdrawal
[Embedded Data] withdrawal = ${q://QID_withdrawal/ChoiceNumericEntryValue}

[Branch] withdrawal == 2
  → [Block 4b] Withdrawal_Confirmation
  → End Survey

[Block 4a] Transition_Screen
[Block 5] DV3_Comprehension (4 items)
[Block 6] DV4_Trust (2 items)
[Block 7] C1_OpenEnded
[Block 8] Debrief_Screen4_Contact
[Block 9] Closing_Screen
```

---

## §7 — Block 4b: Withdrawal Confirmation Screen

**Block type:** Text/Graphic (displayed only to participants who selected withdrawal)

**Block name:** `Withdrawal_Confirmation`

**Text:**

> **Your data withdrawal has been recorded.**
>
> Your T0 and T+14 responses will be deleted within 48 hours. You will receive a confirmation email at the address you provided when you registered for the study.
>
> Thank you for your time. You are free to close this window.

**Qualtrics implementation:**
- Text block only. No Next button — use **End of Survey** element in Survey Flow immediately after this block.
- Customise the End of Survey message to say: "Your withdrawal has been recorded. You may close this window."

---

## §8 — Block 4a: Transition Screen

**Block type:** Text/Graphic (displayed only to non-withdrawing participants)

**Block name:** `Transition_Screen`

**Text:**

> **Survey: Vote receipt research — follow-up questions**
>
> Thank you for agreeing to continue. The following questions take approximately 3–5 minutes.
>
> *Please answer from your current understanding of the voting system — not from the information in the debrief you just read. We are measuring what you had learned by the time you voted, not what you have just been told.*

**Qualtrics implementation:** Text block only. Next button.

---

## §9 — Block 5: DV3 — Verification Comprehension (4 items)

> ⚠️ **Do not build this block until Jony confirms DV3 item wording.** The items below are the recommended draft from `piup-study3-survey-instrument-2026-07-01.md §5.2`. They require Jony's approval before OSF filing and survey launch.

**Block name:** `DV3_Comprehension`

**Preamble (Text/Graphic question before DV3 items):**

> *The following questions are about the vote verification feature you were offered after submitting your ballot. Please answer based on your understanding.*

---

**DV3-1 (Multiple Choice, single answer, vertical)**

Question text:

> *"Does verifying your receipt confirm that your vote was counted?"*

Options:

| Text | Code | Correct |
|------|------|---------|
| Yes | 1 | ✅ |
| No | 2 | ❌ |
| I'm not sure | 3 | ❌ |

**Variable name in export:** `dv3_q1`  
Force response: Yes.

---

**DV3-2 (Multiple Choice, single answer, vertical)**

Question text:

> *"If you verify your receipt, does that reveal which option you voted for?"*

Options:

| Text | Code | Correct |
|------|------|---------|
| Yes | 1 | ❌ |
| No | 2 | ✅ |
| I'm not sure | 3 | ❌ |

**Variable name:** `dv3_q2`  
Force response: Yes.

---

**DV3-3 (Multiple Choice, single answer, vertical)**

Question text:

> *"If you showed your receipt link to another person, could they learn which option you chose?"*

Options:

| Text | Code | Correct |
|------|------|---------|
| Yes | 1 | ❌ |
| No | 2 | ✅ |
| I'm not sure | 3 | ❌ |

**Variable name:** `dv3_q3`  
Force response: Yes.

---

**DV3-4 (Multiple Choice, single answer, vertical)**

Question text:

> *"What does successful verification prove about your vote?"*

Options:

| Label | Code | Correct |
|-------|------|---------|
| (a) That I voted for the winning option | 1 | ❌ |
| (b) That my vote was included in the tally — but not which option I chose | 2 | ✅ |
| (c) That the voting system recorded my vote choice | 3 | ❌ |
| (d) I'm not sure what verification proves | 4 | ❌ |

**Variable name:** `dv3_q4`  
Force response: Yes.  
Display order: Fixed (a–d in order; do not randomise).

**DV3 scoring note for Qualtrics export:**

Qualtrics will export raw choice codes (1, 2, 3) for DV3-1 through DV3-3 and (1, 2, 3, 4) for DV3-4. The scoring derivation (all-correct composite → `dv3_comprehension`) is computed in `analysis/piup-study3-analysis.R` — do not build scoring logic in Qualtrics. Ensure the exported column names match the codebook variable names (`dv3_q1`, `dv3_q2`, `dv3_q3`, `dv3_q4`); rename in Qualtrics → Data & Analysis → Edit Column Labels if needed.

---

## §10 — Block 6: DV4 — Receipt Trust/Affect (2 items)

**Block name:** `DV4_Trust`

**DV4-1 (Matrix/Likert or Single-Answer Horizontal, 7-point)**

Question text:

> *"The receipt convinced me my vote was counted."*

Scale (7-point, strongly disagree → strongly agree):

| Label | Code |
|-------|------|
| Strongly disagree | 1 |
| (unlabelled) | 2 |
| (unlabelled) | 3 |
| Neither agree nor disagree | 4 |
| (unlabelled) | 5 |
| (unlabelled) | 6 |
| Strongly agree | 7 |

**Variable name:** `dv4_trust1`  
Force response: Yes.

---

**DV4-2 (same format)**

Question text:

> *"I understand what the receipt is for."*

Same 7-point scale.

**Variable name:** `dv4_trust2`  
Force response: Yes.

**Implementation option:** Use a **Matrix Table** question with DV4-1 and DV4-2 as two rows on the same 7-point scale. This is cleaner visually and reduces vertical scroll. If using a matrix: label columns 1–7 with "Strongly disagree" at 1 and "Strongly agree" at 7; label the two rows with the question text.

**Export note:** If using a matrix, Qualtrics typically exports columns as `[QID]_1` and `[QID]_2`. Rename to `dv4_trust1` and `dv4_trust2` in Data & Analysis → Edit Column Labels before download.

---

## §11 — Block 7: C1 — Open-Ended Reason

**Block name:** `C1_OpenEnded`

**Question type:** Text Entry (long text / paragraph)

**Question text:**

> *"Did you come back to verify your receipt after voting? Please tell us why or why not. There is no right or wrong answer."*

**Settings:**
- Minimum character count: 10 (prevents accidental empty submission).
- Force response: Yes.
- Text box size: Large (multi-line — participants may write several sentences).

**Variable name:** `c1_reason`  
Export as raw text (string). Do not score in Qualtrics. Qualitative coding is performed post-collection by two independent coders.

---

## §12 — Block 8: Debrief Screen 4 (Privacy Reminder + Contact)

**Block type:** Text/Graphic

**Block name:** `Debrief_Screen4_Contact`

**Text (verbatim from debrief script Screen 4 — fill placeholders before launch):**

> **A note about your privacy:**
>
> This study does not record or store your individual vote. The study cannot determine how you voted. The only information collected is:
>
> - Whether you attempted to verify your vote (from our study platform, not from the blockchain or your wallet)
> - Your survey responses about verification (this survey)
> - If you opted in to behavioral logging: whether and when the `verify_vote_counted()` function was called via your receipt link
>
> The social proof counter (shown to Group B participants) was maintained by the study platform (a lightweight serverless backend), not derived from blockchain logs. The platform recorded only the aggregate number of verification attempts — no receipt IDs, wallet addresses, or vote choices were retained in the counter log.
>
> _[Architecture correction (tick-4456, companion to pre-reg §3.2 amendment tick-4453 and §5/§7 amendments tick-4454): The original text said the counter was derived from "public smart contract logs." This is architecturally incorrect. `verify_vote_counted()` is a view function; it leaves no on-chain record. The correct architecture — host-side serverless backend logging only the aggregate count — was established in the pre-reg amendments (ticks 4452–4455). This debrief text now matches. The participant-facing privacy guarantee is identical: no individual voter is identifiable from the counter.]_
>
> **Questions or concerns:**
>
> If you have questions about this study, how your data is used, or if you want to withdraw your data after completing this survey, please contact:
>
> **Principal investigator:** [PI name]  
> **Email:** [PI email]  
> **Institution:** [Institution]  
> **IRB protocol number:** [IRB protocol number]
>
> You may also contact the IRB office directly at [IRB contact] if you have concerns about your rights as a research participant.

**⚠️ Fill all `[...]` fields before the survey goes live.**

---

## §13 — Block 9: Closing Screen

**Block type:** End of Survey message (or Text/Graphic block before End of Survey)

**Text:**

> **Thank you for completing the survey.**
>
> Your responses have been recorded. You may close this window.
>
> This study is investigating whether public information about how many other voters verified their receipts affects people's likelihood of verifying their own receipt. Your participation contributes to research on usable privacy-preserving voting systems.
>
> If you have questions about the study or your data, contact: **[PI email]**

---

## §14 — Survey Flow: Final Structure (complete)

```
[Embedded Data]
  participant_id   = ${e://Field/participant_id}
  condition        = ${e://Field/condition}
  condition_label  = (set below)
  withdrawal       = 0

[Branch] condition == "A"
  Embedded Data: condition_label = "Group A (standard receipt)"

[Branch] condition == "B"
  Embedded Data: condition_label = "Group B (receipt with verification count)"

[Block 1] Debrief_Screen1_Purpose       ← piped condition_label
[Block 2] Debrief_Screen2_WhyNotTold
[Block 3] Debrief_Screen3_Withdrawal    ← Q: Yes/No withdrawal

[Embedded Data]
  withdrawal = ${q://QID_withdrawal/ChoiceNumericEntryValue}

[Branch] withdrawal == 2
  [Block 4b] Withdrawal_Confirmation
  End Survey

[Block 4a] Transition_Screen
[Block 5]  DV3_Comprehension (4 items: dv3_q1–dv3_q4)
[Block 6]  DV4_Trust (2 items: dv4_trust1, dv4_trust2)
[Block 7]  C1_OpenEnded (c1_reason)
[Block 8]  Debrief_Screen4_Contact
[Block 9]  Closing_Screen / End Survey
```

---

## §15 — Export Column Naming

Before downloading data, go to **Data & Analysis → Edit Column Labels** and confirm these column names match the codebook (instrument §10):

| Qualtrics default export label | Required codebook name | Notes |
|-------------------------------|----------------------|-------|
| `participant_id` | `participant_id` | Embedded Data field |
| `condition` | `condition` | A or B |
| `withdrawal` | `withdrawal` | 0 or 1 (recode from 1/2) |
| DV3-1 column | `dv3_q1` | Rename in Data & Analysis |
| DV3-2 column | `dv3_q2` | Rename |
| DV3-3 column | `dv3_q3` | Rename |
| DV3-4 column | `dv3_q4` | Rename |
| DV4-1 column | `dv4_trust1` | Rename (or from Matrix row 1) |
| DV4-2 column | `dv4_trust2` | Rename (or from Matrix row 2) |
| C1 text column | `c1_reason` | Rename |

**Download format:** CSV (numeric recode). Qualtrics exports raw choice codes by default — this matches the expected input format for `analysis/piup-study3-analysis.R`. Do not request "choice text" format.

**Withdrawal variable recode:** The analysis script expects `withdrawal = 0` (continue) or `withdrawal = 1` (withdrawn). Qualtrics will export `2` for the "Yes — withdraw" option. Add a recode step in the R data-prep block:

```r
df$withdrawal <- ifelse(df$withdrawal_raw == 2, 1, 0)
```

Or set up a Qualtrics recode (Question → Recode Values) to map "2 → 1" and "1 → 0" before export.

---

## §16 — Pre-Launch Checklist

Before sending the T+14 link to any participant:

- [ ] **DV3 item wording confirmed by Jony** (instrument §5.2 decisions DV3-A, DV3-B, M1-W).
- [ ] **IRB placeholders filled** (`[PI name]`, `[PI email]`, `[Institution]`, `[IRB protocol number]`, `[IRB contact]`) in Block 8 and Block 9.
- [ ] **OSF pre-registration filed and live** (timestamped before any T0 data collection).
- [ ] **Survey Flow tested** with `?participant_id=TEST001&condition=A` and `?condition=B`. Confirm `condition_label` pipes correctly in Screen 1 for both conditions.
- [ ] **Withdrawal fork tested**: select "Yes — withdraw" → confirm Block 4b appears, Block 5–9 are skipped, End Survey fires.
- [ ] **Export column names confirmed** (rename in Data & Analysis before any real data).
- [ ] **Data deletion pipeline tested** (withdrawal trigger → confirmation email → record flagged).
- [ ] **T+14 link active window confirmed**: survey expiration set to day 21 post-election.
- [ ] **Internal pilot run (N = 2)**: one simulated participant per condition (A and B) to confirm routing, embedded data, and piped text all work correctly end-to-end.

---

## §17 — Open Decisions (not blocking Qualtrics build, but block survey launch)

| # | Item | Status |
|---|------|--------|
| DV3-A | DV3 item wording | **⏳ JONY DECISION** — confirm §5.2 wording before building Block 5 |
| DV3-B | DV3 scoring rule (all-correct vs ≥3/4) | **⏳ JONY DECISION** — select Option A or B before OSF filing |
| M1-W | M1 item wording (T0 instrument, not T+14) | **⏳ JONY DECISION** — instrument §3.3; does not affect this T+14 guide |
| IRB | Placeholder fields (Screen 4) | **⏳ JONY** — fill before any participant receives the T+14 link |
| T14-LINK | Delivery mechanism (which DAO platform tool sends link) | **⏳ JONY** — determine before launch |

---

*Author: Jony Bursztyn · 2026-07-01 (draft created by OpenClaw tick-4435)*  
*This Qualtrics setup guide implements the Study 3 T+14 survey as specified in `piup-study3-survey-instrument-2026-07-01.md` and `piup-study3-debrief-script-2026-06-30.md`. DV3 item wording (§9 above) requires Jony's confirmation before Block 5 is built. All remaining blocks can be built immediately.*
