# PIUP Study 3: Social Verification in Private Voting

**Date:** 2026-06-29  
**Status:** Design — pre-IRB  
**Author:** @jonybur  
**Connects to:** Das et al. (2014), `piup-study-protocol-2026-06-22.md`, `piup-study2-design-note-2026-06-22.md`, `piup-study3-power-analysis-2026-06-29.md`

---

## Positioning note

The three-study PIUP agenda is:

| Study | Design | Core question |
|-------|--------|---------------|
| 1 | Controlled lab (Prolific) | Which label (fingerprint / confirmation code / nullifier / receipt ID) produces accurate privacy mental models? |
| 2 | Longitudinal field (real election, T0+T+14) | Do voters actually return to verify? What drives the intention-behavior gap? |
| **3** | **Field + manipulation (social proof)** | **Does seeing aggregate verification behavior by other voters change individual verification rates?** |

Study 3 (this document) is an extension of Study 2's field context, adding a between-subjects social-proof manipulation. The coercion surface vignette study previously described as "Study 3" in early drafts of the protocol is better understood as **Study 4 (optional)** and should be read as such.

---

## 1. Research question

**RQ3:** Does a social proof signal — a publicly visible count of how many voters have verified their vote — increase the rate at which voters return to verify their own receipt?

**Secondary:**
- Does the effect of social proof differ by user's technology self-efficacy or stated initial intent to verify?
- Does exposure to social proof change comprehension of what verification proves (i.e., does social proof produce correct or incorrect mental models about the purpose of verification)?

---

## 2. Motivation

Study 2 measures verification rates in the field. Prior work from verifiable voting (Adida et al. 2009 on Helios; Ryan and Bismark 2009 on Prêt à Voter) reports that verification rates in deployed systems are consistently low — typically under 10% — despite positive stated intent. The dominant explanation has been UI friction: the verification interface is too complex to navigate. The PIUP receipt design removes much of that friction (explicit instruction, downloadable artifact, public `verify_vote_counted()` endpoint). If Study 2 finds verification rates remain low despite PIUP receipt design, UI friction is not the bottleneck.

Das et al. (2014) suggest an alternative bottleneck: **social context**. In a large-scale field experiment on password manager adoption, they found that exposure to the behavior of peers — delivered as a simple aggregated count ("X of your contacts use this") — produced a statistically significant increase in adoption rates, with larger effects for participants who reported higher social orientation. The mechanism is Cialdini's social proof heuristic: in ambiguous situations, people use the behavior of similar others as a signal of correct action. Security behaviors are characteristically ambiguous (the benefit of verifying is non-obvious and deferred), which makes them a natural target for social proof effects.

**The gap this study fills:** No prior work has tested a social proof manipulation on post-vote verification behavior specifically, nor in a private voting context where the privacy constraint *prevents* showing *who* verified while *permitting* showing *how many* verified. This is the specific opportunity created by the deployed ZK contract: `verify_vote_counted()` calls are public, countable without de-anonymization, and available in real time. A publicly visible verification counter is technically trivial and privacy-preserving, but has never been studied.

The theoretical connection is direct: Das et al. (2014) operationalized social proof as an aggregate count. The current system can provide an aggregate count of verification events. If deferred security behavior (returning to verify) is social in the same way that upfront security behavior (adopting a password manager) is social, we should observe a significant increase in verification rates under social-proof conditions. If the effect is null, the barrier is intrinsic — motivation, not norm — and the design fix is different (reminders, calendar prompts, gamification).

---

## 3. Design

**Between-subjects, 2 conditions, deployed within the same election as Study 2.**

| Condition | Post-vote receipt display |
|-----------|--------------------------|
| Control | Standard PIUP receipt (fingerprint, verification instruction, no aggregate data) |
| Treatment | PIUP receipt + social proof counter: *"X voters have already verified their vote in this election. Verification is open until [date]."* |

The counter is updated every 15 minutes from on-chain `verify_vote_counted()` call logs. It shows the raw count — not a percentage, not a ratio — to avoid base-rate anchoring problems when n is small early in the verification window. (A count of 12 out of 80 reads as "few people have verified"; 12 out of 80 voters = 15% reads as "a specific low rate." The raw count is more interpretively neutral when the denominator is known to participants through other channels.)

