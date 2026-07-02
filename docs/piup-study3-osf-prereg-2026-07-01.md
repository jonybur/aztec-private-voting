# PIUP Study 3 — OSF Pre-Registration

**Title:** Does a social proof signal on a vote receipt increase post-vote verification return rates? A two-arm between-subjects field pilot.

**Status:** DRAFT — pre-registration text, not yet filed  
**Date drafted:** 2026-07-01 (tick-4400)  
**Study design doc:** `docs/piup-study3-social-verification-2026-06-29.md`  
**Power analysis:** `docs/piup-study3-power-analysis-2026-06-29.md`  
**Pre-IRB critique:** `docs/piup-study3-preIRB-critique-2026-06-30.md` (all H+M items resolved)  
**Debrief script:** `docs/piup-study3-debrief-script-2026-06-30.md`  
**Authors:** Jony Bursztyn  
**OSF component:** To be registered before data collection begins. Amendments must be filed before unblinding condition assignments or accessing outcome data.

---

## 1. Study Overview

Private voting systems based on cryptographic verifiability (e.g., Helios, STAR-Vote, Aztec Private Voting) allow each voter to check that their ballot was counted — but prior deployments consistently report verification rates below 10% (Adida et al., 2009; Bell et al., 2013). The PIUP (Proof-of-Inclusion UX Pattern) reduces verification friction by issuing a voter a named surrogate identifier ("vote fingerprint") with explicit verification instructions and a downloadable artifact. Study 2 (separate paradigm — controlled Prolific experiment; see §9) tests explanation and calibration effects on absent-content interpretation. **Study 3 asks: does a social proof signal embedded in the PIUP receipt increase the rate at which voters return to verify?** Study 3 establishes its own verification-rate baseline via the control arm; no comparison to Study 2 data is pre-registered.

_[Amendment tick-4445 — §1 Study 2 description corrected: original text 'Study 2 (concurrent) establishes a PIUP baseline verification rate' was stale from the pre-redesign conception when Studies 2+3 shared an election. Study 2 was redesigned as a controlled single-session Prolific experiment (primary DV: Q-AC absent-content interpretation accuracy; no T+14 follow-up; no live contract). Study 2 does not measure or establish a baseline verification rate. Study 3 establishes its own baseline via the control arm. Parallel to §3.1 correction and §4 (tick-4429) and §9 (tick-4427) corrections. Pre-data; no hypothesis, DV, or analysis change.]_

Social proof (Cialdini, 1984) has been shown to increase upfront security behavior (Das et al., 2014, CCS: password manager adoption via peer-count display). Study 3 tests whether the same mechanism operates for **deferred** security behavior — returning to verify after a vote has been cast — in a private voting context where the ZK contract's public `verify_vote_counted()` function makes an aggregate verification count technically available without de-anonymizing any individual voter.

**This pre-registration is for a feasibility pilot**, not a confirmatory study. Inferential summaries use 90% confidence intervals for the odds ratio (Lakens, 2021). No NHST threshold is applied to the primary endpoint. Results will be used to calibrate a powered replication (N ≥ 280; see §6 Power and §9 Future directions).

---

## 2. Research Questions

**RQ3 (Primary):** Does a social proof counter — a publicly visible count of verified voters — increase the proportion of voters who return to verify their own receipt at T+14?

**RQ3a (Secondary, exploratory):** Does the effect of social proof on verification rates differ by technology self-efficacy? (Moderation hypothesis: social proof may matter more for low-efficacy participants, for whom the ambiguity of correct action is higher.)

**RQ3b (Secondary, exploratory):** Does exposure to social proof alter comprehension of what verification proves? (Predicted null: social proof should change whether voters verify, not what they believe verification means.)

**RQ3c (Descriptive, if log opt-in n ≥ 40):** Does social proof exposure affect the time-to-verify distribution, not only the total verification rate?

---

## 3. Design

### 3.1 Structure

