#!/usr/bin/env python3
"""
JONY-ACTION U — VoteReceipt.tsx E2 copy discrepancy — commit-ready apply script
Prepared: tick-4230 (2026-06-29)

Background:
  Paper §5.3 + design note §6.1 specify E2 retains a generic privacy note:
    "Your vote is private and verifiable."
  But VoteReceipt.tsx (explanationVariant='unexplained') renders:
    "Your vote choice is not shown on this receipt."
  VoteReceipt.test.tsx APV-PIUP-02 asserts the current implementation.

  Methodological impact: if E2 shows an absent-choice STATEMENT (not just a
  generic privacy note), Q-AC in E2 conditions is partially answerable by
  verbatim reading. This changes what H2.1 tests: explanation vs. absent-choice
  acknowledgment without rationale (not vs. no absent-choice cue).

  Option (a) [RECOMMENDED — spec-faithful]:
    Fix VoteReceipt.tsx E2 → render "Your vote is private and verifiable."
    Update VoteReceipt.test.tsx APV-PIUP-02 assertions.
    Fix design note §6.1 line 159: "Your ballot was counted" → "Your vote was cast"
      (secondary sync — old text fixed in paper tick-4037 but never synced to design note).
    Remove [Note (tick-4125)] block from paper §5.3.

  Option (b) [implementation-as-spec]:
    Update paper §5.3 description to match current VoteReceipt.tsx implementation.
    Update design note §6.1 to match implementation (both items).
    Remove [Note (tick-4125)] block from paper §5.3.
    NOTE: Option (b) requires updating H2.1 rationale separately (not done by this script).

Usage:
    python3 scripts/apply-u.py            # Dry run (shows both options)
    python3 scripts/apply-u.py --apply    # Apply option (a) [RECOMMENDED]
    python3 scripts/apply-u.py --option b --apply   # Apply option (b)

Run from aztec-private-voting/ root.

After running option (a):
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git add docs/piup-study2-design-note-2026-06-22.md
    git add packages/react/src/components/VoteReceipt.tsx
    git add packages/react/src/components/VoteReceipt.test.tsx
    git commit -m "fix E2 copy: JONY-ACTION U resolved — option (a) applied (VoteReceipt.tsx spec-faithful)"

After running option (b):
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git add docs/piup-study2-design-note-2026-06-22.md
    git commit -m "fix E2 description: JONY-ACTION U resolved — option (b) applied (implementation-as-spec)"
"""

import sys
import os

PAPER        = "drafts/piup-chi-paper-draft-2026-06-22.md"
DESIGN_NOTE  = "docs/piup-study2-design-note-2026-06-22.md"
VOTE_RECEIPT = "packages/react/src/components/VoteReceipt.tsx"
VOTE_TEST    = "packages/react/src/components/VoteReceipt.test.tsx"

# Unique anchor for U note block in paper §5.3
U_ANCHOR = "[Note (tick-4125 \u2014 JONY-ACTION U): E2 copy discrepancy \u2014 VoteReceipt.tsx impleme"

U_RESOLUTION_A = (
    "[U RESOLVED \u2014 Option (a) applied tick-4230: VoteReceipt.tsx E2 "
    "('unexplained') updated to render 'Your vote is private and verifiable.' "
    "(spec-faithful). VoteReceipt.test.tsx APV-PIUP-02 assertions updated. "
    "Design note §6.1 synced: 'Your ballot was counted' → 'Your vote was cast'. "
    "H2.1 now tests explanation vs. no absent-choice cue (clean factorial contrast). "
    "Closes JONY-ACTION U.]"
)

U_RESOLUTION_B = (
    "[U RESOLVED \u2014 Option (b) applied tick-4230: Paper §5.3 and design note §6.1 "
    "updated to match VoteReceipt.tsx implementation: E2 shows "
    "'Your vote choice is not shown on this receipt.' (absent-choice statement, not "
    "generic privacy note). H2.1 tests explanation vs. absent-choice acknowledgment "
    "without rationale. Update H2.1 rationale separately before pre-registration. "
    "Design note §6.1 synced: 'Your ballot was counted' → 'Your vote was cast'. "
    "Closes JONY-ACTION U.]"
)

# --- VoteReceipt.tsx changes (option a) ---

