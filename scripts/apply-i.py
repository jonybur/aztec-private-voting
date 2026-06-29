#!/usr/bin/env python3
"""
JONY-ACTION I — §4.2 JONY-ACTION I block removal
Removes the [JONY-ACTION I (new, tick-3819): ...] block from §4.2 (line 262).

Context:
  JONY-ACTION I was a holding note for five wording conflicts (Items A-E) between
  the pre-reg and the instrument. Items A, B, C are resolved by apply-a-b-c.py;
  Item D required no amendment; Item E (BI1 label) is tracked separately.
  Once A/B/C are applied this block is stale and should be removed.

Prerequisite:
  Apply apply-a-b-c.py --apply first. This script does NOT check for that —
  it only checks that the JONY-ACTION I block still exists before removing it.

Dry-run (default): prints matches and diffs without writing.
Apply mode (--apply): writes the change to disk.

Run:
  python3 scripts/apply-i.py           # dry-run
  python3 scripts/apply-i.py --apply   # apply

Commit after applying:
  git add drafts/piup-chi-paper-draft-2026-06-22.md
  git commit -m 'fix §4.2: JONY-ACTION I resolved — block removed (A/B/C applied)'
"""

import sys
import re

DRAFT_PATH = "drafts/piup-chi-paper-draft-2026-06-22.md"

# The exact JONY-ACTION I block to remove
BLOCK_START = "[JONY-ACTION I (new, tick-3819): "
BLOCK_END   = "Awaiting Jony decision.]"

# Resolution marker to insert instead of removing entirely
RESOLUTION_MARKER = "[JONY-ACTION I resolved (tick-4228): Items A/B/C applied (apply-a-b-c.py). Item D: no amendment needed. Item E (BI1 label): tracked separately. Block removed.]"


def run(apply_mode: bool = False):
    with open(DRAFT_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    # Build the full block from start to end (inclusive)
    start_idx = content.find(BLOCK_START)
    if start_idx == -1:
        print("I1: JONY-ACTION I block NOT FOUND — already removed or not yet present.")
        print("FAIL" if apply_mode else "DRY-RUN FAIL (would fail on apply)")
        sys.exit(1)

    end_idx = content.find(BLOCK_END, start_idx)
    if end_idx == -1:
        print("I2: JONY-ACTION I block start found but end marker not found — malformed.")
        sys.exit(1)

    block_end_inclusive = end_idx + len(BLOCK_END)
    full_block = content[start_idx:block_end_inclusive]

    print(f"I1: JONY-ACTION I block found at char {start_idx} — PASS")
    print(f"    Block length: {len(full_block)} chars")
    print(f"    Preview (first 120 chars): {full_block[:120]!r}")

    # Check resolution marker not already present
    if RESOLUTION_MARKER in content:
        print("I3: Resolution marker already present — nothing to do.")
        sys.exit(0)
    print("I2: Resolution marker not yet present — safe to apply — PASS")

    # Build new content: replace block with resolution marker
    new_content = content[:start_idx] + RESOLUTION_MARKER + content[block_end_inclusive:]

    if not apply_mode:
        print("\nDRY-RUN COMPLETE — all checks pass. Run with --apply to write changes.")
        print(f"  Removed block ({len(full_block)} chars)")
        print(f"  Inserted resolution marker ({len(RESOLUTION_MARKER)} chars)")
        return

    with open(DRAFT_PATH, "w", encoding="utf-8") as f:
        f.write(new_content)

    print("\nAPPLIED — JONY-ACTION I block removed and resolution marker inserted.")
    print(f"  {DRAFT_PATH} updated.")
    print("\nNext steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §4.2: JONY-ACTION I resolved — block removed (A/B/C applied)'")


if __name__ == "__main__":
    apply_mode = "--apply" in sys.argv
    run(apply_mode)
