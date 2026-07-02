# Prolific Study Setup Guide — PIUP Study 1

**Author:** Jony Bursztyn  
**Date:** 2026-06-30 (updated 2026-07-02, tick-4451 — Amendment 19+19b prerequisites added)  
**Instrument spec:** [`docs/piup-study1-survey-instrument-2026-06-22.md`](piup-study1-survey-instrument-2026-06-22.md)  
**Pre-registration:** [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md)  
**Qualtrics setup:** [`docs/qualtrics-setup-guide-2026-06-22.md`](qualtrics-setup-guide-2026-06-22.md)

---

## ⛔ Prerequisites — MUST complete before creating any Prolific study

- [ ] **JONY-ACTION O:** File OSF Amendment 5 (SC2 extended to CS/SE students). OSF pre-registration must be live before any data collection.
- [ ] **JONY-ACTION T:** File OSF Amendment 14 (correct attention check descriptions in pre-reg §3). OSF pre-registration must be live before any data collection.
- [ ] **JONY-ACTION (Amendment 19):** File OSF Amendment 19 — Q3 wording deviations × 4 (+ Q4 note). Draft text in `docs/piup-study1-crosscheck-2026-07-01.md` Gap 1. Must be filed before any data collection.
- [ ] **JONY-ACTION (Amendment 19b):** File OSF Amendment 19b — stimuli scope-limiting clarification added (Decision D Option A). Draft text in `docs/piup-study1-decision-d-amendment-19b-draft-2026-07-02.md`. Stimuli HTML files updated in commit 5ac9bd6 — confirm this matches what you deploy at the public URL.
- [ ] Qualtrics survey fully built and tested (all 4 conditions working; screener, screen-out paths, completion redirect confirmed). Follow `qualtrics-setup-guide-2026-06-22.md` first.
- [ ] Stimulus files deployed at a public URL (e.g. `https://your-host.vercel.app/condition-A.html`). **Note:** stimuli now include the scope-limiting study note per Amendment 19b Option A — deploy from `study-stimuli/` in the current repo state (post-commit 5ac9bd6).
- [ ] Prolific account with a funded balance. For the pilot (N=40): budget ≈ £80–100 (see §Payment below). For full study (N=280): budget ≈ £560–700.

---

## Overview — 4 Separate Prolific Studies

You will create **four separate Prolific studies** (one per condition: A, B, C, D). This is the recommended approach (Option A from the Qualtrics setup guide) because:

- Each condition fills its quota independently — no within-Qualtrics randomization needed.
- You can pause, close, or monitor each condition separately.
- Clean audit trail: each Prolific study maps to exactly one condition.

Run all four simultaneously. Each study has a different survey URL (the only difference is `condition=A`, `B`, `C`, or `D` in the query string).

**Pilot configuration:** n = 10 per condition (total N = 40). Launch all 4 studies simultaneously; close each when its 10-participant quota is met.

**Full study configuration:** n = 70 per condition (total N = 280). Launch after pilot instrument validation is confirmed. If the pilot Q2 effect size is substantially smaller than 15 pp, expand to n = 75/cell (N = 300) per §4.2 of the pre-registration.

---

## Step 1 — Create the First Study (Condition A)

1. Log in to **Prolific** → click **New Study**.
2. Select **Survey** as the study type.
3. Fill in the study details (see §Study Details below).
4. After creating Study A, **duplicate it** three times and change only the condition letter in the URL (see Step 7).

---

## Study Details

### Study name (internal — only you see this)

```
PIUP Study 1 — Condition A (vote fingerprint)
PIUP Study 1 — Condition B (confirmation code)
PIUP Study 1 — Condition C (nullifier)
PIUP Study 1 — Condition D (receipt ID)
```

> Keep condition labels in the internal name so you can distinguish studies at a glance on the Prolific dashboard.

---

### Study title (external — participants see this on the Prolific browse page)

```
Short Study: How You Understand a Website Interface (8–12 min)
```

> Do **not** mention voting, receipts, cryptography, or privacy in the title. These words would prime participants and invalidate the comprehension measures.

---

### Study description (participants see this)

Copy this text exactly:

```
In this short study, you will view a screenshot of a prototype website screen and answer 
questions about how you understand what is shown. No technical knowledge is required.

The study takes approximately 8–12 minutes and involves reading a screen and answering 
multiple-choice questions. There are no right or wrong answers — we are interested in 
your genuine first impressions.
```

