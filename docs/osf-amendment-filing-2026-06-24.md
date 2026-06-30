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
> Foils: (a) My vote would be cancelled or reversed; (b) I could still verify that my vote was counted, but I would not have this [LABEL] as personal proof [CORRECT]; (c) The voting system keeps a copy of my [LABEL], so I could always retrieve it later; (d) Nothing — my vote does not depend on having this [LABEL].

**Key differences:** "lost this value" → "closed this screen without saving your [LABEL]"; correct answer: "check" → "verify"; "proof the receipt is mine" → "this [LABEL] as personal proof" ([LABEL] embed for label-consistency); foil (a): "you would lose your vote" → "My vote would be cancelled or reversed" (merges pre-reg foil (d)); foil (c): "the system keeps a backup" → "The voting system keeps a copy of my [LABEL], so I could always retrieve it later"; foil (d): "your vote would be reversed" → "Nothing — my vote does not depend on having this [LABEL]" (near-correct distractor; isolates verification-function understanding). [Fixed tick-4024: prior draft had 'I do not need to save it' and 'check...proof the receipt is mine' — corrected to instrument-exact wording per piup-study1-survey-instrument-2026-06-22.md §6/Q4.]  
**Note:** "closed this screen" changes the ecological validity framing — it tests interface affordance recall, not object permanence. "lost" is more general. The [LABEL] embed in the question also makes the question slightly label-specific. Consider: does the label change how people answer Q4? If yes, the label-embed is meaningful (captures schema activation); if no, it is neutral.

**Your choice:**
- [ ] Keep pre-reg wording → no amendment needed; update instrument to match.
- [ ] Use instrument wording → file amendment below and update §4.3 of paper to quote instrument.

**Amendment text (use only if instrument wording chosen):**
> _"Item Q4 wording updated from 'What would happen if you lost this value?' to 'If you closed this screen without saving your [LABEL], what would happen?' Correct answer (b) updated to instrument wording: 'I could still verify that my vote was counted, but I would not have this [LABEL] as personal proof.' Foils updated: (a) 'you would lose your vote' → 'My vote would be cancelled or reversed' (merges pre-reg foil (d) into one distractor); (c) 'the system keeps a backup' → 'The voting system keeps a copy of my [LABEL], so I could always retrieve it later'; (d) 'your vote would be reversed' → 'Nothing — my vote does not depend on having this [LABEL]' (near-correct distractor; isolates verification-function understanding). Rationale: 'closed this screen without saving your [LABEL]' maps more naturally to the actual study interface affordance; [LABEL] embedding is consistent with the treatment stimulus. Foil (d) design-change is substantive: the pre-reg's 'vote reversed' distractor tests catastrophic-misread; the instrument's 'my vote does not depend on having this [LABEL]' tests whether participants understand the receipt is optional for the vote but necessary for personal verification proof. Correct answer scoring (binary: 1 = option (b), 0 = all others) unchanged. This amendment was made before any data were collected."_ [Foil text corrected tick-4024: earlier draft had 'nothing — I do not need to save it' and 'I could still check...proof the receipt is mine' — corrected to instrument-exact wording.]

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

### ~~Amendment 2 — MQ1 wording: two-part form (Item D)~~

**Status:** ⛔ VOID — DO NOT FILE (superseded 2026-06-25)  
**OSF field:** N/A — no amendment required  
**Category:** N/A

**Reason voided:** The pilot-launch decisions memo (`docs/piup-study1-pilot-decisions-2026-06-25.md` §Item D) overrode the earlier draft recommendation. The final decision was to **keep the pre-registration single-question wording** ('In your own words, what does your [LABEL] prove about your vote?') and NOT add the 'What does it NOT prove?' clause. The survey instrument was reverted to match the pre-reg wording (tick-3819). No amendment is needed — reverting to the pre-reg wording requires no OSF deviation filing. Filing this amendment would be incorrect and would document a change that was not made.

**Rationale for reversal:** The two-part form ('What does it NOT prove?') creates a demand characteristic that inflates non-leakage scores in all conditions, reducing the measure's sensitivity to between-condition differences. The spontaneous mention of non-leakage is the higher-validity test; an explicit prompt undermines this. See pilot-decisions §Item D for full analysis.

**Supporting documentation:** `docs/piup-study1-pilot-decisions-2026-06-25.md` §Item D; `docs/piup-study1-survey-instrument-2026-06-22.md` §7/MQ1 note (2026-06-25); `docs/jony-actions-audit-2026-06-23.md` §Item D (resolved tick-3819, no amendment). [Note added tick-4001: Amendment 2 void confirmed by JONY-ACTION I audit.]

---

### Amendment 3 — BI1 wording: 'this code' form (Item E)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording / behavioral intention measure

