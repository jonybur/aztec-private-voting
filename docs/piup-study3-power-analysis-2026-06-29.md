# PIUP Study 3 Power Analysis: Social Verification Field Study

**Date:** 2026-06-29  
**Status:** Design critique — pre-IRB  
**Author:** @jonybur  
**Connects to:** `piup-study3-social-verification-2026-06-29.md`, `piup-study2-design-note-2026-06-22.md`

---

## Summary

**Critical finding:** Study 3 as currently designed — embedded in Study 2's field deployment (~N=80 total voters, ~40/condition) — is **severely underpowered** for the primary hypothesis (OR ≈ 2.0 from Das et al. 2014). Power at n=40/group ranges from 20–53% across plausible baseline verification rates, depending on where in that range the true rate falls. The minimum detectable OR at 80% power requires n=40/group to observe an effect of OR ≈ 3.3 or larger — substantially stronger than the Das et al. social proof effect.

This analysis specifies required sample sizes, identifies design options to achieve adequate power, and recommends a pragmatic staged approach.

---

## 1. Power analysis

### 1.1 Primary endpoint

Study 3's primary endpoint is verification rate at T+14, measured as a binary outcome (verified / did not verify), compared between treatment (social proof counter) and control (standard PIUP receipt). The analysis is a logistic regression of treatment assignment on verification status, controlling for Study 2 co-enrollment.

The primary hypothesis is OR ≈ 2.0, derived from Das et al. (2014), who observed an odds ratio of approximately 2.0 for password manager adoption under social proof conditions in a population with similar technology orientation to the target Study 3 population (online adults, Mechanical Turk). The transfer assumption — that a social proof effect on *upfront* security behavior (password manager adoption) will generalise to *deferred* security behavior (return-to-verify at T+14) — is the key theoretical claim; magnitude calibration from Das et al. (2014) is the best available prior.

### 1.2 Method

Power for a two-group comparison of binary proportions was computed using the arcsine-transformation formula (Cohen 1988, §6.2), with α = 0.05 (two-sided), power = 1 − β = 0.80. This is equivalent to the logistic regression test for the OR under the specified baseline, provided sample sizes are balanced. Cells: n/group (per condition); N = total sample (2 × n/group).

$$h = 2\arcsin\!\sqrt{p_2} - 2\arcsin\!\sqrt{p_1}$$

$$n = \frac{(z_{\alpha/2} + z_\beta)^2}{h^2}$$

Baseline *p*₁ (control verification rate) was varied across the plausible range. Published verification rates in deployed verifiable voting systems: Adida et al. (2009) Helios — under 10%; Ryan and Bismark (2009) Prêt à Voter — similar range. The PIUP receipt design removes much of the friction (explicit instruction, downloadable artifact, one-click endpoint), so the baseline may be higher — potentially 15–25%. The power analysis is presented for the full plausible range.

### 1.3 Required n per condition for 80% power (primary: OR = 2.0)

| Baseline *p*₁ (control) | Treatment *p*₂ at OR = 2.0 | Effect size *h* | **n/condition** | **N total** |
|---|---|---|---|---|
| 0.05 | 0.095 | 0.176 | **253** | **506** |
| 0.10 | 0.182 | 0.238 | **140** | **280** |
| 0.15 | 0.261 | 0.277 | **103** | **206** |
| 0.20 | 0.333 | 0.304 | **86** | **172** |
| 0.25 | 0.400 | 0.335 | **76** | **152** |

*Key takeaway:* Adequate power for OR = 2.0 requires between 76 and 253 participants *per condition*, depending on the baseline. Even at an optimistic baseline of p₁ = 0.25 — higher than any published ZK voting deployment — the minimum required is N = 152 total. At a more realistic baseline of p₁ = 0.10, required N = 280.

### 1.4 Power at n = 40/condition (Study 2 pool)

Study 3 as designed in `piup-study3-social-verification-2026-06-29.md` is concurrent with Study 2 in the same election. Study 2 targets n = 80. Under random assignment to Study 3 conditions, this gives n = 40/condition.

