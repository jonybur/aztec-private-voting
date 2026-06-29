#!/usr/bin/env python3
"""
JONY-ACTION T — OSF Amendments 12+13+14 — commit-ready apply script
Prepared: tick-4230 (2026-06-29)

Background:
  JONY-ACTION T covers three OSF amendments that Jony must file before pilot launch:

  Amendment 12 (tick-4124, item 1): Q5 wording deviations from pre-reg §5.2.
    The instrument §6/Q5 has 4 deviations: (a) 'In your own words:' prefix;
    (b) 'the system' → 'this voting system'; (c) lowercase 'not' → emphasized 'NOT';
    (d) 'your vote choice' → 'which option you voted for'. Rubric unchanged.

  Amendment 13 (tick-4124, item 2): MQ1 rubric clarification.
    Pre-reg §5.3 abbreviated rubric is ambiguous for non-leakage-only responses.
    Instrument §11 two-dimensional additive rubric is the operative operationalization.
    Amendment 8 log entry 'scoring construct unchanged' is corrected to note the
    two-dimensional rubric.

  Amendment 14 (tick-4150): Attention check descriptions correction.
    Pre-reg §3 describes AC1 as 'select strongly agree' (WRONG — actual answer is
    'Strongly Disagree') and AC2 as 'Which of the following is a fruit?' (WRONG —
    actual question asks for 'the third item from the list' where correct answer is
    Carrot, a vegetable). Both-fail exclusion criterion is correctly implemented;
    only the pre-reg description is inaccurate.

  This script removes three pre-submission note blocks from the paper after Jony
  files Amendments 12+13+14 on OSF.

  PREREQUISITE: File OSF Amendments 12, 13, and 14 before running --apply.
  Amendment 12+13 language is in docs/jony-batch-decision-memo-2026-06-28.md §T.

Usage:
    python3 scripts/apply-t.py            # Dry run (no changes written)
    python3 scripts/apply-t.py --apply    # Apply and write file

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §4.2/§4.4/§4.5: JONY-ACTION T resolved — Amendments 12+13+14 filed, note blocks removed"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# Unique anchors for the three T note blocks
T_AMEND14_ANCHOR = "[Note (tick-4150 \u2014 JONY-ACTION T Amendment 14): Pre-registra"
T_ITEM1_ANCHOR   = "[Note (tick-4124 \u2014 JONY-ACTION T, item 1): Q5 wording deviat"
T_ITEM2_ANCHOR   = "[Note (tick-4124 \u2014 JONY-ACTION T, item 2): MQ1 rubric clarif"

# Resolution markers
T_AMEND14_RESOLUTION = (
    "[T-AMEND14 RESOLVED \u2014 tick-4230: OSF Amendment 14 filed. "
    "Pre-reg §3 attention check descriptions corrected (AC1 → 'Strongly Disagree'; "
    "AC2 → third-item-from-list, correct answer Carrot). "
    "Both-fail exclusion criterion unaffected. Closes Amendment 14 component of JONY-ACTION T.]"
)
T_ITEM1_RESOLUTION = (
    "[T-AMEND12 RESOLVED \u2014 tick-4230: OSF Amendment 12 filed. "
    "Q5 wording deviations documented: (a) 'In your own words:' prefix; "
    "(b) 'this voting system'; (c) emphasized 'NOT'; (d) 'which option you voted for'. "
    "Rubric unchanged. Closes Amendment 12 component of JONY-ACTION T.]"
)
T_ITEM2_RESOLUTION = (
    "[T-AMEND13 RESOLVED \u2014 tick-4230: OSF Amendment 13 filed. "
    "MQ1 two-dimensional additive rubric documented as operative operationalization. "
    "Amendment 8 'unchanged construct' claim corrected. "
    "MQ1 is exploratory; no confirmatory analysis affected. "
    "Closes Amendment 13 component of JONY-ACTION T. Full JONY-ACTION T now closed.]"
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

    for label, anchor, resolution in [
        ("T1a (Amendment 14)", T_AMEND14_ANCHOR, T_AMEND14_RESOLUTION),
        ("T1b (Amendment 12)", T_ITEM1_ANCHOR,   T_ITEM1_RESOLUTION),
        ("T1c (Amendment 13)", T_ITEM2_ANCHOR,   T_ITEM2_RESOLUTION),
    ]:
        start, end = find_bracket_block(content, anchor)
        if start is None:
            print(f"ERROR {label}: Note block anchor not found — already removed?")
            ok = False
        else:
            block_len = end - start if end else 0
            print(f"[OK]  {label}: Note block found at char {start} (length {block_len} chars)")

        if resolution in content:
            print(f"WARNING {label}: Resolution marker already present — may already be applied.")
            ok = False
        else:
            print(f"[OK]  {label}: Resolution marker not yet present (safe to apply)")

    return ok


def apply_script(content: str) -> str:
    """Remove the three JONY-ACTION T note blocks (in reverse order to preserve offsets)."""
    # Collect all blocks first, then replace in reverse order of position
    blocks = []
    for anchor, resolution in [
        (T_AMEND14_ANCHOR, T_AMEND14_RESOLUTION),
        (T_ITEM1_ANCHOR,   T_ITEM1_RESOLUTION),
        (T_ITEM2_ANCHOR,   T_ITEM2_RESOLUTION),
    ]:
        start, end = find_bracket_block(content, anchor)
        if start is None or end is None:
            raise ValueError(f"Could not locate T block for anchor: {anchor[:60]}")
        blocks.append((start, end, resolution))

    # Sort by start position descending (apply last-first to preserve earlier offsets)
    blocks.sort(key=lambda x: x[0], reverse=True)
    for start, end, resolution in blocks:
        content = content[:start] + resolution + content[end:]

    return content


def main():
    do_apply = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION T apply script (OSF Amendments 12+13+14 note blocks) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode:  {'APPLY' if do_apply else 'DRY RUN'}")
    print()
    print("PREREQUISITE: File OSF Amendments 12, 13, and 14 before running --apply.")
    print("  Amendment language: docs/jony-batch-decision-memo-2026-06-28.md §T")
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
        print("  - Remove [Note (tick-4150 — JONY-ACTION T Amendment 14): ...] from §4.2 (1,284 chars)")
        print("  - Remove [Note (tick-4124 — JONY-ACTION T, item 1): ...] from §4.4 (954 chars)")
        print("  - Remove [Note (tick-4124 — JONY-ACTION T, item 2): ...] from §4.5 (1,865 chars)")
        print("  - Insert resolution markers for Amendments 12+13+14")
        sys.exit(0)

    new_content = apply_script(content)

    # Post-apply verification
    errors = []
    for anchor in [T_AMEND14_ANCHOR, T_ITEM1_ANCHOR, T_ITEM2_ANCHOR]:
        if anchor in new_content:
            errors.append(f"Block still present: {anchor[:60]}")
    for resolution in [T_AMEND14_RESOLUTION, T_ITEM1_RESOLUTION, T_ITEM2_RESOLUTION]:
        if resolution not in new_content:
            errors.append(f"Resolution marker missing: {resolution[:60]}")

    if errors:
        print("ERROR: Post-apply verification failed:")
        for e in errors:
            print(f"  {e}")
        print("Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] JONY-ACTION T applied successfully.")
    print()
    print("Changes made:")
    print("  - Removed Amendment 14 note block from §4.2 (1,284 chars)")
    print("  - Removed Amendment 12 note block from §4.4 (954 chars)")
    print("  - Removed Amendment 13 note block from §4.5 (1,865 chars)")
    print("  - Inserted [T-AMEND12/13/14 RESOLVED ...] markers")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §4.2/§4.4/§4.5: JONY-ACTION T resolved — Amendments 12+13+14 filed, note blocks removed"')
    print()
    print("Closes JONY-ACTION T. Open JAs: 24 \u2192 23.")


if __name__ == "__main__":
    main()
