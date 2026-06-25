# Survey Instrument: PIUP Study 1 — Receipt Identifier Label Comprehension

**Date:** 2026-06-22  
**Author:** Jony Bursztyn  
**Status:** Pre-pilot draft — to be uploaded to OSF alongside pre-registration  
**Companion documents:**
- [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) — pre-registration (locks hypotheses and endpoints)
- [`docs/piup-study-protocol-2026-06-22.md`](piup-study-protocol-2026-06-22.md) — full protocol
- [`analysis/piup-study1-analysis.R`](../analysis/piup-study1-analysis.R) — pre-registered analysis script

This document specifies the **exact question wording, answer options, scoring rubrics, and Qualtrics implementation notes** for Study 1. Any change to question wording after OSF registration constitutes an amendment and must be logged in the pre-registration amendments table.

---

## §1 Overview

Participants are recruited through Prolific and assigned to one of four between-subjects conditions (A: *vote fingerprint*, B: *confirmation code*, C: *nullifier*, D: *receipt ID*). They view a static mockup of a post-vote receipt screen for their assigned condition, then answer five comprehension questions, confidence ratings, and secondary items. Total estimated time: 8–12 minutes.

The label varies by condition. Everywhere `[LABEL]` appears below, the actual survey text uses the assigned condition label:

| Condition | [LABEL] |
|-----------|---------|
| A | vote fingerprint |
| B | confirmation code |
| C | nullifier |
| D | receipt ID |

In Qualtrics, this substitution is handled via Embedded Data and Piped Text (see §7).

---

## §2 Survey Flow (Screen-by-Screen)

1. **Screener** — voting experience + occupation exclusion  
2. **Welcome + cover story** — task framing  
3. **Stimulus exposure** — timed display of `condition-[X].html` (minimum 90 s)  
4. **Attention check 1** — standard follow-instruction item  
5. **Comprehension block** — Q1, Q1-confidence, Q2, Q2-confidence, Q3, Q3-confidence, Q4, Q4-confidence, Q5 (open-ended)  
6. **Mental model quality item** — open text: "what does your [LABEL] prove?"  
7. **Behavioral intent item**  
8. **Label affect slider**  
9. **Attention check 2**  
10. **Demographics** — age range, technology occupation bucket  
11. **Debrief screen**

---

## §3 Screener Questions

Displayed before welcome screen. Failing either criterion triggers Prolific screen-out redirect.

### SC1 — Voting experience (inclusion criterion)

**Question text:**  
*"Have you voted in an online election, poll, or survey in the past 12 months? (This includes workplace polls, student-body elections, and any official online ballots.)"*

| Option | Routing |
|--------|---------|
| Yes | Continue |
| No | Screen out → redirect to Prolific screen-out URL |

### SC2 — Occupation exclusion

**Question text:**  
*"What best describes your main occupation or field of study?"*

| Option | Routing |
|--------|---------|
| Software engineer, developer, or programmer | Screen out |
| Other technology professional (e.g. IT support, data analyst, product manager) | Continue |
| Healthcare, education, law, finance, or public service | Continue |
| Skilled trades or manufacturing | Continue |
| Retail, hospitality, or service industry | Continue |
| Student (not in computer science or software engineering) | Continue |
| Student in computer science or software engineering | Screen out |
| Other | Continue |
| Prefer not to say | Continue |

*Screen-out for SC2: redirect to Prolific screen-out URL. Do not apply to main analysis dataset.*

---

## §4 Welcome + Cover Story (Text Screen)

*Displayed as a Qualtrics "Text / Graphic" block — no response required.*

---

**Welcome. Estimated time: 8–12 minutes.**

You are helping researchers evaluate a **prototype voting interface**. You will be shown a screen that appears immediately after you submit a vote. Please read it carefully — you will be asked questions about it afterward.

- The interface is a **prototype only** — there is no real election and no real votes are being collected.
- You are not required to cast any vote or enter any personal information.
- You will be asked questions about what the screen shows and what it means.

*Please do not use external resources (e.g., Google or Wikipedia) to answer the questions. We are interested in your natural understanding of the interface, not in researched definitions.*

---

## §5 Stimulus Exposure Block

### Display screen

**Platform implementation:** ExternalLink question type in Qualtrics, URL:

```
[STATIC_HOST]/condition-${e://Field/condition}.html
```

Or embed as a full-height iframe in a Text/Graphic block if the ExternalLink redirect is not preferred.

**Timing:** A JavaScript timer prevents advancing before 90 seconds have elapsed.

