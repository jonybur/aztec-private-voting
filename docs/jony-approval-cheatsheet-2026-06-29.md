# JONY Approval Cheat-Sheet — All 24 Open JONY-ACTIONs

**Generated:** tick-4231 (2026-06-29)  
**Purpose:** One-line-per-item quick reference. For full rationale, see `docs/jony-batch-decision-memo-2026-06-28.md`.  
**All scripts are dry-run verified.** Run the command, then commit.  
**Full memo:** `docs/jony-batch-decision-memo-2026-06-28.md`

---

## 🟢 BATCH YES — Easy confirms (no real choice needed)

Say these phrases and agent runs the script immediately.

| # | Say this | What it does | Script |
|---|----------|--------------|--------|
| **G** | `"G: option (b)"` | Removes §2.1 undocumented N=12 pilot note — design reframe already in place is CHI-safe | `python3 scripts/apply-g.py --apply` |
| **A+B+C** | `"A+B+C: apply"` | Q3 stem → instrument wording; Q4 stem+foils → instrument wording; Q3 baseline clarification removed. File OSF Amendments 4, B, C before pilot. | `python3 scripts/apply-a-b-c.py --apply` |
| **I** | `"I: apply"` | Removes stale §4.2 [JONY-ACTION I] block. **Must do A+B+C first.** | `python3 scripts/apply-i.py --apply` |
| **R+S** | `"R+S: option (a) for both"` | Removes Egelman & Schechter from §2.2+§2.1 co-citations (mechanism mismatch, wrong paper). W&T alone cited. | `python3 scripts/apply-r-s.py --apply` |
| **W** | `"W: option (a)"` | Accepts label-conditioned CAL-FEEDBACK Q2 text as intentional design feature; adds §5.5 H2.3 note | `python3 scripts/apply-w.py --apply` |
| **DD** | `"DD: option (a)"` | Confirms current Adida et al. (2009) 4-author entry is correct (USENIX BibTeX outlier was wrong) | `python3 scripts/apply-dd.py --apply` |
| **JJ** | `"JJ: option (a)"` | Fixes cover-letter ¶2: `"coercion resistance"` → `"double-vote prevention"` (matches research statement) | `python3 scripts/apply-jj.py --apply` |

**Batch phrase:** `"G: option (b); A+B+C: apply; R+S: option (a); W: option (a); DD: option (a); JJ: option (a)"` → I'll run all six scripts and chain I after A+B+C.

---

## 🟡 STRONG RECOMMENDATIONS (agent has a clear answer; just say yes)

| # | Say this | What it does | Script |
|---|----------|--------------|--------|
| **P** | `"P: option (a)"` | §6.1 E&S description: replaces wrong mechanism (behavioral normalization) with correct one (threat-model dismissal / bounded rationality) | `python3 scripts/apply-p.py --apply` |
| **Y** | `"Y: option (b)"` | §1.1 opener: replaces 3-error KelpDAO claim with verified Mango Markets Oct 2022 (canonical DAO governance exploit, factually accurate) | `python3 scripts/apply-y.py --apply` |
| **Z+AA+Q** | `"Z: option (a2)"` | §1.1 trio: replaces false 'consistent finding' with mechanism-specific framing (W&T absent-inference; Felt et al. low-attention; E&S threat-model dismissal). Resolves Z, AA, and Q simultaneously. | `python3 scripts/apply-z-aa-q.py --apply` |
| **BB** | `"BB: option (a)"` | Corrects Chaum (2010) bibliography to 12-author Carback-first EVT/WOTE 2009 entry; updates in-text 'Chaum et al.' → 'Carback et al.' | `python3 scripts/apply-bb.py --apply` |
| **HH** | `"HH: option (a)"` | Adds §6.5 L2 receipt-freeness paragraph + Juels et al. (2005) bibliography entry (all fields verified) | `python3 scripts/apply-hh.py --apply` |
| **II** | `"II: option (a)"` | Adds §6.5 Study 2 ecological validity paragraph (4 bounds: consequentially inert; Prolific sample; delayed-verification gap; H2.3 underpowering cross-ref) | `python3 scripts/apply-ii.py --apply` |

---

## 🔴 REAL CHOICES (Jony must decide; agent cannot infer)

