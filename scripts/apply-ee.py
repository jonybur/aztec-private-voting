#!/usr/bin/env python3
"""
apply-ee.py — JONY-ACTION EE apply script
TC2 wording in Study 2 Qualtrics guide vs. instrument §9

Conflict: The guide currently has instrument wording "I understand what this
receipt is for." (comprehension), but previously had "I believe the voting
system that produced this receipt is secure." (security belief). The flag
was left pending Jony's confirmation.

Options:
  (a) RECOMMENDED — keep instrument wording (comprehension). Remove flag from
      guide. Instrument §9 already correct — no change there.
  (b) Revert to guide's original security-belief wording in BOTH files:
      guide + instrument §9. Requires an instrument amendment before OSF
      registration.

Usage:
  python3 scripts/apply-ee.py                      # dry-run, option a
  python3 scripts/apply-ee.py --option b            # dry-run, option b
  python3 scripts/apply-ee.py --apply               # apply option a
  python3 scripts/apply-ee.py --option b --apply    # apply option b
"""

import sys
import pathlib

GUIDE = pathlib.Path("docs/qualtrics-setup-guide-study2-2026-06-28.md")
INSTRUMENT = pathlib.Path("docs/piup-study2-survey-instrument-2026-06-28.md")

OPTION = "a"
if "--option" in sys.argv:
    idx = sys.argv.index("--option")
    OPTION = sys.argv[idx + 1].lower().strip("()")

DRY_RUN = "--apply" not in sys.argv

# ─── Text anchors ─────────────────────────────────────────────────────────────

# Option (a): remove the JONY-ACTION EE flag from the guide
GUIDE_FLAG_OLD = (
    '"I understand what this receipt is for." '
    '⚠️ **JONY-ACTION EE: guide previously had "I believe the voting system '
    'that produced this receipt is secure" — a different construct (security '
    'belief vs. comprehension). Instrument §9 specifies TC2 = "I understand '
    'what this receipt is for." Applied instrument wording but flagged for '
    'Jony confirmation.**'
)
GUIDE_FLAG_NEW_A = '"I understand what this receipt is for."'

# Option (b): revert to security-belief wording in guide
GUIDE_FLAG_NEW_B = '"I believe the voting system that produced this receipt is secure."'

# Instrument §9 anchors for option (b)
INSTRUMENT_OLD_HEADING = "### TC2 — Comprehension (Trust Competence 2)"
INSTRUMENT_NEW_HEADING = "### TC2 — Security belief (Trust Competence 2)"
INSTRUMENT_OLD_ITEM = '*"I understand what this receipt is for."*'
INSTRUMENT_NEW_ITEM = '*"I believe the voting system that produced this receipt is secure."*'
INSTRUMENT_OLD_DESC = "| `trust_competence_2` | `COL_TC2` | 1–7 | Understands what receipt is for |"
INSTRUMENT_NEW_DESC = "| `trust_competence_2` | `COL_TC2` | 1–7 | Security belief about the voting system |"

# ─── Check helpers ─────────────────────────────────────────────────────────────

errors = 0


def check(label, condition, detail=""):
    global errors
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        errors += 1
        if detail:
            print(f"         → {detail}")


# ─── Main ──────────────────────────────────────────────────────────────────────

print("=" * 60)
print("JONY-ACTION EE — apply-ee.py")
print(f"Option: ({OPTION})")
print(f"Mode: {'DRY-RUN' if DRY_RUN else 'APPLY'}")
print("=" * 60)

guide_text = GUIDE.read_text(encoding="utf-8")
instrument_text = INSTRUMENT.read_text(encoding="utf-8")