**Two-arm, between-subjects field experiment** in a separate live election from Study 2 (see §4, §9). Participants are voters in a real election using the Aztec Private Voting contract. Condition assignment is random at T0 (moment of ballot submission).

_[Amendment tick-4445 — §3.1 corrected: original text 'embedded within the same live election as Study 2' was stale. Studies 2 and 3 run in separate elections (Study 2 uses a Vercel prototype with no live contract; Study 3 requires a live Aztec deployment). Parallel to §1 correction and §4 (tick-4429) and §9 (tick-4427) corrections. Pre-data; no hypothesis, DV, or analysis change.]_

| Condition | Receipt display at T0 |
|---|---|
| **Control** | Standard PIUP receipt: fingerprint, verification instruction, download button, no aggregate data |
| **Treatment** | Standard PIUP receipt + social proof counter: *"X voters have already verified their vote in this election. Verification is open until [date]."* |

### 3.2 The social proof counter

The counter value is updated every 15 minutes from public on-chain `verify_vote_counted()` call logs. It displays the raw count (not a percentage) to avoid base-rate anchoring when n is small early in the verification window.

**Counter floor (pre-registered):** To avoid negative social proof effects at very low verification counts (Cialdini, 1984) — e.g., "0 voters have verified" may actively demotivate verification — the social proof counter activates only after **≥ 5 participants have verified their receipt**. This threshold (rather than the originally considered ≥10) was chosen because at the expected pilot sample size (N = 80), a floor of 10 would not be reached at the conservative baseline verification rate (10% × 80 = 8 verifications). A floor of 5 avoids negative social proof from a "0 verified" display while remaining reachable at the conservative baseline. Before this floor is reached, the treatment receipt displays "Verification is open until [date]" without a count. This floor value (5) is the pre-registered design parameter; it will not be changed after registration.

### 3.3 Condition assignment and blinding

- Random assignment at T0 via the receipt generation function (server-side coin flip, condition encoded in the receipt session token).
- The receipt endpoint is parameterised by session; conditions are indistinguishable at the network level and from the smart contract.
- **Participants are not informed of the two-condition design at T0** to prevent demand effects. Full debrief at T+14 (see debrief script above).

### 3.4 Condition persistence across devices

The condition flag is encoded in the receipt artifact delivered at T0 (downloadable file and parameterised URL). A participant accessing their receipt from a different device sees the same condition. The counter value in the treatment condition will increase over the 14-day verification window; participants who return at T+7 or T+14 see a higher count. This is by design: the counter provides updated social context at the moment of verification decision. The time-varying nature of the counter is noted as a construct-validity consideration and labelled exploratory in the analysis plan (§6.4).

### 3.5 No T+7 reminder (pre-registered exclusion)

The current pilot **does not include a T+7 social proof reminder notification**. The manipulation is delivered exclusively at T0 via the receipt artifact. Any participant who independently receives an unsolicited T+7 prompt from the deployment platform will be flagged and analysed separately in a sensitivity analysis; they will be retained in the primary intent-to-treat analysis.

---

## 4. Participants

**Target sample:** N = 80 (n = 40 per condition).

**Population:** Voters in a live election using the Aztec Private Voting contract (separate from Study 2; see §9). Study 3 is a live-election field experiment and cannot be embedded in the same election as Study 2, which uses a controlled Vercel prototype with consequentially inert votes. Participants are real voters in an election facilitated by the deployed Aztec Private Voting v5 contract. No separate Prolific or panel recruitment is required; participants are recruited through the DAO's existing voter pool.

_[Amendment: tick-4429 — §4 Population corrected to match §9 (tick-4427). Original §4 incorrectly stated 'Study 3 is embedded in the same election as Study 2; participants overlap with the Study 2 pool.' §9 was corrected at tick-4427 to accurately state Studies 2 and 3 use different paradigms and cannot share an election. §4 was not updated at that time. This amendment corrects the inconsistency. Pre-data; no hypothesis, DV, or analysis change.]_

