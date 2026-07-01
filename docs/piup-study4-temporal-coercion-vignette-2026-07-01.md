# PIUP Study 4: Temporal UI-Lock and Social Deniability Under Coercion Pressure

**Date:** 2026-07-01 (tick-4386)  
**Status:** Design — pre-IRB  
**Author:** @jonybur  
**Connects to:** `docs/piup-temporal-disclosure-ux-spike-2026-07-01.md`, `docs/piup-study3-social-verification-2026-06-29.md`, `docs/piup-receipt-freeness-theory-2026-06-30.md`, `drafts/piup-chi-paper-draft-2026-06-22.md` §6.5

---

## Positioning note

Study 4 is a vignette factorial experiment, not a field study. It requires no deployed election and no real receipt artifact. It tests a targeted causal question about **UX design choice** that Studies 1–3 leave open.

| Study | Design | Core question |
|-------|--------|---------------|
| 1 | Controlled lab (Prolific) | Which label produces accurate privacy mental models? |
| 2 | Longitudinal field (real election) | Do voters return to verify? What drives the intention-behavior gap? |
| 3 | Field + manipulation (social proof) | Does aggregate verification count increase individual verification rates? |
| **4** | **2×2 between-subjects vignette (Prolific)** | **Does a UI-lock (Invariant 2 enforcement) reduce coercion sharing under high-pressure adversarial scenarios? Is the reduction larger at high vs. moderate pressure?** |

Study 4 operationalises the open empirical question from the temporal disclosure spike: does the social deniability afforded by a true UI constraint ("the app won't let me share it until the vote closes") reduce sharing intent under coercion, and does this effect scale with adversarial pressure? It does not require waiting for Study 1–3 data; it can run independently.

---

## 1. Research questions

**RQ4.1 (Main effect):** Does a UI-lock on the vote receipt — preventing download/copy during the pre-vote-close window — reduce sharing intent compared to a countdown-only receipt (no technical barrier)?

**RQ4.2 (Interaction):** Does the UI-lock's effect on sharing intent depend on the level of adversarial pressure? Specifically, is the reduction in sharing intent larger under high-pressure scenarios (explicit job-threat framing) than moderate-pressure scenarios (social request framing)?

**RQ4.3 (Secondary):** Does the UI-lock increase participants' perceived deniability — their belief that "the app won't let me share this" is a convincing and socially acceptable response to the coercion request?

---

## 2. Theoretical motivation

### 2.1 The social deniability mechanism

Option D (countdown-only, implemented in tick-4385) makes the temporal sharing constraint salient but does not enforce it. A voter who receives a coercive request has only a *soft* excuse: "I'm not supposed to share this yet." This excuse is true but requires the voter to assert a normative claim ("the rules say I shouldn't"), which a determined adversary can override ("I don't care about the rules — show me anyway").

Option B (UI-lock + countdown) adds a *structural* excuse: "the app won't let me share this — I literally cannot." This excuse is a truthful statement about a technical constraint, which:
1. Cannot be undermined by the adversary's authority or pressure alone (they cannot compel the voter to have technical capability they lack).
2. Shifts the social dynamics: the voter is not *refusing* — they are *unable*, which changes the moral framing for both parties.
3. Is *deniable in the receipt-freeness sense*: a coerced voter can point to the system as the agent of refusal, not themselves.

This is the social deniability mechanism proposed by the temporal disclosure spike. The key theoretical claim is that a *technically-grounded* excuse is more effective than a normatively-grounded one, and that this advantage scales with pressure: under high pressure, the adversary can override normative barriers but cannot override technical facts.

### 2.2 Connection to Invariant 2 and passive receipt-freeness

PIUP Invariant 2 (Surrogate privacy in transit) requires that the receipt token remain private until vote close. Option B enforces this at the UX layer by disabling download and copy during the pre-close window. Study 4 tests whether this UX enforcement produces an observable behavioural difference in simulated coercion scenarios — the empirical test of whether Invariant 2 enforcement generates the social deniability that its design rationale assumes.

