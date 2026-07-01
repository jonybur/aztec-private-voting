# Qualtrics Setup Guide — PIUP Study 4

**Author:** Jony Bursztyn  
**Date:** 2026-07-01 (tick-4389)  
**Design note:** [`docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`](piup-study4-temporal-coercion-vignette-2026-07-01.md)  
**Pre-registration:** [`docs/piup-study4-osf-prereg-2026-07-01.md`](piup-study4-osf-prereg-2026-07-01.md)

This is a click-by-click implementation guide for building the PIUP Study 4 survey in Qualtrics. Study 4 is a **2×2 between-subjects vignette experiment** (UI condition D × coercion pressure P; 4 cells, N = 160, n = 40 per cell).

**Key differences from Study 2:**
- 4 conditions (not 8) — Qualtrics Randomizer assigns participants to one cell.
- Stimulus is a **static screenshot** (PNG), not an interactive prototype. No external host needed.
- No behavioural logging (download click, verify expansion). Survey responses only.
- Vignette scenario is displayed **after** the receipt stimulus page — a two-step exposure (receipt first, then scenario).
- Much simpler setup: estimated 1–2 hours.

---

## Prerequisites

Before starting the Qualtrics build:

- [ ] Four stimulus screenshots prepared as PNG files (one per cell):
  - `cell-D0P1.png` — Option D (countdown-only, enabled button) + will be used in Moderate pressure cell
  - `cell-D0P2.png` — Option D (countdown-only, enabled button) + will be used in High pressure cell
  - `cell-D1P1.png` — Option B (UI-lock, padlock button) + will be used in Moderate pressure cell
  - `cell-D1P2.png` — Option B (UI-lock, padlock button) + will be used in High pressure cell
  - Screenshots must hold constant: countdown value (5 days 3 hours 12 minutes), receipt identifier value. Only the download button state differs between D0 and D1.
  - Upload each PNG to Qualtrics Library → Graphics before starting survey build.
- [ ] Prolific study created (or ready). Note the **Screen Out URL** and **Study Completion URL** from the Prolific setup page.
- [ ] Qualtrics account with JavaScript allowed (university licence or paid tier).
- [ ] IRB approved or approved-pending (do not run without IRB clearance).

> **Stimulus screenshot construction:** Render `VoteReceipt.tsx` locally with `voteCloseTimestamp` set to a fixed future time (= now + 5d 3h 12m). For D0 cells use default prop (no `temporalLock`). For D1 cells use `temporalLock="lock"`. Take a full-component screenshot at 1280×720 or 800×600 viewport. Do not vary any other props across the four screenshots.

---

## §1 — Survey Settings

In Qualtrics: **Survey Options → General:**
- Anonymous link: Yes (Prolific passes `PROLIFIC_PID` as URL parameter; this is not the same as Qualtrics collecting identifying info).
- Survey expiration: Set end date 2 weeks after target N reached (for replacement collection).

**Survey Options → Security:**
- Prevent ballot box stuffing: Yes (prevent same browser from completing twice — important for between-subjects integrity).
- Bot detection / reCAPTCHA: enabled (reduces inattentive submissions).

**Survey Options → Responses:**
- Record timing: Yes (needed for exclusion criterion: completion time < 3 minutes).
- Save incomplete responses: Yes.

---

## §2 — Embedded Data (Survey Flow)

In Survey Flow, add an **Embedded Data** element at the very top (before any blocks). Define these fields:

| Field name | Set to | Notes |
|------------|--------|-------|
| `PROLIFIC_PID` | `${e://Field/PROLIFIC_PID}` | Passed as URL parameter from Prolific |
| `condition` | (leave blank — set by Randomizer) | Will be `D0P1`, `D0P2`, `D1P1`, or `D1P2` |
| `ui_cond` | (set by Randomizer branch) | `D0` or `D1` |
| `pressure_cond` | (set by Randomizer branch) | `P1` or `P2` |
| `attention_fail` | `0` | Will be set to `1` if attention check fails |
| `comprehension_check_correct` | (blank) | Set to `1` (correct) or `0` (incorrect) in survey logic |

---

## §3 — Survey Flow Overview

The complete Survey Flow, in order:

