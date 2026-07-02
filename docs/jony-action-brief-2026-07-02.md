# Jony Action Brief — Current (tick-4465, 2026-07-02)

**Supersedes:** `docs/jony-approval-cheatsheet-2026-06-29.md` (that doc covered only JA-O and JA-T; new actions have since accumulated)  
**Updated:** tick-4474 (2026-07-02 09:28 UTC)  
**Status:** 7 open Jony actions + 1 optional + 1 CHI paper decision

---

## CRITICAL PATH SUMMARY

To launch Study 1 pilot → which enables Studies 2–4 → which enables CHI submission → which enables GT/CMU application:

| Blocker | What | Est. time |
|---------|------|-----------|
| **A. File OSF amendments (all 16)** | Log every pre-data deviation before any participant sees the study | 30–45 min (paste-ready text in linked docs) |
| **B. Upload pre-reg files to OSF** | `piup-study1-preregistration-2026-06-22.md` + analysis scripts | 10 min |
| **C. Deploy stimuli at public URL** | `study-stimuli/*.html` (4 files, post-commit 5ac9bd6) to Vercel | 5 min |
| **D. Launch Study 1 on Prolific** | See `docs/prolific-setup-guide-study1-2026-06-30.md` | 15 min |
| **Aztec grant** | Redeploy contract + post to forum.aztec.network | ~1 hr (deployment) |
| **GT/CMU cold-contact** | Send emails (text ready in cover letter docs) | 10 min |

**Today is 2026-07-02. CHI deadline is September 10 (69 days). Study 1 N=280 needs 4–6 weeks minimum. OSF filing must happen this week.**

---

## PART 1 — OSF Amendments to File (Study 1)

All amendments are pre-data, ready to paste. File in the Study 1 OSF pre-registration amendment log. Do them all in one OSF session.

### CRITICAL: JA-O — Amendment 5 (CS/SE student screener)

**Text to paste:**

> "Exclusion criteria amendment (pre-data, pre-OSF): The Prolific screener SC2, as deployed, extends the professional exclusion to CS/SE students — participants who self-report as 'Student in computer science or software engineering' are excluded in addition to software engineering professionals. The pre-reg §3 lists only the professional criterion. The student-extension uses the same domain-expert contamination rationale as the professional exclusion (CS/SE students have technical exposure that could systematically elevate comprehension scores). This was made before pilot launch and is documented in the instrument §SC2. §4.2 of the paper accurately describes the deployed screener criteria. This amendment documents the student extension as a Type I minor deviation (pre-data, pre-collection, same rationale as the registered professional exclusion; pre-reg §7.1)."

**After filing:** Run `scripts/apply-o.py --apply` → removes inline `[JONY-ACTION O]` marker from §4.2 → `git commit -m "fix §4.2: JA-O resolved — Amendment 5 filed"`

---

### CRITICAL: JA-T — Amendments 12, 13, 14

**Amendment 12 — Q5 wording (4 deviations):**

> "Item Q5 wording deviates from pre-reg §5.2 on four points: (1) prefix 'In your own words:' added; (2) 'the system' → 'this voting system'; (3) 'NOT' emphasised (HTML bold); (4) 'how you voted' → 'which option you voted for'. Correct scoring rubric, binary pass/fail criterion, and MQ1 relationship unchanged. Deviations are minor presentational/clarification edits; no hypothesis, DV, or analysis plan change."

**Amendment 13 — MQ1 rubric (two-dimensional additive):**

> "MQ1 scoring rubric clarification: the operative rubric is the two-dimensional additive scheme in instrument §11 (1 point for inclusion-correct response + 1 point for non-leakage response = max 2; scale 0–2). The pre-reg §5.3 text 'score the quality of their understanding as 0, 1, or 2' is consistent with this scheme but ambiguous for responses that address only one dimension. The instrument §11 rubric is the complete specification."

**Amendment 14 — Attention check descriptions (two corrections):**

> "Two attention check corrections to pre-reg §3: (1) AC1 (embedded Likert: 'To show you're paying attention, please select Strongly Disagree') — the correct response is 'Strongly Disagree', not 'Strongly Agree' as described in pre-reg §3. (2) AC2 (list selection: 'Please select the third item in this list: Apple, Banana, Carrot, Dog') — the correct answer is 'Carrot' (third item), not 'a fruit' as described in pre-reg §3. The deployed attention checks are correctly designed; the pre-reg descriptions contained errors. No participant was penalised based on the incorrect pre-reg descriptions."

**After filing Amendments 12+13+14:** Run `scripts/apply-t.py --apply` → removes inline `[JONY-ACTION T]` from §4.2 + §4.3 → `git commit -m "fix §§4.2-4.3: JA-T resolved — Amendments 12+13+14 filed"`

