#!/usr/bin/env python3
"""
apply-jj.py — JONY-ACTION JJ apply script
Cover letter ¶2 "coercion resistance" → "double-vote prevention"

Severity: HIGH. Factual overclaim contradicting §3.3 L2 and §6.5 L2.
Blocking: Do NOT send Annie Antón email until this is applied.

Three checks in dry-run mode (default). Use --apply to commit.

Usage:
  python3 scripts/apply-jj.py           # dry-run
  python3 scripts/apply-jj.py --apply   # apply changes
"""

import sys
import re
import pathlib

COVER_LETTER = pathlib.Path("docs/gt-hci-cover-letter-draft-2026-06-29.md")

OLD_TEXT = "coercion resistance simultaneously"
NEW_TEXT = "double-vote prevention simultaneously"

DRY_RUN = "--apply" not in sys.argv

errors = 0


def check(label, condition, detail=""):
    global errors
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        errors += 1
        if detail:
            print(f"         → {detail}")


print("=" * 60)
print("JONY-ACTION JJ — apply-jj.py")
print(f"Mode: {'DRY-RUN' if DRY_RUN else 'APPLY'}")
print("=" * 60)

# Read file
text = COVER_LETTER.read_text(encoding="utf-8")

# JJ1: old text present
jj1_pos = text.find(OLD_TEXT)
check(
    "JJ1: 'coercion resistance simultaneously' found in cover letter",
    jj1_pos != -1,
    f"Expected at line ~20; got position {jj1_pos}"
)

# JJ2: new text NOT yet present (idempotency guard)
jj2_not_present = NEW_TEXT not in text
check(
    "JJ2: 'double-vote prevention simultaneously' not already present (idempotency guard)",
    jj2_not_present,
    "Already applied — re-running would be a no-op."
)

# JJ3: only one occurrence of old text (no unintended multi-replace)
count = text.count(OLD_TEXT)
check(
    "JJ3: exactly one occurrence of old text (no unintended multi-replace)",
    count == 1,
    f"Found {count} occurrences — expected exactly 1."
)

print()
if errors > 0:
    print(f"ABORT — {errors} check(s) failed. No changes written.")
    sys.exit(1)

if DRY_RUN:
    print("Dry-run complete — all 3 checks passed.")
    print()
    print("Change preview:")
    print(f"  BEFORE: '...{OLD_TEXT}...'")
    print(f"  AFTER:  '...{NEW_TEXT}...'")
    print()
    print("To apply:")
    print("  python3 scripts/apply-jj.py --apply")
    print("  git add docs/gt-hci-cover-letter-draft-2026-06-29.md")
    print("  git commit -m 'fix cover letter ¶2: JONY-ACTION JJ — coercion resistance → double-vote prevention'")
else:
    new_text = text.replace(OLD_TEXT, NEW_TEXT, 1)
    COVER_LETTER.write_text(new_text, encoding="utf-8")
    print("Applied. Verify the change:")
    # Show context around the change
    lines = new_text.splitlines()
    for i, line in enumerate(lines, 1):
        if NEW_TEXT in line:
            start = max(0, i - 2)
            end = min(len(lines), i + 2)
            print()
            for j in range(start, end):
                marker = "→" if j + 1 == i else " "
                print(f"  {marker} L{j+1}: {lines[j][:120]}...")
            break
    print()
    print("Next:")
    print("  git add docs/gt-hci-cover-letter-draft-2026-06-29.md")
    print("  git commit -m 'fix cover letter ¶2: JONY-ACTION JJ — coercion resistance → double-vote prevention'")
    print()
    print("Closes JONY-ACTION JJ. Annie Antón email is now unblocked.")
