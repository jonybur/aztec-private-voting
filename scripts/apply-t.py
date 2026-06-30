#!/usr/bin/env python3
"""
JONY-ACTION T — OSF Amendments 12+13+14 — commit-ready apply script
Prepared: tick-4230 (2026-06-29)
Updated: tick-4336 (2026-06-30) — retargeted after compression ticks 4309-4318 stripped
  the old [Note (tick-4124):...] and [Note (tick-4150):...] blocks.
  Amendments 12 (Q5 wording) and 13 (MQ1 rubric) note blocks were cleaned during
  compression and are no longer in the paper. Only the inline Amendment 14 marker
  remains. This script removes that marker after OSF filing.

Background:
  JONY-ACTION T covers three OSF amendments that Jony must file before pilot launch:

  Amendment 12 (tick-4124, item 1): Q5 wording deviations from pre-reg §5.2.
    The instrument §6/Q5 has 4 deviations: (a) 'In your own words:' prefix;
    (b) 'the system' → 'this voting system'; (c) lowercase 'not' → emphasized 'NOT';
    (d) 'your vote choice' → 'which option you voted for'. Rubric unchanged.
    Note: the Amendment 12 annotation block was removed during compression (tick-4318).
    Filing Amendment 12 on OSF is still required before pilot; the paper prose is clean.

  Amendment 13 (tick-4124, item 2): MQ1 rubric clarification.
    Pre-reg §5.3 abbreviated rubric is ambiguous for non-leakage-only responses.
    Instrument §11 two-dimensional additive rubric is the operative operationalization.
    Note: the Amendment 13 annotation block was removed during compression (tick-4318).
    Filing Amendment 13 on OSF is still required before pilot; the paper prose is clean.

  Amendment 14 (tick-4150): Attention check descriptions correction.
    Pre-reg §3 describes AC1 as 'select strongly agree' (WRONG — actual answer is
    'Strongly Disagree') and AC2 as 'Which of the following is a fruit?' (WRONG —
    actual question asks for 'the third item from the list' where correct answer is
    Carrot, a vegetable). Both-fail exclusion criterion is correctly implemented;
    only the pre-reg description is inaccurate.

  After compression (ticks 4309-4318), the old multi-line Note blocks for Amendments
  12 and 13 were stripped. Amendment 14's block was replaced with a compact inline
  marker inside §4.2:
    [JONY-ACTION T: File OSF Amendment 14 — correct attention check descriptions in
    pre-reg §3 (AC1: select "Strongly Disagree"; AC2: select third item = Carrot)
    before CHI submission]

  This script removes that inline marker after Jony files Amendments 12, 13, and 14.

  PREREQUISITE: File OSF Amendments 12, 13, and 14 before running --apply.
  Amendment 12+13 language is in docs/jony-batch-decision-memo-2026-06-28.md §T.
  Amendment 14 language is in docs/osf-amendment-filing-2026-06-24.md §Amendment 14.

Usage:
    python3 scripts/apply-t.py            # Dry run (no changes written)
    python3 scripts/apply-t.py --apply    # Apply and write file

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §4.2: JONY-ACTION T resolved — Amendments 12+13+14 filed, inline T marker removed"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Inline marker present after compression (Amendment 14 only — 12+13 blocks were cleaned)
T_INLINE = (
    '[JONY-ACTION T: File OSF Amendment 14 — correct attention check descriptions in '
    'pre-reg §3 (AC1: select "Strongly Disagree"; AC2: select third item = Carrot) '
    'before CHI submission]'
)

# Old header lines containing the T reference
HEADER_OLD = (
    "_Status: All sections written. §4.6 Results pending Study 1 data collection "
    "(2026-Q3 pilot). Submission-clean pending OSF amendments O+T._"
)
HEADER_NEW_T_RESOLVED = (
    "_Status: All sections written. §4.6 Results pending Study 1 data collection "
    "(2026-Q3 pilot). Submission-clean pending OSF amendment O (Amendment 5). "
    "Amendments 12+13+14 filed. ✅_"
)
HEADER_NEW_BOTH_RESOLVED = (
    "_Status: All sections written. §4.6 Results pending Study 1 data collection "
    "(2026-Q3 pilot). Submission-clean — OSF amendments O+T filed (Amendments 5 and 14). "
    "OSF pre-registration upload required before pilot. ✅_"
)

ACTIONS_OLD = (
    "_Word count: 9,262 body words (target 9,000–12,000; CHI cap). "
    "Open actions: JONY-ACTION O (OSF Amendment 5) + JONY-ACTION T (OSF Amendment 14)._"
)
ACTIONS_NEW_T_RESOLVED = (
    "_Word count: 9,262 body words (target 9,000–12,000; CHI cap). "
    "Open actions: JONY-ACTION O (OSF Amendment 5). JONY-ACTION T closed. ✅_"
)
ACTIONS_NEW_BOTH_RESOLVED = (
    "_Word count: 9,262 body words (target 9,000–12,000; CHI cap). "
    "No open agent-resolvable actions. OSF upload required before pilot. ✅_"
)

O_INLINE = "[JONY-ACTION O: File OSF Amendment 5"


def check(content: str) -> bool:
    """Dry-run validation. Returns True if all checks pass."""
    ok = True

    if T_INLINE not in content:
        print("ERROR T1: Inline JONY-ACTION T marker not found — already removed?")
        print(f"  Looking for: {T_INLINE[:80]}...")
        ok = False
    else:
        print(f"[OK]  T1: Inline JONY-ACTION T (Amendment 14) marker found")

    # Note: Amendments 12+13 note blocks were stripped during compression — no check needed.
    print("[INFO] T2: Amendment 12 (Q5 wording) and Amendment 13 (MQ1 rubric) note blocks")
    print("       were cleaned during compression (ticks 4309-4318). Paper prose is clean.")
    print("       File Amendments 12+13 on OSF before running --apply.")

    return ok


def main():
    do_apply = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION T apply script (OSF Amendments 12+13+14 inline marker removal) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode:  {'APPLY' if do_apply else 'DRY RUN'}")
    print()
    print("PREREQUISITE: File OSF Amendments 12, 13, and 14 before running --apply.")
    print("  Amendment 12+13 language: docs/jony-batch-decision-memo-2026-06-28.md §T")
    print("  Amendment 14 language: docs/osf-amendment-filing-2026-06-24.md §Amendment 14")
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
        print(f"  - Remove inline JONY-ACTION T bracket from §4.2 ({len(T_INLINE)} chars)")
        print("  - Update paper header to reflect T closed")
        print("  Note: Amendment 12+13 note blocks were already cleaned by compression.")
        print("        File them on OSF before running this script.")
        sys.exit(0)

    # Remove inline T marker
    new_content = content.replace(T_INLINE, "", 1)

    # Clean up any double-semicolon or trailing space left by removal
    new_content = new_content.replace("; and participants", "; and participants")  # no-op guard

    # Update header based on whether O is also resolved
    o_resolved = O_INLINE not in new_content
    if o_resolved:
        new_content = new_content.replace(HEADER_OLD, HEADER_NEW_BOTH_RESOLVED, 1)
        new_content = new_content.replace(ACTIONS_OLD, ACTIONS_NEW_BOTH_RESOLVED, 1)
    else:
        new_content = new_content.replace(HEADER_OLD, HEADER_NEW_T_RESOLVED, 1)
        new_content = new_content.replace(ACTIONS_OLD, ACTIONS_NEW_T_RESOLVED, 1)

    # Post-apply verification
    if T_INLINE in new_content:
        print("ERROR: Inline T marker still present after replacement. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    o_status = "also resolved" if o_resolved else "still open"
    print()
    print("[DONE] JONY-ACTION T applied successfully.")
    print()
    print("Changes made:")
    print(f"  - Removed inline [JONY-ACTION T:...] marker from §4.2 ({len(T_INLINE)} chars)")
    print(f"  - Updated paper header (JONY-ACTION O {o_status})")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §4.2: JONY-ACTION T resolved — Amendments 12+13+14 filed, inline T marker removed"')
    if not o_resolved:
        print()
        print("Remaining: JONY-ACTION O (OSF Amendment 5)")
        print("  File Amendment 5 on OSF, then: python3 scripts/apply-o.py --apply")


if __name__ == "__main__":
    main()
