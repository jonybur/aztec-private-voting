#!/usr/bin/env python3
"""
apply-hh.py — JONY-ACTION HH apply script (option a)
§6.5 L2 receipt-freeness paragraph + Juels et al. (2005) bibliography entry

CHI risk: MODERATE (missing L2 disclosure; Juels et al. 2005 fully verified tick-4212)
All cross-references pre-verified (proposal tick-4198, pages+DOI tick-4212).

Three checks in dry-run mode (default). Use --apply to commit.

Jony's options recap:
  (a) Apply paragraph + bib entry  ← this script
  (b) Apply paragraph without Juels citation
  (c) Reject — keep §3.3 L2 note only

Usage:
  python3 scripts/apply-hh.py           # dry-run
  python3 scripts/apply-hh.py --apply   # apply changes
"""

import sys
import pathlib

PAPER = pathlib.Path("drafts/piup-chi-paper-draft-2026-06-22.md")

# --------------------------------------------------------------------------
# Paragraph to insert (after Protocol-layer exposure, before Study 1 eco)
# --------------------------------------------------------------------------
# Anchor: the unique closing bracket of the Protocol-layer exposure paragraph.
# This anchor appears exactly once in the paper (verified grep -c → 1).
PARA_ANCHOR = "revise if M3 is implemented before submission.]"

# Text to insert: a blank line + the new paragraph, then a blank line.
# The paper uses blank lines between paragraphs in §6.5 (confirmed from doc).
NEW_PARA = """

**Partial receipt-freeness.** Receipt-freeness requires that a voter be unable to prove to a third party how they voted, even voluntarily (Juels et al. 2005). The current Aztec Private Voting instantiation does not achieve full receipt-freeness: a voter who shares their fingerprint identifier with a coercer provides a direct handle for that coercer to reconstruct the voter's choice from the on-chain `record_vote` calldata (§3.3, L1 privacy gap), because the `receipt_id → vote_choice` map is publicly constructible from calldata alone. Full receipt-freeness requires a protocol mechanism that severs the link between a voter's identifier and their recorded choice — such as a re-encryption mix — which the contract does not implement (§3.3, L2). PIUP addresses the coercion surface at the receipt-content layer (Invariant 3: the receipt withholds the vote choice) and at the UX layer (protective framing explicitly names the absent content), but these do not prevent a voter from voluntarily producing verifiable coercion evidence by sharing their fingerprint. The term "coercion-resistant" is withheld from user-facing copy in `VoteReceipt.tsx` until a re-encryption mix is implemented, consistent with the §3.3 L2 commitment. This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference — whether participants correctly understand what the receipt shows and withholds — rather than receipt-freeness or threat-model comprehension; no question asks whether a voter can construct coercion evidence using their identifier. [Added tick-4221 — JONY-ACTION HH RESOLVED: §6.5 L2 disclosure added. Juels et al. (2005) pp. 61-70 + DOI verified tick-4212. Cross-references to §3.3 L1/L2, Invariant 3, VoteReceipt.tsx, and Study 1/Study 2 scope all confirmed clean (proposal tick-4198).]"""

# --------------------------------------------------------------------------
# Bibliography entry to insert (alphabetically before Kulyk et al. 2015)
# --------------------------------------------------------------------------
# Anchor: the unique start of the Kulyk bibliography line.
BIB_ANCHOR = "- Kulyk, O., Teague, V., and Volkamer, M. (2015)."

NEW_BIB = """- Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic elections." In _Proceedings of the 4th ACM Workshop on Privacy in the Electronic Society (WPES '05)_, pp. 61-70. ACM. DOI: 10.1145/1102199.1102213. [DBLP: conf/wpes/JuelsCJ05; authors, title, venue, pages, DOI all VERIFIED tick-4198 + tick-4212.]
"""

DRY_RUN = "--apply" not in sys.argv

errors = 0


def check(label, condition, detail=""):
    global errors
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        errors += 1
        if detail:
            print(f"         → {detail}")


