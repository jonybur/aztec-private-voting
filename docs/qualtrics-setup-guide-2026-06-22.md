# Qualtrics Setup Guide — PIUP Study 1

**Author:** Jony Bursztyn  
**Date:** 2026-06-22  
**Instrument spec:** [`docs/piup-study1-survey-instrument-2026-06-22.md`](piup-study1-survey-instrument-2026-06-22.md)  
**Pre-registration:** [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md)

This is a click-by-click implementation guide for building the PIUP Study 1 survey in Qualtrics. Follow in order. Estimated setup time: 90–120 minutes.

---

## Prerequisites

Before starting:
- [ ] Study stimuli hosted at a public URL (e.g. `https://your-host.vercel.app/condition-A.html`). Run `npx vercel study-stimuli/ --prod` from the repo root.
- [ ] Prolific study created (or ready to create) — you will need the **Screen Out URL** and **Completion URL** from Prolific.
- [ ] Qualtrics account with a licence that allows JavaScript (most university + paid tiers).

---

## Step 1 — Create the Survey

1. Log in to Qualtrics → **Create new project** → **Survey**.
2. Name it: `PIUP Study 1 — Receipt Identifier Label Comprehension`.
3. Start with a **Blank survey project**.
4. You will see one default block called "Default Question Block." Rename it to `Screener` (click the block name to edit).

---

## Step 2 — Survey Flow (Critical — do this before adding questions)

Survey Flow controls condition assignment. Set it up before building blocks.

**Open:** Builder → **Survey Flow** (top menu bar).

### 2a. Embedded Data element (first element in flow)

1. Click **Add a New Element Here** → **Embedded Data**.
2. Add the following fields in order:

| Field name | Value |
|------------|-------|
| `condition` | *(leave blank — will be set from URL)* |
| `condition_label` | *(leave blank — will be set by Branch logic below)* |
| `PROLIFIC_PID` | *(leave blank — from URL)* |
| `STUDY_ID` | *(leave blank — from URL)* |
| `SESSION_ID` | *(leave blank — from URL)* |
| `stimulus_shown` | `0` (default) |
| `time_on_stimulus` | `0` (default) |

For each field: click **Add a New Field**, type the field name, leave value blank (except `stimulus_shown` and `time_on_stimulus`).

> **Why this order matters:** Embedded Data must come before all blocks so URL parameters are captured before the screener runs.

### 2b. Screener block reference

After the Embedded Data element, click **Add a New Element Here** → **Block** → select `Screener`.

### 2c. Branch logic — condition_label assignment

After the Screener block, click **Add a New Element Here** → **Branch**.

Set up four branches (one per condition):

**Branch 1:**
- Condition: `Embedded Data` | `condition` | `Equals` | `A`
- Action: **Set Embedded Data** → `condition_label` = `vote fingerprint`

**Branch 2:**
- Condition: `Embedded Data` | `condition` | `Equals` | `B`
- Action: **Set Embedded Data** → `condition_label` = `confirmation code`

**Branch 3:**
- Condition: `Embedded Data` | `condition` | `Equals` | `C`
- Action: **Set Embedded Data** → `condition_label` = `nullifier`

**Branch 4:**
- Condition: `Embedded Data` | `condition` | `Equals` | `D`
- Action: **Set Embedded Data** → `condition_label` = `receipt ID`

> To add actions inside a Branch: click the Branch element, click **Add a New Element Here** (inside the branch), select **Embedded Data**, add the field-value pair.

### 2d. Remaining blocks

After the four branches, add the remaining blocks in this order:
1. Welcome
2. Stimulus
3. Attention Check 1
4. Comprehension
5. Secondary Items
6. Attention Check 2
7. Demographics
8. Debrief

Create placeholder empty blocks for each now; you will add questions in subsequent steps. Click **Add a New Element Here** → **Block** → **Create New Block** for each.

Click **Save Flow**.

---

## Step 3 — Screener Block

Go back to **Builder** tab. Navigate to the Screener block.

### SC1 — Voting experience

- Question type: **Multiple Choice** (single select, vertical)
- Question text: `Have you voted in an online election, poll, or survey in the past 12 months? (This includes workplace polls, student-body elections, and any official online ballots.)`
- Choices:
  - `Yes`
  - `No`
- Add **Skip Logic** on `No`: Skip to **End of Survey** (Qualtrics calls this "End of Survey / Screen Out").
  - Click the question → **Add Skip Logic** → If `No` is selected → `Skip to` → `End of Survey`.
  - In **Survey Options → Survey Termination**, set Terminate Survey URL to your Prolific screen-out URL.

