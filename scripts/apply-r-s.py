#!/usr/bin/env python3
"""
JONY-ACTIONs R + S — E&S co-citation removal from §2.2 Alt3 and §2.1 — commit-ready apply script
Prepared: tick-4217 (2026-06-29)

ISSUE R (§2.2 Alt3):
  'Prior work on absent-content interpretation [Egelman and Schechter 2013; Whitten and Tygar 1999]
   consistently finds that users interpret absent expected content as failure ...'
  Fix: remove E&S from co-citation; remove 'consistently'.
  After: '[Whitten and Tygar 1999] finds that users interpret absent expected content as failure ...'
  Rationale: E&S (2013) studied unexpected PRESENCE of phishing warning → threat-model dismissal.
  Mechanism does not support 'absent expected content → failure' claim. W&T (1999) directly does.

ISSUE S (§2.1):
  '...error, incomplete transaction, or untrustworthy system [Egelman and Schechter 2013; Whitten and Tygar 1999].'
  Fix: remove E&S from co-citation, retain W&T alone.
  After: '...error, incomplete transaction, or untrustworthy system [Whitten and Tygar 1999].'
  Same mechanism mismatch as R: E&S documented threat-model dismissal on a PRESENT warning;
  W&T (1999) directly supports all three failure modes (error/incomplete/untrustworthy) for absent content.

Usage:
    python3 apply-r-s.py           # Dry run (validate without writing)
    python3 apply-r-s.py --apply   # Apply (both R and S)

Run from aztec-private-voting/ root.

After running:
    git add drafts/piup-chi-paper-draft-2026-06-22.md
    git commit -m "fix §2.2+§2.1 E&S co-citation: JONY-ACTIONs R+S resolved — option (a) applied"
"""

import sys
import os

PAPER = "drafts/piup-chi-paper-draft-2026-06-22.md"

# ─── CHANGE S-1: Remove E&S from §2.1 co-citation ────────────────────────────
# Unique because of the [Fixed tick-3991 - JONY-ACTION J (§2.1 site)] suffix
S1_OLD = (
    "untrustworthy system [Egelman and Schechter 2013; Whitten and Tygar 1999]. "
    "[Fixed tick-3991 - JONY-ACTION J (\u00a72.1 site)"
)
S1_NEW = (
    "untrustworthy system [Whitten and Tygar 1999]. "
    "[Fixed tick-3991 - JONY-ACTION J (\u00a72.1 site)"
)

# ─── CHANGE S-2: Replace the open JONY-ACTION S Note with a resolution note ──
# From the Note open to (and including) its closing sentence.
S2_OLD_OPEN = "[Note (tick-4119 - JONY-ACTION S):"
S2_OLD_CLOSE = "categorically different in both cases. Jony must confirm option (a), (b), or (c) before CHI submission.]"
S2_NEW = (
    "[S RESOLVED \u2014 Option (a) applied tick-4217: E&S (2013) removed from "
    "\u00a72.1 co-citation; W&T (1999) retained as sole support for absent-confirmation "
    "failure modes (error, incomplete transaction, untrustworthy system). E&S (2013) "
    "studied unexpected PRESENCE of a phishing warning \u2014 mechanism: threat-model "
    "dismissal / bounded rationality \u2014 not absent-content \u2192 error inference. "
    "W&T (1999) directly documents the error/incomplete/untrustworthy triad for absent "
    "cryptographic output. Closes JONY-ACTION S (tick-4119). 24 \u2192 23 open JAs.]"
)

# ─── CHANGE R-1: Remove E&S + 'consistently' from §2.2 Alt3 co-citation ──────
# Unique string.
R1_OLD = (
    "[Egelman and Schechter 2013; Whitten and Tygar 1999] consistently finds"
)
R1_NEW = (
    "[Whitten and Tygar 1999] finds"
)