```javascript
// Paste in Qualtrics "Add JavaScript" for this question
Qualtrics.SurveyEngine.addOnload(function() {
    var btn = this.getNextButton();
    btn.disabled = true;
    btn.innerHTML = "Please review the screen (0:90 remaining)";
    var seconds = 90;
    var timer = setInterval(function() {
        seconds--;
        if (seconds <= 0) {
            clearInterval(timer);
            btn.disabled = false;
            btn.innerHTML = "Continue";
        } else {
            var m = Math.floor(seconds / 60);
            var s = seconds % 60;
            btn.innerHTML = "Please review the screen (" + m + ":" + (s < 10 ? "0" : "") + s + " remaining)";
        }
    }, 1000);
});
```

**Before the next page, log:** `stimulus_shown = 1`, `condition = [A/B/C/D]`, `time_on_stimulus` in seconds.

### Transition screen (between stimulus and questions)

*Text/Graphic block — no response required.*

---

**The interface screen is now hidden. Please answer the following questions from memory.**

*Take your time. There are no trick questions.*

---

## §6 Comprehension Questions (Q1–Q5)

Each of Q1–Q4 is followed immediately by a confidence item on the same page. Q5 is on a separate page.

---

### Q1 — Vote-counted inference

**Correct answer: Yes**  
*(Tests basic comprehension: the identifier proves the vote was included in the tally.)*

**Question text:**  
*"After voting, the system showed you your [LABEL]. Does having this [LABEL] prove that your vote was counted?"*

| Option | Code |
|--------|------|
| Yes | 1 (correct) |
| No | 0 |
| I'm not sure | 0 |

**Q1-confidence:**  
*"How confident are you in your answer above?"*  
7-point Likert: 1 = *Not at all confident* … 7 = *Completely confident*

---

### Q2 — Representational schema: choice visibility

**Correct answer: No**  
*(Primary endpoint for H2. Tests whether the label activates an opacity or confirmation-of-choice schema.)*

**Question text:**  
*"The [LABEL] is a string of numbers and letters that is unique to your vote. Does having this [LABEL] prove which voting option you chose?"*

| Option | Code |
|--------|------|
| Yes | 0 |
| No | 1 (correct) |
| I'm not sure | 0 |

**Q2-confidence:**  
*"How confident are you in your answer above?"*  
7-point Likert: 1 = *Not at all confident* … 7 = *Completely confident*

---

### Q3 — Privacy mental model: coercion scenario

**Correct answer: No**  
*(Tests whether participants understand that the receipt does not disclose their vote choice to a third party.)*

**Question text:**  
*"Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?"*

| Option | Code |
|--------|------|
| Yes | 0 |
| No | 1 (correct) |
| I'm not sure | 0 |

*Implementation note: A brief "Scenario context" line can appear in smaller text beneath the question: "This is a hypothetical scenario to test your understanding of what the screen reveals. It does not reflect a real situation."*

**Q3-confidence:**  
*"How confident are you in your answer above?"*  
7-point Likert: 1 = *Not at all confident* … 7 = *Completely confident*

---

### Q4 — Receipt utility: what happens if you lose it?

**Correct answer: (b)**  
*(Tests whether participants understand the identifier is a personal verification tool, not a condition for the vote being counted.)*

**Question text:**  
*"If you closed this screen without saving your [LABEL], what would happen?"*

| Option | Code |
|--------|------|
| (a) My vote would be cancelled or reversed | 0 |
| (b) I could still verify that my vote was counted, but I would not have this [LABEL] as personal proof | 1 (correct) |
| (c) The voting system keeps a copy of my [LABEL], so I could always retrieve it later | 0 |
| (d) Nothing — my vote does not depend on having this [LABEL] | 0 |

*Note: Option (d) is partially correct (vote is not affected) but misses the verification function. Score as 0 per the pre-registration. If exploring partial credit is of interest, code (d) separately and treat as exploratory analysis only.*

**Q4-confidence:**  
*"How confident are you in your answer above?"*  
7-point Likert: 1 = *Not at all confident* … 7 = *Completely confident*

---

### Q5 — Mechanism: why is vote choice hidden?

**Open-ended — scored by two independent raters (see §8 Rubric)**  
*(Tests whether participants can articulate the privacy mechanism, not just recognise it.)*

**Question text:**  
*"In your own words: why might this voting system choose NOT to show you which option you voted for on this screen?"*

*Free text entry. Minimum character limit: 20 characters.*

---

## §7 Secondary Items

### Mental model quality item (MQ1)

