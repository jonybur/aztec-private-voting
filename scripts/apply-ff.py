#!/usr/bin/env python3
"""
apply-ff.py — JONY-ACTION FF apply script
calibration_confidence scope and construct conflict (Study 2 guide vs. instrument §11)

Conflict:
  Guide: Q-AC-conf item for ALL conditions (N=240),
         text = "How confident are you in your answer above?"
         → post-receipt Q-AC confidence

  Instrument §11: M4 restricted to I2 conditions only (N=120),
         text = "Before you saw the receipt, we asked you two quick questions.
                  Looking back at your answers: how confident were you that
                  they were correct at the time?"
         → retrospective CAL-probe confidence

These are different constructs. One version needs to win before OSF pre-registration.

Options:
  (a) Guide version wins — all conditions, Q-AC confidence.
      Guide: remove FF flag.
      Instrument §11: update branch logic, question text, and note to match guide.
      ⚠️  Requires instrument amendment before OSF registration if instrument
          was pre-registered as I2-only retrospective.

  (b) Instrument version wins — I2-only, retrospective CAL-probe confidence.
      Guide: restrict Q-AC-conf to I2 only, update question text.
      Instrument §11: no change (already correct).
      ⚠️  Requires amendment if guide version was already implemented in Qualtrics.

Usage:
  python3 scripts/apply-ff.py                      # dry-run, option a
  python3 scripts/apply-ff.py --option b            # dry-run, option b
  python3 scripts/apply-ff.py --apply               # apply option a
  python3 scripts/apply-ff.py --option b --apply    # apply option b
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

# ─── Text anchors ──────────────────────────────────────────────────────────────

# The FF flag block in the guide (exact text)
FF_FLAG = (
    "> ⚠️ **JONY-ACTION FF (structural conflict): This guide places "
    "`calibration_confidence` as Q-AC-conf for ALL conditions "
    "(\"How confident are you in your answer above?\"). However, instrument "
    "§11 (M4) restricts calibration_confidence to I2 only and asks a "
    "DIFFERENT question: \"Before you saw the receipt, we asked you two "
    "quick questions. Looking back at your answers: how confident were you "
    "that they were correct at the time?\" (retrospective confidence in CAL "
    "probe answers). These measure different constructs: (a) guide = "
    "post-receipt Q-AC confidence, all conditions; (b) instrument = "
    "retrospective CAL-probe confidence, I2 only. Which version is "
    "pre-registered? Jony must confirm: option (a) guide version (all "
    "conditions, Q-AC confidence) or option (b) instrument version (I2 only, "
    "CAL-probe retrospective confidence). Guide left unchanged pending "
    "confirmation.** Design note §9.3 / H2.3: `calibration_confidence` is "
    "the primary M4 variable. The residual analysis is computed in R."
)

# Option (a): replace FF flag with just the design note
FF_FLAG_REPLACE_A = (
    "> Design note §9.3 / H2.3: `calibration_confidence` is the primary M4 "
    "variable (all conditions, N=240 — post-receipt Q-AC confidence). "
    "The residual analysis is computed in R."
)

# Instrument §11 anchors (for option a — update to all-conditions)
INST_HEADING_OLD = "## §11 Calibration Confidence (M4 — I2 conditions only)"
INST_HEADING_NEW = "## §11 Calibration Confidence (M4 — all conditions)"

INST_BRANCH_OLD = "*Branch logic: Show this question only when `intervention = I2`.*"
INST_BRANCH_NEW = "*Branch logic: Show this question for all conditions (no branch restriction).*"

INST_QTEXT_OLD = (
    "*\"Before you saw the receipt, we asked you two quick questions. "
    "Looking back at your answers: how confident were you that they were "
    "correct at the time?\"*"
)
INST_QTEXT_NEW = "*\"How confident are you in your answer above?\"*"

INST_NOTE_OLD = (
    "*Note: This item measures retrospective confidence in calibration probe "
    "answers, not post-receipt confidence. It is placed after the Comprehension "
    "and Trust blocks (§8–§9) so that seeing the receipt's actual content can "
    "inform the retrospective judgment."
)
INST_NOTE_NEW = (
    "*Note: This item measures post-receipt confidence in the Q-AC answer "
    "(M1). It is placed immediately after Q-AC on the same page."
)

INST_DICT_OLD = (
    "| `calibration_confidence` | `COL_CALIB_CONF` | 1–7 | "
    "Confidence in calibration probe answers (I2 only; NA for I1) |"
)
INST_DICT_NEW = (
    "| `calibration_confidence` | `COL_CALIB_CONF` | 1–7 | "
    "Post-receipt Q-AC confidence (all conditions; N=240) |"
)

# Option (b): update guide Q-AC-conf to I2-only + change question text
GUIDE_QACCONF_OLD = (
    "**Q-AC-conf (same page):**\n"
    "- Question type: single-row **Matrix Table** or 7-point **Multiple Choice**.\n"
    "- Text: `How confident are you in your answer above?`\n"
    "- Scale: 1 (*Not at all confident*) to 7 (*Completely confident*).\n"
    "- Variable name: `calibration_confidence`"
)
GUIDE_QACCONF_NEW_B = (
    "**Q-AC-conf (I2 conditions only — do not show for I1):**\n"
    "- Question type: single-row **Matrix Table** or 7-point **Multiple Choice**.\n"
    "- Display logic: show only when `intervention = I2` (Qualtrics branch logic).\n"
    "- Text: `Before you saw the receipt, we asked you two quick questions. "
    "Looking back at your answers: how confident were you that they were correct at the time?`\n"
    "- Scale: 1 (*Not at all confident*) to 7 (*Completely confident*).\n"
    "- Variable name: `calibration_confidence` (NA for I1 participants)"
)

# Option (b): design note replacing FF flag (instrument version)
FF_FLAG_REPLACE_B = (
    "> Design note §9.3 / H2.3: `calibration_confidence` is the primary M4 "
    "variable (I2 conditions only, N=120 — retrospective CAL-probe confidence). "
    "The residual analysis is computed in R."
)

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
print("JONY-ACTION FF — apply-ff.py")
print(f"Option: ({OPTION})")
print(f"Mode: {'DRY-RUN' if DRY_RUN else 'APPLY'}")
print("=" * 60)

guide_text = GUIDE.read_text(encoding="utf-8")
instrument_text = INSTRUMENT.read_text(encoding="utf-8")

if OPTION == "a":
    print()
    print("Option (a): guide version wins — all conditions, Q-AC confidence.")
    print("  Guide: remove FF flag, keep current Q-AC-conf section.")
    print("  Instrument §11: update to all-conditions, Q-AC question text.")
    print()

    # FF-A1: flag present in guide
    check("FF-A1: JONY-ACTION FF flag found in guide", FF_FLAG in guide_text,
          "Flag block not found — may already be applied or text changed.")

    # FF-A2: instrument heading present
    check("FF-A2: instrument §11 heading found (I2 conditions only)",
          INST_HEADING_OLD in instrument_text,
          f"Heading not found: '{INST_HEADING_OLD}'")

    # FF-A3: instrument branch logic present
    check("FF-A3: instrument §11 branch logic found",
          INST_BRANCH_OLD in instrument_text,
          f"Branch logic not found: '{INST_BRANCH_OLD}'")

    # FF-A4: instrument question text present
    check("FF-A4: instrument §11 retrospective question text found",
          INST_QTEXT_OLD in instrument_text,
          f"Q-text not found: '{INST_QTEXT_OLD[:60]}...'")

    # FF-A5: instrument note present
    check("FF-A5: instrument §11 note present",
          INST_NOTE_OLD in instrument_text,
          f"Note anchor not found: '{INST_NOTE_OLD[:60]}...'")

    # FF-A6: data dictionary row present
    check("FF-A6: instrument data-dictionary row found",
          INST_DICT_OLD in instrument_text,
          f"Dict row not found: '{INST_DICT_OLD[:60]}...'")

    print()
    if errors > 0:
        print(f"ABORT — {errors} check(s) failed. No changes written.")
        sys.exit(1)

    if DRY_RUN:
        print("Dry-run complete — all 6 checks passed.")
        print()
        print("Change preview:")
        print("  Guide: FF flag replaced with design note (all-conditions, Q-AC).")
        print("  Instrument §11: heading, branch logic, question text, note, dict row updated.")
        print()
        print("⚠️  If instrument was pre-registered as I2-only retrospective,")
        print("   file an instrument amendment on OSF before registration.")
        print()
        print("To apply:")
        print("  python3 scripts/apply-ff.py --apply")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md docs/piup-study2-survey-instrument-2026-06-28.md")
        print("  git commit -m 'fix Study 2 calibration_confidence: JONY-ACTION FF resolved (a) — all-conditions Q-AC'")
    else:
        new_guide = guide_text.replace(FF_FLAG, FF_FLAG_REPLACE_A, 1)
        GUIDE.write_text(new_guide, encoding="utf-8")

        new_instrument = instrument_text
        new_instrument = new_instrument.replace(INST_HEADING_OLD, INST_HEADING_NEW, 1)
        new_instrument = new_instrument.replace(INST_BRANCH_OLD, INST_BRANCH_NEW, 1)
        new_instrument = new_instrument.replace(INST_QTEXT_OLD, INST_QTEXT_NEW, 1)
        # Replace only the opening sentence of the note (the rest stays)
        new_instrument = new_instrument.replace(INST_NOTE_OLD, INST_NOTE_NEW, 1)
        new_instrument = new_instrument.replace(INST_DICT_OLD, INST_DICT_NEW, 1)
        INSTRUMENT.write_text(new_instrument, encoding="utf-8")

        print("Applied — guide and instrument updated to all-conditions Q-AC.")
        print()
        print("⚠️  If instrument was pre-registered as I2-only, file an OSF amendment.")
        print()
        print("Next:")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md docs/piup-study2-survey-instrument-2026-06-28.md")
        print("  git commit -m 'fix Study 2 calibration_confidence: JONY-ACTION FF resolved (a) — all-conditions Q-AC'")
        print()
        print("Closes JONY-ACTION FF. Open JAs: 24 → 23.")

elif OPTION == "b":
    print()
    print("Option (b): instrument version wins — I2-only, retrospective CAL-probe confidence.")
    print("  Guide: restrict Q-AC-conf to I2 only, update question text, remove FF flag.")
    print("  Instrument §11: no change (already correct).")
    print()

    # FF-B1: flag present in guide
    check("FF-B1: JONY-ACTION FF flag found in guide", FF_FLAG in guide_text,
          "Flag block not found — may already be applied or text changed.")

    # FF-B2: guide Q-AC-conf section present with current all-conditions text
    check("FF-B2: guide Q-AC-conf section found (all-conditions version)",
          GUIDE_QACCONF_OLD in guide_text,
          f"Guide Q-AC-conf block not found — may have changed.")

    # FF-B3: instrument §11 heading already correct
    check("FF-B3: instrument §11 already has I2-only heading (no change needed)",
          INST_HEADING_OLD in instrument_text,
          f"Instrument heading not found: '{INST_HEADING_OLD}'")

    # FF-B4: instrument question text already correct
    check("FF-B4: instrument §11 retrospective question text already present",
          INST_QTEXT_OLD in instrument_text,
          f"Instrument Q-text not found (unexpected).")

    print()
    if errors > 0:
        print(f"ABORT — {errors} check(s) failed. No changes written.")
        sys.exit(1)

    if DRY_RUN:
        print("Dry-run complete — all 4 checks passed.")
        print()
        print("Change preview (guide only):")
        print("  Q-AC-conf section: restricted to I2, question text changed to retrospective.")
        print("  FF flag: replaced with design note (I2-only, retrospective).")
        print("  Instrument §11: no change.")
        print()
        print("⚠️  If guide version was already implemented in Qualtrics (all-conditions),")
        print("   a protocol deviation note and Qualtrics correction will be needed.")
        print()
        print("To apply:")
        print("  python3 scripts/apply-ff.py --option b --apply")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md")
        print("  git commit -m 'fix Study 2 calibration_confidence: JONY-ACTION FF resolved (b) — I2-only retrospective'")
    else:
        new_guide = guide_text.replace(GUIDE_QACCONF_OLD, GUIDE_QACCONF_NEW_B, 1)
        new_guide = new_guide.replace(FF_FLAG, FF_FLAG_REPLACE_B, 1)
        GUIDE.write_text(new_guide, encoding="utf-8")

        print("Applied — guide updated to I2-only retrospective calibration confidence.")
        print()
        print("⚠️  Instrument §11 unchanged (already correct for option b).")
        print()
        print("Next:")
        print("  git add docs/qualtrics-setup-guide-study2-2026-06-28.md")
        print("  git commit -m 'fix Study 2 calibration_confidence: JONY-ACTION FF resolved (b) — I2-only retrospective'")
        print()
        print("Closes JONY-ACTION FF. Open JAs: 24 → 23.")

else:
    print(f"Unknown option '{OPTION}'. Use --option a or --option b.")
    sys.exit(1)
