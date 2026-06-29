# JONY Batch Decision Memo — CHI Paper

**Generated:** tick-4148 (2026-06-28) · **Updated:** tick-4160 (2026-06-29 — added BB, DD; noted CC resolved)  
**Purpose:** All 18 active open JONY-ACTIONs consolidated with recommendations. Resolve in one pass.  
**Already applied (no action needed):** CC (Bell et al. 2013 Perez→Pereira fix, commit 98851ad, tick-4155) ✅  
**Blocking CHI submission:** P, Q, R, S, Y, Z, AA (citation precision), U (Study 2 instrument), T (OSF amendments), BB (bibliography)  
**Not submission-blocking (but pre-pilot):** A, B, C, I, O, T, W  
**Confirm design-rationale only:** G  
**Confirm bibliography entry only:** DD (HIGH confidence — just say yes)

---

## PART 1 — Easy confirms (agent already prepared; say YES to all of these)

These have a clear recommended option. Agent can apply all immediately upon Jony's batch YES.

### G — §2.1 N=12 pilot undocumented
**Issue:** Original draft cited 'unpublished pilot study, N=12' for collapsed verification affordance design decision.  
**Three searches** across all repo files found zero documentation of this pilot.  
**Recommended: option (b)** — Design-rationale reframe already in place at §2.1 (tick-3767):  
> "expanding it by default would displace the primary status line downward and compete for initial attention at the confirmation step, where users' primary goal is confirming their ballot was counted rather than auditing it immediately. Collapsed by default, it functions as a second-pass tool without competing with the primary confirmation."  
This is CHI-safe as a first-principles HCI argument. JONY-ACTION G inline block will be removed.  
**Jony action:** Reply "G: option (b)" — or just YES if no pilot exists.

---

### A — Item A: Q3 coercion-scenario phrasing
**Issue:** Pre-reg §5.2 uses 'coercive employer...send screenshot'; instrument uses 'employer wants to verify...show screen + your [LABEL]'.  
**Recommended:** Use instrument wording. Better construct specificity, ecological validity, label integration. File OSF Amendment 4 before pilot.  
**Jony action:** Reply "A: YES to instrument wording + Amendment 4."

---

### B — Item B: Q4 wording and foils
**Issue:** Pre-reg Q4 'lost this value' vs. instrument Q4 'closed screen without saving your [LABEL]'. Instrument foils also cleaner (no duplicate catastrophic distractor).  
**Recommended:** Use instrument wording + foils. File OSF Amendment (Item B).  
**Jony action:** Reply "B: YES to instrument wording."

---

### C — Item C: Q3 baseline clarification
**Issue:** Pre-reg §5.2 includes 'Assume they can only see what is on this screen.' as baseline; §7.2 says add-only-if-confusion. Instrument drops it.  
**Recommended:** Drop the clarification — it hints at the correct answer and is made redundant by the Item A Q3 rewording. File OSF amendment.  
**Jony action:** Reply "C: YES to dropping clarification."

---

### R + S — §2.2 and §2.1 E&S co-citation precision
**Issue (R):** §2.2 Alt3 co-cites E&S for 'absent-content interpretation → failure'. E&S (2013) studied PRESENT phishing warning → threat-model dismissal — categorically different mechanism.  
**Issue (S):** §2.1 co-cites E&S for 'default interpretation: error, incomplete, untrustworthy'. Same mechanism mismatch.  
**Recommended option (a) for both:** Remove E&S from both co-citations, retain W&T alone.  
- §2.2: `[Egelman and Schechter 2013; Whitten and Tygar 1999]` → `[Whitten and Tygar 1999]` + remove 'consistently'  
- §2.1: `[Egelman and Schechter 2013; Whitten and Tygar 1999]` → `[Whitten and Tygar 1999]`  
Full combined resolution memo at `docs/r-s-resolution-memo-2026-06-28.md` (tick-4146, commit 96f3b75).  
**Jony action:** Reply "R+S: option (a) for both."

---

