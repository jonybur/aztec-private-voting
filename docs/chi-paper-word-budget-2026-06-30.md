# CHI 2027 Paper — Word Budget Editorial Memo
**Date:** 2026-06-30 (tick-4273)  
**Deadline:** September 10, 2026 (72 days)  
**Status:** URGENT — body text exceeds 12,000-word desk-rejection threshold


## Progress log

| Tick | Action | Word saving |
|---|---|---|
| tick-4273 | §6.5 Limitations: 1,807 → 594 words (draft ready to paste) | ~1,213 |
| tick-4274 | §4.4 Measures: converted to table format, annotations archived | ~499 (stripped) |
| tick-4275 | §4.5 Analysis plan: 1,096 → 670 words compressed | ~420 |
| tick-4276 | §1.1 Named Limitation: 198 → 65 words; §1.4 Related Work: 191 → 82 words | ~242 |
| tick-4277 | Abstract swapped to 152-word version (step 1 complete) | ~357 |
| tick-4309 | §1.2 Naming: 461 → 155 words; §1.3 Contributions: 150 → 90 words (prose merge) | ~366 |
| tick-4277–4279 | §6.1: ~707→~398; §6.2: ~913→~493; §6.3: ~648→~350; §6.4: ~936→~549 (all done — heartbeat state was stale) | ~1,414 |
| tick-4311 | §2.1 Formal specification: 536 → 421 words (saved 115; target ~400) | ~115 |
| tick-4310 | §1.1 PIUP pattern: 464 → 318 words (full invariant text moved to §2.1 cross-ref) | ~146 |

**Running total saved (clean text): ~5,138 words of estimated ~6,808 needed.**  
**§1 status: 1,379 → ~1,233 clean words (target 1,200; ~33 still to cut from §1.2 Notes/§1.4).**  
**§6.1–6.4 status: DONE (ticks 4277–4279; were already at/below targets when audited tick-4310).**  
**Next up: §2.1 Formal specification (525 → 400, −125); §3 trim (469 remaining); §5 Study 2 (−535).** Commit pending.

---
---

## Current state

| Section | Clean words (annotations stripped) | Target | Cut needed |
|---|---|---|---|
| Abstract | 509 (short draft: 152 exists) | 150 | −357 |
| §1 Introduction | 1,952 | 1,200 | −752 |
| §2 PIUP Pattern | 1,243 | 1,000 | −243 |
| §3 System | 1,669 | 1,200 | −469 |
| §4 Study 1 | 3,994 | 2,200 | −1,794 |
| §5 Study 2 | 1,935 | 1,400 | −535 |
| §6 Discussion | 4,976 | 2,500 | −2,476 |
| §7 Conclusion | 680 | 500 | −180 |
| **TOTAL** | **16,958** | **10,150** | **−6,808** |

CHI 2027: 8,000–8,000 words encouraged; 12,000 hard cap; desk-rejection above 12,000.  
Target: ≤ 10,500 (leaves 1,500-word buffer for results §4.6 fill-in before submission).

---

## Critical path note

**OSF amendments O+T are the blocker for Study 1 data collection.**  
If Jony files O+T on July 1: pilot July 1–14 → full study July 14–August 11 → analysis August 11–25 → paper cut + writing August 25–September 8 → submit September 10.  
Every week of delay on O+T reduces buffer. **O+T must be filed this week.**

---

## Section-by-section cutting plan

### Abstract (−357 words)
**Action: SWAP.** A 152-word trimmed version is already drafted (in the paper file after the long abstract, marked `[FORMATTING-TRIM - tick-3796]`). All claims preserved. This is a 5-second edit.

---

### §1 Introduction (−752 words, 1,952 → 1,200)

The intro has three sources of bloat:

**A. §1.4 Related Work paragraph (~400 words):** Too detailed for an intro subsection — CHI intros cite prior work in 2–3 sentences, not mini-reviews. Cut the per-paper descriptions of MACI/Shutter/NounsDAO/Helios to 1 sentence each ("Prior private voting systems — including MACI, Shutter, and the NounsDAO experiment — ignore the receipt layer entirely"). Move deeper comparative analysis to §6.

**B. §1.1 Named Limitation paragraph (~200 words):** This disclosure is important but can be 3 sentences in the intro ("The current Aztec Private Voting implementation has a named limitation: vote choice appears in `record_vote` public calldata. M3 resolves this at the application layer; PIUP does not provide calldata protection and makes no claim to. See §6.5."). The full disclosure already exists at §3.3 and §6.5.

**C. §1.2 / §1.3 contributions list (~150 words over):** Merge C1–C4 into one compact paragraph rather than a bulleted list. CHI reviewers prefer prose contributions.

---

### §2 PIUP Pattern (−243 words, 1,243 → 1,000)

**A. Feedback inversion paragraph:** Currently restates Norman (1988) at length. 2 sentences max.  
**B. Invariant 2 (transit):** Has an extended "why this matters" explanation; cut to the invariant statement + one example.

