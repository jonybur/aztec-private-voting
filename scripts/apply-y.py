#!/usr/bin/env python3
"""
apply-y.py — JONY-ACTION Y apply script (option b)
§1.1 opening paragraph: replace KelpDAO (multiple factual errors) with
Mango Markets October 2022 — the DAO governance vote example that
actually matches the paper's claim.

Errors in current text:
  (1) YEAR WRONG: KelpDAO exploit was April 2026, not 2023
  (2) AMOUNT WRONG: $71M is the Arbitrum-frozen amount; total exploit ~$292M
  (3) GOVERNANCE STRUCTURE WRONG: it was an Arbitrum DAO vote (ARB holders),
      not a KelpDAO vote on loss socialisation

Mango Markets October 2022 is accurate:
  - October 11-12 2022: Avraham Eisenberg manipulated the MNGO/USDC
    perpetual price oracle on Mango Markets, draining ~$116M in protocol assets
  - October 14-15 2022: MIP-4 governance proposal put to Mango DAO vote on
    Realms (Solana): return ~$67M to treasury, keep ~$47M as "bug bounty"
  - All voter wallet addresses publicly visible on-chain (Realms/Solana)
  - Eisenberg voted with ~488M MNGO (accumulated during the oracle manipulation)
  - This IS a DAO governance vote on loss socialisation with public voter addresses

Two checks in dry-run mode (default). Use --apply to commit.

Jony's options recap:
  (a) Update KelpDAO to accurate April 2026 description
  (b) Replace with Mango Markets October 2022  ← this script
  (c) Generalise and remove specific example

Usage:
  python3 scripts/apply-y.py           # dry-run
  python3 scripts/apply-y.py --apply   # apply changes
"""

import sys
import pathlib

PAPER = pathlib.Path("drafts/piup-chi-paper-draft-2026-06-22.md")

# --------------------------------------------------------------------------
# Anchors — used to find and replace the block (sentence + JONY-ACTION Y note)
# without needing to embed the full 900-character note text.
# --------------------------------------------------------------------------
OLD_SENTENCE_START = (
    "When KelpDAO put the loss-socialisation decision from a $71M protocol exploit "
    "to a governance vote in 2023, every voter's wallet address was public on-chain."
)
OLD_NOTE_END = (
    "current text would be flagged by a CHI reviewer with DeFi knowledge as inaccurate.]"
)

NEW_BLOCK = (
    "When Mango Markets put the loss-socialisation decision from a $116M protocol exploit "
    "to a governance vote in October 2022, every voter's wallet address was public on-chain. "
    "[Added tick-4222 \u2014 JONY-ACTION Y RESOLVED: option (b) applied. "
    "KelpDAO (April 2026 exploit) had three factual errors and has been replaced with "
    "Mango Markets October 2022. Facts: on October 11\u201312, 2022, Avraham Eisenberg "
    "manipulated the MNGO/USDC perpetual oracle on Mango Markets and drained ~$116M in "
    "protocol assets. He then submitted MIP-4, a Mango DAO governance proposal to return "
    "~$67M to the treasury and keep ~$47M; the vote ran on Realms (Solana) with all voter "
    "wallet addresses publicly visible on-chain. This directly matches the paper\u2019s "
    "claim: a DAO governance vote on loss-socialisation, with public on-chain voter "
    "identities. Source: independent verification against multiple public records "
    "(Solana FM, Realms, contemporaneous reporting).]"
)

DRY_RUN = "--apply" not in sys.argv

errors = 0


def check(label, condition, detail=""):
    global errors
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        errors += 1
        if detail:
            print(f"         \u2192 {detail}")


print("=" * 65)
print("JONY-ACTION Y \u2014 apply-y.py (option b: Mango Markets replacement)")
print(f"Mode: {'DRY-RUN' if DRY_RUN else 'APPLY'}")
print("=" * 65)

text = PAPER.read_text(encoding="utf-8")

# Y1: old opening sentence present exactly once
count_sentence = text.count(OLD_SENTENCE_START)
check(
    "Y1: old KelpDAO sentence found exactly once",
    count_sentence == 1,
    f"Expected 1 occurrence; found {count_sentence}."
)

# Y2: note closing anchor present (after sentence position)
if count_sentence == 1:
    sentence_pos = text.index(OLD_SENTENCE_START)
    count_note_end = text.count(OLD_NOTE_END)
    check(
        "Y2: JONY-ACTION Y note closing anchor found exactly once",
        count_note_end == 1,
        f"Expected 1 occurrence; found {count_note_end}."
    )
else:
    check("Y2: JONY-ACTION Y note closing anchor", False, "Cannot verify — Y1 failed.")
    count_note_end = 0

# Y3: idempotency guard — new content not already present
already_applied = "Mango Markets put the loss-socialisation" in text
check(
    "Y3: Mango Markets replacement not already applied (idempotency guard)",
    not already_applied,
    "Replacement already applied \u2014 re-running would corrupt the file."
)

print()
if errors > 0:
    print(f"ABORT \u2014 {errors} check(s) failed. No changes written.")
    sys.exit(1)

# Compute the full block to replace
sentence_pos = text.index(OLD_SENTENCE_START)
note_end_pos = text.index(OLD_NOTE_END, sentence_pos) + len(OLD_NOTE_END)
old_block = text[sentence_pos:note_end_pos]

if DRY_RUN:
    print("Dry-run complete \u2014 all 3 checks passed.")
    print()
    print("Block to replace (chars {sentence_pos}\u2013{note_end_pos}):".format(
        sentence_pos=sentence_pos, note_end_pos=note_end_pos))
    print(f"  FIRST 80 chars: {old_block[:80]!r}")
    print(f"  LAST  80 chars: {old_block[-80:]!r}")
    print(f"  Block length: {len(old_block)} chars")
    print()
    print("Replacement block (first 120 chars):")
    print(f"  {NEW_BLOCK[:120]!r}")
    print()
    print("Net change: \u2212{} chars / +{} chars".format(len(old_block), len(NEW_BLOCK)))
    print()
    print("To apply:")
    print("  python3 scripts/apply-y.py --apply")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §1.1 opener: JONY-ACTION Y \u2014 Mango Markets (option b)'")
else:
    new_text = text[:sentence_pos] + NEW_BLOCK + text[note_end_pos:]
    PAPER.write_text(new_text, encoding="utf-8")
    print("Applied. Changes written to:")
    print(f"  {PAPER}")
    print()
    # Verify
    lines = new_text.splitlines()
    for i, line in enumerate(lines, 1):
        if "Mango Markets put the loss-socialisation" in line:
            start = max(0, i - 2)
            end = min(len(lines), i + 3)
            for j in range(start, end):
                marker = "\u2192" if j + 1 == i else " "
                print(f"  {marker} L{j+1}: {lines[j][:110]}")
            break
    print()
    print("Next:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print("  git commit -m 'fix §1.1 opener: JONY-ACTION Y \u2014 Mango Markets (option b)'")
    print()
    print("Closes JONY-ACTION Y.")
    print("Open JAs after this: 23 (I, G, A, B, C, O, P, Q, R, S, T, U, W, Z, AA, BB, DD, EE, FF, GG, HH, II, JJ).")
