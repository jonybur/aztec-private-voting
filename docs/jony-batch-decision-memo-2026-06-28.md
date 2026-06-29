# JONY Batch Decision Memo — CHI Paper

**Generated:** tick-4148 (2026-06-28) · **Updated:** tick-4211 (2026-06-29 — added GG, HH, II, JJ; updated to 24 active actions)  
**Purpose:** All 20 active open JONY-ACTIONs consolidated with recommendations. Resolve in one pass.  
**Already applied (no action needed):** CC (Bell et al. 2013 Perez→Pereira fix, commit 98851ad, tick-4155) ✅  
**Blocking CHI submission:** P, Q, R, S, Y, Z, AA (citation precision), U (Study 2 instrument), T (OSF amendments), BB (bibliography)  
**Not submission-blocking (but pre-pilot):** A, B, C, I, O, T, W  
**Study 2 instrument conflicts (pre-pilot blocking):** EE (TC2 construct conflict), FF (calibration_confidence scope)  
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

---

## PART 6 — Study 2 instrument conflicts (pre-pilot blocking; found tick-4163)

These arose from the Study 2 Qualtrics setup guide divergence audit (tick-4163). The survey instrument (piup-study2-survey-instrument-2026-06-28.md) is the authoritative pre-registered document. Both conflicts involve the guide and instrument specifying different psychological constructs — not agent-resolvable.

---

### EE — TC2 construct conflict (security vs. comprehension)

**Item:** Trust/confidence scale item TC2 in the Study 2 Qualtrics setup guide vs. survey instrument.

**Guide (pre-fix):** 'I believe the voting system that produced this receipt is **secure**.' → *security belief construct*  
**Instrument §9 TC2:** 'I **understand** what this receipt is for.' → *comprehension construct*

These are entirely different psychological constructs measuring different things. The divergence audit (tick-4163) applied the instrument wording to the guide provisionally (commit df4e112) and flagged for Jony confirmation.

**Option (a) [instrument — confirmed current]:** 'I understand what this receipt is for.' (comprehension). Agent removes [JONY-ACTION EE] flag from guide.  
**Option (b) [guide was correct]:** 'I believe the voting system that produced this receipt is secure.' (security belief). Agent reverts guide TC2 AND updates instrument §9 to match.

**Implication if (a):** TC2 is a comprehension check, not a trust/security item. Consider whether the scale label 'TC' (Trust/Confidence) should be renamed or whether TC2 is intentionally a comprehension anchor in the trust battery.  
**Implication if (b):** Instrument §9 requires amendment before pre-registration submission.

**Jony action:** Reply **"EE: option (a)"** (instrument comprehension wording) or **"EE: option (b)"** (guide security wording — agent also updates instrument §9).

---

### FF — calibration_confidence scope and construct conflict

**Item:** Post-CAL confidence item in the Study 2 Qualtrics setup guide vs. survey instrument.

**Guide version (all conditions, N=240):**  
Item: 'How confident are you in your answer above?' (Q-AC confidence — collected after Q-AC for ALL N=240 participants)  
Variable: `calibration_confidence`

**Instrument §11 version (I2 conditions only, N=120):**  
Item: 'Before you saw the receipt, we asked you two quick questions. Looking back at your answers: how confident were you that they were correct at the time?' (retrospective CAL-probe confidence — I2 conditions only as measure M4)

These measure different constructs at different points in the study and for different subsets:
- Guide: *current* confidence in Q-AC answer, all conditions (post-receipt)
- Instrument: *retrospective* confidence in the CAL-probe answers, I2 only (pre-receipt recall)

The variable name `calibration_confidence` in the guide refers to Q-AC post-receipt confidence. In the instrument it refers to retrospective pre-receipt CAL-probe confidence. This is a substantive design conflict — both cannot be correct simultaneously.

**Option (a) [instrument — I2 only, retrospective]:** Use instrument §11 version: retrospective confidence in CAL probes, collected only in I2 conditions (N=120). This means `calibration_confidence` drops to n=120 and measures calibration accuracy retrospection. Agent updates guide to explicitly scope to I2 and rephrase as retrospective.  
**Option (b) [guide — all conditions, Q-AC]:** Use guide version: post-receipt Q-AC confidence, all N=240. Agent updates instrument §11 to match — changes M4 from retrospective CAL confidence to current Q-AC confidence, changes from I2-only to all conditions.

**Implication if (a):** calibration_confidence (M4) becomes a secondary endpoint for the I2 calibration manipulation only. Sample size n=120. Hypothesis links: if H2.3 is also I2-only, this is consistent.  
**Implication if (b):** calibration_confidence (M4) becomes a general post-receipt confidence measure across all N=240. May need to add to OSF pre-registration if not already covered.

