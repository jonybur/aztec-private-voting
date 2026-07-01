# PIUP Study 3: Debrief Script

**Document type:** IRB submission instrument  
**Study:** Social Verification Pilot — PIUP Study 3  
**Version:** 1.0 (2026-06-30)  
**Relates to:** `piup-study3-social-verification-2026-06-29.md` §7  
**Addresses:** Pre-IRB critique M4 (debrief underspecified)

---

## Overview

Study 3 uses incomplete disclosure: participants consent to research on "how voters use their receipts" but are not told at T0 that there are two versions of the receipt or that a between-subjects manipulation is occurring. IRB standards require a debrief procedure that:

1. Discloses the incomplete information and explains why it was withheld
2. Describes what was actually studied
3. Gives participants an opportunity to withdraw their data
4. Provides a contact for follow-up questions
5. Reinforces privacy protections (no individual vote is identifiable from study data)

The debrief is delivered at **T+14** (end of the verification window), immediately before or during the T+14 survey. It is presented as a screen in the survey instrument before any T+14 measures are collected. Participants must acknowledge the debrief before proceeding.

---

## Debrief Script

*The following text is displayed verbatim to all participants (both conditions) at T+14, before any T+14 survey questions.*

---

### Screen 1: Study Purpose (all participants)

**Thank you for participating in this research.**

Before we ask you a few final questions, we want to tell you more about the study you have been part of.

**What this study is about:**

This study is examining how voters decide whether to verify that their vote was counted after an election. One of the questions researchers find interesting is: does it matter to people to know that *other voters* are also verifying? Could seeing that others have verified encourage someone who might not have thought to do it themselves?

**What we were actually studying:**

When you cast your vote in this election, you were randomly assigned to one of two groups:

- **Group A (about half of participants):** Your vote receipt showed the standard receipt with no additional information.
- **Group B (about half of participants):** Your vote receipt included a line showing how many voters in this election had already attempted to verify their vote.

You may have been in either group. The two receipts were otherwise identical: both contained the same verification information, both linked to the same verification page, and both were privacy-preserving.

---

### Screen 2: Why We Didn't Tell You This Earlier

**Why we didn't tell you about the two groups at the start:**

We didn't mention the two-group design at the time of your vote because knowing about it might have changed how you behaved. If you had known we were studying whether the "other voters have verified" display affects behavior, you might have verified (or not verified) differently — not because of the display itself, but because of your awareness of being in a study. Researchers call this a *demand effect*, and it can make study results difficult to interpret.

This kind of incomplete disclosure is common in behavioural research when the act of explaining the study would change the behavior being studied. Your consent form accurately described the study as research on how voters use their receipts; the specific detail of the two-group design was withheld temporarily to protect the integrity of the findings.

**The count was real:**

If you were in Group B, the counter you saw showed the actual number of voters who had attempted verification — not a simulated or inflated number. Showing a genuine social signal (rather than a fabricated one) was important both ethically and scientifically.

---

### Screen 3: Your Rights — Withdrawing Your Data

**You have the right to withdraw your data.**

Now that you know the full nature of the study, you can choose to withdraw your participation data entirely. If you withdraw, all responses you have provided (T0 and T+14) will be deleted from our dataset and will not appear in any analysis or publication.

Withdrawing will not affect you in any way. There are no penalties for withdrawing.

**Do you wish to withdraw your data from this study?**

- ◯ **No — I'm happy for my responses to be used.** Continue to the final questions.
- ◯ **Yes — Please delete my data.** My responses will not be used. (Selecting this will end the survey and trigger deletion.)

*If you select "Yes," you will receive a confirmation email within 48 hours confirming that your data has been removed.*

---

### Screen 4: Privacy Reminder and Contact

**A note about your privacy:**

This study does not record or store your individual vote. The study cannot determine how you voted. The only information collected is:

- Whether you attempted to verify your vote (from our study platform, not from the blockchain or your wallet)
- Your survey responses about verification (this survey)
- If you opted in to behavioral logging: whether and when the `verify_vote_counted()` function was called via your receipt link

The social proof counter (shown to Group B participants) was derived from public smart contract logs. These logs contain pseudonymous receipt IDs only — no names, wallets, or individual votes are associated with the count.

**Questions or concerns:**

If you have questions about this study, how your data is used, or if you want to withdraw your data after completing this survey, please contact:

> **Principal investigator:** [PI name]  
> **Email:** [PI email]  
> **Institution:** [Institution]  
> **IRB protocol number:** [IRB number]

You may also contact the IRB office directly at [IRB contact] if you have concerns about your rights as a research participant.

---

### Screen 5: Acknowledgement (required to proceed)

*One of the following two options is shown depending on Screen 3 selection.*

**If participant selected "No — happy to continue":**

> ☐ **I have read the above information and understand the nature of this study. I consent to my responses being used in analysis and publication (in aggregated, anonymous form).**
>
> [Continue to final questions →]

**If participant selected "Yes — withdraw my data":**

