# PIUP Study 4 — OSF Pre-Registration

**Title:** Does a temporal UI-lock on a vote receipt reduce coercion compliance under adversarial pressure? A 2×2 between-subjects vignette experiment.

**Status:** DRAFT — pre-registration text, not yet filed  
**Date drafted:** 2026-07-01 (tick-4388)  
**Study design doc:** `docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`  
**Authors:** Jony Bursztyn  
**OSF component:** To be registered before data collection; amendments must be filed before unblinding condition assignments.

---

## 1. Study Overview

Private voting systems issue a receipt token that proves ballot inclusion without revealing vote choice. A voter facing coercion pressure (employer demand, social threat) may be asked to show their receipt in real time. The UI design of the receipt determines whether the voter has a plausible excuse to withhold it.

Two temporal enforcement strategies have been prototyped (design spike: `docs/piup-temporal-disclosure-ux-spike-2026-07-01.md`):

- **Option D (countdown-only):** A live countdown is shown ("Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes"). The download button is enabled; the receipt can be shared at any time. The voter has a normative excuse only: "I'm not supposed to share this yet."

- **Option B (UI-lock):** The same countdown is shown, but the download and copy buttons are disabled until vote close (padlock icon; "Locked until vote closes in 5d 3h 12m"). The voter has a structural (technical-fact) excuse: "the app won't let me share this."

This study tests whether the structural excuse (Option B) reduces sharing intent compared to the normative excuse alone (Option D), and whether this advantage scales with adversarial pressure level.

**Theoretical connection:** PIUP Invariant 2 (Surrogate privacy in transit) requires that the receipt token remain private until vote close. Option B enforces this at the UX layer. Study 4 tests whether the UX enforcement generates the social deniability the design assumes — specifically, whether a technically-grounded excuse ("I can't") is more effective than a normatively-grounded one ("I shouldn't") under coercion.

---

## 2. Research Questions

**RQ4.1 (Main effect):** Does a UI-lock on the vote receipt reduce sharing intent compared to a countdown-only receipt?

**RQ4.2 (Interaction, primary):** Does the UI-lock's effect on sharing intent depend on adversarial pressure level? Specifically, is the reduction in sharing intent larger under high-pressure (explicit job-threat) than moderate-pressure (social-request) scenarios?

**RQ4.3 (Secondary):** Does the UI-lock increase participants' perceived deniability — their belief that "the app won't let me" is a convincing, socially acceptable response?

---

## 3. Design

### 3.1 Factorial structure

2 × 2 between-subjects:

| | **Moderate pressure (P1)** | **High pressure (P2)** |
|---|---|---|
| **Option D: no lock (D0)** | Cell 1 | Cell 2 |
| **Option B: UI-lock (D1)** | Cell 3 | Cell 4 |

### 3.2 Factor D — UI condition

Participants see a static screenshot of a vote receipt in one of two conditions:

- **D0 (countdown-only):** Receipt shows countdown message ("Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes"). Download button is visible and enabled. Implemented via `<VoteReceipt voteCloseTimestamp={ts} />` (temporalLock undefined, default Option D behaviour).

- **D1 (UI-lock):** Same countdown shown, but download and copy buttons are disabled with a padlock icon and text "Locked until vote closes in 5d 3h 12m". After vote close, buttons re-enable. Implemented via `<VoteReceipt temporalLock="lock" voteCloseTimestamp={ts} />` (Option B).

The countdown value displayed is **held constant at "5 days 3 hours 12 minutes"** across all four stimuli. The receipt identifier value is held constant. The only visual difference between D0 and D1 cells is the download button state (enabled vs. disabled with padlock).

### 3.3 Factor P — Coercion pressure

- **P1 (Moderate — social request):** "A colleague at work mentions they're trying to understand how the new voting system works. They ask: 'Hey, can you show me your vote receipt? I'm curious what it looks like.' You still have the vote receipt screen open on your computer."

- **P2 (High — job threat):** "Your manager calls you in and says: 'We need to verify how our team voted on this issue. If you can't show me your vote receipt right now, I'll need to question your commitment to the team.' You still have the vote receipt screen open on your computer."