**Jony action:** Reply **"FF: option (a)"** (instrument I2-only retrospective) or **"FF: option (b)"** (guide all-conditions Q-AC).

---

## PART 7 — New actions since tick-4164 (GG, HH, II, JJ)

These four actions were opened between ticks 4168 and 4201 and were not in the tick-4164 batch memo.

---

### JJ — Cover letter ¶2 "Coercion resistance" overclaim

**File:** `docs/gt-hci-cover-letter-draft-2026-06-29.md` ¶2  
**Severity:** HIGH — factual overclaim contradicting §3.3 L2 and §6.5 L2  
**Annie Antón risk: HIGH** — she is a formal privacy-specification researcher who will notice  
**Blocking:** Do NOT send cover letter or cold-contact email to Antón until ¶2 is fixed

**Error:**
> Cover letter ¶2: "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **coercion resistance** simultaneously."

**Correct (research statement ¶1):**
> "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **double-vote prevention** simultaneously."

**Why wrong:** The contract does not implement a re-encryption mix. A voter who shares their `receipt_id` with a coercer allows reconstruction of vote choice from `record_vote` calldata. "Coercion-resistant" is explicitly withheld from user-facing copy (§3.3 L2; §6.5; VoteReceipt.tsx). The cover letter appears to have been drafted independently of the paper's final §3.3 L2 commitment.

**Option (a) [RECOMMENDED — simple fix]:** Replace `"coercion resistance"` with `"double-vote prevention"` — exact match to research statement ¶1. Agent also searches cover letter file for any other "coercion resistance" occurrences.  
**Option (b):** More informative: "…double-vote prevention simultaneously — but they cannot, alone, guarantee that a voter cannot voluntarily prove how they voted."  
**Option (c):** Drop the three-property list: "zero-knowledge proofs handle the cryptographic half: ballot secrecy and individual verifiability without a central authority."

**Jony action:** Reply **"JJ: option (a)"** — this is the easy fix and matches the research statement exactly.

Full proposal: `docs/chi-cover-letter-coercion-resistance-proposal-tick-4201.md`

---

### HH — §6.5 L2 receipt-freeness paragraph absent

**File:** `drafts/piup-chi-paper-draft-2026-06-22.md` §6.5  
**CHI risk:** MODERATE  
**Context:** §3.3 documents two design limitations — L1 (calldata exposure) and L2 (partial receipt-freeness, no re-encryption mix). §6.5 has a full "Protocol-layer exposure" entry for L1 but **no entry for L2**. A CHI reviewer familiar with e-voting receipt-freeness literature (Juels et al. 2005; Carback et al. 2010) may look for L2 in §6.5 and not find it.

**Proposed paragraph** (insertion after "Protocol-layer exposure"):
> **Partial receipt-freeness.** Receipt-freeness requires that a voter be unable to prove to a third party how they voted, even voluntarily (Juels et al. 2005). The current Aztec Private Voting instantiation does not achieve full receipt-freeness: a voter who shares their fingerprint identifier with a coercer provides a direct handle for that coercer to reconstruct the voter's choice from the on-chain `record_vote` calldata (§3.3, L1 privacy gap), because the `receipt_id → vote_choice` map is publicly constructible from calldata alone. Full receipt-freeness requires a protocol mechanism that severs the link between a voter's identifier and their recorded choice — such as a re-encryption mix — which the contract does not implement (§3.3, L2). PIUP addresses the coercion surface at the receipt-content layer (Invariant 3) and at the UX layer, but these do not prevent a voter from voluntarily producing verifiable coercion evidence by sharing their fingerprint. The term "coercion-resistant" is withheld from user-facing copy in `VoteReceipt.tsx` until a re-encryption mix is implemented. This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference, not receipt-freeness or threat-model comprehension.

**Also requires:** New bibliography entry for Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic elections." WPES '05, pp. 61-70. ACM. DOI: 10.1145/1102199.1102213. (Authors + year confirmed DBLP tick-4198; **pages pp. 61-70 + DOI CONFIRMED DBLP + Semantic Scholar tick-4212**. All fields verified. Ready to apply.)

**Option (a) [RECOMMENDED]:** Apply paragraph + add Juels et al. bibliography entry (pp. 61-70 + DOI fully verified tick-4212, ready to apply).  
**Option (b):** Apply paragraph without Juels citation (remove the inline reference).  
**Option (c) [Reject]:** §3.3's terse L2 note is sufficient; accept CHI risk MODERATE.

**Jony action:** Reply **"HH: option (a)"** (or b or c).

Full proposal: `docs/chi-paper-65-l2-receipt-freeness-proposal-tick-4198.md`

---

### II — §6.5 Study 2 ecological validity paragraph absent

