# Survey Instrument: PIUP Study 3 — Social Proof and Verification Return Rate

**Date:** 2026-07-01 (tick-4430)  
**Author:** Jony Bursztyn  
**Status:** Pre-pilot draft — ⚠️ DV3 item wording and M1 wording pending Jony's decision before OSF filing (decision memos written: DV3 tick-4437, M1 tick-4438; see §5.2 and §3.2 respectively)  
**Companion documents:**
- [`docs/piup-study3-osf-prereg-2026-07-01.md`](piup-study3-osf-prereg-2026-07-01.md) — pre-registration
- [`docs/piup-study3-debrief-script-2026-06-30.md`](piup-study3-debrief-script-2026-06-30.md) — full T+14 debrief script (verbatim text for all four screens)
- [`analysis/piup-study3-analysis.R`](../analysis/piup-study3-analysis.R) — pre-registered analysis script (variable names must match §10 codebook)
- [`docs/piup-study1-survey-instrument-2026-06-22.md`](piup-study1-survey-instrument-2026-06-22.md) — Study 1 instrument (Q1–Q4 source for DV3 adaptation)

This document specifies the **exact question wording, answer options, scoring rubrics, and implementation notes** for Study 3. Study 3 has two survey touch-points:

- **T0** — Embedded in the receipt UI immediately after ballot submission; covers consent, DV2, and M1.
- **T+14** — Delivered via link 14 days after ballot submission; covers debrief, withdrawal, DV3, DV4, and C1.

Any change to pre-registered question wording, answer options, or scoring rubrics after OSF registration constitutes an amendment and must be logged in §11.

---

## §1 Study Overview and Participant Context

This is a **field experiment**, not a Prolific panel study. Participants are real voters in a live DAO election deployed on the Aztec Private Voting v5 contract. They are not recruited through an online panel; they are already voters.

Key differences from Study 1 (which shapes the instrument design):

| Feature | Study 1 | Study 3 |
|---------|---------|---------|
| Recruitment | Prolific (panel) | Real DAO voters |
| Stimulus | Static mockup | Live election receipt |
| Screeners | Required (SC1, SC2) | Not needed (voters already eligibility-confirmed) |
| T0 instrument | Standalone Qualtrics survey | Embedded in receipt UI |
| Follow-up | None (single-session) | T+14 survey link |
| Debrief | At end of single session | At start of T+14 (before T+14 measures) |
| Condition assignment | Prolific URL parameter | Server-side randomisation at ballot submission |

---

## §2 Study Flow

### T0 (Day 0 — at receipt display)
1. Participant submits ballot; redirected to PIUP receipt
2. Receipt displays: fingerprint, verification instruction, download button, ± social proof counter (condition-dependent)
3. T0 consent screen (embedded in receipt UI)
4. T0 survey questions: DV2 (intent), M1 (self-efficacy) — displayed as a brief in-receipt survey block

