# Survey Instrument: PIUP Study 2 — Explanation Effects and Trust Calibration

**Date:** 2026-06-28  
**Author:** Jony Bursztyn  
**Status:** Pre-pilot draft — to be uploaded to OSF alongside Study 2 pre-registration  
**Companion documents:**
- [`docs/piup-study2-design-note-2026-06-22.md`](piup-study2-design-note-2026-06-22.md) — full study design and hypotheses
- [`docs/qualtrics-setup-guide-study2-2026-06-28.md`](qualtrics-setup-guide-study2-2026-06-28.md) — Qualtrics build guide (block-by-block implementation)
- [`analysis/piup-study2-analysis.R`](../analysis/piup-study2-analysis.R) — pre-registered analysis script
- [`analysis/piup-study2-drycheck.R`](../analysis/piup-study2-drycheck.R) — validation dry-run script
- [`docs/piup-study1-survey-instrument-2026-06-22.md`](piup-study1-survey-instrument-2026-06-22.md) — Study 1 instrument (4-condition between-subjects)

This document specifies the **exact question wording, answer options, scoring rubrics, condition-specific branching, and Qualtrics implementation notes** for Study 2. Any change to question wording after OSF registration constitutes an amendment and must be logged in the amendments table (§19).

---

## §1 Overview

Study 2 is a **2×2×2 between-subjects factorial experiment** (Label × Explanation × Calibration Intervention) testing whether explanation copy and a calibration intervention improve absent-content comprehension and trust in a private-voting receipt.

**Factors:**

| Factor | Level 1 | Level 2 |
|--------|---------|---------|
| L — Label | L1: "vote fingerprint" | L2: "confirmation code" |
| E — Explanation | E1: Explanation present | E2: Explanation absent |
| I — Intervention | I1: No pre-receipt calibration | I2: Pre-receipt calibration + feedback |

**8 conditions:**

| Code | Label | Explanation | Calibration |
|------|-------|-------------|-------------|
| L1E1I1 | vote fingerprint | present | none |
| L1E1I2 | vote fingerprint | present | calibration prompt |
| L1E2I1 | vote fingerprint | absent | none |
| L1E2I2 | vote fingerprint | absent | calibration prompt |
| L2E1I1 | confirmation code | present | none |
| L2E1I2 | confirmation code | present | calibration prompt |
| L2E2I1 | confirmation code | absent | none |
| L2E2I2 | confirmation code | absent | calibration prompt |

**Participants:** Recruited through Prolific. Assigned to one of 8 conditions via Qualtrics Randomizer (even distribution, n = 30 per cell, N = 240 target). Screener excludes software engineers and CS/SE students. Online voting experience is an inclusion criterion.

The `[LABEL_NOUN]` token throughout this document substitutes to "vote fingerprint" for L1 conditions and "confirmation code" for L2 conditions. In Qualtrics, this is piped from the `condition_label` Embedded Data field.

---

## §2 Survey Flow (Screen-by-Screen)

1. **Survey Flow — Embedded Data** — declare 15 fields before first block
2. **Qualtrics Randomizer** — 8 sub-elements (one per condition); even distribution; enforced by Quotas (n = 30 per condition)
3. **Screener** (SC1, SC2) — exclude software engineers and non-voters
4. **Welcome + Cover Story** — task framing (no response required)
5. **Calibration Block** (I2 conditions only) — two pre-receipt comprehension probes + accuracy feedback
6. **Stimulus Block** — interactive VoteReceipt prototype in iframe (90 s minimum), browser-fallback static screenshot
7. **AC1 — Attention Check 1** — follow-instruction check (before measures)
8. **Comprehension Block** (Q-AC) — primary measure M1
9. **Trust Scale** (TI1, TI2, TC1, TC2) — M2
10. **Save Intention** (M3-self) — self-report 1–7 scale
11. **Miscalibration Confidence** (M4, all conditions) — confidence in Q-AC answer (post-receipt; N=240)
12. **Open Text Q-OE** (M6) — absent-choice explanation
13. **AC2 — Attention Check 2** — forced-choice check (after measures)
14. **Demographics** (DM1–DM4)
15. **Debrief**
16. **Prolific Completion Code**

_Note: M5 (verification expansion click) is logged automatically by the interactive prototype's postMessage event; it does not correspond to a survey question. The Qualtrics Stimulus block JavaScript captures this into the `verify_expanded` Embedded Data field._

---

## §3 Screener Questions