**File:** `drafts/piup-chi-paper-draft-2026-06-22.md` §6.5  
**CHI risk:** LOW-MODERATE  
**Context:** §6.5 has three paragraphs dedicated to Study 1 (EV, label-substitution contingency, Q1 demand characteristic) but only one paragraph for Study 2 (demand characteristics only), which makes a single passing mention of ecological validity without enumerating remaining bounds.

**Four unaddressed Study 2 EV bounds:**
1. Consequentially inert vote choice (no real stake in the DAO scenario).
2. Prolific sample bound (US-based English-speaking online workers — same as Study 1 but unstated for Study 2).
3. Immediate post-vote measurement only — delayed-verification interaction pattern (revisiting receipt days/weeks later) is untested; most relevant to H2.4 (save intention).
4. H2.3 underpowering cross-reference (power ≈ 0.72 at d = 0.50, L2 n = 60; documented §5.5 but not §6.5).

**Option (a) [RECOMMENDED]:** Insert a full Study 2 ecological validity paragraph (full proposed text in `docs/chi-paper-65-study2-ev-proposal-tick-4200.md`). H2.3 cross-reference absorbed into this paragraph.  
**Option (b):** Apply the Study 2 EV paragraph but drop the H2.3 sentence (it's in §5.5 already).  
**Option (c) [Reject]:** Asymmetric §6.5 treatment acceptable; accept CHI risk LOW-MODERATE.

**Jony action:** Reply **"II: option (a)"** (or b or c).

Full proposal: `docs/chi-paper-65-study2-ev-proposal-tick-4200.md`

---

### GG — Study 2 Qualtrics guide SC3 vs DM4 structural conflict

**File:** `docs/qualtrics-setup-guide-study2-2026-06-28.md`  
**CHI risk:** N/A (internal study protocol)  
**Pre-reg impact:** Structural — the pre-registered instrument does NOT have SC3

**Conflict 1 — SC3 screener vs DM4 post-hoc:**  
The guide adds an SC3 screener question ("Have you participated in any previous sessions of this study?") to screen out prior-study participants during data collection. The pre-registered instrument has NO SC3 — it uses DM4 (demographics) to capture this group and excludes them post-hoc in R, with the Prolific "Previous Studies" filter as primary defence.

- **Option (a):** Remove SC3 from the guide. Use instrument DM4 post-hoc approach (no OSF amendment needed).
- **Option (b):** Keep SC3 in the guide. Log it as a protocol deviation and file an OSF amendment before registration.

**Conflict 2 — DM3 wording (three sub-issues):**  
DM3 asks about prior experience with voting systems.
- (i) Time window: guide says "past 12 months" vs. instrument §14 DM4 says "past 6 months".
- (ii) Question text: guide says "voting interfaces" vs. instrument says "voting receipts, voting confirmations, or post-vote screens".
- (iii) "(follow-up to screener question)" note in guide is only valid if SC3 exists — if SC3 is removed per option (a), this note must also be removed and phrasing revised.

**Jony action:** Reply **"GG: option (a)"** (remove SC3, use DM4 post-hoc) or **"GG: option (b)"** (keep SC3, file amendment). Agent resolves all three DM3 sub-issues in line with the chosen option.

---

## Summary table (updated tick-4211)

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
| EE | TC2 construct: comprehension (a) vs security (b) | Need Jony's choice | Apply instrument or guide wording; update counterpart if (b) |
| FF | calibration_confidence: I2 retrospective (a) vs all-N Q-AC (b) | Need Jony's choice | Update guide or instrument; scope change affects M4 sample size |
| JJ | Cover letter ¶2 "coercion resistance" → "double-vote prevention" | **"JJ: option (a)"** | One-word replace in cover letter; search for other occurrences |
| HH | §6.5 L2 receipt-freeness paragraph absent | option (a) recommended | Apply paragraph + add Juels et al. (2005) bib entry (verify pp.) |
| II | §6.5 Study 2 EV paragraph absent (4 bounds not noted) | option (a) recommended | Insert Study 2 EV paragraph after Study 2 demand characteristics |
| GG | SC3 vs DM4 structural conflict + DM3 wording (3 sub-issues) | Need Jony's choice | Remove SC3 or file OSF amendment; fix DM3 in line with chosen option |

**After Jony confirms the easy batch (G, A, B, C, R, S, W, DD, JJ) + recommendations (P, Y, Z(a2), BB(a), HH(a), II(a)):**  
Open JONY-ACTIONs drop from 24 → 6 (I, O, T — OSF uploads only; U, EE, FF, GG — choices needed).  
_T now includes Amendment 14 (attention check descriptions; tick-4150) in addition to Amendments 12+13._