### W — CAL-FEEDBACK Q2 label-conditioned text
**Issue:** Design note §6.2 used label-neutral 'it proves...'; instrument §5 uses condition-specific '[LABEL_NOUN] proves...'. Means I2 participants see the label twice before the receipt (in CAL2 question + CAL-FEEDBACK Q2). For L2 (confirmation code), feedback directly contradicts eCommerce schema — may amplify I calibration effect in L2. H2.3 is pre-specified to L2-only, so this is absorbed.  
**Recommended option (a):** Accept instrument wording as intentional. Label-conditioned feedback is more precise; H2.3 L2-only restriction absorbs the differential. Note in §5.5 H2.3 analysis note before submission.  
**Jony action:** Reply "W: option (a)."

---

## PART 2 — Real choices (agent needs Jony's specific decision)

### P — §6.1 E&S mechanism description
**Issue:** §6.1 describes E&S (2013) as documenting 'behavioral normalization: users attribute unexpected signal to error...proceed as if system confirmed the usual thing.' This is the W&T mechanism. E&S's actual mechanism: bounded rationality / threat-model dismissal — 'warnings did not apply to me.'  
**Option (a) [RECOMMENDED]:** Replace §6.1 E&S description:  
> "Egelman and Schechter (2013) find that even security-aware users dismiss unexpected security feedback when it does not align with their threat model — acting from bounded rationality, they conscientiously bypass it and proceed as if the system had confirmed the usual thing."  
Option (a) text verified clean and precise (tick-4145, commit df81db9). Z(a2) independent ✅.  
**Option (b):** Keep current text. Risk: CHI reviewer who knows E&S will notice mechanism mismatch.  
**Jony action:** Reply "P: option (a)."

---

### Q — §1.1 E&S label 'framework for security warnings'
**Issue:** E&S (2013) is an empirical study of phishing warning compliance — it does NOT propose a framework. 'Framework for security warnings' is inaccurate.  
**Option (a):** 'Egelman and Schechter's **study of security warning compliance** (2013)' — precise description.  
**Option (b) [RECOMMENDED]:** 'Egelman and Schechter's **work on security warnings** (2013)' — matches parallel structure with 'Felt et al.'s *work on Android permissions*'.  
Note: Q is resolved as part of the Z package. If Z option (a2) confirmed, Q is automatically resolved by the mechanism-naming revision (E&S is cited by author+year only, no label needed).  
**Jony action:** Reply "Q: option (a) or (b)" — or just confirm Z option (a2) which resolves Q simultaneously.

---

### T — OSF Amendments 12 + 13 (Q5 wording, MQ1 rubric)
**Issue 1 (Amendment 12):** Q5 wording has 4 deviations from pre-reg §5.2 (prefix, stem wording, emphasis). The deviations are documented in the paper but no OSF amendment covers them. Must be filed before pilot launch, parallel to Amendments 6/7/8.  
**Issue 2 (Amendment 13):** MQ1 two-dimensional rubric in instrument §11 is the operative operationalization but pre-reg §5.3 rubric description is abbreviated and inconsistent for non-leakage-only responses. Amendment 8 log entry needs correction.  
**Recommended draft language:**  
- Amendment 12: "Q5 wording corrected in survey instrument (instrument §6/Q5): added 'In your own words:' prefix; changed 'the system' → 'this voting system'; added emphasis 'NOT'; changed 'your vote choice' → 'which option you voted for'. Scoring rubric (0-2) unchanged. Hypothesis tests unchanged."  
- Amendment 13: "MQ1 scoring rubric clarification: pre-reg §5.3 abbreviated rubric is operationalized by the two-dimensional additive rubric (Dim 1 = Inclusion, Dim 2 = Non-leakage, total = D1+D2) in instrument §11. Non-leakage-only responses score 1. Amendment 8 claim 'scoring construct unchanged' corrected: two-dimensional rubric is the operative operationalization. MQ1 is exploratory; no confirmatory analysis affected."  
**Jony action:** File Amendments 12 + 13 on OSF before pilot launch.

---

### U — VoteReceipt.tsx E2 'unexplained' copy discrepancy
**Issue:** Paper §5.3 + design note §6.1 specify E2 retains generic privacy note 'Your vote is private and verifiable.' But VoteReceipt.tsx (`explanationVariant='unexplained'`) renders 'Your vote choice is not shown on this receipt.' — an absent-choice statement that partially answers Q-AC.  
**If E2 shows 'Your vote choice is not shown on this receipt.'** then Q-AC in E2 conditions is answerable by verbatim reading. This changes what H2.1 tests: instead of 'does explanation improve absent-choice inference vs. no cue?', it tests 'explanation vs. absent-choice acknowledgment without rationale.'  
**Option (a) [RECOMMENDED — spec-faithful]:** Fix VoteReceipt.tsx E2 to render 'Your vote is private and verifiable.' — clean test of explanation vs. no absent-choice cue.  
**Option (b) [implementation-as-spec]:** Update paper §5.3 + design note §6.1 to match current implementation. Requires updating E factor description and H2.1 rationale.  
**Jony action:** Reply "U: option (a) or (b)."

