# PIUP Study 4: Debrief Script

**Document type:** IRB submission instrument
**Study:** Temporal UI-Lock and Social Deniability - PIUP Study 4
**Version:** 1.0 (2026-07-01, tick-4393)
**Relates to:** `piup-study4-temporal-coercion-vignette-2026-07-01.md` §7, `piup-study4-osf-prereg-2026-07-01.md`
**Mirrors:** `piup-study3-debrief-script-2026-06-30.md` (format and IRB submission structure)

---

## Overview

Study 4 uses partial disclosure: participants consent to research on "how people interact with digital voting systems" but are not told at consent that the specific focus is on coercion resistance and whether UI design affects compliance under adversarial pressure. No active deception (false factual claims) is used. The cover story is a neutral partial-description, not a false claim.

IRB standards require a debrief that:

1. Discloses the withheld study purpose and explains why it was withheld
2. Clarifies that all scenarios were hypothetical
3. Reveals which condition the participant was assigned to
4. Explains the real-world relevance and motivation for the study
5. Gives participants the opportunity to withdraw their data
6. Provides a contact for follow-up questions

The debrief is delivered at the **end of the single study session**, immediately after the final survey item and before the Prolific completion code is displayed. All debrief screens are presented within Qualtrics. Participants must acknowledge the debrief (Screen 4) before receiving the completion code.

Study 4 is a single-session study - there is no T+14 follow-up. All participant data is collected within the session; withdrawal removes only Qualtrics response data (no behavioral log or follow-up data exists).

---

## Debrief Script

*The following text is displayed verbatim to all participants at the end of the survey, after all outcome and covariate items have been collected.*

---

### Screen 1: What This Study Was Really About

**Thank you for completing this study.**

Before we share your completion code, we want to tell you the full story of what this study was about. Please take a moment to read this - it will help you understand what your responses contribute to.

**What we told you at the start:**

At the beginning of this study, we said we were researching "how people interact with digital voting systems." That description is accurate, but it is incomplete.

**What this study was actually about:**

This study is investigating whether the *design* of a private voting receipt can help protect voters who are pressured to prove how they voted.

Privacy-preserving voting systems - a type of online voting that uses cryptography to ensure votes are counted correctly without revealing individual choices - give voters a receipt after they cast their ballot. This receipt proves their vote was counted, but it deliberately does not show what they voted for.

The question we are studying: if someone is pressured to share that receipt (by a colleague, a manager, or anyone else), does it make a difference whether the voting app *prevents* them from sharing it during the active voting period?

We predicted that a voting app that *locks* the receipt from being downloaded or copied during the voting period gives a pressured voter a stronger, more convincing excuse - "I can't share this; my app won't let me" - than one that only shows a countdown without enforcing the restriction. We call this *social deniability*.

---

### Screen 2: Your Condition

**The scenario you were shown:**

You were randomly assigned to one of four groups. Each group saw a different combination of receipt type and social scenario.

**Your receipt type:** [RECEIPT_TYPE]
*(Note: Qualtrics fills this in automatically. See administration note below.)*

- **Countdown-only (Option D):** The receipt showed a countdown to when sharing becomes safe, but the download button remained active throughout. Participants in this group could have shared the receipt at any time.
- **UI-lock (Option B):** The receipt showed the same countdown, but the download button was locked - greyed out with a padlock icon - until the vote close time. Participants in this group could not download the receipt during the active voting period.

**Your scenario:** [PRESSURE_TYPE]
*(Note: Qualtrics fills this in automatically. See administration note below.)*

- **Moderate pressure (social request):** A colleague asked to see the receipt out of curiosity about how the system works.
- **High pressure (job threat):** A manager threatened to question the participant's commitment to the team if they could not produce the receipt.

All four combinations of receipt type and scenario were shown to approximately equal numbers of participants.

---

### Screen 3: The Scenarios Were Hypothetical

**About the scenarios:**

The situation you were asked to respond to - a colleague or manager requesting your vote receipt - was entirely hypothetical. No actual employer relationship or workplace pressure was implied. No real voting system, election, or Prolific recruitment account was connected to the scenario.

We understand that the high-pressure scenario (job threat framing) can feel uncomfortable to read. It was designed to simulate a genuinely threatening coercion situation, because the social deniability we are studying is most relevant precisely when pressure is high. We are grateful for your willingness to engage with a difficult hypothetical.

**Why we did not tell you the full purpose at the start:**

