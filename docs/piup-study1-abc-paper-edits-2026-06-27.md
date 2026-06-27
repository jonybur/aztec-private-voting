# PIUP Study 1 — Paper Edit Specification for A/B/C Decisions

**Prepared:** 2026-06-27 (tick-4005)  
**Purpose:** Exact before/after text for each paper change once Jony confirms Decisions A, B, C.  
**Applies to:** `drafts/piup-chi-paper-draft-2026-06-22.md` (§4.4 Q3 and Q4 entries)  
**Recommendations:** All three recommend the "instrument wording" path (per pilot-decisions memo).  
**Once Jony says "confirm all" or lists individual confirmations:** apply exactly the diffs below and replace each Note block with the corresponding [Fixed] annotation.

---

## Decision A — Q3 wording (instrument wording)

**Recommended path:** Use instrument wording + file OSF Amendment A.

### Change 1 of 2: Q3 question text

**Current Q3 line (pre-reg wording):**
```
*Q3 (Coercion-scenario privacy model):* "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?" Correct answer: No; foils: Yes, Unsure. A clarification is displayed: "Assume they can only see what is on this screen."
```

**After Decision A (+ Decision C below):**
```
*Q3 (Coercion-scenario privacy model):* "Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?" Correct answer: No; foils: Yes, I'm not sure.
```

**Rationale:**
- "coercive" removed: avoids priming alarm before participants reason about the UI
- "send them a screenshot" → "show them this screen": matches the actual stimulus interaction frame
- "[LABEL]" named explicitly: makes the question directly about the identifier construct
- "how you voted" → "which voting option you chose": matches Q2 phrasing (consistent)
- Foils updated: "Unsure" → "I'm not sure" (instrument wording)
- Clarification dropped (Decision C): see below

### Change 2 of 2: Note block replacement

**Current Note block** (long, multi-paragraph block starting "Note (pending Jony decision Items A and C, tick-3842):"):
> Replace entire Note block with:

```
[Fixed tick-4005: Decision A adopted (instrument wording). Q3 updated from pre-reg 'coercive employer/screenshot' framing to instrument employer-shows-screen framing. Decision C adopted: 'Assume they can only see what is on this screen.' clarification removed from baseline — clarification is now amendment-only per §7.2, available post-pilot if Q3 shows confusion. OSF Amendments A and C filed per osf-amendment-filing-2026-06-24.md. Correct answer (No), H1-Q3 and H2-secondary Q3 analysis structure unchanged.]
```

---

## Decision C — Q3 clarification (drop from baseline)

**Recommended path:** §7.2 is authoritative — clarification is amendment-only. Drop from baseline and reconcile §5.2/§7.2 contradiction via OSF Amendment C.

This decision pairs with Decision A above. The full Q3 line after both A+C is shown in Decision A above.

**If A is confirmed but C is NOT confirmed** (keep clarification in baseline):
- Retain the sentence: `A clarification is displayed: "Assume they can only see what is on this screen."`
- Update the Note block to document only Item A resolution, leaving Item C Note in place.

**If C is confirmed but A is NOT confirmed** (unusual case — keep pre-reg wording but drop clarification):
```
*Q3 (Coercion-scenario privacy model):* "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?" Correct answer: No; foils: Yes, Unsure.
```
- Drop `A clarification is displayed: "Assume they can only see what is on this screen."`
- Note block updated accordingly.

**Recommendation:** Confirm A+C together (instrument wording + drop clarification). The instrument wording makes the clarification redundant: "your screen and your [LABEL]" already constrains the information surface.

---

## Decision B — Q4 wording (instrument wording)

**Recommended path:** Use instrument wording + file OSF Amendment B.

### Change 1 of 2: Q4 question and foils

**Current Q4 line (pre-reg wording):**
```
*Q4 (Behavioral consequence of receipt loss):* "What would happen if you lost this value?" Correct answer: You could still verify that your vote was counted, but you would not have proof that the receipt is yours; foils: you would lose your vote; the system keeps a backup; your vote would be reversed.
```

**After Decision B (instrument wording):**
```
*Q4 (Behavioral consequence of receipt loss):* "If you closed this screen without saving your [LABEL], what would happen?" Correct answer: I could still check that my vote was counted, but I would not have proof the receipt is mine; foils: My vote would be cancelled or reversed; The voting system keeps a copy of my [LABEL], so I could always retrieve it later; Nothing — I do not need to save it.
```