---

### Y — §1.1 KelpDAO opener (3 factual errors)
**Issue:** Current opener: 'When KelpDAO put the loss-socialisation decision from a $71M protocol exploit to a governance vote in 2023...' — three errors:  
1. Date wrong: KelpDAO exploit was April 2026, not 2023  
2. Amount framing wrong: $71M was funds frozen by Arbitrum Security Council, not 'loss socialisation' total  
3. Governance vote structure wrong: it was an ARB governance vote (on frozen ETH), not a KelpDAO vote on loss socialisation  

**Option (a):** Update to accurately describe the April 2026 KelpDAO/Arbitrum event — but note this changes from a DAO loss-socialisation vote to an Arbitrum recovery-fund governance vote. The 'voter addresses public' point still holds, but the framing shifts.  
**Option (b) [RECOMMENDED]:** Replace with Mango Markets Oct 2022. Mango Markets is the canonical example: ~$114M exploit, DAO governance vote where token holders voted on recovering funds with attacker's wallet address public on-chain. Directly matches the paper's loss-socialisation + public address framing. Verified factually accurate (tick-4139, commit 814ae97).  
Proposed opener: *"When Mango Markets put the loss-recovery decision from a $114M protocol exploit to a governance vote in October 2022, every voter's wallet address was public on-chain."*  
**Option (c):** Generalise — remove specific example, use generic 'When a DAO puts a governance decision to a vote...' Risk: loses concrete grounding that CHI reviewers expect.  
**Jony action:** Reply "Y: option (a), (b), or (c)" — agent strongly recommends (b).

---

## PART 3 — Z/AA/Q package (one decision resolves three)

### Z + AA + Q — §1.1 historical trio 'consistent finding' claim
**Issue:** The §1.1 sentence claims W&T (1999) + Felt et al. (2012) + E&S (2013) share a 'consistent finding: users interpret interface absence as system error.' This is wrong for two of the three:  
- **Z:** Felt et al. studied PRESENT Android permission warnings → low attention/comprehension, not absence-as-error  
- **AA:** E&S studied PRESENT phishing warnings → threat-model dismissal, not absence-as-error  
Only W&T (1999) directly supports the 'absence as error' mechanism.  

**Option (a2) [RECOMMENDED — resolves Z, AA, and Q simultaneously]:**  
Replace the §1.1 sentence with mechanism-specific framing:  
> "Usability-security research documents multiple failure modes when users encounter unexpected security interface states: inferring system failure from absent confirmation [Whitten and Tygar 1999], ignoring present permission warnings [Felt et al. 2012], and dismissing warnings as inapplicable [Egelman and Schechter 2013]. In the receipt context, the operative failure mode is the first."  
Then add: "A receipt that shows no vote choice, without explanation, will be read as: 'the system didn't record my vote,' 'the vote failed,' or 'this is a bug.'"  
This is accurate for all three citations, removes the false 'consistent finding' claim, preserves all three citations, and makes the paper's argument more precise (it explicitly identifies which failure mode is relevant for receipts).  
Full resolution memo at `docs/z-aa-q-resolution-memo-2026-06-28.md` (tick-4144, commit 9155f73).

**Option (a1):** Find a new third citation that actually documents absence-as-error (e.g., Sunshine et al. 2009 'Crying Wolf'). Replace Felt et al. with the new citation. E&S issue still needs separate fix.  
**Option (b) for Z:** Drop Felt et al. entirely from the §1.1 trio. W&T alone cleanly supports the claim. Then need separate fix for AA.  

**Jony action:** Reply "Z: option (a2)" — this closes Z, AA, and Q in one edit.

---

## PART 4 — OSF upload actions (only Jony can do)

