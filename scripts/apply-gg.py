#!/usr/bin/env python3
"""
apply-gg.py — JONY-ACTION GG apply script
tick-4225 | SC3 vs DM4 structural conflict + DM3 wording fix
Target: docs/qualtrics-setup-guide-study2-2026-06-28.md

JONY-ACTION GG has two parts:
  Part 1 (structural): Guide adds SC3 screener not in instrument. Instrument uses
    DM4 post-hoc. These are incompatible. Option (a) removes SC3; option (b) keeps
    SC3 as an OSF protocol amendment.

  Part 2 (wording): Guide DM3 has two deviations from instrument §14 DM4:
    (a) Time window: "past 12 months" vs instrument "past 6 months"
    (b) Question text: "voting interfaces" vs instrument "voting receipts,
        voting confirmations, or post-vote screens"
    (c) Follow-up screener note only valid if SC3 exists.

Usage:
  python3 scripts/apply-gg.py             # dry-run, option (a)
  python3 scripts/apply-gg.py --option b  # dry-run, option (b)
  python3 scripts/apply-gg.py --apply             # apply option (a)
  python3 scripts/apply-gg.py --option b --apply  # apply option (b)
"""
import sys
import re

TARGET = "docs/qualtrics-setup-guide-study2-2026-06-28.md"
TICK = "tick-4225"

# ── Anchors ──────────────────────────────────────────────────────────────────

SC3_OLD = (
    "### SC3 — Prior receipt study exclusion\n"
    "\n"
    "- Question type: **Multiple Choice** (single select)\n"
    "- Text: `Have you participated in any online research study involving voting interfaces, voting receipts, or confirmation codes in the past 6 months?`\n"
    "- Choices: `Yes` | `No` | `Not sure`\n"
    "- Skip Logic on `Yes` → End of Survey (cross-study contamination exclusion — §11.4 of design note).\n"
    "\n"
    "> ⚠️ **JONY-ACTION GG (structural conflict): This guide adds SC3 to screen out prior-study participants before data collection (no data collected for them). The pre-registered instrument has no SC3 — it uses DM4 (demographics) to capture this group and excludes them post-hoc in R, with the Prolific \"Previous Studies\" filter as primary defence. These are incompatible: option (a) remove SC3 and use the instrument DM4 post-hoc approach (no amendment needed); option (b) keep SC3 and log it as a protocol amendment before OSF registration. Guide left unchanged pending Jony confirmation. Note: GG also affects DM3 wording — see below.**\n"
)

DM3_OLD = (
    "### DM3 — Prior receipt study\n"
    "- Variable name: `prior_receipt_study`\n"
    "- Text: `Have you participated in any online study involving voting interfaces in the past 12 months? (This is a follow-up to the screener question — please answer again.)`\n"
    "- Choices: `Yes` | `No` | `Not sure`\n"
    "\n"
    "> ⚠️ **JONY-ACTION GG (continued — wording conflicts in this question): (a) Time window: guide says \"past 12 months\" vs instrument §14 DM4 says \"past 6 months\". (b) Question text: guide says \"voting interfaces\" vs instrument says \"voting receipts, voting confirmations, or post-vote screens\". (c) The \"(follow-up to screener question)\" note is only valid if SC3 exists — if SC3 is removed per option (a) above, this note must also be removed and the phrasing revised. Confirm with GG resolution above.**\n"
    "\n"
    "> **Why ask again:** The screener version (SC3) captures exclusion; this demographics version feeds `prior_receipt_study` into the analysis script's exclusion logic (§2 of analysis script).\n"
)

SCREEN_OUT_OLD = "Apply to all SC1/SC2/SC3 skip-to-end-of-survey paths."
PREFLIGHT_OLD  = "- [ ] Test screen-out paths (fail SC1, SC2, SC3) — verify Prolific screen-out URL reached."

# ── Replacements (option a) ───────────────────────────────────────────────────

SC3_NEW_A = (
    "[Fixed {tick} — JONY-ACTION GG resolved, option (a): SC3 removed. The "
    "pre-registered instrument has no SC3; it captures prior-study participation "
    "via DM3 (`prior_receipt_study`) post-hoc in R. The Prolific \"Previous "
    "Studies\" filter (set to exclude Study 1 ID) and the Prolific custom screener "
    "are the primary defence. No in-survey screener question is needed. "
    "No OSF amendment required.]\n"
).format(tick=TICK)

DM3_NEW_A = (
    "### DM3 — Prior receipt study\n"
    "- Variable name: `prior_receipt_study`\n"
    "- Text: `Have you participated in a previous study about voting receipts, voting confirmations, or post-vote screens in the past 6 months?`\n"
    "- Choices: `Yes` | `No` | `I'm not sure`\n"
    "\n"
    "[Fixed {tick} — JONY-ACTION GG resolved, option (a): question text corrected "
    "to match instrument §14 DM4 ('voting receipts, voting confirmations, or "
    "post-vote screens', not 'voting interfaces'); time window corrected from "
    "'past 12 months' to 'past 6 months'; follow-up-to-screener note removed "
    "(SC3 no longer exists). This question feeds `prior_receipt_study` into the "
    "analysis script exclusion logic (§2 of analysis script); Prolific 'Previous "
    "Studies' filter is the primary defence.]\n"
).format(tick=TICK)