### SC2 — Occupation exclusion

- Question type: **Multiple Choice** (single select, vertical)
- Question text: `What best describes your main occupation or field of study?`
- Choices (in order):
  1. `Software engineer, developer, or programmer`
  2. `Other technology professional (e.g. IT support, data analyst, product manager)`
  3. `Healthcare, education, law, finance, or public service`
  4. `Skilled trades or manufacturing`
  5. `Retail, hospitality, or service industry`
  6. `Student (not in computer science or software engineering)`
  7. `Student in computer science or software engineering`
  8. `Other`
  9. `Prefer not to say`
- Add **Skip Logic** for choices 1 and 7 (screen out):
  - If choice 1 selected → Skip to End of Survey.
  - If choice 7 selected → Skip to End of Survey.

---

## Step 4 — Welcome Block

- Add one **Text / Graphic** question (no response required; set question type to Descriptive Text).
- Paste exactly:

```
Welcome. Estimated time: 8–12 minutes.

You are helping researchers evaluate a prototype voting interface. You will be shown a screen that appears immediately after you submit a vote. Please read it carefully — you will be asked questions about it afterward.

• The interface is a prototype only — there is no real election and no real votes are being collected.
• You are not required to cast any vote or enter any personal information.
• You will be asked questions about what the screen shows and what it means.

Please do not use external resources (e.g., Google or Wikipedia) to answer the questions. We are interested in your natural understanding of the interface, not in researched definitions.
```

---

## Step 5 — Stimulus Block

### Stimulus display question

- Question type: **Text / Graphic** (Descriptive Text, no response required).
- Paste in the Rich Content Editor (click `<>` HTML button):

```html
<iframe 
  src="https://YOUR_STATIC_HOST/condition-${e://Field/condition}.html"
  width="100%"
  height="700px"
  style="border:none; border-radius:8px;">
</iframe>
<p style="font-size:0.85em; color:#666; margin-top:8px;">
  Prototype interface — read carefully before continuing.
</p>
```

Replace `YOUR_STATIC_HOST` with your actual Vercel/Netlify host.

> **Alternative (if iframe is blocked by your Qualtrics plan):** Use a **Text / Graphic** block with a hyperlink: `<a href="https://YOUR_STATIC_HOST/condition-${e://Field/condition}.html" target="_blank">Open the prototype screen in a new tab</a>`. Then add the 90-second timer text telling participants to return after viewing.

- **Add JavaScript** (click the question → **Add JavaScript**). Replace all default code with:

```javascript
Qualtrics.SurveyEngine.addOnload(function() {
    var btn = this.getNextButton();
    btn.disabled = true;
    btn.innerHTML = "Please review the screen (1:30 remaining)";
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
            btn.innerHTML = "Please review the screen (" + m + ":" + (s < 10 ? "0" : "") + s + " remaining)";
        }
    }, 1000);
    
    // Record time on stimulus
    var start = Date.now();
    this.questionclick = function() {};
    var orig = btn.onclick;
    btn.onclick = function() {
        var elapsed = Math.round((Date.now() - start) / 1000);
        Qualtrics.SurveyEngine.setEmbeddedData("time_on_stimulus", elapsed);
        if (orig) orig.call(this);
    };
});
```

### Transition screen

Add a second **Text / Graphic** question in the same block (or in a new page):

```
The interface screen is now hidden. Please answer the following questions from memory.

Take your time. There are no trick questions.
```

Set this question on a **new page**: click the question options (three dots) → **Add Page Break** before this question.

---

## Step 6 — Attention Check 1 Block

> Place this block between Stimulus and Comprehension in Survey Flow.

- Question type: **Multiple Choice** (single select)
- Question text: `This is an attention check to make sure you are reading carefully. Please select "Strongly Disagree" as your response to this question, regardless of what it says.`
- Choices:
  - `Strongly Agree`
  - `Agree`
  - `Neither Agree nor Disagree`
  - `Disagree`
  - **`Strongly Disagree`** ← correct answer
- **Do NOT add skip logic here** — record all responses and apply exclusion in R per the pre-registration. Variable name in export: `AC1`.

---

## Step 7 — Comprehension Block (Q1–Q5)

**Important:** Q1–Q4 are in **fixed order, not randomised**. In Qualtrics → Block options → ensure **Question Randomization is OFF**.

Each of Q1–Q4 is on its own page with the confidence item on the same page.

