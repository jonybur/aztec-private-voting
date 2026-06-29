#!/usr/bin/env python3
"""
JONY-ACTION O — §4.2 CS/SE student screener extension — commit-ready apply script
Prepared: tick-4230 (2026-06-29)

Background:
  The survey instrument §SC2 explicitly screens out CS/SE students in addition to
  software engineering professionals. The OSF pre-registration §3 lists only
  professionals; CS/SE students are an unregistered extension of the exclusion
  criteria. OSF Amendment 5 documents this extension (text ready in
  docs/osf-amendment-filing-2026-06-24.md, tick-3920, commit a4df690).

  The paper §4.2 already contains the correct disclosure sentence (added tick-4000):
    '(the SC2 screener's extension of the professional exclusion to CS/SE students
    was made before pilot launch and is documented in the OSF amendment log as
    Amendment 5)'

  This script removes the pre-submission note block [Note (tick-3870): ...] from
  §4.2 after Jony files Amendment 5 on OSF.

  PREREQUISITE: File OSF Amendment 5 first (text in docs/osf-amendment-filing-2026-06-24.md).
  After filing, run this script to remove the note.

Usage:
    python3 scripts/apply-o.py            # Dry run (no changes written)
    python3 scripts/apply-o.py --apply    # Apply and write file

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §4.2: JONY-ACTION O resolved — Amendment 5 filed, CS/SE screener note removed"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Unique anchor: first 80 chars of the O note block
O_ANCHOR = "[Note (tick-3870): INSTRUMENT-TO-PRE-REG DISCREPANCY - the survey instrument §SC2"

# Resolution marker (replaces the full block)
O_RESOLUTION = (
    "[O RESOLVED \u2014 tick-4230: OSF Amendment 5 filed. "
    "CS/SE student screener extension documented in OSF amendment log. "
    "Disclosure sentence already in §4.2 body (tick-4000). Closes JONY-ACTION O.]"
)


def find_bracket_block(content: str, anchor: str):
    """Find a bracket-delimited block starting at 'anchor'. Returns (start, end) exclusive."""
    idx = content.find(anchor)
    if idx == -1:
        return None, None
    depth = 0
    i = idx
    while i < len(content):
        if content[i] == '[':
            depth += 1
        elif content[i] == ']':
            depth -= 1
            if depth == 0:
                return idx, i + 1
        i += 1
    return idx, None


def check(content: str) -> bool:
    """Dry-run validation. Returns True if all checks pass."""
    ok = True

    # O1: anchor must be present
    pos = content.find(O_ANCHOR)
    if pos == -1:
        print("ERROR O1: JONY-ACTION O note block anchor not found — already removed?")
        ok = False
    else:
        start, end = find_bracket_block(content, O_ANCHOR)
        if end is None:
            print("ERROR O1b: Found anchor but could not find matching closing bracket.")
            ok = False
        else:
            block_len = end - start
            print(f"[OK]  O1: JONY-ACTION O note block found at char {start} (length {block_len} chars)")

    # O2: resolution marker must NOT already be present
    if O_RESOLUTION in content:
        print("WARNING O2: Resolution marker already present — may already be applied.")
        ok = False
    else:
        print("[OK]  O2: Resolution marker not yet present (safe to apply)")

    # O3: disclosure sentence must be present (verify it was added tick-4000)
    disclosure = "(the SC2 screener's extension of the professional exclusion to CS/SE students was made before pilot launch and is documented in the OSF amendment log as Amendment 5)"
    if disclosure not in content:
        print("WARNING O3: Disclosure sentence not found in §4.2 — was tick-4000 fix reversed?")
        ok = False
    else:
        print("[OK]  O3: Disclosure sentence present in §4.2 body")

    return ok


def apply_script(content: str) -> str:
    """Remove the JONY-ACTION O note block and insert resolution marker."""
    start, end = find_bracket_block(content, O_ANCHOR)
    if start is None or end is None:
        raise ValueError("Could not locate JONY-ACTION O block for replacement.")
    return content[:start] + O_RESOLUTION + content[end:]


def main():
    do_apply = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION O apply script (§4.2 CS/SE screener note removal) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode:  {'APPLY' if do_apply else 'DRY RUN'}")
    print()
    print("PREREQUISITE: File OSF Amendment 5 before running --apply.")
    print("  Amendment 5 text: docs/osf-amendment-filing-2026-06-24.md")
    print()

    ok = check(content)
    if not ok:
        print()
        print("One or more checks failed. Fix issues before applying.")
        sys.exit(1)

    if not do_apply:
        print()
        print("All checks passed. Run with --apply to write changes.")
        print()
        print("This script will:")
        print("  - Remove [Note (tick-3870): ...] block from §4.2 (1,859 chars)")
        print("  - Insert [O RESOLVED ...] resolution marker")
        print("  - Paper disclosure sentence (Amendment 5) is already in §4.2 body")
        sys.exit(0)

    new_content = apply_script(content)

    # Post-apply verification
    if O_ANCHOR in new_content:
        print("ERROR: O note block still present after replacement. Aborting write.")
        sys.exit(1)
    if O_RESOLUTION not in new_content:
        print("ERROR: Resolution marker not found after apply. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] JONY-ACTION O applied successfully.")
    print()
    print("Changes made:")
    print("  - Removed [Note (tick-3870): ...] note block from §4.2 (1,859 chars)")
    print("  - Inserted [O RESOLVED ...] resolution marker")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §4.2: JONY-ACTION O resolved — Amendment 5 filed, CS/SE screener note removed"')
    print()
    print("Closes JONY-ACTION O. Open JAs: 24 \u2192 23.")


if __name__ == "__main__":
    main()
