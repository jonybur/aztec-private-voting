# Qualtrics Setup Guide — PIUP Study 2

**Author:** Jony Bursztyn  
**Date:** 2026-06-28  
**Design note:** [`docs/piup-study2-design-note-2026-06-22.md`](piup-study2-design-note-2026-06-22.md)  
**Analysis script:** [`analysis/piup-study2-analysis.R`](../analysis/piup-study2-analysis.R)

This is a click-by-click implementation guide for building the PIUP Study 2 survey in Qualtrics. Study 2 is a 2×2×2 between-subjects factorial (L × E × I; 8 cells, N = 240, n = 30 per cell).

**Key differences from Study 1:**
- 8 conditions (not 4) — Qualtrics Randomizer handles within-survey assignment.
- Stimulus is an **interactive prototype** (Vercel-hosted React component), not a static screenshot.
- Factor I (Calibration Intervention) adds a **pre-receipt prompt** block in I2 conditions.
- **Behavioral logging**: download click and verify-expansion are captured via `window.postMessage` from the prototype back to Qualtrics.
- **Browser-fallback detection**: prototype must fire a ready signal within 8 seconds; failure triggers static screenshot fallback and `browser_fallback = "1"`.

Estimated setup time: 3–4 hours (guide + Vercel host setup).

---

## Prerequisites

Before starting:
- [ ] Study 2 interactive prototype host page built and deployed (see §A — Prototype Host Setup).
- [ ] Note the Vercel deployment URL: `https://aztec-study2.vercel.app` (or your domain).
- [ ] Prolific study created (or ready). You will need the **Screen Out URL** and **Completion URL**.
- [ ] Qualtrics account with JavaScript allowed (university licence or paid tier).

---

## §A — Prototype Host Setup (required before Qualtrics build)

The Study 2 stimulus is the `VoteReceipt` React component rendered in `studyMode`. It must be hosted on a page that:
1. Reads condition parameters from the URL query string.
2. Renders `VoteReceipt` with the appropriate props.
3. Sends `window.parent.postMessage` events for behavioral logging (download click, verify expansion, render-ready signal).

### A.1 URL parameter schema

The hosted page accepts a single `condition` query parameter:

| URL parameter | Example values |
|---------------|---------------|
| `condition`   | `L1E1I1`, `L1E1I2`, `L1E2I1`, `L1E2I2`, `L2E1I1`, `L2E1I2`, `L2E2I1`, `L2E2I2` |

The host page decodes the condition string and maps it to `VoteReceipt` props:

| Condition segment | VoteReceipt prop | Value |
|-------------------|-----------------|-------|
| L1 | `labelVariant` prop | `"fingerprint"` |
| L2 | `labelVariant` prop | `"confirmation-code"` |
| E1 | `explanationVariant` | `"explained"` |
| E2 | `explanationVariant` | `"unexplained"` |
| `studyMode` | always `true` | disables real download; routes to callbacks |

> **Note on Factor I (Calibration Intervention):** The I factor (I1/I2) is handled entirely in Qualtrics — the pre-receipt calibration prompt and feedback are Qualtrics question blocks. The hosted prototype page does NOT need to vary by I level. All 8 condition variants map to only 4 distinct prototype pages (L × E).

### A.2 postMessage protocol

The host page sends the following messages to `window.parent`:

| Event | postMessage payload |
|-------|---------------------|
| Prototype rendered successfully | `{ type: 'piup-ready' }` |
| Download button clicked | `{ type: 'piup-download-click', clicked: true }` |
| Verify section toggled | `{ type: 'piup-verify-expanded', expanded: true \| false }` |

Send `piup-ready` after `useEffect` confirms the component has mounted (or in `onLoad` of the iframe host). This is the browser-fallback signal: if Qualtrics does not receive `piup-ready` within 8 seconds, it assumes the prototype failed to render.

### A.3 Minimal host page (React)

```jsx
// study2-host/src/App.jsx  — deploy to Vercel as a standalone app
import { useEffect, useCallback } from 'react';
import { VoteReceipt } from '@aztec-private-voting/react';
import '@aztec-private-voting/react/dist/style.css';

const FAKE_RECEIPT = {
  electionId: 'piup-study-2026',
  nullifier: '0xa3f7...8c2e',
  timestamp: new Date().toISOString(),
  verificationUrl: 'https://verify.example.com',
};

export default function App() {
  const params = new URLSearchParams(window.location.search);
  const condition = params.get('condition') ?? 'L1E1I1';

  const labelVariant = condition.startsWith('L1') ? 'fingerprint' : 'confirmation-code';
  const explanationVariant = condition.includes('E1') ? 'explained' : 'unexplained';

  // Signal render-ready to Qualtrics parent
  useEffect(() => {
    window.parent?.postMessage({ type: 'piup-ready' }, '*');
  }, []);

  const handleDownloadClick = useCallback(() => {
    window.parent?.postMessage({ type: 'piup-download-click', clicked: true }, '*');
  }, []);

  const handleVerifyExpanded = useCallback((expanded) => {
    window.parent?.postMessage({ type: 'piup-verify-expanded', expanded }, '*');
  }, []);

  return (
    <div style={{ padding: '16px', maxWidth: '640px', margin: '0 auto' }}>
      <VoteReceipt
        receipt={FAKE_RECEIPT}
        labelVariant={labelVariant}
        explanationVariant={explanationVariant}
        studyMode={true}
        onDownloadClick={handleDownloadClick}
        onVerifyExpanded={handleVerifyExpanded}
      />
    </div>
  );
}
```