### 3.4 Procedure

1. **Consent and cover story.** Study described as "understanding how people interact with digital voting systems." Duration ~8–10 minutes.

2. **Receipt display.** Participant reads: "Imagine you just finished voting in an online election through a company governance platform. After submitting your vote, you were shown the following confirmation screen." Stimulus (one of four screenshots) is displayed. A **minimum 30-second page timer** is enforced via Qualtrics page timing; participants who advance before 30 seconds see a warning.

3. **Comprehension check (DV3).** "Based on what you saw, did the receipt you received tell you or anyone else how you voted?" (Yes / No / Not sure). Correct answer: No. *(Note: DV3 incorrect answers are not excluded from the primary analysis — they are flagged for a pre-registered sensitivity analysis; see §4. The attention check is the embedded Likert item in step 6, below.)*

4. **Vignette scenario.** Scenario text (P1 or P2) displayed below the receipt screenshot (shown again in this step). The scenario is presented after the comprehension check to prevent scenario framing from priming receipt interpretation.

5. **Primary outcomes (DV1, DV2).** Presented in fixed order (DV1 → DV2) to prevent deniability priming contaminating sharing intent.

6. **Moderator and covariates (M1, C1, attention check).** Presented in randomised order within the covariate battery.

7. **Debrief.** Full debrief explaining study purpose (testing whether UI design affects coercion resistance), that scenarios were hypothetical, and real-world relevance for private voting systems. Affirms that no actual employer relationship was implicated.

---

## 4. Participants

**Target sample:** N = 160 (n = 40 per cell).

**Platform:** Prolific (US adults, English fluency).

**Inclusion criteria:**
- Prolific approval rate ≥ 95%
- English-speaking, US-based (platform filter)
- Age ≥ 18

**Exclusion and replacement criteria (pre-registered):**
- Completion time < 3 minutes total (Q_TotalDuration < 180 seconds; inattention proxy). **Note on independence of timing exclusions:** The Qualtrics page timer enforces a hard minimum of 30 seconds on the receipt-display page (Block 2) via JavaScript button-disabling; participants cannot advance before 30 seconds. This enforcement means post-hoc exclusion based on Block 2 page time alone is not expected to apply. If the JavaScript fails (rare browser-compatibility issue), the Q_TotalDuration < 180-second criterion serves as a catch-all. The two timing criteria are independent — either alone triggers replacement; they are not joint criteria.
- Failed attention check (must select "Strongly agree" on embedded item; see Attention Check in §5)
- Complete non-responder on DV1 or DV2 (system error or refusal)

Participants meeting any exclusion criterion are replaced until n = 40 per cell is reached.

**Sensitivity analysis — comprehension filter:** Participants who answer DV3 (comprehension check) incorrectly (answer "Yes — the receipt showed how I voted") are **not excluded from the primary analysis** (intent-to-treat principle) but are flagged for a pre-registered sensitivity re-analysis with this group removed (§7.2).

**Amendment protocol:** If DV3 incorrect-Yes rate exceeds 40% in any condition (indicating stimulus failure — participants believe the receipt reveals their choice), the pre-registration will be amended before unblinding condition assignments. Exclusion rate monitoring using aggregate counts; condition assignments remain blinded at that stage.

---

## 5. Measures

### Primary outcome (DV1): Sharing intent

**Item:** "If you were in this situation, how likely would you be to share the vote receipt screen with the person asking?"

**Scale:** 1 (Very unlikely) to 7 (Very likely)

Single-item, 7-point Likert. The construct (willingness to comply with a specific, concrete sharing request) is behaviourally unidimensional; single-item is appropriate and avoids construct proliferation.

**Scoring:** Higher scores = greater sharing intent = worse coercion resistance.

### Secondary outcome (DV2): Perceived deniability

**Item:** "If you were in this situation, how convincing do you think it would be to say 'I can't share this — my voting app won't let me until the vote closes'?"

**Scale:** 1 (Not at all convincing) to 7 (Very convincing)