---

### OTHER AMENDMENTS (file in same OSF session — all pre-data)

These were already documented in `docs/osf-amendment-filing-2026-06-24.md`. The full paste-ready text is there. Summary:

| Amd | What | Script re-upload? |
|-----|------|------------------|
| 6 | Q1 '[LABEL]' substitution ('Does this value' → 'Does having this [LABEL]') | No |
| 7 | Q2 '[LABEL]' substitution | No |
| 8 | MQ1 '[LABEL]' substitution | No |
| 9 | TOST `lower.tail` bug fix in analysis script | Yes — re-upload `piup-study1-analysis.R` |
| 10 | TOSTER package removal (base R used instead) | Yes — re-upload analysis.R |
| 11 | `multcomp` removal + `dunn.test` addition | No — script already correct |
| 15 | H2 reversed-verdict uses `p_two_tailed` not `p_one_tailed` | Yes — re-upload analysis.R |
| 16 | BI1 scale direction corrected in §4.4 (text only) | No |
| 17 | SC1 wording + SC2 scope ('cryptography' removed) | No |
| 18 | H4 ANOVA gate bug fix; H4-null + H4-partial verdict branches added | Yes — re-upload analysis.R |

**Re-uploads needed:** Amendments 9, 10, 15, 18 each require re-uploading `piup-study1-analysis.R`. Do these last; upload the final corrected script once.

---

### Amendment 19 — Q3 wording (pre-data)

> "Amendment 19 — Q3 stem wording (pre-data): Instrument §6/Q3 has 4 wording deviations from pre-reg §5.2: (a) 'a coercive employer' → 'your employer'; (b) 'send them a screenshot' → 'show them this screen'; (c) 'could they learn how you voted?' → 'could they tell which voting option you chose?'; (d) '[LABEL]' added to question stem. Correct answer (No), binary scoring, H1/H2-secondary assignment unchanged. Parallel to Amendments 6, 7, 8, 12. Q4 note: instrument Q4 correct answer wording changed from 'proof that the receipt is yours' to 'this [LABEL] as personal proof'; correct answer category unchanged. No hypothesis, alpha level, or primary analysis change."

**Source:** `docs/piup-study1-crosscheck-2026-07-01.md` Gap 1.

---

### Amendment 19b — Stimuli scope-limiting clarification (pre-data)

> "Amendment 19b — Stimuli scope-limiting clarification (pre-data): Pre-reg §5.2 states for Q3: 'Clarification appended: Assume they can only see what is on this screen. This wording is in the stimuli.' The four stimulus HTML files did not contain this text at initial registration. Amendment 19b adds: `<p class='study-note' role='note'><strong>Study note:</strong> Assume they can only see what is on this screen.</p>` to each stimulus file (below the receipt card div). Styling keeps the note visually distinct from the receipt UI. No hypothesis, measure, analysis plan, alpha level, or primary DV changed. Brings stimuli into compliance with pre-registered §5.2 Q3 clarification commitment."

**Source:** `docs/piup-study1-decision-d-amendment-19b-draft-2026-07-02.md`  
**Stimuli already updated** in commit `5ac9bd6`. Jony: confirm the study-note appears in the deployed HTML files before launching.

---

## PART 2 — Study 2 Amendment

### Amendment 21 — Analysis script cross-reference fixes (pre-data)

> "Amendment 21 — Analysis script §9 cross-reference corrections (pre-data, pre-OSF): Three comments in `piup-study2-analysis.R` cited pre-registration §9.x subsections that do not exist (§9 has no subsections). Corrections: (1) line 335 'Per pre-registration §9.3' → 'Per design note §9.3 / pre-registration §4.1'; (2) line 646 'per pre-registration §9.1' → 'per design note §9.1 / pre-registration §6.3'; (3) pilot-mode output 'per pre-registration §9' → 'per pre-registration §7.1'. Script footer: added `piup-study2-drycheck.R` to OSF upload reminder. No hypothesis, endpoint, alpha, equivalence bound, or verdict criterion change. Dry-check: PASS (CLEAN, 37/40 N). Commit tick-4305."

**File this when uploading Study 2 pre-registration** (after Study 1 pilot confirms instrument performance). Both scripts (`piup-study2-analysis.R`, `piup-study2-drycheck.R`) must be uploaded to OSF with the Study 2 pre-registration.

---

## PART 3 — Study 3 Decisions Needed

These are needed before filing the Study 3 OSF pre-registration. Studies 3+4 are downstream of Study 1+2 but you can pre-decide these now.

### Decision A — DV3-3 item wording