### Q1 — Vote-counted inference

**Page 1:**
- Question type: **Multiple Choice** (single select)
- Question text: `After voting, the system showed you your ${e://Field/condition_label}. Does having this ${e://Field/condition_label} prove that your vote was counted?`
- Choices: `Yes` | `No` | `I'm not sure`
- Variable name (Qualtrics field export name): set to `Q1` in Question Behavior → Custom variable name.

**Q1-confidence (same page):**
- Question type: **Multiple Choice** (single select) or use a **Slider** question.
- Recommended: Single-row **Matrix** question (see below).
- Question text: `How confident are you in your answer above?`
- Scale: 7-point, labelled `1 — Not at all confident` to `7 — Completely confident`.
- Variable name: `Q1_conf`.

> **Qualtrics tip for 7-point Likert:** Use a **Matrix Table** question type with a single row ("Confidence") and 7 columns. Or use a plain **Multiple Choice** with forced single-choice and choices `1` through `7` with scale labels.

**Add a page break after Q1-confidence** before Q2.

### Q2 — Representational schema (Primary H2 endpoint)

**Page 2:**
- Question type: **Multiple Choice** (single select)
- Question text: `The ${e://Field/condition_label} is a string of numbers and letters that is unique to your vote. Does having this ${e://Field/condition_label} prove which voting option you chose?`
- Choices: `Yes` | `No` | `I'm not sure`
- Variable name: `Q2`

**Q2-confidence (same page):**
- Same format as Q1-confidence.
- Variable name: `Q2_conf`

**Page break before Q3.**

### Q3 — Privacy mental model

**Page 3:**
- Question type: **Multiple Choice** (single select)
- Question text: `Imagine your employer tells you they want to verify how you voted, and asks you to show them this screen as proof. If you showed a third party your screen and your ${e://Field/condition_label}, could they tell which voting option you chose?`
- Sub-text (smaller text beneath, use Rich Text → smaller font): `This is a hypothetical scenario to test your understanding of what the screen reveals. It does not reflect a real situation.`
- Choices: `Yes` | `No` | `I'm not sure`
- Variable name: `Q3`

**Q3-confidence (same page):**
- Variable name: `Q3_conf`

**Page break before Q4.**

### Q4 — Receipt utility

**Page 4:**
- Question type: **Multiple Choice** (single select)
- Question text: `If you closed this screen without saving your ${e://Field/condition_label}, what would happen?`
- Choices (label carefully — one choice per line):
  - `(a) My vote would be cancelled or reversed`
  - `(b) I could still verify that my vote was counted, but I would not have this ${e://Field/condition_label} as personal proof`
  - `(c) The voting system keeps a copy of my ${e://Field/condition_label}, so I could always retrieve it later`
  - `(d) Nothing — my vote does not depend on having this ${e://Field/condition_label}`
- Variable name: `Q4`

> **Randomise Q4 answer choices** (choice randomisation within this question only, not question order) — reduces position bias on this multi-option question. Enable in question options → **Randomize Choices**. This is safe — Q4 is not part of the composite accuracy score ordering.

**Q4-confidence (same page):**
- Variable name: `Q4_conf`

**Page break before Q5.**

### Q5 — Open-ended mechanism

**Page 5 (its own page):**
- Question type: **Text Entry** (long form)
- Question text: `In your own words: why might this voting system choose NOT to show you which option you voted for on this screen?`
- Set **Minimum characters**: 20.
- Variable name: `Q5_text`

---

## Step 8 — Secondary Items Block

### MQ1 — Mental model quality

- Question type: **Text Entry** (long form)
- Question text: `In your own words: what does your ${e://Field/condition_label} prove about your vote? What does it NOT prove?`
- Minimum characters: 20
- Variable name: `MQ1_text`

**Page break.**

### BI1 — Behavioral intent

- Question type: **Multiple Choice** (single select)
- Question text: `If this was a real election and you saw this screen after submitting your vote, how likely would you be to save your ${e://Field/condition_label} for future reference?`
- Choices (ordered high to low):
  - `Definitely would save it` → code 5
  - `Probably would save it` → code 4
  - `Might or might not` → code 3
  - `Probably would not save it` → code 2
  - `Definitely would not save it` → code 1
- Variable name: `BI1`

**Page break.**

### LA1 — Label affect slider