Note on DV2 asymmetry: In D0 (no lock) cells, this item measures *counterfactual* deniability (what participants imagine would happen if they claimed the app prevents sharing, even though it does not). In D1 (UI-lock) cells, it measures *actual* deniability. This asymmetry is inherent to the design; DV2 is secondary and exploratory, and the asymmetry will be noted in the analysis.

### Attention filter (embedded, not an outcome)

"Please select 'Strongly agree' for this item." Failure → exclusion and replacement (see §4).

### Comprehension check (DV3, filter for sensitivity analysis)

"Based on what you saw, did the receipt you received tell you or anyone else how you voted?" (Yes / No / Not sure)

Correct answer: No. Used as attention/comprehension signal; see exclusion criteria.

### Moderator M1: Technology self-efficacy

**Item:** "I am confident in my ability to troubleshoot technical problems with apps and websites."

**Scale:** 1–7 Likert

Pre-registered moderator for H4.4: high self-efficacy participants may be less affected by the UI-lock excuse (they can imagine workarounds such as screenshotting), attenuating the D × P interaction.

### Covariate C1: Prior voting app experience

**Item:** "Have you ever used a digital voting platform (other than standard government voting)?" (Yes / No)

Used as covariate in sensitivity analyses only. Not predicted to moderate primary outcomes.

### Attention Check

**Item:** "For quality purposes, please select **Strongly agree** for this item."

**Scale:** 1–7 Likert (1 = Strongly disagree, 7 = Strongly agree)

**Correct response:** 7 (Strongly agree). Participants who do not select 7 are excluded and replaced (see §4 exclusion criteria). The attention check is embedded among M1 and C1 items in Block 6; item order within Block 6 is randomised so attention-check position is not predictable.

---

## 6. Hypotheses

### H4.1 — Main effect of UI-lock on sharing intent (confirmatory)

**Formal statement:** Mean sharing intent (DV1) is lower in UI-lock cells (D1; Option B) than in countdown-only cells (D0; Option D), collapsed across pressure levels.

**Direction:** D1 < D0 on DV1.

**Test:** One-tailed independent-samples t-test. IV: UI condition (D1 vs. D0); DV: DV1 as continuous; N = 160 (80 per level after collapsing over P).

**Alpha:** α = .05 (one-tailed).

**Reporting:** p-value (one-tailed), Cohen's d with 95% CI.

**Rationale:** If Option B reduces sharing intent, a main effect should be visible regardless of pressure level. Power at f = 0.25, α = .05, N = 80 per group: >99% for a main effect.

---

### H4.2 — D × P interaction on sharing intent (primary confirmatory)

**Formal statement:** The reduction in sharing intent attributable to UI-lock is larger under high-pressure (P2) scenarios than moderate-pressure (P1) scenarios.

**Formally:** (M\_D0\_P2 – M\_D1\_P2) > (M\_D0\_P1 – M\_D1\_P1)

where M\_X\_Y is the cell mean of DV1 in condition X × Y.

**Direction:** The D × P interaction is in the expected direction (UI-lock provides proportionally greater sharing-intent reduction under high pressure).

**Test:** Two-way ANOVA on DV1, factors D × P. F-test for the D × P interaction term at α = .05 (two-tailed). If the interaction is significant at α = .05, simple-effects comparisons are conducted: D1 vs. D0 within P1, and D1 vs. D0 within P2 (one-tailed t-tests at α = .05, treating these as planned comparisons).

**Reporting:** F-statistic and p-value for D × P interaction; η² (partial) for the interaction term; cell means and SDs; simple-effects results if interaction significant.

**Rationale:** Under high adversarial pressure, normative refusals ("I shouldn't share this") can be overridden by authority or threats. Technical facts ("the app won't let me") cannot be overridden by the adversary's authority alone. This asymmetry predicts that the UI-lock's advantage over countdown-only should be larger — possibly substantially larger — under high-pressure conditions.

**Power:** At f = 0.25 (interaction term, 2×2 ANOVA), α = .05, N = 160: ≈86% power. Minimum detectable interaction effect at N = 160, 80% power, α = .05: f ≈ 0.22.