# ─── CHANGE R-2: Replace the open JONY-ACTION R Note with a resolution note ──
R2_OLD_OPEN = "[Note (tick-4118 - JONY-ACTION R):"
R2_OLD_CLOSE = "comparable to \u00a71.1 JONY-ACTION Q). Jony must confirm option (a), (b), or (c) before CHI submission.]"
R2_NEW = (
    "[R RESOLVED \u2014 Option (a) applied tick-4217: E&S (2013) removed from "
    "\u00a72.2 Alt3 co-citation; W&T (1999) retained as sole support for "
    "'absent-content interpretation \u2192 failure' claim. 'Consistently' removed (W&T "
    "alone does not require that qualifier). E&S (2013) studied unexpected PRESENCE of "
    "phishing warning \u2014 mechanism: threat-model dismissal / bounded rationality \u2014 "
    "not absent-expected-content \u2192 failure inference. W&T (1999) directly documents "
    "absent PGP output \u2192 user concludes system failed. Closes JONY-ACTION R "
    "(tick-4118). 23 \u2192 22 open JAs (after S).]"
)


def apply_s2(content: str) -> tuple[bool, str]:
    """Find and replace the S Note block (from open to close)."""
    pos_open = content.find(S2_OLD_OPEN)
    if pos_open == -1:
        return False, "S2_OLD_OPEN not found"
    pos_close = content.find(S2_OLD_CLOSE, pos_open)
    if pos_close == -1:
        return False, "S2_OLD_CLOSE not found after S2_OLD_OPEN"
    block_end = pos_close + len(S2_OLD_CLOSE)
    new_content = content[:pos_open] + S2_NEW + content[block_end:]
    return True, new_content


def apply_r2(content: str) -> tuple[bool, str]:
    """Find and replace the R Note block (from open to close)."""
    pos_open = content.find(R2_OLD_OPEN)
    if pos_open == -1:
        return False, "R2_OLD_OPEN not found"
    pos_close = content.find(R2_OLD_CLOSE, pos_open)
    if pos_close == -1:
        return False, "R2_OLD_CLOSE not found after R2_OLD_OPEN"
    block_end = pos_close + len(R2_OLD_CLOSE)
    new_content = content[:pos_open] + R2_NEW + content[block_end:]
    return True, new_content


def dry_run(content: str) -> bool:
    """Validate all 4 changes are applicable."""
    ok = True

    # S1
    count_s1 = content.count(S1_OLD)
    if count_s1 == 0:
        print("ERROR S1: S1_OLD not found — §2.1 citation may already be fixed.")
        ok = False
    elif count_s1 > 1:
        print(f"ERROR S1: S1_OLD found {count_s1} times — not unique.")
        ok = False
    else:
        pos = content.find(S1_OLD)
        print(f"[OK] S1 found at char {pos}: ...{repr(content[pos:pos+80])}...")

    # S2
    pos_open_s2 = content.find(S2_OLD_OPEN)
    if pos_open_s2 == -1:
        print("ERROR S2: S2_OLD_OPEN not found — may already be resolved.")
        ok = False
    else:
        pos_close_s2 = content.find(S2_OLD_CLOSE, pos_open_s2)
        if pos_close_s2 == -1:
            print("ERROR S2: S2_OLD_CLOSE not found after S2_OLD_OPEN.")
            ok = False
        else:
            block_len_s2 = (pos_close_s2 + len(S2_OLD_CLOSE)) - pos_open_s2
            print(f"[OK] S2 Note block: open at {pos_open_s2}, close at {pos_close_s2}, length {block_len_s2} chars")

    # R1
    count_r1 = content.count(R1_OLD)
    if count_r1 == 0:
        print("ERROR R1: R1_OLD not found — §2.2 citation may already be fixed.")
        ok = False
    elif count_r1 > 1:
        print(f"ERROR R1: R1_OLD found {count_r1} times — not unique.")
        ok = False
    else:
        pos = content.find(R1_OLD)
        print(f"[OK] R1 found at char {pos}: ...{repr(content[pos:pos+80])}...")

    # R2
    pos_open_r2 = content.find(R2_OLD_OPEN)
    if pos_open_r2 == -1:
        print("ERROR R2: R2_OLD_OPEN not found — may already be resolved.")
        ok = False
    else:
        pos_close_r2 = content.find(R2_OLD_CLOSE, pos_open_r2)
        if pos_close_r2 == -1:
            print("ERROR R2: R2_OLD_CLOSE not found after R2_OLD_OPEN.")
            ok = False
        else:
            block_len_r2 = (pos_close_r2 + len(R2_OLD_CLOSE)) - pos_open_r2
            print(f"[OK] R2 Note block: open at {pos_open_r2}, close at {pos_close_r2}, length {block_len_r2} chars")

    # Check that S changes precede R changes (ordering sanity)
    if ok:
        pos_s1 = content.find(S1_OLD)
        pos_r1 = content.find(R1_OLD)
        if pos_s1 < pos_r1:
            print(f"[OK] S1 ({pos_s1}) precedes R1 ({pos_r1}) — §2.1 before §2.2 as expected")
        else:
            print(f"WARNING: S1 ({pos_s1}) is after R1 ({pos_r1}) — unexpected ordering")

    print()
    if ok:
        print("[OK] All checks passed. Ready to apply.")
    return ok