print("=" * 65)
print("JONY-ACTION HH — apply-hh.py (option a)")
print(f"Mode: {'DRY-RUN' if DRY_RUN else 'APPLY'}")
print("=" * 65)

text = PAPER.read_text(encoding="utf-8")

# HH1: paragraph anchor present exactly once (idempotency + uniqueness)
count_anchor = text.count(PARA_ANCHOR)
check(
    "HH1: Protocol-layer exposure closing anchor found exactly once",
    count_anchor == 1,
    f"Expected 1 occurrence; found {count_anchor}."
)

# HH2: bibliography anchor present exactly once
count_bib = text.count(BIB_ANCHOR)
check(
    "HH2: Kulyk bibliography anchor found exactly once",
    count_bib == 1,
    f"Expected 1 occurrence; found {count_bib}."
)

# HH3: idempotency guards — new content not already present
already_para = "Partial receipt-freeness." in text
already_bib  = "Juels, A., Catalano, D., and Jakobsson, M. (2005)" in text
check(
    "HH3: new paragraph not already present (idempotency guard)",
    not already_para,
    "Paragraph already applied — re-running would duplicate it."
)
check(
    "HH4: Juels bib entry not already present (idempotency guard)",
    not already_bib,
    "Bibliography entry already applied — re-running would duplicate it."
)

print()
if errors > 0:
    print(f"ABORT — {errors} check(s) failed. No changes written.")
    sys.exit(1)

if DRY_RUN:
    print("Dry-run complete — all 4 checks passed.")
    print()
    print("Change 1 — Insert §6.5 L2 receipt-freeness paragraph:")
    print("  AFTER  : '..." + PARA_ANCHOR[-60:] + "'")
    print("  INSERT : **Partial receipt-freeness.** Receipt-freeness requires...")
    print()
    print("Change 2 — Insert Juels et al. (2005) bibliography entry:")
    print("  BEFORE : '" + BIB_ANCHOR[:60] + "...'")
    print("  INSERT : - Juels, A., Catalano, D., and Jakobsson, M. (2005)...")
    print()
    print("To apply:")
    print("  python3 scripts/apply-hh.py --apply")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §6.5: JONY-ACTION HH — add L2 receipt-freeness paragraph + Juels et al. (2005)'")
else:
    # Apply change 1: insert paragraph after PARA_ANCHOR
    new_text = text.replace(PARA_ANCHOR, PARA_ANCHOR + NEW_PARA, 1)

    # Apply change 2: insert bib entry before BIB_ANCHOR
    new_text = new_text.replace(BIB_ANCHOR, NEW_BIB + BIB_ANCHOR, 1)

    PAPER.write_text(new_text, encoding="utf-8")

    print("Applied. Changes written to:")
    print(f"  {PAPER}")
    print()
    print("Verification — paragraph inserted (search for 'Partial receipt-freeness'):")
    lines = new_text.splitlines()
    for i, line in enumerate(lines, 1):
        if "Partial receipt-freeness." in line:
            start = max(0, i - 2)
            end = min(len(lines), i + 3)
            for j in range(start, end):
                marker = "→" if j + 1 == i else " "
                print(f"  {marker} L{j+1}: {lines[j][:110]}")
            break
    print()
    print("Verification — bib entry inserted (search for 'Juels, A., Catalano'):")
    for i, line in enumerate(lines, 1):
        if "Juels, A., Catalano, D., and Jakobsson, M. (2005)" in line:
            start = max(0, i - 1)
            end = min(len(lines), i + 2)
            for j in range(start, end):
                marker = "→" if j + 1 == i else " "
                print(f"  {marker} L{j+1}: {lines[j][:110]}")
            break
    print()
    print("Next:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §6.5: JONY-ACTION HH — add L2 receipt-freeness paragraph + Juels et al. (2005)'")
    print()
    print("Closes JONY-ACTION HH.")
    print("Open citations needing Jony decisions: DD, BB (apply-dd.py, apply-bb.py ready).")