---

### H4.3 — UI-lock effect on perceived deniability (secondary, confirmatory)

**Formal statement:** Perceived deniability (DV2) is higher in UI-lock cells (D1) than in countdown-only cells (D0), collapsed across pressure levels.

**Direction:** D1 > D0 on DV2.

**Test:** One-tailed independent-samples t-test. IV: UI condition (D1 vs. D0); DV: DV2 as continuous.

**Alpha:** α = .05 (one-tailed).

**Reporting:** p-value, Cohen's d with 95% CI.

**Note:** DV2 is secondary and exploratory relative to DV1. The DV2 asymmetry (counterfactual in D0, actual in D1) is noted; this limits causal inference from H4.3 but does not preclude the test. A significant H4.3 indicates that UI-lock increases perceived deniability, but the asymmetry prevents ruling out that D1 participants simply have more reason to think the phrase is accurate (it is). This will be discussed in the analysis.

---

### H4.4 — Self-efficacy moderation of the D × P interaction (exploratory)

**Formal statement:** Technology self-efficacy (M1) moderates the D × P interaction on DV1: the interaction effect (H4.2) is attenuated among participants with high self-efficacy.

**Direction:** Higher M1 → smaller D × P interaction on DV1.

**Test:** Moderated regression. DV: DV1; predictors: D (dummy, 0/1), P (dummy, 0/1), M1 (continuous, centred), D×P, D×M1, P×M1, D×P×M1. Key term: three-way D × P × M1 interaction.

**Alpha:** Not pre-specified (exploratory). Report β, 95% CI, ΔR² for three-way interaction term.

**Rationale:** High self-efficacy participants may believe they can circumvent the lock (e.g., by screenshotting the screen). If so, the structural excuse provided by D1 is less subjectively compelling for them, reducing the D × P interaction. This is a theoretically motivated but exploratory prediction.

---

## 7. Analysis Plan

### 7.1 Primary analyses (in order of priority)

1. **H4.2 (primary confirmatory — run first):** Two-way ANOVA on DV1 (UI condition × pressure level). Report F for interaction, η² partial. If F significant (α = .05, two-tailed), run planned simple effects: one-tailed t-test D1 vs. D0 within P1, and one-tailed t-test D1 vs. D0 within P2.

2. **H4.1 (confirmatory main effect):** One-tailed t-test, DV1, D1 vs. D0 (collapsed over P). Cohen's d and 95% CI.

3. **H4.3 (secondary confirmatory):** One-tailed t-test, DV2, D1 vs. D0 (collapsed over P). Cohen's d.

4. **H4.4 (exploratory moderation):** Moderated regression as specified in §6 H4.4.

### 7.2 Sensitivity analyses (pre-registered, run after primary)

**SA-1: Comprehension filter.** Exclude participants who answered DV3 incorrectly (answered "Yes — receipt revealed my vote"). Re-run H4.1 and H4.2 on the filtered sample. Report N excluded per condition.

**SA-2: Self-efficacy covariate.** Re-run H4.1 and H4.2 with M1 as a continuous covariate (not moderator). Report coefficient β for M1 and test of primary effects with M1 partialled out.

**SA-3: Prior experience covariate.** Re-run H4.1 and H4.2 with C1 (prior voting app experience, binary) as a covariate.

**SA-4: ANCOVA with M1 and C1 combined.** Re-run H4.2 with M1 and C1 as simultaneous covariates. This is the most conservative robustness check.

### 7.3 Equivalence test (null result protocol)

If H4.1 is not significant (p ≥ .05 one-tailed), a TOST equivalence test (Lakens, 2017) is run with equivalence bounds ±1 SD of DV1 (computed from the full sample SD, pooled across conditions). Bounds specified as Cohen's d_z units; equivalence is concluded if both one-sided tests reject at α = .05. If equivalence is not established, the null result is reported as ambiguous (insufficient power or small effect).

### 7.4 Data processing and blinding

