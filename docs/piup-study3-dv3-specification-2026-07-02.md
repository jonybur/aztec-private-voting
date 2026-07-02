# PIUP Study 3 — DV3 Item Specification and Scoring Rule

**Date:** 2026-07-02 (tick-4437)  
**Status:** Decision memo — **Jony must approve item wording + scoring rule before OSF filing**  
**Author:** OpenClaw Agent  
**Resolves:** `docs/piup-study3-crosscheck-2026-07-01.md` Gap 2 (DV3 item wording absent from pre-reg) and Gap 3 (DV3 scoring rule undefined)  
**Connects to:** `docs/piup-study3-survey-instrument-2026-07-01.md §5.2`, `analysis/piup-study3-analysis.R`, `docs/piup-study3-osf-prereg-2026-07-01.md §5`

---

## Summary

The Study 3 pre-reg §5 defines DV3 as "abbreviated Q1–Q4 rubric adapted from Study 1" but gives no verbatim item wording and no composite scoring rule. The survey instrument (§5.2) has draft items marked ⚠️ JONY DECISION REQUIRED. This document:

1. Reviews the four draft items against Study 3's coercion scenario
2. Identifies one misalignment in DV3-3 and proposes a refined version
3. Recommends **Option A (strict composite)** as the scoring rule
4. Provides ready-to-paste amendment text for pre-reg §5 and the OSF amendment log

**Decision required:**
- [ ] Approve or revise DV3-3 (see §2 below)
- [ ] Confirm scoring rule (Option A recommended; see §3)
- [ ] File OSF amendment and update pre-reg §5 (see §4)

---

## 1. Study 3 DV3 context

DV3 measures "comprehension of verification purpose — whether the participant correctly understands that verifying confirms counting but not vote content" (pre-reg §5).

**What makes Study 3 DV3 different from Study 1 Q1–Q4:**

| | Study 1 | Study 3 DV3 |
|---|---|---|
| Stimulus | Static receipt UI (Qualtrics + HTML screenshot) | Real Aztec Private Voting receipt (live election) |
| Construct | Label-level privacy mental model: what does the *identifier label* (fingerprint/code/nullifier/receipt ID) prove? | Verification-purpose mental model: what does the *verification action* reveal? |
| Coercion scenario | Showing the receipt *screen* to a third party (Q3) | Performing verification *in front of* a third party or in a socially observable context |
| Participants | Prolific panel, no real election | Real DAO voters who have already voted |
| DV3 context | T0 (immediate post-receipt) | T+14 (two weeks post-vote; verification may or may not have occurred) |

The core construct is the same (verification does not reveal choice), but the *mechanism* and *coercion scenario* differ. Study 3's manipulation is a social-proof counter: "X voters have verified their receipt." This counter makes verification a socially observable act — a coercer who sees the counter could demand "verify now in front of me." DV3-3 should test whether participants understand that this observable verification action still does not reveal their vote choice.

---

## 2. Item review and refinement

### Draft items (from instrument §5.2)

| # | Draft wording | Correct | Issue |
|---|---|---|---|
| DV3-1 | "Does verifying your receipt confirm that your vote was counted?" | Yes | ✅ Clean. Directly tests the inclusion-confirmation construct. |
| DV3-2 | "If you verify your receipt, does that reveal which option you voted for?" | No | ✅ Clean. Directly tests choice-blindness of the verification action. |
| DV3-3 | "If you showed your receipt link to another person, could they learn which option you chose?" | No | ⚠️ **Misalignment — see below** |
| DV3-4 | "What does successful verification prove about your vote?" | (b) Counted, not choice | ✅ Clean. Tests the combined inference directly. |

### ⚠️ DV3-3: Misalignment with Study 3's coercion scenario

**Current wording:** "If you showed your receipt link to another person, could they learn which option you chose?"

**The problem:** The question is about *sharing a link*, not about *performing verification*. Sharing a link is a receipt-artifact action (closer to the Study 1 Q3 context of showing a screen). Study 3's coercion scenario is specifically about the *verification action* being socially observable — a coercer sees the social-proof counter and demands you verify on the spot. The correct comprehension question tests whether participants understand that performing verification publicly does not leak their vote choice.