**Assignment:** Random assignment at T0 (vote cast). The receipt endpoint is parameterized by voter session; conditions are indistinguishable at the network level and from the contract. This is essential for coercion resistance: the condition flag must not be observable by a third party.

**Blinding:** Participants are told the study is about "how voters use their receipts." They are not told there are two versions of the receipt. Debrief at T+14 discloses the manipulation and its purpose.

---

## 4. Participants

**Target:** n = 80 (matched to Study 2; participants may overlap). Study 3 can be run concurrently with Study 2 in the same election by adding a condition flag at randomization.

**Power:** ⚠️ **Study 3 as currently designed (n ≈ 40/condition, N ≈ 80 total) is underpowered for OR = 2.0.** Full power analysis: [`docs/piup-study3-power-analysis-2026-06-29.md`](piup-study3-power-analysis-2026-06-29.md).

Key numbers: to detect OR = 2.0 (Das et al. 2014 estimate) at 80% power with α = .05, two-tailed:
- Baseline p₁ = 0.10 (conservative ZK voting estimate) → **140/condition (N = 280)**
- Baseline p₁ = 0.15 (PIUP-optimistic) → **103/condition (N = 206)**
- Baseline p₁ = 0.20 (upper bound) → **86/condition (N = 172)**

At n = 40/condition (Study 2 pool): power = 32–53% across plausible baselines (minimum detectable OR = 2.67–3.28). The original power estimate of 0.79 conflated total N with n per condition — at n = 80 *per condition* (N = 160 total), power ≈ 56–72%; still below 0.80 at realistic baselines.

**Recommended design:** Run Study 3 embedded in Study 2 as a **pilot study** — pre-register as a pilot, report 90% CI for OR rather than NHST, and use results to calibrate a powered multi-election replication. See power analysis document for three replication options (pilot, sequential election deployment, platform partnership).

**Target n for powered replication (secondary planning parameter):**

| Baseline p₁ (control) | n/condition needed | N total | Recruitment path |
|---|---|---|---|
| 0.10 (conservative) | 140 | 280 | 3–4 DAO elections or Prolific field panel |
| 0.15 (PIUP-optimistic) | 103 | 206 | 3 elections or Vocdoni partnership |
| 0.20 (upper bound) | 86 | 172 | 3 elections minimum |

The pilot (N ≈ 80) provides the point estimate and 90% CI for OR needed to select the row above and pre-register the powered replication. The multi-election or platform-partnership paths in the power analysis document are the recommended routes to the required n.

---

## 5. Measures

**Primary (RQ3):**
- Verification rate at T+14 (binary: attempted verification or not; definition same as Study 2)
- **Group comparison:** treatment vs. control, logistic regression

**Secondary:**
- Technology self-efficacy × condition interaction (moderation hypothesis: social proof may matter more for participants with lower self-efficacy, for whom ambiguity about correct action is higher)
- Stated initial intent (T0) × condition interaction (social proof may be redundant for high-intent participants)
- Comprehension at T+14 (same Q1–Q4 rubric from Study 1): does social proof exposure affect mental model quality? (Predicted null; social proof should not change what participants understand about what verification proves, only whether they attempt it)
- Affect toward receipt: does the social proof display change how the receipt is perceived (e.g., more trustworthy, more legitimate)?

**Process measure:**
- Passive log: `verify_vote_counted()` calls by receipt ID, stratified by condition (opt-in only; see Study 2 ethics note). This provides ground-truth behavioral data independent of self-report and allows time-to-verify analysis: does social proof accelerate verification (more early verifiers) as well as increasing total verification rate?

---

## 6. Analysis

**Primary (pilot framing — NOT confirmatory NHST):** This study is pre-registered as a **feasibility pilot**. The primary analysis is the point estimate and **90% CI for the odds ratio** of the condition effect on verification at T+14, using logistic regression with condition (treatment vs. control), T0 intent, and technology self-efficacy as predictors. The 90% CI is the pre-specified inferential summary; no NHST threshold is applied to the primary endpoint.