- Random assignment is performed by Prolific (balanced, stratified by completion time where possible).
- Condition codes are recorded in the Qualtrics embedded data field `condition` (values: "D0P1", "D0P2", "D1P1", "D1P2").
- The researcher will remain blinded to cell-level means during data collection; only the attention-check failure rate and overall N per cell are monitored.
- Analysis script is written before data collection and deposited on OSF.

### 7.5 Multiple comparisons policy

- H4.1 and H4.2 are pre-specified confirmatory hypotheses. No correction for multiple comparisons between H4.1 and H4.2 (orthogonal tests; both registered as primary).
- H4.3 is secondary confirmatory; treated as independent from H4.1/H4.2 (different DV).
- H4.4 is exploratory; no alpha correction.
- Simple-effects comparisons within H4.2 (D1 vs. D0 within P1; D1 vs. D0 within P2) are treated as planned contrasts following a significant interaction; no additional alpha correction beyond the parent ANOVA threshold.

---

## 8. Materials

**Stimuli:** Two distinct visual stimulus variants (one per D condition), each used in two cells (D0 is used in P1 and P2 cells; D1 is used in P1 and P2 cells). Screenshot files are named by cell (`cell-D0P1.png`, `cell-D0P2.png`, `cell-D1P1.png`, `cell-D1P2.png`) for Qualtrics routing clarity, but D0P1 ≅ D0P2 (visually identical) and D1P1 ≅ D1P2 (visually identical). The pressure factor P is operationalised through the vignette text (Block 4), not through the stimulus image.

Stimulus props:
- D0 variant: `<VoteReceipt voteCloseTimestamp={ts} />` (countdown, download enabled)
- D1 variant: `<VoteReceipt temporalLock="lock" voteCloseTimestamp={ts} />` (countdown, download disabled + padlock)
- `ts` is set to render "5 days 3 hours 12 minutes" remaining
- Receipt identifier: held constant across all four screenshot files
- Vote title: held constant ("Company governance vote — Q2 infrastructure proposal")

**Survey platform:** Qualtrics. Block randomisation by condition, four-group between-subjects; one condition per participant.

**Condition assignment:** Prolific pre-screened study links (four links, one per condition) or Qualtrics block randomiser set to equal allocation. Final allocation method is noted in the study registration.

**All materials** (Qualtrics survey export, stimulus PNGs, analysis script) deposited on OSF prior to data collection.

---

## 9. Ethical Considerations

**Risk classification:** Minimal risk. Participants are not exposed to real employer pressure; the vignette scenarios are hypothetical and comparable in intensity to standard employment-related survey research.

**Minimal-risk justification for high-pressure scenario (P2):** The job-threat vignette ("If you can't show me your vote receipt right now, I'll need to question your commitment to the team") is delivered in hypothetical-present tense. No participant is in an actual employment relationship with the study; no real job consequences exist. The scenario language is calibrated to engage a genuine coercion response while remaining clearly fictional (the consent form and cover story both describe the study as involving "a short workplace scenario"; participants self-select at that disclosure). This is methodologically consistent with prior vignette research using employment-coercion scenarios in security and privacy contexts (Egelman & Felt, 2012). No occupation filters are applied in Prolific; the study does not target workers in specific vulnerable circumstances. At most institutions, vignette research using hypothetical workplace scenarios qualifies for expedited review under the "no more than minimal risk" standard.

**Deception:** Partial. The cover story ("understanding how people interact with digital voting systems") withholds the study's specific focus on coercion resistance. Active deception (false claims) is not used. Full debrief is provided at the end of the study.

**Debrief content:** Study purpose (testing whether UI design affects coercion compliance), explanation that the scenarios were entirely hypothetical, description of real-world context (privacy-preserving voting, receipt design), and contact information for questions.

**IRB pathway:** Minimal risk; expedited review expected. IRB approval is obtained before data collection.

**Vulnerable populations:** Qualtrics/Prolific populations with high approval rates are used; no targeting of vulnerable groups. The job-threat scenario language is reviewed for potential distress; language is kept professional and clearly hypothetical.

