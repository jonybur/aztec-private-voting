# PIUP Study 1 — Pilot-Launch Wording Decisions

**Date:** 2026-06-25  
**Author:** @jonybur-oc (tick-3819)  
**Status:** Recommendations for Jony's review — resolve before OSF upload  
**Companion docs:**
- [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) — pre-registration
- [`docs/piup-study1-survey-instrument-2026-06-22.md`](piup-study1-survey-instrument-2026-06-22.md) — survey instrument
- [`docs/jony-actions-audit-2026-06-23.md`](jony-actions-audit-2026-06-23.md) — action tracking

---

## Overview

Five wording conflicts exist between the pre-registration (PRE-REG) and the survey instrument. Each must be resolved before OSF upload — whichever wording is uploaded IS the pre-registration. Conflicts requiring OSF amendment are flagged; some can be avoided by reverting to pre-reg wording.

**Decision table (see full analysis below):**

| Item | Conflict | Recommendation | Amendment needed? |
|------|----------|---------------|-------------------|
| A | Q3 coercion scenario phrasing | **Use instrument wording** | Yes — minor |
| B | Q4 "lost" vs "closed screen" + foils | **Use instrument wording** | Yes — minor |
| C | Q3 clarification baseline vs amendment | **Drop "assume only on screen"; use scenario-context note as optional** | Yes — clears ambiguity |
| D | MQ1 one-part vs two-part prompt | **Keep pre-reg single-question wording** | No |
| E | BI1 "download this file" vs "save your [LABEL]" | **Use instrument wording, replace [LABEL] with "this code"** | Yes — minor |

**Net amendments needed: 4 (A, B, C, E).** All are minor clarifications — no hypothesis direction changes, no new measures.

---

## Item A — Q3 coercion scenario phrasing

### The conflict

**Pre-reg (§5.2):**  
> "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?"

**Instrument (§6/Q3):**  
> "Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?"

### Analysis

The instrument wording is substantively better:

1. **Specificity:** "Could they tell which voting option you chose?" is more precisely the construct we're measuring than "could they learn how you voted?" The pre-reg phrasing is ambiguous — "how you voted" could include method, timing, etc. The instrument's phrasing maps directly to Q2's construct (choice visibility).

2. **Ecological validity:** "Show them this screen" matches the actual stimulus task (participants have just viewed the screen). "Send a screenshot" adds an abstraction step. The instrument keeps the scenario grounded in the same interaction frame.

3. **Tone:** "Coercive employer" may prime alarm or defensiveness before participants reason about the UI. "Your employer...wants to verify" presents the same coercive situation more neutrally, letting the participant's understanding of the screen drive their answer.

4. **Label integration:** Instrument Q3 references "[LABEL]" directly, making the question explicitly about what the identifier reveals — which is the construct. Pre-reg Q3 doesn't mention the identifier at all.

### Recommendation

**Use instrument wording for Q3.** File OSF amendment before pilot upload. Amendment rationale: "Q3 wording updated for improved construct specificity, ecological validity, and label integration. Correct answer (No), scoring rubric, and hypothesis tests unchanged."

The amendment is permitted under pre-reg §7.3 ("wording changes to Q3"). The pre-reg's analysis structure (H1-Q3, H2-secondary Q3) is fully preserved — the correct answer, foils, and one-tailed tests are unchanged.

---

## Item B — Q4 wording and foils

### The conflict

**Pre-reg (§5.2, §5.4):**  
> "What would happen if you lost this value?"  
> Foils: (a) you would lose your vote; (c) the system keeps a backup; (d) your vote would be reversed.  
> Correct: (b) you could still verify that your vote was counted, but you would not have proof that the receipt is yours.

**Instrument (§6/Q4):**  
> "If you closed this screen without saving your [LABEL], what would happen?"  
> Foils: (a) My vote would be cancelled or reversed; (c) The voting system keeps a copy of my [LABEL], so I could always retrieve it later; (d) Nothing — my vote does not depend on having this [LABEL].  
> Correct: (b) I could still verify that my vote was counted, but I would not have this [LABEL] as personal proof.

### Analysis

The instrument wording is better on ecological validity, and the foil set is cleaner:

1. **Ecological validity:** "Closed this screen without saving" is the scenario participants literally face at the end of the stimulus. "Lost this value" is abstract — lost how? (forgotten, device failure, screenshot deleted?). The instrument's grounding in the stimulus interaction reduces cognitive load on the scenario setup and focuses the question on the actual UI affordance (the save/download button).

