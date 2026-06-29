# JONY-ACTION JJ — Full Coercion Resistance Cross-Check

_Tick 4213 · 2026-06-29 · Agent-executed_

## Purpose

Verify all occurrences of "coercion resistance" and "coercion vector/vector" language across:
1. `docs/gt-hci-cover-letter-draft-2026-06-29.md` (full cover letter + embedded cold-contact template)
2. `drafts/email-annie-anton-cold-outreach-2026-06-22.md` (standalone cold-contact email)

This is the final pre-application check before JONY-ACTION JJ can be marked ready-to-apply.

---

## File 1: `gt-hci-cover-letter-draft-2026-06-29.md`

### Section: Cover Letter body (lines 17–31)

| Line | Text | Verdict |
|------|------|---------|
| 20 | "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **coercion resistance** simultaneously." | ❌ **BUG — JONY-ACTION JJ** |
| 22 | "receipts containing vote summaries create **coercion vectors**" | ✅ CORRECT — problem description |
| 24 | "sharing a receipt **under coercion**, misreading an absent vote summary as an error…" | ✅ CORRECT — scenario description |

**Bug detail (line 20):**
The system achieves **double-vote prevention (L1)** per §3.3 of the CHI paper.
It does NOT achieve full coercion resistance. L2 is a named limitation (receipt-freeness):
the PIUP fingerprint can function as a selective receipt under a sophisticated coercer.
Claiming "coercion resistance" here is factually inconsistent with the paper's §3.3 L2 and
§6.5 L2 entries, and contradicts the research statement ¶1 which uses "double-vote prevention" precisely.

**Fix (option (a) — RECOMMENDED):**
Replace: `ballot privacy, individual verifiability, and coercion resistance simultaneously`
With: `ballot privacy, individual verifiability, and double-vote prevention simultaneously`

No other wording change needed. Surrounding context remains accurate.

### Section: Cold-contact email template embedded in cover letter (lines 56–80)

| Line | Text | Verdict |
|------|------|---------|
| 67 | "A receipt that includes a vote summary creates a **coercion vector**" | ✅ CORRECT — problem description |

No property claim. No new bugs.

---

## File 2: `drafts/email-annie-anton-cold-outreach-2026-06-22.md`

| Line | Text | Verdict |
|------|------|---------|
| 59 | "demand a receipt that shows their vote — the exact **coercion vector** the ZK guarantee was designed to close" | ✅ CORRECT — design intent description |

**Analysis of line 59:**
"Designed to close" is accurate: the ZK guarantee (non-revealing receipts) was intended to
close the vote-revelation coercion vector. The sentence correctly describes what happens
when bad UX undermines that intent — not claiming the property is fully achieved. The
language does not say the system IS coercion-resistant; it says it was DESIGNED TO CLOSE
a specific coercion vector (vote-reveal demands). This is compatible with L2.

No property overclaims. No new bugs.

---

## Summary

| File | Total "coercion" occurrences | Bugs | Status |
|------|------------------------------|------|--------|
| GT cover letter (body) | 3 | **1** (line 20) | ❌ JJ fix required |
| Cover letter (embedded template) | 1 | 0 | ✅ |
| Standalone cold-contact email | 1 | 0 | ✅ |
| **TOTAL** | **5** | **1** | |

---

## Verdict

- **1 bug**: cover letter ¶2 line 20 — already documented as JONY-ACTION JJ option (a)
- **0 new bugs** found in either cold-contact email
- **Cold-contact email is CLEAN** — ready to send once JJ is applied to the cover letter

### Blocking status

- Cover letter: **BLOCKED** pending JJ option (a) approval
- Cold-contact email to Antón: **BLOCKED** (the cover letter must be fixed before outreach,
  as both represent the same research narrative — an overclaim in the cover letter would
  undermine the cold email's precision)

### When JJ is applied

Cover letter fix takes 10 seconds. No CHI paper edits required by this check.
After JJ: cover letter ¶2 is internally consistent with §3.3 L2, research statement ¶1,
and CMU research statement ¶1 (all say "double-vote prevention").

---

## What this tick did NOT find

No additional "coercion resistance" overclaims were found. The two cold-contact email
drafts use "coercion vector" only — always to describe the design problem, never as a
claimed property. This is the correct register.