SCREEN_OUT_NEW_A = "Apply to all SC1/SC2 skip-to-end-of-survey paths."
PREFLIGHT_NEW_A  = "- [ ] Test screen-out paths (fail SC1, SC2) — verify Prolific screen-out URL reached."

# ── Replacements (option b) ───────────────────────────────────────────────────

SC3_NEW_B = (
    "### SC3 — Prior receipt study exclusion\n"
    "\n"
    "- Question type: **Multiple Choice** (single select)\n"
    "- Text: `Have you participated in any online research study involving voting interfaces, voting receipts, or confirmation codes in the past 6 months?`\n"
    "- Choices: `Yes` | `No` | `Not sure`\n"
    "- Skip Logic on `Yes` → End of Survey (cross-study contamination exclusion — §11.4 of design note).\n"
    "\n"
    "[Fixed {tick} — JONY-ACTION GG resolved, option (b): SC3 retained. This "
    "adds a screener not in the pre-registered instrument; log as a protocol "
    "amendment before OSF registration. The Prolific 'Previous Studies' filter "
    "and SC3 together provide pre-data-collection exclusion. DM3 wording corrected "
    "separately (see DM3 note below).]\n"
).format(tick=TICK)

DM3_NEW_B = (
    "### DM3 — Prior receipt study\n"
    "- Variable name: `prior_receipt_study`\n"
    "- Text: `Have you participated in any online research study involving voting receipts, voting confirmations, or post-vote screens in the past 6 months? (This is a follow-up to the screener question — please answer again.)`\n"
    "- Choices: `Yes` | `No` | `Not sure`\n"
    "\n"
    "[Fixed {tick} — JONY-ACTION GG resolved, option (b): question text corrected "
    "to match instrument §14 DM4 ('voting receipts, voting confirmations, or "
    "post-vote screens', not 'voting interfaces'); time window corrected from "
    "'past 12 months' to 'past 6 months'. Follow-up screener note retained (SC3 "
    "kept under option b). DM3 feeds `prior_receipt_study` into the analysis "
    "script exclusion logic (§2 of analysis script).]\n"
    "\n"
    "> **Why ask again:** The screener version (SC3) captures exclusion; this "
    "demographics version feeds `prior_receipt_study` into the analysis script's "
    "exclusion logic (§2 of analysis script).\n"
).format(tick=TICK)

# option (b): no changes to SC1/SC2/SC3 references (SC3 still exists)


def run(option: str, apply: bool) -> None:
    text = open(TARGET, encoding="utf-8").read()

    if option == "a":
        checks = [
            ("GG1 SC3 block",       SC3_OLD,          SC3_NEW_A),
            ("GG2 DM3 block",       DM3_OLD,          DM3_NEW_A),
            ("GG3 screen-out ref",  SCREEN_OUT_OLD,   SCREEN_OUT_NEW_A),
            ("GG4 preflight item",  PREFLIGHT_OLD,    PREFLIGHT_NEW_A),
        ]
    else:  # option b
        checks = [
            ("GG1 SC3 block",       SC3_OLD,          SC3_NEW_B),
            ("GG2 DM3 block",       DM3_OLD,          DM3_NEW_B),
        ]

    errors = 0
    results = []
    for label, old, new in checks:
        pos = text.find(old)
        if pos == -1:
            print(f"  ❌ {label}: NOT FOUND")
            errors += 1
        else:
            print(f"  ✅ {label}: found at char {pos}")
            results.append((old, new))

    if errors:
        print(f"\n{errors} check(s) failed — aborting.")
        sys.exit(1)

    print(f"\nAll {len(checks)} checks passed.")

    if not apply:
        print("\nDry-run complete. Pass --apply to write changes.")
        return

    # Apply
    out = text
    for old, new in results:
        assert old in out, f"Anchor disappeared mid-apply: {old[:60]!r}"
        out = out.replace(old, new, 1)

    open(TARGET, "w", encoding="utf-8").write(out)
    print(f"\nApplied option ({option}) to {TARGET}.")


if __name__ == "__main__":
    option = "a"
    apply  = False
    args = sys.argv[1:]
    if "--option" in args:
        idx = args.index("--option")
        option = args[idx + 1].lower()
        if option not in ("a", "b"):
            print(f"Unknown option '{option}'. Use 'a' or 'b'.")
            sys.exit(1)
    if "--apply" in args:
        apply = True

    mode = "APPLY" if apply else "DRY-RUN"
    print(f"\n=== apply-gg.py — option ({option}) — {mode} ===\n")
    run(option, apply)