### T+14 (Day 14 — via follow-up link)
1. Participant receives the T+14 survey link (sent via the platform's own messaging, not by the agent)
2. Debrief (Screens 1–4 of the debrief script) — presented before any T+14 measures
3. Withdrawal screen — participant confirms data use or withdraws
4. T+14 survey questions: DV3 (comprehension), DV4 (trust/affect), C1 (open-ended reason)
5. Closing screen with completion confirmation

---

## §3 T0 Survey (Embedded in Receipt UI)

### §3.1 T0 Consent and Log Opt-In

*Displayed as a consent block in the receipt UI, after the receipt is shown and download opportunity provided.*

---

**Research consent**

You have just submitted your vote. We are conducting research on how voters use their vote receipts — specifically, whether voters come back to verify their receipt over the next 14 days.

- **What we will record:** Whether you return to verify your vote within 14 days (counted from your ballot timestamp). We will also ask two brief questions now.
- **No vote content is recorded:** Your vote choice is never logged or shared. Only your receipt ID (a pseudonymous identifier, not linked to your wallet) is used to match a verification event to your consent record.
- **Optional log opt-in (below):** If you opt in, we will also log the timestamps of any verification calls you make (for time-to-verify analysis). This is separate from the main study — you can participate without opting in.
- **Follow-up survey:** In 14 days, you will receive a brief survey link. Completing it is optional but appreciated.
- **Withdrawal:** At the 14-day survey, you will have the option to withdraw your data entirely before answering any questions.

*"I understand and consent to my verification behaviour being tracked for 14 days as part of this research study."*  

| Option | Code |
|--------|------|
| ✅ I consent | Continue to T0 questions |
| ❌ I do not consent | Do not record this participant; exit survey block |

**Optional: Host server log opt-in (for timing analysis)**

*"I also consent to my verification timestamps being logged to the study's host server (if I verify). This adds time-of-verification data to the study."*

_[Amendment tick-4457 — host server log opt-in wording correction (companion to pre-reg §3.2 tick-4453, §5+§7 tick-4454, Qualtrics guide tick-4456, analysis script tick-4457): "on-chain verification timestamps" corrected to "verification timestamps logged to the study's host server". verify_vote_counted() is a view function; no on-chain record is created. The host server (serverless API + KV store) logs timestamp + outcome + receipt ID (no wallet address). Consent semantics unchanged: participant is consenting to the host server log being used for the time-to-verify survival analysis (DV5/RQ3c). | Jony Bursztyn]_

| Option | Code |
|--------|------|
| ✅ Yes, log my timestamps | `log_optin = 1` |
| ❌ No, only track whether I verified | `log_optin = 0` |

---

### §3.2 DV2 — Stated Intent to Verify

*Displayed immediately after consent, still within the receipt UI.*

**Question text:**  
*"How likely are you to come back to this receipt to verify your vote was counted?"*

| Option | Code |
|--------|------|
| 1 — Very unlikely | 1 |
| 2 | 2 |
| 3 — Unsure | 3 |
| 4 | 4 |
| 5 — Quite likely | 5 |
| 6 | 6 |
| 7 — Very likely | 7 |

**Variable name (analysis.R):** `dv2_intent` (integer 1–7)

**Implementation note:** Participants who vote after the counter floor (≥ 5 verified) is reached will have already seen the social proof counter when this question is asked. These participants' DV2 is post-treatment and should be flagged `late_voter = 1` in the dataset (see §10 codebook). The primary analysis includes DV2 as a covariate regardless; see SA-3 sensitivity analysis (pre-reg §7.8) for timing heterogeneity.

---

### §3.3 M1 — Technology Self-Efficacy

*4-item adapted Compeau-Higgins scale. Displayed immediately after DV2.*

**Preamble text:**  
*"The following questions are about your confidence using online tools. There are no right or wrong answers."*

> ⚠️ **JONY DECISION REQUIRED: M1 item wording (recommended draft below)**  
> The pre-registration specifies "4-item adapted Compeau-Higgins scale (1–5 each, mean composite)" but does not give verbatim item text. The items below are a recommended adaptation for the receipt/verification context. Confirm or revise before OSF filing.

---

**Recommended M1 item wording (4 items, 1–5 Likert each):**

Scale labels: 1 = *Not confident at all* … 5 = *Very confident*

| # | Item text | Variable |
|---|-----------|----------|
| M1-1 | *"I could use the receipt verification link even if no one was available to help me."* | `m1_eff1` |
| M1-2 | *"I could verify my vote receipt even if I had never done anything like it before."* | `m1_eff2` |
| M1-3 | *"I could use the receipt verification link if I had brief written instructions available."* | `m1_eff3` |
| M1-4 | *"I could figure out the verification steps on my own by trying them."* | `m1_eff4` |

**Scoring:** Mean composite across M1-1 to M1-4. `m1_composite = mean(m1_eff1, m1_eff2, m1_eff3, m1_eff4)`. Mean-centred in analysis script (`m1_c`). See `analysis/piup-study3-analysis.R` §§7.1, 7.4.

**Note on item order:** Present M1 items in fixed order (not randomised). The items are not hypothesised to interact with each other in order-dependent ways, but consistent ordering avoids a protocol amendment.

---

## §4 T+14 Survey Structure

The T+14 survey is delivered 14 calendar days after ballot submission. The debrief must appear **before** any T+14 measures are collected.

**Survey flow:**

1. Debrief Screen 1 — study disclosure (treatment/control assignment)
2. Debrief Screen 2 — what was manipulated and why
3. Debrief Screen 3 — withdrawal option (must acknowledge before proceeding)
4. Debrief Screen 4 — contact information
5. **[If withdrawn → end survey; trigger data deletion pipeline]**
6. DV3 — Verification comprehension questions (adapted Q1–Q4)
7. DV4 — Receipt trust/affect composite
8. C1 — Open-ended reason (verifying or not verifying)
9. Closing screen

**Debrief text:** See [`docs/piup-study3-debrief-script-2026-06-30.md`](piup-study3-debrief-script-2026-06-30.md) for verbatim text of all four debrief screens. Do not paraphrase in implementation — use the exact text.

---

## §5 T+14 Survey Questions

### §5.1 Transition screen (between debrief and DV3)

*Text block — no response required. Displayed after participant confirms data use on Debrief Screen 3.*

---

**Survey: Vote receipt research — follow-up questions**

Thank you for agreeing to continue. The following questions take approximately 3–5 minutes.

*Please answer from your current understanding of the voting system — not from the information in the debrief you just read. We are measuring what you had learned by the time you voted, not what you have just been told.*

---

### §5.2 DV3 — Verification Comprehension (adapted Q1–Q4 from Study 1)

> ⚠️ **JONY DECISION REQUIRED: DV3 item wording (see options below)**  
> The pre-registration specifies "abbreviated Q1–Q4 rubric adapted from Study 1 (L2 context-shift note: rubric adapted to measure comprehension of verification purpose — whether the participant correctly understands that verifying confirms counting but not vote content)." The pre-reg does not give verbatim item text. The items below are a recommended adaptation. Jony must confirm or revise item wording and select a scoring rule before OSF filing.  
> **This is the blocking gap from `docs/piup-study3-crosscheck-2026-07-01.md` Gaps 2 and 3.**

---

**Construct being measured (from pre-reg §5):** Whether the participant correctly understands that verifying their receipt confirms that their vote was *counted*, but does **not** reveal *which option* they voted for. This is the "verification purpose" mental model — distinct from the "label-level privacy mental model" measured in Study 1.

**Source items (Study 1 Q1–Q4):**

| Q | Study 1 construct | Study 1 question (abbreviated) | Correct answer |
|---|---|---|---|
| Q1 | Vote counted? | Does your [LABEL] prove your vote was counted? | Yes |
| Q2 | Choice visible? | Does your [LABEL] prove which option you chose? | No |
| Q3 | Coercion scenario | If you showed your screen to a third party, could they tell which option you voted for? | No |
| Q4 | Receipt utility | If you closed the screen without saving, what would happen? | (b) could still vote but no personal proof |

**Recommended adapted items for Study 3 (for Jony's decision):**

*Preamble text:*  
*"The following questions are about the vote verification feature you were offered after submitting your ballot. Please answer based on your understanding."*

| # | Adapted question | Correct answer | Variable | Study 1 source |
|---|---|---|---|---|
| DV3-1 | *"Does verifying your receipt confirm that your vote was counted?"* | Yes | `dv3_q1` | Q1 |
| DV3-2 | *"If you verify your receipt, does that reveal which option you voted for?"* | No | `dv3_q2` | Q2 |
| DV3-3 | *"If you showed your receipt link to another person, could they learn which option you chose?"* | No | `dv3_q3` | Q3 |
| DV3-4 | *"What does successful verification prove about your vote?"* | Counted, not choice | `dv3_q4` | Q4 |

**Answer options by item:**

*DV3-1:*  
- Yes *(correct = 1)*  
- No *(correct = 0)*  
- I'm not sure *(correct = 0)*

*DV3-2:*  
- Yes *(correct = 0)*  
- No *(correct = 1)*  
- I'm not sure *(correct = 0)*

*DV3-3:*  
- Yes *(correct = 0)*  
- No *(correct = 1)*  
- I'm not sure *(correct = 0)*

*DV3-4 (multi-choice):*  
- (a) That I voted for the winning option *(correct = 0)*  
- (b) That my vote was included in the tally — but not which option I chose *(correct = 1)*  
- (c) That the voting system recorded my vote choice *(correct = 0)*  
- (d) I'm not sure what verification proves *(correct = 0)*

> ⚠️ **SCORING RULE — JONY DECISION REQUIRED (Gap 3 from crosscheck):**  
> The analysis script treats `dv3_comprehension` as a single 0/1 binary column. Two options:  
> **Option A (recommended):** Strict composite — `dv3_comprehension = 1` if *all four* items (DV3-1, DV3-2, DV3-3, DV3-4) are answered correctly; 0 otherwise. Matches analysis script's binary treatment and parallels Study 1 composite accuracy.  
> **Option B:** Majority rule — `dv3_comprehension = 1` if ≥ 3 of 4 items correct; 0 otherwise. More lenient; would require updating the analysis script comment and adding a sensitivity analysis with Option A.  
> **Recommend Option A.** Confirm before OSF filing.

**Scoring implementation (if Option A selected):**

```r
# In analysis script: DV3 composite (all-correct binary)
df$dv3_q1_correct <- as.integer(df$dv3_q1 == "Yes")
df$dv3_q2_correct <- as.integer(df$dv3_q2 == "No")
df$dv3_q3_correct <- as.integer(df$dv3_q3 == "No")
df$dv3_q4_correct <- as.integer(df$dv3_q4 == "b")
df$dv3_comprehension <- as.integer(
  df$dv3_q1_correct == 1 &
  df$dv3_q2_correct == 1 &
  df$dv3_q3_correct == 1 &
  df$dv3_q4_correct == 1
)
```

*This scoring code should be added to `analysis/piup-study3-analysis.R` at the data-prep block, replacing or supplementing the current `dv3_comprehension = sample(c(0,1), N, ...)` dry-run line, once DV3 item wording is confirmed and column names are known.*

---

### §5.3 DV4 — Receipt Trust and Affect Composite

*Two-item trust composite. Wording fully specified in pre-registration §5 and analysis script header.*

**Question text (item 1):**  
*"The receipt convinced me my vote was counted."*

| Scale | Code |
|-------|------|
| 1 — Strongly disagree | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 — Neither agree nor disagree | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 — Strongly agree | 7 |

**Variable name:** `dv4_trust1` (integer 1–7)

---

**Question text (item 2):**  
*"I understand what the receipt is for."*

| Scale | Code |
|-------|------|
| 1 — Strongly disagree | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 — Neither agree nor disagree | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 — Strongly agree | 7 |

**Variable name:** `dv4_trust2` (integer 1–7)

**Composite scoring:** `dv4_trust = mean(dv4_trust1, dv4_trust2)`. No IRR required (fixed wording, single-rater numerical items). Missing data: if either item is NA, `dv4_trust = NA`.

---

### §5.4 C1 — Stated Reason for Verifying / Not Verifying

*Open-ended. Qualitative only; not coded for confirmatory analysis. Used to generate hypotheses for powered replication.*

**Branch logic:** Two versions based on whether participant verified at T+14 (derived from DV1 at data analysis, not from live Qualtrics branching — ask both versions as a single question with response options).

**Question text:**  
*"Did you come back to verify your receipt after voting? Please tell us why or why not. There is no right or wrong answer."*

*Free text entry. Minimum 10 characters. No scoring.*

**Variable name:** `c1_reason` (character, raw text)

**Analysis note:** Qualitative only. No pre-registered coding. Used for hypothesis generation for the powered replication. Two independent coders will thematically code responses after data collection; coding scheme is not pre-specified and findings will be labelled exploratory.

---

## §6 Closing Screen

*Text block — no response required.*

---

**Thank you for participating in this study.**

Your responses have been recorded. You may close this window.

This study is investigating whether public information about how many other voters verified their receipts affects people's likelihood of verifying their own receipt. Your participation contributes to research on usable privacy-preserving voting systems.

If you have questions about the study or your data, contact:  
**[PI name]** — [PI email]  
**IRB contact:** [Institution IRB email]

---

## §7 Timing and Delivery

**T0 survey:** Embedded in receipt UI. No separate Qualtrics link. Response timing should be captured in the receipt session log.

**T+14 survey:** Delivered via link sent through the DAO platform's native communication. The link should be pre-parameterised with:

```
?participant_id=[PSEUDONYMOUS_RECEIPT_ID]&condition=[A/B]&study=piup-study3
```

Or, if using Qualtrics: encode `participant_id` and `condition` as URL parameters and set as Qualtrics Embedded Data in the Survey Flow.

**Minimum viewing time:** No minimum enforced at T+14 (unlike Study 1's 90-second stimulus gate). Participants have already had 14 days to think about verification.

**T+14 access window:** The survey link should remain active for 7 days after T+14 (i.e., days 14–21 post-vote). Responses received after day 21 are excluded per the pre-registration exclusion criteria.

---

## §8 Condition Assignment and Embedded Data

**Server-side (T0):** At ballot submission, the receipt server assigns `condition = "A"` (control) or `condition = "B"` (treatment) with a fair coin flip. This is logged server-side along with `participant_id = [receipt_id]` (pseudonymous, not wallet-linked).

**Embedded data flow:**

```
T0: condition → stored in receipt session record
T+14 link: condition passed as URL parameter → Qualtrics Embedded Data → debrief Screen 1 condition disclosure
```

**Debrief disclosure label:**  
- `condition = A` → `condition_label = "Group A (standard receipt)"`
- `condition = B` → `condition_label = "Group B (receipt with verification count)"`

See debrief script for how `[GROUP_ASSIGNMENT]` is piped into Screen 1.

---

## §9 Exclusions at Analysis Stage

These are applied in `analysis/piup-study3-analysis.R` at the data-prep block; do not exclude via Qualtrics flow.

| Exclusion | Rule | Variable flag |
|-----------|------|---------------|
| No T0 consent | `consent_t0 = 0` | `EXCLUDE_no_consent` |
| T+14 withdrawal | Participant selected "delete my data" on debrief Screen 3 | `EXCLUDE_withdrawal` |
| Survey link expired | T+14 response received > 21 days post-vote | `EXCLUDE_late_t14` |
| Invalid participant_id | `participant_id` not in T0 consent record | `EXCLUDE_invalid_id` |

Note: No attention checks are included in this instrument. Study 3 participants are real voters in an election (not a Prolific panel); attention-check-based exclusion is not appropriate in this context. Data quality is assessed via response time logs and C1 open-ended quality.

---

## §10 Variable Codebook

| Variable name | Type | Description | Survey timing |
|---------------|------|-------------|--------------|
| `participant_id` | string | Pseudonymous receipt ID (not wallet-linked) | T0 (server-assigned) |
| `condition` | string (A/B) | A = control, B = treatment | T0 (server-assigned) |
| `consent_t0` | binary 0/1 | 1 = consented to behavioral tracking | T0 |
| `log_optin` | binary 0/1 | 1 = consented to host server verification log | T0 |
| `dv2_intent` | integer 1–7 | Stated intent to verify ("How likely are you to come back...") | T0 |
| `late_voter` | binary 0/1 | 1 = voted after counter floor reached (DV2 post-treatment) | T0 (derived) |
| `m1_eff1` | integer 1–5 | Self-efficacy item 1 (no help available) | T0 |
| `m1_eff2` | integer 1–5 | Self-efficacy item 2 (never done before) | T0 |
| `m1_eff3` | integer 1–5 | Self-efficacy item 3 (brief instructions) | T0 |
| `m1_eff4` | integer 1–5 | Self-efficacy item 4 (figure out on own) | T0 |
| `m1_composite` | numeric | Mean of m1_eff1–m1_eff4 (computed in R) | T0 (derived) |
| `dv1_verified` | binary 0/1 | 1 = participant self-reported verifying receipt by T+14 | T+14 |
| `dv1_onchain` | binary 0/1 or NA | 1 = host server log verification confirmed (verify_vote_counted() view simulation logged by host); NA if no log opt-in | T+14 (log) |
| `withdrawal` | binary 0/1 | 1 = participant withdrew data at T+14 debrief | T+14 |
| `dv3_q1` | string | DV3 item 1 response (raw Qualtrics value) | T+14 |
| `dv3_q2` | string | DV3 item 2 response | T+14 |
| `dv3_q3` | string | DV3 item 3 response | T+14 |
| `dv3_q4` | string | DV3 item 4 response | T+14 |
| `dv3_comprehension` | binary 0/1 | All-correct composite (computed in R from dv3_q1–q4) | T+14 (derived) |
| `dv4_trust1` | integer 1–7 | "The receipt convinced me my vote was counted" | T+14 |
| `dv4_trust2` | integer 1–7 | "I understand what the receipt is for" | T+14 |
| `dv4_trust` | numeric | Mean of dv4_trust1 + dv4_trust2 (computed in R) | T+14 (derived) |
| `c1_reason` | string | Open-ended reason for verifying / not verifying | T+14 |
| `t14_response_day` | integer | Days since T0 that T+14 survey was completed | T+14 |
| `EXCLUDE_no_consent` | binary | 1 = no T0 consent; exclude from all analyses | Derived |
| `EXCLUDE_withdrawal` | binary | 1 = data withdrawal at T+14 debrief | Derived |
| `EXCLUDE_late_t14` | binary | 1 = T+14 response received > 21 days post-vote | Derived |
| `EXCLUDE_invalid_id` | binary | 1 = participant_id not in T0 consent record | Derived |

The R analysis script (`analysis/piup-study3-analysis.R`) uses these column names in the dry-run data simulation and the analysis functions. Update the `COL_*` constants or column-rename section when actual Qualtrics export column names are known.

---

## §11 Open Decisions (Pre-OSF)

| # | Item | Status | Required action |
|---|------|--------|-----------------|
| DV3-A | DV3 item wording (4 adapted items) | **⏳ JONY DECISION** (memo written tick-4437) | Review `docs/piup-study3-dv3-specification-2026-07-02.md`; confirm DV3-3A or DV3-3B; paste amendment §4 |
| DV3-B | DV3 scoring rule (strict vs majority) | **⏳ JONY DECISION** (memo written tick-4437) | Confirm Option A (all-correct, recommended) or select Option B; no script change needed for Option A |
| M1-W | M1 item wording (4 Compeau-Higgins items) | **⏳ JONY DECISION** (memo written tick-4438) | Review `docs/piup-study3-m1-item-review-2026-07-02.md`; confirm M1-3 Option A or keep original; paste amendment §4 |
| IRB | Debrief placeholder fields | **⏳ JONY** | Fill [PI name], [PI email], [Institution], [IRB protocol number] in debrief script §4 |
| T14-LINK | T+14 survey link delivery mechanism | **⏳ JONY** | Confirm which DAO platform tool sends the T+14 link |

---

## §12 Amendments Log

| Date | Amendment type | Description | Authorized by |
|------|---------------|-------------|---------------|
| (none at pre-registration) | — | — | — |

---

*Author: Jony Bursztyn · 2026-07-01 (draft created by OpenClaw tick-4430)*  
*This survey instrument is part of the pre-registered PIUP Study 3 protocol. DV3 item wording (§5.2) and M1 wording (§3.3) must be confirmed by Jony before OSF upload. All changes to confirmed items after OSF upload must be logged above.*