```
[Embedded Data — top-level]
  PROLIFIC_PID = ${e://Field/PROLIFIC_PID}
  attention_fail = 0

[Randomizer — evenly present one of 4 branches]
  Branch A: Set condition=D0P1, ui_cond=D0, pressure_cond=P1
  Branch B: Set condition=D0P2, ui_cond=D0, pressure_cond=P2
  Branch C: Set condition=D1P1, ui_cond=D1, pressure_cond=P1
  Branch D: Set condition=D1P2, ui_cond=D1, pressure_cond=P2

[Block 1: Consent]
[Block 2: Cover story + receipt display]       ← page timer (min 30s)
[Block 3: Comprehension check (DV3)]
[Block 4: Vignette scenario (shown per condition)]
[Block 5: Primary outcomes — DV1 then DV2]
[Block 6: Moderator + covariates + attention check (randomised order)]
[Branch: QR6_ATTN ≠ 7 → Set attention_fail = 1 → Screen-Out block]  ← AFTER Block 6
[Branch: Q_TotalDuration < 180 AND attention_fail = 0 → Screen-Out block]
[Block 7: Debrief]
[End of Survey]
```

> ⚠️ **Implementation note:** The attention-fail Branch must come AFTER Block 6 — that is where `QR6_ATTN` is collected and where `attention_fail` is set to 1. Do not place an attention-fail branch before the Randomizer or before Block 6; it will never fire because the flag is initialised to 0 and only changes in post-Block-6 logic.

The Randomizer element uses "Evenly Present Elements" to ensure balanced cell assignment. Do NOT use weighted randomisation.

---

## §4 — Block 1: Consent

**Page 1 of Block 1 (single scrolling page):**

**Consent to Participate in Research**

You are invited to participate in a research study about how people interact with digital voting systems. This study is being conducted by [PI name / institution].

**What you will do:** You will be shown a screenshot of a digital voting confirmation screen and asked to read a short workplace scenario. The study takes approximately 8–10 minutes.

**Risks and benefits:** This research involves no more than minimal risk. Your participation is voluntary. You may withdraw at any time without penalty.

**Confidentiality:** Your Prolific ID will be stored separately from your survey responses and will not appear in any publication.

**Payment:** You will receive payment through Prolific at the rate shown on the study listing regardless of your answers.

**Contact:** [IRB contact name and email]. If you have questions about your rights as a research participant, contact [University IRB email/phone].

By clicking **"I agree"** below, you confirm that you are at least 18 years old and consent to participate.

> Button: **"I agree — start the study"**

> No: If participant does not consent → redirect to Prolific Screen Out URL. Set up an End of Survey redirect. In Qualtrics: add a Branch after Block 1 checking Q_TotalDuration < 60 AND consent = No → redirect to Prolific Screen-Out URL.

---

## §5 — Block 2: Cover Story + Receipt Display

**Page timing:** Add a JavaScript page timer enforcing **minimum 30 seconds** on this page. The Next button is disabled on page load (`this.disableNextButton()`) and re-enabled only after 30 seconds (`enableNextButton()`). Participants literally cannot advance until the timer expires — this is not a soft warning. Do NOT use Qualtrics\'s built-in Page Timer feature instead; it does not block advancement without additional scripting.

**JavaScript (add to first question in Block 2):**

```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var minTime = 30; // seconds
    var secondsLeft = minTime;
    var timerEl = document.createElement('div');
    timerEl.id = 'piup-timer';
    timerEl.style.cssText = 'color:#666;font-size:13px;margin-top:8px;';
    timerEl.innerHTML = 'Please read the receipt carefully. Continue available in ' + secondsLeft + 's.';

    // Disable Next button
    this.disableNextButton();

    var interval = setInterval(function() {
        secondsLeft--;
        timerEl.innerHTML = secondsLeft > 0
            ? 'Please read the receipt carefully. Continue available in ' + secondsLeft + 's.'
            : 'You may now continue.';
        if (secondsLeft <= 0) {
            clearInterval(interval);
            Qualtrics.SurveyEngine.getInstance().enableNextButton();
            timerEl.style.color = '#2a7a2a';
        }
    }, 1000);

    // Append timer message below question text
    var container = document.getElementById('QID_RECEIPT_IMAGE-body') || document.querySelector('.QuestionBody');
    if (container) container.appendChild(timerEl);
});
```

