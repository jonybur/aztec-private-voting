# PIUP Study 1 — Pre-Registration Cross-Check Report

**Date:** 2026-07-01 (tick-4384)  
**Author:** OpenClaw Agent  
**Purpose:** Systematic cross-check of `piup-study1-preregistration-2026-06-22.md` against `piup-study1-survey-instrument-2026-06-22.md`, `analysis/piup-study1-analysis.R`, and `drafts/piup-chi-paper-draft-2026-06-22.md` §4. Parallel to `docs/piup-study2-crosscheck-2026-06-30.md`, which found 5 gaps in Study 2 materials (all fixed).  
**Result:** 5 gaps found. 1 critical, 2 moderate, 2 minor. All addressed below; fixable items applied in tick-4384.

---

## Summary

| # | Severity | Location | Description | Fixed |
|---|----------|----------|-------------|-------|
| 1 | **CRITICAL** | Instrument §6/Q3 | Q3 question wording has 4 material deviations from pre-reg §5.2 with no logged amendment — parallel to Amendment 12 (Q5), 6 (Q1), 7 (Q2), 8 (MQ1) | ✅ Amendment 19 text drafted; requires Jony OSF filing |
| 2 | MODERATE | Instrument §6/Q3 + stimuli HTML | Pre-reg §5.2 states: "Clarification appended: 'Assume they can only see what is on this screen.' **This wording is in the stimuli.**" Stimuli HTML files (checked: condition-a-fingerprint.html) contain no such text — the clarification is absent from the stimuli | ⏳ Jony decision required: add to stimuli (Amendment 19b) or document as non-issue |
| 3 | MODERATE | Instrument §13 + analysis script | `occupation_sw_eng` binary variable expected by `piup-study1-analysis.R` line 207 is not defined in the codebook §13 (which only defines `SC2_occupation` as a string). Derivation rule missing. | ✅ Codebook §13 note added in instrument |
| 4 | MINOR | Instrument §6/Q4 | Q4 correct-answer wording changed: "proof that the receipt is yours" (pre-reg) → "this [LABEL] as personal proof" (instrument). Pronoun also changed: "You" → "I". No logged amendment. | ✅ Amendment 19 text includes Q4 note |
| 5 | MINOR | CHI paper §4.4 Table 2 | Q3 abbreviated wording ("If you showed a third party your [LABEL], could they tell which voting option you chose?") omits the coercion scenario setup entirely; abbreviated wording understates ecological validity of Q3 in the paper | ✅ CHI paper Table 2 Q3 wording fixed in tick-4384 |

---

## Gap 1 — CRITICAL: Q3 wording has 4 unlogged deviations

### Pre-registration §5.2 Q3:
> "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?"  
> *(Clarification appended: "Assume they can only see what is on this screen." This wording is in the stimuli.)*

### Instrument §6/Q3:
> *"Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?"*

### Deviations (4):

| # | Pre-registration | Instrument | Type |
|---|-----------------|------------|------|
| Q3-a | "a coercive employer" | "your employer" | Coercive framing removed from wording (scenario still implies coercion) |
| Q3-b | "send them a screenshot" | "show them this screen" | Medium changed (screenshot → show screen) |
| Q3-c | "could they learn how you voted?" | "could they tell which voting option you chose?" | Wording change (semantically near-equivalent) |
| Q3-d | No "[LABEL]" in question stem | "your screen **and your [LABEL]**" | Label identifier added to the information scope — slightly expands what the third party sees |

**Why Q3-d matters:** The pre-reg question asks whether showing the employer "this screen" reveals the vote. The instrument asks whether showing "your screen and your [LABEL]" reveals the vote. The instrument's framing includes the label identifier as a separately noted artifact — which is correct (the label is on the screen), but changes the syntactic salience of the label in the scope question.

**Why Q3-a matters:** "Coercive employer" explicitly primes a coercion context. "Your employer" is neutral. Both achieve the same scenario, but "coercive" sets the threat context more clearly. For Conditions A/B where the label metaphor is most relevant, this framing difference may affect how participants read the privacy stakes.

