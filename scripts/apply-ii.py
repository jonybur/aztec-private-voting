#!/usr/bin/env python3
"""
apply-ii.py — JONY-ACTION II apply script

Inserts §6.5 Study 2 Ecological Validity paragraph.

Insertion point: after "Study 2 demand characteristics" paragraph,
before "Statistical power" paragraph.

Options:
  (a) Full paragraph with H2.3 underpowering cross-reference [RECOMMENDED]
  (b) Paragraph without H2.3 sentence (shorter)

Usage:
  python3 scripts/apply-ii.py            # dry-run (both options previewed)
  python3 scripts/apply-ii.py --apply    # apply option (a)
  python3 scripts/apply-ii.py --apply-b  # apply option (b)
"""

import sys
import os

DRAFT = "drafts/piup-chi-paper-draft-2026-06-22.md"

# ─── Anchors ───────────────────────────────────────────────────────────────────

# End of Study 2 demand characteristics paragraph (insertion after this)
ANCHOR = "The mitigations do not provide full protection against demand-characteristic effects."

# Start of Statistical power paragraph (insertion before this)
STAT_ANCHOR = "**Statistical power.**"

# ─── Proposed text — option (a): full paragraph with H2.3 cross-ref ───────────

STUDY2_EV_A = """\n\n**Study 2 ecological validity.** Study 2 uses the actual `VoteReceipt.tsx` component (§3.4) hosted in study mode and presents an interactive voting flow, improving substantially on Study 1's static-screenshot method — participants cast an active choice before receiving the receipt, providing a choice-commitment context absent from Study 1. Three ecological validity bounds remain. First, the vote is consequentially inert: participants select a DAO governance option in a context they know to be a study, so their choice carries no real decision-making weight. The choice-commitment effect — having a personal stake in the decided outcome — is a plausible driver of post-vote receipt attention and absent-content salience in real deployment; its absence may mean Study 2 underestimates the personal urgency with which real voters interrogate their receipt's absent content. Second, the Prolific sample introduces the same validity bound as Study 1: participants are US-based English-speaking online workers whose familiarity with digital privacy UI may not represent the full population of likely deployment users. Third, both studies measure receipt comprehension immediately after voting; real voters may revisit their saved receipt days or weeks after the vote closes, when the verification event approaches. The delayed-verification interaction pattern — returning to a stored receipt, re-engaging the verification affordance — is not tested in either study. This gap is most relevant to Study 2's save-behavior endpoint (H2.4; observed download-button click as proxy for save intention): the behavioral measure captures immediate post-vote save behavior, not the downstream verification act the save is intended to enable. The internal validity of the L × E × I factorial design and the confirmatory contrasts (H2.1–H2.4; §5.5) is not affected by these bounds; they primarily constrain the generalizability of the effect-size estimates to real-world deployment contexts. H2.3 (calibration intervention: no-harm TOST on save intention) is the only underpowered endpoint (power ≈ 0.72 at d = 0.50, L2 n = 60; §5.5); if the TOST is inconclusive, a targeted Study 2b (N = 80, L2 only) is planned.\n"""

# ─── Option (b): without H2.3 sentence ────────────────────────────────────────

STUDY2_EV_B = """\n\n**Study 2 ecological validity.** Study 2 uses the actual `VoteReceipt.tsx` component (§3.4) hosted in study mode and presents an interactive voting flow, improving substantially on Study 1's static-screenshot method — participants cast an active choice before receiving the receipt, providing a choice-commitment context absent from Study 1. Three ecological validity bounds remain. First, the vote is consequentially inert: participants select a DAO governance option in a context they know to be a study, so their choice carries no real decision-making weight. The choice-commitment effect — having a personal stake in the decided outcome — is a plausible driver of post-vote receipt attention and absent-content salience in real deployment; its absence may mean Study 2 underestimates the personal urgency with which real voters interrogate their receipt's absent content. Second, the Prolific sample introduces the same validity bound as Study 1: participants are US-based English-speaking online workers whose familiarity with digital privacy UI may not represent the full population of likely deployment users. Third, both studies measure receipt comprehension immediately after voting; real voters may revisit their saved receipt days or weeks after the vote closes, when the verification event approaches. The delayed-verification interaction pattern — returning to a stored receipt, re-engaging the verification affordance — is not tested in either study. This gap is most relevant to Study 2's save-behavior endpoint (H2.4; observed download-button click as proxy for save intention): the behavioral measure captures immediate post-vote save behavior, not the downstream verification act the save is intended to enable. The internal validity of the L × E × I factorial design and the confirmatory contrasts (H2.1–H2.4; §5.5) is not affected by these bounds; they primarily constrain the generalizability of the effect-size estimates to real-world deployment contexts.\n"""