**Why this matters:** If DV3-3 tests "shared a link → reveals choice?" instead of "verified in front of someone → reveals choice?", it measures a slightly different (and less ecologically valid for Study 3) mental model. A participant could answer DV3-3 correctly by reasoning "sharing a link doesn't do anything by itself" without understanding that *completed* verification is also choice-blind. These are the same answer but different reasoning paths.

**Recommended refined wording:**

> *"If you verified your vote in front of another person, could they learn which option you voted for?"*

**Why this is better:**
1. Directly tests the coercion scenario Study 3's manipulation creates (social-proof counter → public verification pressure)
2. Tests comprehension of the verification *action* rather than the receipt *artifact* (consistent with DV3-1 and DV3-2, which both use "verify" as the verb)
3. Closer to Study 4's coercion-pressure manipulation, making inter-study comparison more direct
4. Correct answer remains **No**; scoring logic unchanged

**Option DV3-3A (recommended):**  
*"If you verified your vote in front of another person, could they learn which option you voted for?"*  
→ Answer options: Yes / No / I'm not sure. Correct = No.

**Option DV3-3B (keep original):**  
*"If you showed your receipt link to another person, could they learn which option you chose?"*  
→ Acceptable; slightly less ecologically valid for Study 3's coercion scenario.

**Jony's choice:** If the vote-verification interface shows the link clearly and "showing the link" is the natural metaphor for participants who verified, DV3-3B may be more natural. If the verification action (clicking verify, seeing "confirmed") is the salient memory, DV3-3A is better. Recommend DV3-3A.

---

## 3. Scoring rule recommendation

**Recommendation: Option A — strict composite (all-correct = 1)**

| | Option A: Strict composite | Option B: Majority rule |
|---|---|---|
| Rule | `dv3_comprehension = 1` if *all four* items correct | `dv3_comprehension = 1` if ≥3 of 4 correct |
| Analysis script | **Matches current implementation** (4-way AND) | Requires script update |
| Parallel to Study 1 | ✅ Study 1 composite = proportion correct on Q1–Q4; strict composite is the binary analog | ✗ No Study 1 parallel |
| False positive risk | Lower (harder to score 1) | Higher |
| Power | Lower (fewer 1s) | Higher |
| Conservative | ✅ Yes | ✗ No |
| Pre-reg alignment | ✅ Consistent with "Q1–Q4 composite accuracy" language | Slightly inconsistent |

**Rationale for Option A:**

DV3 is a secondary/exploratory outcome (pre-reg §7.5: "Labelled exploratory; underpowered at pilot n for any non-trivial effect"). Because it is exploratory and predicted to be a null condition difference, the priority is *not* maximizing power — it is *avoiding false positives*. Option A (strict composite) is conservative and matches the analysis script as written. It also makes DV3's composite directly interpretable: "all four comprehension items correct" is a clear criterion.

If Study 3 results suggest DV3 is near floor (very few all-correct participants), a sensitivity analysis with Option B can be run and reported as exploratory. This does not require a pre-registration amendment as long as Option A remains the primary analysis.

**Option A scoring code (already in analysis script):**