> _"Item BI1 wording updated from the pre-registered 'If this screen appeared after a real vote, would you download this file?' (5-point: Definitely yes → Definitely no) to: 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save this code for future reference?' (5-point: Definitely would save it → Definitely would not save it). Rationale: (a) 'save for future reference' makes the verification purpose of saving explicit, better operationalizing RQ2 (behavioral intention to preserve the receipt for later verification); (b) 'this code' replaces 'your [LABEL]' to remove label-name demand from the behavioral intent measure — BI1 should measure whether participants intend to save the receipt, not whether they associate saving with their specific condition label schema; (c) 'this code' is a neutral label-agnostic reference that maps cleanly to the download affordance visible in the stimulus across all four conditions. Response scale direction preserved (Definitely would save = positive behavioral intention). This amendment was made before any data were collected."_

**Supporting documentation:** `docs/piup-study1-pilot-decisions-2026-06-25.md` §Item E; `docs/piup-study1-survey-instrument-2026-06-22.md` §7/BI1 (updated to 'this code', 2026-06-25); `docs/jony-actions-audit-2026-06-23.md` §Item E (resolved tick-3819). [Note updated tick-4001: corrected from 'save your [LABEL]' to 'save this code' per final pilot-decisions recommendation. Earlier draft had '[LABEL]' which was the instrument wording before the demand-characteristic fix was applied.]

---

### Amendment 4 — R analysis script: DescTools removed, replaced with base-R

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Analysis script / software dependency

> _"Analysis script amendment (§14 deviation log): DescTools::CramerV and DescTools::OddsRatio replaced with base-R equivalents (cramer_v_base() and odds_ratio_base() functions defined in the script header). Statistical results are identical: CramerV uses the standard formula √(χ²/(n × min(r−1, c−1))); OddsRatio uses Woolf-logit confidence intervals. Change made for portability — DescTools requires the 'fs' C++ package, which is unavailable in sandboxed analysis environments. The DescTools package has been removed from the required packages list. This change does not affect any confirmatory hypothesis tests; all 14 confirmatory analyses use chi-squared, Holm-corrected proportions comparison, and TOST equivalence tests, none of which relied on DescTools. Amendment logged in script header (date: 2026-06-24)."_

**Supporting documentation:** analysis/piup-study1-analysis.R lines 16, 36–40, 45–62 (amendment header + base-R implementations).

---

### Amendment 5 — CS/SE student screener extension (pre-OSF deviation)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Exclusion criteria deviation  
**Source:** JONY-ACTION O (tick-3870)

> _"Exclusion criteria amendment (pre-data, pre-OSF): The Prolific screener question SC2, as deployed in the survey instrument, extends the professional exclusion to CS/SE students — participants who self-report as 'Student in computer science or software engineering' are excluded in addition to software engineering professionals (computer science, software development, or cryptography as primary occupation). The OSF pre-registration §3 lists only the professional exclusion criterion. The SC2 student-extension uses the same domain-expert contamination rationale as the professional exclusion: CS/SE students have technical exposure to cryptographic concepts that could systematically elevate comprehension scores and invalidate the between-subjects comprehension measures. This extension was made before pilot launch and is documented in the survey instrument §SC2. §4.2 of the paper accurately describes the deployed screener criteria ('self-reported software engineering professionals (computer science, software development, or cryptography by primary occupation) or CS/SE students'). This amendment documents the student extension as a Type I minor deviation (pre-data, pre-collection, same rationale as the registered professional exclusion; pre-reg §7.1)."_

**Supporting documentation:** piup-chi-paper-draft-2026-06-22.md §4.2 SC2 exclusion note (tick-3870); piup-study1-survey-instrument-2026-06-22.md §SC2.

---

### Amendment 6 — Q1 wording: label-substitution from 'this value' to '[LABEL]' form (pre-OSF deviation)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording deviation  
**Source:** §4.4 Q1 note (tick-3842); construct-validity disclosure added tick-4008

> _"Item Q1 wording updated from the pre-registered text 'Does this value prove that your vote was counted?' to: 'After voting, the system showed you your [LABEL]. Does having this [LABEL] prove that your vote was counted?' Changes: (1) preamble sentence added to contextualise the question; (2) 'this value' replaced with 'your [LABEL]' and 'Does this value prove' replaced with 'Does having this [LABEL] prove' — condition-specific label name is substituted throughout. Correct answer (Yes), foils (No; Unsure), and binary scoring are unchanged. Rationale: the '[LABEL]' form is consistent with the label-effect manipulation across all question items and makes explicit that the identifier being asked about is the same label the participant received on the receipt stimulus. This amendment was made before any data were collected. Construct-validity note: in Condition C (nullifier), Q1 reads 'Does having this nullifier prove that your vote was counted?' — the word 'nullifier' appears in the question stem itself, which may independently prime the incorrect 'nullified = invalidated' schema. This creates a potential indirect demand characteristic operating in the H3 prediction direction (H3 predicts Q1(C) < Q1(A, B, D)). This limitation does not change the pre-registered H3 analysis; it is disclosed in §6.5 of the paper and should be noted in the OSF deviation log."_

**Supporting documentation:** `piup-chi-paper-draft-2026-06-22.md` §4.4 Q1 note (tick-3842); §6.5 Q1 construct-validity disclosure (tick-4008); `piup-study1-survey-instrument-2026-06-22.md` §6/Q1.