Displayed immediately after Survey Flow initialisation, before the Welcome screen. Failing either criterion triggers Prolific screen-out redirect (set in Qualtrics Survey Options → Survey Termination → redirect to Prolific screen-out URL).

### SC1 — Online voting experience (inclusion criterion)

**Question text:**  
*"Have you voted in an online election, poll, or survey in the past 12 months? (This includes workplace polls, student-body elections, and any official online ballots.)"*

| Option | Routing |
|--------|---------|
| Yes | Continue |
| No | Screen out → redirect to Prolific screen-out URL |

### SC2 — Occupation exclusion

**Question text:**  
*"What best describes your main occupation or field of study?"*

| Option | Routing |
|--------|---------|
| Software engineer, developer, or programmer | Screen out |
| Other technology professional (e.g. IT support, data analyst, product manager) | Continue |
| Healthcare, education, law, finance, or public service | Continue |
| Skilled trades or manufacturing | Continue |
| Retail, hospitality, or service industry | Continue |
| Student (not in computer science or software engineering) | Continue |
| Student in computer science or software engineering | Screen out |
| Other | Continue |
| Prefer not to say | Continue |

*Exclusion note: Screen out for both `Software engineer` and `CS/SE student`. These are the same exclusion criteria as Study 1 (including the CS/SE student extension, Study 1 Amendment 5). Do not expose screened-out participants to any survey content.*

---

## §4 Welcome + Cover Story (Text Screen)

*Qualtrics "Text / Graphic" block — no response required.*

---

**Welcome. Estimated time: 10–15 minutes.**

You are helping researchers evaluate a **prototype voting interface**. You will interact with a screen that appears immediately after you submit a vote. Please read it carefully — you will be asked questions about it afterward.

- The interface is a **prototype only** — there is no real election and no real votes are being collected.
- You are not required to cast any vote or enter any personal information.
- You may interact with the screen (for example, using any buttons shown), but you are not required to.
- You will be asked questions about what the screen shows and what it means.

*Please do not use external resources (e.g., Google or Wikipedia) to answer the questions. We are interested in your natural understanding of the interface.*

---

## §5 Calibration Block (I2 conditions only)

*Branch logic: Show this block only when `intervention = I2`.*  
*Qualtrics block label: "Calibration — I2 conditions only."*

The calibration block appears **before** the Stimulus block (pre-receipt calibration). Two comprehension probes are shown, then immediate accuracy feedback is provided before the participant proceeds to the receipt.

### Text screen before probes

*Qualtrics "Text / Graphic" block — no response required.*

---

**Before we show you the receipt: two quick questions.**

These questions are about private voting systems in general. Please answer from your current understanding — there are no tricks.

---

### CAL1 — Screenshot coercion probe

**Question text:**  
*"If someone asked you to send them a screenshot of your voting receipt to prove how you voted, could they learn your vote choice from the screenshot?"*

| Option | Code |
|--------|------|
| Yes, they could see my vote | 0 (incorrect) |
| No, the receipt doesn't include my vote | 1 (correct) |
| I'm not sure | 0 |

*This is a forced-choice question — do not include "I'm not sure" as a selectable option if this creates demand characteristics; alternatively, keep it and score as incorrect. See design note §6.2.*

### CAL2 — Purpose of the receipt identifier probe

**Question text:**  
*"What is the main purpose of the [LABEL_NOUN] on the receipt?"*

| Option | Code |
|--------|------|
| To prove that you voted in this election | 0 |
| To confirm which voting option you chose | 0 |
| To let you verify later that your ballot was counted | 1 (correct) |
| To identify you to the election organizer | 0 |

### CAL-FEEDBACK — Accuracy feedback screen

*Displayed immediately after CAL1 and CAL2 are submitted. Text/Graphic block — no response required.*

---

**Your answers:**

**Question 1:** The correct answer is **No** — the receipt does not include your vote choice. This is intentional: showing your vote would create a risk of coercion.

**Question 2:** The correct answer is **To let you verify later that your ballot was counted** — the [LABEL_NOUN] proves your ballot was included in the tally, not what you voted.

*Now, please review the voting receipt on the next screen.*

---

*Implementation note: The calibration questions and feedback are shown BEFORE the interactive prototype is loaded. Participants in I2 conditions have their expected comprehension schema activated before they encounter absent vote choice in the receipt. This is the pre-specified mechanism for H2.3 (reducing miscalibration residual in L2 conditions).*

---

## §6 Stimulus Block — Interactive Prototype

### Prototype host URL

The `study2-host` Vite/React app serves `VoteReceipt` in `studyMode` at:

```
https://aztec-study2.vercel.app/?condition=L1E1I1
```

Replace `L1E1I1` with the piped Embedded Data field:

```
https://aztec-study2.vercel.app/?condition=${e://Field/condition}
```

*(The I factor in the URL is used only for the host's record; the receipt rendering is determined by L and E factors only. The Qualtrics survey handles the I-factor branching for the Calibration block independently.)*

### Embedding in Qualtrics

Use a Qualtrics "Text / Graphic" block with an `<iframe>` element:

```html
<iframe
  id="piup-receipt-frame"
  src="https://aztec-study2.vercel.app/?condition=${e://Field/condition}"
  width="100%"
  height="700px"
  style="border:none; max-width:600px; display:block; margin:0 auto;"
  sandbox="allow-scripts allow-same-origin allow-forms"
  title="Voting receipt prototype"
  aria-label="Voting receipt prototype"
></iframe>
```

### JavaScript — countdown, postMessage logging, browser-fallback detection

Add the following JavaScript to the Stimulus block ("Add JavaScript" in Qualtrics):

```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var self = this;
    var btn = self.getNextButton();
    var piupReady = false;
    var verifyExpanded = false;
    var downloadClicked = false;
    var fallbackShown = false;
    var TIMEOUT_MS = 8000;
    var COUNTDOWN_SEC = 90;

    // Disable next button and start countdown
    btn.disabled = true;
    btn.innerHTML = "Please review the receipt (1:30 remaining)";
    var seconds = COUNTDOWN_SEC;
    var timer = setInterval(function() {
        seconds--;
        if (seconds <= 0) {
            clearInterval(timer);
            btn.disabled = false;
            btn.innerHTML = "Continue";
        } else {
            var m = Math.floor(seconds / 60);
            var s = seconds % 60;
            btn.innerHTML = "Please review the receipt (" + m + ":" + (s < 10 ? "0" : "") + s + " remaining)";
        }
    }, 1000);

    // Browser-fallback: if piup-ready not received within TIMEOUT_MS, show static image
    var fallbackTimer = setTimeout(function() {
        if (!piupReady) {
            fallbackShown = true;
            Qualtrics.SurveyEngine.setEmbeddedData("browser_fallback", "1");
            // Show fallback static screenshot
            // Truncate 6-char condition code to 4 chars (e.g. "L1E1I1" → "L1E1").
            // Static files are named fallback-<LxEx>.png (I factor omitted; it does
            // not affect the receipt visual). See packages/study2-host/public/static/.
            var cond = "${e://Field/condition}".substring(0, 4); // e.g. "L1E1"
            var fallbackImg = document.getElementById("piup-fallback-img");
            if (fallbackImg) {
                fallbackImg.src = "https://aztec-study2.vercel.app/static/fallback-" + cond + ".png";
                fallbackImg.style.display = "block";
            }
            var frame = document.getElementById("piup-receipt-frame");
            if (frame) { frame.style.display = "none"; }
        }
    }, TIMEOUT_MS);

    // Listen for postMessage events from VoteReceipt
    window.addEventListener("message", function(event) {
        if (!event.data || !event.data.type) return;
        if (event.data.type === "piup-ready") {
            piupReady = true;
            clearTimeout(fallbackTimer);
            Qualtrics.SurveyEngine.setEmbeddedData("browser_fallback", "0");
        }
        if (event.data.type === "piup-download-click" && event.data.clicked === true) {
            downloadClicked = true;
            Qualtrics.SurveyEngine.setEmbeddedData("download_clicked", "1");
        }
        if (event.data.type === "piup-verify-expanded") {
            verifyExpanded = event.data.expanded;
            Qualtrics.SurveyEngine.setEmbeddedData("verify_expanded", event.data.expanded ? "1" : "0");
        }
    });

    // On next page: log stimulus_shown
    self.clickNextButton = function() {
        Qualtrics.SurveyEngine.setEmbeddedData("stimulus_shown", "1");
        if (!downloadClicked) {
            Qualtrics.SurveyEngine.setEmbeddedData("download_clicked", "0");
        }
        if (!verifyExpanded) {
            Qualtrics.SurveyEngine.setEmbeddedData("verify_expanded", "0");
        }
        return true;
    };
});
```

### Fallback static screenshot markup

Include a hidden `<img>` element below the iframe. The JavaScript above reveals it if the prototype does not load within the timeout:

```html
<img
  id="piup-fallback-img"
  src=""
  style="display:none; max-width:600px; width:100%; margin:0 auto;"
  alt="Voting receipt static fallback"
/>
```

*Note: The `src` attribute is intentionally left empty in the HTML. The JavaScript fallback timer sets it dynamically to `https://aztec-study2.vercel.app/static/fallback-<LxEx>.png` (4-char prefix; I factor omitted) at the moment the fallback fires. This ensures the image URL is always correct regardless of condition. Four fallback images must be pre-generated: `fallback-L1E1.png`, `fallback-L1E2.png`, `fallback-L2E1.png`, `fallback-L2E2.png`. See `packages/study2-host/scripts/generate-fallback-screenshots.js` for generation instructions.*

### Transition screen (after stimulus)

*Text/Graphic block — no response required.*

---

**The receipt screen is now hidden. Please answer the following questions from memory.**

*Take your time. There are no trick questions.*

---

## §7 Attention Check 1 (AC1)

*Placed after the transition screen, before the comprehension questions.*

**Question text:**  
*"This is an attention check to make sure you are reading carefully. Please select 'Strongly Disagree' as your response to this question, regardless of what it says."*

| Option | Code |
|--------|------|
| Strongly Agree | Fail |
| Agree | Fail |
| Neither Agree nor Disagree | Fail |
| Disagree | Fail |
| Strongly Disagree | Pass ✓ |

---

## §8 Primary Comprehension Measure (M1 — Q-AC)

**Primary endpoint for H2.1 (E main effect).**

**Question text:**  
*"Looking at that receipt: does it show which voting option you chose?"*

| Option | Code |
|--------|------|
| Yes, my vote choice is shown | 0 (incorrect) |
| No, my vote choice is not shown | 1 (correct) |
| It's not clear from what I see | 0 |

*Note: "voting option you chose" aligns with DAO governance terminology (non-candidate framing). If Study 2 is fielded with a political-election Prolific frame, update stem and options to "which candidate you voted for" / "Yes, my candidate is shown" / "No, my candidate is not shown" — both stem and options must be updated consistently (not mixed). Log any such update as an amendment.*

*Scoring: binary (1 = correct "No, my vote choice is not shown", 0 = all other answers). This is an observational question — the receipt is on-screen during the question; participants are asked to report what they see, not infer from abstract knowledge. The inference barrier is lower than Study 1's Q2 ("does having this [LABEL] prove which voting option you chose?"). Participants who choose the "not clear" option in E1 conditions (where the explanation copy is explicit) are of particular analytical interest as they may be indicating explanation-copy comprehension failure rather than stimulus ambiguity.*

*Column name in analysis script: `qac_correct` (`COL_QAC`)*

---

## §9 Trust Scale (M2 — McKnight 4-item adapted)

*Adapted from McKnight et al. (2002) integrity and competence subscales.*  
*All four items on the same page, presented as a grid or list.*

**Page heading (Text/Graphic):**  
*"Please rate your level of agreement with each statement about the receipt you just saw."*

7-point Likert scale for all items:  
1 = *Strongly Disagree* … 4 = *Neither Agree nor Disagree* … 7 = *Strongly Agree*

---

### TI1 — Receipt accuracy (Trust Integrity 1)

**Item text:**  
*"I believe this receipt accurately reflects what happened with my vote."*

*Column name: `trust_integrity_1` (`COL_TI1`)*

---

### TI2 — Identifier uniqueness (Trust Integrity 2)

**Item text:**  
*"I trust that the [LABEL_NOUN] is unique to my ballot."*

*Column name: `trust_integrity_2` (`COL_TI2`)*

---

### TC1 — Usability for verification (Trust Competence 1)

**Item text:**  
*"I feel confident I could use this receipt to prove my ballot was counted."*

*Column name: `trust_competence_1` (`COL_TC1`)*

---

### TC2 — Comprehension (Trust Competence 2)

**Item text:**  
*"I understand what this receipt is for."*

*Column name: `trust_competence_2` (`COL_TC2`)*

---

**Composite score (M2):**  
`M2 = mean(TI1, TI2, TC1, TC2)`. Cronbach's α ≥ 0.70 required before using composite in analysis. If α < 0.70, items are reported individually (pre-registered contingency; analysis script handles both paths).

---

## §10 Save Intention (M3)

*Self-report save intention — primary self-report measure.*

**Question text:**  
*"How likely are you to save or screenshot this receipt before closing this page?"*

| Option | Code |
|--------|------|
| Definitely will | 7 |
| Very likely | 6 |
| Somewhat likely | 5 |
| Neither likely nor unlikely | 4 |
| Somewhat unlikely | 3 |
| Very unlikely | 2 |
| Definitely will not | 1 |

*Note: This is a 7-point likelihood scale (not the 5-point "Definitely would / Probably would" scale used in Study 1 BI1). The finer-grained scale is used here because M3 save_intention is a primary secondary endpoint (H2.4), not a tertiary behavioral intent item.*

*Download click (behavioral proxy for M3):* Captured via `piup-download-click` postMessage event in the Stimulus block JavaScript above. No separate survey question required. Column name: `download_clicked` (`COL_DOWNLOAD_CLICK`).

*Column name (self-report): `save_intention` (`COL_SAVE_INTENT`)*

---

## §11 Calibration Confidence (M4 — all conditions)

*Branch logic: Show this question for all conditions (no branch restriction).*

**Question text:**  
*"How confident are you in your answer above?"*

7-point Likert:  
1 = *Not at all confident* … 4 = *Moderately confident* … 7 = *Completely confident*

*Note: This item measures post-receipt confidence in the Q-AC answer (M1). It is placed immediately after Q-AC on the same page. The analysis script computes the calibration residual as: `m4_residual = (calibration_confidence − 1) / 6 − qac_correct`. Confidence is first rescaled from its raw 1–7 range to a 0–1 scale using the `(x − 1) / 6` transform, so that it is on the same 0–1 metric as Q-AC binary accuracy before subtraction. Positive residual = over-confidence (confident but wrong on Q-AC); negative residual = under-confidence (answered Q-AC correctly but rated own calibration-probe answers poorly).*

*Column name: `calibration_confidence` (`COL_CALIB_CONF`)*

---

## §12 Open-Text Q-OE (M6)

**Question text:**  
*"In your own words, why doesn't this receipt show which voting option you chose?"*

*Free text entry. Minimum character limit: 20 characters.*  
*Response box size: tall enough for 3–4 lines of text.*

*Note: Q-OE asks the participant to articulate a design reason (active explanation generation) rather than simply recognise correct/incorrect features. The question phrasing presupposes that the receipt does not show the vote choice — which is the correct understanding. This phrasing prevents confusion from participants who answered "Yes, my vote choice is shown" on Q-AC; the question re-anchors them to the correct state before asking for an explanation. If post-hoc it becomes apparent this phrasing inflates Q-OE scores for incorrect-Q-AC participants, report this as an exploratory sensitivity check.*

*Column names: `qoe_rater1` (`COL_QOE_RATER1`), `qoe_rater2` (`COL_QOE_RATER2`)*

---

## §13 Attention Check 2 (AC2)

*Placed after the open-text question, before demographics.*

**Question text:**  
*"Please select the third item from the list below."*

| Option | Code |
|--------|------|
| Apple | Fail |
| Banana | Fail |
| Carrot | Pass ✓ |
| Dog | Fail |
| Elephant | Fail |

**Exclusion rule (pre-registered):** Participants who fail **both** AC1 and AC2 are excluded from all primary analyses. Single attention-check failure: retained. Record individual AC responses in the raw dataset; apply exclusion in the R analysis script (see `piup-study2-analysis.R` §Exclusions), not at the Qualtrics survey level.

---

## §14 Demographics

### DM1 — Age range

**Question text:**  
*"What is your age?"*

18–24 / 25–34 / 35–44 / 45–54 / 55–64 / 65 or older / Prefer not to say

*Column name: `age_group` (`COL_AGE`)*

### DM2 — Technology background (secondary cross-check)

**Question text:**  
*"Have you ever written code professionally or as part of a degree?"*

| Option | Code |
|--------|------|
| Yes — as my main job | Flag (`occupation_sw_eng = 1`) for sensitivity analysis |
| Yes — occasionally / as part of a degree | Flag for sensitivity analysis |
| No | Reference group |
| Prefer not to say | Include |

*Note: SC2 (screener) excludes practising software engineers before they enter. DM2 is a secondary cross-check for sensitivity analysis — it does not trigger exclusion. Compare results with and without DM2-flagged participants as an exploratory analysis.*

*Column name: `occupation_sw_eng` (`COL_OCCUPATION`) — 1 if main-job or degree-level coding*

### DM3 — Prior voting experience specificity

**Question text:**  
*"Which of the following have you participated in? (Select all that apply)"*

- An online opinion poll or workplace survey
- A national or local government election (online or paper)
- A student body or organisational election (online or paper)
- I have never voted in any election or poll *(log as inconsistent with SC1; do not auto-exclude — apply sensitivity check in analysis)*
- Prefer not to say

*Column name: `prior_voting` (`COL_PRIOR_VOTE`)*

### DM4 — Prior voting-receipt study participation

**Question text:**  
*"Have you participated in a previous study about voting receipts, voting confirmations, or post-vote screens in the past 6 months?"*

| Option | Code |
|--------|------|
| Yes | Flag (`prior_receipt_study = 1`) — exclude from primary analysis, include in sensitivity check |
| No | Reference group |
| I'm not sure | Include (treat as No) |

*Column name: `prior_receipt_study` (`COL_PRIOR_STUDY`)*

*Design rationale: Study 2 is fielded after Study 1. Participants who completed Study 1 may have calibrated their understanding of absent-content receipts. The Prolific "previous studies" filter is the first line of defence (set to exclude Study 1 ID); DM4 is a self-report cross-check.*

---

## §15 Debrief Screen

*Text/Graphic block — no response required.*

---

**Thank you for your participation.**

This study examined how the design of a voting receipt affects people's understanding and trust. Specifically, we looked at how different label names ("vote fingerprint" vs. "confirmation code") and explanatory text affect whether people correctly understand that the receipt does not show their vote choice.

In real private voting systems, the identifier — whether called a "vote fingerprint," a "confirmation code," or something else — proves only that your vote was counted, not which option you chose. This is an intentional privacy-preserving feature.

The study is being conducted as part of research on the usability of privacy-preserving voting technology. If you have questions, please contact the research team via Prolific.

**Compensation:** You will receive your Prolific payment regardless of your answers. There are no correct or incorrect answers from a payment perspective.

*Your completion code will appear on the next screen.*

---

## §16 Scoring Rubric — Q-OE Open-Ended Item (M6)

### Q-OE: "In your own words, why doesn't this receipt show which voting option you chose?"

Two independent raters score each response on a 0–2 scale before any confirmatory analysis is run.

| Score | Criteria |
|-------|----------|
| **2** | Response correctly identifies **privacy or ballot secrecy as a deliberate design feature**. Must include: (1) something equivalent to "to protect privacy / anonymity / secrecy" AND (2) either an explanation that this was intentional/designed, OR a reason why it would be harmful to show the vote (coercion risk, traceability). Example: "Because showing my vote would let others see how I voted and might pressure me to vote differently next time." |
| **1** | Response mentions one correct element — privacy, secrecy, or "so others can't see" — without explicitly framing it as a design decision or without naming a concrete consequence. "For privacy" or "to keep it secret" alone = 1. Responses that correctly recognise absence as a feature (not an error) but cannot articulate why = 1. |
| **0** | No correct element. Includes: "I don't know," technical error attribution ("it didn't save," "the system didn't record it," "it was encrypted"), responses expressing confusion, or responses that state the vote choice IS shown somewhere ("you can find it if you look"). |

**IRR threshold:** κ ≥ 0.70 required before including Q-OE in any pre-specified analysis. If κ < 0.70 on pilot data, raters adjudicate disagreements and rescore using the revised rubric. Log rubric revision as a protocol amendment.

**Tie-breaking:** If rater 1 = 1 and rater 2 = 2 (or vice versa), the two raters discuss until consensus. If no consensus, the lower score is used.

**Analysis script column:** `qoe_rater1`, `qoe_rater2`. The script computes `qoe_final = round((r1 + r2) / 2)` after IRR check.

---

## §17 Qualtrics Implementation Notes

### Embedded Data fields (declare all before first block)

```
condition           = (from Randomizer)         — e.g. "L1E1I1"
label               = (from Randomizer)         — "L1" or "L2"
explanation         = (from Randomizer)         — "E1" or "E2"
intervention        = (from Randomizer)         — "I1" or "I2"
condition_label     = (from Randomizer)         — "vote fingerprint" or "confirmation code"
PROLIFIC_PID        = (from URL param)
STUDY_ID            = (from URL param)
SESSION_ID          = (from URL param)
stimulus_shown      = ""                        — set by JS to "1"
time_on_stimulus    = ""                        — set by JS (if implementing timer)
download_clicked    = ""                        — set by JS to "1" or "0"
verify_expanded     = ""                        — set by JS to "1" or "0"
browser_fallback    = ""                        — set by JS to "0" or "1"
```

*All piped-text references to `[LABEL_NOUN]` use `${e://Field/condition_label}`.*

### Qualtrics Randomizer setup

Add one Randomizer block at Survey Flow start. Inside it, add 8 sub-elements (one per condition). Each sub-element is a short branch that sets all factor-level Embedded Data fields:

**Example — sub-element for L1E1I1:**
```
Set Embedded Data:
  condition         = L1E1I1
  label             = L1
  explanation       = E1
  intervention      = I1
  condition_label   = vote fingerprint
```

**Even distribution:** Enable "Evenly Present Elements" in the Randomizer.  
**Quota enforcement:** Add 8 Quotas (one per condition, n = 30). When quota is met, redirect to Prolific over-quota URL.

### I2 Calibration block — branch logic

In Survey Flow, wrap the Calibration block (§5: CAL1, CAL2, CAL-FEEDBACK) in a Branch:

```
Branch: If intervention = I2 → show [Calibration Block]
```

Place this Branch immediately before the Stimulus block. I1 participants skip directly to the Stimulus block.

### Qualtrics timing

Use the built-in **Timing question** in a hidden block before the Screener and after the Debrief to capture total survey duration in seconds. Add Embedded Data field `response_time_sec` and populate it from the Timing question export column.

*Column name: `response_time_sec` (`COL_RT_SEC`). Exclusion criterion: `response_time_sec < 90` (applied in analysis script, not in Qualtrics).*

### Prolific setup

- Create one Prolific study with the Qualtrics survey URL.
- In the URL, include Prolific parameters: `?PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}`.
- Set "Previous Studies" filter to exclude Study 1 Prolific study ID.
- Set "Country of Origin" filter consistent with Study 1 (US/UK/CA/AU).
- Reward and estimated completion time: match Study 1 rate (≥ £9.00/hr equivalent).
- Set "Fluent English" filter.
- Sample size: recruit to N = 240 (Quotas will close each condition at n = 30; use over-recruit buffer of ~10% → target N = 265 submissions).

### Block randomisation note

Q-AC, TI1–TC2, M3, M4, M6 are presented in **fixed order** (not randomised). Fixed order preserves comparability with Study 1 and ensures the trust scale (M2) always follows the primary accuracy question (M1). Do not randomise question order within or across blocks after OSF registration.

---

## §18 Variable Codebook

Matches column map constants in `analysis/piup-study2-analysis.R`. Update those constants to match the actual Qualtrics export column headers before running the analysis.

| Variable name | Analysis script constant | Type | Description |
|---------------|--------------------------|------|-------------|
| `participant_id` | `COL_ID` | string | Prolific participant ID |
| `condition` | `COL_CONDITION` | string | Condition code (e.g. "L1E1I1") |
| `label` | `COL_L` | string | "L1" or "L2" |
| `explanation` | `COL_E` | string | "E1" or "E2" |
| `intervention` | `COL_I` | string | "I1" or "I2" |
| `qac_correct` | `COL_QAC` | 0/1 | 1 = "No, my vote choice is not shown" |
| `trust_integrity_1` | `COL_TI1` | 1–7 | Receipt accurately reflects vote |
| `trust_integrity_2` | `COL_TI2` | 1–7 | [LABEL_NOUN] is unique to ballot |
| `trust_competence_1` | `COL_TC1` | 1–7 | Could use receipt to prove counted |
| `trust_competence_2` | `COL_TC2` | 1–7 | Understands what receipt is for |
| `save_intention` | `COL_SAVE_INTENT` | 1–7 | Likelihood to save/screenshot receipt |
| `download_clicked` | `COL_DOWNLOAD_CLICK` | 0/1 | 1 = clicked download button in prototype |
| `calibration_confidence` | `COL_CALIB_CONF` | 1–7 | Post-receipt Q-AC confidence (all conditions; N=240) |
| `verify_expanded` | `COL_VERIFY_EXPAND` | 0/1 | 1 = expanded "how to verify" accordion |
| `qoe_rater1` | `COL_QOE_RATER1` | 0/1/2 | Q-OE score from rater 1 |
| `qoe_rater2` | `COL_QOE_RATER2` | 0/1/2 | Q-OE score from rater 2 |
| `attention_check_1` | `COL_ATTN1` | 0/1 | 1 = pass (selected "Strongly Disagree") |
| `attention_check_2` | `COL_ATTN2` | 0/1 | 1 = pass (selected "Carrot") |
| `response_time_sec` | `COL_RT_SEC` | integer | Total survey completion time in seconds |
| `occupation_sw_eng` | `COL_OCCUPATION` | 0/1 | 1 = self-reported software engineer or CS student (sensitivity only) |
| `prior_receipt_study` | `COL_PRIOR_STUDY` | 0/1 | 1 = participated in prior voting-receipt study |
| `browser_fallback` | `COL_BROWSER_FALLBACK` | 0/1 | 1 = received static screenshot (prototype did not render) |
| `age_group` | `COL_AGE` | ordinal | Age range bucket (18–24, 25–34, …) |
| `prior_voting` | `COL_PRIOR_VOTE` | multi-select | Voting experience types |
| `tech_efficacy_mean` | `COL_EFFICACY` | float | Optional: 3-item Hargittai tech efficacy scale mean (if included in final survey) |
| `stimulus_shown` | — | 0/1 | 1 = participant confirmed seeing stimulus (set by Stimulus block JS) |

*`tech_efficacy_mean` (`COL_EFFICACY`): This item is optional in Study 2. If tech efficacy items (3-item Hargittai scale) are added as a demographics supplement to match Study 1's DM2 coding, compute the mean here. If not included, `COL_EFFICACY` is unused by the analysis script (it is referenced only in exploratory sections).*

---

## §19 Amendments Log

| Date | Amendment type | Description | Authorized by |
|------|---------------|-------------|---------------|
| 2026-06-28 | Initial instrument draft | First complete draft of Study 2 survey instrument. Pre-pilot; not yet submitted to OSF. (tick-4069) | OpenClaw Agent |
| 2026-06-28 | Three consistency fixes (tick-4070) | (1) §11 M4 residual formula: added `(conf − 1)/6` rescaling step that was present in the analysis script but missing from the instrument's verbal description. (2) §6 Fallback img src: changed from static `fallback-${condition}.png` (would 404 with 6-char code) to dynamically set by JS at fallback-fire time using 4-char `cond` prefix. (3) analysis.R M6: changed `rowMeans()` to `round(rowMeans())` to match instrument §16 formula. All pre-pilot; no protocol change, no change to question wording or hypotheses. | OpenClaw Agent |
| 2026-06-30 | TOC M4 scope + description fix (tick-4260) | TOC §11 entry said "(M4, I2 only) — confidence rating for calibration probe answers". Two bugs: (1) "I2 only" should be "all conditions" — Amendment 7 (tick-4246) changed M4 from I2-only retrospective CAL-probe confidence to all-conditions post-receipt Q-AC confidence, but the TOC was never updated; §11 body and data dictionary already said "all conditions". (2) "calibration probe answers" is the wrong description — M4 measures confidence in the Q-AC answer (M1), not in CAL1/CAL2 (which are the I2 pre-receipt comprehension probes). Corrected to "all conditions — confidence in Q-AC answer (post-receipt; N=240)". No question wording, branch logic, or analysis change; description precision only. | OpenClaw Agent |
| (pending) | OSF registration | Upload this document, `piup-study2-analysis.R`, and `piup-study2-design-note-2026-06-22.md` to OSF before any data collection. | Jony Bursztyn |

---

## §20 Pre-Launch Checklist

- [ ] Study 1 pilot (N = 40) run and Q-AC baseline in E2 conditions confirmed
- [ ] Study 1 H4 verdict known (determines whether H2.3 / I2 calibration test is run)
- [ ] N = 240 power confirmed against Study 1 pilot Q-AC estimates; if E2 baseline < 40%, increase to N = 320 (n = 40/cell)
- [ ] Interactive prototype deployed to Vercel (study2-host) and all 8 condition URLs verified
- [ ] Four static fallback screenshots generated and deployed (`/static/fallback-L1E1.png`, etc.)
- [ ] Qualtrics survey built per `qualtrics-setup-guide-study2-2026-06-28.md`
- [ ] All 8 condition URLs tested end-to-end: Randomizer → correct condition → prototype → questions → Prolific completion
- [ ] Pilot dry-run: 5 participants per condition (N = 40) via Prolific; verify column structure with `piup-study2-drycheck.R`
- [ ] IRR pilot: two raters score all N = 40 pilot Q-OE responses; κ ≥ 0.70 confirmed
- [ ] This document, `piup-study2-analysis.R`, and `piup-study2-design-note-2026-06-22.md` uploaded to OSF
- [ ] OSF DOI obtained and inserted into CHI paper §5 "Study 2 pre-registration" placeholder
- [ ] Prolific "Previous Studies" filter set to exclude Study 1 Prolific study ID
- [ ] Prolific budget approved for N = 265 (N = 240 + 10% over-recruit buffer)

---

*Author: Jony Bursztyn · 2026-06-28*  
*This survey instrument is part of the pre-registered PIUP Study 2 protocol. Changes to question wording, answer options, or scoring rubrics after OSF upload must be logged in §19 above and noted as amendments in the OSF pre-registration record.*
