#!/usr/bin/env python3
"""
JONY-ACTION G — §2.1 undocumented N=12 pilot citation removal — commit-ready apply script
Prepared: tick-4227 (2026-06-29)

Background:
  The original §2.1 draft cited 'unpublished pilot study, N=12' for the design decision
  to collapse the verification affordance by default. Three consecutive repo-wide searches
  (ticks 3767, 4023, 4161) found zero documentation of this pilot anywhere in
  aztec-private-voting/. The design-rationale reframe already in place at §2.1 is
  CHI-safe as a first-principles HCI argument and requires no empirical citation.

  Option (b) [RECOMMENDED]: Remove the JONY-ACTION G inline block. The existing
  first-principles argument ('collapsing avoids displacing the primary status line;
  functions as a second-pass tool') is the full justification. A resolved marker is
  added in its place.

Usage:
    python3 scripts/apply-g.py            # Dry run (no changes written)
    python3 scripts/apply-g.py --apply    # Apply option (b) and write file

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §2.1 N=12 pilot: JONY-ACTION G resolved — option (b) applied (design-rationale reframe CHI-safe)"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Anchor: text immediately before the JONY-ACTION G block.
# This is the last clean sentence of the "Verification affordance" paragraph.
ANCHOR_BEFORE = (
    "Collapsed by default, it functions as a second-pass tool "
    "without competing with the primary confirmation."
)

# The full JONY-ACTION G inline block (to be removed)
JONY_BLOCK = (
    " [JONY-ACTION G: The original draft cited 'unpublished pilot study, N=12' "
    "for this design decision. No documentation of this pilot was found in the "
    "repo (tick-3767 search). Before CHI submission: (a) if the pilot was run "
    "and documented, restore the empirical citation; (b) if it was not run, the "
    "design-rationale reframe above is CHI-safe. Do not leave an undocumented "
    "'unpublished pilot study' claim in the final submission.]"
)

# Resolution marker to insert in place of the JONY-ACTION G block
RESOLUTION_MARKER = (
    " [G RESOLVED \u2014 Option (b) applied tick-4227: Three repo-wide searches "
    "(ticks 3767, 4023, 4161) found zero documentation of any N=12 pilot. "
    "Design-rationale reframe retained: collapsing avoids displacing the primary "
    "status line downward; affordance functions as a second-pass tool. "
    "CHI-safe as a first-principles HCI argument. Closes JONY-ACTION G.]"
)

# Full search string = anchor + block (must appear contiguously)
FULL_SEARCH = ANCHOR_BEFORE + JONY_BLOCK

# Replacement string = anchor + resolution marker
REPLACEMENT = ANCHOR_BEFORE + RESOLUTION_MARKER


def check(content: str) -> bool:
    """Dry-run validation. Returns True if all checks pass."""
    ok = True

    # G1: anchor before block must be present
    pos_anchor = content.find(ANCHOR_BEFORE)
    if pos_anchor == -1:
        print("ERROR G1: ANCHOR_BEFORE not found — was §2.1 verification affordance paragraph moved?")
        ok = False
    else:
        print(f"[OK]  G1: ANCHOR_BEFORE found at char {pos_anchor}")

    # G2: full search string (anchor + block) must be present contiguously
    pos_full = content.find(FULL_SEARCH)
    if pos_full == -1:
        print("ERROR G2: JONY-ACTION G block not found immediately after anchor — already removed?")
        ok = False
    else:
        print(f"[OK]  G2: FULL_SEARCH (anchor + JONY-ACTION G block) found at char {pos_full}")
        print(f"      Block length: {len(JONY_BLOCK)} chars")

    # G3: resolution marker must NOT already be present
    if RESOLUTION_MARKER in content:
        print("WARNING G3: Resolution marker already present — may already be applied.")
        ok = False
    else:
        print("[OK]  G3: Resolution marker not yet present (safe to apply)")

    return ok


def apply_option_b(content: str) -> str:
    """Remove JONY-ACTION G block and insert resolution marker."""
    return content.replace(FULL_SEARCH, REPLACEMENT, 1)


def main():
    do_apply = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION G apply script (§2.1 N=12 pilot citation removal) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode:  {'APPLY' if do_apply else 'DRY RUN'}")
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
        print("Option (b) will:")
        print("  - Remove the [JONY-ACTION G: ...] inline block from §2.1")
        print("  - Insert a [G RESOLVED — ...] marker in its place")
        sys.exit(0)

    new_content = apply_option_b(content)

    # Post-apply verification
    if FULL_SEARCH in new_content:
        print("ERROR: JONY-ACTION G block still present after replacement. Aborting write.")
        sys.exit(1)
    if RESOLUTION_MARKER not in new_content:
        print("ERROR: Resolution marker not found after apply. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] Option (b) applied successfully.")
    print()
    print("Changes made:")
    print("  - Removed [JONY-ACTION G: ...] inline block from §2.1")
    print("  - Inserted [G RESOLVED — Option (b) applied tick-4227: ...] marker")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §2.1 N=12 pilot: JONY-ACTION G resolved — option (b) applied (design-rationale reframe CHI-safe)"')
    print()
    print("Closes JONY-ACTION G. Open JAs: 24 \u2192 23.")


if __name__ == "__main__":
    main()