| Baseline *p*₁ | Treatment *p*₂ at OR = 2.0 | **Power at n = 40/group** |
|---|---|---|
| 0.05 | 0.095 | **19.9%** |
| 0.10 | 0.182 | **32.4%** |
| 0.15 | 0.261 | **41.7%** |
| 0.20 | 0.333 | **48.4%** |
| 0.25 | 0.400 | **53.1%** |

**None of these reach 80%.** At the most realistic baseline (p₁ = 0.10), power is 32.4% — less than one in three replication attempts would yield a statistically significant result even if the true effect is OR = 2.0. This is not an arguable design; it is an underpowered study.

### 1.5 Minimum detectable OR at n = 40/condition (80% power)

To put it the other way: given n = 40/condition and α = 0.05, what OR can be detected with 80% power?

| Baseline *p*₁ | MDE *p*₂ | **MDE OR** |
|---|---|---|
| 0.05 | 0.187 | **4.37** |
| 0.10 | 0.267 | **3.28** |
| 0.15 | 0.337 | **2.88** |
| 0.20 | 0.400 | **2.67** |

For the design to detect the hypothesised effect (OR = 2.0) with adequate power at n = 40/group, the true effect would need to be 2.67–4.37 times larger than expected. This is implausible: Das et al. (2014) found OR ≈ 2.0 in a population with *more* social motivation (password manager adoption has visible peer benefits) and a *simpler* behavior (one-time install, not returning to a website 14 days later). The verification behavior is harder. OR ≥ 2.67 is not a defensible planning assumption.

---

## 2. Design options

### Option A: Pilot/feasibility framing (current scale)

Run Study 3 as a **feasibility pilot** embedded in Study 2 (n = 40/condition, N = 80 total). Report as:
- A feasibility study for a future pre-registered replication
- Point estimate and 90% confidence interval for the OR
- No null-hypothesis significance test as the primary analysis (avoid the Type II error interpretation)
- Use results to calibrate the baseline and OR for a powered replication (see Option B or C)

**Pros:** Immediately executable within Study 2 infrastructure; no additional recruitment required; publishable as a Methods or design paper establishing the measurement paradigm; demonstrates that the ZK contract's `verify_vote_counted()` event log is a viable ground-truth verification measure.

**Cons:** Cannot confirm OR = 2.0 hypothesis. Any observed effect, positive or null, will be uninterpretable as a definitive test of the social proof hypothesis. A null result may be incorrectly interpreted as disconfirmation.

**Verdict:** Acceptable as a first step and the pragmatic near-term path. Must be labelled clearly as a pilot. Pre-register as a pilot (OSF "Pilot" badge) with explicit statement that a powered replication is planned.

### Option B: Sequential election deployment

Recruit multiple elections (DAO governance votes, student elections, community polls) until the required n is reached. Run Study 3 as a multi-site randomised experiment, aggregated with a random-effects logistic regression (site as clustering variable).

**Required elections at n = 80 voters/election:**
- p₁ = 0.10 → need n = 140/condition → 3–4 elections (to allow for attrition and unequal distribution)
- p₁ = 0.15 → need n = 103/condition → 3 elections minimum

**Pros:** Ecologically valid; uses the same ZK contract infrastructure; the multi-site design increases external validity beyond a single election. Feasible if Jony is actively deploying Umbra in real DAO votes over the next 12–18 months.

**Cons:** Timeline is 12–18 months minimum; requires repeat IRB amendments or umbrella protocol; individual elections may have different voter populations (different OR estimates across sites).

**Verdict:** Best long-term path for a publication-quality primary endpoint. Feasible but slow. The Aztec Wave 3 grant ($25,000) could fund the Prolific recruitment needed to supplement field data if DAO elections are insufficient.

### Option C: Platform partnership

Partner with a deployed platform with a larger voter pool:
- **Vocdoni (app.vocdoni.io):** 1,000+ elections, larger voter pools
- **Snapshot + Shutter:** 850+ DAOs, but temporary privacy (votes revealed post-close — the verification semantics are different)
- **Aragon Voice / Aragon App:** Established DAO governance with accessible voter pools