---

### Amendment 7 — Q2 wording: label-substitution from 'this value' to '[LABEL]' form (pre-OSF deviation)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording deviation  
**Source:** §4.4 Q2 note (tick-3842); added to filing doc tick-4008

> _"Item Q2 wording updated from the pre-registered text 'Does this value prove which option you chose?' to: 'The [LABEL] is a string of numbers and letters that is unique to your vote. Does having this [LABEL] prove which voting option you chose?' Changes: (1) preamble sentence added describing the identifier's structural properties; (2) 'this value' replaced with 'this [LABEL]' and 'Does this value prove' replaced with 'Does having this [LABEL] prove'; (3) 'which option you chose' updated to 'which voting option you chose'. Correct answer (No), foils (Yes; Unsure), and binary scoring are unchanged. Rationale: the '[LABEL]' form is consistent with the label-effect manipulation and ensures the Q2 question directly references the same identifier the participant received in the stimulus. The preamble ('a string of numbers and letters that is unique to your vote') provides a neutral description of the token's structure, free of any hint about its content-revealing or content-hiding properties; this framing is value-neutral across all four conditions. This amendment was made before any data were collected. No construct-validity concern analogous to Q1: none of the four condition labels (fingerprint, confirmation code, nullifier, receipt ID) semantically suggest whether the identifier proves or fails to prove vote choice; the H1, H2, H3, and H4 comparisons are unaffected by this wording change."_

**Supporting documentation:** `piup-chi-paper-draft-2026-06-22.md` §4.4 Q2 note (tick-3842); `piup-study1-survey-instrument-2026-06-22.md` §6/Q2.

---

### Amendment 8 — MQ1 wording: label-substitution from 'this value' to '[LABEL]' form (pre-OSF deviation)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Instrument wording deviation  
**Source:** §4.4 MQ1 note (tick-3835/3840); amendment gap identified tick-4022

> _"Item MQ1 (mental model quality open-text question) wording updated from the pre-registered text 'In your own words, what does this value prove about your vote?' to: 'In your own words: what does your [LABEL] prove about your vote?' Changes: (1) 'this value' replaced with 'your [LABEL]' — condition-specific label name substituted throughout, consistent with the label-effect manipulation; (2) colon added after 'words:' (minor punctuation change). Correct answer construct (0–2 two-rater scoring; κ ≥ 0.70 required; pre-reg §5.2) is unchanged. Rationale: the '[LABEL]' form ensures the MQ1 question directly references the same identifier the participant received in the stimulus, consistent with the Q1 and Q2 label-substitution amendments (Amendments 6 and 7). No separate construct-validity concern: none of the four condition labels (vote fingerprint, confirmation code, nullifier, receipt ID) semantically hint at whether the identifier 'proves' anything specific; the '[LABEL]' substitution in MQ1 does not create a demand characteristic analogous to the Q1-Condition-C nullifier issue. This amendment was made before any data were collected. Note: Amendment 2 (VOID) addressed the two-part form question ('What does it NOT prove?') — that change was reverted; the present amendment documents the separately required '[LABEL]' substitution, which is a remaining deviation from the pre-reg 'this value' wording regardless of the two-part/single-part decision."_

**Supporting documentation:** `piup-chi-paper-draft-2026-06-22.md` §4.4 MQ1 note (tick-3835/3840, tick-4022); `piup-study1-preregistration-2026-06-22.md` §5.2 line 171 ('this value' wording); `piup-study1-survey-instrument-2026-06-22.md` §7/MQ1 ('[LABEL]' wording). Parallel to Amendments 6 (Q1) and 7 (Q2).

---

### Amendment 9 — TOST p-value tail direction bug fix (pre-data correction)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Analysis script bug fix (pre-data, pre-OSF)  
**Source:** tick-4029 audit

> _"Analysis script bug fix (pre-data, pre-OSF): The tost_prop() function in the pre-registered analysis script had inverted lower.tail arguments in the two one-sided z-test p-value calculations (H2-tertiary equivalence test, §6.5). As written, the script computed: p_lo = pnorm(z_lo, lower.tail=TRUE) and p_hi = pnorm(z_hi, lower.tail=FALSE). The correct computation for TOST of two independent proportions is: p_lo = pnorm(z_lo, lower.tail=FALSE) [upper tail, rejecting H0a: diff ≤ -δ when z_lo is large] and p_hi = pnorm(z_hi, lower.tail=TRUE) [lower tail, rejecting H0b: diff ≥ +δ when z_hi is small]. The inverted tails produced p_tost = max(p_lo, p_hi) > 0.50 when the observed difference was within the equivalence bounds, making the equivalence criterion (p_tost < 0.05) impossible to satisfy regardless of effect size. The fix swaps the lower.tail arguments to their correct values. The 90% CI of the proportion difference (ci_lo_90, ci_hi_90) and the Cohen's h effect size are unaffected. The equivalence bounds (±0.10), alpha (0.05), and the logical equivalence_established criterion (p_tost < alpha) are unchanged. This correction was made before any data were collected. Amendment logged in the script at line ~503 with [AMENDMENT tick-4029] comment."_

