# Decision Memo: JONY-ACTIONs EE, FF, GG
_tick-4234 | 2026-06-29 | pre-registration-critical choices_

These are the four **real choices** from the cheatsheet that require your judgment call —
the other 20 JAs have a clear recommendation or are batch-approvable.
All three apply scripts pass dry-run (✅ EE: 3/3, FF: 6/6 (a) or 4/4 (b), GG: 4/4 (a) or 2/2 (b)).

---

## EE — TC2 wording: comprehension vs. security belief

**Conflict:** Guide had `trust_competence_2` = "I believe the voting system that produced
this receipt is secure" (security belief). Instrument §9 specifies TC2 = "I understand
what this receipt is for." (comprehension). The instrument wording was already applied in
the guide. This flag just needs confirmation.

**Option (a):** Keep instrument wording — "I understand what this receipt is for."
Remove EE flag. No instrument change. ← **1-check confirm**

**Assessment:** This is the obvious right call. TC2 is in the _Comprehension_ scale, not
a security scale. The old wording measured a completely different construct (security
belief vs. comprehension). The instrument §9 wording is correct. No real tension here.

**Recommended: (a).** Approve with `python3 scripts/apply-ee.py --apply`.

---

## FF — calibration_confidence: all-conditions post-receipt vs. I2-only retrospective

**Conflict:** Two incompatible designs were drafted for M4:
- **Guide (option a):** `calibration_confidence` = post-receipt confidence in Q-AC answer,
  asked of _all_ conditions. Question: "How confident are you in your answer above?"
- **Instrument §11 (option b):** `calibration_confidence` = retrospective confidence in
  CAL-probe answers, asked of _I2 only_. Question: "Before you saw the receipt, we asked
  you two quick questions. Looking back at your answers: how confident were you that they
  were correct at the time?"

**What the pre-registration says:** Instrument §11 (the registered document) specifies
I2-only, retrospective CAL-probe confidence. This is the construct that was pre-registered.

**Option (a):** Guide wins. All conditions. Q-AC post-receipt confidence. Instrument §11
updated to match. _⚠️ If the instrument was pre-registered I2-only, this is an instrument
amendment — file OSF amendment before registration._

**Option (b):** Instrument wins. I2 only. Retrospective CAL-probe confidence. Guide updated
to match. No OSF amendment needed (pre-registration intact).

**Assessment:** The instrument §11 is what was registered. The retrospective calibration
confidence (option b) is the construct that H2.3 was designed around — it directly asks
"were you confident about the CAL probes before seeing the receipt?", which is the
calibration residual used in the R analysis (`m4_residual = calibration_confidence_scaled - qac_correct`).
If you go with option (a), you're measuring something different (post-receipt Q-AC confidence)
and you need to file an OSF amendment. For a CHI pre-registered study, changing the
dependent variable measure requires justification.

**The key question for you:** Was H2.3 designed with the retrospective calibration residual
in mind, or did you always intend all-conditions Q-AC confidence?
- If retrospective residual → **option (b)**, no amendment needed.
- If all-conditions Q-AC → **option (a)**, file OSF amendment first.

**Lean: (b)** — matches the pre-registered instrument, no amendment required.
Commands: `python3 scripts/apply-ff.py --option b --apply`

---

## GG — SC3 screener: remove (no amendment) vs. keep (OSF amendment)

**Conflict:** The guide adds SC3 — a pre-survey screener that excludes prior-study
participants before any data is collected (skip logic → screen out). The pre-registered
instrument has no SC3. Instead it uses DM3/DM4 to capture prior-study participation
post-hoc in R, with the Prolific "Previous Studies" filter as primary defence.
These approaches are incompatible.

**Option (a):** Remove SC3. Rely on Prolific "Previous Studies" filter + DM3 post-hoc
R exclusion. No OSF amendment needed. DM3 wording corrected (instrument §14 match:
"voting receipts, voting confirmations, or post-vote screens"; "past 6 months").
Screener references (screen-out paths, preflight checklist) updated to SC1/SC2 only.

**Option (b):** Keep SC3. Log as protocol amendment before OSF registration. DM3 wording
corrected (instrument match, follow-up-to-screener note retained). Screen-out paths
keep SC3 reference.

**Assessment:**
- The Prolific "Previous Studies" filter is the standard method and is typically reliable.
- SC3 adds an extra layer but creates a pre-registration deviation that _requires_ an
  amendment (more work, more reviewer scrutiny).
- DM3 post-hoc exclusion in R is the registered mechanism — it works.
- For a CHI study, the cleaner pre-registration story is option (a): "we relied on
  the Prolific filter + DM3 post-hoc, as pre-registered."
- If you're worried about contamination risk (e.g., Study 1 not yet on Prolific so the
  filter can't be set), then option (b) is the safety play — but costs you an amendment.

**Recommended: (a)** — keeps the pre-registration clean, no amendment, DM3 corrected.
But if Study 1 is not yet launched on Prolific, reconsider.
Commands: `python3 scripts/apply-gg.py --apply`

---

## Quick verdict table

| JA | Question | Lean | OSF impact |
|----|----------|------|------------|
| EE | TC2 wording (comprehension vs. security belief) | **(a)** — confirm instrument | None |
| FF | calibration_confidence (all-conditions Q-AC vs. I2-only retrospective) | **(b)** — keep pre-reg | None |
| GG | SC3 screener (remove vs. keep) | **(a)** — remove, no amendment | None if (a) |

If all three go **(a), (b), (a)**: no OSF amendments triggered by this batch.
If FF→(a): need OSF instrument amendment before registration.
If GG→(b): need OSF protocol amendment before registration.

---

## Apply commands (recommended path)

```bash
cd ~/workspace/aztec-private-voting

# EE — (a)
python3 scripts/apply-ee.py --apply
git add docs/qualtrics-setup-guide-study2-2026-06-28.md
git commit -m 'fix Study 2 guide: JONY-ACTION EE resolved (a) — TC2 instrument wording confirmed'

# FF — (b)
python3 scripts/apply-ff.py --option b --apply
git add docs/qualtrics-setup-guide-study2-2026-06-28.md
git commit -m 'fix Study 2 calibration_confidence: JONY-ACTION FF resolved (b) — I2-only retrospective'

# GG — (a)
python3 scripts/apply-gg.py --apply
git add docs/qualtrics-setup-guide-study2-2026-06-28.md
git commit -m 'fix Study 2 screener: JONY-ACTION GG resolved (a) — SC3 removed, DM3 corrected'
```

That clears EE + FF + GG (3 JAs), leaving U (the code fix choice) as the
only remaining real-decision JA.