Deploy with `npx vercel --prod` from `study2-host/`. After deploy, note the URL (e.g. `https://aztec-study2.vercel.app`).

Test each variant manually before building the Qualtrics survey:
- `https://aztec-study2.vercel.app?condition=L1E1I1` → fingerprint, explained
- `https://aztec-study2.vercel.app?condition=L2E2I1` → confirmation code, no explanation
- Open DevTools → Console → check `piup-ready` fires on load.

---

## Step 1 — Create the Survey

1. Log in to Qualtrics → **Create new project** → **Survey**.
2. Name it: `PIUP Study 2 — VoteReceipt Explanation & Trust (2×2×2)`.
3. Start with a **Blank survey project**.
4. Rename the default block to `Screener`.

---

## Step 2 — Survey Flow (Critical — do this before adding questions)

Survey Flow controls the 8-condition randomisation, factor assignments, and branch logic. Set it up before building any blocks.

**Open:** Builder → **Survey Flow** (top menu bar).

### 2a. Embedded Data element (first — before all blocks)

Click **Add a New Element Here** → **Embedded Data**.

Add all fields below in order:

| Field name | Default value | Purpose |
|------------|---------------|---------|
| `condition` | *(blank)* | 8-level condition code set by Randomizer below |
| `label_factor` | *(blank)* | L1 or L2 |
| `explanation_factor` | *(blank)* | E1 or E2 |
| `intervention_factor` | *(blank)* | I1 or I2 |
| `condition_label` | *(blank)* | Human-readable label for piped text |
| `PROLIFIC_PID` | *(blank)* | From URL param |
| `STUDY_ID` | *(blank)* | From URL param |
| `SESSION_ID` | *(blank)* | From URL param |
| `stimulus_shown` | `0` | Set to 1 when prototype displayed |
| `time_on_stimulus` | `0` | Seconds on stimulus (set by JS) |
| `download_clicked` | `0` | Set to 1 by postMessage listener |
| `verify_expanded` | `0` | Set to 1 by postMessage listener |
| `browser_fallback` | `0` | Set to 1 if prototype fails to render in 8s |

> **Why `browser_fallback` here:** The analysis script reads `browser_fallback` as a sensitivity covariate (§9.3 of design note). It must be declared in this Embedded Data block — before the Stimulus block — so Qualtrics captures it in the CSV export regardless of whether the JS fires successfully.

### 2b. Randomizer element

After the Embedded Data element, click **Add a New Element Here** → **Randomizer**.

Set: **Evenly Present Elements** — present **1** of the 8 sub-elements (even distribution).

Inside the Randomizer, add 8 Embedded Data sub-elements (one per condition):

**Sub-element 1 (L1E1I1):**
- `condition` = `L1E1I1`
- `label_factor` = `L1`
- `explanation_factor` = `E1`
- `intervention_factor` = `I1`
- `condition_label` = `vote fingerprint`

**Sub-element 2 (L1E1I2):**
- `condition` = `L1E1I2`
- `label_factor` = `L1`
- `explanation_factor` = `E1`
- `intervention_factor` = `I2`
- `condition_label` = `vote fingerprint`

**Sub-element 3 (L1E2I1):**
- `condition` = `L1E2I1`
- `label_factor` = `L1`
- `explanation_factor` = `E2`
- `intervention_factor` = `I1`
- `condition_label` = `vote fingerprint`

**Sub-element 4 (L1E2I2):**
- `condition` = `L1E2I2`
- `label_factor` = `L1`
- `explanation_factor` = `E2`
- `intervention_factor` = `I2`
- `condition_label` = `vote fingerprint`

**Sub-element 5 (L2E1I1):**
- `condition` = `L2E1I1`
- `label_factor` = `L2`
- `explanation_factor` = `E1`
- `intervention_factor` = `I1`
- `condition_label` = `confirmation code`

**Sub-element 6 (L2E1I2):**
- `condition` = `L2E1I2`
- `label_factor` = `L2`
- `explanation_factor` = `E1`
- `intervention_factor` = `I2`
- `condition_label` = `confirmation code`

**Sub-element 7 (L2E2I1):**
- `condition` = `L2E2I1`
- `label_factor` = `L2`
- `explanation_factor` = `E2`
- `intervention_factor` = `I1`
- `condition_label` = `confirmation code`