> **Your data withdrawal has been recorded.**
>
> Your T0 and T+14 responses will be deleted within 48 hours. You will receive a confirmation email at the address you provided when you registered for the study.
>
> Thank you for your time. You are free to close this window.

---

## Debrief Administration Notes

### Timing

The debrief is delivered **before** any T+14 measures are collected. The debrief screens appear immediately when the participant follows the T+14 survey link. Participants who withdraw on Screen 3 do not proceed to T+14 questions; their withdrawal flag is logged and triggers the deletion pipeline.

### Condition unblinding

Participants are told they were in "Group A" or "Group B" but are **not** told which group they were in specifically. The debrief describes both conditions accurately but does not reveal individual assignment. This is deliberate: revealing condition assignment could change retrospective interpretation of the experience and is not necessary for ethical disclosure. If a participant specifically asks which group they were in, the contact PI can disclose this post-study.

### Data withdrawal pipeline

If a participant selects withdrawal:
1. A withdrawal flag is written to the participant record in the study database immediately.
2. Responses are soft-deleted (flagged `withdrawn = TRUE`) within 48 hours.
3. A confirmation email is sent to the participant's registered email.
4. Hard deletion of response data occurs within 30 days per IRB data management protocol.
5. Behavioral log data (if opt-in) is deleted from the log store in the same cycle.
6. Withdrawal does not affect the verification count data drawn from public on-chain logs (this data is public by design and cannot be deleted).

### Expected withdrawal rate

No firm precedent for withdrawal rates in ZK voting studies. Based on analogous deception-debrief studies (e.g., memory and attention studies with delayed disclosure), withdrawal rates are typically 2–5%. A 10% upper bound is assumed for power analysis purposes. The pilot is powered at N = 80; if withdrawal reaches 10%, effective n per condition drops to ~36, reducing power to ~30–50% for OR = 2.0. This is acceptable for a pilot study; the primary goal is the point estimate, not confirmatory NHST.

### IRB documentation

This script should be submitted as **Attachment D: Debrief Procedure** in the IRB application. A note in the application body under §3 (Procedures) should cross-reference Attachment D and confirm that:

> *"Debrief is provided at T+14, prior to collection of T+14 measures. Participants are informed of the two-condition design, given the opportunity to withdraw their data, and provided contact information for the PI and IRB. The debrief script is reproduced verbatim in Attachment D."*

---

## Open Issues (from pre-IRB critique, 2026-06-30)

_Updated tick-4319 (2026-06-30): all items verified against current document versions._

Items resolved by this document:

- **M4** ✅ Debrief script specifies: what participants are told (two conditions, counter purpose, study goal), withdrawal opportunity (Screen 3), contact for follow-up (Screen 4), privacy clarification, and IRB submission pathway via Attachment D.

All other pre-IRB critique items are also resolved in `piup-study3-social-verification-2026-06-29.md` as of tick-4319:

- **H1** ✅ Das et al. (2014) citation correct in both docs (CCS '14, Kim et al.)
- **H2** ✅ Nissen et al. (2025) cited in §7 of social-verification doc
- **H3** ✅ Section heading is "Partial disclosure with debrief"
- **M1** ✅ Counter floor ≥10 pre-specified in §3
- **M2** ✅ Condition persistence documented in §3
- **M3** ✅ Lakens (2021) justification in §6
- **L1** ✅ T+7 reminder exclusion committed in §3
- **L2** ✅ Comprehension context-shift caveat in §5
- **L3** ⏳ Study 2 ethics xref: partially resolved (document + section named; no page number possible in Markdown; tighten at IRB submission time)

**Outstanding Jony actions before IRB submission:**
- Fill placeholders: `[PI name]`, `[PI email]`, `[Institution]`, `[IRB protocol number]`, `[IRB contact]` in Screen 4 of this debrief script
- Upload OSF pre-registration (JONY-ACTION O + T prerequisite)
- **Decide: disclose condition assignment in debrief?** (see M5 below)

### M5 — Condition assignment disclosure (flagged tick-4366)

The current administration note says participants are **not told which group they were in** (Group A or Group B). The justification is "could change retrospective interpretation of the experience."

**IRB risk:** This is a methodological justification, not an ethical one. IRBs evaluate debrief adequacy from the participant's perspective, not the researcher's data-quality perspective. Standard guidance (APA Ethics Code §8.08; Baumrind 1985) requires full disclosure in debrief unless withholding is itself protective of the participant. Here, knowing "you saw the social counter" or "you did not" is not harmful — the counter was real and participants' behavior is already in the past.

**Recommended fix (one of two options):**
1. **Disclose condition:** Add to Screen 1 — "If you saw a line showing how many others had verified, you were in Group B. If you did not see this line, you were in Group A." This is cleaner ethically and easier to justify to IRB.
2. **Strengthen justification in IRB application:** If Jony has a specific reason not to disclose (e.g., linked to a post-study qualitative follow-up that needs condition-blindness), that reason must appear explicitly in the IRB narrative — not just in the debrief admin notes.

Option 1 is recommended unless there is a study-design reason to avoid it.