*Displayed after Q5, before behavioral intent. Open-ended — scored by two raters (see §8).*

**Question text:**  
*"In your own words: what does your [LABEL] prove about your vote?"*

*Free text entry. Minimum character limit: 20 characters.*

*Note (2026-06-25): The two-part wording "What does it NOT prove?" was removed — it creates a demand characteristic that inflates non-leakage scores and reduces sensitivity to between-condition differences on the MQ1 non-leakage dimension. Pre-reg single-question wording restored. See `docs/piup-study1-pilot-decisions-2026-06-25.md` §Item D.*

---

### Behavioral intent item (BI1)

**Question text:**  
*"If this was a real election and you saw this screen after submitting your vote, how likely would you be to save this code for future reference?"*

*Note (2026-06-25): "[LABEL]" replaced with "this code" to remove label-name demand characteristic from behavioral intent measure. See `docs/piup-study1-pilot-decisions-2026-06-25.md` §Item E.*

| Option | Code |
|--------|------|
| Definitely would save it | 5 |
| Probably would save it | 4 |
| Might or might not | 3 |
| Probably would not save it | 2 |
| Definitely would not save it | 1 |

---

### Label affect item (LA1)

**Question text:**  
*"What is your first impression of the term '[LABEL]' as a name for this identifier?"*

Slider: −3 (*Very negative*) to +3 (*Very positive*), default midpoint 0. Display tick marks at −3, −2, −1, 0, +1, +2, +3 with labels *Very negative* / *Neutral* / *Very positive*.

---

## §8 Attention Checks

### AC1 — Follow-instruction check (placed before comprehension block)

**Question text:**  
*"This is an attention check to make sure you are reading carefully. Please select 'Strongly Disagree' as your response to this question, regardless of what it says."*

| Option | Code |
|--------|------|
| Strongly Agree | Fail |
| Agree | Fail |
| Neither Agree nor Disagree | Fail |
| Disagree | Fail |
| Strongly Disagree | Pass ✓ |

---

### AC2 — Forced-choice check (placed after label affect item, before demographics)

**Question text:**  
*"Please select the third item from the list below."*

| Option | Code |
|--------|------|
| Apple | Fail |
| Banana | Fail |
| Carrot | Pass ✓ |
| Dog | Fail |
| Elephant | Fail |

**Exclusion rule (pre-registered):** Participants who fail BOTH AC1 and AC2 are excluded from all analyses. Participants who fail only one are retained (single attention lapse is not treated as disqualifying). Record individual AC responses in the dataset — do not apply exclusion at Qualtrics level; apply in the R analysis script (see `analysis/piup-study1-analysis.R` §Exclusions).

---

## §9 Demographics

### DM1 — Age range

*"What is your age?"*

18–24 / 25–34 / 35–44 / 45–54 / 55–64 / 65 or older / Prefer not to say

### DM2 — Technology background (secondary exclusion check)

*"Have you ever written code professionally or as part of a degree?"*

| Option | Code |
|--------|------|
| Yes — as my main job | Flag for sensitivity analysis |
| Yes — occasionally / as part of a degree | Flag for sensitivity analysis |
| No | Reference group |
| Prefer not to say | Include |

*Note: SC2 (screener) excludes practising software engineers before they reach this point. DM2 is a secondary cross-check for sensitivity analysis only — it does not trigger exclusion. Compare results with and without DM2-flagged participants in exploratory analysis.*

### DM3 — Prior voting experience specificity

*"Which of the following have you participated in? (Select all that apply)"*

- An online opinion poll or workplace survey
- A national or local government election (online or paper)
- A student body or organisational election (online or paper)
- I have never voted in any election or poll *(triggers flag — inconsistent with SC1; log but do not auto-exclude)*
- Prefer not to say

---

## §10 Debrief Screen

*Text/Graphic block — no response required.*

---

**Thank you for your participation.**

This study examined how different labels for a voting identifier affect people's understanding of what it proves. In real private voting systems, the identifier — whether it is called a "vote fingerprint," a "confirmation code," or something else — proves only that your vote was counted, not which option you chose.

The study is being conducted as part of research on the usability of privacy-preserving voting technology. If you have questions about the study, please contact the research team via Prolific.

**Compensation:** You will receive your Prolific payment regardless of your answers. There are no correct or incorrect answers from a payment perspective.

*Your completion code will appear on the next screen.*

---

## §11 Scoring Rubric — Open-Ended Items

### Q5 Rubric ("In your own words: why might this voting system choose NOT to show you which option you voted for on this screen?")