TSX_OLD_JSDOC_SHORT = (
    "   * - 'unexplained' (E2) Minimal statement only: \"Your vote choice is not shown\n"
    "   *   on this receipt. This is intentional. No design-intent signal.\""
)
TSX_NEW_JSDOC_SHORT = (
    "   * - 'unexplained' (E2) Minimal privacy note: \"Your vote is private and\n"
    "   *   verifiable.\" No absent-choice signal; spec-faithful E2 copy (JONY-ACTION U)."
)

TSX_OLD_PROP_COMMENT = "  * - 'unexplained' (E2) Minimal statement: no design-intent signal."
TSX_NEW_PROP_COMMENT = "  * - 'unexplained' (E2) Minimal privacy note: no absent-choice signal."

TSX_OLD_RENDER = "        Your vote choice is not shown on this receipt."
TSX_NEW_RENDER = "        Your vote is private and verifiable."

# --- VoteReceipt.test.tsx changes (option a) ---
# All occurrences of the old E2 assertion text
TEST_OLD_TEXT = "your vote choice is not shown on this receipt"
TEST_NEW_TEXT = "your vote is private and verifiable"

# --- Design note §6.1 changes (both options) ---
# Fix 1 (both options): "Your ballot was counted" → "Your vote was cast" (sync from paper tick-4037)
DN_OLD_COUNTED = '"Your ballot was counted,"'
DN_NEW_COUNTED = '"Your vote was cast,"'

# Fix 2 (option b only): privacy note text → implementation text
DN_OLD_PRIVACY_NOTE = (
    'The privacy copy section is retained (to avoid a confound with privacy-awareness), '
    'but limited to: "Your vote is private and verifiable."'
)
DN_NEW_PRIVACY_NOTE_B = (
    'The receipt shows an absent-choice acknowledgment: '
    '"Your vote choice is not shown on this receipt." '
    'This is an absent-choice statement (not a generic privacy note); '
    'Q-AC in E2 conditions is partially answerable by verbatim reading of the receipt '
    '(per JONY-ACTION U option b resolution).'
)

