# CHI Paper §6.5 Study 2 Ecological Validity — Cross-Check Proposal (tick-4200)

**Tick:** 4200 (even — CI check; 4th-tick audit)
**Date:** 2026-06-29
**Status:** JONY-ACTION II — pending Jony decision (a/b/c)

---

## Background

tick-4200 task: §6.5 cross-check for remaining omissions beyond JONY-ACTION HH (L2 receipt-freeness, tick-4198).

Full §6.5 audit completed this tick. Seven paragraphs enumerated and cross-checked:

| # | Paragraph | Status |
|---|-----------|--------|
| 1 | Protocol-layer exposure (L1 calldata) | ✅ CLEAN |
| 2 | Study 1 ecological validity | ✅ CLEAN |
| 3 | Study 1 label-substitution contingency | ✅ CLEAN |
| 4 | Q1 Condition-C demand characteristic | ✅ CLEAN |
| 5 | Study 2 demand characteristics | ✅ CLEAN (in isolation) |
| 6 | Statistical power | ✅ CLEAN (Study 1 focus; see INFO below) |
| 7 | Scope | ✅ CLEAN |

**HH (L2 receipt-freeness):** proposal exists (tick-4198). Still open. Still the highest priority §6.5 addition. Not re-examined this tick.

---

## Finding 1 — JONY-ACTION II: Study 2 Ecological Validity Paragraph Absent

### Problem

§6.5 has no dedicated **Study 2 ecological validity** paragraph.

**Structural asymmetry:**
- Study 1: 3 dedicated §6.5 paragraphs (EV, label-substitution contingency, Q1 demand characteristic)
- Study 2: 1 dedicated §6.5 paragraph (demand characteristics only)

The Study 2 demand characteristics paragraph (§6.5 para 5) contains a single passing mention: "While this improves ecological validity over the static-screenshot predecessor…" — it does not enumerate what remains limited.

Study 2 uses the actual `VoteReceipt.tsx` component hosted on Vercel in study mode (§5.2), which is an improvement over Study 1's static screenshot. But four ecological validity bounds specific to Study 2 are not noted anywhere in §6.5:

1. **Consequentially inert vote choice.** Participants vote in a simulated DAO governance scenario they know to be a study. The choice has no real outcome weight. In real deployment, the choice-commitment effect (personal stake in the decision) would heighten post-vote receipt attention and absent-content salience; the simulated context may underestimate this effect. Study 1's §6.5 explicitly flags "absence of choice-commitment context" — Study 2 reduces but does not eliminate this gap.

2. **Prolific sample bound.** Study 2 uses the same Prolific US-based English-speaking convenience sample as Study 1. The Study 1 ecological validity paragraph names this bound; Study 2 does not. A CHI reviewer auditing §6.5 will notice that the Study 1 paragraph says "US-based English-speaking online workers" and then Study 2's sole limitations paragraph says nothing equivalent.

3. **Single-session / immediate-post-vote design.** Both studies measure receipt comprehension immediately after voting. Real voters may revisit receipts days or weeks after the vote closes (at the verification event). The delayed-verification interaction pattern — returning to the saved receipt, re-engaging the verification affordance — is not tested in either study. This is Study 2's most important remaining EV gap, because Study 2 is specifically designed to test the save-behavior endpoint (download click; H2.4) and trust in delayed verification; yet the post-receipt delay is absent by design.

4. **H2.3 underpowering note cross-reference.** §5.5 (tick-4130 note) documents that H2.3 (calibration intervention: save intention no-harm TOST) has power ≈ 0.72 at d = 0.50 (L2 n = 60). The §6.5 Statistical power paragraph covers only Study 1. A reviewer may note the §6.5 Statistical power paragraph is Study-1-only; the H2.3 underpowering is the Study 2 equivalent omission. Minor — it is documented in §5.5, but a cross-reference in §6.5 would be cleaner.