def apply_all(content: str) -> str:
    """Apply all 4 changes in order (S1, S2, R1, R2)."""
    # S1: simple string replace
    content = content.replace(S1_OLD, S1_NEW, 1)
    # S2: block replace
    ok, result = apply_s2(content)
    if not ok:
        print(f"FATAL during apply_s2: {result}")
        sys.exit(1)
    content = result
    # R1: simple string replace
    content = content.replace(R1_OLD, R1_NEW, 1)
    # R2: block replace
    ok, result = apply_r2(content)
    if not ok:
        print(f"FATAL during apply_r2: {result}")
        sys.exit(1)
    content = result
    return content


def verify_applied(content: str) -> bool:
    """Post-apply checks."""
    ok = True
    if S1_OLD in content:
        print("ERROR: S1_OLD still present after apply.")
        ok = False
    if S1_NEW not in content:
        print("ERROR: S1_NEW not found after apply.")
        ok = False
    if R1_OLD in content:
        print("ERROR: R1_OLD still present after apply.")
        ok = False
    if R1_NEW not in content:
        print("ERROR: R1_NEW not found after apply.")
        ok = False
    if S2_OLD_OPEN in content:
        print("ERROR: S2_OLD_OPEN still present after apply (S Note not replaced).")
        ok = False
    if R2_OLD_OPEN in content:
        print("ERROR: R2_OLD_OPEN still present after apply (R Note not replaced).")
        ok = False
    if "S RESOLVED" not in content:
        print("ERROR: S RESOLVED marker not found after apply.")
        ok = False
    if "R RESOLVED" not in content:
        print("ERROR: R RESOLVED marker not found after apply.")
        ok = False
    return ok


def main():
    dry = "--apply" not in sys.argv

    if not os.path.exists(PAPER):
        print(f"ERROR: Paper not found at {PAPER}")
        print("Run from aztec-private-voting/ root.")
        sys.exit(1)

    with open(PAPER, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== JONY-ACTIONs R+S apply script (\u00a72.2+\u00a72.1 E&S co-citation removal) ===")
    print(f"Paper: {PAPER}")
    print(f"Mode: {'DRY RUN' if dry else 'APPLY'}")
    print()

    ok = dry_run(content)
    if not ok:
        sys.exit(1)

    if dry:
        print("Dry run complete. No changes written.")
        sys.exit(0)

    new_content = apply_all(content)

    # Post-apply verification
    if not verify_applied(new_content):
        print("ERROR: Post-apply verification failed. Aborting write.")
        sys.exit(1)

    with open(PAPER, "w", encoding="utf-8") as f:
        f.write(new_content)

    print()
    print("[DONE] R+S applied successfully.")
    print()
    print("Changes made:")
    print("  S1: Removed E&S from \u00a72.1 co-citation (\u00a72.1 'error, incomplete, untrustworthy')")
    print("  S2: Replaced JONY-ACTION S Note with resolution note")
    print("  R1: Removed E&S + 'consistently' from \u00a72.2 Alt3 co-citation")
    print("  R2: Replaced JONY-ACTION R Note with resolution note")
    print()
    print("Next steps:")
    print("  git add drafts/piup-chi-paper-draft-2026-06-22.md")
    print('  git commit -m "fix \u00a72.2+\u00a72.1 E&S co-citation: JONY-ACTIONs R+S resolved \u2014 option (a) applied"')
    print()
    print("Closes JONY-ACTIONs R and S. Open JAs: 24 \u2192 22.")


if __name__ == "__main__":
    main()