**Question QR2_COVER (Descriptive Text / Instructions):**

*No question response needed — this is an instruction block.*

> Imagine you just finished voting in an online election run through a company governance platform. After submitting your vote, you were shown the following confirmation screen on your computer.
>
> **Please read the confirmation screen carefully.**

**Question QR2_STIMULUS (Image Display):**

Display the appropriate stimulus image using Display Logic:

- Show `cell-D0P1.png` if `ui_cond = D0` AND `pressure_cond = P1`
- Show `cell-D0P2.png` if `ui_cond = D0` AND `pressure_cond = P2`
- Show `cell-D1P1.png` if `ui_cond = D1` AND `pressure_cond = P1`
- Show `cell-D1P2.png` if `ui_cond = D1` AND `pressure_cond = P2`

In Qualtrics: use a **Descriptive Text** question type with an embedded image from the Graphics Library. Add four copies of this question (one per condition image), each with the appropriate Display Logic.

> **Image alt text (for accessibility):** "Screenshot of a vote confirmation screen showing a vote receipt with a receipt ID and [D0: a countdown message reading 'Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes.' A download button is visible and enabled. / D1: a padlock icon on the download button reading 'Locked until vote closes in 5d 3h 12m. After the vote closes you can download and share your receipt safely.']"

Use Display Logic (not Skip Logic) so the timer JavaScript fires regardless of condition.

---

## §6 — Block 3: Comprehension Check (DV3)

New page. Single question, no timer.

**Question QR3_DV3 (Multiple Choice — Single Answer):**

> Based on what you saw, did the receipt you received tell you or anyone else how you voted?
>
> ○ Yes — the receipt showed how I voted
> ○ No — the receipt did not show how I voted
> ○ I'm not sure

**Embedded data:** After this question, set `comprehension_check_correct`:
- Use Qualtrics **Embedded Data** in survey flow after Block 3 (or use JavaScript):
  - If QR3_DV3 = "No" → `comprehension_check_correct = 1`
  - Else → `comprehension_check_correct = 0`

**Important:** DV3 incorrect answers do **not** trigger exclusion or screen-out at this point. Per the pre-registration (§4), incorrect-DV3 participants remain in the ITT analysis; they are flagged for a pre-registered sensitivity analysis. Only the attention check (Block 6) triggers hard exclusion.

---

## §7 — Block 4: Vignette Scenario

New page. Display the receipt screenshot again (small/thumbnail, same condition-appropriate image as Block 2) followed by the scenario text. This prevents participants from having to scroll back.

**Question QR4_SCENARIO_INTRO (Descriptive Text):**

> Now please re-read the confirmation screen below — you still have it open on your computer — and imagine the following situation:

**Question QR4_STIMULUS_REPEAT (Image Display):**

Same Display Logic as Block 2 — show the condition-appropriate screenshot. Use a smaller display size (e.g., max-width: 400px via Custom CSS or an Inline Image option) so both the image and the scenario text are visible on one screen without scrolling.

**Question QR4_SCENARIO (Descriptive Text — condition-branched):**

Show the appropriate vignette using Display Logic:

**P1 (Moderate pressure) — show if `pressure_cond = P1`:**

> A colleague at work mentions they're trying to understand how the new voting system works. They ask: *"Hey, can you show me your vote receipt? I'm curious what it looks like."* You still have the vote receipt screen open on your computer.

**P2 (High pressure) — show if `pressure_cond = P2`:**

> Your manager calls you in and says: *"We need to verify how our team voted on this issue. If you can't show me your vote receipt right now, I'll need to question your commitment to the team."* You still have the vote receipt screen open on your computer.

> **Implementation note:** Use two separate Descriptive Text questions, each with Display Logic gating on `pressure_cond`. Do not use Skip Logic for this — you want both questions to exist in the flow for data integrity; only one will render per participant.

---

## §8 — Block 5: Primary Outcomes (DV1, DV2)

New page. Present DV1 first, then DV2 on the same page (forced order — do not randomise). The ordering is pre-registered to prevent deniability-priming from contaminating sharing-intent measurement.

**Question QR5_DV1 (Likert — Single Row):**

> If you were in this situation, how likely would you be to share the vote receipt screen with the person asking?

Scale: 1–7  
Label 1: **Very unlikely**  
Label 7: **Very likely**  
Force response: Yes