**Supporting documentation:** `analysis/piup-study1-analysis.R` lines ~499–506 (tost_prop() function); CHI paper §4.5 H2-tertiary description; pre-reg §6.5 (TOST equivalence test specification).

---

### Amendment 10 — TOSTER package removal (software dependency, pre-data)

**Status:** ✅ Ready to file  
**OSF field:** Amendment log  
**Category:** Analysis script — software dependency (pre-data, pre-OSF)  
**Source:** tick-4032 audit

> _"Analysis script software dependency change (pre-data, pre-OSF): TOSTER removed from the required packages list and from the script. The OSF pre-registration §6.9 listed TOSTER as a planned package for equivalence tests. On review of the analysis script, TOSTER::tsum_TOST was never called: H2-tertiary uses a custom tost_prop() z-test function (implemented in the script at lines ~495–520). TOSTER::tsum_TOST operates on means (t-distribution); H2-tertiary is a TOST of two independent proportions, which requires a z-test on the raw probability scale, not an arcsine-transformed t-test. The custom tost_prop() implements the correct two one-sided z-test procedure per Lakens (2017). TOSTER was loaded via library(TOSTER) but never called, creating a spurious installation dependency. Removing it is parallel to Amendment 4 (DescTools removal). No statistical result is affected; the tost_prop() function and all H2-tertiary outputs are unchanged. (Pre-data.) Amendment logged in the script at lines ~32–40 with [AMENDMENT tick-4032] comment."_

**Supporting documentation:** `analysis/piup-study1-analysis.R` (library block); pre-reg §6.9 (packages list updated to remove TOSTER); pre-reg §14 Amendment 10.

---

### Amendment 11 — multcomp removal + dunn.test addition (software dependency, pre-data)

**Type:** Pre-data, pre-OSF. Software dependency correction.

**Pre-registration section affected:** §6.10 (Software, planned packages list).

**What changed:** `multcomp` removed from planned packages list; `dunn.test` added.

**Reason:**
- `multcomp` was listed in the original §6.10 as 'Holm corrections' but was never loaded (`library(multcomp)` absent from script) and never called anywhere in the analysis. Holm corrections use base-R `p.adjust(vector, method = "holm")`. `multcomp` appeared only in the `install.packages()` comment at script creation (tick-3636) and was a ghost dependency.
- `dunn.test` has been loaded (`library(dunn.test)`) and called (`dunn.test::dunn.test()`) for the H3 secondary Q5 Kruskal-Wallis post-hoc block since tick-3636. Absent from §6.10 despite being a genuine dependency.

**Net effect:** Removes `multcomp`; adds `dunn.test`. No statistical result affected: Holm corrections unchanged (base-R `p.adjust()`); Dunn post-hoc is H3-secondary only.

**Parallel amendments:** Amendment 4 (DescTools removal), Amendment 10 (TOSTER removal).

**OSF amendment text:**

> _"§6.10 Software planned packages corrected (pre-data, pre-OSF): multcomp removed — Holm multiple-comparison corrections are implemented via base-R p.adjust(); multcomp appeared in the original install.packages() comment but was never loaded (no library(multcomp)) or called anywhere in the analysis script. dunn.test added — loaded via library(dunn.test) and called via dunn.test::dunn.test() for H3 secondary Q5 Kruskal-Wallis post-hoc analysis; present in script from initial commit but absent from §6.10. No statistical result affected. (Pre-data, pre-OSF upload.)"_

**Supporting documentation:** `analysis/piup-study1-analysis.R` (library block line 42, install hint line 14); pre-reg §6.10 (Amendment 11 inline note added); pre-reg §14 Amendment 11.

---

### Amendment 12 — Q5 wording: 4 deviations from pre-reg §5.2 (instrument §6/Q5, pre-data)

**Amendment type:** Type I (minor) — pre-data correction; Q5 stem wording deviates from pre-registration in four places. Scoring rubric unchanged.

**Detected:** tick-4124 (2026-06-28). Cross-check of instrument §6/Q5 against pre-reg §5.2.

**Description:** Pre-registration §5.2 specifies Q5 wording as: 'Why might the system choose not to show you your vote choice on this screen?' The deployed instrument §6/Q5 has four deviations:

1. **Prefix added:** 'In your own words:' added before the stem.
2. **'the system' → 'this voting system':** more specific referent, matches the stimulus frame.
3. **'not' → 'NOT':** lowercase emphasis changed to uppercase emphasis (demand characteristic neutralised).
4. **'your vote choice' → 'which option you voted for':** plainer English, avoids jargon.

Deployed Q5 wording: _'In your own words: why might this voting system choose NOT to show you which option you voted for on this screen?'_

Scoring rubric (0–2), two-rater requirement (κ ≥ 0.70), and hypothesis tests are unchanged. Amendment 12 is parallel to Amendments 6 (Q1), 7 (Q2), and 8 (MQ1).