**Eligibility:**
- Completed ballot submission in the target election (ballot recorded on-chain)
- Received a PIUP receipt at T0 (downloaded artifact or in-browser receipt display)
- Provided opt-in consent for behavioral log analysis at T0 (consent checkbox in receipt UI)

**Power note:** At n = 40/condition (N = 80), this study is underpowered for NHST at OR = 2.0 (power = 32–53% across plausible baselines; see power analysis document). The pilot is pre-registered as a feasibility study. Inferential output is the 90% CI for OR; results calibrate a powered replication (N ≥ 280).

---

## 5. Measures

### Primary outcome (DV1): Verification at T+14

**Operationalisation:** Binary indicator (0/1). A participant is coded 1 if they called `verify_vote_counted()` with a valid receipt ID on-chain at any time within the 14-day post-vote window. Receipt IDs are pseudonymous (randomly generated at T0, not wallet-linked); verification calls are matched to participants by receipt ID with participant consent.

**Measurement timing:** T0 to T+14 (14 calendar days after ballot submission).

**Definition note:** Verification requires a successful on-chain call (call returned true); a call that returns false (receipt ID not found) is coded 0. Partial attempts (network error, aborted call) that do not produce an on-chain event are coded as missing and excluded from intent-to-treat analysis with sensitivity check.

### Secondary outcomes

**DV2 — Stated intent to verify (T0, self-report):** "How likely are you to come back to this receipt to verify your vote was counted?" (1 = Very unlikely, 7 = Very likely). Administered at T0 immediately after receipt display, while participants are unaware that a two-condition design is in operation. Note: participants who vote after the counter floor is reached will have already seen the social proof counter when DV2 is measured; DV2 is post-treatment for this subgroup (see §7.8).

**DV3 — Verification comprehension (T+14, self-report):** Abbreviated Q1–Q4 rubric adapted from Study 1 (L2 context-shift note: in Study 1, Q1–Q4 measure label-level privacy mental models; here the rubric is adapted to measure comprehension of verification purpose — whether the participant correctly understands that verifying confirms counting but not vote content). Labelled "adapted" in all study materials. Predicted null condition difference.

**DV4 — Affect toward receipt (T+14):** Two-item trust composite: "The receipt convinced me my vote was counted" and "I understand what the receipt is for" (1–7 each, mean composite).

### Process measure (opt-in only)

**DV5 — On-chain verification log (opt-in consent at T0):** Timestamped `verify_vote_counted()` calls, matched by receipt ID. Used for time-to-verify survival analysis (RQ3c). Participants who do not opt in are excluded from DV5 analysis only; primary analysis (DV1) uses participant-reported behavior to maintain full sample.

### Moderator

**M1 — Technology self-efficacy:** 4-item adapted Compeau-Higgins scale (1–5 each, mean composite). Administered at T0 post-receipt, pre-scenario. Exploratory only: condition × self-efficacy interaction (RQ3a).

### Covariate

**C1 — Stated reason for verifying / not verifying (T+14, open-ended):** Free-text field. Qualitative only; not coded for confirmatory analysis. Used to generate hypotheses for the powered replication.

---

## 6. Power and Inferential Framework

**This study is a feasibility pilot; no NHST threshold is applied to the primary endpoint.**

**Primary inferential summary:** Point estimate and 90% confidence interval for the odds ratio of the condition effect on DV1 (verification at T+14), from logistic regression (see §7.1).

**90% CI choice:** Consistent with pilot-study convention (Lakens, 2021): the 90% CI is used to calibrate the powered replication, not to draw a confirmatory inference. The choice of 90% (rather than 95%) reflects the feasibility purpose.

**Pre-specified interpretation rule (filed with OSF, not to be changed post-data):**

