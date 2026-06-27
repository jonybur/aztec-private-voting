# PIUP Study 2 Design Note: Absent-Content Interpretation and Trust Calibration

_Author: Jony Bursztyn · 2026-06-22_  
_Status: Design note — not yet a pre-registration. Finalize after Study 1 pilot data._  
_Related: [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) · [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md) · [`docs/h2-analysis-fingerprint-vs-confirmation-code.md`](h2-analysis-fingerprint-vs-confirmation-code.md)_

---

## 1. Position in the research arc

Study 1 tests a single question: **does the identifier label on a private voting receipt affect a user's mental model of what that receipt proves?** It isolates the label as the single manipulated variable, holds the receipt copy constant across conditions, and measures comprehension through four forced-choice questions and one open-text probe.

Study 1 does not test:

- Whether users can correctly interpret the **absence of vote choice** from the receipt (absent-content as design choice vs. absent-content as failure)
- Whether a correct mental model produces **behavioral intentions** aligned with that model (saving the receipt, intending to verify later)
- Whether there is a **gap between comprehension and confidence** — specifically whether users who score well on accuracy still hold systematically miscalibrated confidence (H4)
- Whether an **explicit calibration intervention** at receipt display time can close such a gap

Study 2 addresses all four. It is the second of a three-study arc:

| Study | Central question | Method | Status |
|-------|-----------------|--------|--------|
| 1 | Does label choice affect privacy mental model? | 4-condition between-subjects screenshot study (Prolific, N=280, n=70/cell; corrected from pre-registration N=200 after power analysis fix — see CHI paper §4.2) | Pre-registered; pending OSF upload + pilot |
| **2** | **Does absent-choice explanation affect trust and save behavior? Can calibration interventions reduce over-confidence?** | **2×2×2 between-subjects interactive prototype study (Prolific, N=240; L × E × I, 8 cells, n=30/cell)** | **This document** |
| 3 | Do users actually return to verify? What predicts verification behavior? | Longitudinal field study in DAO deployment | Deferred until Study 2 complete |

---

## 2. Motivation: the gap Study 1 leaves open

### 2.1 The absent-content problem is distinct from the label problem

Study 1 tests whether different labels (fingerprint, confirmation code, nullifier, receipt ID) produce different rates of correct belief formation about receipt semantics. It holds the explanatory copy constant.

But the explanation copy in the current PIUP design does something that no label can do: it explicitly names the design intent of absent content.

> "Your vote is not shown here. This is intentional — your privacy is protected."

This sentence is doing a specific job: preempting the natural inference that "confirmation of a transaction" implies that the confirmation contains the transaction contents. That inference is correct in nearly every other confirmation context users encounter (bank receipts, eCommerce orders, email confirmation links). The receipt design violates this schema, and without an explicit explanation, users are likely to interpret absent choice as a failure rather than a feature.

Study 1 cannot measure whether this explanation is working. The explanation is present in all four conditions. If users are forming wrong mental models despite the explanation, Study 1 attributes the failure to the label. If users are forming correct mental models because of the explanation, Study 1 credits the label. The explanation copy is a confound in Study 1's design — an acknowledged one, because Study 1's goal is isolating the label effect, not the explanation effect.

Study 2 isolates the explanation as the variable.

### 2.2 The comprehension/intention gap

Study 1 measures belief formation (what does this receipt prove?). It does not measure behavioral intention (would you save this receipt? would you return to verify?).

The Whitten-Tygar tradition distinguishes between usability failures of understanding (the user doesn't know what the system can do) and usability failures of motivation (the user understands but doesn't act). Study 1 addresses the former. The PIUP's ultimate goal — that users save the receipt and use it later to verify — requires the latter.

Users may correctly answer Study 1's Q2 ("this doesn't prove how I voted") while having no intention of saving the receipt, because saving it feels pointless if the confirmation is opaque. Study 2 adds behavioral intention measures: self-reported likelihood of saving, observed interaction with the download affordance in an interactive prototype.

### 2.3 The H4 calibration direction

H4 in Study 1 predicts that Condition B ("confirmation code") produces the highest confidence rating while scoring moderately on accuracy. If confirmed, this is a calibration failure: familiar labels borrow perceived competence from eCommerce contexts without validating the underlying mental model.