If participants knew in advance that the study was about coercion resistance and whether a UI feature makes compliance easier to resist, they would likely respond to the scenarios based on what they think the "correct" privacy-respecting answer is rather than their genuine intentions. This is called a *demand effect*, and it makes study results difficult to interpret. Temporarily withholding the specific focus of the study protects the scientific integrity of the findings. Your consent form accurately described the study as research on how people interact with digital voting systems; only the specific coercion-resistance focus was withheld temporarily.

---

### Screen 4: Your Rights - Withdrawing Your Data

**You have the right to withdraw your data.**

Now that you know the full nature of this study, you can choose to have your responses removed from our dataset. If you withdraw, all responses you have provided in this session will be deleted and will not appear in any analysis or publication.

Withdrawing will not affect your Prolific account, your compensation, or any future studies. Compensation is paid for your time regardless of your data withdrawal decision. There are no penalties for withdrawing.

**Do you wish to withdraw your data from this study?**

- ◯ **No - I'm happy for my responses to be used.** Continue to the completion code.
- ◯ **Yes - Please delete my data.** My responses will not be used.

*If you select "Yes," your data will be flagged for deletion. You will still receive your Prolific completion code on the next screen. If you want to confirm deletion has been completed, contact [PI email] within 48 hours of study completion.*

---

### Screen 5: Privacy and Contact

**A note about your privacy:**

This study collected only your survey responses (the items about sharing intent, deniability, and the background questions). No personal information beyond your Prolific ID was recorded. Your Prolific ID is used only to prevent duplicate participation and to process payment; it is not linked to your response data in any publication.

The voting scenarios and receipt screenshots shown in this study were mockups. No actual vote was cast, no blockchain transaction occurred, and no voting record of any kind was created.

**Questions or concerns:**

If you have questions about this study, how your data is used, or if you want to withdraw your data after completing this survey, please contact:

> **Principal investigator:** [PI name]
> **Email:** [PI email]
> **Institution:** [Institution]
> **IRB protocol number:** [IRB number]

You may also contact the IRB office directly at [IRB contact] if you have concerns about your rights as a research participant.

**Further reading (optional):**

If you are interested in the research area, the following references describe the problems this study is designed to address:

- Benaloh, J., and Tuinstra, D. (1994). "Receipt-Free Secret-Ballot Elections." *STOC '94.* - The foundational paper defining receipt-freeness in voting.
- Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic elections." *WPES '05.* - The formal treatment of coercion resistance.

---

### Screen 6: Acknowledgement and Completion Code

*One of the following two screens is shown depending on Screen 4 selection.*

**If participant selected "No - happy to continue":**

> ☐ **I have read the above information and understand the purpose of this study. I consent to my responses being used in analysis and publication (in aggregated, anonymous form).**
>
> [Show Prolific completion code →]

**If participant selected "Yes - withdraw my data":**

> **Your data withdrawal has been recorded.**
>
> Your session responses have been flagged for deletion. The researcher will process withdrawal requests within 48 hours of study completion. If you want confirmation, contact [PI email].
>
> Thank you for your time. Your Prolific completion code is: **[COMPLETION_CODE]**
>
> Please enter this code on Prolific to receive your payment.

---

## Debrief Administration Notes

### Timing

The debrief screens appear **after all outcome and covariate items** have been collected, as the final element of the survey before the Prolific completion code. This ensures that debrief disclosure does not contaminate outcome measures.

Do not split the debrief across sessions or present any debrief screens before all study items are complete. The single-session design means there is no risk of contamination beyond the session boundary.

### Condition unblinding (Screens 1 and 2)

Participants are told which condition they were assigned to via two Qualtrics piped-text fields:

**`[RECEIPT_TYPE]`** → Qualtrics embedded data field `receipt_label`:
- Set at randomisation: `receipt_label = "Countdown-only (Option D)"` for D0 cells; `receipt_label = "UI-lock (Option B)"` for D1 cells.
- Piped in Screen 2 as `${e://Field/receipt_label}`.

**`[PRESSURE_TYPE]`** → Qualtrics embedded data field `pressure_label`:
- Set at randomisation: `pressure_label = "Moderate pressure (social request)"` for P1 cells; `pressure_label = "High pressure (job threat)"` for P2 cells.
- Piped in Screen 2 as `${e://Field/pressure_label}`.

**Rationale for full condition disclosure:** APA Ethics Code §8.08 requires debrief to provide full disclosure of the nature of the study unless withholding serves a specific protective purpose. Knowing which receipt type and scenario you were assigned to is not harmful and cannot change past responses (this is a single-session study with no follow-up). Full condition disclosure is implemented. The mapping from cell code (D0P1, D0P2, D1P1, D1P2) to readable condition labels is handled by the embedded data fields set at randomisation.