| 90% CI lower bound | 90% CI upper bound | Interpretation |
|---|---|---|
| ≥ 1.5 | (any) | Social proof effect plausible; consistent with Das et al. (2014). Proceed to powered replication (N ≥ 280). |
| < 1.5 | ≥ 1.0 | Effect uncertain; CI width and baseline rate used to select powered replication N from power analysis Table 2. |
| (any) | < 1.0 | Counter may suppress verification; investigate mechanism before replication. Do not proceed to powered replication without design revision. |

**Power notes for planning (from power analysis document):**
- To detect OR = 2.0 at 80% power (α = .05, two-tailed): N = 280 (baseline p₁ = 0.10) to N = 172 (baseline p₁ = 0.20).
- The pilot estimate and CI constrain the powered replication target.

---

## 7. Analysis Plan

### 7.1 Primary analysis (DV1)

Logistic regression: **DV1 ~ Condition + T0_intent (DV2) + self_efficacy (M1)**

- Condition coded 0 = Control, 1 = Treatment.
- T0_intent and self_efficacy included as continuous covariates (mean-centred).
- Coefficient of interest: condition β, exponentiated to odds ratio with 90% CI.
- No NHST p-value threshold applied to this coefficient.
- Apply pre-specified interpretation rule (§6).
- Report verification rates per condition (raw fractions and 95% binomial CIs for descriptive purposes).

### 7.2 Sensitivity analysis 1 — Exclusion of partial verifiers

If any participant made a `verify_vote_counted()` call that failed (receipt ID not found, e.g., due to network error) and was coded missing in the primary analysis, re-run logistic regression treating them as 0 (non-verifier). Report difference in OR.

### 7.3 Sensitivity analysis 2 — Per-protocol (opt-in log subsample)

Repeat primary analysis restricted to participants who opted into log monitoring (DV5). This subsample's DV1 is based on direct on-chain events rather than self-report; compare OR estimates for self-report vs. on-chain DV1 within this subsample.

### 7.4 Exploratory: Moderation by self-efficacy (RQ3a)

Add condition × self_efficacy interaction to the logistic regression. If interaction coefficient p < .10: stratify sample by self-efficacy tertile (pre-registered cut: tertile split at T0 data, not post-hoc). Report OR by tertile. No primary inference drawn from interaction (underpowered at pilot n).

### 7.5 Exploratory: Comprehension (RQ3b)

χ² test on Q1–Q4 composite accuracy (DV3) across conditions. Report raw proportions. Predicted null. Labelled exploratory; underpowered at pilot n for any non-trivial effect.

### 7.6 Descriptive: Time-to-verify (RQ3c, opt-in subsample only)

If log opt-in n ≥ 40: Kaplan-Meier survival curves by condition; log-rank test for difference in time-to-first-`verify_vote_counted()` call. Labelled descriptive. No confirmatory inference.

### 7.7 Amendment protocol

If the counter floor (≥5 verified) is not reached before T+14 in the treatment condition, the social proof counter will never have activated. In this case, the treatment was not delivered as designed. Pre-specified response: treat this as a manipulation failure; report verification rates descriptively without the logistic regression primary analysis; document for powered replication design revision.

**Note on floor calibration:** The floor of 5 was chosen to be reachable at the conservative baseline (p₁ = 0.10, N = 80 → expected 8 verifications), unlike the originally considered floor of 10 (which would not be reached at p₁ = 0.10). At the PIUP-elevated baseline expected from Study 2 (p₁ ≥ 0.15, N = 80 → ≥12 verifications), the floor is cleared comfortably. If the floor of 5 is not reached before T+14, manipulation failure applies and results are reported descriptively. This constitutes an extreme implementation failure scenario (< 5 of ~80 participants verifying), which would indicate a fundamental baseline problem to be documented for the powered replication.

### 7.8 Sensitivity analysis 3 — DV2 timing heterogeneity

For participants who voted after the counter floor was reached, DV2 (stated intent to verify) was administered after exposure to the social proof counter and is therefore a post-treatment variable. Including DV2 as a covariate in the primary analysis (§7.1) may introduce post-treatment bias for this subgroup.