> Do **not** mention voting, elections, ballot receipts, verification, or cryptography. The cover story ("prototype voting interface") is introduced inside the survey, after the SC1/SC2 screener, to avoid selection bias.

---

### Study category

Select: **Academic research**

---

### Study type

Select: **Survey** (link to external survey)

---

## Step 2 — Payment

### Estimated completion time

Set: **12 minutes** (conservative end of the 8–12 min instrument range; the 8-min floor accounts for fast readers who don't linger on the stimulus, but Prolific bases reward on your stated estimate).

> **Why 12 min, not 8?** Participants who complete in 8 min are not penalised; the 12-min estimate protects slower/more careful readers and avoids a Prolific "fast completion" flag that can trigger quality reviews.

### Reward

Set: **£2.00 per participant** (recommended)

This gives an implied hourly rate of £10.00/hour — above Prolific's minimum (£9.00/hour as of 2026) and appropriate for a study at this level of cognitive engagement. Avoid going below £1.80 (implied rate < £9/hr); Prolific may flag it and participants may decline.

> **Higher-quality option:** £2.50/participant (implied £12.50/hr) → faster recruitment, likely better response quality. Budget impact: +£100 for full N=280.

### Pilot budget

- n=40 × £2.00 = **£80** reward + Prolific fee (~33% = £26.40) = **~£106 total**
- n=40 × £2.50 = £100 + £33 = **~£133 total**

### Full study budget

- n=280 × £2.00 = **£560** + Prolific fee = **~£745 total**
- n=280 × £2.50 = £700 + £933 fee = **~£931 total**

---

## Step 3 — Eligibility Filters (Prolific built-in)

> ⚠️ **PRE-REGISTRATION DISCREPANCY — READ BEFORE SETTING FILTERS**
>
> The OSF pre-registration (§2, Participants) specifies: **"US-resident adults, age 18+"**
> The CHI paper §4.2 states the same: **"US-resident adults (18+)"**
>
> This guide's original country filter (UK + US + Canada + Australia) and age cap (18–65) **deviate from the pre-registration**. Using them without an OSF amendment would be an unregistered deviation — a CHI reviewer could flag this.
>
> **You have two compliant options before data collection:**
> - **Option A (no amendment needed):** Set country = **United States only**, age = **18 or older** (no upper bound). Matches pre-reg exactly.
> - **Option B (file amendment first):** File an OSF amendment updating §2 Participants to allow UK + US + Canada + Australia and removing the age upper bound. Then set filters as originally listed below. Amendment must be live **before any data collection**.
>
> Recommendation: Option A is lower-friction. The US Prolific pool is large enough for N=280 at £2/participant. Only choose Option B if you have a specific reason to want UK/CA/AU participants (e.g. DAO governance participant demographics).

Set the following filters on the **Participant eligibility** page:

| Filter | Pre-reg compliant setting (Option A) | Original guide setting (Option B — requires amendment) | Rationale |
|--------|--------------------------------------|-------------------------------------------------------|-----------|
| **Fluent languages** | English | English | Pre-registration inclusion criterion: "English-speaking" |
| **Country of residence** | **United States only** | United Kingdom, United States, Canada, Australia | Pre-reg specifies US-resident; multi-country requires amendment |
| **Age** | **18 or older (no upper bound)** | 18–65 | Pre-reg specifies 18+; no upper bound |

**Use Option A unless you have filed an OSF amendment.**

> **Do NOT set a CS/SE employment filter.** The SC2 screener inside Qualtrics handles the software engineering exclusion with more precision than Prolific's sector categories. Using Prolific's "IT sector" filter would over-exclude (e.g. product managers, data analysts who are eligible). Let SC2 handle it.

> **Do NOT set a "voting experience" filter.** SC1 (in-survey) handles this. There is no Prolific built-in filter for "voted in online election/poll in past 12 months."

> **No previous participation filter needed.** Prolific's deduplication system automatically prevents participants from taking the same study twice. Since you are running 4 separate studies, check the box "Prevent participants who have already taken part in one of your studies from taking part in this one" — see Step 8.

---

## Step 4 — Places (Quota)

**Pilot:** Set each study to **n = 10 places**. You will need approval/confirmation from Prolific if running multiple simultaneous studies (most accounts allow 2–5; contact support if needed).

**Full study:** Set each study to **n = 70 places**.

> Prolific will auto-close the study when the quota is met. Do not exceed the quota — participants who complete after quota are paid but their data is not pre-registered.

---

## Step 5 — Collect the Completion Code and Screen-Out Code

When you create the study, Prolific generates a **completion code** (also called a "success code"). You also need to create a **screen-out code** and a **no-consent code**.

1. After creating the study, go to **Study settings → Completion**.
2. Copy the **completion URL**. It looks like:
   ```
   https://app.prolific.com/submissions/complete?cc=XXXXXXXX
   ```
3. Create a screen-out redirect. Prolific provides a separate screen-out URL:
   ```
   https://app.prolific.com/submissions/complete?cc=SCREENOUT_CODE
   ```
4. Note both URLs for each of the 4 studies. You will need to put them into Qualtrics (see `qualtrics-setup-guide-2026-06-22.md` Step 11 and Step 12).

> **Completion codes differ per study.** Study A and Study B have different completion codes. When you duplicate studies (Step 8), Prolific generates new codes automatically.

---

## Step 6 — Compose the Survey Link

For each condition, the Qualtrics survey link must include the condition parameter and Prolific URL variables. Construct the link as follows:

**Template:**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=[LETTER]&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Study A (vote fingerprint):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=A&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Study B (confirmation code):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=B&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Study C (nullifier):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=C&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

**Study D (receipt ID):**
```
https://[YOUR_QUALTRICS_SURVEY_URL]?condition=D&PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

> Replace `[YOUR_QUALTRICS_SURVEY_URL]` with the actual Qualtrics **anonymous survey link** (not the preview link). In Qualtrics: **Distributions → Anonymous Link**. The base URL looks like `https://[organisation].qualtrics.com/jfe/form/SV_XXXXXXXXXX`.

> **`{{%PROLIFIC_PID%}}`** is Prolific's template variable for the participant's Prolific ID. It is replaced automatically by Prolific when the participant clicks through. Do not change this syntax.

---

## Step 7 — Enter the Survey Link in Prolific

On the **Study → Survey link** page:

1. Paste the complete URL (with condition letter and Prolific variables) into the survey URL field.
2. Prolific will show a preview of the URL with a test PID substituted. Verify the URL looks correct.
3. Prolific will warn you if `{{%PROLIFIC_PID%}}` is not found in the URL. If you see this warning, check the URL syntax.

---

## Step 8 — Create Studies B, C, D (Duplicate Study A)

1. On the Prolific dashboard, open Study A.
2. Click **Duplicate study**.
3. Change only:
   - Internal name (e.g. "Condition B (confirmation code)")
   - Survey URL — change `condition=A` to `condition=B`
   - Places to n=10 (pilot) or n=70 (full)
4. Repeat for conditions C and D.

> **Do not** reuse Study A's completion code or screen-out code. Each duplicated study gets new codes; update Qualtrics accordingly if you are using condition-specific surveys. If you are using a single Qualtrics survey that redirects to a completion URL via embedded data, see the Qualtrics guide §Step 12 for the approach using a single shared screen-out URL.

---

## Step 9 — Cross-study deduplication

For each study:

1. Go to **Study → Eligibility → Additional filters**.
2. Enable **"Exclude participants who have taken part in any of my other studies"** and select all PIUP Study 1 studies (A, B, C, D) from the list.

This ensures no participant can take more than one condition. This is critical — double-participation would contaminate the between-subjects design.

> Prolific enforces this check at participant selection time, not just at completion. A participant who is in-progress on Study A cannot start Study B.

---

## Step 10 — Pre-launch Checklist

### Qualtrics (complete first — from `qualtrics-setup-guide-2026-06-22.md`)

- [ ] Survey flow: Embedded Data → Screener → Branch (condition assignment) → Main survey → End
- [ ] SC1 and SC2 screeners route to Prolific screen-out URL on fail
- [ ] Each condition iframe/link tested in preview mode (conditions A, B, C, D)
- [ ] Attention checks AC1 and AC2 present and correct
- [ ] Completion redirect at end of survey goes to Prolific completion URL
- [ ] PROLIFIC_PID, STUDY_ID, SESSION_ID captured via embedded data
- [ ] piup-study1-drycheck.R PASS on synthetic data

### Prolific (from this guide)

- [ ] OSF pre-registration is **live** — all 4 amendments filed before pilot launch: **O** (Amendment 5), **T** (Amendment 14), **Amendment 19** (Q3 wording), **Amendment 19b** (stimuli scope note). OSF URL accessible.
- [ ] 4 studies created (A, B, C, D), each with correct condition URL
- [ ] Estimated time: 12 minutes
- [ ] Reward: ≥ £2.00 per participant
- [ ] English-fluent filter active
- [ ] Cross-study deduplication enabled across all 4 studies
- [ ] Pilot quota: n=10 per study
- [ ] Completion URL and screen-out URL from Prolific entered into Qualtrics

### End-to-end test (do this before launching)

1. Create a test Prolific submission (Prolific provides a test mode).
2. Click through the survey as a participant in condition A.
3. Fail SC1 → confirm you are redirected to the Prolific screen-out URL.
4. Fail SC2 → confirm you are redirected to the Prolific screen-out URL.
5. Complete the full survey → confirm you are redirected to the completion URL.
6. Check the Qualtrics response in the data export — confirm: condition=A, PROLIFIC_PID populated, all question responses recorded.
7. Repeat steps 2–6 for condition D (different label label, same flow).

---

## Step 11 — After Pilot Launch: Monitoring

After launching the pilot (N=40):

1. **Check response rate** at 24 hrs. If < 50% of places filled in 48 hrs, increase reward to £2.50 or broaden country filter.
2. **Check median completion time** in Prolific submissions. Should be 8–15 min. If median > 20 min: survey has a usability issue. If median < 6 min: participants are rushing; check attention check failure rate.
3. **Check screen-out rate** in Qualtrics (SC1 or SC2 failures). Target: ≤ 30%. If SC2 is screening too many people (CS/SE occupation is over-represented in your Prolific audience), you can add Prolific's "Employment sector" filter to pre-exclude "Computing / IT" sector as a supplementary filter — this reduces screen-outs and cost.
4. **Download Qualtrics data** → run `piup-study1-drycheck.R` → confirm pilot N ≈ 10 per condition, exclusions as expected.
5. **Do not analyse hypotheses on pilot data.** Pilot is for instrument validation only (pre-registration §4.1 Stopping Rule).

---

## Step 12 — Data Export Naming Convention

After closing the pilot or full study, export Qualtrics data as CSV and name the file:

```
piup-study1-raw-pilot-YYYY-MM-DD.csv      (pilot data)
piup-study1-raw-full-YYYY-MM-DD.csv       (full study data)
```

Save to `analysis/data/` (this directory is in `.gitignore` — raw participant data is never committed to the repo).

Run `piup-study1-drycheck.R` → then `piup-study1-analysis.R` on the cleaned file.

---

## Appendix — Prolific Study Configuration Summary (Pilot)

| Parameter | Value |
|-----------|-------|
| Study type | Survey |
| Number of studies | 4 (one per condition) |
| Internal names | PIUP Study 1 — Condition A/B/C/D |
| External title | "Short Study: How You Understand a Website Interface (8–12 min)" |
| Estimated time | 12 minutes |
| Reward | £2.00 per participant (≥ £9/hr threshold) |
| Places per study (pilot) | 10 |
| Places per study (full) | 70 |
| Language filter | English (fluent) |
| Country filter | US only (pre-reg compliant) — or file OSF amendment for UK+US+CA+AU |
| Age filter | 18+ no upper bound (pre-reg compliant) — or file OSF amendment for 18-65 |
| CS/SE exclusion | SC2 in-survey (not a Prolific filter) |
| Voting experience inclusion | SC1 in-survey (not a Prolific filter) |
| Cross-study dedup | Enabled across all 4 studies |
| OSF pre-reg required | Yes — must be live before launch |

---

## Appendix — Study Description for Ethics/IRB File (if needed)

> Participants will be recruited online via Prolific Academic. Eligible participants are English-speaking adults (18–65) who have completed at least one online election, poll, or survey in the past 12 months, and who are not employed or studying in software engineering or computer science. Participants will view a single screenshot of a prototype voting interface and answer five comprehension questions, four confidence ratings, one open-ended question, and two demographic items. Estimated time: 8–12 minutes. Compensation: £2.00 per participant (equivalent to approximately £10/hour). No identifying information is collected. Prolific participant IDs are pseudonymous and will not be linked to names.

---

*Created tick-4323. Companion to `qualtrics-setup-guide-2026-06-22.md`. Waiting on JONY-ACTION O+T before use.*
