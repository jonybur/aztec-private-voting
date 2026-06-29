#!/usr/bin/env python3
"""
apply-kk.py — JONY-ACTION KK: H2.3 power disclosure added to §5.2

DEFAULT: dry-run (checks only, no writes)
--apply: apply the fix to the CHI paper draft

Fix: Add H2.3 ≈72% power sentence to §5.2 Power paragraph.
Background: §5.2 disclosed H2.1 (84%) and H2.2 (80%) but omitted H2.3 (72%).
H2.3 (calibration residual TOST, L2 only, n=60) is the only underpowered
Study 2 endpoint. tick-4130 note acknowledged this but only in a Note block;
after note-stripping for CHI submission the disclosure would be invisible.

No real choice required — this is a missing disclosure only.
No OSF amendment needed — design note §10.3 already documents H2.3 power.
"""

import sys
import os

# ── paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT   = os.path.dirname(SCRIPT_DIR)
PAPER_PATH  = os.path.join(REPO_ROOT, "drafts", "piup-chi-paper-draft-2026-06-22.md")

# ── mode ──────────────────────────────────────────────────────────────────────
APPLY = "--apply" in sys.argv

# ── find / verify anchors ─────────────────────────────────────────────────────
with open(PAPER_PATH, "r") as f:
    content = f.read()

# Check KK1: §5.2 Power paragraph present
KK1_ANCHOR = (
    "N = 240 also provides approximately 80% power for the H2.2 interaction endpoint "
    "(f ≈ 0.22; design note §10.2) and adequate headroom for a 20-25% Prolific exclusion "
    "rate without falling below 80% power for H2.1. The final power analysis will be "
    "revised using Study 1 pilot data before Study 2 pre-registration (§5.6)."
)
KK1_PASS = KK1_ANCHOR in content
print(f"KK1 §5.2 Power anchor present: {'PASS ✅' if KK1_PASS else 'FAIL ❌'}")

# Check KK2: H2.3 power NOT yet in §5.2 (idempotency guard)
KK2_SENTINEL = "approximately 72% power for d = 0.50"
KK2_PASS = KK2_SENTINEL not in content
print(f"KK2 H2.3 power sentence not yet present (idempotency): {'PASS ✅' if KK2_PASS else 'ALREADY APPLIED ⚠️'}")

# Check KK3: Design note §10.3 cross-reference present in tick-4130 note
KK3_ANCHOR = "Design note §10.3 reports power ≈ 0.72"
KK3_PASS = KK3_ANCHOR in content
print(f"KK3 tick-4130 source note with §10.3 reference present: {'PASS ✅' if KK3_PASS else 'FAIL ❌'}")

# Check KK4: §5.5 tick-4130 note says 'H2.3 is the only underpowered endpoint'
KK4_ANCHOR = "H2.3 is the only underpowered endpoint"
KK4_PASS = KK4_ANCHOR in content
print(f"KK4 source note 'only underpowered endpoint' statement: {'PASS ✅' if KK4_PASS else 'FAIL ❌'}")

# ── summary ───────────────────────────────────────────────────────────────────
all_pass = KK1_PASS and KK3_PASS and KK4_PASS
if not KK2_PASS:
    print("\n⚠️  KK2 failed — fix already applied. Nothing to do.")
    sys.exit(0)

if not all_pass:
    print("\n❌ Pre-conditions failed — cannot apply safely.")
    sys.exit(1)

print("\n4/4 checks pass ✅")

if not APPLY:
    print("\nDRY-RUN: No changes written. Run with --apply to apply.")
    print("\nWould insert after H2.2 power sentence, before 'The final power analysis will be revised':")
    print()
    print("  H2.3 (calibration residual TOST; M4 in L2 conditions only; n = 60 pooled across I levels)")
    print("  provides approximately 72% power for d = 0.50 (α = 0.05, one-tailed; design note §10.3) —")
    print("  below the 80% threshold, consistent with H2.3's status as a conditional secondary test")
    print("  dependent on H4 support; a calibration-focused Study 2b (L2 only, N = 80) is pre-planned")
    print("  if H2.3 is inconclusive.")
    sys.exit(0)

# ── apply ─────────────────────────────────────────────────────────────────────
H2_3_SENTENCE = (
    " H2.3 (calibration residual TOST; M4 in L2 conditions only; n = 60 pooled across I levels) "
    "provides approximately 72% power for d = 0.50 (α = 0.05, one-tailed; design note §10.3) — "
    "below the 80% threshold, consistent with H2.3's status as a conditional secondary test dependent "
    "on H4 support; a calibration-focused Study 2b (L2 only, N = 80) is pre-planned if H2.3 is inconclusive."
)

OLD_TAIL = (
    " The final power analysis will be revised using Study 1 pilot data before Study 2 pre-registration (§5.6)."
)
NEW_TAIL = H2_3_SENTENCE + OLD_TAIL

new_content = content.replace(KK1_ANCHOR, KK1_ANCHOR.replace(OLD_TAIL, "") + H2_3_SENTENCE + OLD_TAIL, 1)

# Verify replacement happened
if new_content == content:
    # Try direct replacement
    new_content = content.replace(
        "rate without falling below 80% power for H2.1. The final power analysis will be revised using Study 1 pilot data before Study 2 pre-registration (§5.6).",
        "rate without falling below 80% power for H2.1." + H2_3_SENTENCE + " The final power analysis will be revised using Study 1 pilot data before Study 2 pre-registration (§5.6).",
        1
    )

if new_content == content:
    print("❌ Replacement failed — anchor not found for substitution.")
    sys.exit(1)

with open(PAPER_PATH, "w") as f:
    f.write(new_content)

print("\n✅ APPLIED: H2.3 power sentence added to §5.2 Power paragraph.")
print("   Discloses: ≈72% power for d=0.50 (design note §10.3); Study 2b pre-planned if inconclusive.")
print("   No protocol or analysis impact — disclosure only.")
