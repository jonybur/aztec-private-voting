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
*Q4 (Behavioral consequence of receipt loss):* "If you closed this screen without saving your [LABEL], what would happen?" Correct answer: I could still verify that my vote was counted, but I would not have this [LABEL] as personal proof; foils: My vote would be cancelled or reversed; The voting system keeps a copy of my [LABEL], so I could always retrieve it later; Nothing — my vote does not depend on having this [LABEL].
```

**Key changes:**
- "lost this value" → "closed this screen without saving your [LABEL]": maps to actual interface affordance; tests interface-level comprehension rather than abstract object-permanence
- Foil (a): "you would lose your vote" → "My vote would be cancelled or reversed": adds "reversed" escalation for better distractor validity
- Foil (c): "the system keeps a backup" → "The voting system keeps a copy of my [LABEL], so I could always retrieve it later": more specific (uses [LABEL])
- Foil (d): "your vote would be reversed" → "Nothing — my vote does not depend on having this [LABEL]": replaces catastrophic-misread distractor with a near-correct option, which isolates comprehension of the verification function (the receipt is not the vote — not having [LABEL] has no vote-outcome consequence; but it removes personal verification proof)
- Correct answer: "check" → "verify"; "proof the receipt is mine" → "this [LABEL] as personal proof" — instrument uses [LABEL] embed for label-consistency
- Note: foil (d) design-change is substantive — the pre-reg's "vote reversed" distractor tests catastrophic-misread; the instrument's "my vote does not depend on having this [LABEL]" tests whether participants understand the receipt is optional for the vote but needed for verification. This is a better operationalization of H2 schema understanding and was pre-cleared in pilot-decisions §Item B. [Fixed tick-4024: prior draft had 'Nothing — I do not need to save it' and 'I could still check...proof the receipt is mine' — both sourced from an earlier draft; corrected to match the finalized instrument (piup-study1-survey-instrument-2026-06-22.md §6/Q4 and piup-study1-pilot-decisions-2026-06-25.md §Item B).]

### Change 2 of 2: Note block replacement

**Current Note block** (starting "Note (pending Jony decision Item B, tick-3840):"):
> Replace with:

```
[Fixed tick-4005: Decision B adopted (instrument wording). Q4 updated from pre-reg 'lost this value' phrasing to instrument 'closed this screen without saving your [LABEL]' phrasing. Foil (d) updated from 'your vote would be reversed' (catastrophic-misread distractor) to 'Nothing — my vote does not depend on having this [LABEL]' (near-correct distractor; isolates verification-function understanding). Correct answer updated: 'check' → 'verify'; '[LABEL] as personal proof' embed added. OSF Amendment B filed per osf-amendment-filing-2026-06-24.md. See pilot-decisions §Item B for full foil-revision rationale. [Foil text corrected tick-4024: earlier draft had 'Nothing — I do not need to save it' and 'I could still check...proof the receipt is mine' — corrected to instrument-exact wording.]]
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

## Addendum: Cross-Reference Audit Results (tick-4006)

**Scope:** All paper sites that describe Q3's content using "screenshot" language. If Decision A is adopted (instrument wording: "show them this screen" instead of "send a screenshot"), these sites become slightly inaccurate — they anchor Q3's scenario to the old pre-reg framing.

**Audit result:** §4.1 CLEAN, §4.5 CLEAN, §6.1 CLEAN. Three sites need updating.

### Site 1 — Line 90 (§1.2, H2 dissociation prediction)

**Context:** Intro-level paraphrase of what Q3 measures, embedded in the H2 dissociation prediction.

**Current:**
```
Q3: whether a third party could learn how the voter voted from a screenshot of the receipt
```

**After Decision A:**
```
Q3: whether a third party could determine the vote choice by seeing the receipt
```

**Rationale:** "from a screenshot" anchors to the pre-reg scenario (employer asks for a screenshot). New Q3 uses "show them this screen" — a live screen-sharing scenario, not an asynchronous screenshot send. "seeing the receipt" is wording-agnostic and accurate under both old and new Q3 framings.

---

### Site 2 — Line 403 (§6.2, H2 description)

**Context:** H2 dissociation analysis description in the Discussion.

