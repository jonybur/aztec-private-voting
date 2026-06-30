# JONY Approval Cheat-Sheet — Current State

**Updated:** tick-4337 (2026-06-30)  
**Supersedes:** tick-4231 version that listed 24 open JAs.  
**Status: 22 of 24 JAs resolved. 2 remain — both require OSF filing only.**

---

## What happened to the 22 resolved JAs

Compression ticks 4309–4318 rewrote §§1.1, 2.1, 2.2, 4.2, 5, 6.1, 6.2, 6.5, 7 directly, incorporating all pending fixes and cutting the body to ~11,576 words. All `[Note (tick-XXXX): ...]` blocks (including JA markers for A–C, G, I, P, Q, R, S, U, W, Y, Z, AA, BB, DD, EE, FF, GG, HH, II, JJ) were absorbed or removed during compression.

The scripts for those JAs (`apply-a-b-c.py`, `apply-g.py`, `apply-i.py`, `apply-p.py`, `apply-r-s.py`, `apply-u.py`, `apply-w.py`, `apply-y.py`, `apply-z-aa-q.py`, `apply-bb.py`, `apply-dd.py`, `apply-ee.py`, `apply-ff.py`, `apply-gg.py`, `apply-hh.py`, `apply-ii.py`, `apply-jj.py`) **are now obsolete** — the paper sections they targeted no longer contain the original anchor text. Do not run them.

---

## ✅ 22/24 Resolved — all scripts applied or absorbed during compression

| JA | Description | Resolution |
|----|-------------|------------|
| A | Q3 stem → instrument wording | Applied (compression tick-4318) |
| B | Q4 stem + foils → instrument wording | Applied (compression tick-4318) |
| C | Q3 clarification removed | Applied (compression tick-4318) |
| I | Remove stale §4.2 marker (post-A+B+C) | Applied (compression tick-4318) |
| G | Remove §2.1 undocumented N=12 pilot note | Applied (compression tick-4318) |
| P | §6.1 E&S description: mechanism corrected | Applied (compression tick-4318) |
| Q | E&S "framework" label removed | Applied via Z+AA+Q rewrite |
| R | Egelman & Schechter §2.2 co-citation removed | Applied (compression tick-4318) |
| S | Egelman & Schechter §2.1 co-citation removed | Applied (compression tick-4318) |
| U | VoteReceipt.tsx E2 text / §5.3 alignment | Applied (compression tick-4318) |
| W | CAL-FEEDBACK Q2 / §5.5 H2.3 note | Applied (compression tick-4318) |
| Y | §1.1 opener: KelpDAO → Mango Markets | Applied (compression tick-4318) |
| Z | Felt 2012 mechanism fix in §1.1 trio | Applied via Z+AA+Q rewrite |
| AA | E&S 2013 mechanism fix in §1.1 trio | Applied via Z+AA+Q rewrite |
| BB | Chaum (2010) → Carback et al. (2009) fix | Applied (compression tick-4318) |
| DD | Adida et al. 4-author entry confirmed | Applied (compression tick-4318) |
| EE | TC2 instrument wording chosen | Applied (compression tick-4318) |
| FF | calibration_confidence definition | Applied (compression tick-4318) |
| GG | SC3 screener removed; DM4 post-hoc | Applied (compression tick-4318) |
| HH | §6.5 L2 receipt-freeness paragraph | Applied (compression tick-4318) |
| II | §6.5 Study 2 ecological validity paragraph | Applied (compression tick-4318) |
| JJ | Cover letter ¶2: "coercion resistance" fix | Applied (compression tick-4318) |

---

## 🔴 2 Open — OSF uploads required (only Jony can do this)

### O — File OSF Amendment 5 (CS/SE student screener extension)

**What:** The SC2 Prolific screener extends the professional exclusion to CS/SE students. This extension is not registered in OSF pre-reg §3. Amendment 5 documents it.

**Amendment text:** Ready in `docs/osf-amendment-filing-2026-06-24.md` → "Amendment 5" section (also accessible via `docs/jony-batch-decision-memo-2026-06-28.md §O`).

**After filing on OSF:**
```bash
python3 scripts/apply-o.py --apply
git add drafts/piup-chi-paper-draft-2026-06-22.md
git commit -m "fix §4.2: JONY-ACTION O resolved — Amendment 5 filed"
```

**Current paper state:** §4.2 contains an inline marker `[JONY-ACTION O: File OSF Amendment 5 — CS/SE student screener extension (before CHI submission)]`. The disclosure sentence is already present. The script removes only the inline marker.

**Priority:** 🔴 CRITICAL PATH — must be filed before any data collection.

---

### T — File OSF Amendments 12, 13, and 14

**What:** Three OSF amendment filings:

| Amendment | What | Pre-reg deviation |
|-----------|------|-------------------|
| **12** | Q5 wording — 4 deviations from pre-reg §5.2 | Prefix "In your own words:"; "this voting system"; emphasized "NOT"; "which option you voted for" |
| **13** | MQ1 rubric clarification — two-dimensional additive rubric is operative | Pre-reg §5.3 is ambiguous for non-leakage-only responses |
| **14** | Attention check descriptions — AC1 answer is "Strongly Disagree" (not "Strongly Agree"); AC2 answer is Carrot/third item (not "a fruit") | Pre-reg §3 descriptions are wrong |

**Amendment text:**
- Amendments 12+13: `docs/jony-batch-decision-memo-2026-06-28.md` → §T
- Amendment 14: `docs/osf-amendment-filing-2026-06-24.md` → "Amendment 14" section

**After filing all three on OSF:**
```bash
python3 scripts/apply-t.py --apply
git add drafts/piup-chi-paper-draft-2026-06-22.md
git commit -m "fix §4.2: JONY-ACTION T resolved — Amendments 12+13+14 filed"
```

**Current paper state:** The Amendments 12 and 13 note blocks were removed during compression (paper prose is clean). §4.2 contains an inline marker `[JONY-ACTION T: File OSF Amendment 14 — correct attention check descriptions in pre-reg §3 (AC1: select "Strongly Disagree"; AC2: select third item = Carrot) before CHI submission]`. The script removes only that inline marker.

**Priority:** 🔴 CRITICAL PATH — must be filed before any data collection.

---

## Fastest path to submission

**Step 1:** File OSF Amendment 5 → run `apply-o.py --apply` → commit.  
**Step 2:** File OSF Amendments 12, 13, 14 → run `apply-t.py --apply` → commit.

After both commits: paper is submission-clean. No further JAs remain.

**CHI deadline:** September 10, 2026 (72 days from June 30, 2026).

---

## Also required before pilot (not paper edits)

From Qualtrics guide cross-check (tick-4335):

| Decision | Action | When |
|----------|--------|------|
| **A** | File OSF Amendment 19 (Q3 wording — instrument vs. pre-reg) | Before pilot |
| **B** | File OSF Amendment 20 (Q4 wording + foils — instrument vs. pre-reg) | Before pilot |
| **C** | File OSF Amendment 21 (Q3 clarification removed — instrument vs. pre-reg) | Before pilot |

These fix the Qualtrics guide's OSF compliance warnings (⚠️ headers). They do NOT require paper edits (paper text is already correct for A+B+C — applied during compression).

---

*Updated tick-4337 (2026-06-30). Previous version (tick-4231) listed 24 JAs — now archived in Multica VON-767.*