**No protocol, analysis, or exclusion criterion change.** Script re-upload not required.

**OSF amendment text to paste:**

> _“Q5 wording corrected in survey instrument (instrument §6/Q5; pre-data): 4 deviations from pre-reg §5.2 wording. (a) 'In your own words:' prefix added. (b) 'the system' → 'this voting system'. (c) 'not' → 'NOT' (emphasis). (d) 'your vote choice' → 'which option you voted for'. Deployed Q5: 'In your own words: why might this voting system choose NOT to show you which option you voted for on this screen?' Scoring rubric (0–2) and κ ≥ 0.70 requirement unchanged. Parallel to Amendments 6, 7, 8. No protocol or analysis change. (Pre-data, pre-OSF upload.)”_

**Supporting documentation:** `docs/piup-study1-survey-instrument-2026-06-22.md` §6 Q5; pre-reg §5.2 Q5 entry.

---

### Amendment 13 — MQ1 scoring rubric clarification: two-dimensional additive rubric is operative (pre-data)

**Amendment type:** Type I (minor) — pre-data clarification of operationalization; no change to scoring logic, rater instructions, or confirmatory analyses.

**Detected:** tick-4124 (2026-06-28). Review of instrument §11 MQ1 rubric vs. pre-reg §5.3.

**Description:** Pre-registration §5.3 describes the MQ1 open-text scoring rubric as:

> '0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states choice is hidden from system.'

This abbreviated rubric is the reporting summary. The operative operationalization is the **two-dimensional additive rubric** in instrument §11:

- **Dim 1 (Inclusion):** 0 or 1 — does the response reference that the ballot was counted/included?
- **Dim 2 (Non-leakage):** 0 or 1 — does the response correctly state the choice is hidden/private?
- **Total = D1 + D2** (range 0–2)

Critically, **non-leakage-only responses** (correctly states choice is hidden but does not mention inclusion) score Dim 1=0 + Dim 2=1 = **1**. Under the abbreviated rubric, a naïve reading of 'correctly states inclusion without choice' (score 1) might incorrectly exclude non-leakage-only responses. The two-dimensional rubric resolves this ambiguity. The final 0–2 scale and interpretation are unchanged.

Amendment 8 log entry stated 'scoring construct unchanged' — corrected here: the two-dimensional rubric is the operative operationalization; the abbreviated scale in §5.3 is the reporting summary. MQ1 is exploratory; no confirmatory analysis affected.

**No protocol, analysis, or exclusion criterion change.** Script re-upload not required.

**OSF amendment text to paste:**

> _“MQ1 scoring rubric clarification (pre-data): pre-reg §5.3 abbreviated rubric (0=no correct element; 1=inclusion without choice; 2=choice hidden) is operationalized by the two-dimensional additive rubric in instrument §11: Dim 1 (Inclusion, 0/1) + Dim 2 (Non-leakage, 0/1), total = D1+D2. Non-leakage-only responses score Dim 1=0 + Dim 2=1 = 1. Amendment 8 'scoring construct unchanged' corrected: the two-dimensional rubric is operative; the abbreviated 0–2 scale is the reporting summary. MQ1 is exploratory; no confirmatory analysis affected. (Pre-data, pre-OSF upload.)”_

**Supporting documentation:** `docs/piup-study1-survey-instrument-2026-06-22.md` §11 MQ1 rubric; pre-reg §5.3; Amendment 8 log entry.

---

### Amendment 14 — Attention check descriptions: pre-reg §3 descriptions both wrong (pre-data)

**Amendment type:** Type I (minor) — pre-data correction to attention check descriptions in pre-reg §3. Both-fail exclusion criterion and analysis script implementation are correct.

**Detected:** tick-4150 (2026-06-28). Cross-check of pre-reg §3 attention check descriptions against survey instrument.

**Description:** Pre-registration §3 describes the two Prolific attention checks as: 'Which of the following is a fruit? / Please select “strongly agree” for this item.' Both descriptions are wrong:

1. **AC1 (‘select strongly agree’):** The instrument AC1 item asks participants to select a specified option. The correct answer is **'Strongly Disagree'** (not 'strongly agree'). The item was designed so that participants who attend to instructions select the counter-intuitive option.

2. **AC2 (‘which is a fruit’):** The instrument AC2 item does **not** ask 'which of the following is a fruit?' It presents a list and asks participants to select **the third item from the list**. The correct answer is **Carrot** (a vegetable). The pre-reg description of both the question and the correct answer type is wrong.

**The both-fail exclusion criterion is correctly implemented** in the analysis script (participants failing AC1 AND AC2 are excluded; single-fail participants are retained). Only the pre-registration's text description of the checks is wrong.

**No protocol, analysis, or exclusion criterion change.** Script re-upload not required.

**OSF amendment text to paste:**