The property tested is *passive receipt-freeness* at the artifact layer: whether the UX design prevents a coerced voter from constructing a usable vote proof, not through technical unforgeability (Benaloh & Tuinstra, 1994), but through the friction and social dynamics created by the temporal lock. Study 4 is therefore a direct test of the behavioural assumption underlying the Invariant 2 UI rationale.

### 2.3 Why vignette is appropriate here

A vignette experiment is appropriate for Study 4 because:
- The behaviour of interest (compliance with a coercion request) cannot be elicited in a real field study without genuine ethical harm.
- Vignette methodology is standard for coercion-adjacent research in security and privacy (Egelman & Felt, 2012; Das et al., 2014's survey arm).
- The focal question is about *intent and perception* under simulated pressure, not actual field behaviour — vignette ecological validity is sufficient for the causal inference target.

A within-subjects design would introduce demand effects (participants would notice the manipulation). Between-subjects is required.

---

## 3. Design

### 3.1 2×2 between-subjects factorial

| | **Moderate pressure** | **High pressure** |
|---|---|---|
| **No lock (Option D)** | Cell 1: countdown-only + social request | Cell 2: countdown-only + job threat |
| **UI-lock (Option B)** | Cell 3: UI-lock + countdown + social request | Cell 4: UI-lock + countdown + job threat |

**Factor D — UI condition:**
- **Option D (no lock):** Participant sees a screenshot of the receipt with a countdown: *"Sharing is safe in 5 days 3 hours 12 minutes — after the vote closes. Until then, keep this receipt private."* The download button is visible and enabled.
- **Option B (UI-lock):** Participant sees a screenshot of the receipt with the same countdown but with a locked download button: *"Download locked until vote closes in 5 days 3 hours 12 minutes. After the vote closes, you can download and share your receipt safely."* A padlock icon is visible on the button.

**Factor P — Coercion pressure:**
- **Moderate (social request):** *"Imagine a colleague at work mentions they're trying to understand how the new voting system works. They ask: 'Hey, can you show me your vote receipt? I'm curious what it looks like.' You still have the vote receipt screen open on your computer."*
- **High (job threat):** *"Imagine your manager calls you in and says: 'We need to verify how our team voted on this issue. If you can't show me your vote receipt right now, I'll need to question your commitment to the team.' You still have the vote receipt screen open on your computer."*

Both scenarios are presented immediately after the participant reads a description of the post-vote receipt they received (with screenshot), before any comprehension questions.

### 3.2 Stimuli

Four static stimuli (one per cell), delivered as inline images in Qualtrics. Each shows:
- A VoteReceipt.tsx screenshot in the relevant condition (Option D or Option B)
- The lock state is visually obvious (enabled download button vs. greyed-out padlock button)
- The countdown timer value is held constant across all four stimuli (5 days 3 hours 12 minutes)
- The receipt identifier value is held constant across conditions

The vignette scenario (moderate vs. high pressure) is shown as text *below* the receipt screenshot, after the participant has had time to read the receipt. This ordering prevents the scenario from priming interpretation of the receipt.

**Stimulus construction:** Use existing VoteReceipt.tsx with `voteCloseTimestamp` set and the TemporalDisclosure component active (Option D baseline). For Option B cells, add a `disabled` prop to the download button with a padlock SVG icon and updated copy. Stimuli are static PNGs — no interactive voting flow is required.

---

## 4. Participants

**Target:** N = 160 (n = 40 per cell).

**Recruitment:** Prolific, US adults, English fluency, no restriction on prior voting app use (natural variation in familiarity is a covariate).

**Exclusion criteria (pre-registered):**
- Prolific approval rate < 95%
- Completion time < 3 minutes (inattention)
- Failed attention check (see §6 measures)
- Complete non-responder on primary outcome items

**Replacement:** Participants meeting exclusion criteria are replaced until n = 40/cell.

---

## 5. Power analysis

**Primary test (H4.2, interaction):** 2×2 factorial ANOVA, F-test for D × P interaction.

Inputs:
- Effect size f = 0.25 (medium; analogous to the UI-friction-reduction effects in Das et al. 2014 survey arm; plausible given the structural vs. normative excuse distinction is qualitatively large but unverified)
- α = .05, two-tailed
- Power = 0.80

G*Power 3.1 (F-test, ANOVA: fixed effects, special, main effects and interactions, groups = 4):
- Total N required: **N ≈ 128** (32/cell) for 80% power at f = 0.25
- **N = 160** (40/cell) gives ≈ 86% power at f = 0.25

Sensitivity analysis:
- At f = 0.15 (small-medium): 160 participants yield ~52% power — underpowered. If the effect is this small, Study 4 would be exploratory for the interaction.
- At f = 0.35 (medium-large): 128 participants yield ~97% power.

**Minimum detectable effect at N = 160, 80% power, α = .05:** f ≈ 0.22 (2×2 interaction).

**Main effect of D (RQ4.1):** Powered identically (1 df numerator, 156 df denominator). At f = 0.25, 80% power, α = .05: N = 64 is sufficient; N = 160 gives ~99% power for the main effect. If the main effect is null, the interaction test has priority.

**Main effect of P:** Not the primary theoretical interest; treated as a covariate in sensitivity analyses.

---

## 6. Measures

### Primary outcome (DV1): Sharing intent

**Item:** "If you were in this situation, how likely would you be to share the vote receipt screen with the person asking?" *(1 = Very unlikely, 7 = Very likely)*

Single-item, 7-point Likert. Single-item is appropriate because the construct (willingness to comply with a specific, concrete sharing request) is behaviorally unidimensional.

### Secondary outcome (DV2): Perceived deniability

**Item:** "If you were in this situation, how convincing do you think it would be to say 'I can't share this — my voting app won't let me until the vote closes'?"
*(1 = Not at all convincing, 7 = Very convincing)*

Note: DV2 is equally interpretable in both UI conditions. In the Option D (no lock) condition, this question measures *counterfactual* perceived deniability — what the participant imagines would happen if they said the app won't let them, even though it would. In the Option B condition, it measures *actual* perceived deniability. This asymmetry should be noted in the analysis; DV2 is secondary and exploratory.

### Secondary outcome (DV3): Comprehension check (not an outcome)

"Based on what you saw, did the receipt you received tell you or anyone else how you voted?" (Yes / No / Not sure)

Correct answer: No. Used as an attention/comprehension filter: participants who answer Yes are flagged for sensitivity analysis (retained in primary ITT analysis). High incorrect-Yes rate in Option B may indicate that the lock UI triggered a negative inference ("they're hiding my vote choice").

### Moderator (M1): Technology self-efficacy

**Measure:** Single-item: "I am confident in my ability to troubleshoot technical problems with apps and websites." (1–7 Likert). Pre-registered as moderator of H4.2: high self-efficacy participants may be less affected by the UI-lock excuse (they can imagine workarounds), reducing the interaction effect.

### Covariate (C1): Prior voting app experience

Binary: "Have you ever used a digital voting platform (other than standard government voting)?" (Yes/No). Used as covariate in sensitivity analyses only; not predicted to moderate primary outcomes.

### Attention check

"Please select 'Strongly agree' for this item." (Embedded in covariate battery.) Participants who fail are excluded and replaced.

---

## 7. Hypotheses

**H4.1 (main effect, confirmatory):** Mean sharing intent (DV1) is lower in Option B (UI-lock) cells than in Option D (countdown-only) cells, collapsed across pressure levels.
- *Direction: B < D*
- *Test: One-tailed independent-samples t-test (UI-lock vs. no-lock, DV1 as continuous), α = .05*
- *Preregistered threshold: p < .05 one-tailed, Cohen's d reported*

**H4.2 (interaction, primary confirmatory):** The reduction in sharing intent attributable to UI-lock (D – B) is larger under high pressure than moderate pressure.
- *Formally: (M\_D\_high – M\_B\_high) > (M\_D\_moderate – M\_B\_moderate)*
- *Direction: D × P interaction in the expected direction*
- *Test: 2×2 ANOVA, F-test for D × P interaction term, α = .05 two-tailed; followed by planned simple effects (B vs. D within each pressure level)*
- *Rationale: High-pressure adversaries are more likely to override normative refusals but cannot override technical facts. The UI-lock provides a true-capability excuse that scales in value with pressure.*

**H4.3 (secondary, exploratory):** Perceived deniability (DV2) is higher in Option B cells than Option D cells. No directional prediction for the D × P interaction on DV2.
- *Test: One-tailed independent-samples t-test, α = .05; interaction tested two-tailed as exploratory*

**H4.4 (moderation, exploratory):** Technology self-efficacy (M1) moderates H4.2: the D × P interaction on DV1 is attenuated among participants with high self-efficacy.
- *Test: Moderated regression, 2×2×M1, exploratory (no alpha level pre-specified); reported as partial effect size and 95% CI*

---

## 8. Procedure

1. **Welcome and consent.** Study described as "understanding how people interact with digital voting systems." Duration ~8–10 minutes. Prolific.
2. **Receipt display.** Participant reads: "Imagine you just finished voting in an online election through a company governance platform. After submitting your vote, you were shown the following confirmation screen." Stimulus (screenshot, one of four) displayed for minimum 30 seconds before proceeding.
3. **Comprehension check (DV3).** "Based on what you saw, did the receipt you received tell you or anyone else how you voted?" — ensures the participant read the receipt.
4. **Vignette scenario.** Scenario text (moderate or high pressure) displayed.
5. **Primary outcomes (DV1, DV2).** Presented in fixed order (DV1 then DV2) to prevent deniability priming contaminating sharing intent.
6. **Moderator and covariates (M1, C1, attention check).** Presented in random order within a battery.
7. **Debrief.** Full debrief: study purpose (testing whether UI design affects coercion resistance), explanation that the scenarios were hypothetical, description of real-world relevance for private voting systems.

**Timing control:** Qualtrics `Page Timer` enforces minimum 30-second receipt viewing time. Participants who advance before 30 seconds are shown a warning. This is pre-registered as an exclusion criterion for completion time.

---

## 9. Analysis plan

### Primary analyses

1. **H4.2 (interaction, primary):** Two-way ANOVA on DV1 with factors D (lock vs. no lock) × P (moderate vs. high pressure). F-test for interaction. If significant, planned simple-effects comparisons: B vs. D within moderate-pressure cells, B vs. D within high-pressure cells. Report η² partial for interaction term.

2. **H4.1 (main effect):** One-tailed t-test on DV1, lock vs. no-lock (collapsed). Report Cohen's d with 95% CI.

3. **H4.3 (deniability, secondary):** One-tailed t-test on DV2, lock vs. no-lock. Report Cohen's d.

### Sensitivity analyses

- **Comprehension filter:** Rerun H4.1 and H4.2 excluding DV3 incorrect responders.
- **Self-efficacy moderation (H4.4):** Moderated regression with M1 as continuous moderator; report interaction term β, 95% CI, ΔR².
- **Prior experience covariate (C1):** Rerun H4.1 and H4.2 with C1 as covariate to check robustness.

### Equivalence test

If H4.1 is null (no main effect of UI-lock): TOST (Lakens, 2017) with equivalence bounds ±1 SD of DV1 to confirm whether the null result indicates true equivalence or merely underpowered effect.

---

## 10. Ethical considerations

### Deception

The vignette scenarios involve an adversarial employer. Participants are not actually put under coercion; they are asked to rate their intentions in a *hypothetical* scenario. This is standard vignette methodology and does not require active deception. The cover story ("understanding how people interact with digital voting systems") is a neutral partial-disclosure, not a false claim. Full debrief follows.

**IRB risk level:** Minimal risk. No participant is actually exposed to employer pressure; scenario language is comparable to standard employment-vignette research. Debriefing is required given the stress-inducing scenario language ("I'll need to question your commitment").

### Demand characteristics

The within-scenario ordering (receipt display → comprehension check → scenario → DV1 → DV2) minimises demand: DV1 is the first outcome item, before the deniability framing (DV2) is introduced. High self-efficacy participants may still anchor on workarounds ("I could screenshot it"), but this is a realistic individual difference that does not invalidate the design.

### Pre-registration target

OSF. Pre-register before data collection. Amendment process: if any DV3-based exclusion rate exceeds 40% (indicating stimulus failure), pre-register an exclusion before unblinding condition assignments.

---

## 11. Expected outcomes and decision tree

| Result | Interpretation | Design implication |
|--------|---------------|-------------------|
| H4.1 supported, H4.2 supported | UI-lock reduces sharing; effect largest under high pressure | Ship Option B in adversarial-context deployments; label as "most effective against high-pressure coercion" |
| H4.1 supported, H4.2 not supported | UI-lock reduces sharing uniformly across pressure levels | Option B is valuable in any coercion context; pressure-scaling claim is not empirically confirmed |
| H4.1 not supported (null), equivalence confirmed | Countdown + framing alone (Option D) is sufficient | Option B adds no measurable sharing-intent reduction; invest in other Invariant 2 enforcement (framing copy, reminder timing) |
| H4.1 not supported, H4.2 supported (crossover) | UI-lock reduces sharing under high pressure but *increases* it under moderate (backfire) | Option B has disqualifying risk for moderate-pressure contexts; deploy only in explicitly adversarial governance contexts |
| DV2 high in Option B regardless of DV1 | Perceived deniability is strong even if sharing intent does not shift | The *perception* of having a UI-backed excuse is valuable for voter confidence; document as a secondary design rationale independent of behavioral outcomes |

---

## 12. Study 4 position in the PIUP paper

Study 4 is not currently in the CHI 2027 draft. Two integration options:

**Option A (Future Work mention):** Add one paragraph to §6.5 Limitations noting that Invariant 2 UI enforcement is not empirically validated against behavioural coercion outcomes, and citing Study 4 as the pre-registered confirmatory test. This adds ~80 words and is safe regardless of Study 4's timeline.

**Option B (Full study section):** If Study 4 data is available before the September 10, 2026 CHI deadline, add §6 as a Study 3-equivalent section and retitle §5 as Study 2. At N=160, Prolific completion time ~10 minutes/participant, this study could complete in 2–3 weeks if launched by mid-July. **Feasibility: possible pre-deadline, but tight.** Would require IRB (minimal risk; expedited review likely feasible in ~2–3 weeks at GT/CMU).

**Recommended:** Start with Option A (add Future Work mention to §6.5 now, tick-4387), run Study 4 before CHI deadline, upgrade to Option B if data is complete.

---

## 13. Stimulus construction checklist

- [ ] VoteReceipt.tsx: confirm `voteCloseTimestamp` prop works and TemporalDisclosure renders countdown correctly (done, tick-4385)
- [ ] Option B: add `disabled` + padlock + updated copy to download button in VoteReceipt.tsx (new work — estimate 1 hour)
- [ ] Export 4 static PNGs: 2 UI conditions × 2 (done from VoteReceipt; take screenshots)
- [ ] Qualtrics: build 4-condition survey with stimulus images, DV1–DV2, M1, C1, attention check, debrief
- [ ] OSF: pre-register before data collection (hypotheses, measures, analysis plan, N=160 target, exclusion criteria verbatim)

---

## Related documents

- `docs/piup-temporal-disclosure-ux-spike-2026-07-01.md` — Option B/D design rationale; Study 4 first mentioned here
- `docs/piup-receipt-freeness-theory-2026-06-30.md` — passive receipt-freeness; Invariant 2 theoretical grounding
- `docs/piup-study3-social-verification-2026-06-29.md` — Study 3 design; Study 4 labelled "optional" in earlier protocol
- `docs/piup-study3-power-analysis-2026-06-29.md` — power analysis reference (Study 3)
- `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` — Invariant 2 canonical definition
- `packages/react/src/components/VoteReceipt.tsx` — implementation (countdown added tick-4385; Option B lock to add)
