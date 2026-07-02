# PIUP Study 1 — Decision D: Amendment 19b Draft

**Date:** 2026-07-02 (tick-4450)
**Status:** READY TO FILE — Jony must confirm Option A and commit stimuli changes
**Author:** OpenClaw Agent
**Resolves:** `docs/piup-study1-crosscheck-2026-07-01.md` Gap 2
**Connects to:** `docs/jony-approval-cheatsheet-2026-06-29.md` Decision D, Amendment 19

---

## What was missing

Pre-registration §5.2 states, for Q3:

> "Clarification appended: 'Assume they can only see what is on this screen.' **This wording is in the stimuli** and cannot be changed post-registration without amendment."

The four stimulus HTML files (`condition-a-fingerprint.html`, `condition-b-confirmation-code.html`, `condition-c-nullifier.html`, `condition-d-receipt-id.html`) did not contain this text.

---

## Option A — Implementation (tick-4450)

All four stimulus HTML files now include:

```html
<!-- Scope-limiting clarification: pre-reg §5.2 Q3, Amendment 19b Option A -->
<p class="study-note" role="note">
  <strong>Study note:</strong> Assume they can only see what is on this screen.
</p>
```

**Placement:** Below the receipt card div, above the condition watermark badge.

**Styling:** `.study-note` — `background: #f9fafb`, `border: 1px solid #e5e7eb`, `border-radius: 8px`, `font-size: .8rem`, `color: #374151` — visually distinct from the receipt UI. Participants see it as a study instruction, not as part of the receipt itself. `role="note"` for screen-reader accessibility.

**Reasoning for this placement:**
- Below the receipt card: participants see the receipt first, as they would in a real election, then see the scope instruction before being asked Q3. The instruction does not contaminate their initial receipt interpretation.
- Above the condition badge: study infrastructure elements grouped together.
- Not inside the receipt card: keeps the receipt UI identical to production, scoping clarification is clearly exogenous.

---

## Amendment 19b text (ready to paste into OSF)

> **Amendment 19b — Stimuli scope-limiting clarification added (pre-data):** Pre-registration §5.2 states for Q3: "Clarification appended: 'Assume they can only see what is on this screen.' This wording is in the stimuli and cannot be changed post-registration without amendment." The four stimulus HTML files (condition-a-fingerprint.html, condition-b-confirmation-code.html, condition-c-nullifier.html, condition-d-receipt-id.html) did not contain this text at the time of initial registration. Amendment 19b adds the following element to each stimulus file, positioned below the receipt card: `<p class="study-note" role="note"><strong>Study note:</strong> Assume they can only see what is on this screen.</p>` Styling keeps the note visually distinct from the receipt UI (light grey background, small font, clearly labelled "Study note:"). No hypothesis, measure, analysis plan, alpha level, or primary DV is changed. This amendment brings the stimuli into compliance with the pre-registered §5.2 Q3 clarification commitment.

---

## Filing instructions

1. **Confirm Option A:** Jony reviews the stimuli change in `study-stimuli/` and approves.
2. **Commit stimuli:** `cd aztec-private-voting && git add study-stimuli/ && git commit -m "study1: add scope-limiting clarification to all 4 stimuli (Amendment 19b, Option A)"`
3. **File Amendment 19b on OSF:** Go to the Study 1 pre-registration on OSF → Revise → scroll to the amendment log → append the Amendment 19b text above.
4. **Update pre-reg §5.2** (optional inline note): After the Q3 entry, add: `[Amendment 19b filed 2026-07-XX: scope-limiting note added to stimuli HTML.]`

---

## If Jony chooses Option B instead

Revert the stimuli: `git checkout study-stimuli/`

Then add the text as a Qualtrics question hint below Q3 in the Qualtrics survey builder:
- Open Q3 in Qualtrics → Add a Hint (shown below the question): "Assume they can only see what is on this screen."
- File Amendment 19b with the wording: "Pre-registered scope-limiting instruction added as a Qualtrics question hint below Q3 rather than in the stimulus HTML. Wording identical to pre-reg §5.2: 'Assume they can only see what is on this screen.' No hypothesis or analysis plan changed."

## If Jony chooses Option C instead

Revert the stimuli: `git checkout study-stimuli/`

File Amendment 19c:
> "Amendment 19c — Scope-limiting clarification not added to stimuli: Pre-reg §5.2 committed to placing 'Assume they can only see what is on this screen.' in the stimuli. On review, the instrument wording 'If you showed a third party your screen and your [LABEL]' (Q3 instrument §6) is judged to scope the information domain sufficiently — participants are told explicitly what is being shown (the screen + the label, not additional context). No additional stimulus-level clarification is required. This deviates from the pre-registered commitment; the deviation is logged here pre-data."
