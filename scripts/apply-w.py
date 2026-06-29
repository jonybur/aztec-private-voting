#!/usr/bin/env python3
"""
JONY-ACTION W — CAL-FEEDBACK Q2 label-conditioned feedback — commit-ready apply script
Prepared: tick-4229 (2026-06-29)

Issue:
  Design note §6.2 originally used label-neutral 'it proves...'; the instrument §5
  master source uses condition-specific '[vote fingerprint / confirmation code] proves...'
  I2 participants therefore see the condition label twice before viewing the receipt:
    (1) in the CAL2 question stem  ('What is the main purpose of the [LABEL] on the receipt?')
    (2) in the CAL-FEEDBACK Q2 explanation  ('the [LABEL] proves your ballot was included...')
  For L2 (confirmation code), this feedback directly contradicts the eCommerce schema H4
  predicts — potentially amplifying calibration in L2 vs. L1.

Option (a) [RECOMMENDED — only option in this script]:
  Accept the instrument wording as intentional. Label-conditioned feedback is more precise.
  The H2.3 pre-specified L2-only restriction (design note §9.1) absorbs any L1 vs. L2
  calibration differential. Add a design-feature note to the §5.5 H2.3 analysis.
  Design note §6.2 was already updated tick-4126 to match the instrument master source.

Option (b) [NOT in this script]:
  Make feedback label-neutral in instrument §5. Requires instrument and design-note edits.
  If Jony prefers option (b), do NOT run this script — notify agent to prepare apply-w-b.py.

Usage:
    python3 scripts/apply-w.py              # dry-run (no changes)
    python3 scripts/apply-w.py --apply      # apply option (a)

Run from aztec-private-voting/ root.

After running --apply:
  git add drafts/piup-chi-paper-draft-2026-06-22.md
  git commit -m "fix §5.3+§5.5: JONY-ACTION W resolved — option (a) applied (label-conditioned feedback accepted)"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# ─────────────────────────────────────────────────────────────────────────────
# CHANGE W1 — Remove JONY-ACTION W note block from §5.3 Factor I description
# ─────────────────────────────────────────────────────────────────────────────

W1_BLOCK_OPEN = "[Note (tick-4126 \u2014 JONY-ACTION W): CAL-FEEDBACK Q2 is label-conditioned"
W1_CLOSE_ANCHOR = "Jony must confirm option (a) or (b) before Study 2 instrument lock.]"
W1_SUFFIX = "\n\n**Power (preliminary estimate).**"

W1_RESOLUTION_MARKER = (
    "[Fixed tick-4229 \u2014 JONY-ACTION W RESOLVED option (a): "
    "CAL-FEEDBACK Q2 label-conditioned feedback accepted as intentional. "
    "Instrument §5 master source uses '[vote fingerprint / confirmation code] proves "
    "your ballot was included in the tally, not what you voted.' "
    "The H2.3 pre-specified L2-only restriction (design note §9.1) absorbs any L1 vs. L2 "
    "calibration differential. Design-feature note added to §5.5 H2.3 analysis "
    "(see tick-4229 note). Design note §6.2 updated tick-4126 to match instrument. "
    "Closes JONY-ACTION W (tick-4126).]"
)

# ─────────────────────────────────────────────────────────────────────────────
# CHANGE W2 — Insert design-feature note in §5.5 H2.3 analysis
# ─────────────────────────────────────────────────────────────────────────────

W2_INSERTION_ANCHOR = "[Note (tick-4130 \u2014 \u00a710.3 power): H2.3 is the only underpowered endpoint."

W2_DESIGN_FEATURE_NOTE = (
    "[Note (tick-4229 \u2014 JONY-ACTION W design feature / §5.5 H2.3): "
    "The I2 calibration feedback (CAL-FEEDBACK Q2) is label-conditioned in the instrument "
    "master source (survey instrument §5). The Q2 feedback sentence reads: "
    "'The correct answer is **To let you verify later that your ballot was counted** \u2014 "
    "the [vote fingerprint / confirmation code] proves your ballot was included in the tally, "
    "not what you voted.' This means I2 participants see the condition label name twice "
    "before viewing the receipt: once in the CAL2 question stem ('What is the main purpose "
    "of the [LABEL] on the receipt?') and once in CAL-FEEDBACK Q2. "
    "DESIGN FEATURE (accepted, JONY-ACTION W option (a)): "
    "For H2.3 (pre-specified conditional secondary, L2 cells only; design note §9.1): "
    "the L2-specific feedback ('the confirmation code proves your ballot was included in "
    "the tally, not what you voted') directly contradicts the eCommerce schema that H4 "
    "predicts, potentially amplifying the calibration effect in L2 relative to L1. "
    "This differential is absorbed by the pre-specified L2-only restriction of H2.3 "
    "(design note §9.1) and does not threaten the validity of the conditional secondary test. "
    "For exploratory analysis of all 8 L \u00d7 E \u00d7 I cells: the label-conditioned "
    "feedback in I2 rows is a design feature that may produce a larger Q-AC accuracy gain "
    "in L2-I2 vs. L1-I2 cells; descriptive comparisons across all 8 cells should note "
    "this as a design feature (not a confound). No confirmatory analysis is affected: "
    "H2.3 is L2-conditional, H2.1 and H2.2 pool I and L respectively.] "
)


# ─────────────────────────────────────────────────────────────────────────────
# DRY-RUN CHECKS
# ─────────────────────────────────────────────────────────────────────────────

def dry_run(content: str) -> bool:
    all_ok = True

    # W1 — JONY-ACTION W block present
    pos_open = content.find(W1_BLOCK_OPEN)
    if pos_open == -1:
        print("ERROR [W1a]: JONY-ACTION W block opening not found.")
        print(f"  Looking for: {repr(W1_BLOCK_OPEN[:80])}...")
        all_ok = False
    else:
        print(f"[OK] W1a: JONY-ACTION W block found at char {pos_open}")

    pos_close = content.find(W1_CLOSE_ANCHOR) if pos_open != -1 else -1
    if pos_open != -1 and pos_close == -1:
        print("ERROR [W1b]: JONY-ACTION W block closing anchor not found.")
        print(f"  Looking for: {repr(W1_CLOSE_ANCHOR[:80])}")
        all_ok = False
    elif pos_open != -1:
        block_len = pos_close + len(W1_CLOSE_ANCHOR) - pos_open
        print(f"[OK] W1b: JONY-ACTION W block closing anchor found at char {pos_close} (block length: {block_len} chars)")

    # W2 — CAL-FEEDBACK-specific resolution marker not yet present (safe to apply)
    # Note: a prior JONY-ACTION W (tick-3985, §2.1 Invariant 2) is already resolved;
    # check only for the tick-4229-specific resolution text.
    if "Fixed tick-4229 \u2014 JONY-ACTION W RESOLVED option (a)" in content:
        print("ERROR [W2]: tick-4229 resolution marker already present — may already be applied.")
        all_ok = False
    else:
        print("[OK] W2: tick-4229 resolution marker not yet present — safe to apply")

    # W3 — §5.5 H2.3 insertion anchor present
    pos_insert = content.find(W2_INSERTION_ANCHOR)
    if pos_insert == -1:
        print("ERROR [W3]: §5.5 H2.3 insertion anchor (tick-4130 power note) not found.")
        print(f"  Looking for: {repr(W2_INSERTION_ANCHOR[:80])}")
        all_ok = False
    else:
        print(f"[OK] W3: §5.5 H2.3 insertion anchor found at char {pos_insert}")

    # W4 — Design-feature note not yet present (idempotency guard)
    if "JONY-ACTION W design feature" in content:
        print("ERROR [W4]: Design-feature note already present — may already be applied.")
        all_ok = False
    else:
        print("[OK] W4: Design-feature note not yet present — safe to insert")

    print()
    if all_ok:
        print("[OK] All 4 checks passed. Ready to apply option (a).")
    else:
        print("FAIL: One or more checks failed. Do not apply.")

    return all_ok


# ─────────────────────────────────────────────────────────────────────────────
# APPLY
# ─────────────────────────────────────────────────────────────────────────────

def apply_option_a(content: str) -> str:
    """
    Change W1: Replace the JONY-ACTION W note block in §5.3 with a resolution marker.
    Change W2: Insert design-feature note before the tick-4130 power note in §5.5.
    """
    # --- W1: Find the full block to replace ---
    pos_open = content.find(W1_BLOCK_OPEN)
    pos_close = content.find(W1_CLOSE_ANCHOR, pos_open)
    block_end = pos_close + len(W1_CLOSE_ANCHOR)

    # Replacement: resolution marker (no trailing suffix — suffix is preserved separately)
    content = content[:pos_open] + W1_RESOLUTION_MARKER + content[block_end:]

    # --- W2: Insert design-feature note before tick-4130 power note ---
    # Re-find insertion anchor after W1 edit (W1 change is before it; offset unchanged but safer to re-search)
    pos_insert = content.find(W2_INSERTION_ANCHOR)
    if pos_insert == -1:
        raise RuntimeError("Insertion anchor not found after W1 edit — aborting.")

    content = content[:pos_insert] + W2_DESIGN_FEATURE_NOTE + content[pos_insert:]

    return content


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

def main():
    apply_mode = "--apply" in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTION W apply script (§5.3 W-block removal + §5.5 H2.3 design-feature note) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode: {'APPLY' if apply_mode else 'DRY RUN'}")
    print()

    ok = dry_run(content)
    if not ok:
        sys.exit(1)

    if not apply_mode:
        print("Dry run complete. No changes written.")
        print("Re-run with --apply to apply option (a).")
        sys.exit(0)

    # Apply changes
    new_content = apply_option_a(content)

    # Post-apply verification
    if W1_BLOCK_OPEN in new_content:
        print("ERROR: JONY-ACTION W note block still present after apply. Aborting write.")
        sys.exit(1)
    if "JONY-ACTION W RESOLVED" not in new_content:
        print("ERROR: Resolution marker not found after apply. Aborting write.")
        sys.exit(1)
    if "JONY-ACTION W design feature" not in new_content:
        print("ERROR: Design-feature note not found after apply. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] JONY-ACTION W option (a) applied successfully.")
    print()
    print("Changes made:")
    print("  1. §5.3 Factor I: JONY-ACTION W note block (1,942 chars) → resolution marker")
    print("  2. §5.5 H2.3: Design-feature note inserted before tick-4130 power note")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix §5.3+§5.5: JONY-ACTION W resolved — option (a) applied (label-conditioned feedback accepted)"')
    print()
    print("Closes JONY-ACTION W. Open JAs: 24 \u2192 23.")
    print("On approval 'W: option (a)': run python3 scripts/apply-w.py --apply, then git commit.")


if __name__ == "__main__":
    main()
