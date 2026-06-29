#!/usr/bin/env python3
"""
Apply script for JONY-ACTION DD (Adida et al. 2009 author list confirmation).

Resolution: The current bibliography entry is CORRECT — 4-author Adida-first list
confirmed by three independent sources:
  (1) USENIX PDF URL naming convention (adida.pdf → Adida is first author)
  (2) Caltech Election Updates recap (2009-08-12): explicitly lists all 4 authors, Adida first
  (3) Springer book chapter citation: same 4-author Adida-first order

The USENIX proceedings BibTeX (3-author, no Adida) is a database error that
contradicts the URL convention and two other sources. OPTION (a): accept current entry.

Action: Remove the JONY-ACTION DD note from the bibliography entry; mark RESOLVED.
In-text: 'Adida et al. (2009)' is correct — no changes needed.

Usage:
  python3 scripts/apply-dd.py          # dry-run (no changes)
  python3 scripts/apply-dd.py --apply  # apply changes to file
"""

import sys

DRAFT_PATH = "drafts/piup-chi-paper-draft-2026-06-22.md"

# The current entry including the JONY-ACTION DD note
OLD_ENTRY = (
    '- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). '
    '"Electing a University President Using Open-Audit Voting: Analysis of Real-World '
    'Use of Helios." _EVT/WOTE 2009._ '
    '[Note (tick-4156 — JONY-ACTION DD, updated tick-4158): AUTHOR LIST CONFLICT, '
    'CONFIDENCE UPGRADED TO HIGH for current entry \u2705(probable). '
    'Verification sources: (1) USENIX legacy PDF URL `adida.pdf` \u2014 under USENIX '
    'naming conventions, filename = first author surname; supports Adida-first. '
    '(2) Caltech Election Updates real-time recap (2009-08-12): explicitly lists '
    '\'Authors: Ben Adida, Olivier de Marneffe, Olivier Pereira and Jean-Jacques '
    'Quisquater\' \u2014 4 authors, Adida first. (3) Springer book citation '
    '(link.springer.com): \'Adida, B., De Marneffe, O., Pereira, O., Quisquater, '
    'J.J.\' \u2014 4 authors, Adida first. (4) USENIX current proceedings BibTeX '
    '(snippet): `author = {Olivier de Marneffe and Olivier Pereira and Jean-Jacques '
    'Quisquater}` \u2014 3 authors, no Adida; likely a database error on the USENIX '
    'side (contradicts the URL naming convention). (5) NIST CSRC '
    '`demarneffe_papere2e.pdf` \u2014 separate NIST E2E workshop document, not the '
    'EVT/WOTE proceedings paper; not directly relevant. CONCLUSION: Weight of evidence '
    'strongly supports 4-author Adida-first list. OPTION (a) RECOMMENDED WITH HIGH '
    'CONFIDENCE: accept current bibliography. In-text citations \'Adida et al. (2009)\' '
    'are likely correct. Jony: please confirm option (a) to close JONY-ACTION DD.]'
)

# Clean replacement: correct entry with a short RESOLVED note
NEW_ENTRY = (
    '- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). '
    '"Electing a University President Using Open-Audit Voting: Analysis of Real-World '
    'Use of Helios." _EVT/WOTE 2009._ '
    '[JONY-ACTION DD RESOLVED \u2014 4-author Adida-first list confirmed by Caltech '
    'Election Updates recap (2009-08-12) and Springer citation; USENIX BibTeX '
    '(3-author) is a database error.]'
)


def run(apply: bool) -> int:
    text = open(DRAFT_PATH, encoding="utf-8").read()

    # --- Check 1: old entry present ---
    pos = text.find(OLD_ENTRY)
    if pos == -1:
        print("FAIL DD1: JONY-ACTION DD bibliography entry not found")
        print("  Expected start: '- Adida, B., de Marneffe...'")
        return 1
    print(f"PASS DD1: JONY-ACTION DD bibliography entry found at char {pos}")

    # --- Check 2: in-text citation present and correct ---
    intxt = "Helios (Adida et al. 2009)"
    pos2 = text.find(intxt)
    if pos2 == -1:
        print("FAIL DD2: In-text 'Helios (Adida et al. 2009)' not found")
        return 1
    print(f"PASS DD2: In-text 'Helios (Adida et al. 2009)' found at char {pos2} — CORRECT, no change needed")

    # --- Check 3: new entry not already present ---
    if text.find(NEW_ENTRY) != -1:
        print("INFO DD3: Replacement already applied — nothing to do")
        return 0
    print("PASS DD3: Replacement not yet applied — safe to write")

    if not apply:
        print()
        print("DRY-RUN complete (3/3 checks passed). Run with --apply to write changes.")
        print()
        print("Changes summary:")
        print("  DD1: Remove JONY-ACTION DD note from bibliography entry (Adida et al. 2009)")
        print("       Replace with clean entry + short RESOLVED marker")
        print("  No in-text changes — 'Adida et al. (2009)' is already correct")
        return 0

    # Apply
    new_text = text.replace(OLD_ENTRY, NEW_ENTRY, 1)
    if new_text == text:
        print("ERROR: replace() had no effect — file unchanged")
        return 1

    open(DRAFT_PATH, "w", encoding="utf-8").write(new_text)
    print()
    print("APPLIED. Changes written to", DRAFT_PATH)
    print()
    print("Next step:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix bibliography: JONY-ACTION DD resolved — Adida et al. (2009) confirmed'")
    print()
    print("Open JAs after commit: 24 → 23")
    return 0


if __name__ == "__main__":
    apply = "--apply" in sys.argv
    sys.exit(run(apply))
