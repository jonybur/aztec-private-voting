#!/usr/bin/env python3
"""
Apply script for JONY-ACTION BB: Carback et al. (2010) author fix.

Two changes:
  BB1 — In-text: 'Chaum et al.'s (2010)' → 'Carback et al.'s (2010)' in §1.4
  BB2 — Bibliography: Correct author list (Chaum-first 10-author → Carback-first 12-author)

DBLP key: conf/uss/CarbackCCCEHMPRSSV10
Correct 12-author list (Carback first, Ryan P.Y.A. removed, 3 authors added):
  Carback, R., Chaum, D., Clark, J., Conway, J., Essex, A., Herrnson, P.S.,
  Mayberry, T., Popoveniuc, S., Rivest, R.L., Shen, E., Sherman, A.T., and Vora, P.L.

Run with --dry-run to validate without writing.
"""
import sys
import re

PAPER = 'drafts/piup-chi-paper-draft-2026-06-22.md'

BB1_OLD = "Chaum et al.'s (2010)"
BB1_NEW = "Carback et al.'s (2010)"
BB1_NOTE_OLD = "[Note (tick-4154 — JONY-ACTION BB): AUTHOR LIST INCORRECT ❌."
BB1_NOTE_NEW = "[Note (tick-4218 — JONY-ACTION BB RESOLVED — option (a) applied): AUTHOR LIST CORRECTED ✅. Carback-first 12-author list applied. In-text 'Chaum et al.' → 'Carback et al.' (§1.4). Bibliography corrected: Conway, J.; Herrnson, P.S.; Mayberry, T. added; Ryan, P.Y.A. removed; Carback listed first. Source: DBLP conf/uss/CarbackCCCEHMPRSSV10 (verified tick-4154)."

BB2_OLD = "- Chaum, D., Carback, R., Clark, J., Essex, A., Popoveniuc, S., Rivest, R.L., Ryan, P.Y.A., Shen, E., Sherman, A.T., and Vora, P.L. (2010)."
BB2_NEW = "- Carback, R., Chaum, D., Clark, J., Conway, J., Essex, A., Herrnson, P.S., Mayberry, T., Popoveniuc, S., Rivest, R.L., Shen, E., Sherman, A.T., and Vora, P.L. (2010)."

DRY_RUN = '--apply' not in sys.argv

with open(PAPER, 'r') as f:
    text = f.read()

errors = []
checks = []

# BB1: in-text replacement
count_bb1_old = text.count(BB1_OLD)
if count_bb1_old == 1:
    char_pos = text.index(BB1_OLD)
    checks.append(f"BB1 (in-text): '{BB1_OLD}' found at char {char_pos} — PASS")
elif count_bb1_old == 0:
    errors.append("BB1 (in-text): ANCHOR NOT FOUND — 'Chaum et al.'s (2010)' missing")
else:
    errors.append(f"BB1 (in-text): AMBIGUOUS — found {count_bb1_old} occurrences of anchor")

# BB1-note: note replacement (exactly 1 occurrence)
count_note_old = text.count(BB1_NOTE_OLD)
if count_note_old == 1:
    char_pos_note = text.index(BB1_NOTE_OLD)
    checks.append(f"BB1-note: JONY-ACTION BB note found at char {char_pos_note} — PASS")
elif count_note_old == 0:
    errors.append("BB1-note: BB note anchor not found — may already be resolved or text changed")
else:
    errors.append(f"BB1-note: AMBIGUOUS — {count_note_old} occurrences")

# BB2: bibliography replacement
count_bb2_old = text.count(BB2_OLD)
if count_bb2_old == 1:
    char_pos_bib = text.index(BB2_OLD)
    checks.append(f"BB2 (bibliography): author line found at char {char_pos_bib} — PASS")
elif count_bb2_old == 0:
    errors.append("BB2 (bibliography): ANCHOR NOT FOUND — Chaum-first author line missing")
else:
    errors.append(f"BB2 (bibliography): AMBIGUOUS — {count_bb2_old} occurrences")

# Report checks
print("=== JONY-ACTION BB apply script ===")
for c in checks:
    print(f"  ✅ {c}")
for e in errors:
    print(f"  ❌ {e}")

if errors:
    print(f"\n{len(errors)} error(s) — aborting. Do not apply.")
    sys.exit(1)

print(f"\nAll {len(checks)} checks passed.")

if DRY_RUN:
    print("DRY RUN — no changes written.")
    sys.exit(0)

# Apply BB1: in-text
text = text.replace(BB1_OLD, BB1_NEW, 1)

# Apply BB1-note: replace JONY-ACTION BB note (cap at note start through first closing bracket)
# The note starts with BB1_NOTE_OLD and ends with '...Jony must confirm before CHI submission.]'
# We replace from the note open marker to '...submission.]'
NOTE_END = "Jony must confirm before CHI submission.]"
note_start_pos = text.index(BB1_NOTE_OLD)
note_end_pos = text.index(NOTE_END, note_start_pos)
if note_end_pos == -1:
    print("ERROR: note end anchor not found after applying BB1")
    sys.exit(1)
note_end_pos += len(NOTE_END)
text = text[:note_start_pos] + BB1_NOTE_NEW + text[note_end_pos:]

# Apply BB2: bibliography
text = text.replace(BB2_OLD, BB2_NEW, 1)

with open(PAPER, 'w') as f:
    f.write(text)

print("Applied:")
print(f"  BB1: in-text 'Chaum et al.'s (2010)' → 'Carback et al.'s (2010)'")
print(f"  BB1-note: JONY-ACTION BB note updated to RESOLVED")
print(f"  BB2: bibliography corrected to Carback-first 12-author list")
print("\nReady to commit:")
print(f"  git add {PAPER}")
print("  git commit -m 'fix bibliography: JONY-ACTION BB resolved — Carback et al. (2010) corrected'")
