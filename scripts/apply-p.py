#!/usr/bin/env python3
"""
JONY-ACTION P — §6.1 E&S mechanism precision — commit-ready apply script
Prepared: tick-4216 (2026-06-29)

Usage:
    python3 apply-p.py          # Dry run (validate without writing)
    python3 apply-p.py --apply   # Apply Option A (only option — recommended)

Run from aztec-private-voting/ root.

After running: git add drafts/piup-chi-paper-draft-2026-06-22.md && git commit -m "fix §6.1 E&S mechanism: JONY-ACTION P resolved — option (a) applied"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Exact opening of the block to replace
# (starts immediately with "This failure mode" — the W&T sentence before it is untouched)
BLOCK_OPEN = (
    "This failure mode is not limited to novice users. Egelman and Schechter (2013) "
    "find that even security-aware users, when confronted with feedback that violates "
    "expected conventions, tend toward behavioral normalization: they attribute the "
    "unexpected signal to error rather than design and proceed as if the system had "
    "confirmed the usual thing. [Note (tick-4113 - JONY-ACTION P):"
)

# Suffix anchor — everything from here onward is preserved intact
SUFFIX_ANCHOR = "] The security property is invisible precisely to the users who most need to understand it."

# Option A — mechanism-accurate E&S sentence (no inline note after resolution)
OPTION_A_REPLACEMENT = (
    "This failure mode is not limited to novice users. Egelman and Schechter (2013) "
    "find that even security-aware users dismiss unexpected security feedback when it "
    "does not align with their threat model \u2014 acting from bounded rationality, they "
    "conscientiously bypass it and proceed as if the system had confirmed the usual thing. "
    "[P RESOLVED \u2014 Option (a) applied tick-4216: E&S mechanism corrected from "
    "'error-attribution' (which is W&T's mechanism) to 'threat-model dismissal / "
    "bounded rationality' (E&S 2013 actual finding: 'misunderstandings about the threat "
    "model led participants to believe that the warnings did not apply to them; acting "
    "out of bounded rationality, participants made conscientious decisions to ignore the "
    "warnings'). Closes JONY-ACTION P (tick-4113).]"
    + SUFFIX_ANCHOR
)


def dry_run(content: str) -> bool:
    """Validate the block is findable and the suffix anchor is intact."""
    pos = content.find(BLOCK_OPEN)
    if pos == -1:
        print("ERROR: BLOCK_OPEN not found — was §6.1 already fixed?")
        print(f"Looking for: {repr(BLOCK_OPEN[:80])}...")
        return False
    print(f"[OK] BLOCK_OPEN found at char {pos}")

    suffix_pos = content.find(SUFFIX_ANCHOR, pos + len(BLOCK_OPEN))
    if suffix_pos == -1:
        print("ERROR: SUFFIX_ANCHOR not found after BLOCK_OPEN.")
        return False
    block_end = suffix_pos + len(SUFFIX_ANCHOR)
    block_len = block_end - pos
    print(f"[OK] SUFFIX_ANCHOR found at char {suffix_pos}")
    print(f"[OK] Total block length: {block_len} chars")
    print()

    # Preview
    excerpt = content[pos:pos + 200]
    print(f"Block opening (first 200 chars):\n  {repr(excerpt)}")
    print()
    excerpt_end = content[suffix_pos - 80:block_end]
    print(f"Block closing (80 chars before suffix + suffix):\n  {repr(excerpt_end)}")
    print()

    # Check replacement text doesn't already appear BEFORE the block
    # (it appears inside the [Note] block itself as quoted option text — that's fine)
    pre_block_text = content[:pos]
    if "acting from bounded rationality, they conscientiously bypass it" in pre_block_text:
        print("WARNING: Option (a) replacement text already present before block — may already be applied.")
        return False
    # Also check it doesn't appear after the block end (i.e., already applied)
    post_block_text = content[block_end:]
    if "conscientiously bypass it and proceed as if the system had confirmed the usual thing. [P RESOLVED" in post_block_text:
        print("WARNING: Resolution marker already present — may already be applied.")
        return False

    print("[OK] All checks passed. Ready to apply.")
    return True


def apply_option_a(content: str) -> str:
    """Replace the broken block with option (a) text."""
    pos = content.find(BLOCK_OPEN)
    suffix_pos = content.find(SUFFIX_ANCHOR, pos + len(BLOCK_OPEN))
    block_end = suffix_pos + len(SUFFIX_ANCHOR)

    new_content = content[:pos] + OPTION_A_REPLACEMENT + content[block_end:]
    return new_content


def main():
    dry = "--apply" not in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION P apply script (§6.1 E&S mechanism fix) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode: {'DRY RUN' if dry else 'APPLY'}")
    print()

    ok = dry_run(content)
    if not ok:
        sys.exit(1)

    if dry:
        print("Dry run complete. No changes written.")
        sys.exit(0)

    new_content = apply_option_a(content)

    # Post-apply verification
    if BLOCK_OPEN in new_content:
        print("ERROR: BLOCK_OPEN still present after replacement. Aborting write.")
        sys.exit(1)
    if "acting from bounded rationality, they conscientiously bypass it" not in new_content:
        print("ERROR: Replacement text not found after apply. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] Option (a) applied successfully.")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §6.1 E&S mechanism: JONY-ACTION P resolved — option (a) applied"')
    print()
    print("Closes JONY-ACTION P. Open JAs: 24 → 23.")


if __name__ == "__main__":
    main()