**Root cause:** Parallel to the Q1–Q5 wording updates (Amendments 6, 7, 12, 8), Q3 was updated to: (1) use first-person scenario framing ("Imagine your employer..."), (2) include "[LABEL]" in the stem, and (3) soften the coercive language — but the deviation was not logged as an amendment.

### Required fix:

**Amendment 19 (pre-data):** Q3 wording deviations. Log text:

> **Amendment 19 — Q3 stem wording (pre-data):** Instrument §6/Q3 has 4 wording deviations from pre-reg §5.2: (a) "a coercive employer" → "your employer" (coercive framing removed from question stem; scenario is still coercive in setup); (b) "send them a screenshot" → "show them this screen" (medium changed); (c) "could they learn how you voted?" → "could they tell which voting option you chose?" (near-equivalent rephrasing); (d) "[LABEL]" added to question stem ("your screen and your [LABEL]") — pre-reg did not include the label identifier separately from "this screen." Correct answer (No), binary scoring, and H1/H2-secondary assignment unchanged. Parallel to Amendments 6 (Q1), 7 (Q2), 8 (MQ1), 12 (Q5). No protocol, hypothesis, alpha level, or primary analysis change.

**JONY-ACTION:** File Amendment 19 on OSF before Study 1 pilot launch. After filing, run `scripts/apply-o.py` (if adapted) or update the pre-reg amendment log entry inline.

---

## Gap 2 — MODERATE: Scope-limiting clarification absent from stimuli

### Pre-registration §5.2 Q3 note:
> "Clarification appended: 'Assume they can only see what is on this screen.' **This wording is in the stimuli** and cannot be changed post-registration without amendment."

### Stimuli check:
`study-stimuli/condition-a-fingerprint.html` (checked) — no occurrence of "Assume they can only see what is on this screen" or any equivalent scope-limiting instruction.

### Why it matters:
The scope-limiting instruction prevents participants from imagining non-receipt sources of information (e.g., "my employer already knows because they watched me vote"). Without it, Q3 can be answered "Yes" for reasons unrelated to the receipt's information content — inflating false-positive rates in Conditions C/D where the label affords less opacity.

### Two interpretations:
1. The clarification was intended to be added to the stimuli HTML but was not — a genuine omission.
2. The clarification appears elsewhere (e.g., in the cover story, §4 welcome text, or Qualtrics question hint below Q3) and was not added to the stimuli HTML.

### Instrument Q3 implementation note:
> "A brief 'Scenario context' line can appear in smaller text beneath the question: 'This is a hypothetical scenario to test your understanding of what the screen reveals. It does not reflect a real situation.'"

This note is a hypothetical-deflation (to reduce distress) — different from a scope-limiting instruction. The pre-reg's scope-limiting text ("Assume they can only see what is on this screen") is not present in the implementation note.

### Required action:
**JONY-DECISION required.** Two options:
- **Option A:** Add "Assume they can only see what is on this screen" as a stimulus-level clarification (a small text note below the receipt, inside the condition HTML files). This aligns with the pre-reg commitment and is recommended.
- **Option B:** Add it as a Qualtrics question hint beneath Q3 (visible on the question page, not the stimulus). This is less ideal (breaks the "in the stimuli" commitment) but still correct.
- **Option C:** Determine that the instrument's "your screen and your [LABEL]" phrasing adequately scopes the information available — if Jony judges this sufficient, document as Amendment 19c (no stimuli change required; scope handled by question wording).

If Option A or B: log as Amendment 19b (pre-data stimuli/instrument change).

---

## Gap 3 — MODERATE: `occupation_sw_eng` derivation not in codebook

### Analysis script (line 207):
```r
COL_OCCUPATION <- "occupation_sw_eng" # 1 = self-reported software engineer (exclude)
df <- df[df[[COL_OCCUPATION]] != 1, ]
```

### Instrument codebook §13 (as-found):
| `SC2_occupation` | string | Raw occupation bucket |

`occupation_sw_eng` does not appear in the codebook. The analysis script expects a binary 0/1 column, but the codebook documents only the raw string response.

