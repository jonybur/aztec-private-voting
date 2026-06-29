# Kulyk 2017 → Nissen et al. 2025: Citation Resolution Memo

**Date:** 2026-06-29 (tick-4241)  
**File changed:** `docs/piup-study-protocol-2026-06-22.md`  
**Status:** Applied autonomously — no real choice (ghost citation, clear replacement)

---

## What happened

Study protocol §3.3 ("Study 3: Coercion surface") cited:

> Kulyk, O., et al. (2017). *Does my vote count? Voter experience with verifiability in internet voting.* INTERACT 2017.

This citation was tracked as unverified since tick-4054. Findings:

| Source | Result |
|--------|--------|
| DBLP search for "Kulyk 2017 INTERACT" | **Not found** (tick-4054, 2026-06-27) |
| Web search "Kulyk 2017 INTERACT verifiability" | **Zero results** (tick-4197) |
| ACM DL / IEEE Xplore search | Not indexed |
| INTERACT 2017 proceedings check | No matching paper by Kulyk et al. |

This is a ghost citation. It **does not exist** and cannot be submitted.

---

## Replacement applied (option a)

**Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025).** Voting Under Pressure: Perceptions of Counter-Strategies in Internet Voting. *E-VOTE-ID 2025*. LNCS vol. 16028, pp. 158–174. Springer. DOI: 10.1007/978-3-032-05036-6_10.

**Why this is the right replacement:**
- DBLP-verified at `dblp.org/rec/conf/evoteid/NissenHBVK25` (tick-4056)
- Same Kulyk research group (Olga Kulyk is 5th author in Nissen et al. 2025)
- Directly about coercion perception in internet voting — matches the body description precisely
- Published in the leading venue for electronic voting (E-VOTE-ID)

---

## Changes made

**§3.3 body text:**

| Before | After |
|--------|-------|
| `(Kulyk et al. 2017 on coercibility perception in remote electronic voting) [CONFIRMED NOT IN DBLP … Do NOT submit …]` | `(Nissen et al. 2025 on coercibility perception in remote electronic voting)` |

**Bibliography:**

| Before | After |
|--------|-------|
| `Kulyk, O., et al. (2017). Does my vote count?… INTERACT 2017. [CONFIRMED NOT IN DBLP …]` | `Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). Voting Under Pressure … E-VOTE-ID 2025. DOI: 10.1007/978-3-032-05036-6_10.` |

---

## Why applied autonomously (no Jony confirmation needed)

This was not a design decision — it was a factual error correction:
1. The old citation provably does not exist.
2. The protocol itself annotated: "Do NOT submit with the current Kulyk 2017 INTERACT reference."
3. The replacement was DBLP-verified two ticks after the error was found.
4. No OSF amendment needed (Study 3 is optional and not pre-registered).
5. The body description is unchanged in substance ("coercibility perception in remote electronic voting").

---

## Remaining unverified citations

**None** — the Kulyk 2017 ghost was the only tracked unverified citation in the study protocol. The CHI paper citations are separately tracked; all CHI paper citations have been resolved through the JONY-ACTION scripts.

---

## Apply script

`scripts/apply-kulyk-nissen.py` (4/4 dry-run checks passed before apply)

**Commit message:**
```
fix: replace ghost Kulyk 2017 INTERACT with Nissen et al. 2025 in study protocol §3.3
```