**Key changes:**
- "lost this value" → "closed this screen without saving your [LABEL]": maps to actual interface affordance; tests interface-level comprehension rather than abstract object-permanence
- Foil (a): "you would lose your vote" → "My vote would be cancelled or reversed": adds "reversed" escalation for better distractor validity
- Foil (c): "the system keeps a backup" → "The voting system keeps a copy of my [LABEL], so I could always retrieve it later": more specific (uses [LABEL])
- Foil (d): "your vote would be reversed" → "Nothing — I do not need to save it": replaces catastrophic-misread distractor with a near-correct option, which isolates comprehension of the verification function (the receipt is not the vote — not saving it has no vote-outcome consequence)
- Correct answer: unchanged conceptually; first-person voice aligned with instrument format
- Note: foil (d) design-change is substantive — the pre-reg's "vote reversed" distractor tests catastrophic-misread; the instrument's "nothing — I do not need to save it" tests whether participants understand the receipt is optional for the vote but needed for verification. This is a better operationalization of H2 schema understanding and was pre-cleared in pilot-decisions §Item B.

### Change 2 of 2: Note block replacement

**Current Note block** (starting "Note (pending Jony decision Item B, tick-3840):"):
> Replace with:

```
[Fixed tick-4005: Decision B adopted (instrument wording). Q4 updated from pre-reg 'lost this value' phrasing to instrument 'closed this screen without saving your [LABEL]' phrasing. Foil (d) updated from 'your vote would be reversed' (catastrophic-misread distractor) to 'Nothing — I do not need to save it' (near-correct distractor; isolates verification-function understanding). Correct answer unchanged. OSF Amendment B filed per osf-amendment-filing-2026-06-24.md. See pilot-decisions §Item B for full foil-revision rationale.]
```

---

## Summary of changes after "confirm all"

| Decision | Section | Change |
|---|---|---|
| A | §4.4 Q3 text | Pre-reg wording → instrument wording (employer-shows-screen) |
| A | §4.4 Q3 Note | Multi-paragraph Note → [Fixed tick-4005] annotation |
| C | §4.4 Q3 text | Drop `A clarification is displayed: "Assume they can only see what is on this screen."` |
| B | §4.4 Q4 text | Pre-reg wording + foils → instrument wording + instrument foils |
| B | §4.4 Q4 Note | Note → [Fixed tick-4005] annotation |

**OSF amendments required:** A, B, C (texts already in `docs/osf-amendment-filing-2026-06-24.md` Section A, pending Jony checkbox confirmation)

**jony-actions-audit updates needed:**
- Items A, B, C: mark RESOLVED tick-4005
- JONY-ACTION I: mark RESOLVED tick-4005 (all sub-items A/B/C done)
- Open count: 6 → 2 (G + O + [verification URL] remain)

---

## What does NOT change

- Q3 correct answer: **No** (unchanged)
- Q3 Holm family membership: H1-Q3 and H2-secondary Q3 (unchanged)
- Q4 correct answer concept: unchanged (vote is durable; receipt needed only for verification)
- H2 analysis structure: unchanged
- §4.1 H1/H2 directional predictions: unchanged
- §4.5 analysis plan: unchanged
- OSF pre-reg §5.2 Q1/Q2/Q5 wording: unchanged (no decisions needed there)

---

## Cross-references to verify after applying

Once A+B+C are applied, verify these are still internally consistent:

1. **§6.1** mentions Q3 coercion scenario — check framing doesn't say "coercive employer" (should be updated to employer-shows-screen framing or kept generic)
2. **§4.1** — H1/H2 describe Q3 as "whether a third party could learn how the voter voted from a screenshot" — this description may need minor update to match new Q3 framing (now "show screen" not "send screenshot")
3. **§4.5** — H1-Q3 and H2-secondary Q3 analysis entries: check no wording-specific description of Q3 that uses pre-reg phrasing

These are §4.1/§6.1 cross-reference checks for the next pass after A/B/C are applied.

---

_Prepared by heartbeat agent tick-4005. Jony confirms → next tick applies all three changes._