Two independent raters score each response on a 0–2 scale.

| Score | Criteria |
|-------|----------|
| **2** | Response mentions **both**: (1) protecting voter privacy or anonymity AND (2) a reason why the system does not store or reveal the choice (e.g., "the system doesn't know / wasn't designed to record your choice," "to protect ballot secrecy," "to prevent coercion"). The two concepts may be expressed together. |
| **1** | Response mentions **one of**: privacy, anonymity, secrecy of the ballot, protection from coercion, or avoiding surveillance — without fully explaining the mechanism. Generic responses like "for privacy" count as 1. |
| **0** | No correct privacy concept. Includes: "I don't know," technical error attribution, "to save storage," "because it is encrypted" without connecting to privacy, or responses expressing pure confusion. |

**IRR note:** κ ≥ 0.70 required before including Q5 in any analysis (pre-registered in `piup-study1-preregistration-2026-06-22.md` §6.8). Score independently; reconcile disagreements by discussion. If κ < 0.70 on pilot data, revise rubric before full study launch (this constitutes a protocol amendment).

---

### Mental Model Quality Rubric (MQ1: "In your own words: what does your [LABEL] prove about your vote?")

*Note (2026-06-25): Question updated to single-question wording ("What does it NOT prove?" removed to avoid demand characteristic; see §7 and pilot-decisions doc §Item D). The two-dimensional rubric is unchanged — Dimension 2 (Non-leakage) is coded from responses that voluntarily mention what the identifier does not reveal. Removal of the prompt may reduce the frequency of non-leakage responses; this is a known sensitivity trade-off accepted in the pilot-launch decision.*

Two-dimensional scoring: 0–2 total.

| Dimension | Score 1 = present | Score 0 = absent |
|-----------|-------------------|------------------|
| **Inclusion** | Response states the [LABEL] proves the vote was **counted / included / processed** by the system. Synonyms acceptable: "was submitted," "went through," "was recorded." | Response omits the counting/inclusion concept entirely, or only references a different claim (e.g., "it proves I voted" without any tally implication). |
| **Non-leakage** | Response states the [LABEL] does **NOT** prove the voter's specific choice / option / candidate preference. Synonyms: "doesn't show how I voted," "doesn't reveal my choice," "can't tell which option." | Response omits the non-leakage concept, or implies the [LABEL] does reveal the choice. |

**Total:** 0, 1, or 2. Use 2 as the pre-specified threshold for "full credit" in descriptive breakdowns. In the R analysis script, `MQ_SCORE` is the sum of the two dimensions (0–2).

**IRR:** Same κ ≥ 0.70 threshold as Q5. Both items must meet threshold before any MQ analysis is included in the pre-registered results.

---

## §12 Qualtrics Implementation Notes

### Condition assignment

Prolific study URL passes the condition as a URL parameter:

