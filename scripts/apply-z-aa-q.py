#!/usr/bin/env python3
"""
JONY-ACTIONs Z, AA, Q — §1.1 Trio Sentence commit-ready apply script
Prepared: tick-4215 (2026-06-29)

Usage:
    python3 apply-z-aa-q.py A    # Apply Option A (recommended)
    python3 apply-z-aa-q.py B    # Apply Option B (W&T solo)

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


def apply(option: str):
    if option not in ("A", "B"):
        print(f"Unknown option '{option}'. Use A or B.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    # Find the broken opening sentence
    if BROKEN_OPENING not in content:
        print("ERROR: Broken opening sentence not found — was it already fixed?")
        print(f"Looking for: {repr(BROKEN_OPENING[:80])}...")
        sys.exit(1)

    # Find the suffix anchor (comes after all three [Note] blocks)
    broken_start = content.index(BROKEN_OPENING)
    suffix_pos = content.find(SUFFIX_ANCHOR, broken_start + len(BROKEN_OPENING))
    if suffix_pos == -1:
        print("ERROR: Suffix anchor not found after broken opening. File may have changed.")
        sys.exit(1)

    # The full block to replace = from broken_opening start up to (not including) suffix_anchor
    block_to_replace = content[broken_start:suffix_pos]

    # Verify it starts correctly and ends with the last [Note AA] closing bracket
    if not block_to_replace.startswith("Across usability-security research"):
        print("ERROR: Block extraction mismatch — start check failed.")
        sys.exit(1)

    replacement = OPTION_A if option == "A" else OPTION_B
    new_content = content[:broken_start] + replacement + content[suffix_pos:]

    # Safety check: verify the suffix was preserved
    if SUFFIX_ANCHOR not in new_content:
        print("ERROR: Suffix anchor lost after replacement — aborting.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    chars_removed = len(block_to_replace) - len(replacement)
    print(f"Option {option} applied.")
    print(f"Replaced {len(block_to_replace)} chars with {len(replacement)} chars ({chars_removed:+d} net).")
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
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)
    apply(sys.argv[1].upper())