Interpretation rule (pre-specified):
- If the 90% CI lower bound ≥ 1.5: social proof effect is plausible, consistent with Das et al. (2014); proceed to powered replication.
- If the 90% CI includes 1.0: effect is uncertain; use CI width and baseline rate to calibrate powered replication.
- If the 90% CI upper bound < 1.0: social proof counter may suppress verification; investigate before replication.

**Moderation (exploratory):** Test condition × self-efficacy interaction; stratify by self-efficacy tertile if coefficient p < .10 (exploratory threshold). No primary inference drawn from interaction term (would require n ≈ 560/condition to be confirmatory; see power analysis §5.1).

**Comprehension (exploratory):** χ² on Q1–Q4 composite accuracy across conditions. Predicted null. Labelled exploratory; underpowered for any non-trivial effect at pilot n.

**Time-to-verify (if log opt-in n ≥ 40, descriptive):** Survival analysis (Kaplan-Meier) comparing treatment vs. control on time from T0 to first `verify_vote_counted()` call. Log-rank test reported descriptively. Visual inspection for an early-surge pattern (social proof may primarily accelerate early adopters rather than convert non-verifiers). Labelled descriptive; n too small for confirmatory survival analysis at pilot scale.

---

## 7. Ethical considerations

**Disclosure:** Participants consent to "research on how voters use their receipts after an election." The existence of two receipt versions is not disclosed at T0 to avoid demand effects. Full debrief at T+14.

**Privacy of the counter:** The social proof counter shows a count, not identities. The counter is computed from public smart contract logs. No individual voter is identifiable from the count display.

**Non-deception:** The count is real and accurate. Participants in the treatment condition see genuine social behavior, not a simulated one. This is important both ethically (we are not deceiving about social norms) and methodologically (the manipulation is ecologically valid).

**IRB category:** The manipulation (showing a publicly available aggregate count) carries minimal risk. IRB review should confirm: (a) the debrief adequately explains the two-condition design, (b) the social proof counter is not misleading, and (c) the log opt-in process is distinct from implied consent through participation. Anticipated category: exempt or expedited review under 45 CFR 46.104(d)(2).

---

## 8. Relation to Das et al. (2014)

Das et al. (2014) studied social proof for **upfront** security behavior (adopting a tool before the security event occurs). The current study examines social proof for **deferred** security behavior (returning to check an artifact after a vote has already been cast). This is a different temporal structure with different psychological dynamics:

- Upfront behavior is prospective: "others use this, so maybe I should try it."
- Deferred behavior is retrospective: "others are checking their receipt, so maybe I should check mine."