```
https://your-qualtrics-survey.com/jfe/form/SV_XXXX?condition=A&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

In Qualtrics Survey Flow (Survey Flow → Add a New Element → Embedded Data), set:

```
condition   = (from URL)
PROLIFIC_PID = (from URL)
```

Then immediately below, add a Branch logic block to set `condition_label`:

```
If condition = A → condition_label = vote fingerprint
If condition = B → condition_label = confirmation code
If condition = C → condition_label = nullifier
If condition = D → condition_label = receipt ID
```

All question text uses `${e://Field/condition_label}` wherever `[LABEL]` appears in this document.  
Stimulus URL uses `${e://Field/condition}` to select the correct HTML file.

### Randomisation (alternative to URL parameter)

If Prolific does not support URL parameter condition assignment, use a Qualtrics Randomizer block at the survey start to randomly assign participants to conditions A–D. Set `condition` and `condition_label` via the branch logic above. Even randomisation (n = 50 per condition) should be enforced using Qualtrics Quotas.

### Timing data

Add Embedded Data `time_on_stimulus` (set via the stimulus page JavaScript) and `total_time_seconds` (Qualtrics built-in timing question). Both should be recorded in every export row and passed to the R analysis script as filtering variables (`total_time_seconds < 90` → exclude for pre-specified minimum-time exclusion).

### Block randomisation

Q1–Q4 are presented in a **fixed order** (not randomised). Question order randomisation is NOT used — the questions build on each other conceptually, and changing order would invalidate the composite accuracy score and the H2-tertiary pre-registration. Do not change question order after OSF registration.

### Prolific completion

Display Prolific completion code on the final screen using a Text/Graphic block with embedded data pipe:

```
Your completion code is: [PROLIFIC_COMPLETION_CODE]
```

Set up a Screen Out URL in Prolific for SC1/SC2 failures to avoid paying screen-outs.

---

## §13 Variable Codebook

| Variable name | Type | Description |
|---------------|------|-------------|
| `PROLIFIC_PID` | string | Participant Prolific ID |
| `condition` | string (A/B/C/D) | Assigned condition |
| `condition_label` | string | Human-readable label for assigned condition |
| `SC1` | binary | 1 = pass screener (voted past 12m), 0 = fail |
| `SC2_occupation` | string | Raw occupation bucket |
| `Q1` | binary | 1 = correct (Yes), 0 = incorrect |
| `Q2` | binary | 1 = correct (No), 0 = incorrect |
| `Q3` | binary | 1 = correct (No), 0 = incorrect |
| `Q4` | binary | 1 = correct (b), 0 = incorrect |
| `Q5_text` | string | Raw open-ended response |
| `Q5_score_r1` | 0/1/2 | Q5 score, rater 1 |
| `Q5_score_r2` | 0/1/2 | Q5 score, rater 2 |
| `Q5_score_final` | 0/1/2 | Q5 final score (average, rounded; or resolved by discussion) |
| `Q1_conf` … `Q4_conf` | 1–7 | Confidence rating per question |
| `MQ1_text` | string | Raw mental model quality response |
| `MQ1_inclusion_r1` | 0/1 | Inclusion dimension, rater 1 |
| `MQ1_leakage_r1` | 0/1 | Non-leakage dimension, rater 1 |
| `MQ1_inclusion_r2` | 0/1 | Inclusion dimension, rater 2 |
| `MQ1_leakage_r2` | 0/1 | Non-leakage dimension, rater 2 |
| `MQ_SCORE` | 0/1/2 | Final summed MQ score |
| `BI1` | 1–5 | Behavioral intent (save the receipt) |
| `LA1` | −3 to +3 | Label affect slider |
| `AC1` | pass/fail | Attention check 1 |
| `AC2` | pass/fail | Attention check 2 |
| `DM1_age` | ordinal | Age range bucket |
| `DM2_code` | string | Technology background flag |
| `DM3_voting` | multi-select | Voting experience specifics |
| `time_on_stimulus` | seconds | Time spent on stimulus screen |
| `total_time_seconds` | seconds | Total survey duration |
| `EXCLUDE_dual_attn_fail` | binary | 1 = failed both AC1+AC2, exclude from analysis |
| `EXCLUDE_speed` | binary | 1 = total_time_seconds < 90, exclude from analysis |

The R analysis script (`analysis/piup-study1-analysis.R`) references these column names via the `COL_*` constants at the top of the file. Update those constants to match the actual Qualtrics export column names before running.

---

## §14 Amendments Log

| Date | Amendment type | Description | Authorized by |
|------|---------------|-------------|---------------|
| (none at pre-registration) | — | — | — |
| 2026-06-25 (pre-pilot, pre-OSF) | Question wording — D | MQ1 "What does it NOT prove?" prompt removed. Reverted to pre-reg single-question wording to avoid demand characteristic. See piup-study1-pilot-decisions-2026-06-25.md §Item D. | @jonybur-oc |
| 2026-06-25 (pre-pilot, pre-OSF) | Question wording — E | BI1 "your [LABEL]" replaced with "this code" to remove label-name demand from behavioral intent measure. Scale labels updated to match question. Coding unchanged. See piup-study1-pilot-decisions-2026-06-25.md §Item E. | @jonybur-oc |
| PENDING (Jony decision) | Question wording — A | Q3 coercion scenario: recommend instrument wording over pre-reg wording. Construct specificity + ecological validity. Correct answer + tests unchanged. See piup-study1-pilot-decisions-2026-06-25.md §Item A. | Pending |
| PENDING (Jony decision) | Question wording — B | Q4 "closed screen" replaces "lost this value"; foils consolidated. Correct answer unchanged. See piup-study1-pilot-decisions-2026-06-25.md §Item B. | Pending |
| PENDING (Jony decision) | Baseline clarification — C | Q3 "assume only on screen" clarification dropped from baseline; "hypothetical scenario" note becomes optional. See piup-study1-pilot-decisions-2026-06-25.md §Item C. | Pending |

---

*Author: Jony Bursztyn · 2026-06-22*  
*This survey instrument is part of the pre-registered PIUP Study 1 protocol. Changes to question wording, answer options, or scoring rubrics after OSF upload must be logged above and noted as amendments in the pre-registration record.*