```r
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

*Note: update `dv3_q3 == "No"` if DV3-3A is selected (correct answer is still No; code unchanged).*

---

## 4. Amendment text for pre-reg §5

The following text is ready to paste into `docs/piup-study3-osf-prereg-2026-07-01.md §5`, replacing the current underspecified DV3 paragraph. File as a pre-data OSF amendment.

### Replacement text for pre-reg §5 DV3 block

> **DV3 — Verification comprehension (T+14, self-report):** Four binary items adapted from Study 1's Q1–Q4 label-comprehension rubric, re-contextualized to measure comprehension of the verification action rather than the receipt label. Items and correct answers:
>
> - **DV3-1:** "Does verifying your receipt confirm that your vote was counted?" Correct: **Yes** (tests inclusion confirmation).
> - **DV3-2:** "If you verify your receipt, does that reveal which option you voted for?" Correct: **No** (tests choice-blindness of the verification action).
> - **DV3-3:** "If you verified your vote in front of another person, could they learn which option you voted for?" Correct: **No** (tests coercion-scenario comprehension — the verification action does not reveal vote choice even when observed; parallels Study 3's social-proof counter manipulation).
> - **DV3-4:** "What does successful verification prove about your vote?" Correct: (b) "That my vote was included in the tally — but not which option I chose" (tests combined inclusion + choice-blindness inference).
>
> Answer options for DV3-1 through DV3-3: Yes / No / I'm not sure (with "I'm not sure" scored 0). Answer options for DV3-4: (a) That I voted for the winning option; (b) That my vote was included in the tally — but not which option I chose [correct]; (c) That the voting system recorded my vote choice; (d) I'm not sure what verification proves.
>
> **Composite scoring (Option A — strict):** `dv3_comprehension = 1` if all four items answered correctly; 0 otherwise. Reported alongside per-item accuracy descriptives.
>
> **Expected performance:** DV3 is predicted to be high (ceiling possible at T+14, given debrief exposure). Predicted null condition difference (verification comprehension is not manipulated by the social-proof counter — only verification *behavior*, DV1, is predicted to differ).

### OSF amendment log entry

> **Amendment [N] — DV3 item wording and scoring rule (pre-data, pre-OSF filing):** Pre-reg §5 defined DV3 as "abbreviated Q1–Q4 rubric adapted from Study 1" without specifying verbatim item wording or composite scoring rule. This amendment adds verbatim item wording for DV3-1 through DV3-4 (adapted from Study 1 Q1–Q4 with context shift: label-artifact questions → verification-action questions; DV3-3 uses verification-in-front-of-person scenario rather than receipt-link-sharing to align with Study 3's coercion scenario). Scoring rule: Option A strict composite (`dv3_comprehension = 1` iff all four items correct). No hypothesis, DV1 primary analysis, DV2 secondary analysis, or sample size change. DV3 remains exploratory/secondary throughout. (Pre-data, pre-OSF.) | [Jony Bursztyn]

---

## 5. Impact on other documents

| Document | Change required | Action |
|---|---|---|
| `docs/piup-study3-osf-prereg-2026-07-01.md §5` | Replace DV3 paragraph with verbatim items + scoring rule (§4 above) | Jony to paste and file on OSF |
| `docs/piup-study3-survey-instrument-2026-07-01.md §5.2` | Update DV3-3 wording if DV3-3A approved; remove ⚠️ JONY DECISION REQUIRED note | Agent can apply once Jony confirms |
| `analysis/piup-study3-analysis.R` | No change needed (scoring code already matches Option A; column names `dv3_q1`–`dv3_q4` already in drycheck) | None |
| `docs/piup-study3-crosscheck-2026-07-01.md` | Gaps 2 and 3 — mark resolved pending Jony approval | Agent to update once Jony confirms |
| `docs/qualtrics-setup-guide-study3-t14-2026-07-01.md §9` | Remove ⚠️ DV3 item wording confirmation checklist item once approved | Agent can apply once Jony confirms |

---

## 6. What Jony needs to do

**Before OSF filing:**

1. **Review DV3-3.** Choose: DV3-3A (verify in front of someone) or DV3-3B (show receipt link to someone). **Recommend 3A.**
2. **Confirm Option A** (strict composite) scoring rule. No action needed if agreed.
3. **Paste amendment text** from §4 into `piup-study3-osf-prereg-2026-07-01.md §5` (replacing the current DV3 paragraph).
4. **File on OSF** as a pre-data amendment.
5. **Reply to confirm** so the agent can: (a) update DV3-3 in the instrument, (b) remove the ⚠️ notes, (c) close crosscheck Gaps 2 and 3.

**Estimated time:** 10–15 minutes (review + paste + OSF file).

This unblocks Study 3 pre-reg from being OSF-ready (only remaining blocker after this: Jony's IRB contact details in the survey instrument).