The H4 finding, if replicated, has a direct design implication: users of familiar-label conditions believe they understand the receipt better than they do. This makes them less likely to seek the explanation copy, less likely to notice a verification failure, and (in a coercion scenario) more vulnerable to confident but incorrect disclosure. The calibration failure is not benign.

Study 2 tests whether an **accuracy-feedback calibration intervention** — showing the user how they scored on a comprehension prompt before proceeding — can close this gap without reducing save behavior.

---

## 3. Study 1 contingency

Study 2's design is specified independently of Study 1 outcomes. H2.1 (E main effect on Q-AC accuracy) is the fixed pre-specified primary endpoint regardless of Study 1 outcomes. The reporting emphasis and the co-primary or secondary analysis axis shifts depending on Study 1's results. [Fixed tick-4027: prior sentence said 'primary analysis axis shifts' — corrected; H2.1 is fixed as primary; only emphasis and secondary/co-primary axis shifts per Study 1 contingency.]

| Study 1 outcome | Study 2 emphasis | Pre-specified primary (H2.1: always Q-AC) + additional emphasis |
|----------------|-----------------|------------------------------|
| H2 supported (A > B on Q2/Q3) | Explanation effect: does absent-choice explanation increase trust and save behavior for fingerprint users? | H2.1: E main effect on Q-AC accuracy (primary); trust composite M2 interaction (H2.2 secondary); save intention descriptive (H2.4) |
| H2 null (A ≈ B on all measures) | Calibration: if familiarity and metaphor produce equal comprehension, does calibration feedback differentially affect over-confident B users? | H2.1: E main effect on Q-AC (primary; expected null if explanation doesn't help either label); I factor × confidence calibration exploratory (H2.3 conditional on H4) |
| H2 reversed (B > A on Q2) | Trust without explanation: does confirmation code's accuracy advantage persist when explanation copy is removed? | H2.1: E main effect on Q-AC (primary); L × E interaction (H2.2) interpreted under reversed-H2 framing; exploratory L main effect within E2 (no-explanation) conditions |
| H4 supported (B highest confidence, moderate accuracy) | Calibration intervention: does accuracy feedback reduce confidence miscalibration without reducing save rate? | H2.1: E main effect on Q-AC (primary); H2.3 co-primary: I × confidence−accuracy residual (M4, L2 conditions only; pre-specified conditional on H4) |
| No significant differences (all ≈ 55%) | Explanation is load-bearing: test explanation-present vs. absent with a fixed label | H2.1: E main effect on Q-AC (primary); composite accuracy reported as secondary/descriptive (not pre-specified primary) |

[Fixed tick-4027: The previous column header 'Primary endpoint for Study 2' and three cell descriptions were inconsistent with the pre-specified primary endpoint defined in §9.1. (a) Column header corrected: H2.1 (E main effect on Q-AC) is the pre-specified primary endpoint for Study 2 regardless of Study 1 outcomes; the contingency table describes which secondary/co-primary emphasis is active per Study 1 scenario, not a replacement of H2.1. (b) Row 1 (H2 supported): 'E factor × save rate' was wrong — save rate (M3) is H2.4 (secondary), not the primary endpoint; H2.1 on Q-AC is primary. (c) Row 3 (H2 reversed): 'Main effect of L factor on Q2 accuracy' was wrong in two ways — Q2 is a Study 1 measure not administered in Study 2; and the L main effect is secondary (primary is E main effect H2.1); corrected to H2.1 primary + L × E interaction under reversed framing. (d) Row 5 (No significant differences): 'E factor main effect on composite accuracy' was wrong — composite accuracy is not the pre-specified primary; Q-AC is. Composite accuracy is secondary/descriptive. Rows 2 and 4 were accurate and unchanged.]

In all cases, Study 2 runs the same 2×2×2 design (L × E × I). [Fixed tick-4026: '2×2' → '2×2×2' — parallel fix to §5.1 and the study arc table above; all three locations now consistent with the CHI paper's '2×2×2 factorial (L × E × I)' framing.] The contingency affects which secondary or co-primary contrast receives greatest reporting emphasis in the paper; H2.1 (E main effect on Q-AC) remains the fixed primary throughout. [Fixed tick-4027: prior sentence said 'primary endpoint' — corrected; H2.1 is always primary; the contingency shifts co-primary/secondary emphasis only.]

---

## 4. Research questions

**RQ1 (Explanation effect).** Does explicit absent-choice explanation in the receipt increase (a) correct absent-content interpretation, (b) trust in the receipt, and (c) self-reported save intention, compared to a receipt with no explanation?

**RQ2 (Label × Explanation interaction).** Is the explanation effect moderated by label choice? Specifically, does the "confirmation code" label produce lower absent-content accuracy in the no-explanation condition (because it activates the wrong schema), but close the gap to "vote fingerprint" when explanation is added?

**RQ3 (Calibration intervention).** Does an accuracy-feedback intervention — a two-question comprehension check with immediate correct-answer feedback, displayed before the receipt — (a) increase correct absent-content interpretation, and (b) reduce confidence miscalibration without reducing save intention?

**RQ4 (Save behavior).** Does correct absent-content interpretation predict save intention? Is this relationship moderated by confidence calibration?

---

## 5. Study design

### 5.1 Design

2×2×2 between-subjects factorial experiment (L × E × I; 8 cells). [Fixed tick-4026: prior text said '2×2' — but the design crosses three factors (L, E, I), creating 8 conditions (2³). The study arc table above and §5.1 heading both incorrectly said '2×2'; corrected to '2×2×2' to match the CHI paper §1.3 C4 ('A 2×2×2 factorial (L × E × I; 8 cells, n=30/cell)'), §5 ('2×2×2 factorial (Label × Explanation × Calibration Intervention)'), and the 8-cell count and N=240 total (30/cell × 8 = 240) described in this section.]

**Factor L (Label):** 2 levels
- L1: "vote fingerprint" — metaphor-activating, current production default
- L2: "confirmation code" — eCommerce convention; predicted to activate wrong representational schema without explanation

The 4-condition label space from Study 1 is reduced to the theoretically central contrast (L1 vs. L2). "Nullifier" is excluded (Study 1 addressed its failure; no production path). "Receipt ID" is excluded (generic baseline; Study 1 will have characterized it).

**Factor E (Explanation):** 2 levels
- E1: Explanation present — "Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [vote fingerprint / confirmation code] is the only thing you need — matching it later proves your ballot was counted, nothing more." (Full copy in §6.1; label token inserted dynamically per Factor L.)
- E2: Explanation absent — receipt shows the identifier, download prompt, and verification instructions, but no explicit absent-choice explanation sentence

**Factor I (Intervention):** 2 levels, crossed with L × E
- I1: No calibration intervention — participant sees the receipt directly
- I2: Calibration intervention — participant answers two comprehension questions before seeing the receipt, then receives correct-answer feedback (whether their answers were right, and a one-sentence explanation)

This creates an 8-condition space: L × E × I. With N = 30 per cell, total N = 240.

**Note on nesting:** The intervention (I) necessarily precedes the receipt display, so I is not crossed independently of L and E in terms of receipt exposure order. Randomization to condition is block-randomized; all 8 conditions are present within each Prolific batch.

### 5.2 Platform

Interactive prototype: the actual `VoteReceipt.tsx` component from the Aztec Private Voting React package, hosted on Vercel in study mode.

Rationale: Study 1's static screenshot is appropriate for label comparison (the label is the only variable). Study 2's absent-content and save-behavior questions require an interactive receipt — specifically, the download affordance must be clickable and observable. Hosting the actual production component (rather than a screenshot) also increases ecological validity for the trust measure.

**Study mode features needed (to be implemented before Study 2):**
- Receipt displays with condition-specific label (L1 or L2) and explanation (E1 or E2)
- Download button registers a click event (no actual file is written; click is logged to study backend)
- "How to verify" section is expandable; expansion is logged
- Calibration prompt (I2) displayed before receipt, with immediate feedback

The deployment is a Prolific-embedded URL, same architecture as the Study 1 stimuli.

---

## 6. Materials

### 6.1 Receipt variants

Four base receipt variants (crossing L × E), each instantiated as a React component prop combination:

| Variant | Label | Explanation |
|---------|-------|-------------|
| A (L1E1) | "vote fingerprint" | Present |
| B (L1E2) | "vote fingerprint" | Absent |
| C (L2E1) | "confirmation code" | Present |
| D (L2E2) | "confirmation code" | Absent |

The rest of the receipt (identifier value, privacy copy, verification instructions, download button text) is held constant across variants.

**Explanation copy (E1):**

> Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [vote fingerprint / confirmation code] is the only thing you need — matching it later proves your ballot was counted, nothing more.

The label token ("vote fingerprint" vs. "confirmation code") is inserted dynamically to match Factor L.

**No-explanation copy (E2):**

The absent-choice design is not explained. The receipt shows the identifier value, the statement "Your ballot was counted," the download prompt, and the verification instructions. The privacy copy section is retained (to avoid a confound with privacy-awareness), but limited to: "Your vote is private and verifiable."

### 6.2 Calibration intervention (I2)

Participants in the I2 conditions see the following two-question prompt before the receipt:

> **Before we show you the receipt, two quick questions:**
>
> 1. If someone asked you to send them a screenshot of your voting receipt to prove how you voted, could they learn your vote choice from the screenshot?
>    ○ Yes, they could see my vote  
>    ○ No, the receipt doesn't include my vote  
>    ○ I'm not sure
>
> 2. What is the main purpose of the [vote fingerprint / confirmation code] on the receipt?
>    ○ To prove that you voted in this election  
>    ○ To confirm which voting option you chose  
>    ○ To let you verify later that your ballot was counted  
>    ○ To identify you to the election organizer

Immediately after submitting:

> **Your answers:**  
> Q1: The correct answer is **No** — the receipt does not include your vote choice. This is intentional: showing your vote would create a coercion risk.  
> Q2: The correct answer is **To let you verify later that your ballot was counted** — it proves your ballot was included in the tally, not what you voted.

Participants then proceed to the receipt.

**Design rationale:** The intervention is a micro-desensitization to absent-content surprise. By surfacing the absent-choice design as a deliberate choice (not a display glitch) before the receipt is shown, it aligns the user's schema before they encounter the receipt — rather than requiring the receipt's explanation copy to do the alignment work retroactively.

The two questions are drawn from Study 1's Q2 and Q3 (adapted for open-world comprehension rather than condition-specific comprehension). Using the same conceptual structure allows cross-study comparisons of pre-vs-post-explanation comprehension rates.

---

## 7. Measures

### 7.1 Primary measures

**M1 — Absent-content accuracy (proportion correct on Q-AC)**

Q-AC is a new question, not in Study 1:

> "Looking at this receipt: does it show which voting option you chose?"
> ○ Yes, my vote choice is shown  
> ○ No, my vote choice is not shown  
> ○ It's not clear from what I see

[Fixed tick-4023: Q-AC stem updated from 'which candidate you voted for' to 'which voting option you chose' — resolves stem–option mismatch (stem used 'candidate'; options used 'my vote choice'). Parallel fix to tick-4021 correction in the CHI paper §5.4. 'Voting option you chose' aligns with Study 1 Q2 phrasing and the DAO governance terminology used throughout the paper; also aligns with the answer options ('my vote choice'). If Study 2 is fielded with a political-election Prolific frame that uses 'candidate' intentionally, update both stem and answer options consistently: 'which candidate you voted for' / 'Yes, my candidate is shown' / 'No, my candidate is not shown'.]

Correct answer: "No." This is an observational rather than inferential question — the receipt is on screen; the participant is asked to report what they see. Study 1's Q2 asked about proof ("does this prove how you voted?"); Q-AC asks about content ("is your vote shown?"). Q-AC has a lower inference barrier and tests a more basic absent-content interpretation. If users still fail Q-AC at high rates in E2 conditions, it indicates that absent content is being interpreted as a display failure, not a design decision.

Scored binary (1 = correct, 0 = incorrect/unsure).

**M2 — Trust-in-receipt (adapted McKnight scale, 4 items, 7-point Likert)**

Adapted from McKnight et al. (2002) integrity and competence subscales, reworded for receipt context:

- TI1: "I believe this receipt accurately reflects what happened with my vote."
- TI2: "I trust that the [vote fingerprint / confirmation code] is unique to my ballot."
- TC1: "I feel confident I could use this receipt to prove my ballot was counted."
- TC2: "I understand what this receipt is for."

Items scored 1–7 (Strongly Disagree to Strongly Agree). Composite = mean(TI1, TI2, TC1, TC2). α ≥ 0.70 required; if not met, items are reported individually.

**M3 — Save intention (single item + behavioral proxy)**

Self-report: "How likely are you to save or screenshot this receipt before closing this page?"  
Scale: 1 (Definitely not) to 7 (Definitely will).

Behavioral proxy: The download button click (yes/no) is logged in the interactive prototype. Logistic regression is used to model download click from condition and M1/M2 scores.

### 7.2 Secondary measures

**M4 — Confidence miscalibration residual**

Same 7-point confidence rating used in Study 1 (H4 measure), adapted for the 2-question I2 probe: "How confident are you that your answers were correct?" (I2 condition only).

Calibration residual = confidence rating − actual accuracy score (from Q-AC and I2 feedback). Positive residual = over-confidence; negative = under-confidence. H4 in Study 1 predicts B (confirmation code) will have positive residual; Study 2 tests whether I2 intervention reduces this residual in the L2 conditions.

**M5 — Verification instruction engagement**

Binary: did the participant expand the "how to verify" section? This is the interaction log from the prototype's verification accordian.

Expected direction: E1 conditions (explanation present) will produce higher engagement than E2 because the explanation establishes purpose before the verification instructions appear.

**M6 — Open-text absent-choice explanation (Q-OE)**

"In your own words, why doesn't this receipt show which voting option you chose?" [Fixed tick-4023: 'candidate' → 'voting option you chose' — consistent with Q-AC stem and answer options fix above; and with Study 1 MQ1 / Q2 phrasing.]

Scored 0–2 by two raters:
- 2: Correct explanation of absent-content design ("to protect my privacy," "so it can't be used to prove my vote to others")
- 1: Partial understanding ("it's private") without design intent
- 0: Incorrect ("it must have been an error," "the system didn't record it") or no response

κ ≥ 0.70 required; adjudicate disagreements before analysis.

---

## 8. Hypotheses

### H2.1 — Explanation effect on absent-content accuracy

**Prediction:** E1 conditions will produce higher Q-AC accuracy than E2 conditions (main effect of E).

**Mechanism:** Without explanation, absent vote choice is ambiguous: it could be a feature (privacy-preserving design) or a failure (incomplete data). The explanation copy eliminates this ambiguity.

**Direction:** E1 > E2.

**Predicted direction in each L × E cell, based on prior work:**

- L1E1 (fingerprint + explanation): highest Q-AC accuracy (metaphor + explanation; correct schema activated and confirmed)
- L1E2 (fingerprint + no explanation): moderate Q-AC accuracy (metaphor active; absent content remains ambiguous)
- L2E1 (code + explanation): moderate-to-high Q-AC accuracy (explanation overrides wrong schema)
- L2E2 (code + no explanation): lowest Q-AC accuracy (eCommerce schema predicts content in confirmation; nothing to override it)

If this rank ordering holds (L1E1 ≥ L2E1 > L1E2 ≥ L2E2), the L × E interaction is ordinal disordinal for L2.

### H2.2 — Explanation × Label interaction on trust

**Prediction:** The increase in trust (M2) produced by adding explanation (E1 vs. E2) will be larger for the L2 ("confirmation code") condition than for the L1 ("vote fingerprint") condition.

**Mechanism:** The fingerprint label partially self-explains absent content — a fingerprint is not expected to contain a full transaction record. The confirmation code label sets an expectation (confirmation = content) that the explanation must correct. The explanation should therefore do more work in L2 than L1.

**Pre-specified test:** L × E interaction on M2 composite, two-way ANOVA. If interaction F is significant, report simple effects of E within each L level.

### H2.3 — Calibration intervention reduces over-confidence

**Prediction (conditional on H4 being supported in Study 1):** In L2 conditions, the calibration intervention (I2) will reduce the confidence miscalibration residual (M4) compared to I1, without reducing save intention (M3).

**Mechanism:** Showing users that their initial mental model was incorrect (Q1 feedback: "No, the receipt doesn't include your vote") before the receipt display aligns schema and expectation. Users who receive correct feedback are less likely to hold a falsely high confidence in their understanding.

**Direction:** M4 residual: I1-L2 > I2-L2. M3 save intention: I1-L2 ≈ I2-L2 (no significant decrease; equivalence test bounds ±0.5 SD).

### H2.4 — Correct absent-content interpretation predicts save intention

**Prediction:** Q-AC accuracy (M1 = 1) predicts higher save intention (M3) within participants.

**Mechanism:** A user who understands that the receipt does not contain their vote choice is more likely to recognise it as auditable evidence (rather than a meaningless opaque string), which motivates saving.

**Note:** This is also consistent with the alternative mechanism — that save intention reflects general receipt engagement, not absent-content comprehension specifically. The study is not powered to distinguish these mechanisms; the correlation is a first test.

**Pre-specified test:** Logistic regression of download click (M3 behavioral proxy) on M1 accuracy, controlling for condition. Report OR + 95% CI.

---

## 9. Analysis plan

### 9.1 Primary analysis

**H2.1 (E main effect on Q-AC):**  
Chi-squared (E1 pooled vs. E2 pooled × Q-AC correct/incorrect), one-tailed (E1 > E2), α = 0.05.  
Report: OR + 95% CI (Wilson).

**H2.2 (L × E interaction on M2):**  
Two-way ANOVA (L × E, between-subjects) on M2 composite.  
If F interaction significant (α = 0.05): simple effects of E within L1 and L2 separately.  
If F interaction not significant: report null with 90% CI on interaction term.

**H2.3 (Calibration intervention effect, L2 only):**  
This is a pre-specified conditional test: run only if H4 is supported in Study 1.  
If run: two-sample t-test on M4 residual (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05.  
Equivalence test on M3 save intention (I1-L2 vs. I2-L2), bounds ±0.5 SD, TOST procedure (Lakens, 2017).

**H2.4 (M1 predicts M3):**  
Logistic regression: download click ~ M1 + L + E + I (main effects, no interactions). Report OR for M1.  
Secondary: include M1 × L interaction to test whether the effect is stronger in the "fingerprint" condition (where correct understanding implies the receipt is auditably meaningful).

### 9.2 Multiple comparisons

H2.1, H2.2, H2.3, and H2.4 are four pre-specified hypothesis families. Within each family, no correction is needed (single test per hypothesis). Across families, no correction is applied — each hypothesis is an independent pre-specified prediction. Any additional comparisons (e.g. simple effects of L across all E × I combinations) are exploratory.

### 9.3 Exclusion criteria

Consistent with Study 1:
- Self-reported software engineers / cryptographers
- Response time < 90 seconds (total study time; interactive prototype auto-timestamps)
- Failed both attention checks

**Additional exclusion for Study 2:**
- Browser that does not support the interactive prototype rendering (fallback to static screenshot allowed, flagged in analysis as a sensitivity covariate)

### 9.4 Open-text coding (M6 / Q-OE)

Two independent coders (recruited via Prolific Academic researcher pool or RA) score Q-OE (0–2) before any other data are analyzed. If κ < 0.70, raters adjudicate disagreements and rescore. Q-OE analysis is supplementary (Kruskal-Wallis across 8 conditions; random 15 responses per condition published as illustrative examples).

---

## 10. Power analysis and sample size

### 10.1 Primary endpoint (H2.1 — E main effect on Q-AC)

Study 1 pilot data will provide an estimate of baseline Q-AC accuracy in the E2 conditions. In the absence of pilot data, we use a conservative estimate based on Study 1's comparable question (Q2 accuracy ≈ 55% in Condition D, which is the weakest label with no absent-choice context).

Assuming:
- Q-AC accuracy in E2 conditions: 50%
- Expected Q-AC accuracy in E1 conditions: 70% (OR ≈ 2.3)
- α = 0.05, one-tailed
- Power = 0.80

Required n per E level (E1 vs. E2 pooled): ~52 per E level → ~26 per L × E cell.

We target n = 30 per cell (N = 240 total) to achieve ≈ 0.84 power on H2.1 and headroom for the 20–25% exclusion rate expected from Study 1.

### 10.2 Secondary endpoint (H2.2 — L × E interaction on M2)

Detecting an interaction effect requires larger samples than a main effect. We estimate an interaction ES of f ≈ 0.22 (medium-small; ANOVA two-way) based on the H2 dissociation mechanism (expected to be stronger for L2 than L1).

Power for f = 0.22, α = 0.05, df = 1 (interaction), N = 240: power ≈ 0.80. Sufficient.

### 10.3 Conditional calibration test (H2.3)

If run (conditional on H4 in Study 1), the test uses L2 conditions only (n = 30 per I level within L2 = 60 participants). For d = 0.50 (medium calibration residual reduction), α = 0.05, one-tailed: power ≈ 0.72. Slightly underpowered; tolerated because this is a conditional secondary test. If underpowered, note as a limitation and plan for a calibration-focused Study 2b (N = 80 in L2 only).

---

## 11. Methodological considerations

### 11.1 Interactive prototype demand characteristics

Using the actual production React component increases ecological validity but introduces demand characteristics absent in Study 1: participants may infer they are expected to interact with the download button because it is clickable. Two mitigations:

1. The download button is styled identically in I1 and I2 conditions; the only variation is the receipt content (L × E) and the pre-receipt prompt (I).
2. The study task instructions do not mention the download button: "You have just voted in a simulated election. Take a moment to review your receipt. Then answer the questions below."

Download click rate should be interpreted as a lower bound on save intention; the self-report item (M3) is the primary measure of save intention, with download click as a behavioral proxy.

### 11.2 Order effects between I2 calibration and E1 explanation

In I2E1 conditions, participants receive pre-receipt calibration feedback AND in-receipt explanation. Both address absent-content. The combination may produce ceiling effects on Q-AC accuracy, making the individual effects difficult to separate.

Pre-specified plan: if Q-AC accuracy in the I2E1 cells exceeds 90% in both L conditions, report the ceiling and treat the I1E1 vs. I1E2 contrast as the primary E-effect estimate (calibration is factored out).

### 11.3 Label replication from Study 1

Study 2 uses a 2-level label factor (L1: fingerprint, L2: confirmation code). If Study 1 produces a null result for the H2 label contrast (fingerprint ≈ confirmation code on all measures), the premise of H2.1 in Study 2 is weakened — the E manipulation may show no interaction with L because L doesn't matter. This is a valid null finding that advances the theory: it would suggest the explanation copy is the load-bearing element of the receipt design, and label choice is not independently causal.

In this case, Study 2 should be framed as: "Study 1 found no label effect; Study 2 tests whether absent-choice explanation is the causal mechanism responsible for correct mental model formation, independent of label."

### 11.4 Test-retest contamination

Study 2 uses some of the same conceptual questions as Study 1 (absent-content accuracy, confidence rating). Participants who have completed Study 1 may have residual memory of the correct answers, inflating Study 2 scores if the Prolific sample overlaps.

Mitigation: Prolific custom screener — exclude participants who completed any study involving "voting receipts or confirmation codes" in the past 6 months. This relies on self-report; it is imperfect but sufficient for this study size.

---

## 12. Study 3 preview: deferred verification behavior

Study 2 closes the loop on mental model formation and behavioral intention. It does not address deferred behavior: whether participants who correctly understand the receipt and intend to save it actually return to use the verification affordance.

Study 3 is a longitudinal field study using DAO deployment data (see `hci-research-framing-2026-06-22.md`, §Study 3). It is design-independent (it measures behavior in production, not in a controlled study), and its design is not contingent on Study 1 or Study 2 outcomes.

**Study 3 depends on:**
- The aztec-private-voting contract deployed to a DAO governance platform with active voting
- The public verification endpoint returning deterministic results (the `verify_inclusion` view function in the contract)
- Access to on-chain event data for receipt fingerprint submission events (anonymized; no voter de-anonymization)

Study 3 is deferred until:
1. Study 2 is complete (so that the in-production receipt design is informed by Studies 1+2)
2. A DAO partnership is established (contact: potentially Snapshot, Aragon, or a Noir-native governance system)

The Study 3 design note will be written after Study 2 data collection.

---

## 13. Connection to HCI program framing

### 13.1 CMU HCII (Sauvik Das)

Das's research program is focused on how security context and social signals affect security-protective behavior. The Study 2 research questions map to two of his program's central concerns:

1. **Explanation effects on trust.** Das et al. (2014 CCS) found that social proof signals change security feature adoption rates. Study 2's H2.1 tests whether an analogous effect exists for explanatory framing (not social proof, but design-intent transparency) in receipt comprehension. This is a micro-extension of his work: instead of social influence, the influence is the designer's stated intent.

2. **Calibration and over-confidence.** Das's lab has addressed the "confidence-competence gap" in security contexts — users who feel secure without being secure. H2.3 in Study 2 is a direct intervention study in that tradition: testing a calibration mechanism (accuracy feedback) against over-confidence produced by familiar UI conventions.

The connection to make in an email to Das: "Study 1 tests label comprehension (what users believe about receipt semantics). Study 2 tests explanation effects on trust and behavioral intention, and a calibration intervention for the confidence-accuracy gap we expect to find in Study 1. Both connect to the 'how do UI design choices affect privacy mental model formation' question your lab has addressed in the social-proof direction."

### 13.2 Georgia Tech HCI

Study 2's design connects to the GT Security and Privacy thread through:

- **Interaction design for security behaviors** (Felt et al. 2012 permission dialog tradition) — the explanation copy and calibration intervention are specific UI interventions whose effectiveness is empirically tested
- **Trust in automated systems** (Lee and See 2004 tradition, widely cited in GT HCI) — the McKnight trust measure (M2) places Study 2 in a well-established measurement tradition
- **Absent-content as a UI pattern** — a generalizable contribution that extends beyond voting to sealed-bid auctions, whistleblower systems, and any domain where a submission receipt must be coercion-resistant

The CHI contribution framing for a combined Studies 1+2 paper would be: **artifact contribution** (the PIUP design pattern) + **empirical validation** (Studies 1+2 establishing boundary conditions for when the pattern succeeds and fails). This is a full CHI paper, not a workshop note.

---

## 14. Jony-actions before Study 2 can launch

Study 2 has the following dependencies on Study 1:

1. **Study 1 pilot data** — needed to calibrate Study 2's E1/E2 accuracy estimates for power analysis. Without pilot data, the N = 240 estimate is a reasonable prior but unvalidated.

2. **Study 1 full-study data** — H2.3 (calibration intervention) is conditional on H4 being supported in Study 1. If H4 is not supported, H2.3 is dropped from Study 2 and N can be reduced to 160 (4 cells × 40).

3. **Interactive prototype deployment** — the `VoteReceipt.tsx` component needs a "study mode" prop that disables actual file download, enables click logging, and injects condition-specific label and explanation variants. This is a ≈ 1-day engineering task.

4. **Study 2 pre-registration** — this design note is not a pre-registration. Once Study 1 pilot results are available and H4 status is known, this document should be converted to a formal pre-registration (OSF upload) with the Study 1 contingencies resolved.

**Recommended sequence:**
1. Run Study 1 pilot (N = 40) → confirm power estimates + identify protocol issues
2. Run Study 1 full study (N = 280, n = 70/cell) → confirm or refute H4
3. Update Study 2 design based on H4 status (resolve H2.3 conditional)
4. Build Study 2 interactive prototype (VoteReceipt study mode)
5. Pre-register Study 2 on OSF
6. Run Study 2 (N = 160–240 depending on H4)

---

## 15. Amendments log

| Date | Amendment type | Description | Authorized by |
|------|---------------|-------------|---------------|
| 2026-06-22 | Initial design note | First draft; not yet pre-registered | Jony Bursztyn |

---

## References

- Whitten, A., and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." _USENIX Security._
- Adida, B., et al. (2009). "Helios: Web-based Open-Audit Voting." _USENIX Security / EVT/WOTE._
- Bell, S., et al. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _EVT/WOTE._
- Das, S., Dabbish, L., and Hong, J. (2014). "The Effect of Social Influence on Security Sensitivity." _ACM CCS._
- Das, S., Kim, T.H.-J., Dabbish, L., and Hong, J. (2014). "The Role of Social Influence in Security Feature Adoption." _CSCW._
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _SOUPS._
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." _SPSS 8(4)._
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." _Information Systems Research 13(3)._
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." _Human Factors 46(1)._
- Cranor, L.F., and Garfinkel, S. (eds.) (2005). _Security and Usability._ O'Reilly.
- Norman, D.A. (1988). _The Design of Everyday Things._ Basic Books.

---

_Author: Jony Bursztyn · 2026-06-22_  
_Status: Design note — not yet a pre-registration. Finalize and submit to OSF after Study 1 H4 outcome is known._