# --- Paper §5.3 changes (option b only — description before U note) ---
PAPER_OLD_E2_DESC = (
    'A minimal privacy note ("Your vote is private and verifiable") is retained in E2 '
    'to avoid a privacy-awareness confound; only the absent-choice explanation is omitted '
    '(design note §6.1).'
)
PAPER_NEW_E2_DESC_B = (
    'An absent-choice acknowledgment ("Your vote choice is not shown on this receipt.") '
    'is shown in E2; only the design-rationale explanation is omitted (design note §6.1). '
    'Note: Q-AC in E2 conditions is partially answerable by verbatim reading; '
    'H2.1 tests explanation versus absent-choice acknowledgment without rationale '
    '(per JONY-ACTION U option b).'
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


def check(content_paper: str, content_dn: str, content_tsx: str, content_test: str,
          option: str) -> bool:
    """Dry-run validation."""
    ok = True

    # U1: U note block in paper must be present
    start, end = find_bracket_block(content_paper, U_ANCHOR)
    if start is None:
        print("ERROR U1: JONY-ACTION U note block anchor not found in paper — already removed?")
        ok = False
    else:
        block_len = (end - start) if end else 0
        print(f"[OK]  U1: JONY-ACTION U note block found in paper at char {start} (length {block_len})")

    # U2: resolution marker must NOT already be present
    resolution = U_RESOLUTION_A if option == 'a' else U_RESOLUTION_B
    if resolution in content_paper:
        print(f"WARNING U2: Resolution marker (option {option}) already present — may be applied.")
        ok = False
    else:
        print(f"[OK]  U2: Resolution marker (option {option}) not yet present (safe to apply)")

    # U3: design note §6.1 must have the old "Your ballot was counted" text (to fix)
    if DN_OLD_COUNTED not in content_dn:
        print("WARNING U3: Design note §6.1 'Your ballot was counted' not found — already fixed?")
    else:
        print("[OK]  U3: Design note §6.1 'Your ballot was counted' found (secondary sync fix)")

    if option == 'a':
        # U4a: VoteReceipt.tsx must render old E2 text
        if TSX_OLD_RENDER not in content_tsx:
            print("ERROR U4a: VoteReceipt.tsx E2 old render text not found — already changed?")
            ok = False
        else:
            print("[OK]  U4a: VoteReceipt.tsx E2 render text found (will fix to spec)")

        # U5a: test file must assert old E2 text
        if TEST_OLD_TEXT not in content_test:
            print("ERROR U5a: VoteReceipt.test.tsx E2 assertion text not found — already changed?")
            ok = False
        else:
            count = content_test.count(TEST_OLD_TEXT)
            print(f"[OK]  U5a: VoteReceipt.test.tsx E2 assertion text found ({count} occurrences to update)")

    else:  # option b
        # U4b: paper must have the old E2 description text
        if PAPER_OLD_E2_DESC not in content_paper:
            print("ERROR U4b: Paper §5.3 old E2 description text not found — already changed?")
            ok = False
        else:
            print("[OK]  U4b: Paper §5.3 old E2 description text found (will update to implementation)")

        # U5b: design note must have old privacy note text
        if DN_OLD_PRIVACY_NOTE not in content_dn:
            print("ERROR U5b: Design note §6.1 old privacy note text not found — already changed?")
            ok = False
        else:
            print("[OK]  U5b: Design note §6.1 old privacy note text found (will update)")

    return ok


def apply_option_a(paper: str, dn: str, tsx: str, test: str):
    """Option (a): fix VoteReceipt.tsx to match spec; update tests; sync design note; remove paper note."""

    # 1. Fix VoteReceipt.tsx JSDoc (short comment)
    if TSX_OLD_JSDOC_SHORT in tsx:
        tsx = tsx.replace(TSX_OLD_JSDOC_SHORT, TSX_NEW_JSDOC_SHORT, 1)
    # Fix prop JSDoc comment
    if TSX_OLD_PROP_COMMENT in tsx:
        tsx = tsx.replace(TSX_OLD_PROP_COMMENT, TSX_NEW_PROP_COMMENT, 1)
    # Fix render text
    tsx = tsx.replace(TSX_OLD_RENDER, TSX_NEW_RENDER, 1)

    # 2. Fix VoteReceipt.test.tsx: all occurrences of old E2 assertion text
    test = test.replace(TEST_OLD_TEXT, TEST_NEW_TEXT)

    # 3. Design note: fix "Your ballot was counted" → "Your vote was cast"
    dn = dn.replace(DN_OLD_COUNTED, DN_NEW_COUNTED, 1)

    # 4. Paper: remove U note block, insert resolution marker
    start, end = find_bracket_block(paper, U_ANCHOR)
    paper = paper[:start] + U_RESOLUTION_A + paper[end:]

    return paper, dn, tsx, test


def apply_option_b(paper: str, dn: str):
    """Option (b): update paper + design note to match implementation; remove paper note."""

    # 1. Design note: fix "Your ballot was counted" → "Your vote was cast"
    dn = dn.replace(DN_OLD_COUNTED, DN_NEW_COUNTED, 1)
    # Update privacy note → absent-choice statement
    dn = dn.replace(DN_OLD_PRIVACY_NOTE, DN_NEW_PRIVACY_NOTE_B, 1)

    # 2. Paper: update E2 description BEFORE removing note block
    paper = paper.replace(PAPER_OLD_E2_DESC, PAPER_NEW_E2_DESC_B, 1)

    # 3. Paper: remove U note block, insert resolution marker
    start, end = find_bracket_block(paper, U_ANCHOR)
    paper = paper[:start] + U_RESOLUTION_B + paper[end:]

    return paper, dn


def main():
    do_apply = "--apply" in sys.argv
    option = 'b' if '--option' in sys.argv and sys.argv[sys.argv.index('--option') + 1] == 'b' else 'a'

    for path in [PAPER, DESIGN_NOTE, VOTE_RECEIPT, VOTE_TEST]:
        if not os.path.exists(path):
            print(f"ERROR: File not found at {path}")
            print("Run from aztec-private-voting/ root.")
            sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        paper = f.read()
    with open(DESIGN_NOTE, "r", encoding="utf-8") as f:
        dn = f.read()
    with open(VOTE_RECEIPT, "r", encoding="utf-8") as f:
        tsx = f.read()
    with open(VOTE_TEST, "r", encoding="utf-8") as f:
        test = f.read()

    print(f"=== JONY-ACTION U apply script (E2 copy discrepancy) — option ({option}) ===")
    print(f"Paper:       {PAPER}")
    print(f"Design note: {DESIGN_NOTE}")
    print(f"VoteReceipt: {VOTE_RECEIPT}")
    print(f"Tests:       {VOTE_TEST}")
    print(f"Mode:        {'APPLY' if do_apply else 'DRY RUN'}")
    print()

    ok = check(paper, dn, tsx, test, option)
    if not ok:
        print()
        print("One or more checks failed. Fix issues before applying.")
        sys.exit(1)

    if not do_apply:
        print()
        print("All checks passed. Run with --apply to write changes.")
        print()
        if option == 'a':
            print("Option (a) [RECOMMENDED — spec-faithful] will:")
            print("  - Fix VoteReceipt.tsx E2: 'Your vote choice is not shown...' → 'Your vote is private and verifiable.'")
            print("  - Update VoteReceipt.test.tsx APV-PIUP-02 assertions (all occurrences)")
            print("  - Sync design note §6.1: 'Your ballot was counted' → 'Your vote was cast'")
            print("  - Remove [Note (tick-4125)] block from paper §5.3 (2,253 chars)")
            print()
            print("  Run 'npm test' in packages/react/ after applying to confirm tests pass.")
        else:
            print("Option (b) [implementation-as-spec] will:")
            print("  - Update design note §6.1: privacy note → absent-choice statement; fix counted→cast")
            print("  - Update paper §5.3 E2 description to match VoteReceipt.tsx implementation")
            print("  - Remove [Note (tick-4125)] block from paper §5.3 (2,253 chars)")
            print()
            print("  NOTE: H2.1 rationale should be updated separately before Study 2 pre-registration.")
        sys.exit(0)

    if option == 'a':
        new_paper, new_dn, new_tsx, new_test = apply_option_a(paper, dn, tsx, test)
    else:
        new_paper, new_dn = apply_option_b(paper, dn)
        new_tsx, new_test = tsx, test  # unchanged for option b

    # Post-apply verification
    errors = []
    if U_ANCHOR in new_paper:
        errors.append("U note block still present in paper after replacement")
    resolution = U_RESOLUTION_A if option == 'a' else U_RESOLUTION_B
    if resolution not in new_paper:
        errors.append("Resolution marker not found in paper after apply")
    if option == 'a':
        if TSX_OLD_RENDER in new_tsx:
            errors.append("VoteReceipt.tsx old E2 render text still present")
        if TSX_NEW_RENDER not in new_tsx:
            errors.append("VoteReceipt.tsx new E2 render text not found")
        if TEST_OLD_TEXT in new_test:
            errors.append("VoteReceipt.test.tsx old assertion text still present")

    if errors:
        print("ERROR: Post-apply verification failed:")
        for e in errors:
            print(f"  {e}")
        print("Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_paper)
    with open(DESIGN_NOTE, "w", encoding="utf-8") as f:
        f.write(new_dn)
    if option == 'a':
        with open(VOTE_RECEIPT, "w", encoding="utf-8") as f:
            f.write(new_tsx)
        with open(VOTE_TEST, "w", encoding="utf-8") as f:
            f.write(new_test)

    print()
    print(f"[DONE] JONY-ACTION U option ({option}) applied successfully.")
    print()
    if option == 'a':
        print("Changes made:")
        print("  - VoteReceipt.tsx: E2 render changed to 'Your vote is private and verifiable.'")
        print("  - VoteReceipt.test.tsx: all APV-PIUP-02 assertions updated")
        print("  - Design note §6.1: 'Your ballot was counted' → 'Your vote was cast'")
        print("  - Paper §5.3: [Note (tick-4125)] block removed (2,253 chars), resolution marker inserted")
        print()
        print("IMPORTANT: Run 'npm test' in packages/react/ to confirm tests pass.")
        print()
        print("Next steps:")
        print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
        print("  git add docs/piup-study2-design-note-2026-06-22.md")
        print("  git add packages/react/src/components/VoteReceipt.tsx")
        print("  git add packages/react/src/components/VoteReceipt.test.tsx")
        print('  git commit -m "fix E2 copy: JONY-ACTION U resolved — option (a) applied (VoteReceipt.tsx spec-faithful)"')
    else:
        print("Changes made:")
        print("  - Design note §6.1: privacy note → absent-choice statement; 'counted' → 'cast'")
        print("  - Paper §5.3: E2 description updated to match implementation")
        print("  - Paper §5.3: [Note (tick-4125)] block removed (2,253 chars), resolution marker inserted")
        print()
        print("  Update H2.1 rationale before Study 2 pre-registration.")
        print()
        print("Next steps:")
        print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
        print("  git add docs/piup-study2-design-note-2026-06-22.md")
        print('  git commit -m "fix E2 description: JONY-ACTION U resolved — option (b) applied (implementation-as-spec)"')
    print()
    print("Closes JONY-ACTION U. Open JAs: 24 \u2192 23.")


if __name__ == "__main__":
    main()