print("JONY-ACTION II — apply-ii.py")
print("=" * 60)

# ─── Load draft ────────────────────────────────────────────────────────────────

if not os.path.exists(DRAFT):
    print(f"ERROR: {DRAFT} not found — run from repo root")
    sys.exit(1)

content = open(DRAFT, "r").read()

# ─── Validation ───────────────────────────────────────────────────────────────

errors = []

anchor_pos = content.find(ANCHOR)
if anchor_pos == -1:
    errors.append("ANCHOR not found: demand-characteristics closing sentence")
else:
    print(f"  CHECK 1: Demand-characteristics anchor found at char {anchor_pos} — PASS")

stat_pos = content.find(STAT_ANCHOR)
if stat_pos == -1:
    errors.append("STAT_ANCHOR not found: '**Statistical power.**'")
else:
    print(f"  CHECK 2: Statistical power anchor found at char {stat_pos} — PASS")

if anchor_pos != -1 and stat_pos != -1:
    gap = stat_pos - (anchor_pos + len(ANCHOR))
    if gap != 2:
        errors.append(f"Gap between anchors is {gap} chars (expected 2: '\\n\\n')")
    else:
        print(f"  CHECK 3: Gap between anchors is 2 chars ('\\n\\n') — PASS")

    # Verify no Study 2 EV paragraph already present
    if "**Study 2 ecological validity.**" in content:
        errors.append("Study 2 ecological validity paragraph ALREADY present — do not re-apply")
    else:
        print(f"  CHECK 4: Study 2 EV paragraph not yet present — PASS")

if errors:
    print("\nERRORS:")
    for e in errors:
        print(f"  ❌ {e}")
    sys.exit(1)

print("\nAll checks passed.\n")

# ─── Show diff ────────────────────────────────────────────────────────────────

print("Insertion point: after demand-characteristics paragraph, before Statistical power.")
print(f"  Char {anchor_pos + len(ANCHOR)} → insert Study 2 EV paragraph\n")

apply = "--apply" in sys.argv
apply_b = "--apply-b" in sys.argv

if not apply and not apply_b:
    print("DRY-RUN — pass --apply for option (a) or --apply-b for option (b)\n")
    print("Option (a) replacement text (first 200 chars):")
    print("  " + STUDY2_EV_A[:200].replace("\n", "\\n") + "...")
    print()
    print("Option (b) replacement text (first 200 chars):")
    print("  " + STUDY2_EV_B[:200].replace("\n", "\\n") + "...")
    sys.exit(0)

# ─── Apply ────────────────────────────────────────────────────────────────────

chosen = STUDY2_EV_A if apply else STUDY2_EV_B
option_name = "(a)" if apply else "(b)"

insert_pos = anchor_pos + len(ANCHOR)
new_content = content[:insert_pos] + chosen + content[insert_pos + 2:]  # replace \n\n gap with \n\n<para>\n + \n

open(DRAFT, "w").write(new_content)

print(f"Applied option {option_name}: Study 2 EV paragraph inserted.")
print()
print("Next steps:")
print(f"  git add {DRAFT}")
if apply:
    print("  git commit -m 'add §6.5 Study 2 EV paragraph: JONY-ACTION II resolved — option (a)'")
else:
    print("  git commit -m 'add §6.5 Study 2 EV paragraph: JONY-ACTION II resolved — option (b)'")
print()
print("Closes JONY-ACTION II. Open JAs: 24 → 23.")