| Item | Action needed |
|------|---------------|
| O | File Amendment 5 (CS/SE screener extension) on OSF |
| A | File Amendment 4 (Q3 wording) on OSF |
| B | File Amendment (Q4 wording) on OSF |
| C | File Amendment (Q3 baseline clarification removed) on OSF |
| T | File Amendments 12+13 (Q5 wording, MQ1 rubric) on OSF |
| I | After confirming A/B/C: remove JONY-ACTION I block from §4.2 |

---

---

## PART 5 — New bibliography items (found in bibliography passes 5-8, tick-4154 to tick-4158)

### CC — Bell et al. (2013) 'Perez, O.' → 'Pereira, O.' ✅ ALREADY APPLIED

**Status:** RESOLVED. Fix applied autonomously tick-4155, commit 98851ad. Verified against USENIX archived page (Wayback Machine snapshot 2024-12-05).  
**No Jony action needed.** Author is Olivier Pereira (UCLouvain) — a different person from any 'Perez'. In-text citations say 'Bell et al. (2013)' — first author Bell is correct, no in-text change needed. This item has been removed from the active action list.

---

### DD — Adida et al. (2009) author list — CONFIRM CURRENT ENTRY (HIGH CONFIDENCE)

**Current bibliography:** `Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). 'Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios.' EVT/WOTE 2009.`  
**Issue:** USENIX current BibTeX snippet lists only 3 authors (de Marneffe, Pereira, Quisquater — no Adida). Conflict with multiple other sources.

**Evidence gathered (tick-4156 to tick-4158):**

| Source | Authors | First author | Verdict |
|--------|---------|--------------|--------|
| USENIX legacy URL (`adida.pdf`) | 4 (implied by naming convention) | Adida | ✅ supports current entry |
| Caltech Election Updates blog (2009-08-12) | 4 (Adida, de Marneffe, Pereira, Quisquater) explicit | Adida | ✅ supports current entry |
| Springer book citation | 4 (Adida, de Marneffe, Pereira, Quisquater) | Adida | ✅ supports current entry |
| USENIX current BibTeX (snippet) | 3 (de Marneffe, Pereira, Quisquater) | de Marneffe | ❌ outlier — contradicts its own URL |

**Assessment:** 3 sources confirm 4-author Adida-first. The USENIX BibTeX (3-author) is the outlier, likely a database entry error — it contradicts USENIX's own URL naming convention. **CONFIDENCE: HIGH for current entry.**

**Option (a) [RECOMMENDED — HIGH CONFIDENCE]:** Confirm current bibliography entry as correct. In-text 'Adida et al. (2009)' citations are correct. No paper change required; agent removes JONY-ACTION DD note block.

**Option (b):** Jony supplies or checks the paper PDF title page to verify definitively.

**Jony action:** Reply **"DD: option (a)"** to confirm current entry is correct and close the action.

---

### BB — Chaum et al. (2010) author list — ERROR CONFIRMED, CHOICE REQUIRED

**Current bibliography:** `Chaum, D., Essex, A., Clark, J., Carback, R., Popoveniuc, S., Lundin, D., Vora, P., Sherman, A., and Voutier, P. (2010). 'Scantegrity II: End-to-end verifiability by voters of optical scan elections through confirmation codes.' IEEE TIFS.`

**Issue (tick-4154):** This is a **10-author list with Chaum first**. DBLP (`conf/eVote/CarbackCSCLVSVP10`) for the EVT/WOTE 2009 deployment paper lists **12 authors, Carback first**:

> Richard Carback, David Chaum, Jeremy Clark, John Conway, Aleksander Essex, Phill Herrnson, Travis Mayberry, Stefan Popoveniuc, Ronald L. Rivest, Emily Shen, Alan T. Sherman, Poorvi L. Vora

**Discrepancies:**
- 10 vs. 12 authors (2 missing: John Conway, Travis Mayberry; 1 spurious: Voutier; Phill Herrnson also missing from current entry)
- First author: current entry Chaum-first vs. DBLP Carback-first
- Venue: DBLP is EVT/WOTE 2009 (conference); current entry cites 'IEEE TIFS' (journal) — these may be different publications

**Important note on venue:** 'IEEE TIFS' = IEEE Transactions on Information Forensics and Security. There IS a journal version of Scantegrity II published in IEEE TIFS. The DBLP entry is specifically the conference paper (EVT/WOTE 2009). The current bibliography may be citing the journal version (IEEE TIFS) which can have different authors/ordering from the conference version. The in-text uses 'Chaum et al. (2010)' which may be correct for the journal version.