**Choose one:**
- **Option A (recommended):** *"If you verified your vote in front of another person, could they learn which option you voted for?"*  
  → Tests the coercion scenario Study 3 creates (social-proof counter → public verification pressure). More ecologically valid.
- **Option B (original):** *"If you showed your receipt link to another person, could they learn which option you chose?"*  
  → Acceptable; slightly less ecologically valid for Study 3's coercion scenario.

**Source:** `docs/piup-study3-dv3-specification-2026-07-02.md §2`

---

### Decision B — DV3 scoring rule

**Option A (recommended):** Strict composite — all 4 items must be correct for DV3=1.  
Full scoring text is in `docs/piup-study3-dv3-specification-2026-07-02.md §3`.  
**Recommendation: Option A.** Consistent with Study 1 Q1-Q4 composite and the pre-reg "abbreviated Q1–Q4 rubric" language.

---

### Decision C — M1-3 item wording

**Choose one:**
- **Option A (recommended):** *"I could use the receipt verification link if I had a short step-by-step guide to follow."*  
  → Avoids confounding with in-UI receipt instructions participants have already seen.
- **Option B (original):** *"I could use the receipt verification link if I had brief written instructions available."*  
  → Acceptable; slightly confounded.

**Source:** `docs/piup-study3-m1-item-review-2026-07-02.md §2`

**After you decide A/B/C above:** Agent will update instrument §3.3, remove ⚠️ markers, and write the combined OSF amendment text (DV3 + M1 combined amendment).

---

## PART 4 — CHI Paper Decision

### Decision D — Volkamer 2022 §1.4 insertion

**One sentence, +22 words.** Insert between the list sentence and "Carback et al. (2010)":

> "While subsequent work has extended these findings to varied verifiable voting system designs (Volkamer et al., 2022), the receipt privacy-mental-model problem — the artifact voters retain *after* verification — has not been empirically addressed."

**Bibliography entry to add:**
> `Volkamer, M., Kulyk, O., Ludwig, J., and Fuhrberg, N. (2022). "Increasing Security without Decreasing Usability: A Comparison of Various Verifiable Voting Systems." _Eighteenth Symposium on Usable Privacy and Security (SOUPS 2022)_. USENIX Association. ISBN 978-1-939133-30-4.`

**Effect:** Blocks CHI reviewer objection that the gap claim doesn't hold after 2018. Adds 22 words; word count → ~11,845 (under 12,000 cap).  
**Source:** `docs/chi-paper-citation-proposals-tick-4463-2026-07-02.md §2`

**If yes:** Say so and the agent applies the edit in the next tick.

---

## PART 5 — Aztec Grant + GT/CMU Emails

### Grant submission
1. Testnet is **live** (block 2203 confirmed tick-4473, rollupVersion `2787991301` stable as of tick-4474 09:28 UTC). The RPC endpoint `https://v5.testnet.rpc.aztec-labs.com` is healthy.
2. Redeploy using `docs/v5-upgrade-runbook.md` (needs `DEPLOYER_SECRET_KEY` + `DEPLOYER_SIGNING_KEY` in your local env).
3. Update the contract address in `GRANT.md` before posting.
4. Post to `forum.aztec.network` — the post text is in `docs/forum-post-grant-application.md`.

### GT cold-contact (Annie Antón)
**Email is ready.** The 300-word text is in `docs/gt-hci-cover-letter-draft-2026-06-29.md` → Cold-contact email template section. Send to `aanton@cc.gatech.edu`.  
**Pre-send requirement:** Either (a) upload Study 1 pre-reg to OSF first so you can link the DOI, OR (b) change "pre-registration complete and ready for OSF upload" to "pre-registration document complete, pending OSF upload" in the email body.

### CMU cold-contact (Sauvik Das)
**Email is ready.** Text is in `docs/cmu-hci-research-statement-draft-2026-06-22.md` → Cold-contact email template section. Send to `sauvik@cmu.edu`.  
**Same pre-send requirement as GT.**

---

## What Agent Will Do Without Jony

| Item | Status |
|------|--------|
| Study 3+4 drycheck passes | ✅ Confirmed tick-4465 |
| Study 1+2 analysis scripts | ✅ Pass — no changes needed |
| CHI paper body | ✅ 11,683 words (tick-4467 –140w §7 compression), all sections written |
| Bibliography | ✅ 17/17 entries verified |
| ADR-038 M2 RIPEMD-160 code changes | ⏳ **Jony approval needed** before agent applies |
| Study 3 instrument M1-3 + DV3 update | ⏳ After Jony confirms Decisions A/B/C above |
| CHI paper Volkamer 2022 edit | ⏳ After Jony confirms Decision D |

---

_Created: 2026-07-02 (tick-4465). Supersedes jony-approval-cheatsheet-2026-06-29.md._