> _“Attention check descriptions corrected in pre-reg §3 (pre-data): Both descriptions were inaccurate. AC1 correct answer is 'Strongly Disagree' (not 'strongly agree'). AC2 does not ask 'which of the following is a fruit?' — it presents a list and asks participants to select the third item; the correct answer is Carrot (a vegetable). The both-fail exclusion criterion and analysis script implementation are correct. Only the pre-registration text description is corrected here. (Pre-data, pre-OSF upload.)”_

**Supporting documentation:** `docs/piup-study1-survey-instrument-2026-06-22.md` §AC1 and §AC2; `analysis/piup-study1-analysis.R` exclusion logic.

---

### Amendment 15 — H2 reversed-verdict criterion: p_one_tailed → p_two_tailed (analysis script, pre-data)

**Type:** I (minor; analysis-script bug fix, pre-data, no statistical conclusion affected)

**Detected:** tick-4170 (2026-06-29). Cross-check of §4.5 H2 outcome classification text vs. `piup-study1-analysis.R`.

**Description:** The H2 reversed-verdict criterion in `piup-study1-analysis.R` line 571 used `h2_reversed_test$p_one_tailed < 0.05` to test whether B > A on Q2 is significant. The pre-registration §6.5 and paper §4.5 both specify this post-hoc test should be evaluated at α = 0.05 **two-tailed**. Using `p_one_tailed` is equivalent to two-tailed α = 0.10, making the 'reversed' verdict systematically too easy to reach. Corrected to `h2_reversed_test$p_two_tailed < 0.05`.

**Evidence of intent:** The script comment on the same line read "# Post-hoc reversed test (two-tailed; only if primary not significant)" — the developer's intent was two-tailed, but the implementation was wrong.

**Impact:** No statistical results affected (pre-data correction). The 'reversed' verdict is now correctly guarded by two-tailed α = 0.05, consistent with the pre-registration.

**Relationship to other amendments:** Parallel to Amendment 9 (TOST lower.tail bug fix, same analysis file, also pre-data).

**OSF amendment text to paste:**

> _"H2 reversed-verdict criterion corrected (pre-data): `piup-study1-analysis.R` line 571 used a one-tailed p-value (p_one_tailed < 0.05) for the post-hoc B > A reversed test, equivalent to two-tailed α = 0.10. Pre-registration §6.5 specifies two-tailed α = 0.05 for this post-hoc check. Corrected to p_two_tailed < 0.05. The script comment on the same line correctly stated 'two-tailed' — only the code was inconsistent with the stated intent. No statistical conclusion affected (pre-data correction). (Pre-data, pre-OSF upload.)"_

**Supporting documentation:** `analysis/piup-study1-analysis.R` line 571 (fixed tick-4170); paper §4.5 H2 outcome classification [Fixed tick-4170 note]; pre-reg §6.5.

---

### Amendment 18 — H4 analysis script: ANOVA omnibus gate missing from verdict logic (pre-data)

**Amendment type:** Type I (minor) — pre-data correction to analysis script; no change to pre-specified hypotheses, primary endpoint, or statistical procedures.

**Detected:** tick-4178 (2026-06-29). Cross-check of CHI paper §6.1-§6.2 Discussion against pre-reg §H4 / §6.7 and analysis script.

**Description:** The pre-registration §6.7 and paper §4.5 both specify that Tukey HSD post-hoc comparisons for H4 are performed only if the one-way ANOVA omnibus is significant (F test, α = 0.05). Paper §4.5 H4-null definition: 'the ANOVA is non-significant; no pairwise extractions are performed.' The analysis script (lines ~718-728) ran `TukeyHSD()` regardless of ANOVA significance — the else-branch when ANOVA was non-significant included a comment 'Pre-specified Tukey HSD comparisons reported regardless', and the verdict determination logic (`h4_support`) checked only whether all three Holm-corrected Tukey comparisons were significant (`h4_sig && h4_direction`) without first gating on ANOVA significance. This means a non-significant ANOVA could still (implausibly) produce an `h4_support = TRUE` verdict.

**Fix (pre-data, pre-OSF upload):**
1. Added `anova_sig <- f_pval < 0.05` flag.
2. When ANOVA non-significant: Tukey HSD still computed and printed but clearly labelled 'descriptive/exploratory only; H4 verdict is H4-null per pre-reg §6.7'.
3. `h4_support` gated on `anova_sig`: `h4_support <- anova_sig && h4_sig && h4_direction`.
4. Verdict logic gains explicit H4-null branch: `if (!anova_sig) → "H4-NULL: ANOVA non-significant; no confirmatory pairwise extraction."`
5. H4-partial branch added for ANOVA significant but ≤ 2/3 Tukey comparisons surviving — consistent with paper §4.5 H4-partial definition.

**Impact:** No protocol, sample size, alpha level, or hypothesis change. All pre-specified tests unchanged. Script re-upload required at OSF filing.

**OSF amendment text to paste:**