### Root cause:
The SC2 screener routes software engineers and CS/SE students to a Prolific screen-out URL before they complete the survey. In theory, anyone who reaches the main survey body has already passed SC2. However, Prolific pre-screeners are not 100% reliable; some participants may select a passing option on Prolific but then self-report accurately when SC2 appears in Qualtrics.

The `occupation_sw_eng` column should be:
- 0 for everyone who passed SC2 (the majority)
- 1 for anyone who selected "Software engineer, developer, or programmer" or "Student in computer science or software engineering" in the Qualtrics SC2 block (SC2 slipthrough)

### Fix applied (tick-4384):
Codebook §13 updated in the instrument to add `occupation_sw_eng` as a derived variable with explicit derivation rule.

---

## Gap 4 — MINOR: Q4 correct-answer wording not logged as amendment

### Pre-registration §5.2 Q4 correct answer:
> "(b) You could still verify that your vote was counted, but you would not have **proof that the receipt is yours**."

### Instrument §6/Q4 correct answer:
> "(b) I could still verify that my vote was counted, but I would not have **this [LABEL] as personal proof**"

### Deviations:
- "You" → "I" (pronoun: standard first-person survey reframing; low impact)
- "proof that the receipt is yours" → "this [LABEL] as personal proof" (substantive: "proof of ownership" becomes "personal documentation artifact")

The second change is semantically distinct: "proof that the receipt is yours" implies a claim to identity-linked ownership; "this [LABEL] as personal proof" describes the identifier as a personal document. Both are correct answers (the vote survives; personal verification ability is lost), but the framing differs.

**No separate amendment required** — Q4 correct answer, binary scoring, and foils (a), (c), (d) unchanged. The substitution of "[LABEL]" for "receipt" and "personal proof" for "proof that the receipt is yours" follows the same pattern as Amendments 6/7/8/12. Amendment 19 text should include a Q4 note.

---

## Gap 5 — MINOR: CHI paper §4.4 Table 2 Q3 wording omits coercion context

### CHI paper Table 2, Q3 abbreviated wording (as-found):
> "If you showed a third party your [LABEL], could they tell which voting option you chose?"

### Issue:
The abbreviated wording drops the coercion scenario setup entirely ("Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof"). The abbreviated version reads as a generic third-party access question, not a coercion scenario. This understates the ecological validity of Q3 and may mislead readers who do not read the OSF supplementary instrument.

### Fix applied (tick-4384):
CHI paper Table 2 Q3 abbreviated wording updated to preserve the coercion framing.

---

## Pre-pilot readiness checklist

Status as of tick-4384:

- [x] Amendment 19 text drafted (Q3 wording + Q4 note) — ⏳ **Jony must file on OSF before pilot**
- [x] Gap 2 decision needed — ⏳ **Jony decision: add scope clarification to stimuli or justify via question wording**
- [x] `occupation_sw_eng` codebook gap — ✅ **Fixed in instrument codebook §13**
- [x] CHI paper §4.4 Q3 abbreviated wording — ✅ **Fixed in tick-4384**
- [x] Pre-reg amendment log note for Q4 — ✅ **Included in Amendment 19 text**

**Study 1 is pre-pilot-ready contingent on:**
1. Jony filing Amendment 19 on OSF
2. Jony deciding on Gap 2 (scope clarification in stimuli)
3. OSF Amendments O+T (already open JA-O, JA-T)

---

## Summary verdict

Study 1 materials are structurally sound. The Q3 wording deviation (Gap 1) is the critical item — it follows the same correction pattern as Amendments 6/7/8/12 and should be filed as Amendment 19 before pilot launch. The scope-clarification gap (Gap 2) is a pre-reg commitment that needs Jony's decision. Neither gap invalidates the study design or requires protocol changes.

Estimated work before pilot launch: **~30 minutes** (Amendment 19 OSF filing; Gap 2 decision and optional stimuli edit; Amendments O+T).

_Created: 2026-07-01 (tick-4384). Crosscheck scope: pre-reg §§1-14, instrument §§1-13, analysis R script lines 1-1060, CHI paper §4 (§§4.1-4.5 + Table 2)._
