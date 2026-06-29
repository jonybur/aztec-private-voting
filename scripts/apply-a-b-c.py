#!/usr/bin/env python3
"""
apply-a-b-c.py — JONY-ACTIONs A, B, C: Q3 stem + Q3 clarification + Q4 stem/answer/foils
Tick-4226 (2026-06-29)

JONY-ACTION A: Q3 question stem — update from pre-reg to instrument wording.
  OLD: "If a coercive employer asked you to send them a screenshot of this screen
       as proof of your vote, could they learn how you voted?"
  NEW: "Imagine your employer tells you they want to verify how you voted, and asks
       you to show them this screen as proof. If you showed a third party your screen
       and your [LABEL], could they tell which voting option you chose?"

JONY-ACTION C: Q3 clarification — remove "Assume they can only see what is on this
  screen." (redundant given new Q3 wording which already constrains info to screen+LABEL).
  OSF amendment required before pilot launch.

JONY-ACTION B: Q4 question stem + correct answer + foils — update from pre-reg to
  instrument wording.
  OLD stem:    "What would happen if you lost this value?"
  OLD correct: "You could still verify that your vote was counted, but you would not
               have proof that the receipt is yours"
  OLD foils:   "you would lose your vote; the system keeps a backup; your vote would
               be reversed"
  NEW stem:    "If you closed this screen without saving your [LABEL], what would happen?"
  NEW correct: "I could still verify that my vote was counted, but I would not have
               this [LABEL] as personal proof"
  NEW foils:   "My vote would be cancelled or reversed; The voting system keeps a copy
               of my [LABEL], so I could always retrieve it later; Nothing — my vote
               does not depend on having this [LABEL]"

On Jony approval 'A+B+C: apply':
  1. cd aztec-private-voting
  2. python3 scripts/apply-a-b-c.py --apply
  3. git add drafts/piup-chi-paper-draft-2026-06-22.md
  4. git commit -m 'fix §4.4 Q3+Q4: JONY-ACTIONs A+B+C resolved — instrument wording adopted'

OSF amendments required before pilot launch (after Jony applies):
  - Amendment for Item A (Q3 stem)
  - Amendment for Item B (Q4 stem + correct answer + foils)
  - Amendment for Item C (Q3 clarification removal)
  See docs/osf-amendment-filing-2026-06-24.md for the filing template.
"""

import sys
import re
import os

DRY_RUN = "--apply" not in sys.argv
PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