### Data withdrawal pipeline

If a participant selects withdrawal on Screen 4:
1. A withdrawal flag is written to the participant's Qualtrics response record immediately (embedded data field `withdrawn = TRUE`).
2. Response data is soft-deleted (flagged `withdrawn = TRUE`) within 48 hours.
3. Withdrawal requests are processed within 48 hours of study completion (no automated email — participants who want confirmation of deletion may contact [PI email] directly).
4. Hard deletion of response data occurs within 30 days per IRB data management protocol.
5. The participant's Prolific completion code is displayed regardless of withdrawal choice, ensuring compensation is not conditional on data donation.

**Qualtrics implementation note:** Use a Branch after Screen 4 to detect `withdrawn = TRUE` and route to the withdrawal-confirmation variant of Screen 6. Both branches display the completion code. The Qualtrics survey flow after the debrief block:

```
[Debrief Block: Screens 1-5]
[Branch: withdrawn = TRUE → Screen 6 (withdrawal variant)]
[Branch: withdrawn ≠ TRUE → Screen 6 (continue variant)]
[End of Survey]
```

### Expected withdrawal rate

Single-session vignette studies with partial (non-deceptive) disclosure and hypothetical scenarios typically see low withdrawal rates (< 3%) because:
- No active deception was used (no false claims to feel aggrieved about)
- The hypothetical scenarios did not place participants in genuinely threatening situations
- Compensation is not withheld based on withdrawal

A withdrawal rate up to 5% is assumed for planning purposes; at n = 40/cell target (after exclusions and replacements), a 5% withdrawal rate reduces the analytic sample by ≤ 2 participants per cell - well within the replacement margin.

### Compensation

Participants receive full payment regardless of their data withdrawal decision. The consent form and debrief both affirm this. Compensation is not contingent on completing all items or retaining data.

### IRB documentation

This script should be submitted as **Attachment D: Debrief Procedure** in the IRB application, parallel to Study 3's Attachment D. A note in the IRB application body under §3 (Procedures) should cross-reference Attachment D and confirm:

> *"Debrief is provided at the end of the single study session, after all outcome and covariate items have been collected and before the Prolific completion code is shown. Participants are informed of the study's coercion-resistance focus, revealed to which of four conditions they were assigned, reminded that all scenarios were hypothetical, given the opportunity to withdraw their data, and provided contact information for the PI and IRB. The debrief script is reproduced verbatim in Attachment D."*

---

## Pre-IRB Checklist

Before IRB submission, the following placeholders must be replaced with real values:

- [ ] `[PI name]` → Principal investigator's name
- [ ] `[PI email]` → PI's institutional email
- [ ] `[Institution]` → University/institution name
- [ ] `[IRB protocol number]` → Assigned at submission (leave blank until assigned)
- [ ] `[IRB contact]` → IRB office email or phone
- [ ] `[COMPLETION_CODE]` → Prolific completion code (set per-study, not in this document; confirm Qualtrics pipes the correct variable)

Verify before Prolific launch:
- [ ] `receipt_label` embedded data field is set correctly at randomisation (D0 cells → "Countdown-only (Option D)"; D1 cells → "UI-lock (Option B)")
- [ ] `pressure_label` embedded data field is set correctly at randomisation (P1 cells → "Moderate pressure (social request)"; P2 cells → "High pressure (job threat)")
- [ ] Withdrawal branch in Qualtrics survey flow is functional (test with pilot data)
- [ ] Both Screen 6 variants display the completion code
- [ ] Debrief block appears AFTER all outcome/covariate items in survey flow

---

## Relation to Study 3 Debrief

Study 4 debrief differs from Study 3 in the following respects:

| Dimension | Study 3 | Study 4 |
|-----------|---------|---------|
| Debrief timing | T+14 (end of follow-up window) | End of single session (immediate) |
| Number of conditions | 2 (Group A / Group B) | 4 (D0P1 / D0P2 / D1P1 / D1P2) |
| Deception level | Incomplete disclosure; real social count withheld | Partial disclosure; coercion focus withheld (no active deception) |
| Count was real? | Yes - social proof counter was real | N/A - no social proof element |
| Study involves real election? | Yes (participants voted in a real election) | No - scenarios are hypothetical throughout |
| Behavioral log data? | Yes (opt-in) | No |
| Longitudinal data withdrawal complexity | High (T0 + T+14 + behavioral log) | Low (single session only) |

Both studies use the same core structure: purpose disclosure → condition reveal → hypothetical scenarios caveat → withdrawal offer → privacy note + contact.
