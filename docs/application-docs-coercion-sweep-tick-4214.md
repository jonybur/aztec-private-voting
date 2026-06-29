# Application Docs 'Coercion Resistance' Full Sweep — tick-4214

**Date:** 2026-06-29  
**Purpose:** Defensive sweep — verify no outgoing application document claims 'coercion resistance' as a system property, beyond the already-known cover letter ¶2 bug (JONY-ACTION JJ).

---

## Files Checked

### 1. GT HCI Research Statement (`docs/gt-hci-research-statement-draft-2026-06-22.md`)

| Line | Text | Verdict |
|---|---|---|
| 15 | 'zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **double-vote prevention** simultaneously' | ✅ CLEAN — correct property |
| 16 | 'receipts containing vote summaries created **coercion vectors** (a coercer could demand to see the receipt)' | ✅ CLEAN — describes design problem, not a claimed property |
| 28 | 'sharing receipts **under coercion**, misinterpreting the absent vote summary...' | ✅ CLEAN — describes user behavior risk |

**Result: 0 BUGS.**

---

### 2. CMU HCI Research Statement (`docs/cmu-hci-research-statement-draft-2026-06-22.md`)

| Line | Text | Verdict |
|---|---|---|
| 17 | 'receipts containing vote summaries created **coercion vectors** (a coercer could demand to see the receipt)' | ✅ CLEAN — describes design problem |

**Result: 0 BUGS.**

---

### 3. Forum Post / Grant Application (`docs/forum-post-grant-application.md`)

| Line | Text | Verdict |
|---|---|---|
| 105 | '\| MACI V3 \| **strongest coercion resistance** \| library only \| ❌ \|' | ✅ CLEAN — Cryptography column of comparison table; describes MACI V3's property, not Aztec Private Voting |

**Result: 0 BUGS.** The comparison table correctly attributes 'coercion resistance' to MACI V3 as a competitor property; the Aztec Private Voting row does not claim it.

---

### 4. GT HCI Cover Letter (`docs/gt-hci-cover-letter-draft-2026-06-29.md`)

Already swept in tick-4213. Known bug at ¶2 line 20: 'coercion resistance simultaneously' — JONY-ACTION JJ pending.

**Result: 1 KNOWN BUG (JONY-ACTION JJ).**

---

### 5. Cold-Contact Email (`drafts/email-annie-anton-cold-outreach-2026-06-22.md`)

Already swept in tick-4213. Confirmed CLEAN.

**Result: 0 BUGS.**

---

### 6. JJ Proposal Doc (`docs/chi-cover-letter-coercion-resistance-proposal-tick-4201.md`)

Internal analysis document — not an outgoing application document. Not counted.

---

## Overall Verdict

**0 NEW BUGS across all outgoing application documents.**

All research statements (GT + CMU) correctly use 'double-vote prevention' as the claimed property and 'coercion vectors' only to describe the UI design problem. The forum post correctly attributes 'coercion resistance' to MACI V3 (competitor), not to Aztec Private Voting.

**Remaining block:** GT cover letter ¶2 (JONY-ACTION JJ) — pending Jony's 'JJ: option (a)' approval.

After JJ is resolved: all application documents will be cleared for sending to Annie Antón.