**CHI risk: LOW-MODERATE.** CHI reviewers familiar with ecological validity in HCI studies will notice the asymmetric §6.5 treatment (Study 1 = 3 paragraphs; Study 2 = 1 paragraph that doesn't enumerate remaining EV bounds). A reviewer may raise this as a revision comment. Adding a Study 2 EV paragraph preempts this.

---

## Finding 2 — INFO: §6.5 Statistical Power — Study 1 Only

The existing §6.5 Statistical power paragraph covers Study 1's sample size correction (McNemar → independent proportions; n = 70/cell). It does not note H2.3 underpowering (power ≈ 0.72; Study 2). However, H2.3 is documented in §5.5 at the hypothesis-specification level. This is a minor omission — the §6.5 paragraph should arguably add a sentence cross-referencing H2.3.

CHI risk: LOW. Not proposed as a separate action; absorbed into option (a) of JONY-ACTION II if Jony accepts the full §6.5 Study 2 EV paragraph (see below).

---

## Proposed §6.5 Paragraph: Study 2 Ecological Validity

**Insertion point:** After "Study 2 demand characteristics" paragraph, before "Statistical power" paragraph.

**Proposed text:**

> **Study 2 ecological validity.** Study 2 uses the actual `VoteReceipt.tsx` component (§3.4) hosted in study mode and presents an interactive voting flow, improving substantially on Study 1's static-screenshot method — participants cast an active choice before receiving the receipt, providing a choice-commitment context absent from Study 1. Three ecological validity bounds remain. First, the vote is consequentially inert: participants select a DAO governance option in a context they know to be a study, so their choice carries no real decision-making weight. The choice-commitment effect — having a personal stake in the decided outcome — is a plausible driver of post-vote receipt attention and absent-content salience in real deployment; its absence may mean Study 2 underestimates the personal urgency with which real voters interrogate their receipt's absent content. Second, the Prolific sample introduces the same validity bound as Study 1: participants are US-based English-speaking online workers whose familiarity with digital privacy UI may not represent the full population of likely deployment users. Third, both studies measure receipt comprehension immediately after voting; real voters may revisit their saved receipt days or weeks after the vote closes, when the verification event approaches. The delayed-verification interaction pattern — returning to a stored receipt, re-engaging the verification affordance — is not tested in either study. This gap is most relevant to Study 2's save-behavior endpoint (H2.4; observed download-button click as proxy for save intention): the behavioral measure captures immediate post-vote save behavior, not the downstream verification act the save is intended to enable. The internal validity of the L × E × I factorial design and the confirmatory contrasts (H2.1–H2.4; §5.5) is not affected by these bounds; they primarily constrain the generalizability of the effect-size estimates to real-world deployment contexts. H2.3 (calibration intervention: no-harm TOST on save intention) is the only underpowered endpoint (power ≈ 0.72 at d = 0.50, L2 n = 60; §5.5); if the TOST is inconclusive, a targeted Study 2b (N = 80, L2 only) is planned.

---

## Jony's Options

**(a) Apply — insert Study 2 EV paragraph [RECOMMENDED].** Closes the structural asymmetry. The H2.3 underpowering cross-reference is absorbed into this paragraph (last sentence). No additional changes elsewhere.

**(b) Apply without H2.3 sentence.** Accept the Study 2 EV paragraph; drop the H2.3 underpowering sentence (it's already documented in §5.5; §6.5 doesn't need it). Slightly shorter but the §6.5 Statistical power paragraph remains Study-1-only.

**(c) Reject.** Asymmetric §6.5 treatment is acceptable; Study 2 demand characteristics paragraph sufficient. Accept CHI risk LOW-MODERATE.

---

## Tick Summary

- 7 items cross-checked: 7 CLEAN
- 1 structural omission identified: Study 2 EV paragraph absent (JONY-ACTION II)
- 1 minor INFO: §6.5 Statistical power = Study 1 only (absorbed into option a/b)
- 0 BUGS
- No commit needed