if OPTION == "a":
    print()
    print("Option (a): keep instrument wording — remove JONY-ACTION EE flag from guide.")
    print()

    # EE-A1: flag present in guide
    check(
        "EE-A1: JONY-ACTION EE flag found in guide",
        GUIDE_FLAG_OLD in guide_text,
        "Flag block not found — may already be applied or text has changed.",
    )

    # EE-A2: idempotency — resolved wording not already clean
    already_clean = (GUIDE_FLAG_NEW_A in guide_text and "JONY-ACTION EE" not in guide_text)
    check(
        "EE-A2: flag not already removed (idempotency guard)",
        not already_clean,
        "Already applied — re-running would be a no-op.",
    )

    # EE-A3: instrument already correct — no change needed there
    check(
        "EE-A3: instrument §9 already has comprehension wording (no instrument change needed)",
        INSTRUMENT_OLD_ITEM in instrument_text,
        "Instrument §9 TC2 item text not found.",
    )

    print()
    if errors > 0:
        print(f"ABORT — {errors} check(s) failed. No changes written.")
        sys.exit(1)

    if DRY_RUN:
        print("Dry-run complete — all 3 checks passed.")
        print()
        print("Change preview (guide only):")
        print(f"  BEFORE: '...{GUIDE_FLAG_OLD[:80]}...'")
        print(f"  AFTER:  '{GUIDE_FLAG_NEW_A}'")
        print()
        print("Instrument: no change required.")
        print()
        print("To apply:")
        print("  python3 scripts/apply-ee.py --apply")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md")
        print("  git commit -m 'fix Study 2 guide: JONY-ACTION EE resolved (a) — TC2 instrument wording confirmed'")
    else:
        new_guide = guide_text.replace(GUIDE_FLAG_OLD, GUIDE_FLAG_NEW_A, 1)
        GUIDE.write_text(new_guide, encoding="utf-8")
        print("Applied — JONY-ACTION EE flag removed from guide.")
        print()
        print("Verify with:")
        print("  grep -n 'trust_competence_2' docs/qualtrics-setup-guide-study2-2026-06-28.md")
        print()
        print("Next:")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md")
        print("  git commit -m 'fix Study 2 guide: JONY-ACTION EE resolved (a) — TC2 instrument wording confirmed'")
        print()
        print("Closes JONY-ACTION EE. Open JAs: 24 → 23.")

elif OPTION == "b":
    print()
    print("Option (b): revert to security-belief wording — update BOTH guide AND instrument §9.")
    print()

    # EE-B1: flag present in guide
    check(
        "EE-B1: JONY-ACTION EE flag found in guide",
        GUIDE_FLAG_OLD in guide_text,
        "Flag block not found — may already be applied or text has changed.",
    )

    # EE-B2: instrument heading present
    check(
        "EE-B2: instrument TC2 heading found",
        INSTRUMENT_OLD_HEADING in instrument_text,
        "Heading '### TC2 — Comprehension (Trust Competence 2)' not found in instrument.",
    )

    # EE-B3: instrument item text present
    check(
        "EE-B3: instrument TC2 item text found",
        INSTRUMENT_OLD_ITEM in instrument_text,
        f"Item text not found: {INSTRUMENT_OLD_ITEM}",
    )

    # EE-B4: instrument table row present
    check(
        "EE-B4: instrument data-dictionary row found",
        INSTRUMENT_OLD_DESC in instrument_text,
        f"Table row not found: {INSTRUMENT_OLD_DESC}",
    )

    print()
    if errors > 0:
        print(f"ABORT — {errors} check(s) failed. No changes written.")
        sys.exit(1)

    if DRY_RUN:
        print("Dry-run complete — all 4 checks passed.")
        print()
        print("Change preview:")
        print("  Guide TC2 row: security-belief wording restored; flag removed.")
        print("  Instrument §9: heading, item text, and data-dictionary row updated.")
        print()
        print("⚠️  This option requires an instrument amendment before OSF registration.")
        print()
        print("To apply:")
        print("  python3 scripts/apply-ee.py --option b --apply")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md docs/piup-study2-survey-instrument-2026-06-28.md")
        print("  git commit -m 'revert Study 2 TC2: JONY-ACTION EE resolved (b) — security-belief wording restored'")
    else:
        new_guide = guide_text.replace(GUIDE_FLAG_OLD, GUIDE_FLAG_NEW_B, 1)
        GUIDE.write_text(new_guide, encoding="utf-8")

        new_instrument = instrument_text
        new_instrument = new_instrument.replace(INSTRUMENT_OLD_HEADING, INSTRUMENT_NEW_HEADING, 1)
        new_instrument = new_instrument.replace(INSTRUMENT_OLD_ITEM, INSTRUMENT_NEW_ITEM, 1)
        new_instrument = new_instrument.replace(INSTRUMENT_OLD_DESC, INSTRUMENT_NEW_DESC, 1)
        INSTRUMENT.write_text(new_instrument, encoding="utf-8")

        print("Applied — guide and instrument updated to security-belief wording.")
        print()
        print("⚠️  File an instrument amendment on OSF before registration.")
        print()
        print("Next:")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md docs/piup-study2-survey-instrument-2026-06-28.md")
        print("  git commit -m 'revert Study 2 TC2: JONY-ACTION EE resolved (b) — security-belief wording restored'")
        print()
        print("Closes JONY-ACTION EE. Open JAs: 24 → 23.")

else:
    print(f"Unknown option '{OPTION}'. Use --option a or --option b.")
    sys.exit(1)