**Sub-element 8 (L2E2I2):**
- `condition` = `L2E2I2`
- `label_factor` = `L2`
- `explanation_factor` = `E2`
- `intervention_factor` = `I2`
- `condition_label` = `confirmation code`

> **Quotas:** After building the full survey, add 8 Quotas in **Survey Options → Quotas** — one per condition, counting on `Embedded Data` `condition` equals the condition code, quota = 30. When quota is met → redirect to Prolific over-quota URL. This enforces n = 30 per cell.

### 2c. Screener block

After the Randomizer, add: **Block** → `Screener`.

### 2d. Calibration Intervention branch (I factor)

After the Screener, add a **Branch** element:

**Branch condition:** `Embedded Data` | `intervention_factor` | `Equals` | `I2`

Inside this branch, add: **Block** → `Calibration` (create this block now; questions added in Step 6).

Participants in I1 conditions skip this block entirely. Participants in I2 see it before the stimulus.

### 2e. Remaining blocks (all conditions)

After the I2 branch, add the remaining blocks in this order:
1. Welcome
2. Stimulus
3. Attention Check 1
4. Comprehension (M1, M2, M3-self-report, M4, M5 questions)
5. Attention Check 2
6. Demographics
7. Debrief

Click **Save Flow**.

---

## Step 3 — Screener Block

### SC1 — Voting experience

- Question type: **Multiple Choice** (single select)
- Text: `Have you voted in an online election, poll, or survey in the past 12 months? (This includes workplace polls, student-body elections, and any official online ballots.)`
- Choices: `Yes` | `No`
- Skip Logic on `No` → End of Survey (Prolific screen-out URL).

### SC2 — Occupation exclusion

- Question type: **Multiple Choice** (single select)
- Text: `What best describes your main occupation or field of study?`
- Choices: same as Study 1 (see Study 1 guide §3 for full list).
- Skip Logic on choices 1 (Software engineer) and 7 (CS student) → End of Survey.

### SC3 — Prior receipt study exclusion

- Question type: **Multiple Choice** (single select)
- Text: `Have you participated in any online research study involving voting interfaces, voting receipts, or confirmation codes in the past 6 months?`
- Choices: `Yes` | `No` | `Not sure`
- Skip Logic on `Yes` → End of Survey (cross-study contamination exclusion — §11.4 of design note).

> ⚠️ **JONY-ACTION GG (structural conflict): This guide adds SC3 to screen out prior-study participants before data collection (no data collected for them). The pre-registered instrument has no SC3 — it uses DM4 (demographics) to capture this group and excludes them post-hoc in R, with the Prolific "Previous Studies" filter as primary defence. These are incompatible: option (a) remove SC3 and use the instrument DM4 post-hoc approach (no amendment needed); option (b) keep SC3 and log it as a protocol amendment before OSF registration. Guide left unchanged pending Jony confirmation. Note: GG also affects DM3 wording — see below.**

---

## Step 4 — Welcome Block

- Question type: **Text / Graphic** (Descriptive Text, no response required).

```
Welcome. Estimated time: 10–15 minutes.

You are helping researchers evaluate a prototype voting interface. You will interact with a screen that appears immediately after you submit a vote. Please read it carefully — you will be asked questions about it afterward.

• The interface is a prototype only — there is no real election and no real votes are being collected.
• You are not required to cast any vote or enter any personal information.
• You may interact with the screen (for example, using any buttons shown), but you are not required to.
• You will be asked questions about what the screen shows and what it means.

Please do not use external resources (e.g., Google or Wikipedia) to answer the questions. We are interested in your natural understanding of the interface.
```

---

## Step 5 — Stimulus Block

The Stimulus block embeds the interactive VoteReceipt prototype in an iframe. It captures behavioral signals (download click, verify expansion) via postMessage and detects browser-fallback.

### 5a. Stimulus display question

- Question type: **Text / Graphic** (Descriptive Text, no response required).
- Click `<>` HTML editor in the Rich Content Editor. Paste:

```html
<div id="piup-stimulus-container">
  <iframe
    id="piup-prototype-frame"
    src="https://aztec-study2.vercel.app?condition=${e://Field/condition}"
    width="100%"
    height="700px"
    style="border:none; border-radius:8px; display:block;"
    allow="same-origin">
  </iframe>

  <!-- Fallback: hidden until browser-fallback detected -->
  <div id="piup-fallback" style="display:none;">
    <p style="color:#666; font-size:0.9em;">
      The interactive prototype could not load in your browser.
      A screenshot of the voting receipt is shown below instead.
    </p>
    <img
      id="piup-fallback-img"
      src=""
      alt="Vote receipt prototype (static fallback)"
      style="width:100%; border-radius:8px; border:1px solid #e0e0e0;"
    />
  </div>

  <p style="font-size:0.85em; color:#666; margin-top:8px;">
    Prototype interface — read it carefully and try any interactive elements before continuing.
  </p>
</div>
```