| # | Options | What each means |
|---|---------|-----------------|
| **U** | `"U: option (a)"` — **RECOMMENDED** | Fixes VoteReceipt.tsx E2: 'Your vote choice is not shown...' → 'Your vote is private and verifiable.' (spec-faithful). Updates test assertions. **Dry-run verified all 5 checks pass.** |
| | `"U: option (b)"` | Updates paper §5.3 + design note §6.1 to match current E2 implementation as-is. |
| **EE** | `"EE: option (a)"` — instrument | TC2 = 'I understand what this receipt is for.' (comprehension construct) |
| | `"EE: option (b)"` — guide | TC2 = 'I believe the voting system is secure.' (security belief). Agent also updates instrument §9. |
| **FF** | `"FF: option (a)"` — instrument | `calibration_confidence` = retrospective CAL-probe confidence, I2 only (n=120) |
| | `"FF: option (b)"` — guide | `calibration_confidence` = post-receipt Q-AC confidence, all N=240 |
| **GG** | `"GG: option (a)"` — **RECOMMENDED** | Remove SC3 in-survey screener; use DM4 post-hoc exclusion per pre-reg. No OSF amendment needed. | 
| | `"GG: option (b)"` | Keep SC3; file OSF protocol-deviation amendment. |

---

## 📋 OSF UPLOADS (only Jony can do; no apply script)

| # | Action | When |
|---|--------|------|
| **O** | File **OSF Amendment 5** (CS/SE screener extension) | Before running `apply-o.py` |
| **T** | File **OSF Amendments 12+13+14** (Q5 wording; MQ1 rubric; attention check descriptions) | Before pilot launch |
| **A** | File **OSF Amendment 4** (Q3 wording) | After `apply-a-b-c.py` |
| **B** | File **OSF Amendment** (Q4 wording + foils) | After `apply-a-b-c.py` |
| **C** | File **OSF Amendment** (Q3 clarification removed) | After `apply-a-b-c.py` |

After OSF Amendment 5 is filed: `python3 scripts/apply-o.py --apply`  
After OSF Amendments 12+13+14 are filed: `python3 scripts/apply-t.py --apply`

---

## ⚡ Fastest path to submission

**Step 1 — Say the batch phrase:**
```
"G: option (b); A+B+C: apply; R+S: option (a); W: option (a); DD: option (a); JJ: option (a)"
```
→ Drops 7 JAs. Then I also chain I automatically after A+B+C. → **24 → 16**

**Step 2 — Confirm recommendations:**
```
"P: option (a); Y: option (b); Z: option (a2); BB: option (a); HH: option (a); II: option (a)"
```
→ Drops 6 more JAs. → **16 → 10** (R+S+Q already counted in step 1)

**Step 3 — Real choices:**
```
"U: option (a); EE: option (a); FF: option (a); GG: option (a)"
```
→ Drops 4 more JAs. → **10 → 6**

**Step 4 — OSF uploads (only you can):**
File O (Amendment 5), then run `apply-o.py`.  
File T (Amendments 12+13+14), then run `apply-t.py`.  
→ **6 → 4** (I closes after A+B+C chain already done; leaves zero non-OSF JAs)

**After steps 1–4:** All 24 JAs resolved. Paper + instrument + guide are submission-ready. Annie Antón email unblocked after JJ.

---

## All 24 JAs — status at a glance

| JA | Status | Script |
|----|--------|--------|
| A | 🟢 Batch yes | apply-a-b-c.py |
| B | 🟢 Batch yes | apply-a-b-c.py |
| C | 🟢 Batch yes | apply-a-b-c.py |
| I | 🟢 Batch yes (after A+B+C) | apply-i.py |
| G | 🟢 Batch yes | apply-g.py |
| W | 🟢 Batch yes | apply-w.py |
| DD | 🟢 Batch yes | apply-dd.py |
| JJ | 🟢 Batch yes | apply-jj.py |
| R | 🟢 Batch yes | apply-r-s.py |
| S | 🟢 Batch yes | apply-r-s.py |
| P | 🟡 Strong rec (a) | apply-p.py |
| Y | 🟡 Strong rec (b) | apply-y.py |
| Z | 🟡 Strong rec (a2) | apply-z-aa-q.py |
| AA | 🟡 Strong rec (a2) | apply-z-aa-q.py |
| Q | 🟡 Strong rec (a2) | apply-z-aa-q.py |
| BB | 🟡 Strong rec (a) | apply-bb.py |
| HH | 🟡 Strong rec (a) | apply-hh.py |
| II | 🟡 Strong rec (a) | apply-ii.py |
| U | 🔴 Real choice (rec: a) | apply-u.py |
| EE | 🔴 Real choice (rec: a) | apply-ee.py |
| FF | 🔴 Real choice (rec: a) | apply-ff.py |
| GG | 🔴 Real choice (rec: a) | apply-gg.py |
| O | 📋 OSF upload first | apply-o.py |
| T | 📋 OSF upload first | apply-t.py |
