# OSF Amendment Filing — PIUP Study 1

**Prepared:** 2026-06-24  
**Purpose:** Consolidate all pre-registration amendments into a single document ready for OSF upload.  
**OSF project:** PIUP Study 1 (aztec-private-voting repo, Jony Bursztyn)

---

## How to use this document

1. Complete **Section A — Pending Decisions** (your judgment call on A, B, C).
2. Upload the three pre-registration files to OSF.
3. Paste each amendment from **Section B** into the OSF amendment log.
4. Update the `[DATE]` fields below.

---

## Section A — Pending Jony Decisions (required before OSF upload)

These three items need your judgment. For each, mark which version you choose, then copy the completed amendment text into Section B.

---

### Decision A — Q3 wording

**Pre-reg wording (§5.2 line 155):**
> "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?"
> Foils: Yes / No / Unsure. Correct: No.

**Instrument wording (survey §3):**
> "Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?"
> Foils: Yes / No / I'm not sure. Correct: No.

**Key difference:** "coercive" vs. "your employer" framing; "send a screenshot" vs. "show them this screen"; "could they learn how you voted" vs. "could they tell which voting option you chose."

**Your choice:**
- [ ] Keep pre-reg wording → no amendment needed for Q3 text; update instrument to match.
- [ ] Use instrument wording → file amendment below and update §4.3 of paper to quote instrument.

**Amendment text (use only if instrument wording chosen):**
> _"Item Q3 wording updated from the pre-registered text to: 'Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?' Rationale: scenario made more ecologically concrete; 'which voting option you chose' is more specific than 'how you voted,' reducing ambiguity. Correct answer (No), foil structure, and scoring (binary) unchanged."_

---

### Decision B — Q4 wording and foils

**Pre-reg wording (§5.2 line 158):**
> "What would happen if you lost this value?"
> Foils: (a) you would lose your vote; (b) you could still verify that your vote was counted, but you would not have proof that the receipt is yours [CORRECT]; (c) the system keeps a backup and you can retrieve it; (d) your vote would be reversed.

**Instrument wording (survey §4):**
> "If you closed this screen without saving your [LABEL], what would happen?"
> Foils: (a) my vote would be cancelled or reversed; (b) I could still check that my vote was counted, but I would not have proof the receipt is mine [CORRECT]; (c) the system keeps a copy and I can retrieve it later; (d) nothing — I do not need to save it.

**Key differences:** "lost this value" → "closed this screen without saving [LABEL]"; foil (a) adds "cancelled or reversed"; foil (d) changes from "vote reversed" to "nothing — I do not need to save it."  
**Note:** "closed this screen" changes the ecological validity framing — it tests interface affordance recall, not object permanence. "lost" is more general. The [LABEL] embed in the question also makes the question slightly label-specific. Consider: does the label change how people answer Q4? If yes, the label-embed is meaningful (captures schema activation); if no, it is neutral.

**Your choice:**
- [ ] Keep pre-reg wording → no amendment needed; update instrument to match.
- [ ] Use instrument wording → file amendment below and update §4.3 of paper to quote instrument.

**Amendment text (use only if instrument wording chosen):**
> _"Item Q4 wording updated from 'What would happen if you lost this value?' to 'If you closed this screen without saving your [LABEL], what would happen?' Foils updated: (a) 'you would lose your vote' → 'my vote would be cancelled or reversed'; (d) 'your vote would be reversed' → 'nothing — I do not need to save it.' Correct answer (b) unchanged. Rationale: 'closed this screen' maps more naturally to the actual study interface affordance; [LABEL] embedding is consistent with the treatment stimulus."_

---

### Decision C — Q3 clarification: baseline or amendment-only?

**Pre-reg §5.2 lists as baseline stimulus:**  
> "Assume they can only see what is on this screen."

**Pre-reg §7.2 says:**  
> "Wording changes to Q3 (adding the 'assume only what is on screen' clarification)" are a permitted pilot amendment "if Q3 shows confusion."

**Contradiction:** §5.2 includes the clarification as baseline; §7.2 describes adding it as a post-pilot amendment. The instrument (survey §3) does NOT include this clarification — the question ends after the foils.

**Your choice:**
- [ ] §5.2 is authoritative — clarification IS in the baseline instrument → update instrument to add it; no amendment needed.
- [ ] §7.2 is authoritative — clarification is amendment-only, excluded from baseline → update §5.2 of pre-reg to resolve the conflict; file amendment below.
- [ ] Neither — remove the clarification from pre-reg entirely and don't use it → file amendment.

**Amendment text (use only if resolving §5.2/§7.2 conflict by removing baseline clarification):**
> _"Pre-registration §5.2 Q3 stimulus description: clarification 'Assume they can only see what is on this screen' removed from the baseline question. The clarification remains available as a post-pilot instrument amendment (§7.2) if Q3 shows evidence of misinterpretation in the pilot. The baseline Q3 question is: 'Imagine your employer tells you...' [final wording per Decision A above] with no appended clarification. Rationale: §7.2 takes precedence; adding the clarification at baseline risks anchoring participants toward the correct answer."_

---

## Section B — Ready-to-File Amendments

These amendments are finalized. Paste into OSF amendment log at upload time. Update `[DATE]` fields.

---

### Amendment 1 — G\*Power test type correction (pre-OSF deviation)

**Status:** ✅ Ready to file  
**OSF field:** Deviation note / Amendment log  
**Category:** Sample size / statistical method