- Question type: **Slider** (or Constant Sum with one item)
- Question text: `What is your first impression of the term "${e://Field/condition_label}" as a name for this identifier?`
- Scale: −3 to +3 (in Qualtrics: set **Min value** = −3, **Max value** = 3, **Starting value** = 0).
- Display labels: tick marks at −3 (*Very negative*), 0 (*Neutral*), +3 (*Very positive*).

> **Qualtrics note:** Native sliders default to 0–100. To get −3 to +3: use a **Text Entry** (numeric) question type with validation set to allow only integers from −3 to +3, if your Qualtrics licence doesn't support Slider min/max override. Or use a 7-point Multiple Choice with values −3/−2/−1/0/+1/+2/+3.

- Variable name: `LA1`

---

## Step 9 — Attention Check 2 Block

- Question type: **Multiple Choice** (single select)
- Question text: `Please select the third item from the list below.`
- Choices:
  1. `Apple`
  2. `Banana`
  3. **`Carrot`** ← correct answer
  4. `Dog`
  5. `Elephant`
- Variable name: `AC2`
- **No skip logic** — record all responses; exclusion is applied in R.

---

## Step 10 — Demographics Block

### DM1 — Age range
- Question type: **Multiple Choice** (single select)
- Question text: `What is your age?`
- Choices: `18–24` | `25–34` | `35–44` | `45–54` | `55–64` | `65 or older` | `Prefer not to say`
- Variable name: `DM1_age`

### DM2 — Technology background
- Question type: **Multiple Choice** (single select)
- Question text: `Have you ever written code professionally or as part of a degree?`
- Choices:
  - `Yes — as my main job`
  - `Yes — occasionally / as part of a degree`
  - `No`
  - `Prefer not to say`
- Variable name: `DM2_code`

### DM3 — Prior voting experience
- Question type: **Multiple Choice** (multiple select)
- Question text: `Which of the following have you participated in? (Select all that apply)`
- Choices:
  - `An online opinion poll or workplace survey`
  - `A national or local government election (online or paper)`
  - `A student body or organisational election (online or paper)`
  - `I have never voted in any election or poll`
  - `Prefer not to say`
- Variable name: `DM3_voting`

---

## Step 11 — Debrief Block

- Question type: **Text / Graphic** (Descriptive Text, no response)
- Paste exactly:

```
Thank you for your participation.

This study examined how different labels for a voting identifier affect people's understanding of what it proves. In real private voting systems, the identifier — whether it is called a "vote fingerprint," a "confirmation code," or something else — proves only that your vote was counted, not which option you chose.

The study is being conducted as part of research on the usability of privacy-preserving voting technology. If you have questions about the study, please contact the research team via Prolific.

Compensation: You will receive your Prolific payment regardless of your answers. There are no correct or incorrect answers from a payment perspective.
```

- Add a second question (Text / Graphic) for the completion code:

```
Your completion code is: [PROLIFIC_COMPLETION_CODE_HERE]
```

(Alternatively: configure the **End of Survey** redirect in Survey Options → Survey Termination to redirect to `https://app.prolific.com/submissions/complete?cc=YOURCODE` — this is cleaner than showing the code on-screen.)

---

## Step 12 — Prolific Configuration

### Survey URL

In Prolific → Your study → Share link, the base URL is:

```
https://[your-qualtrics-survey].qualtrics.com/jfe/form/SV_XXXX
```

In Prolific URL parameters section, add:

| Parameter name | Value |
|----------------|-------|
| `condition` | `{{%CONDITION%}}` ← **not available natively; see below** |
| `PROLIFIC_PID` | `{{%PROLIFIC_PID%}}` |
| `STUDY_ID` | `{{%STUDY_ID%}}` |
| `SESSION_ID` | `{{%SESSION_ID%}}` |

> **Condition assignment via Prolific URL parameters:** Prolific does not natively support custom URL parameter variables per participant. Two options:
>
> **Option A (recommended):** Create **four separate Prolific studies** (one per condition). Each study has a different survey URL with `?condition=A`, `?condition=B`, etc. hard-coded. Run them simultaneously; set target n=70 per study.
>
> **Option B:** Use **Qualtrics Randomizer** instead of URL parameter assignment. In Survey Flow, replace the Branch logic above with a **Randomizer** element (Even Distribution across 4 branches, each setting `condition` and `condition_label` via Embedded Data). Use Qualtrics **Quotas** (see Step 13) to enforce n=70 per condition.
>
> Option A is simpler to audit. Use it unless your Prolific account type doesn't allow multiple simultaneous studies.

### Screen-out redirect