> _"H4 analysis script: ANOVA omnibus gate added to verdict logic (pre-data). The script previously ran TukeyHSD() regardless of ANOVA significance and did not gate h4\_support on the omnibus p-value. Pre-reg §6.7 and paper §4.5 both require ANOVA significance before pairwise extraction. Fixed: h4\_support now requires anova\_sig (f\_pval < 0.05) AND all three Holm-corrected Tukey comparisons significant AND correct direction. H4-null verdict branch added when ANOVA non-significant. Tukey HSD still computed and printed descriptively when ANOVA non-significant; labelled exploratory. H4-partial branch added for ANOVA significant but ≤ 2/3 comparisons surviving. No protocol, sample size, alpha level, or hypothesis change. (Pre-data, pre-OSF upload.) Commit: see osf-amendment-filing-2026-06-24.md Amendment 18."_

**Supporting documentation:** `analysis/piup-study1-analysis.R` H4 block (lines ~716-810); `drafts/piup-chi-paper-draft-2026-06-22.md` §4.5 H4-null definition.

---

### Amendment 17 — SC1 wording + SC2 scope: pre-reg language differs from instrument (inclusion/exclusion criteria, pre-data)

**Amendment type:** Type I (minor) — pre-data correction to inclusion/exclusion criterion descriptions; no change to protocol, analysis, or who is actually included/excluded (instrument is the master source and was implemented as-is).

**Summary:**
1. **SC1 wording**: Pre-registration §3 inclusion criterion says 'Completed at least one online vote, poll, or election in the past 12 months.' Instrument §SC1 question text says 'Have you voted in an online election, poll, or survey in the past 12 months?' The instrument added 'survey' as an eligible activity type and restructured the phrasing ('voted in an online election, poll, or survey' vs. 'online vote, poll, or election'). 'Survey' is a meaningfully distinct inclusion category (a participant who has taken online surveys but not formal elections or polls passes SC1). The instrument is the deployed master source; the OSF pre-registration should be corrected to match.
2. **SC2 scope**: Pre-registration §3 exclusion criterion says 'Self-reported software engineering professionals (computer science / software dev / cryptography as primary occupation).' Instrument §SC2 screen-out option for professionals is 'Software engineer, developer, or programmer' — 'cryptography' is not listed as a separate screen-out option (cryptographers selecting 'Other technology professional' are NOT screened). Analysis script uses `COL_OCCUPATION = 'occupation_sw_eng'` (the software engineer flag), confirming cryptography is not separately operationalised. Pre-registration's mention of 'cryptography as primary occupation' should be corrected to match the SC2 implementation.

**No protocol or analysis impact:** The instrument SC1 and SC2 criteria are the implemented protocol; participants were enrolled per the instrument. This amendment corrects the pre-registration text to match what was actually deployed.

**Paper fix:** §4.2 updated at tick-4172 — SC1 changed to 'online election, poll, or survey' (matching instrument §SC1); SC2 changed to 'software developer, engineer, or programmer by primary occupation' (matching instrument §SC2 screen-out option; 'cryptography' removed as a distinct criterion description).

**Supporting documentation:** `docs/piup-study1-survey-instrument-2026-06-22.md` §SC1 (question text) and §SC2 (screen-out options); `analysis/piup-study1-analysis.R` line 123 (`COL_OCCUPATION = 'occupation_sw_eng'`).

---

### Amendment 16 — BI1 scale direction: paper description inverted (paper text only, pre-data)

**Type:** I (minor; paper text correction, pre-data, no protocol or analysis impact)

**Detected:** tick-4171 (2026-06-29). Cross-check of §4.4 BI1 description vs. instrument §7 code table.

**Description:** Paper §4.4 described the BI1 behavioral intent scale as '(5-point: Definitely would save it → Definitely would not save it)', implying that higher numeric codes corresponded to lower save intention (1 = save, 5 = not-save). The instrument §7 code table has the opposite mapping: 1 = Definitely would not save it, 5 = Definitely would save it (higher code = stronger save intention). The paper description was inverted. Corrected to '(5-point: 1 = Definitely would not save it, 5 = Definitely would save it; higher score = stronger save intention)'.

**Impact:** No protocol or analysis impact. BI1 is exploratory with no pre-specified confirmatory test; descriptive means are reported as-is and are not affected by this text correction. No analysis script change required.

**OSF amendment text to paste:**

> _"BI1 scale direction description corrected in paper §4.4 (pre-data): Prior text '(5-point: Definitely would save it → Definitely would not save it)' implied higher codes = less save intention. Instrument §7 codes: 1 = Definitely would not save it, 5 = Definitely would save it (higher code = stronger save intention). Paper text corrected to reflect instrument coding. No protocol or analysis impact (BI1 is exploratory; no pre-specified confirmatory test). (Pre-data, pre-OSF upload.)"_

**Supporting documentation:** `drafts/piup-chi-paper-draft-2026-06-22.md` §4.4 [Fixed tick-4171]; instrument §7 BI1 code table.

---

## Section C — Filing checklist

Complete this before OSF upload.

**Decisions:**
- [ ] Decision A resolved (Q3 wording)
- [ ] Decision B resolved (Q4 wording)
- [ ] Decision C resolved (Q3 clarification)

