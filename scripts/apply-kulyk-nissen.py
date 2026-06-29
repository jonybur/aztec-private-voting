#!/usr/bin/env python3
"""
apply-kulyk-nissen.py — Replace ghost citation Kulyk et al. 2017 with Nissen et al. 2025.

JONY-ACTION: Kulyk 2017 INTERACT citation resolution.

Usage:
  python3 scripts/apply-kulyk-nissen.py           # dry-run (default)
  python3 scripts/apply-kulyk-nissen.py --apply   # apply changes

What it does (option a — recommended):
  1. §3.3 body text: replaces the long [Kulyk et al. 2017 ... CONFIRMED NOT IN DBLP ...] block
     with a clean "Nissen et al. 2025" citation.
  2. Bibliography: replaces the non-existent Kulyk 2017 INTERACT entry with the
     DBLP-verified Nissen et al. 2025 reference.

Evidence:
  - Kulyk 2017 INTERACT: NOT IN DBLP (confirmed tick-4054), zero web search results (tick-4197).
  - Nissen et al. 2025: DBLP-verified at dblp.org/rec/conf/evoteid/NissenHBVK25.
    Same Kulyk research group, directly about coercion perception in internet voting.
"""

import sys
import re

PROTOCOL_PATH = "docs/piup-study-protocol-2026-06-22.md"

# ---------------------------------------------------------------------------
# Change 1 — §3.3 body text
# ---------------------------------------------------------------------------
OLD_BODY = (
    "A single coercion demand vignette has been used in voting UX studies (Kulyk et al. 2017 "
    "on coercibility perception in remote electronic voting) [CONFIRMED NOT IN DBLP tick-4054. "
    "CANDIDATE REPLACEMENT VERIFIED tick-4056: Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., "
    "and Kulyk, O. (2025). 'Voting Under Pressure: Perceptions of Counter-Strategies in Internet "
    "Voting.' E-VOTE-ID 2025. DOI: 10.1007/978-3-032-05036-6_10 \u2014 DBLP-verified "
    "(dblp.org/rec/conf/evoteid/NissenHBVK25). This paper (a) is by the same Kulyk research group, "
    "(b) is directly about coercion perception in internet voting, matching the body description. "
    "Jony must choose before submission: (a) replace with Nissen et al. 2025 (recommended \u2014 "
    "best match for coercion-vignette precedent), (b) supply the original DOI/page-range if "
    "'Kulyk 2017 INTERACT' exists as an unindexed workshop paper, or (c) remove and rephrase as "
    "protocol design rationale. Do NOT submit with the current Kulyk 2017 INTERACT reference.]; "
    "the current protocol adapts that design to the private-voting receipt context."
)

NEW_BODY = (
    "A single coercion demand vignette has been used in voting UX studies (Nissen et al. 2025 "
    "on coercibility perception in remote electronic voting); "
    "the current protocol adapts that design to the private-voting receipt context."
)

# ---------------------------------------------------------------------------
# Change 2 — Bibliography entry
# ---------------------------------------------------------------------------
OLD_BIB = (
    "- Kulyk, O., et al. (2017). Does my vote count? Voter experience with verifiability in "
    "internet voting. *INTERACT 2017*. [CONFIRMED NOT IN DBLP tick-4054 (2026-06-27). "
    "CANDIDATE REPLACEMENT VERIFIED tick-4056: Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., "
    "and Kulyk, O. (2025). 'Voting Under Pressure: Perceptions of Counter-Strategies in Internet "
    "Voting.' *E-VOTE-ID 2025*. DOI: 10.1007/978-3-032-05036-6_10 (DBLP-verified: "
    "dblp.org/rec/conf/evoteid/NissenHBVK25). This 2025 paper is by the same Kulyk group and "
    "matches the body description ('coercibility perception in remote electronic voting'). "
    "Recommendation: replace this entry with the Nissen et al. 2025 citation. Body text cross-ref "
    "should change from 'Kulyk et al. 2017' to 'Nissen et al. 2025'. Do NOT submit the current "
    "entry \u2014 it does not exist. Action required before submission (Jony confirmation of "
    "option (a), (b), or (c) as noted in \u00a73.3 body note).]"
)

NEW_BIB = (
    "- Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). "
    "Voting Under Pressure: Perceptions of Counter-Strategies in Internet Voting. "
    "*E-VOTE-ID 2025*. LNCS vol. 16028, pp. 158\u2013174. Springer. "
    "DOI: 10.1007/978-3-032-05036-6_10."
)

CHECKS = [
    ("body_old_present", OLD_BODY, True),
    ("bib_old_present",  OLD_BIB,  True),
    ("body_new_absent",  NEW_BODY, False),
    ("bib_new_absent",   NEW_BIB,  False),
]

def run(apply: bool = False):
    with open(PROTOCOL_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    print("=== DRY-RUN ===" if not apply else "=== APPLYING ===")

    passed = 0
    failed = 0
    for name, text, should_be_present in CHECKS:
        found = text in content
        ok = found == should_be_present
        status = "PASS" if ok else "FAIL"
        label = "present" if should_be_present else "absent"
        if ok:
            passed += 1
        else:
            failed += 1
        print(f"  [{status}] {name}: expected {label}, found {'present' if found else 'absent'}")

    print(f"\n{passed}/{passed+failed} checks pass.")

    if failed:
        print("ABORT: pre-conditions not met.")
        sys.exit(1)

    if not apply:
        print("\nDry-run complete. Run with --apply to write changes.")
        return

    # Apply changes
    updated = content.replace(OLD_BODY, NEW_BODY)
    if updated == content:
        print("ERROR: body replacement had no effect.")
        sys.exit(1)

    updated = updated.replace(OLD_BIB, NEW_BIB)
    if updated == content:
        print("ERROR: bib replacement had no effect.")
        sys.exit(1)

    with open(PROTOCOL_PATH, "w", encoding="utf-8") as f:
        f.write(updated)

    print(f"\nWrote: {PROTOCOL_PATH}")
    print("Changes applied:")
    print("  1. §3.3 body: Kulyk et al. 2017 [ghost] → Nissen et al. 2025")
    print("  2. Bibliography: ghost entry → Nissen et al. 2025 (DBLP-verified)")
    print("\nNext: git add docs/piup-study-protocol-2026-06-22.md && git commit -m 'fix: replace ghost Kulyk 2017 INTERACT with Nissen et al. 2025 in study protocol §3.3'")


if __name__ == "__main__":
    apply_flag = "--apply" in sys.argv
    run(apply=apply_flag)