In **Survey Options → Survey Termination** (End of Survey section):  
Enable "Redirect to a URL" → paste your Prolific screen-out URL:  
`https://app.prolific.com/submissions/complete?cc=SCREENOUT`

Apply this to the SC1 and SC2 skip-to-end-of-survey paths only (not to the actual survey completion).

---

## Step 13 — Quotas (Option B / Randomizer only)

If using the Qualtrics Randomizer instead of four separate Prolific studies:

1. Go to **Survey Options** → **Quotas**.
2. Create four quotas:
   - `condition_A`: When Embedded Data `condition` = `A` → Quota 50 → **Close survey** when quota met.
   - `condition_B`: Same for B, C, D.
3. When a quota is met, redirect participant to Prolific's over-quota URL: `https://app.prolific.com/submissions/complete?cc=OVERQUOTA`.

---

## Step 14 — Question Variable Names (Export Prep)

Qualtrics auto-names questions `Q1`, `Q2`, etc. — but these may not match the `COL_*` constants in `analysis/piup-study1-analysis.R`.

After building all questions, export one row of test data (use the **Preview Survey** link, complete the survey as a test, then download data). Check that the column names match:

| Expected R column (COL_*) | Qualtrics export column (typical) |
|--------------------------|-----------------------------------|
| `condition` | `condition` (Embedded Data) |
| `condition_label` | `condition_label` (Embedded Data) |
| `Q1` | `Q1` or `QID1` |
| `Q1_conf` | `Q2` or `QID2` ← note: Qualtrics auto-numbers sequentially |
| `Q2` | `QID3` |
| `Q2_conf` | `QID4` |
| … | … |
| `AC1` | whichever QID it was assigned |
| `AC2` | whichever QID it was assigned |
| `time_on_stimulus` | `time_on_stimulus` (Embedded Data) |
| `total_time_seconds` | Add a **Timing** question to your survey for this |

After the test export, update the `COL_*` constants at the top of `analysis/piup-study1-analysis.R` to match the actual Qualtrics export column names.

> **Add a Timing question:** In the Welcome block (or as a separate hidden question), add a **Timing** question type. Qualtrics records total survey duration automatically. This produces `total_time_seconds` in the export.

---

## Step 15 — Pre-launch Checklist

- [ ] Preview survey end-to-end as Condition A. Verify condition_label = "vote fingerprint" everywhere.
- [ ] Repeat preview for Conditions B, C, D.
- [ ] Confirm 90-second timer fires and the Continue button enables correctly.
- [ ] Confirm stimulus iframe / link opens correctly in the preview.
- [ ] Test screen-out paths: fail SC1, fail SC2 — verify Prolific screen-out URL is hit.
- [ ] Test attention checks: fail AC1, fail AC2, fail both — confirm responses are recorded (not auto-excluded in Qualtrics).
- [ ] Download one pilot preview export. Confirm all column names match the R script COL_* constants (or update the R script).
- [ ] Confirm Prolific completion redirect URL works (check the `cc=` code matches your Prolific study).
- [ ] Confirm study stimuli are publicly accessible (open `condition-A.html` on a mobile device).
- [ ] If using four separate Prolific studies: confirm quota is set to n=70 per condition.

---

## Step 16 — Pilot Run (N=40)

Before full launch (N=280), run a pilot on N=40 (10 per condition). Use `PILOT=TRUE` in the R script:

```r
source("analysis/piup-study1-analysis.R")
# Set PILOT <- TRUE at top of script
```

The pilot run checks:
- Floor/ceiling effects per question
- Timing: median total_time_seconds (target 8–12 min)
- Attention check pass rate (target >85%)
- IRR: κ ≥ 0.70 for Q5 and MQ1 (rater instructions in instrument §11)

If κ < 0.70 on pilot: revise the rubric, log the amendment in `docs/piup-study1-survey-instrument-2026-06-22.md §14`, and log in the OSF pre-registration amendments table before full launch.

---

## Quick Reference — Piped Text Cheat Sheet

| What you want | Qualtrics Piped Text syntax |
|--------------|----------------------------|
| Show the label for current condition | `${e://Field/condition_label}` |
| Show the condition letter | `${e://Field/condition}` |
| Show Prolific PID | `${e://Field/PROLIFIC_PID}` |
| Embed the stimulus | `https://YOUR_HOST/condition-${e://Field/condition}.html` |

---

*This guide implements the survey exactly as specified in the pre-registered instrument. Do not change question wording after OSF upload without logging an amendment in both documents.*