Sensitivity analysis 3: re-run the primary logistic regression excluding DV2 as a covariate (i.e., `DV1 ~ Condition + self_efficacy (M1)` only). Compare condition OR and 90% CI with and without DV2. If estimates differ by >10% in either direction, report both and note the post-treatment bias mechanism. Label exploratory.

---

## 8. Ethical Considerations

**Disclosure:** Participants consent to "research on how voters use their receipts after a vote." The existence of two receipt versions is not disclosed at T0 to prevent demand effects. Full debrief at T+14.

**Partial disclosure framing:** Participants are not informed of the two-condition design at T0. This constitutes incomplete disclosure, justified by the minimal-risk nature of the manipulation (one receipt version includes publicly available aggregate count data; neither version affects the privacy of the voter's ballot) and mitigated by full debrief at T+14 (see `piup-study3-debrief-script-2026-06-30.md`).

**Privacy of the counter:** The social proof counter shows a count, not identities. The counter is computed from public smart contract logs. No individual voter is identifiable from the count display. The count is real and accurate; participants in the treatment condition see genuine social behavior.

**Coercion-surface note:** The counter does not display which voters verified, only how many. This is consistent with the privacy-preserving design documented in Nissen et al. (2025), who found that counter-strategies are more effective when coercer visibility is low. A count without individual identities does not increase the coercion surface relative to the control condition.

**Log monitoring consent:** DV5 (on-chain log analysis) is opt-in at T0. Consent is separate from general study consent. Non-opt-in participants are excluded from DV5 analysis only; their primary DV1 is based on self-report at T+14.

**Anticipated IRB category:** Exempt or expedited review (45 CFR 46.104(d)(2)). The manipulation (showing a publicly available aggregate count) carries minimal risk. IRB review will confirm: (a) debrief adequately explains the two-condition design; (b) the social proof counter is not misleading; (c) the log opt-in process is distinct from implied consent through participation.

---

## 9. Relation to Study 2

Study 2 and Study 3 address different phases of the PIUP behavioral arc and use different paradigms. **Study 2** is a controlled single-session experiment: participants are recruited via Prolific, interact with the actual VoteReceipt.tsx component hosted on Vercel in study mode (download-button click is logged but no file is written; the vote is consequentially inert), and answer questionnaires immediately after receipt exposure (T0 only). Study 2's primary outcome is absent-content interpretation accuracy (Q-AC; H2.1), not verification return rate. Study 2 has no T+14 follow-up component.

**Study 3** is a field experiment requiring a live DAO election with the Aztec Private Voting contract deployed on testnet (or mainnet). Participants are real voters who receive a real, downloadable receipt and can interact with the `verify_vote_counted()` function 14 days after casting their ballot. The social proof counter manipulation draws from actual on-chain verification counts, not simulated data.

Because Study 2 uses a simulated Vercel prototype and Study 3 requires a live contract deployment, they cannot be embedded in the same election. The Study 3 pre-registration must be filed independently of Study 2's OSF upload. The timing dependency is: Study 1 H4 outcome is needed to confirm Study 2 N and to set the Study 3 pool estimate; Study 3 data collection requires a separate live election in parallel with or following Study 2 data collection.

**Study 3 participant pool:** Voters in a live election using the deployed Aztec Private Voting v5 contract. Recruitment proceeds through the DAO's existing voter pool (no Prolific). No additional questionnaire recruitment is required beyond the election itself; T0 and T+14 measures are embedded in the voting flow and a follow-up email (if IRB-approved follow-up contact mechanism is in place).

_[Amended tick-4427: §9 rewrote to accurately reflect that Study 2 is a controlled Vercel prototype (no T+14, primary DV = Q-AC accuracy) and Study 3 is a separate live-election field experiment. The original §9 incorrectly described Study 2 as a field experiment with T+14 measures and verification-rate DV — this reflected an earlier design conception that was superseded when Study 2 was redesigned as a controlled factorial experiment (pre-reg finalized 2026-06-29). Design dependency unchanged: Study 1 H4 gates Study 2 N, which sets Study 3 pool estimate. This amendment is pre-data and does not alter any hypothesis, DV, or analysis plan.]_

---

## 10. Future Directions (Powered Replication)

The pilot is designed to feed into one of three replication options (see `docs/piup-study3-power-analysis-2026-06-29.md` §2):

**Option A — Sequential election deployment (preferred, 12–18 months):** Recruit 3–4 additional DAO or institutional elections; aggregate participants across elections using random-effects logistic regression (site as clustering variable). Use pilot OR estimate and 90% CI to set per-election recruitment target.

**Option B — Platform partnership (opportunistic, faster):** A research agreement with a platform (e.g., Vocdoni, which has 1,000+ elections and a public verification API) would allow Study 3 to scale without requiring a new voter pool. Platform-neutral: the social proof counter is implementation-neutral; privacy-preserving properties are strongest on Aztec but the manipulation is deployable on any system with a public verification count.

**Option C — Prolific field panel supplement:** Prolific-based simulated election as secondary robustness check alongside field data; not the primary replication vehicle.

**Registered report target (post-pilot):** Use Study 3 pilot data + Study 1 outcome measures to submit a Stage 1 registered report to CSCW 2027, CHI 2028 LBW, or *Behaviour & Information Technology*. Stage 1 acceptance is blind to results.

---

## 11. References

- Adida, B., de Marneffe, O., Pereira, O., & Quisquater, J.-J. (2009). Electing a university president using open-audit voting. *EVT/WOTE 2009*.
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., et al. (2013). STAR-Vote: A secure, transparent, auditable, and reliable voting system. *EVT/WOTE 2013*. USENIX Association.
- Cialdini, R. B. (1984). *Influence: The Psychology of Persuasion*. Harper Collins.
- Das, S., Kramer, A. D. I., Dabbish, L. A., & Hong, J. I. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. In *Proceedings of the 21st ACM Conference on Computer and Communications Security (CCS '14)* (pp. 739–749). ACM. https://doi.org/10.1145/2660267.2660271
- Lakens, D. (2021). Sample size justification. *Collabra: Psychology, 8*(1), 33267. https://doi.org/10.1525/collabra.33267
- Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., & Kulyk, O. (2025). Voting under pressure: Perceptions of counter-strategies in internet voting. *E-VOTE-ID 2025*, LNCS vol. 16028, pp. 158–174.

---

## Registration Checklist

Before filing on OSF (complete in order):

- [ ] Study 2 design is finalized and Study 2 pre-reg is filed (Study 3 runs in a separate live election, not embedded in Study 2's Vercel prototype experiment; see §9)
- [ ] Study 1 H4 outcome available (informs whether Study 2 proceeds with N=240 or N=160, which sets the available Study 3 pool)
- [ ] Counter floor value confirmed as 5 (pre-registered; chosen over ≥10 for pilot reachability at N=80)
- [ ] No T+7 reminder confirmed (not in deployment pipeline)
- [ ] Logistic regression specification confirmed with statistician (covariates, centering)
- [ ] Debrief script finalized (`piup-study3-debrief-script-2026-06-30.md`)
- [ ] Log opt-in consent form text finalized
- [ ] This document uploaded as OSF pre-registration component
- [ ] **Do not access outcome data (DV1) until registration is confirmed filed**

---

## Amendment Protocol

Amendments must be filed on OSF before unblinding condition assignments. Anticipated amendment triggers:

1. Counter floor not reached by T+14 (manipulation failure — see §7.7)
2. Self-efficacy measure changes (scale substitution)
3. Study 1 H4 outcome forces Study 2 N revision that materially changes Study 3 pool size
4. Any covariate added post-registration

Amendments do not require restarting data collection if condition assignments remain blinded at time of filing.