2. **Foils — instrument is cleaner:**
   - (a): "Cancelled or reversed" consolidates pre-reg's two separate foils (lose vote; vote reversed) into one. Avoids participants choosing between two semantically similar wrong answers.
   - (c): Instrument makes the error more specific ("the voting system keeps a copy of my [LABEL]") — the pre-reg's "the system keeps a backup" is vaguer. Both test the same misconception.
   - (d): "Nothing — my vote does not depend on having this [LABEL]" is a partially correct distractor (vote IS still counted) that correctly captures the nuance. Pre-reg (d) ("your vote would be reversed") is the same type of error as (a) — this duplication is removed in the instrument.

3. **Correct answer:** Identical in substance. Both state: vote is counted regardless; you lose personal proof. Instrument adds "[LABEL]" for label-consistency.

### Recommendation

**Use instrument wording for Q4, including the updated foils.** File OSF amendment before pilot upload. Amendment rationale: "Q4 wording updated for ecological validity (stimulus-grounded scenario). Foils consolidated to remove duplicated error type. Correct answer and scoring unchanged."

Note: The analysis script (`analysis/piup-study1-analysis.R`) scores Q4 as binary correct/incorrect — the foil re-ordering doesn't affect R analysis. Qualtrics implementation must confirm option (b) remains the correct-coded response.

---

## Item C — Q3 baseline clarification

### The conflict

**Pre-reg §5.2** lists this as the baseline clarification for Q3:  
> "Assume they can only see what is on this screen."

**Pre-reg §7.2** says the same text "can be added if Q3 shows confusion" — implying it is amendment-only, not baseline.

**Instrument §6** drops this clarification entirely and offers a different optional note:  
> *"This is a hypothetical scenario to test your understanding of what the screen reveals. It does not reflect a real situation."*

This is an internal pre-reg inconsistency: §5.2 and §7.2 contradict each other.

### Analysis

The "assume only on screen" clarification has a significant problem: **it hints at the correct answer.** If participants are told "assume they can only see this screen," it shifts the task from "does the screen reveal your choice?" (construct) to "can you infer your choice from what's visible on this specific screen?" — a more constrained and more leading version of the question.

The instrument Q3 wording ("If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?") already constrains the information source by specifying "your screen and your [LABEL]" as the only information shared. The clarification is redundant and leading.

The instrument's alternative note ("This is a hypothetical scenario...it does not reflect a real situation") is weaker — it's a consent/ethics hedge, not a construct clarification.

**Neither clarification is needed** given the updated Q3 wording from Item A.

### Recommendation

**Drop "assume they can only see what is on this screen" from the pre-reg baseline.** The updated Q3 wording implicitly constrains the information to the screen; the clarification adds hint-risk. Retain the "hypothetical scenario" note as an optional implementation detail (small text below the question) to be added if pilot participants show scenario-confusion in free-text, but do not pre-specify it as baseline.

File OSF amendment clarifying: "Q3 baseline clarification removed. Pre-reg §5.2 and §7.2 are reconciled: clarification is now amendment-only (add only if pilot data shows systematic scenario confusion). Updated Q3 wording (Item A) makes clarification redundant."

---

## Item D — MQ1 one-part vs two-part prompt

### The conflict

**Pre-reg (§5.5/§6.1):**  
> "In your own words, what does this value prove about your vote?"

**Instrument (§7/MQ1):**  
> "In your own words: what does your [LABEL] prove about your vote? What does it NOT prove?"

### Analysis

The "What does it NOT prove?" addition in the instrument is a demand characteristic that would inflate the non-leakage dimension of MQ_SCORE.

The MQ1 rubric has two dimensions: (1) inclusion — did the participant mention the vote was counted? and (2) non-leakage — did the participant spontaneously state the receipt doesn't reveal the choice? 

Spontaneous mention of non-leakage is a higher-validity test of mental model accuracy. If we explicitly prompt "what does it NOT prove?", we are:
- Cuing participants to think about what is NOT shown (strong hint toward the correct framing)
- Potentially inflating non-leakage scores in all conditions (reduces sensitivity to between-condition differences on this dimension)
- Introducing a demand effect (participants feel obliged to fill in the "NOT prove" part)

The pre-reg wording is harder but more valid. The mental model quality measure (RQ3) is specifically designed to test whether participants can spontaneously articulate non-leakage — not whether they can recognise it when prompted.

**Critical implication for H2:** If the label manipulation (vote fingerprint vs confirmation code) genuinely affects privacy mental model accuracy, we want the MQ1 non-leakage dimension to be sensitive to that difference. Explicitly prompting non-leakage reduces that sensitivity and weakens the test.

### Recommendation

**Keep pre-reg single-question wording: "In your own words, what does your [LABEL] prove about your vote?"**

**Do not add "What does it NOT prove?"**

No OSF amendment needed — this is a decision to retain the registered wording. Update the survey instrument to match the pre-reg wording. The instrument file currently diverges; it should be corrected before Qualtrics setup.

This is the one item where the pre-reg wording is clearly better. Reverting costs nothing (no amendment, no OSF re-upload needed on this item).