---

### §3 System: Aztec Private Voting (−469 words, 1,669 → 1,200)

**A. Table of components:** The component descriptions (§3.4) repeat what the code comments already say. Keep only `<VoteReceipt />` in detail (it's the research contribution). 1 sentence each for the other 4 components.  
**B. §3.5 M2 ownership proof:** Currently 200+ words. For CHI, this is a named extension — 2 sentences: "M2 adds in-circuit secp256k1 signature verification via EIP-191 personal_sign, closing the pre-computation attack surface (ADR-036). 339 ACIR + 348 Brillig opcodes; 7/7 Noir tests pass."

---

### §4 Study 1 (−1,794 words, 3,994 → 2,200)

This section is the most over-written. It was developed as a research-group working document, not a submission draft.

**A. §4.4 Measures (1,496 → 500 words):** Convert to a table:

| Item | Wording (abbreviated) | Correct answer | Family |
|---|---|---|---|
| Q1 Inclusion | "Does having your [LABEL] prove your vote was counted?" | Yes | H1/H3 |
| Q2 Choice-blindness | "Does having your [LABEL] prove which option you chose?" | No | H1/H2 (primary) |
| Q3 Coercion scenario | "If you showed an employer your [LABEL], could they tell how you voted?" | No | H1/H2 |
| Q4 Receipt loss | "If you closed without saving, what would happen?" | Vote survives; [LABEL] is personal proof | — |
| Q5 Open-ended | "Why might the system NOT show you which option you voted for?" | Scored 0–2; rubric in §SI | — |
| MQ1 Mental model | "What does your [LABEL] prove about your vote?" | Scored 0–2; additive 2D rubric | — |
| BI1 Save intent | "How likely would you be to save this code?" | 5-point; descriptive only | — |
| Confidence | Post-Q1-Q4 rating (1–7) | N/A | H4 |

Full wording, scoring rubric, and amendment history: supplementary instrument (OSF).

The 1,496-word expansion (exact question text, wording deviations, amendment cross-references) is correct and necessary as an OSF archive document — but belongs in supplementary materials, not the CHI body. The CHI reviewer wants to understand what was measured, not audit every wording decision.

**B. §4.5 Analysis plan (1,096 → 700 words):** The Holm table is excellent — keep it. The per-hypothesis paragraphs are too long:
- H1: cut to 3 sentences (endpoint, test, directional magnitude)
- H2: cut to 5 sentences (primary endpoint Q2, secondary Q3, TOST equivalence, bounds, outcome classification in 1 sentence each)
- H3: cut to 3 sentences
- H4: cut to 3 sentences
- Q5/MQ1: 2 sentences each

The multi-paragraph outcome classifications (supported/null/reversed/inconclusive for H2; supported/null/partial for H4) can be collapsed to: "Outcome classification follows the pre-registration decision table (OSF); see §6.2 for the H2 production implications."

**C. §4.6 Results:** Currently a 2-line placeholder. When results arrive, this will expand. Target: 500–700 words for results + 1 figure.

---

### §5 Study 2 (−535 words, 1,935 → 1,400)

The pre-analysis plan detail mirrors §4.5's verbosity. Same treatment:
- Factorial table: keep (it's efficient)
- Per-hypothesis paragraphs: cut to 2–3 sentences each
- Power section: cut to 1 sentence + table row for H2.3

The pre-registration DOI (once Jony files amendments + OSF upload) can replace the inline power justification.

---

### §6 Discussion (−2,476 words, 4,976 → 2,500)

This is the biggest single cut needed. The discussion is currently written at a monograph depth. For CHI, each subsection should be 400–600 words.

**§6.1 When does protective absence work? (707 → 400)**  
Keep the core claim: protective absence succeeds when the token label does not import the content-evidence schema. 1 paragraph of elaboration max.

**§6.2 The confirmation code paradox (913 → 500)**  
The H2 three-outcome framework is the key contribution. Keep that structure. Cut the extended eCommerce mental model explanation by half — the reviewer has already read §4.

**§6.3 The protective absence feedback inversion (648 → 400)**  
This is the most theoretical subsection. Trim the Norman/HTTPS analogy — one paragraph — and cut the extension into other failure modes.

**§6.4 Generalisation beyond voting (900 → 500)**  
The auction/whistleblower/peer-review triptych is too long. 1 tight paragraph per domain instead of 1 full paragraph + follow-up each. The core design principle (timing constraint adapts; invariants hold) is what the reviewer needs.

**§6.5 Limitations (1,807 → 600):**  
9 limitation topics → 5 consolidated:
1. **Protocol exposure + receipt-freeness** (merge): 120 words. Same root cause (calldata gap); PIUP addresses UX layer only.
2. **Ecological validity** (merge Study 1 + Study 2): 120 words. Screenshot vs. interactive; consequential inertness; Prolific convenience sample.
3. **Demand characteristics + label-substitution** (merge): 100 words. Q1-C demand characteristic; ethics-clause substitution possibility.
4. **Statistical power**: 120 words. McNemar error corrected; n=70/cell, 82% power on H2-primary; Study 2 all adequately powered.
5. **Scope**: 80 words. Single-vote binary/multi-option only; ranked-choice extension = future work.

A shortened §6.5 draft follows at the end of this document.

---

### §7 Conclusion (−180 words, 680 → 500)

The conclusion restates the two boundary conditions and practical prescription. This is well-structured but 30% too long. Cut by removing one explanatory sentence from each of the three final paragraphs.

---

## Implementation priority order

1. **Abstract swap** — 5 minutes, saves 357 words immediately.
2. **§6.5 Limitations** — draft below, saves 1,200 words.
3. **§4.4 Measures table** — convert to table format, saves ~1,000 words.
4. **§4.5 Analysis plan** — compress per-hypothesis paragraphs, saves ~400 words.
5. **§1 Introduction** — cut §1.4 related work and §1.1, saves ~750 words.
6. **§6.1–§6.4** — tighten, saves ~900 words.
7. **§3 System** — trim M2 and component descriptions, saves ~470 words.
8. **§5 Study 2** — trim, saves ~535 words.
9. **§2 PIUP** — trim, saves ~240 words.

Steps 1–5 get the paper to ~12,000 words. Steps 6–9 take it to ~9,800. Do all 9 before CHI submission.

---

## Shortened §6.5 Limitations (draft — 594 words)

**Ready to paste in.** Replaces the current 1,807-word version. Preserves all 5 key disclosures. Eliminates per-tick annotation history and excessive cross-referencing that belongs in pre-reg, not the CHI paper.

---

### 6.5 Limitations

**Protocol exposure and receipt-freeness.** The current Aztec Private Voting implementation exposes `vote_choice` and `receipt_id` as plaintext arguments in `record_vote` public calldata. An observer monitoring on-chain calldata can construct a `receipt_id → vote_choice` map without access to the receipt itself. PIUP addresses the coercion surface at the UX layer — the receipt withholds the choice (Invariant 3), protective framing names the absence — but does not protect against calldata observation. Full receipt-freeness (Juels et al., 2005) additionally requires severing the identifier-to-choice link at the protocol layer; the current contract does not implement a re-encryption mix. Users whose threat model includes calldata surveillance are not protected by PIUP alone. The calldata exposure is resolved at the application layer in M3, which removes `vote_choice` from `record_vote`'s public arguments; the PIUP receipt invariants hold regardless of whether M3 is deployed. "Coercion-resistant" is withheld from user-facing copy pending this protocol fix (§3.3). This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference, not protocol threat-model awareness.

**Ecological validity.** Study 1 uses screenshot stimuli, removing the choice-commitment context present in real voting flows. Confidence ratings and save intention may be underestimated when participants assess a static receipt for a choice they did not actively make. Study 2 improves ecological validity substantially — participants cast a simulated vote before receiving the receipt — but three bounds remain: the vote is consequentially inert; the Prolific sample (US-based English-speaking online workers) may not represent DAO governance participant populations; and both studies measure receipt comprehension immediately after voting, not at the delayed-verification event that the downloaded receipt is intended to support. These bounds primarily constrain effect-size generalisation; internal validity of the factorial contrasts is not affected.

**Demand characteristics and label substitution.** In Condition C (nullifier label), Q1 reads: "Does having this *nullifier* prove that your vote was counted?" The word "nullifier" in the question stem may independently depress Q1-C accuracy — participants associating "nullifier" with "null, cancelled" may answer No based on the question text alone, not the receipt label. The Q1-C demand characteristic operates in the H3 prediction direction; the H3 analysis does not require isolating the two sources. If the pilot (n = 10/cell) shows < 30% Q1 accuracy in Condition C, a pre-registered ethics clause permits label substitution before the full launch; this decision is independent of and does not alter the H3 alpha level.

**Statistical power.** The pre-registration used G\*Power's McNemar (within-subjects) test in error; the corrected between-subjects calculation (Cohen's h = 0.30, one-tailed, α = 0.05) yields n = 67/cell for 80% power; the study targets n = 70/cell (≈82%). The omnibus 4-condition chi-squared is intentionally underpowered (≈67%); it is descriptive-secondary and does not adjudicate any of the 14 confirmatory hypotheses. For Study 2, all four confirmatory hypotheses (H2.1–H2.4) are adequately powered at pre-specified effect sizes (§5.2); H2.3 (TOST on save intention) achieves ≈86% power at d = 0.50 with n = 60 per I level.

**Scope.** The PIUP invariants and empirical tests apply to single-vote binary or multi-option receipts. Ranked-choice, quadratic, and cumulative voting receipts introduce additional absent-content complexity — the receipt must confirm that a full preference ordering was recorded without revealing it — and are not addressed here. Generalisation to non-binary preference structures is a direction for future work.

---

*End of editorial memo.*