**Question QR5_DV2 (Likert — Single Row):**

> If you were in this situation, how convincing do you think it would be to say *"I can't share this — my voting app won't let me until the vote closes"*?

Scale: 1–7  
Label 1: **Not at all convincing**  
Label 7: **Very convincing**  
Force response: Yes

> **Note on D0 DV2:** In Option D (countdown-only) cells, the download button is enabled — so the claim "the app won't let me" is not literally true. This measures *counterfactual* deniability. The asymmetry is noted in the pre-registration (§5) and will be acknowledged in the analysis.

---

## §9 — Block 6: Moderator, Covariates, Attention Check

New page. Present all items in **randomised order** within this block (Qualtrics: enable question randomisation for Block 6). The attention check is embedded among the other items to detect inattentive responding.

### Attention Check

**Question QR6_ATTN (Likert — Single Row):**

> For quality purposes, please select **Strongly agree** for this item.

Scale: 1–7  
Label 1: **Strongly disagree**  
Label 7: **Strongly agree**  
Force response: Yes

**Exclusion logic (post-block):** After Block 6, add a Branch in Survey Flow:

```
IF QR6_ATTN ≠ 7 (Strongly agree)
  → Set attention_fail = 1
  → Jump to Screen-Out block
```

The Screen-Out block (see §11) redirects to the Prolific Screen-Out URL. This participant is replaced.

### Moderator M1: Technology Self-Efficacy

**Question QR6_M1 (Likert — Single Row):**

> I am confident in my ability to troubleshoot technical problems with apps and websites.

Scale: 1–7  
Label 1: **Strongly disagree**  
Label 7: **Strongly agree**  
Force response: Yes

### Covariate C1: Prior Voting App Experience

**Question QR6_C1 (Multiple Choice — Single Answer):**

> Have you ever used a digital voting platform (other than standard government voting — for example, for workplace decisions, a community group, or an online community)?

○ Yes  
○ No  
Force response: Yes

---

## §10 — Block 7: Debrief

**⚠ IRB-CRITICAL: This block implements the full 5-screen debrief from `piup-study4-debrief-script-2026-07-01.md`. Do not simplify. The withdrawal question (Screen 4) is an IRB requirement.**

New page. No timer. Participants cannot go back after the debrief. The debrief block appears in Survey Flow AFTER the two exclusion Branches (§11 trigger logic); excluded participants never see the debrief.

**Embedded data to add in Survey Flow BEFORE the Randomizer** (in addition to existing fields):

```
receipt_label  = "" (set at randomisation — see below)
pressure_label = "" (set at randomisation — see below)
withdrawn      = FALSE
```

In each of the 4 Randomizer branches, set:
- D0 branches: `receipt_label = Countdown-only (Option D)`
- D1 branches: `receipt_label = UI-lock (Option B)`
- P1 branches: `pressure_label = Moderate pressure (a colleague asking out of curiosity)`
- P2 branches: `pressure_label = High pressure (a manager threatening consequences)`

---

### Screen 1 — What This Study Was Really About

**Question QR7_S1 (Descriptive Text):**

> **Thank you for completing this study.**
>
> Before we share your completion code, we want to tell you the full story of what this study was about.
>
> **What we told you at the start:** We said we were researching "how people interact with digital voting systems." That description is accurate, but it is incomplete.
>
> **What this study was actually about:** This study investigates whether the *design* of a private voting receipt can protect voters who are pressured to prove how they voted. The question: if someone is pressured to share their receipt, does it help if the app *prevents* sharing during the voting period — giving them a stronger excuse ("the app won\'t let me") than a normative one ("I\'m not supposed to")?
>
> Your responses help us understand whether this design choice matters for people\'s experience of social pressure.
>
> **Your responses are confidential.** All answers appear only in aggregate form in publications.

No question — Descriptive Text only. Page Break after this block.

---

### Screen 2 — Your Condition

**Question QR7_S2 (Descriptive Text):** *(Use Display Logic or Piped Text from Embedded Data fields.)*

You were randomly assigned to one of four groups. Use four separate Descriptive Text questions with Display Logic on `ui_cond` + `pressure_cond`, or pipe from the embedded data fields set at randomisation:

| Condition | `receipt_label` value | `pressure_label` value |
|-----------|----------------------|------------------------|
| D0P1 | Countdown-only (Option D) | Moderate pressure (a colleague asking out of curiosity) |
| D0P2 | Countdown-only (Option D) | High pressure (a manager threatening consequences) |
| D1P1 | UI-lock (Option B) | Moderate pressure (a colleague asking out of curiosity) |
| D1P2 | UI-lock (Option B) | High pressure (a manager threatening consequences) |

> **Your receipt type:** `${e://Field/receipt_label}`
>
> - **Countdown-only (Option D):** The download button remained active; only a countdown was shown.
> - **UI-lock (Option B):** The download button was locked with a padlock icon until the vote closed.
>
> **Your scenario:** `${e://Field/pressure_label}`
>
> - **Moderate pressure:** A colleague asked to see your receipt out of curiosity.
> - **High pressure:** A manager threatened to question your commitment if you could not produce the receipt.

Page Break after this screen.

---

### Screen 3 — The Scenarios Were Hypothetical

**Question QR7_S3 (Descriptive Text):**

> **About the scenarios:**
>
> The situation you were asked to respond to — a colleague or manager requesting your vote receipt — was entirely hypothetical. No actual employer relationship or workplace pressure was implied. No real voting system, election, or Prolific account was connected to the scenario.
>
> We understand the high-pressure scenario (job-threat framing) can feel uncomfortable to read. It was designed to simulate a genuinely threatening coercion situation, because social deniability is most relevant when pressure is high.
>
> **Why we did not tell you the full purpose at the start:** If participants knew the study was about coercion resistance, they would likely respond based on what they think the "correct" privacy-respecting answer is — rather than their genuine intentions. Temporarily withholding the specific focus protects the scientific validity of the findings. Your consent form accurately described the study; only the specific coercion-resistance focus was withheld temporarily.

Page Break after this screen.

---

### Screen 4 — Data Withdrawal (IRB required)

**⚠ IRB-REQUIRED: This screen must be implemented exactly as specified. A withdrawal mechanism is required for studies using partial disclosure.**

**Question QR7_WITHDRAW (Multiple Choice — Single Answer):**

Question text:

> **You have the right to withdraw your data.**
>
> Now that you know the full purpose of this study, you can choose to have your responses removed from our dataset. If you withdraw, all responses from this session will be deleted and will not appear in any analysis or publication.
>
> Withdrawing will not affect your Prolific account, your compensation, or any future studies. There are no penalties.
>
> **Do you wish to withdraw your data from this study?**

Choices:
- ◯ **No — I am happy for my responses to be used.** (Choice value: 1)
- ◯ **Yes — Please delete my data.** My responses will not be used. (Choice value: 2)

Force response: Yes.

**Survey Flow — Branch after QR7_WITHDRAW:**
```
IF QR7_WITHDRAW = 2 (Yes — withdraw)
  → Set Embedded Data: withdrawn = TRUE
  → Jump to Screen 6 (withdrawal variant)
ELSE (No — continue)
  → Continue to Screen 5
```

Page Break after this screen.

---

### Screen 5 — Privacy and Contact (Jony: fill placeholders before IRB submission)

**Question QR7_S5 (Descriptive Text):**

> **A note about your privacy:**
>
> This study collected only your survey responses. No personal information beyond your Prolific ID was recorded. Your Prolific ID is used only to prevent duplicate participation and to process payment; it is not linked to your response data in any publication.
>
> The voting scenarios and receipt screenshots were mockups. No actual vote was cast, no blockchain transaction occurred, and no voting record was created.
>
> **Questions or concerns:**
>
> **Principal investigator:** [PI name — FILL BEFORE IRB SUBMISSION]
> **Email:** [PI email — FILL BEFORE IRB SUBMISSION]
> **Institution:** [Institution — FILL BEFORE IRB SUBMISSION]
> **IRB protocol number:** [Assigned at submission — leave blank until assigned]
>
> You may also contact the IRB office at [IRB contact email/phone — FILL BEFORE IRB SUBMISSION] if you have concerns about your rights as a research participant.

Page Break after this screen. (Screen 5 shown only to non-withdrawing participants via Survey Flow.)

---

### Screen 6 — Acknowledgement and Completion Code (two variants)