> **Fallback img src:** The `src` attribute is intentionally left empty in the HTML. The JavaScript fallback timer (§5b) sets it dynamically — using `"${e://Field/condition}".substring(0, 4)` — at the moment the 8-second timeout fires. This avoids an unnecessary browser pre-fetch of the fallback image on every survey page load, and ensures the URL is correct regardless of condition. Do not add a static src here.

> **Fallback images:** Generate 4 static fallback screenshots (L1E1, L1E2, L2E1, L2E2) from the deployed Vercel host and add them to `study2-host/public/static/` before launch. Name them exactly `fallback-L1E1.png`, `fallback-L1E2.png`, `fallback-L2E1.png`, `fallback-L2E2.png`.

### 5b. Stimulus JavaScript (browser-fallback + behavioral logging)

Add JavaScript to the Stimulus question: **question options → Add JavaScript**. Replace all default code:

```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var engine = this;
    var btn = engine.getNextButton();
    btn.disabled = true;
    btn.innerHTML = "Please review the interface (1:30 remaining)";

    // ── Countdown timer ──────────────────────────────────────────────────────
    var seconds = 90;
    var timer = setInterval(function() {
        seconds--;
        if (seconds <= 0) {
            clearInterval(timer);
            btn.disabled = false;
            btn.innerHTML = "Continue";
            Qualtrics.SurveyEngine.setEmbeddedData("stimulus_shown", "1");
        } else {
            var m = Math.floor(seconds / 60);
            var s = seconds % 60;
            btn.innerHTML = "Please review the interface (" + m + ":" +
                            (s < 10 ? "0" : "") + s + " remaining)";
        }
    }, 1000);

    // ── Time-on-stimulus recording ────────────────────────────────────────────
    var startTime = Date.now();
    var origOnclick = btn.onclick;
    btn.onclick = function() {
        var elapsed = Math.round((Date.now() - startTime) / 1000);
        Qualtrics.SurveyEngine.setEmbeddedData("time_on_stimulus", String(elapsed));
        if (origOnclick) origOnclick.call(this);
    };

    // ── Browser-fallback detection ────────────────────────────────────────────
    // If the prototype does not send piup-ready within 8 seconds, show fallback.
    var readyReceived = false;
    var fallbackTimeout = setTimeout(function() {
        if (!readyReceived) {
            // Prototype failed to render — show static fallback.
            // Set img src dynamically: truncate 6-char condition to 4-char LxEx prefix.
            // Files are named fallback-L1E1.png etc. (I factor omitted; not needed for screenshots).
            var cond = "${e://Field/condition}".substring(0, 4);
            var fallbackImg = document.getElementById('piup-fallback-img');
            if (fallbackImg) {
                fallbackImg.src = 'https://aztec-study2.vercel.app/static/fallback-' + cond + '.png';
            }
            document.getElementById('piup-prototype-frame').style.display = 'none';
            document.getElementById('piup-fallback').style.display = 'block';
            Qualtrics.SurveyEngine.setEmbeddedData("browser_fallback", "1");
        }
    }, 8000);

    // ── postMessage listener (behavioral signals from prototype) ─────────────
    function onMessage(event) {
        // Accept messages from the prototype host domain only
        if (event.origin !== 'https://aztec-study2.vercel.app') return;

        var data = event.data;
        if (!data || !data.type) return;

        if (data.type === 'piup-ready') {
            readyReceived = true;
            clearTimeout(fallbackTimeout);
            Qualtrics.SurveyEngine.setEmbeddedData("browser_fallback", "0");
        }
        if (data.type === 'piup-download-click' && data.clicked === true) {
            Qualtrics.SurveyEngine.setEmbeddedData("download_clicked", "1");
        }
        if (data.type === 'piup-verify-expanded') {
            // Record first expansion only (subsequent toggles don't re-flag)
            if (data.expanded === true) {
                Qualtrics.SurveyEngine.setEmbeddedData("verify_expanded", "1");
            }
        }
    }

    window.addEventListener('message', onMessage);

    // Cleanup listener when participant leaves the question
    engine.addOnUnload(function() {
        window.removeEventListener('message', onMessage);
    });
});
```

> **Origin whitelist:** Replace `'https://aztec-study2.vercel.app'` with your actual Vercel domain. This prevents other frames or pages from injecting false behavioral signals.

### 5c. Transition screen

Add a second **Text / Graphic** question in the Stimulus block (on a new page):

```
The interface is now hidden. Please answer the following questions from memory.

Take your time.
```

Add a **Page Break** before this question (question options → Add Page Break).

---

## Step 6 — Calibration Block (I2 conditions only)

This block appears in Survey Flow only for I2 participants (inside the Branch at §2d). It presents two comprehension questions *before* the receipt, then shows immediate feedback.

### CAL1 — Pre-receipt comprehension probe 1 (screenshot coercion)

- Question type: **Multiple Choice** (single select, vertical)
- Text: `If someone asked you to send them a screenshot of your voting receipt to prove how you voted, could they learn your vote choice from the screenshot?`
- Choices:
  - `Yes, they could see my vote` → scored 0 (incorrect)
  - `No, the receipt doesn't include my vote` → scored 1 (correct)
  - `I'm not sure` → scored 0
