#!/usr/bin/env python3
"""
JONY-ACTIONs Z, AA, Q — §1.1 Trio Sentence commit-ready apply script
Prepared: tick-4215 (2026-06-29)
Fixed: tick-4233 (2026-06-29) — added --apply safety guard + dry-run mode

Usage:
    python3 apply-z-aa-q.py            # Dry-run: check + show what would change (NO WRITE)
    python3 apply-z-aa-q.py --apply A  # Apply Option A (mechanism-naming revision, recommended)
    python3 apply-z-aa-q.py --apply B  # Apply Option B (W&T solo)

Run from aztec-private-voting/ root.

After running: git add drafts/piup-chi-paper-draft-2026-06-22.md && git commit -m "fix §1.1 trio: Z/AA/Q resolved — Option A/B applied"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Exact text to remove: the broken trio sentence + all three [Note] blocks
BROKEN_OPENING = (
    "Across usability-security research from Whitten and Tygar's foundational "
    "evaluation of PGP (1999) through Felt et al.'s work on Android permissions "
    "(2012) to Egelman and Schechter's framework for security warnings (2013), a "
    "consistent finding emerges: users interpret interface absence as system error "
    "unless the absence is explicitly marked as intentional. "
)

# The suffix that follows all three [Note] blocks on line 49 — must be preserved exactly
SUFFIX_ANCHOR = " A receipt that shows no vote choice, without explanation"

# Option A: mechanism-naming revision — all three citations retained, each accurately described
OPTION_A = (
    "Usability-security research documents multiple failure modes when users encounter "
    "unexpected security interface states: inferring system failure from absent "
    "confirmation [Whitten and Tygar 1999], ignoring present permission warnings "
    "[Felt et al. 2012], and dismissing warnings as inapplicable [Egelman and "
    "Schechter 2013]. In the receipt context, the operative failure mode is the first."
    " [Z/AA/Q RESOLVED -- Option A applied tick-4215: mechanism-naming revision. "
    "W&T: absent confirmation -> error-attribution. Felt et al.: present dialog -> "
    "non-attention. E&S: present warning -> threat-model dismissal. "
    "'Consistent finding' replaced with precise per-paper characterisation. "
    "Closes JONY-ACTIONs Z (tick-4141), AA (tick-4142), Q (tick-4114).]"
)

# Option B: W&T solo — Felt et al. and E&S removed from §1.1 trio (retained elsewhere)
OPTION_B = (
    "Whitten and Tygar's foundational usability evaluation of PGP (1999) "
    "established the operative failure mode for absent-confirmation interfaces: users "
    "interpret interface absence as system error unless the absence is explicitly "
    "marked as intentional."
    " [Z/AA/Q RESOLVED -- Option B applied tick-4215: W&T solo. Felt et al. (2012) "
    "and E&S (2013) removed from SS1.1 trio (both retained elsewhere: "
    "Felt et al. at SS6.1 lock-icon paragraph; E&S at SS2.1/SS2.2/SS6.1). "
    "Closes JONY-ACTIONs Z (tick-4141), AA (tick-4142), Q (tick-4114).]"
)


def run(option: str | None, dry_run: bool):
    """Run checks and optionally apply. option is 'A', 'B', or None (dry-run only)."""

    if not dry_run and option not in ("A", "B"):
        print(f"ERROR: --apply requires option A or B. Got: {repr(option)}")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    # CHECK 1: broken opening sentence must exist
    if BROKEN_OPENING not in content:
        print("  [FAIL] ZQ1: Broken opening sentence NOT found — already fixed or file changed?")
        print(f"         Looking for: {repr(BROKEN_OPENING[:80])}...")
        sys.exit(1)
    broken_start = content.index(BROKEN_OPENING)
    print(f"  [PASS] ZQ1: Broken opening sentence found at char {broken_start}")

    # CHECK 2: suffix anchor must exist after broken opening
    suffix_pos = content.find(SUFFIX_ANCHOR, broken_start + len(BROKEN_OPENING))
    if suffix_pos == -1:
        print("  [FAIL] ZQ2: Suffix anchor not found after broken opening — file may have changed")
        sys.exit(1)
    block_to_replace = content[broken_start:suffix_pos]
    print(f"  [PASS] ZQ2: Suffix anchor found at char {suffix_pos} (block length: {len(block_to_replace)} chars)")

    # CHECK 3: block starts correctly
    if not block_to_replace.startswith("Across usability-security research"):
        print("  [FAIL] ZQ3: Block extraction mismatch — start check failed")
        sys.exit(1)
    print(f"  [PASS] ZQ3: Block starts correctly")

    # CHECK 4: idempotency — replacement not already present
    resolved_marker = "Z/AA/Q RESOLVED"
    if resolved_marker in content:
        print(f"  [FAIL] ZQ4: Resolution marker already present — already applied?")
        sys.exit(1)
    print(f"  [PASS] ZQ4: Resolution marker not yet present (safe to apply)")

    print()

    if dry_run:
        print("Dry-run complete — all 4 checks passed. No changes written.")
        print()
        print("Option A: mechanism-naming revision (recommended)")
        print(f"  Replaces {len(block_to_replace)}-char block with {len(OPTION_A)}-char replacement")
        print()
        print("Option B: W&T solo")
        print(f"  Replaces {len(block_to_replace)}-char block with {len(OPTION_B)}-char replacement")
        print()
        print("To apply:")
        print("  python3 scripts/apply-z-aa-q.py --apply A")
        print("  python3 scripts/apply-z-aa-q.py --apply B")
        print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
        print('  git commit -m "fix §1.1 trio: Z/AA/Q resolved — Option A/B applied"')
        return

    # Apply
    replacement = OPTION_A if option == "A" else OPTION_B
    new_content = content[:broken_start] + replacement + content[suffix_pos:]

    # Safety check: suffix preserved
    if SUFFIX_ANCHOR not in new_content:
        print("ERROR: Suffix anchor lost after replacement — aborting (no write).")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    chars_diff = len(replacement) - len(block_to_replace)
    print(f"Option {option} applied.")
    print(f"Replaced {len(block_to_replace)} chars with {len(replacement)} chars ({chars_diff:+d} net).")
    print(f"File: {PAPER}")
    print()
    print("Next steps:")
    print(f"  git add {PAPER}")
    if option == "A":
        print('  git commit -m "fix §1.1 trio: Option A — mechanism-naming revision, Z/AA/Q resolved"')
    else:
        print('  git commit -m "fix §1.1 trio: Option B — W&T solo, Z/AA/Q resolved"')
    print()
    print("JAs closed: Z, AA, Q  (24 open → 21 open)")
    print("§2.1 (S), §2.2 (R), §6.1 (P) — NOT touched by this commit. Separate proposals apply.")


if __name__ == "__main__":
    args = sys.argv[1:]
    dry_run = "--apply" not in args
    option = None
    remaining = [a for a in args if a != "--apply"]
    if remaining:
        option = remaining[0].upper()
    run(option=option, dry_run=dry_run)