**⚠ Both variants must display the Prolific Completion Code. Compensation is NOT conditional on data retention.**

**Variant A — for participants who did NOT withdraw** (shown when `withdrawn ≠ TRUE`):

**Question QR7_S6A (Descriptive Text / Acknowledgement):**

> ☐ **I have read the above information and understand the purpose of this study. I consent to my responses being used in analysis and publication (in aggregated, anonymous form).**
>
> Your Prolific completion code: **[Paste Prolific Completion Code here]**
>
> Please enter this code on Prolific to receive your payment.

Force response on the checkbox. End of Survey redirect → Prolific Completion URL.

---

**Variant B — for participants who withdrew** (shown when `withdrawn = TRUE`):

**Question QR7_S6B (Descriptive Text):**

> **Your data withdrawal has been recorded.**
>
> Your session responses will be flagged for deletion within 48 hours. Thank you for your time.
>
> Your Prolific completion code: **[Paste Prolific Completion Code here]**
>
> Please enter this code on Prolific to receive your payment.

End of Survey redirect → Prolific Completion URL.

---

### §10 — Survey Flow for Debrief Block

```
[Block 7: Debrief]
  Screen 1 (QR7_S1) — Study purpose disclosure
  Screen 2 (QR7_S2) — Condition reveal (Piped Text from receipt_label + pressure_label)
  Screen 3 (QR7_S3) — Hypothetical caveat
  Screen 4 (QR7_WITHDRAW) — Data withdrawal question
  [Branch: QR7_WITHDRAW = 2 → Set withdrawn = TRUE → Skip to Screen 6B]
  Screen 5 (QR7_S5) — Privacy note + contact (non-withdrawing only)
  Screen 6A (QR7_S6A) — Acknowledgement + code (non-withdrawing)
[Branch: withdrawn = TRUE]
  Screen 6B (QR7_S6B) — Withdrawal confirmed + code
[End of Survey → Prolific Completion URL]
```

### §10 — Data Export Variables Added

Add these to the §12 variable reference table:

| Qualtrics variable | Pre-reg name | Type | Notes |
|--------------------|--------------|------|-------|
| `receipt_label` | — | string | Set at randomisation; piped into Screen 2 |
| `pressure_label` | — | string | Set at randomisation; piped into Screen 2 |
| `QR7_WITHDRAW` | — | 1 or 2 | 1 = No (retain); 2 = Yes (withdraw) |
| `withdrawn` | — | TRUE/FALSE | Set by Branch if QR7_WITHDRAW = 2 |

**Post-study action:** Before analysis, filter out all rows where `withdrawn = TRUE`. Document this step in the IRB data management section.

---

## §11 — Screen-Out Block

A dedicated block for excluded participants. Contains one instruction and an End of Survey redirect to the Prolific Screen-Out URL.

**Question (Descriptive Text):**

> Unfortunately, we cannot use your responses for this study (this may be due to a completion time issue or a quality check failure). Your submission will be marked as returned on Prolific. You will not be penalised.

End of Survey redirect → Prolific Screen-Out URL.

**Trigger conditions (both Branches placed in Survey Flow AFTER Block 6):**
1. **Attention check failure:** Branch: `QR6_ATTN ≠ 7` → Set `attention_fail = 1` → Screen-Out.
2. **Completion time:** Branch: `Q_TotalDuration < 180` AND `attention_fail = 0` → Screen-Out.

> Both Branches must appear in Survey Flow AFTER Block 6, before Block 7 (Debrief). Placing them before the Randomizer or before Block 6 will cause them to never fire (the conditions cannot be true before the questions are asked).

**Comprehension-check failure (DV3 incorrect):** Do NOT redirect to Screen-Out. Flag in data (`comprehension_check_correct = 0`) for pre-registered sensitivity analysis. These participants complete the full survey and receive payment.

---

## §12 — Data Export Variable Reference

When you export data from Qualtrics, the relevant columns are:

| Qualtrics variable | Pre-reg name | Type | Notes |
|--------------------|--------------|------|-------|
| `ResponseId` | — | string | Qualtrics internal ID |
| `PROLIFIC_PID` | — | string | From URL parameter |
| `condition` | — | string | `D0P1`, `D0P2`, `D1P1`, `D1P2` |
| `ui_cond` | D factor | string | `D0` (no lock) or `D1` (UI-lock) |
| `pressure_cond` | P factor | string | `P1` (moderate) or `P2` (high) |
| `QR5_DV1` | DV1 | integer 1–7 | Sharing intent |
| `QR5_DV2` | DV2 | integer 1–7 | Perceived deniability |
| `QR3_DV3` | DV3 | string | Comprehension check (Yes/No/Not sure) |
| `comprehension_check_correct` | — | 0/1 | 1 = correct (No) |
| `QR6_ATTN` | — | integer 1–7 | Attention check; must = 7 to pass |
| `attention_fail` | — | 0/1 | 1 = failed attention check |
| `QR6_M1` | M1 | integer 1–7 | Technology self-efficacy |
| `QR6_C1` | C1 | string | Prior voting app experience (Yes/No) |
| `Q_TotalDuration` | — | integer (seconds) | Completion time |

**Derived exclusion flags (R code):**

```r
df <- df %>%
  mutate(
    # Hard exclusions (these participants are replaced)
    exclude_attn   = (QR6_ATTN != 7),
    exclude_time   = (Q_TotalDuration < 180),  # < 3 minutes
    exclude_any    = exclude_attn | exclude_time,
    
    # Sensitivity analysis flag (not excluded from ITT)
    low_comprehension = (comprehension_check_correct == 0),
    
    # Factor coding
    D = factor(ui_cond, levels = c("D0", "D1")),
    P = factor(pressure_cond, levels = c("P1", "P2"))
  )

# ITT sample (primary analysis)
df_itt <- df %>% filter(!exclude_any)

# Per-protocol sensitivity sample (comprehension-correct only)
df_pp <- df_itt %>% filter(!low_comprehension)
```

---

## §13 — Prolific Setup Checklist

- [ ] Study title: "How people interact with digital voting confirmation screens" (do not mention coercion or privacy — blind participants to the true DV)
- [ ] Study description: "You'll be shown a screenshot of a digital voting confirmation screen and answer a few questions about a hypothetical workplace scenario. Takes 8–10 minutes."
- [ ] Estimated completion time: 10 minutes
- [ ] Reward: [Set per Prolific guidelines for 10-minute study]
- [ ] Eligibility filters: Country = United States; Language = English; Approval rate ≥ 95%; Age ≥ 18
- [ ] Number of places: 160 (plus replacement buffer — request 175 and top up as needed)
- [ ] Survey URL: Your Qualtrics anonymous link with `PROLIFIC_PID=${PROLIFIC_PID}` appended:
  `https://[your-qualtrics-url]?PROLIFIC_PID=${PROLIFIC_PID}`
- [ ] Completion URL: Paste Prolific's completion URL into Qualtrics End of Survey redirect (Block 7)
- [ ] Screen-Out URL: Paste Prolific's screen-out URL into Qualtrics Screen-Out block redirect (§11)

---

## §14 — Cell Balance Monitoring

After launching, monitor cell balance daily in the Qualtrics Data & Analysis tab using the embedded data filter on `condition`. Qualtrics Randomizer should maintain approximate balance, but check that no cell exceeds n = 45 before reaching target.

If a cell reaches n = 45 before the study closes, contact Prolific support to cap additional responses (Prolific does not natively support per-condition caps on standard surveys — monitoring is manual).

**Replacement cap:** Do not collect more than n = 60 per cell to replace exclusions; if exclusion rate is high (>30%), investigate stimulus display issues before continuing.

---

## §15 — Pre-Launch Checklist

Run a soft launch (n = 5 internal testers, not Prolific participants) and verify:

- [ ] Condition assignment is random and approximately balanced across 5 runs
- [ ] Timer fires correctly — Next button disabled for 30 seconds on Block 2 page
- [ ] Correct stimulus image displays for each condition
- [ ] Scenario text matches condition (P1 vs. P2)
- [ ] DV1 and DV2 both record responses
- [ ] Attention check failure routes to Screen-Out correctly
- [ ] Debrief condition description is correct for each of the 4 cells
- [ ] Prolific Completion URL redirect fires after debrief
- [ ] Data export includes `PROLIFIC_PID`, `condition`, `ui_cond`, `pressure_cond` fields

File the OSF pre-registration before launching on Prolific. Do not collect data before the pre-registration timestamp is fixed.