- Variable name: `CAL1`
- **Randomise choices**: no (binary + I'm not sure — fixed order avoids confusion).
- **Correct answer:** `No, the receipt doesn't include my vote`. Do not expose correct answer in the question text.

### CAL2 — Pre-receipt comprehension probe 2 (purpose of the identifier)

- Question type: **Multiple Choice** (single select, vertical)
- Text: `What is the main purpose of the ${e://Field/condition_label} on the receipt?`
- Choices:
  - `To prove that you voted in this election` → 0
  - `To confirm which voting option you chose` → 0
  - `To let you verify later that your ballot was counted` → 1 (correct)
  - `To identify you to the election organizer` → 0
- Variable name: `CAL2`
- **Randomise choices** (question options → Randomize Choices): yes — reduces order bias.
- **Correct answer:** `To let you verify later that your ballot was counted`. Do not expose correct answer.

**Page break after CAL2.**

### CAL-FEEDBACK — Feedback screen

- Question type: **Text / Graphic** (Descriptive Text, no response)
- Paste:

```
Your answers:

Question 1: The correct answer is No — the receipt does not include your vote choice. This is intentional: showing your vote would create a risk of coercion.

Question 2: The correct answer is To let you verify later that your ballot was counted — the ${e://Field/condition_label} proves your ballot was included in the tally, not what you voted.

Now, please review the voting receipt on the next screen.
```

> **Why this wording:** This matches the calibration feedback described in design note §6.2. It corrects both over-claiming ("it proves my choice") and under-claiming ("it proves nothing"). It does not yet show the receipt.

**Page break after CAL-FEEDBACK.**

> **Note on scoring:** `CAL1` and `CAL2` feed into M4 (confidence miscalibration residual) in the analysis script. The analysis script computes `cal_pre_accuracy` as a binary correct/incorrect for each probe; `cal_confidence` is collected at Q-AC (see §8 below). The pre/post accuracy gap and confidence residual are computed in R, not Qualtrics.

---

## Step 7 — Attention Check 1 Block

Place this block in Survey Flow between the Stimulus block and the Comprehension block.

- Question type: **Multiple Choice** (single select)
- Text: `This is an attention check to make sure you are reading carefully. Please select "Strongly Disagree" as your response to this question, regardless of what it says.`
- Choices: `Strongly Agree` | `Agree` | `Neither Agree nor Disagree` | `Disagree` | **`Strongly Disagree`** (correct)
- Variable name: `attention_check_1`
- No skip logic — record all responses; exclusion applied in R per pre-registration.

---

## Step 8 — Comprehension Block

Questions in fixed order (no question randomisation). Each question is on its own page. All piped-text uses `${e://Field/condition_label}`.

### Q-AC — Absent-content accuracy (M1, primary endpoint)

**Page 1:**
- Question type: **Multiple Choice** (single select)
- Text: `Looking at that receipt: does it show which voting option you chose?`
- Choices: `Yes, my vote choice is shown` | `No, my vote choice is not shown` | `It's not clear from what I see`
- Variable name: `qac_correct`
- **Correct answer:** `No`. Coded 1 = correct, 0 = incorrect in the analysis script.

**Q-AC-conf (same page):**
- Question type: single-row **Matrix Table** or 7-point **Multiple Choice**.
- Text: `How confident are you in your answer above?`
- Scale: 1 (*Not at all confident*) to 7 (*Completely confident*).
- Variable name: `calibration_confidence`

> ⚠️ **JONY-ACTION FF (structural conflict): This guide places `calibration_confidence` as Q-AC-conf for ALL conditions ("How confident are you in your answer above?"). However, instrument §11 (M4) restricts calibration_confidence to I2 only and asks a DIFFERENT question: "Before you saw the receipt, we asked you two quick questions. Looking back at your answers: how confident were you that they were correct at the time?" (retrospective confidence in CAL probe answers). These measure different constructs: (a) guide = post-receipt Q-AC confidence, all conditions; (b) instrument = retrospective CAL-probe confidence, I2 only. Which version is pre-registered? Jony must confirm: option (a) guide version (all conditions, Q-AC confidence) or option (b) instrument version (I2 only, CAL-probe retrospective confidence). Guide left unchanged pending confirmation.** Design note §9.3 / H2.3: `calibration_confidence` is the primary M4 variable. The residual analysis is computed in R.

**Page break before next question.**

### M2-Trust — Trust-in-receipt composite (4 items, 7-point Likert)

**Page 2:**
- Page heading: `Please rate your level of agreement with each statement about the receipt you just saw.`
- Question type: **Matrix Table** (4 rows, 7 columns).
- Rows (variable names in parentheses — set via Export Tag):
  1. `trust_integrity_1` — "I believe this receipt accurately reflects what happened with my vote."
  2. `trust_integrity_2` — "I trust that the ${e://Field/condition_label} is unique to my ballot."
  3. `trust_competence_1` — "I feel confident I could use this receipt to prove my ballot was counted."
  4. `trust_competence_2` — "I understand what this receipt is for." ⚠️ **JONY-ACTION EE: guide previously had "I believe the voting system that produced this receipt is secure" — a different construct (security belief vs. comprehension). Instrument §9 specifies TC2 = "I understand what this receipt is for." Applied instrument wording but flagged for Jony confirmation.**
- Column labels: 1 (*Strongly Disagree*) through 7 (*Strongly Agree*).
- No "N/A" option.
- Variable name prefix: use **Export Tags** (question options → Export Tag) to force column names `trust_integrity_1`, `trust_integrity_2`, `trust_competence_1`, `trust_competence_2` in the CSV.
- Scale: Cronbach α ≥ 0.70 required; if not met, items reported individually (§9.2 design note).

**Page break.**

### M3 — Save intention (primary self-report + behavioral proxy already captured)

**Page 3:**
- Question type: **Multiple Choice** (single select)
- Text: `How likely are you to save or screenshot this receipt before closing this page?`
- Choices (with numeric export codes — 7-point likelihood scale):
  - `Definitely will` → 7
  - `Very likely` → 6
  - `Somewhat likely` → 5
  - `Neither likely nor unlikely` → 4
  - `Somewhat unlikely` → 3
  - `Very unlikely` → 2
  - `Definitely will not` → 1
- Variable name: `save_intention`

> **Scale note:** This is a 7-point present-tense likelihood scale (not the 5-point "Definitely would / Probably would" scale used in Study 1 BI1). Study 2 uses the finer-grained scale because M3 save_intention is a primary secondary endpoint (H2.4). Do NOT pipe `${e://Field/condition_label}` into this item — instrument §10 uses "this receipt" (label-neutral).

> **Behavioral proxy note:** `download_clicked` (M3 behavioral proxy) was already captured from the Stimulus block's postMessage listener. `save_intention` (M3 self-report) is the primary measure; `download_clicked` is secondary (§8.1 of design note).

**Page break.**

### Q-OE — Open-text absent-choice explanation (M6, supplementary)

**Page 4:**
- Question type: **Text Entry** (paragraph)
- Text: `In your own words, why doesn't this receipt show which voting option you chose?`
- Minimum characters: 20.
- Variable name: `qoe_rater1` (leave blank for rater 1 — this column is filled post-study by coders).

> **Implementation note:** The Qualtrics export column for this open-text response will be the participant's raw text. Rename the column in the export to `qoe_raw` (or update `COL_QOE_RATER1` in the analysis script). Raters score it 0–2 post-collection; scores are entered in separate spreadsheet columns and merged into the analysis CSV.

**Page break.**

---

## Step 9 — Attention Check 2 Block

- Question type: **Multiple Choice** (single select)
- Text: `Please select the third item from the list below.`
- Choices: `Apple` | `Banana` | **`Carrot`** | `Dog` | `Elephant`
- Variable name: `attention_check_2`
- No skip logic — exclusion in R.

---

## Step 10 — Demographics Block

### DM1 — Age range
- Question type: **Multiple Choice** (single select)
- Text: `What is your age?`
- Variable name: `age_group`
- Choices: `18–24` | `25–34` | `35–44` | `45–54` | `55–64` | `65 or older` | `Prefer not to say`

### DM2 — Technology background
- Variable name: `occupation_sw_eng`
- Text: `Have you ever written code professionally or as part of a degree?`
- Choices: `Yes — as my main job` | `Yes — occasionally / as part of a degree` | `No` | `Prefer not to say`

### DM3 — Prior receipt study
- Variable name: `prior_receipt_study`
- Text: `Have you participated in any online study involving voting interfaces in the past 12 months? (This is a follow-up to the screener question — please answer again.)`
- Choices: `Yes` | `No` | `Not sure`

> ⚠️ **JONY-ACTION GG (continued — wording conflicts in this question): (a) Time window: guide says "past 12 months" vs instrument §14 DM4 says "past 6 months". (b) Question text: guide says "voting interfaces" vs instrument says "voting receipts, voting confirmations, or post-vote screens". (c) The "(follow-up to screener question)" note is only valid if SC3 exists — if SC3 is removed per option (a) above, this note must also be removed and the phrasing revised. Confirm with GG resolution above.**

> **Why ask again:** The screener version (SC3) captures exclusion; this demographics version feeds `prior_receipt_study` into the analysis script's exclusion logic (§2 of analysis script).

### DM4 — Prior voting
- Variable name: `prior_voting`
- Text: `Which of the following have you participated in? (Select all that apply)` (multiple select)
- Choices:
  - `An online opinion poll or workplace survey`
  - `A national or local government election (online or paper)`
  - `A student body or organisational election (online or paper)`
  - `I have never voted in any election or poll` *(log as inconsistent with SC1 pass; do not auto-exclude — apply sensitivity check in analysis)*
  - `Prefer not to say`

### DM5 — Technology efficacy
- Variable name: `tech_efficacy_mean`
- Question type: **Matrix Table** (3 rows, 7 columns)
- Rows:
  1. "I am confident in my ability to use technology to complete tasks."
  2. "I understand how most digital services I use actually work."
  3. "I am comfortable evaluating whether a digital system is trustworthy."
- Scale: 1 (*Strongly Disagree*) to 7 (*Strongly Agree*).
- The analysis script computes the row mean as `tech_efficacy_mean`.

---

## Step 11 — Debrief Block

- Question type: **Text / Graphic** (Descriptive Text, no response).

```
Thank you for your participation.

This study examined how the design of a voting receipt affects people's understanding and trust. Specifically, we looked at how different label names ("vote fingerprint" vs. "confirmation code") and explanatory text affect whether people correctly understand that the receipt does not show their vote choice.

In real private voting systems, the identifier — whether called a "vote fingerprint," a "confirmation code," or something else — proves only that your vote was counted, not which option you chose. This is an intentional privacy-preserving feature.

The study is being conducted as part of research on the usability of privacy-preserving voting technology. If you have questions, please contact the research team via Prolific.

Compensation: You will receive your Prolific payment regardless of your answers. There are no correct or incorrect answers from a payment perspective.

Your completion code will appear on the next screen.
```

Add completion redirect in **Survey Options → Survey Termination**: redirect to `https://app.prolific.com/submissions/complete?cc=YOURCODE`.

---

## Step 12 — Prolific Configuration

### Survey URL (with Prolific piping)

```
https://[your-qualtrics-instance].qualtrics.com/jfe/form/SV_XXXX?PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

> **Condition assignment:** Handled entirely by the Qualtrics Randomizer (§2b). You do NOT need separate Prolific studies per condition. Run one Prolific study pointing at the single Qualtrics survey URL.

### Screen-out redirect

In Survey Options → Survey Termination → End of Survey → enable redirect URL → paste Prolific screen-out URL:  
`https://app.prolific.com/submissions/complete?cc=SCREENOUT`

Apply to all SC1/SC2/SC3 skip-to-end-of-survey paths.

### Over-quota redirect (for Quotas)

When a quota is met (see §2b), redirect to:  
`https://app.prolific.com/submissions/complete?cc=OVERQUOTA`

---

## Step 13 — Quotas (enforce n = 30 per cell)

In **Survey Options → Quotas**, create 8 quotas — one per condition:

| Quota name | Condition | Trigger | Quota count | Action when met |
|------------|-----------|---------|-------------|----------------|
| `cell_L1E1I1` | `condition` = `L1E1I1` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L1E1I2` | `condition` = `L1E1I2` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L1E2I1` | `condition` = `L1E2I1` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L1E2I2` | `condition` = `L1E2I2` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L2E1I1` | `condition` = `L2E1I1` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L2E1I2` | `condition` = `L2E1I2` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L2E2I1` | `condition` = `L2E2I1` | Survey completion | 30 | Redirect to over-quota URL |
| `cell_L2E2I2` | `condition` = `L2E2I2` | Survey completion | 30 | Redirect to over-quota URL |

> **Quota trigger on completion (not response):** Set trigger to "Survey complete" rather than "Response started" — this ensures Quotas count retained participants, matching the n = 30/cell target after exclusions are accounted for (add ~20–25% over-recruitment to each cell target; target 38–40 completions per cell before exclusions).

---

## Step 14 — Variable Name Checklist (analysis script alignment)

After building the survey, preview it end-to-end and download one test export. Verify the column names match `piup-study2-analysis.R`:

| Expected R column (`COL_*` constant) | Qualtrics export column |
|--------------------------------------|------------------------|
| `participant_id` | `PROLIFIC_PID` (Embedded Data) |
| `condition` | `condition` (Embedded Data) |
| `label` | `label_factor` (Embedded Data) |
| `explanation` | `explanation_factor` (Embedded Data) |
| `intervention` | `intervention_factor` (Embedded Data) |
| `qac_correct` | `qac_correct` |
| `trust_integrity_1` | `trust_integrity_1` (Matrix Export Tag) |
| `trust_integrity_2` | `trust_integrity_2` |
| `trust_competence_1` | `trust_competence_1` |
| `trust_competence_2` | `trust_competence_2` |
| `save_intention` | `save_intention` |
| `download_clicked` | `download_clicked` (Embedded Data) |
| `calibration_confidence` | `calibration_confidence` |
| `verify_expanded` | `verify_expanded` (Embedded Data) |
| `qoe_rater1` | *(rater score added post-collection)* |
| `qoe_rater2` | *(rater score added post-collection)* |
| `attention_check_1` | `attention_check_1` |
| `attention_check_2` | `attention_check_2` |
| `response_time_sec` | Add a **Timing** question in the Welcome block |
| `occupation_sw_eng` | `occupation_sw_eng` |
| `prior_receipt_study` | `prior_receipt_study` |
| `age_group` | `age_group` |
| `prior_voting` | `prior_voting` |
| `tech_efficacy_mean` | Computed by R from 3 Matrix rows |
| `browser_fallback` | `browser_fallback` (Embedded Data) |

> **Timing question:** Add a **Timing** question type in the Welcome block. Qualtrics records total survey duration. Export this column as `response_time_sec` or update the `COL_RT` constant in the analysis script to match Qualtrics's auto-generated name.

---

## Step 15 — Pre-launch Checklist

**Prototype host:**
- [ ] Vercel deployment live and publicly accessible.
- [ ] Test `?condition=L1E1I1` — vote fingerprint, explanation present, loads correctly.
- [ ] Test `?condition=L2E2I2` — confirmation code, no explanation, loads correctly.
- [ ] Confirm `piup-ready` fires on load (DevTools → Console → check `window.parent.postMessage`).
- [ ] Confirm `piup-download-click` fires when Download button is clicked.
- [ ] Confirm `piup-verify-expanded` fires when "How to verify" section is expanded.
- [ ] Static fallback images present at `/static/fallback-L1E1.png`, `L1E2.png`, `L2E1.png`, `L2E2.png`.

**Qualtrics survey:**
- [ ] Preview end-to-end as an I1 condition (skip Calibration block) — verify condition assigned, prototype loads, behavioral data captured in Embedded Data.
- [ ] Preview end-to-end as an I2 condition — verify Calibration block appears before Stimulus, feedback text correct.
- [ ] Simulate browser-fallback: block Vercel domain in DevTools → Network, preview Stimulus block — verify fallback image appears after 8 seconds, `browser_fallback = "1"` in Embedded Data.
- [ ] Test screen-out paths (fail SC1, SC2, SC3) — verify Prolific screen-out URL reached.
- [ ] Test over-quota: manually fill quota for one condition, verify redirect fires.
- [ ] Download one preview export — verify all 25 column names match the analysis script.
- [ ] Confirm Randomizer distributes evenly across 8 conditions after 24 test previews (should be approximately 3 per condition).

**Before launch:**
- [ ] OSF pre-registration lodged and locked.
- [ ] Prolific study set to N = ~304 (38 per cell × 8; ~20% over-recruitment buffer).
- [ ] Prolific screener includes: `custom screener: prior receipt study = No`.

---

## Step 16 — Pilot Run (N = 40 / ~5 per cell)

Run a pilot on N ≈ 40 before full launch. Set `PILOT <- TRUE` at top of `analysis/piup-study2-analysis.R`.

Pilot checks (§14.2 of design note):
1. **Column structure** — `piup-study2-drycheck.R` validates all 25 columns; run first.
2. **Condition balance** — Randomizer should distribute ±2 per cell at N = 40.
3. **Timing** — median `response_time_sec` target: 12–18 minutes.
4. **Attention check pass rate** — target > 80%.
5. **Q-AC floor/ceiling** — flag any cell > 90% or < 20% correct.
6. **Browser-fallback rate** — target < 5%; if > 10%, fix Vercel deployment before full launch.
7. **Cronbach α for M2** — with N = 40, expect low α; check directional consistency; recompute with full-N data.

Log any amendments in §15 of the design note before full launch.

---

## Quick Reference — Piped Text Cheat Sheet

| What you want | Qualtrics Piped Text syntax |
|--------------|----------------------------|
| Current label (vote fingerprint / confirmation code) | `${e://Field/condition_label}` |
| 8-level condition code | `${e://Field/condition}` |
| Label factor (L1/L2) | `${e://Field/label_factor}` |
| Explanation factor (E1/E2) | `${e://Field/explanation_factor}` |
| Intervention factor (I1/I2) | `${e://Field/intervention_factor}` |
| Prolific PID | `${e://Field/PROLIFIC_PID}` |
| Prototype URL for current condition | `https://aztec-study2.vercel.app?condition=${e://Field/condition}` |

---

## Appendix — Condition × Measure Matrix

| Condition | Label | Explanation | Intervention | Calibration block? | Prototype variant |
|-----------|-------|-------------|--------------|-------------------|------------------|
| L1E1I1 | vote fingerprint | Present | None | No | L1E1 |
| L1E1I2 | vote fingerprint | Present | Calibration | Yes | L1E1 |
| L1E2I1 | vote fingerprint | Absent | None | No | L1E2 |
| L1E2I2 | vote fingerprint | Absent | Calibration | Yes | L1E2 |
| L2E1I1 | confirmation code | Present | None | No | L2E1 |
| L2E1I2 | confirmation code | Present | Calibration | Yes | L2E1 |
| L2E2I1 | confirmation code | Absent | None | No | L2E2 |
| L2E2I2 | confirmation code | Absent | Calibration | Yes | L2E2 |

*Only 4 distinct prototype page variants needed (L × E); I factor handled in Qualtrics.*

---

*This guide implements the survey as specified in `piup-study2-design-note-2026-06-22.md`. Any deviations from this guide must be logged in §15 (Amendments) of the design note before the study launches.*