**Files to upload:**
- [ ] `docs/piup-study1-preregistration-2026-06-22.md` → OSF pre-registration
- [ ] `analysis/piup-study1-analysis.R` → OSF file (committed at tick-3798; **re-upload after Amendment 9 fix**)
- [ ] `docs/piup-study1-survey-instrument-2026-06-22.md` → OSF file

**Amendments to paste into OSF (Section B above):**
- [ ] Amendment 1 — G\*Power correction
- ~~[ ] Amendment 2 — VOID: Item D kept pre-reg wording; no amendment needed; do not file~~
- [ ] Amendment 3 — BI1 'this code' wording (Item E: file this)
- [ ] Amendment 4 — DescTools → base-R
- [ ] Amendment 5 — CS/SE student screener extension
- [ ] Amendment 6 — Q1 '[LABEL]' label-substitution (file this)
- [ ] Amendment 7 — Q2 '[LABEL]' label-substitution (file this)
- [ ] Amendment 8 — MQ1 '[LABEL]' label-substitution (file this)
- [ ] Amendment 9 — TOST lower.tail bug fix (file this; re-upload analysis.R)
- [ ] Amendment 10 — TOSTER package removal (file this; re-upload analysis.R)
- [ ] Amendment 11 — multcomp removal + dunn.test addition (file this; no analysis.R re-upload needed — script already correct)
- [ ] Amendment 12 — Q5 wording: 4 deviations from pre-reg §5.2 ('In your own words:' prefix; 'the system'→'this voting system'; 'NOT' emphasis; 'which option you voted for') (file this; no analysis.R re-upload needed)
- [ ] Amendment 13 — MQ1 rubric clarification: two-dimensional additive rubric (instrument §11) is operative operationalization (file this; no analysis.R re-upload needed)
- [ ] Amendment 14 — Attention check descriptions corrected: AC1 answer is 'Strongly Disagree'; AC2 asks for third list item (Carrot) (file this; no analysis.R re-upload needed)
- [ ] Amendment 15 — H2 reversed-verdict criterion p_one_tailed → p_two_tailed (file this; re-upload analysis.R)
- [ ] Amendment 16 — BI1 scale direction corrected in paper §4.4 (text only; no analysis.R re-upload needed)
- [ ] Amendment 17 — SC1 wording (pre-reg 'vote/poll/election' → instrument 'election/poll/survey') + SC2 scope ('cryptography' removed as distinct criterion; not in SC2 screen-out; paper §4.2 updated tick-4172)
- [ ] Amendment 18 — H4 ANOVA gate bug fix: `h4_support` now gates on `anova_sig`; H4-null verdict branch added; H4-partial branch added (analysis.R re-upload required)
- [ ] Amendment A — Q3 wording (if instrument wording chosen)
- [ ] Amendment B — Q4 wording (if instrument wording chosen)
- [ ] Amendment C — Q3 clarification resolution (if applicable)

**After OSF upload:**
- [ ] Copy the OSF DOI into `docs/forum-post-grant-application.md` lines 5 and 58
- [ ] Update `docs/jony-actions-audit-2026-06-23.md` Jony-action #1 as DONE
- [ ] Proceed to Jony-action #2 (Qualtrics survey creation)

---

_Document prepared by heartbeat agent tick-3803. All amendment texts are drafts — Jony should review before filing._

---

### Tick-4173 fix — §4.5 H1 note: false attribution of "pivot hypothesis" to H1 (draft note only, no OSF amendment needed)

**Type:** Paper draft note correction (not an OSF amendment — pre-registration text and protocol are unchanged)

**Detected:** tick-4173 (2026-06-29). §4.1 RQ/hypothesis spec cross-check vs. pre-registration §H1–H4.

**Description:** The §4.5 note for H1 incorrectly stated: "The OSF pre-registration designates H1 as a pivot hypothesis and states 'all three outcome patterns (supported / null / reversed) produce actionable production decisions' (pre-reg §H1)." This is factually wrong. The pre-reg §H1 section states only the directional prediction (Condition A outperforms D by ≥ 10 pp on Q2 and Q3) and the pre-registered test; it does not call H1 a pivot hypothesis and does not enumerate three named outcome patterns. The "pivot hypothesis" designation and "all three outcome patterns produce actionable production decisions" language appears ONLY in pre-reg §H2. The §4.5 note also self-contradicted the false opening claim by then saying "Unlike H2, the pre-registration decision table does not assign separate named rows to H1-null and H1-reversed" — which is consistent with H2 being the pivot, not H1.

**Fix:** §4.5 H1 note corrected (tick-4173). Note now accurately states the pre-reg does NOT designate H1 as a pivot hypothesis; that designation is exclusive to §H2. The three H1 outcome patterns remain in the note, correctly labelled as logical design implications rather than pre-reg language.

**No OSF amendment needed:** This was an error in the draft paper's internal annotation notes (bracketed [Note: ...] blocks that are stripped before submission). No body text, pre-registration, analysis script, or protocol was affected.