> _"Power analysis correction (pre-data, pre-OSF): The original power calculation used G\*Power's 'Proportion: Inequality of two dependent proportions' (McNemar test), which is a within-subjects test and does not apply to the between-subjects design of Study 1. The corrected calculation uses 'Proportion: Inequality of two independent proportions' (Cohen's h = 0.30, one-tailed, α = 0.05), yielding n = 67 per cell for 80% power on the H2 primary endpoint. Target sample updated to n = 70 per cell (N = 280), providing approximately 82% power. The originally pre-registered n = 50 per cell would have provided approximately 69% power for H2 primary. This correction was made and documented in the paper before any data were collected and before this OSF upload. The 14 confirmatory hypotheses and all analysis procedures are unchanged."_

**Supporting documentation:** Paper §4.2 and §6.5 (Statistical power); pre-registration §4.2 correction note (line 129).

---

### Amendment 2 — MQ1 wording: two-part form (Item D)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording / measurement procedure

> _"Item MQ1 wording updated from the pre-registered 'In your own words, what does this value prove about your vote?' to the two-part instrument form: 'In your own words: what does your [LABEL] prove about your vote? What does it NOT prove?' Scoring updated from cumulative 0–2 scale to two independent binary rater dimensions (MQ1_inclusion and MQ1_leakage); composite score = MQ1_inclusion + MQ1_leakage (range 0–2, same scale as pre-registered). Rationale: the two-part form directly elicits both the inclusion and absent-choice dimensions that are central to H2. The pre-registered 0–2 cumulative scale maps directly onto the two binary dimensions (0+0 = 0; 1+0 = 1; 1+1 = 2); no re-analysis is required. This amendment was made before any data were collected."_

**Supporting documentation:** jony-actions-audit-2026-06-23.md §Item D analysis; survey instrument §6 (MQ1 wording).

---

### Amendment 3 — BI1 wording: label-embedded form (Item E)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording / behavioral intention measure

> _"Item BI1 wording updated from the pre-registered 'If this screen appeared after a real vote, would you download this file?' (5-point: Definitely yes → Definitely no) to the instrument form: 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save your [LABEL] for future reference?' (5-point: Definitely would save it → Definitely would not save it). Rationale: (a) 'save for future reference' makes the verification purpose of saving explicit, better operationalizing RQ2 (behavioral intention to preserve the receipt for later verification); (b) embedding [LABEL] in the question is intentional — BI1 measures whether the label's behavioral schema (save-to-verify) is activated independently of comprehension accuracy, which is the behavioral corollary of the H2 representational schema hypothesis. Demand characteristic risk is low because [LABEL] appears prominently throughout the stimuli. Response scale direction preserved (Definitely would save = positive behavioral intention). This amendment was made before any data were collected."_

**Supporting documentation:** jony-actions-audit-2026-06-23.md §Item E analysis; survey instrument §7 (BI1 wording); h2-analysis-fingerprint-vs-confirmation-code.md (schema mechanism).

---

### Amendment 4 — R analysis script: DescTools removed, replaced with base-R

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Analysis script / software dependency

> _"Analysis script amendment (§14 deviation log): DescTools::CramerV and DescTools::OddsRatio replaced with base-R equivalents (cramer_v_base() and odds_ratio_base() functions defined in the script header). Statistical results are identical: CramerV uses the standard formula √(χ²/(n × min(r−1, c−1))); OddsRatio uses Woolf-logit confidence intervals. Change made for portability — DescTools requires the 'fs' C++ package, which is unavailable in sandboxed analysis environments. The DescTools package has been removed from the required packages list. This change does not affect any confirmatory hypothesis tests; all 14 confirmatory analyses use chi-squared, Holm-corrected proportions comparison, and TOST equivalence tests, none of which relied on DescTools. Amendment logged in script header (date: 2026-06-24)."_

**Supporting documentation:** analysis/piup-study1-analysis.R lines 16, 36–40, 45–62 (amendment header + base-R implementations).

---

## Section C — Filing checklist

Complete this before OSF upload.

**Decisions:**
- [ ] Decision A resolved (Q3 wording)
- [ ] Decision B resolved (Q4 wording)
- [ ] Decision C resolved (Q3 clarification)

**Files to upload:**
- [ ] `docs/piup-study1-preregistration-2026-06-22.md` → OSF pre-registration
- [ ] `analysis/piup-study1-analysis.R` → OSF file (committed at tick-3798)
- [ ] `docs/piup-study1-survey-instrument-2026-06-22.md` → OSF file

**Amendments to paste into OSF (Section B above):**
- [ ] Amendment 1 — G\*Power correction
- [ ] Amendment 2 — MQ1 two-part wording (Decision D: if accepted)
- [ ] Amendment 3 — BI1 label-embedded wording (Decision E: if accepted)
- [ ] Amendment 4 — DescTools → base-R
- [ ] Amendment A — Q3 wording (if instrument wording chosen)
- [ ] Amendment B — Q4 wording (if instrument wording chosen)
- [ ] Amendment C — Q3 clarification resolution (if applicable)

**After OSF upload:**
- [ ] Copy the OSF DOI into `docs/forum-post-grant-application.md` lines 5 and 58
- [ ] Update `docs/jony-actions-audit-2026-06-23.md` Jony-action #1 as DONE
- [ ] Proceed to Jony-action #2 (Qualtrics survey creation)

---

_Document prepared by heartbeat agent tick-3803. All amendment texts are drafts — Jony should review before filing._