**Sequencing note (DV3 before vignette):** DV3 (comprehension check: "did the receipt tell you how you voted?") is administered in Block 3, before the vignette scenario in Block 4. Participants who correctly answer No have confirmed the receipt does not reveal their vote before reading the adversarial scenario. This may lower sharing intent in both conditions if participants reason that sharing is lower-risk once receipt privacy is confirmed. This ordering is pre-specified and unavoidable — placing the vignette before DV3 would allow coercion framing to prime the comprehension answer, severely reducing DV3 validity. The DV3-before-vignette sequence does not threaten internal validity for the D × P interaction (H4.2) because any priming effect is constant across conditions. It may attenuate the H4.1 main effect (UI-lock vs. no lock on sharing intent) by making sharing seem lower-risk in both conditions before adversarial pressure is introduced. This is a pre-registered limitation; it is reported as such in the manuscript's limitations section.

---

## 10. Decision Tree for Outcomes

| H4.1 result | H4.2 result | Interpretation | Design implication |
|---|---|---|---|
| Supported (p < .05, one-tailed) | Supported (D×P interaction, expected direction) | UI-lock reduces sharing; effect is amplified under high pressure | Deploy Option B in adversarial-context governance voting; label as most effective against high-pressure coercion |
| Supported | Not supported | UI-lock reduces sharing uniformly, regardless of pressure level | Option B is beneficial in all coercion contexts; pressure-scaling claim not empirically confirmed |
| Not supported (equivalence established) | — | Countdown + framing alone (Option D) is sufficient for sharing-intent reduction | Option B adds no measurable behavioural advantage; invest in framing copy or reminder timing for Invariant 2 enforcement |
| Not supported (not equivalent) | — | Ambiguous null (insufficient power or small effect) | Replicate with larger N before drawing design conclusion |
| Not supported | Supported (crossover interaction) | UI-lock reduces sharing under high pressure but increases it under moderate pressure (backfire) | Option B has disqualifying risk for moderate-pressure contexts; deploy only in explicitly adversarial governance settings |
| Supported | — | DV2 (deniability) high in D1 regardless of DV1 | Perceived deniability is a secondary benefit; voter confidence rationale independent of behavioural outcomes |

---

## 11. Amendment Log

*(To be completed if any amendments are filed before data collection.)*

| Date | Amendment | Reason | Filed before unblinding? |
|---|---|---|---|
| 2026-07-01 | **Amendment 4-A:** Vignette opening-word change. P1: “Imagine a colleague at work…” → “A colleague at work…”. P2: “Imagine your manager calls you in…” → “Your manager calls you in…”. Scenario meaning and hypothetical framing unchanged. No effect on DV1/DV2 scoring or hypotheses. | Pre-data (noted; OSF filing pending before data collection) |

---

## 12. Registration Checklist

- [ ] IRB approval obtained (expedited, minimal risk)
- [ ] Analysis script written and deposited on OSF
- [ ] Stimulus PNGs (4) deposited on OSF
- [ ] Qualtrics survey export deposited on OSF
- [ ] Pre-registration text registered on OSF (this document)
- [ ] Pre-registration timestamp captured before Prolific launch
- [ ] Study links (4, one per condition) generated and tested on Prolific sandbox
- [ ] Amendment protocol: any exclusion-rate trigger (DV3 > 40%) filed before unblinding

---

## 13. Related Documents

- Study design: `docs/piup-study4-temporal-coercion-vignette-2026-07-01.md`
- Temporal disclosure spike (Option B/D rationale): `docs/piup-temporal-disclosure-ux-spike-2026-07-01.md`
- Receipt-freeness theory: `docs/piup-receipt-freeness-theory-2026-06-30.md`
- VoteReceipt.tsx implementation: `packages/react/src/components/VoteReceipt.tsx`
- CHI paper §6.5: `drafts/piup-chi-paper-draft-2026-06-22.md` (Invariant 2 behavioural validation, Future Work)
- Study 3 power analysis reference: `docs/piup-study3-power-analysis-2026-06-29.md`