A platform partnership would allow Study 3 to run at the required N without building the voter pool from scratch. The social proof intervention (adding a counter to the receipt) is implementation-neutral — it does not require Aztec.

**Pros:** Fastest path to adequate n; strengthens external validity by testing across platforms; may produce a co-authorship or acknowledgment opportunity with the platform team.

**Cons:** Platform negotiation takes time; the verification event log (`verify_vote_counted()` equivalent) must be available on the partner platform — Snapshot+Shutter likely does not provide this; Vocdoni may (their open API includes vote census proofs). The PIUP receipt design is not implemented on any partner platform — the intervention is the counter, but the baseline receipt would need to be the partner platform's native receipt.

**Verdict:** Strongest external validity; most complex to execute; requires early-stage feasibility conversations before IRB submission.

---

## 3. Recommended path

**Immediate (tick-4244):** Add this power analysis to the Study 3 design document and note the underpowering as a named limitation.

**Near-term (Study 2 deployment, ~Q3 2026):** Run Study 3 as a **pilot** (Option A) embedded in Study 2. Pre-register explicitly as a pilot. Use the 90% CI for OR as the basis for a powered replication protocol.

**Medium-term (~Q1 2027, post-Study 1 data):** Submit a registered report for the powered Study 3 replication, using Study 1 outcomes and the Study 3 pilot point estimate to specify the design parameters. Target a conference with registered report tracks (CHI, CSCW) or a journal (IJHCS, TOCHI).

**Platform partnership (opportunistic):** Initiate a Vocdoni API feasibility check to determine whether their event log supports the `verify_vote_counted()` equivalent. If yes, Option C becomes viable for the powered replication without requiring 12–18 months of DAO election recruitment.

---

## 4. Impact on Study 3 document

The Study 3 design document (`piup-study3-social-verification-2026-06-29.md`) should be updated to:
1. Add a power analysis section citing this document
2. Reframe the study as a **pilot** with explicit power caveats
3. State the pre-specified primary analysis as a 90% CI for OR rather than an NHST
4. Add the target n for a powered replication as a secondary planning parameter
5. Add the multi-site/platform extension as a named future direction

---

## 5. Secondary endpoint notes

### 5.1 Self-efficacy moderation (interaction term)

H3.2 in Study 3 tests whether the social proof effect is moderated by technology self-efficacy. Interaction terms in logistic regression require substantially larger samples than main effects — roughly 4× the main-effect n. At baseline p₁ = 0.10:
- Main effect n = 140/condition (N = 280)
- Moderation test n ≈ 560/condition (N ≈ 1,120)

The self-efficacy moderation test is **exploratory only** at any realistic study scale. It should be labelled as exploratory in the pre-registration, with no primary inference drawn from the interaction term.

### 5.2 Survival analysis (time-to-verify)

The Study 3 design specifies a time-to-verify survival analysis for participants who opt into verification logging (n ≥ 40 threshold). At n = 40 total (20/condition), the survival analysis has extremely limited power — adequate only for very large hazard ratios (HR > 3). This should be labelled as descriptive/exploratory, not confirmatory.

### 5.3 Comprehension check (secondary)

Study 3 includes a comprehension check at T+14 to test whether social proof exposure changes comprehension of what verification proves (correct model vs. incorrect social desirability inference). This is a binary outcome at n = 40/condition — power similar to Section 1.4 above. Treat as exploratory.

---

## References

- Cohen, J. (1988). *Statistical Power Analysis for the Behavioral Sciences* (2nd ed.). LEA. §6.2 (arcsine transformation for proportions).
- Das, S., Kim, T. H.-J., Dabbish, L. A., & Hong, J. I. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. In *Proceedings of the 21st ACM Conference on Computer and Communications Security (CCS '14)* (pp. 739–749). ACM. https://doi.org/10.1145/2660267.2660271
- Adida, B., de Marneffe, O., Pereira, O., & Quisquater, J.J. (2009). Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios. *EVT/WOTE 2009*.
- Ryan, P.Y.A., & Bismark, D. (2009). The Prêt à Voter Verifiable Voting System. *IEEE Security & Privacy*, 7(5), 32–37.