The retrospective case may produce weaker social proof effects (the vote is already cast; the verification is purely for one's own assurance, not protective). Alternatively, the retrospective case may produce *stronger* effects (FOMO: if others are verifying and I am not, am I missing something?).

Das et al. also tested social proof delivered at the **moment of decision** (at password manager setup prompt). In the PIUP context, social proof is delivered **at T0** (vote receipt) and the behavior measured is **at T+14**. The persistence of a social proof nudge across a two-week gap is unknown. This is the substantive theoretical contribution: whether the social proof heuristic operates across a deferred horizon, not only at the moment of initial exposure.

If the effect is null across the two-week window, a follow-up design could test a **T+7 social proof reminder** ("127 voters have now verified their vote. Verification closes in 7 days.") to test whether recency is a necessary condition for social proof effectiveness.

---

## 9. Connection to the ZK contract

The deployed `aztec-private-voting` contract provides two features relevant to this study that no prior verifiable voting system has offered simultaneously:

1. **Public verification count without de-anonymization.** `verify_vote_counted()` is a public read function. Anyone can count successful verification calls. Verified voters are not identified; only the aggregate count is public.

2. **Pseudonymous receipt IDs.** Receipt IDs in logs are randomized by client (not wallet-linked). This means log analysis can count verification events without identifying which voter verified, even in the server-side log.

Together, these make the ecological validity of the social proof manipulation technically honest: the count shown to participants is a real, cryptographically grounded count of real verification events, not a simulated social norm. This distinguishes the manipulation from typical social proof experiments, which often use injected or simulated norms.

---

## 10. Expected outcomes and implications

**If social proof significantly increases verification rates (OR ≥ 2, p < .05):**  
The barrier to verification is normative, not cognitive. The UI fix is to add a live verification counter to the receipt and post-vote confirmation screen. This is low-cost, privacy-preserving, and deployable in the current system. The finding would also generalize: any private system with a public proof endpoint (ZK-based or otherwise) can use this design intervention.

**If null (OR ≈ 1, CI narrow):**  
The barrier is intrinsic — participants' mental model of verification as personally relevant is too weak for social context to activate it. The fix moves toward intrinsic motivation design: personalized reminders, calendar integration, or gamification of verification ("your fingerprint was verified — share this achievement"). The null result would also be informative: it would suggest that the Das et al. social proof mechanism does not transfer from upfront to deferred security behavior, which is a theoretically interesting boundary condition.

**If technology self-efficacy moderates the effect:**  
Social proof targets low-efficacy users. The design implication is a **segmented** receipt: show the social proof counter only to users who fail an early indicator of intent (e.g., did not download the receipt at T0). This avoids cluttering the receipt for high-intent verifiers while providing normative scaffolding for those who are uncertain whether verification is "for people like me."

---

## 11. Future directions: powered replication paths

The pilot is designed to feed into one of three replication options (full analysis: `docs/piup-study3-power-analysis-2026-06-29.md`, §2).

**Option A — Sequential election deployment (preferred, 12–18 months):** Recruit 3–4 DAO or institutional elections as future deployment sites for the Aztec private voting contract. Aggregate participants across elections using a random-effects logistic regression (site as clustering variable). Use the pilot OR estimate and CI to set the per-election recruitment target. Pre-register the powered replication as a registered report at CHI, CSCW, or TOCHI.

**Option B — Vocdoni API partnership (opportunistic, faster):** Vocdoni (app.vocdoni.io) has 1,000+ elections and a public vote-verification API. A platform partnership would allow Study 3 to scale to the required N without building a new voter pool from scratch. Prerequisites: confirm that Vocdoni's verification event log is accessible and supports the `verify_vote_counted()` equivalent; negotiate a research agreement. The social proof counter is implementation-neutral — it does not require the Aztec contract — but the privacy-preserving properties of the count are strongest on Aztec (ZK verification events, pseudonymous receipt IDs).

**Option C — Prolific field panel supplement:** If DAO election recruitment is insufficient, Prolific can supply participants for a simulated election scenario (loss of ecological validity but faster n accrual). Use only as a secondary robustness check alongside field data, not as the primary replication vehicle.

**Registered report target:** Use Study 3 pilot data + Study 1 outcome measures to submit a Stage 1 registered report with one of: CSCW 2027, CHI 2028 LBW, or *Behaviour & Information Technology* (no annual deadline). Stage 1 acceptance is blind to results and insulates the powered replication from publication bias.

---

## References

- Adida, B., de Marneffe, O., Pereira, O., & Quisquater, J.-J. (2009). Electing a university president using open-audit voting. *EVT/WOTE 2009*.
- Cialdini, R. B. (1984). *Influence: The Psychology of Persuasion*. Harper Collins.
- Das, S., Kim, T. H.-J., Dabbish, L. A., & Hong, J. I. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. *Proceedings of the Symposium on Usable Privacy and Security (SOUPS 2014)*. USENIX.
- Hargittai, E. (2009). An update on survey measures of web-oriented digital literacy. *Social Science Computer Review, 27*(1), 130–137.
- Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). Voting under pressure: Perceptions of counter-strategies in internet voting. *E-VOTE-ID 2025*. LNCS vol. 16028, pp. 158–174.
- Ryan, P. Y. A., & Bismark, D., Heather, J., Schneider, S., & Xia, Z. (2009). Prêt à Voter: A voter-verifiable voting system. *IEEE Transactions on Information Forensics and Security, 4*(4), 662–673.
