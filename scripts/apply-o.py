#!/usr/bin/env python3
"""
JONY-ACTION O — §4.2 CS/SE student screener extension — commit-ready apply script
Prepared: tick-4230 (2026-06-29)
Updated: tick-4336 (2026-06-30) — retargeted after compression ticks 4309-4318 stripped
  the old [Note (tick-3870):...] block. The paper now carries an inline bracket marker.

Background:
  The survey instrument §SC2 explicitly screens out CS/SE students in addition to
  software engineering professionals. The OSF pre-registration §3 lists only
  professionals; CS/SE students are an unregistered extension of the exclusion
  criteria. OSF Amendment 5 documents this extension (text ready in
  docs/osf-amendment-filing-2026-06-24.md, tick-3920, commit a4df690).

  After compression (ticks 4309-4318), the old multi-line Note block was replaced
  with a compact inline marker inside §4.2:
    [JONY-ACTION O: File OSF Amendment 5 — CS/SE student screener extension
    (before CHI submission)]

  The paper §4.2 also contains the correct disclosure sentence (added tick-4000):
    '(the SC2 screener's extension of the professional exclusion to CS/SE students
    was made before pilot launch and is documented in the OSF amendment log as
    Amendment 5)'

  This script removes the inline [JONY-ACTION O:...] bracket and updates the paper
  header after Jony files Amendment 5 on OSF.

  PREREQUISITE: File OSF Amendment 5 first (text in docs/osf-amendment-filing-2026-06-24.md).
  After filing, run this script to remove the marker.

Usage:
    python3 scripts/apply-o.py            # Dry run (no changes written)
    python3 scripts/apply-o.py --apply    # Apply and write file

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §4.2: JONY-ACTION O resolved — Amendment 5 filed, inline O marker removed"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Inline marker present after compression
O_INLINE = "[JONY-ACTION O: File OSF Amendment 5 — CS/SE student screener extension (before CHI submission)]"

# Disclosure sentence that should still be in the paper body
DISCLOSURE = (
    "(the SC2 screener's extension of the professional exclusion to CS/SE students "
    "was made before pilot launch and is documented in the OSF amendment log as Amendment 5)"
)

# Old header line containing the O reference
HEADER_OLD = (
    "_Status: All sections written. §4.6 Results pending Study 1 data collection "
    "(2026-Q3 pilot). Submission-clean pending OSF amendments O+T._"
)
HEADER_NEW_O_RESOLVED = (
    "_Status: All sections written. §4.6 Results pending Study 1 data collection "
    "(2026-Q3 pilot). Submission-clean pending OSF amendment T (Amendment 14). "
    "Amendment 5 filed. ✅_"
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
ACTIONS_NEW_O_RESOLVED = (
    "_Word count: 9,262 body words (target 9,000–12,000; CHI cap). "
    "Open actions: JONY-ACTION T (OSF Amendment 14). JONY-ACTION O closed. ✅_"
)
ACTIONS_NEW_BOTH_RESOLVED = (
    "_Word count: 9,262 body words (target 9,000–12,000; CHI cap). "
    "No open agent-resolvable actions. OSF upload required before pilot. ✅_"
)

T_INLINE = "[JONY-ACTION T: File OSF Amendment 14"


def check(content: str) -> bool:
    """Dry-run validation. Returns True if all checks pass."""
    ok = True

    if O_INLINE not in content:
        print("ERROR O1: Inline JONY-ACTION O marker not found — already removed?")
        print(f"  Looking for: {O_INLINE[:80]}...")
        ok = False
    else:
        print(f"[OK]  O1: Inline JONY-ACTION O marker found")

    if DISCLOSURE not in content:
        print("WARNING O2: Disclosure sentence not found in §4.2 — was tick-4000 fix reversed?")
        ok = False
    else:
        print("[OK]  O2: Disclosure sentence present in §4.2 body")

    if HEADER_OLD not in content and ACTIONS_OLD not in content:
        print("[INFO] O3: Header already updated or in non-standard state — will still remove inline marker")
    else:
        print("[OK]  O3: Paper header contains open-actions reference (will be updated)")

    return ok


def main():
    do_apply = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION O apply script (§4.2 CS/SE screener inline marker removal) ===")
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
        print(f"  - Remove inline JONY-ACTION O bracket from §4.2 ({len(O_INLINE)} chars)")
        print("  - Update paper header to reflect O closed")
        print("  - Disclosure sentence (Amendment 5) is already in §4.2 body — no change")
        sys.exit(0)

    # Remove inline O marker
    new_content = content.replace(O_INLINE, "", 1)

    # Clean up any double-space left by removal
    new_content = new_content.replace("measures  (the SC2", "measures (the SC2")

    # Update header based on whether T is also resolved
    t_resolved = T_INLINE not in new_content
    if t_resolved:
        new_content = new_content.replace(HEADER_OLD, HEADER_NEW_BOTH_RESOLVED, 1)
        new_content = new_content.replace(ACTIONS_OLD, ACTIONS_NEW_BOTH_RESOLVED, 1)
    else:
        new_content = new_content.replace(HEADER_OLD, HEADER_NEW_O_RESOLVED, 1)
        new_content = new_content.replace(ACTIONS_OLD, ACTIONS_NEW_O_RESOLVED, 1)

    # Post-apply verification
    if O_INLINE in new_content:
        print("ERROR: Inline O marker still present after replacement. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    t_status = "also resolved" if t_resolved else "still open"
    print()
    print("[DONE] JONY-ACTION O applied successfully.")
    print()
    print("Changes made:")
    print(f"  - Removed inline [JONY-ACTION O:...] marker from §4.2")
    print(f"  - Updated paper header (JONY-ACTION T {t_status})")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §4.2: JONY-ACTION O resolved — Amendment 5 filed, inline O marker removed"')
    if not t_resolved:
        print()
        print("Remaining: JONY-ACTION T (OSF Amendments 12+13+14)")
        print("  File Amendment 14 on OSF, then: python3 scripts/apply-t.py --apply")


if __name__ == "__main__":
    main()