---

## Item E — BI1 wording

### The conflict

**Pre-reg (§5.6):**  
> "If this screen appeared after a real vote, would you download this file?"  
> Scale: Definitely yes / Probably yes / Might or might not / Probably no / Definitely no (5-point)

**Instrument (§7/BI1):**  
> "If this was a real election and you saw this screen after submitting your vote, how likely would you be to save your [LABEL] for future reference?"  
> Scale: Definitely would save it / Probably would save it / Might or might not / Probably would not save it / Definitely would not save it (5-point)

### Analysis

The instrument wording is better in three respects:

1. **"Save" vs "download":** The stimulus shows a download button, but "save" is a broader and more natural behaviour (screenshot, cloud save, copy-paste). "Download this file" constrains the behavioral intention to the specific UI action, which may vary in familiarity by participant. "Save for future reference" captures the intent (will you preserve this?) regardless of the specific mechanism.

2. **Ecological scenario:** "You saw this screen after submitting your vote" is more natural than "if this screen appeared." The instrument phrasing matches how participants just experienced the stimulus.

3. **Scale labels:** "Definitely would save it / Definitely would not save it" makes the scale item consistent with the question's "how likely would you be to save" framing. Pre-reg's "Definitely yes / Definitely no" is fine but less parallel.

**Problem with "[LABEL]" in instrument wording:** "How likely would you be to save your vote fingerprint / confirmation code / nullifier / receipt ID for future reference?" embeds the condition label into BI1. This is a demand characteristic — participants who found the label confusing may be less likely to say they'd save "their nullifier" regardless of their actual behavioral intent. BI1 should measure save intention, not label preference.

**Fix:** Replace "[LABEL]" with "this code" in the instrument BI1 text.

### Recommendation

**Use instrument BI1 wording with one edit:** replace "your [LABEL]" with "this code":  
> "If this was a real election and you saw this screen after submitting your vote, how likely would you be to save **this code** for future reference?"

File OSF amendment: "BI1 wording updated — 'download this file' → 'save this code for future reference' to use broader, label-neutral behavioral framing. Scale labels updated to match question phrasing. Coding (5=Definitely would save → 1=Definitely would not) unchanged."

**Update the survey instrument file to use "this code" (not "[LABEL]") in BI1.**

---

## Summary of actions for Jony

### 1. Make the decisions (15 minutes)

Read the recommendations above. If you agree:
- A: ✅ Use instrument Q3
- B: ✅ Use instrument Q4 + foils
- C: ✅ Drop baseline clarification
- D: ✅ Revert MQ1 to pre-reg single-question wording (fix instrument file)
- E: ✅ Use instrument BI1 with "this code" substitution (fix instrument file)

If you disagree with any item, note your decision and I'll update the pre-reg accordingly.

### 2. Update survey instrument (30 minutes)

Apply these changes to `docs/piup-study1-survey-instrument-2026-06-22.md`:
- D: Q7/MQ1 text → revert to "In your own words: what does your [LABEL] prove about your vote?" (remove "What does it NOT prove?")
- E: Q7/BI1 text → replace "save your [LABEL]" with "save this code"

### 3. OSF upload (Jony-only action)

Upload to OSF with the resolved wording. The 4 amendments (A, B, C, E) should be noted in the pre-registration amendments table as "instrument reconciliation before pilot launch."

Files to upload:
1. `docs/piup-study1-preregistration-2026-06-22.md` (with amendments table updated)
2. `analysis/piup-study1-analysis.R`
3. `docs/piup-study1-survey-instrument-2026-06-22.md` (with D/E fixes applied)

### 4. Then proceed to pilot launch

After OSF upload: Qualtrics setup → Prolific pilot (N=10/condition = N=40) → stimuli deploy.

---

## Critical path (Jony-actions remaining before Prolific pilot)

```
Today:   Review + decide A-E (this doc)
         Fix instrument D + E (30 min)
         
OSF:     Upload 3 files to OSF (Jony only — OSF account required)
         Note 4 amendments in pre-reg amendments table
         
Setup:   Create Qualtrics survey (qualtrics-setup-guide-2026-06-22.md)
         Deploy stimuli: bash scripts/deploy-stimuli.sh --prod
         Configure 4 Prolific study URLs (A/B/C/D conditions)
         
Launch:  Run N=40 pilot (N=10/condition)
         Review kappa on Q5 + MQ1 after pilot
         Check for floor/ceiling on Q3 (trigger if > 20% confused)
         
Full:    If pilot clear → launch N=280 full study
```

---

*Generated tick-3819 by @jonybur-oc. This memo resolves the pre-pilot blocking items from jony-actions-audit-2026-06-23.md §🟡 BLOCKING PRE-PILOT.*