**Current:**
```
Q3 (whether a third party could learn how the voter voted from a screenshot)
```

**After Decision A:**
```
Q3 (whether a third party could determine the vote choice by seeing the receipt screen)
```

**Rationale:** Same fix as Site 1 — removes "screenshot" shorthand that references the old pre-reg framing.

---

### Site 3 — Line 463 (§7, conclusion boundary condition)

**Context:** §7 conclusion characterising Q3 as the H2-secondary endpoint.

**Current:**
```
potentially Q3, whether a screenshot reveals the vote choice (H2-secondary; §4.5)
```

**After Decision A:**
```
potentially Q3, whether sharing the receipt reveals the vote choice (H2-secondary; §4.5)
```

**Rationale:** "a screenshot reveals" → "sharing the receipt reveals". Neutral phrasing covers both the old (send screenshot) and new (show screen) scenario framings.

---

### Sites confirmed CLEAN (no changes needed)

| Section | Lines | Check | Result |
|---|---|---|---|
| §4.1 H1 | 240 | "Q2 and Q3" — no wording-specific description | ✅ CLEAN |
| §4.1 H2 | 241 | "Q2 (primary) and Q3 (secondary)" — no wording-specific description | ✅ CLEAN |
| §4.5 H1 | 307 | "chi-squared tests on Q2 and Q3 accuracy" — no wording description | ✅ CLEAN |
| §4.5 H2 | 309 | "H2-secondary: Q3 accuracy, A vs. B" — no wording description | ✅ CLEAN |
| §6.1 | 393 | "coercion scenario" framing — conceptual, no "screenshot" Q3 description | ✅ CLEAN |
| §6.5 / §4.3 | 266, 439 | "screenshot stimuli" / "screenshot method" — describes METHOD not Q3 wording | ✅ CLEAN |
| §6.5 | 441 | **⚠️ GAP — quotes old Q4 wording directly** (see Site 4 below) | needs fix after Decision B |

### Site 4 — Line 441 (§6.5, ecological validity note)

**Context:** Ecological validity discussion. Quotes the Q4 wording directly to argue Q4 is a knowledge question answerable from a screenshot. Argument is valid under both old and new Q4 wording; only the quoted text needs updating.

**Current:**
```
Note: Q4 as defined in §4.4 is a behavioral-consequence knowledge question ('what would happen if you lost this value?') - a knowledge item equally answerable from a screenshot
```

**After Decision B:**
```
Note: Q4 as defined in §4.4 is a behavioral-consequence knowledge question ('if you closed this screen without saving your [LABEL], what would happen?') - a knowledge item equally answerable from a screenshot
```

**Rationale:** The ecological validity argument is unchanged — Q4 tests abstract knowledge of a behavioral consequence, not an interactive affordance, so it remains equally answerable from a screenshot under either wording. The quote simply needs to reflect the adopted instrument wording. The [LABEL] placeholder is used throughout the paper and is appropriate here.

**Gap discovered:** tick-4031 cross-reference audit. This site was not in the tick-4006 addendum (that addendum only audited "screenshot" METHOD language for Decision A; this is a Decision B Q4 quote gap).

---

### Summary of additional changes to apply after A/B/C confirmed

When applying the A/B/C changes from the section above, also apply:

| Site | Line | Triggered by | Current | After decision |
|---|---|---|---|---|
| §1.2 | 90 | Decision A | "from a screenshot of the receipt" | "by seeing the receipt" |
| §6.2 | 403 | Decision A | "from a screenshot" | "by seeing the receipt screen" |
| §7 | 463 | Decision A | "whether a screenshot reveals" | "whether sharing the receipt reveals" |
| §6.5 | 441 | Decision B | "'what would happen if you lost this value?'" | "'if you closed this screen without saving your [LABEL], what would happen?'" |

Total additional paper changes: **3 after Decision A + 1 after Decision B** (all in main text, none in Note blocks).

---

_Prepared by heartbeat agent tick-4005. Cross-reference addendum added tick-4006. Site 4 (§6.5 Q4 quote) added tick-4031. Jony confirms → next tick applies all §4.4 + cross-ref changes in one pass._