def load(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def save(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)

# ── ANCHORS ────────────────────────────────────────────────────────────────────

# ── ABC1: Q3 stem (JONY-ACTION A) ──────────────────────────────────────────────
ABC1_OLD = '"If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?"'
ABC1_NEW = '"Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?"'

# ── ABC2: Q3 clarification + note (JONY-ACTION C) ─────────────────────────────
# Remove the clarification sentence and update the pending-decision note block.
# The old note references Items A and C; replace with a RESOLVED note.
ABC2_OLD = (' A clarification is displayed: "Assume they can only see what is on this screen."'
            ' [Note (pending Jony decision Items A and C, tick-3842): (a) Item A - Q3 wording:'
            ' the pre-registration \u00a75.2 wording above is what the paper currently quotes,'
            ' but the survey instrument \u00a76/Q3 has different wording:'
            " 'Imagine your employer tells you they want to verify how you voted, and asks you"
            " to show them this screen as proof. If you showed a third party your screen and"
            " your [LABEL], could they tell which voting option you chose?'"
            ' The instrument wording (i) avoids the loaded term \u2018coercive\u2019 which may prime'
            " alarm before participants reason about the UI; (ii) replaces 'send them a screenshot'"
            " with 'show them this screen' to match the actual stimulus interaction frame;"
            " (iii) explicitly names '[LABEL]' as the shared information, making the question"
            " directly about the identifier construct; (iv) uses 'which voting option you chose'"
            " (matches Q2 phrasing) rather than 'how you voted.'"
            " The pilot-decisions doc \u00a7Item A (2026-06-25) recommends using the instrument"
            " wording for Q3 and filing an OSF amendment before pilot upload."
            " Correct answer, foils (Yes/No/I'm not sure), and H1-Q3 and H2-secondary Q3"
            " analysis structure are unchanged by this wording update."
            " The amendment is permitted under pre-reg \u00a77.3 ('wording changes to Q3')."
            " If Item A is adopted: update paper \u00a74.4 Q3 question text to instrument wording;"
            " OSF amendment required before pilot launch."
            " (b) Item C - Q3 clarification: pilot-decisions \u00a7Item C recommends DROPPING"
            " the 'Assume they can only see what is on this screen.' clarification from the"
            " baseline. The updated Q3 wording (Item A) already constrains information to the"
            " screen by specifying 'your screen and your [LABEL]' - the clarification is"
            " redundant and introduces a hint. The 'hypothetical scenario' note becomes"
            " implementation-only (added if pilot data shows scenario confusion in free-text)."
            " If Item C is adopted: remove the clarification from paper \u00a74.4 Q3."
            " OSF amendment required (reconciles pre-reg \u00a75.2 and \u00a77.2)."
            " Both Items A and C require Jony's approval before OSF upload.]")

ABC2_NEW = (' [Fixed tick-4226 \u2014 JONY-ACTIONs A+C RESOLVED \u2014 option (a) applied:'
            ' Q3 stem updated to instrument wording (Item A applied):'
            ' avoids loaded term \u201ccoercive\u201d, grounds scenario in the actual stimulus'
            ' interaction (\u201cshow them this screen\u201d), integrates [LABEL] explicitly,'
            ' and uses \u201cwhich voting option you chose\u201d (matching Q2 phrasing).'
            ' Clarification \u201cAssume they can only see what is on this screen.\u201d removed'
            ' (Item C applied): redundant given new wording which already constrains information'
            ' to screen+[LABEL]; removing it also removes an inadvertent hint.'
            ' Correct answer (No), foils (Yes/I\u2019m not sure), and H1-Q3 and H2-secondary Q3'
            ' analysis structure are unchanged. OSF amendments required before pilot launch'
            ' (Amendment for Item A, Amendment for Item C).'
            ' See docs/osf-amendment-filing-2026-06-24.md for the filing template.]')

# ── ABC3: Q4 stem + correct answer + foils (JONY-ACTION B) ────────────────────
ABC3_OLD = ('"What would happen if you lost this value?"'
            ' Correct answer: You could still verify that your vote was counted, but you would'
            ' not have proof that the receipt is yours; foils: you would lose your vote;'
            ' the system keeps a backup; your vote would be reversed.'
            ' Tests understanding that the vote is durable and not rescindable via the receipt.'
            ' [Note (pending Jony decision Item B, tick-3840): the survey instrument (\u00a76/Q4)'
            ' has new wording - \u2018If you closed this screen without saving your [LABEL],'
            " what would happen?' - and new foil structure: (a) My vote would be cancelled or"
            " reversed; (b) CORRECT; (c) The voting system keeps a copy of my [LABEL], so I"
            " could always retrieve it later; (d) Nothing - my vote does not depend on having"
            " this [LABEL]. The pre-registration foils have (a) lose your vote, (c) system keeps"
            " a backup, (d) your vote would be reversed - foil (d) in the instrument is"
            " completely different, replacing a catastrophic-misread distractor with a near-correct"
            " option that isolates the verification-function understanding. Correct answer code"
            " (option b) is unchanged; the correct answer WORDING also differs \u2014 pre-reg"
            " wording (paper body text above): 'you could still verify that your vote was counted,"
            " but you would not have proof that the receipt is yours'; instrument \u00a76/Q4"
            " wording: '(b) I could still verify that my vote was counted, but I would not have"
            " this [LABEL] as personal proof.' Pilot-decisions \u00a7Item B assesses the wording"
            " difference as 'identical in substance' (vote is counted regardless; you lose"
            " personal proof; instrument adds '[LABEL]' for label-consistency). The paper body"
            " text currently quotes the pre-reg wording; if Item B is adopted, all three elements"
            " of the Q4 body-text description must be updated: (1) question stem, (2) correct"
            " answer wording, (3) foils. OSF amendment required before pilot launch."
            " See pilot-decisions \u00a7Item B.] [Cross-check tick-4123: full Q4 body-text"
            " vs instrument \u00a76/Q4 audit complete. JONY-ACTION B scope confirmed to cover"
            " all three elements; note precision gap ('question and foils') fixed above to make"
            " the correct-answer wording update requirement explicit. No new deviations beyond"
            " the stem/correct-answer-wording/foils already documented under JONY-ACTION B.]")

ABC3_NEW = ('"If you closed this screen without saving your [LABEL], what would happen?"'
            ' Correct answer: I could still verify that my vote was counted, but I would not'
            ' have this [LABEL] as personal proof; foils: My vote would be cancelled or reversed;'
            ' The voting system keeps a copy of my [LABEL], so I could always retrieve it later;'
            ' Nothing \u2014 my vote does not depend on having this [LABEL].'
            ' Tests understanding that the vote is durable and not rescindable via the receipt.'
            ' [Fixed tick-4226 \u2014 JONY-ACTION B RESOLVED \u2014 option (a) applied:'
            ' Q4 stem updated to instrument wording (\u201cIf you closed this screen without'
            ' saving your [LABEL]\u201d grounds the scenario in the actual stimulus interaction);'
            ' correct answer updated (\u201cI could still verify\u2026 I would not have this'
            ' [LABEL] as personal proof\u201d adds label-consistency); foils updated to instrument'
            ' \u00a76/Q4 set (foil (d) changed from \u201cyour vote would be reversed\u201d'
            ' \u2014 a duplicate of foil (a) catastrophic-misread \u2014 to'
            ' \u201cNothing \u2014 my vote does not depend on having this [LABEL]\u201d,'
            ' a near-correct option that isolates verification-function understanding).'
            ' Correct answer code (option b) unchanged; analysis script COL_Q4 coding'
            ' unaffected. OSF amendment required before pilot launch.'
            ' See docs/osf-amendment-filing-2026-06-24.md for the filing template.]]')

# ── CHECKS ─────────────────────────────────────────────────────────────────────

def check(text, label, anchor, present=True):
    found = anchor in text
    status = "PASS" if found == present else "FAIL"
    direction = "found" if present else "absent"
    print(f"  {status} — {label}: '{anchor[:80]}...' {direction}")
    return found == present

def run():
    if not os.path.exists(PAPER):
        print(f"ERROR: {PAPER} not found. Run from aztec-private-voting/ root.")
        sys.exit(1)

    text = load(PAPER)
    errors = 0

    print("=== DRY-RUN CHECKS ===\n")

    print("── ABC1: Q3 stem (JONY-ACTION A) ──")
    if not check(text, "ABC1-OLD", ABC1_OLD):
        errors += 1
    print()

    print("── ABC2: Q3 clarification + note (JONY-ACTION C) ──")
    # Check that the old note's opening is present
    abc2_anchor = 'A clarification is displayed: "Assume they can only see what is on this screen."'
    if not check(text, "ABC2-OLD (clarification sentence)", abc2_anchor):
        errors += 1
    abc2_note_anchor = '[Note (pending Jony decision Items A and C, tick-3842):'
    if not check(text, "ABC2-OLD (note opening)", abc2_note_anchor):
        errors += 1
    print()

    print("── ABC3: Q4 stem + answer + foils (JONY-ACTION B) ──")
    abc3_stem_anchor = '"What would happen if you lost this value?"'
    if not check(text, "ABC3-OLD (stem)", abc3_stem_anchor):
        errors += 1
    abc3_answer_anchor = 'Correct answer: You could still verify that your vote was counted, but you would not have proof that the receipt is yours'
    if not check(text, "ABC3-OLD (correct answer)", abc3_answer_anchor):
        errors += 1
    abc3_foils_anchor = 'foils: you would lose your vote; the system keeps a backup; your vote would be reversed.'
    if not check(text, "ABC3-OLD (foils)", abc3_foils_anchor):
        errors += 1
    abc3_note_anchor = '[Note (pending Jony decision Item B, tick-3840):'
    if not check(text, "ABC3-OLD (note opening)", abc3_note_anchor):
        errors += 1
    print()

    if errors > 0:
        print(f"❌ {errors} check(s) FAILED — aborting.")
        sys.exit(1)

    print(f"✅ All checks passed.")
    if DRY_RUN:
        print("\nDry run complete. To apply: python3 scripts/apply-a-b-c.py --apply")
        print("\nChanges that would be applied:")
        print("  1. Q3 stem: pre-reg wording → instrument wording")
        print("  2. Q3 clarification: removed (redundant given new stem)")
        print("  3. Q4 stem + correct answer + foils: pre-reg → instrument wording")
        sys.exit(0)

    print("\n=== APPLYING CHANGES ===\n")

    # ── ABC1: Replace Q3 stem ──────────────────────────────────────────────────
    if ABC1_OLD not in text:
        print("ERROR: ABC1 anchor not found after re-check.")
        sys.exit(1)
    text = text.replace(ABC1_OLD, ABC1_NEW, 1)
    print("  ✅ ABC1: Q3 stem updated to instrument wording.")

    # ── ABC2: Remove clarification sentence + replace note ─────────────────────
    # Strategy: find the clarification sentence + old note block and replace with new note
    # The old note block spans from '[Note (pending Jony decision Items A and C' to the closing ']'
    # We need to find the exact closing bracket.
    # Use a targeted replacement from the clarification sentence through the note closing.

    ABC2_TARGET_START = ' A clarification is displayed: "Assume they can only see what is on this screen." [Note (pending Jony decision Items A and C, tick-3842):'
    # Find the end of the note block by looking for its unique closing suffix
    ABC2_TARGET_END = "Both Items A and C require Jony's approval before OSF upload.]"

    start_idx = text.find(ABC2_TARGET_START)
    if start_idx == -1:
        print("ERROR: ABC2 start anchor not found.")
        sys.exit(1)
    end_idx = text.find(ABC2_TARGET_END, start_idx)
    if end_idx == -1:
        print("ERROR: ABC2 end anchor not found.")
        sys.exit(1)
    end_idx += len(ABC2_TARGET_END)

    text = text[:start_idx] + ABC2_NEW + text[end_idx:]
    print("  ✅ ABC2: Q3 clarification removed + note updated (JONY-ACTIONs A+C resolved).")

    # ── ABC3: Replace Q4 block ─────────────────────────────────────────────────
    ABC3_TARGET_START = '"What would happen if you lost this value?" Correct answer: You could still verify that your vote was counted, but you would not have proof that the receipt is yours; foils: you would lose your vote; the system keeps a backup; your vote would be reversed. Tests understanding that the vote is durable and not rescindable via the receipt. [Note (pending Jony decision Item B, tick-3840):'
    ABC3_TARGET_END   = "the stem/correct-answer-wording/foils already documented under JONY-ACTION B.]"

    start_idx = text.find(ABC3_TARGET_START)
    if start_idx == -1:
        print("ERROR: ABC3 start anchor not found.")
        sys.exit(1)
    end_idx = text.find(ABC3_TARGET_END, start_idx)
    if end_idx == -1:
        print("ERROR: ABC3 end anchor not found.")
        sys.exit(1)
    end_idx += len(ABC3_TARGET_END)

    text = text[:start_idx] + ABC3_NEW + text[end_idx:]
    print("  ✅ ABC3: Q4 stem + correct answer + foils updated to instrument wording (JONY-ACTION B resolved).")

    # ── Verify new anchors present ─────────────────────────────────────────────
    print("\n── Post-apply verification ──")
    post_errors = 0
    if ABC1_NEW not in text:
        print("  FAIL — ABC1 new anchor not found after apply")
        post_errors += 1
    else:
        print("  PASS — ABC1 new Q3 stem present")
    if 'A clarification is displayed: "Assume they can only see what is on this screen."' in text:
        print("  FAIL — ABC2 old clarification still present after apply")
        post_errors += 1
    else:
        print("  PASS — ABC2 clarification removed")
    if 'JONY-ACTIONs A+C RESOLVED' not in text:
        print("  FAIL — ABC2 resolution note not found")
        post_errors += 1
    else:
        print("  PASS — ABC2 resolution note present")
    if '"If you closed this screen without saving your [LABEL], what would happen?"' not in text:
        print("  FAIL — ABC3 new Q4 stem not found")
        post_errors += 1
    else:
        print("  PASS — ABC3 new Q4 stem present")
    if 'JONY-ACTION B RESOLVED' not in text:
        print("  FAIL — ABC3 resolution note not found")
        post_errors += 1
    else:
        print("  PASS — ABC3 resolution note present")

    if post_errors > 0:
        print(f"\n❌ {post_errors} post-apply check(s) failed — NOT saving.")
        sys.exit(1)

    save(PAPER, text)
    print(f"\n✅ Saved {PAPER}")
    print("\nNext steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §4.4 Q3+Q4: JONY-ACTIONs A+B+C resolved — instrument wording adopted'")
    print("\nOSF amendments required before pilot launch:")
    print("  - Amendment for Item A (Q3 stem change)")
    print("  - Amendment for Item B (Q4 stem + answer + foils change)")
    print("  - Amendment for Item C (Q3 clarification removal)")
    print("  See docs/osf-amendment-filing-2026-06-24.md for the filing template.")

if __name__ == "__main__":
    run()