**Options:**

**Option (a) [if citing conference paper]:** Correct to DBLP 12-author Carback-first list (EVT/WOTE 2009). Change venue to 'EVT/WOTE 2009'. Change in-text 'Chaum et al.' → 'Carback et al.'. This is a significant in-text citation change affecting all occurrences of 'Chaum et al. (2010)' in the paper.

**Option (b) [if citing journal version]:** Verify the IEEE TIFS version of Scantegrity II (Chaum et al., IEEE TIFS 2010). If the journal version has Chaum as first author with the 10-author list in the current bibliography, the current entry may be correct for the journal version. Locate the IEEE TIFS paper (DOI: 10.1109/TIFS.2009.2038144 or similar) to confirm.

**Option (c) [practical resolution]:** The paper currently describes 'Chaum et al.'s (2010) deployment of Scantegrity II in Takoma Park, the first binding governmental election...' (§1.4). This description matches the 2009 Takoma Park deployment, which is documented in the conference paper (EVT/WOTE 2009 / 2010 publication = the proceedings year). If the year '2010' in the bibliography refers to the proceedings year of the conference paper, the DBLP 12-author Carback-first entry is the correct citation and option (a) is correct.

**Recommendation:** Check whether your citation note/Zotero/saved PDF identifies this as the conference paper (EVT/WOTE) or the journal article (IEEE TIFS). If EVT/WOTE → option (a). If IEEE TIFS → verify the IEEE TIFS author list and update the bibliography accordingly.

**Jony action:** Reply **"BB: option (a) [conference paper]"** or **"BB: option (b) [journal version — will verify IEEE TIFS]"**.

---

## Summary table (updated tick-4160)

| # | Action | Recommendation | What agent does after confirm |
|---|--------|---------------|------------------------------|
| CC | **ALREADY APPLIED** — Perez→Pereira (commit 98851ad) | No action ✅ | Already done |
| DD | Confirm current 4-author Adida-first entry | **"DD: option (a)"** | Remove [JONY-ACTION DD] note block from bibliography |
| BB | Chaum (2010) conf vs. journal — resolve venue | Pick (a) or (b) after checking source | Update bibliography; if (a): update in-text 'Chaum et al.' → 'Carback et al.' |
| G | Confirm option (b) — design reframe CHI-safe | **YES** | Remove [JONY-ACTION G] block from paper |
| A | Item A: Q3 instrument wording | **YES** | Update §4.4 Q3 note; draft Amendment 4 |
| B | Item B: Q4 instrument wording | **YES** | Update §4.4 Q4 note |
| C | Item C: Drop Q3 baseline clarification | **YES** | Update pilot decisions doc |
| R+S | Remove E&S from §2.2+§2.1 co-citations | **YES** | Apply edits to paper |
| W | Accept label-conditioned CAL-FEEDBACK | **YES** | Add §5.5 H2.3 design note |
| P | §6.1 E&S → threat-model dismissal wording | option (a) ready | Apply option (a) edit to §6.1 |
| Q | §1.1 E&S 'framework' label | option (a) or (b) | Apply edit; or resolved by Z(a2) |
| T | File Amendments 12+13+14 on OSF | Jony OSF upload | — |
| U | E2 copy: fix impl. (a) or update spec (b) | option (a) recommended | Fix VoteReceipt.tsx or update spec |
| Y | §1.1 opener: Mango Markets 2022 replacement | option (b) recommended | Apply opener edit to paper |
| Z+AA | §1.1 trio: rename mechanisms | option (a2) recommended | Apply sentence replacement to §1.1 |
| I | Items A/B/C OSF amendments + §4.2 block | After A/B/C confirmed | Remove [JONY-ACTION I] block |
| O | CS/SE Amendment 5 | Jony OSF upload | — |

**After Jony confirms the easy batch (G, A, B, C, R, S, W, DD) + recommendations (P, Y, Z(a2), BB(a)):**  
Open JONY-ACTIONs drop from 18 → 4 (I, O, T — OSF uploads only; U — choice needed).  
_T now includes Amendment 14 (attention check descriptions; tick-4150) in addition to Amendments 12+13._
