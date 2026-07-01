# Prolific Study Setup Guide — PIUP Study 2

**Author:** Jony Bursztyn  
**Date:** 2026-07-01 (tick-4432)  
**Instrument spec:** [`docs/piup-study2-survey-instrument-2026-06-28.md`](piup-study2-survey-instrument-2026-06-28.md)  
**Pre-registration:** [`docs/piup-study2-preregistration-draft-2026-06-29.md`](piup-study2-preregistration-draft-2026-06-29.md)  
**Qualtrics setup:** [`docs/qualtrics-setup-guide-study2-2026-06-28.md`](qualtrics-setup-guide-study2-2026-06-28.md)  
**Parallel doc:** [`docs/prolific-setup-guide-study1-2026-06-30.md`](prolific-setup-guide-study1-2026-06-30.md)

---

## ⛔ Prerequisites — MUST complete before creating any Prolific study

- [ ] **Study 1 pilot (N = 40) complete and H4 outcome confirmed.** Study 2 pre-registration (particularly N, H2.3 inclusion, and power analysis) is contingent on Study 1 H4 results. Do not finalise Study 2 pre-registration until Study 1 H4 is known (pre-reg §1 status note).
- [ ] **Study 2 pre-registration finalized and uploaded to OSF.** The draft is at `docs/piup-study2-preregistration-draft-2026-06-29.md`. If Study 1 H4 is not supported, reduce N from 240 to 160 and drop H2.3 before filing. OSF URL must be live before any Study 2 data collection.
- [ ] **Qualtrics survey fully built and tested** (all 8 conditions working; SC1/SC2 screen-out paths, calibration block for I2 conditions, prototype iframe embed, quota triggers, and completion redirect confirmed). Follow `qualtrics-setup-guide-study2-2026-06-28.md` end-to-end first.
- [ ] **Prototype deployed on Vercel in study mode** (`studyMode=true`, `explanationVariant` prop set per condition from URL, fallback static images present). The Qualtrics survey embeds the prototype in an iframe; if the iframe fails to load within 8 seconds, a static fallback image is shown (`browser_fallback = 1` flagged). Test this path before launch.
- [ ] **Study 1 Prolific study IDs noted.** You will use these to set the Prolific "previous studies" exclusion filter (Step 6 of this guide).
- [ ] Prolific account with a funded balance. Full study budget: ~$600 (N = 240 × $2.50) + platform fee (~33% = ~$198) = **~$800 total**. Pilot: ~$200 + platform fee (~$66) = ~$266 total.

---

## Overview — Single Prolific Study (not 4 or 8 separate)

**Critical difference from Study 1:** Study 2 uses **ONE Prolific study** pointing at a single Qualtrics survey URL. The Qualtrics Randomizer assigns participants to one of 8 conditions (L1/L2 × E1/E2 × I1/I2) internally, enforced via 8 Qualtrics Quotas (n = 30 per cell). You do NOT need 8 separate Prolific studies.

**Why:** Qualtrics handles condition assignment via `Randomizer → Embedded Data (condition = L1E1I1, …, L2E2I2)`. The 8-quota system ensures no cell overfills. Prolific needs only one study with the aggregate target N (for the full study: ~304 places; for the pilot: ~96 places — see §Places below).

**Study 1 comparison:**

| Feature | Study 1 | Study 2 |
|---------|---------|---------|
| Prolific studies | 4 (one per condition) | 1 (Qualtrics randomizes) |
| Condition assignment | Via Prolific URL parameter (`?condition=A`) | Via Qualtrics Randomizer |
| Quota enforcement | Prolific places cap (n = 70/study) | Qualtrics 8-cell Quota system |
| Cross-deduplication | Prolific cross-study filter across 4 studies | N/A (single study) |
| Stimulus | Static HTML file (iframe) | Interactive React prototype (iframe, with static fallback) |
| Screen-out | Separate per-study Prolific codes (4 sets) | Single screen-out URL |

---

## Step 1 — Create the Prolific Study

1. Log in to **Prolific** → click **New Study**.
2. Select **Survey** as the study type.
3. Fill in the study details (see §Study Details below).

> You will create only one study for Study 2, regardless of whether you are running the pilot or the full study. Set the **places** to the correct pilot or full-study N (see §Places).

---

## Study Details

### Study name (internal — only you see this)

**Pilot:**
```
PIUP Study 2 — Pilot (N=80; 2×2×2 receipt UX)
```

**Full study:**
```
PIUP Study 2 — Full (N=240; 2×2×2 receipt UX)
```

> Keep "Study 2" and the pilot/full distinction in the internal name for easy dashboard identification and for applying the Study 2 exclusion to Study 3 and 4 later.

---

### Study title (external — participants see this on Prolific browse page)

```
Short Study: How You Interact with a Prototype Website Interface (10–14 min)
```

> Use "interact with" (not "view") because Study 2 uses an interactive React prototype, not a static image. Do **not** mention voting, receipts, cryptography, privacy, or zero-knowledge. These terms would prime participants and invalidate Q-AC (the absent-content comprehension measure).

---

### Study description (participants see this)

Copy this text exactly:

```
In this study, you will interact with a prototype web interface and answer questions 
about your experience. No technical knowledge is required.

You will spend a few minutes using a prototype screen, then answer multiple-choice and 
short-answer questions about what you observed. The study takes approximately 10–14 
minutes. There are no right or wrong answers — we are interested in your genuine 
impressions of the prototype.
```

> "Interact with a prototype screen" is accurate and neutral. It does not reveal that the prototype is a voting receipt. The cover story (instrument §4) is introduced inside the survey only after SC1/SC2 screeners pass.

---

### Study category

Select: **Academic research**

---

### Study type

Select: **Survey** (link to external survey)

---

## Step 2 — Payment

### Estimated completion time

Set: **14 minutes** (conservative end of the 10–14 min instrument range).

> **Why 14 min?** The interactive prototype adds variability: participants with slower connections or who explore the prototype more thoroughly take longer. The I2 (calibration) conditions have extra questions (CAL1 + CAL2 + feedback screens). Setting 14 min protects participants who go carefully and avoids Prolific's "fast completion" quality flag. Participants who finish in 10 min are not penalised.

### Reward

Set: **£2.00 per participant** (equivalent to ~$2.50 USD; ≈ £8.57/hr at 14 min stated time).

> The pre-registration (§12) uses USD ($2.50/participant). Prolific accounts based in the UK use GBP; £2.00 ≈ $2.50. This is above Prolific's £9.00/hr minimum at 14 min stated time (£2.00/14 min × 60 = £8.57/hr — slightly under £9/hr). **Recommended: use £2.20/participant** (£9.43/hr at 14 min — above the minimum). If your Prolific account is USD-denominated, set $2.75/participant.

> **Higher-quality option:** £2.50/participant (£10.71/hr) → faster recruitment, better response quality. Budget impact: +£60 for full N=240.

### Pilot budget (N = 80)

- n = 80 × £2.00 = **£160** reward + Prolific fee (~33% = £52.80) = **~£213 total**
- n = 80 × £2.20 = £176 + £58.08 = **~£234 total**

> The quick instrument-validation check (N ≈ 40; ~5/cell) runs before the pre-registered pilot (N = 80; 10/cell). Run the N = 40 check first (pause the study after 40 completions), inspect data quality via `piup-study2-drycheck.R`, then resume for the remaining 40 pilot participants.

### Full study budget (N = 240; or N = 160 if H2.3 dropped)

- n = 240 × £2.00 = **£480** + Prolific fee = **~£638 total**
- n = 160 × £2.00 = **£320** + Prolific fee = **~£426 total** (H2.3-dropped scenario)

---

## Step 3 — Eligibility Filters (Prolific built-in)

> **Pre-registration alignment:** Pre-registration §4.1 specifies "US-resident adults, age 18+, English-speaking." Set filters to match exactly; any deviation requires an OSF amendment before data collection.

| Filter | Pre-reg compliant setting | Rationale |
|--------|--------------------------|-----------|
| **Fluent languages** | English | Pre-registration inclusion criterion |
| **Country of residence** | **United States only** | Pre-reg specifies US-resident |
| **Age** | **18 or older (no upper bound)** | Pre-reg specifies 18+; no upper cap |

**Do NOT set a CS/SE employment filter.** The SC2 screener inside Qualtrics handles the software engineering exclusion. Prolific's "IT sector" filter over-excludes (product managers, data analysts, QA, etc. would be excluded but are eligible per pre-reg §4.1). Let SC2 handle it.

**Do NOT set a "voting experience" filter.** SC1 (in-survey) handles this. Prolific has no matching built-in screener.

---

## Step 4 — Prior Study 1 Exclusion (Critical)

> **Why:** Pre-registration §4.1 states "No prior participation in Study 1 of this series (Prolific 'previous studies' filter on Study 1 Prolific ID; see also DM4)." Without this filter, Study 1 participants could re-enter Study 2 — their prior receipt exposure would contaminate Q-AC.

1. On the **Eligibility** page, scroll to **Custom eligibility → Previous studies**.
2. Add **each Study 1 Prolific study ID** (all 4 conditions: A, B, C, D) to the "Exclude participants who have taken part in" list.
3. This filter is enforced by Prolific at participant selection; affected participants never see the Study 2 study page.

> **DM4 (in-survey, not a Prolific filter):** DM4 ("Have you participated in any previous studies about voting receipts or receipt interfaces?") is asked inside the survey. Per pre-registration §4.1, DM4 = "Yes" is a **sensitivity flag, not an exclusion** from the primary analysis. Do not set a Prolific custom screener for DM4. The Qualtrics setup guide §15 "Before launch" checklist erroneously includes "custom screener: prior receipt study = No" — **do not add this as a Prolific screener**. The Prolific "previous studies" filter (for Study 1 Prolific IDs) is the correct and pre-registered exclusion mechanism. DM4 is handled in-survey as a flag only.

---

## Step 5 — Places (Aggregate N)

Prolific places = aggregate participant target across all 8 conditions. The 8-cell Qualtrics Quota system enforces n = 30/cell independently; you need enough Prolific places to fill all 8 cells after accounting for screen-outs and exclusions.

### Pilot

Set Prolific places to **N = 96** (12 per cell × 8 cells; ~20% over-recruitment buffer on 80 pre-registered pilot participants).

> For the quick instrument validation phase: pause the Prolific study after ~40 completions (5/cell). Inspect data quality (see Step 10: Monitoring). If instrument checks pass, resume for the remaining completions to reach N = 80.

### Full study (H2.3 included, N = 240)

Set Prolific places to **N = 304** (38 per cell × 8 cells; ~20% over-recruitment buffer on 240 pre-registered target).

> The 20% over-recruitment buffer accounts for: SC1/SC2 screen-outs (target ≤ 30%); attention-check exclusions; speed-through exclusions; and Qualtrics over-quota redirects (cells that fill first send remaining participants to the Prolific over-quota URL). Over-recruited participants who are screened out or over-quota are paid the screen-out rate (Prolific standard); they do not count toward the 240 pre-registered target.

### Full study (H2.3 dropped, N = 160)

If Study 1 H4 is not supported: update pre-registration to N = 160 (4 conditions only: L1E1I1, L1E1I2, L2E1I1, L2E1I2 — E1 conditions only; I still crossed within E1). Set Prolific places to **N = 192** (48 per cell × 4 cells).

> **Wait:** If H2.3 is dropped, the design collapses to L × E (4 cells); I is removed. Re-read pre-reg §1 contingency note carefully before setting N. The 4-condition collapse also requires removing the I2 Calibration block from the Qualtrics survey (see Qualtrics setup guide §3 Randomizer).

---

## Step 6 — Collect the Completion Codes

Study 2 uses **three Prolific codes** (one study, three outcomes):

| Code | Used for | Where configured |
|------|----------|-----------------|
| **Completion code** | Participant completes all questions + passes quotas | Qualtrics → Survey Termination → Redirect URL |
| **Screen-out code** | SC1 or SC2 fail | Qualtrics → End-of-Survey branch for screeners |
| **Over-quota code** | Qualtrics Quota met for a cell; participant routed out | Qualtrics → Quota action: redirect to over-quota URL |

When you create the Prolific study:

1. Go to **Study → Completion** to find the **completion URL** format: `https://app.prolific.com/submissions/complete?cc=XXXXXXXX`
2. Note the completion code `XXXXXXXX`.
3. Prolific's study dashboard also provides a **screen-out URL** (different code). Note this separately.
4. For over-quota: use Prolific's standard over-quota redirect URL (Prolific provides this in your study settings; it is separate from the screen-out URL).

Enter all three URLs into Qualtrics (see Qualtrics setup guide Steps 11–13).

---

## Step 7 — Compose the Survey URL

The single Qualtrics survey URL — with Prolific piping variables — is:

```
https://[YOUR_QUALTRICS_INSTANCE].qualtrics.com/jfe/form/SV_XXXX?PROLIFIC_PID={{%PROLIFIC_PID%}}&STUDY_ID={{%STUDY_ID%}}&SESSION_ID={{%SESSION_ID%}}
```

> **No `?condition=` parameter here.** Unlike Study 1, condition assignment is handled by the Qualtrics Randomizer inside the survey — not by the URL. All participants enter via the same URL.

> Replace `[YOUR_QUALTRICS_INSTANCE]` with your Qualtrics org prefix and `SV_XXXX` with your actual survey ID. Get the base URL from Qualtrics: **Distributions → Anonymous Link**.

> `{{%PROLIFIC_PID%}}` is Prolific's template variable — it is automatically replaced with each participant's Prolific ID when they click through. Do not modify this syntax.

---

## Step 8 — Enter the Survey URL in Prolific

On the **Study → Survey link** page:

1. Paste the complete URL (with Prolific piping variables) into the survey URL field.
2. Prolific will show a preview with a test PID substituted. Confirm the URL renders correctly.
3. Prolific will warn you if `{{%PROLIFIC_PID%}}` syntax is not recognized — check for curly-brace typos.

---

## Step 9 — Pre-launch Checklist

### Pre-registration (complete first)

- [ ] Study 1 H4 outcome known and Study 2 pre-registration updated if H2.3 is dropped
- [ ] OSF pre-registration **live and locked** (URL accessible) — data collection must not begin before this
- [ ] OSF URL noted for entry into Qualtrics welcome screen (instrument §4 cover story)

### Qualtrics (complete second — from `qualtrics-setup-guide-study2-2026-06-28.md`)

- [ ] Randomizer evenly distributes to 8 conditions (verified in preview)
- [ ] SC1 and SC2 screen-out paths redirect to Prolific screen-out URL
- [ ] I2 Calibration block (CAL1, CAL2, feedback screens) present and conditional on `I = I2`
- [ ] Prototype iframe loads in I1 and I2 conditions (test all 8 condition codes)
- [ ] Browser-fallback: blocked domain test confirms `browser_fallback = 1` fires + static image shown
- [ ] M4 (Calibration Confidence) item placed immediately after Q-AC and before Trust Scale (not after M3)
- [ ] 8 Qualtrics Quotas configured: n = 30 per cell; over-quota → Prolific over-quota URL
- [ ] Completion redirect → Prolific completion URL
- [ ] PROLIFIC_PID, STUDY_ID, SESSION_ID captured via embedded data
- [ ] `piup-study2-drycheck.R` PASS on synthetic data (N = 40 dry-run)
- [ ] End-to-end preview: I1 condition — condition assigned, prototype loads, Q-AC, completion redirect works
- [ ] End-to-end preview: I2 condition — Calibration block appears before prototype, feedback text correct

### Prolific (from this guide)

- [ ] Country filter: United States only
- [ ] Age filter: 18+ (no upper bound)
- [ ] Language filter: English (fluent)
- [ ] Previous studies filter: Study 1 Prolific study IDs (all 4 conditions) in "Exclude participants" list
- [ ] **No** DM4 custom screener on Prolific (DM4 is an in-survey flag only)
- [ ] Estimated time: 14 minutes
- [ ] Reward: ≥ £2.00 per participant (≥ £9/hr minimum; recommend £2.20)
- [ ] Prolific places: 96 (pilot) or 304 (full study, H2.3 included) or 192 (full study, H2.3 dropped)
- [ ] Three Prolific codes (completion, screen-out, over-quota) noted and entered into Qualtrics

### End-to-end test (do this before launching)

1. Use Prolific's **Preview** mode (or run as a test participant via Anonymous Link).
2. Arrive at survey via the Prolific-formatted URL — confirm `PROLIFIC_PID` is captured in Qualtrics Embedded Data.
3. Fail SC1 → confirm Prolific screen-out URL is reached.
4. Fail SC2 → confirm Prolific screen-out URL is reached.
5. Complete as an I1 participant (no calibration block) → confirm prototype loads, Q-AC answered, completion redirect fires.
6. Complete as an I2 participant (with calibration block) → confirm CAL1/CAL2 appear before prototype, feedback shown, M4 present, completion redirect fires.
7. Manually fill one Quota to quota limit in Qualtrics test mode → confirm over-quota redirect fires for the next participant in that cell.
8. Download one preview export → confirm 25 column names match `piup-study2-drycheck.R` expected columns.

---

## Step 10 — After Pilot Launch: Monitoring

### Instrument validation phase (first ~40 completions; ~5/cell)

Run the Qualtrics drycheck and inspect these before resuming to full pilot N = 80:

| Check | Target | Action if out of range |
|-------|--------|----------------------|
| Median completion time | 10–18 min | < 8 min: likely rushing; > 20 min: likely prototype issue |
| Condition balance | ≈ 5/cell (±2) | Randomizer may not balance at low N — acceptable; check at N=80 |
| SC1/SC2 screen-out rate | ≤ 30% | > 35%: Prolific participant pool has more CS/SE workers than expected; add Prolific "Computing/IT" sector exclusion as a supplementary filter and file OSF amendment |
| Browser-fallback rate | < 5% | > 10%: Vercel deployment issue — fix before resuming |
| Q-AC floor/ceiling | 20%–90% correct per cell | Outside range: ceiling effect (wording too easy) or floor (prototype not rendering) |
| Attention check pass rate | > 80% | < 70%: attention check too strict or prototype confusing |

### Full pilot monitoring (N = 80; 10/cell)

1. **Check response rate** at 48 hrs. If < 50% of places filled: increase reward to £2.50 or broaden to UK+US+CA+AU (requires OSF amendment).
2. **Check browser-fallback rate.** If > 10%, the Vercel prototype has loading issues affecting condition validity — pause, fix, file amendment.
3. **Do NOT analyse hypotheses on pilot data.** Pilot is for instrument validation only (pre-registration §7.1 stopping rule).
4. **Run** `Rscript -e "PILOT <- TRUE; source('analysis/piup-study2-analysis.R')"` → inspect pilot output for structural errors before full launch.

---

## Step 11 — Data Export Naming Convention

After closing the pilot or full study, export Qualtrics data as CSV and name the file:

```
piup-study2-raw-validate-YYYY-MM-DD.csv   (N≈40 instrument validation check)
piup-study2-raw-pilot-YYYY-MM-DD.csv      (N=80 pre-registered pilot)
piup-study2-raw-full-YYYY-MM-DD.csv       (N=240 full study)
```

Save to `analysis/data/` (in `.gitignore` — raw participant data is never committed to the repo).

Run `piup-study2-drycheck.R` first (confirms column names and structure), then `piup-study2-analysis.R` on the cleaned file.

---

## Key Design Differences from Study 1 — Summary

| Dimension | Study 1 | Study 2 |
|-----------|---------|---------|
| Prolific study count | 4 separate | 1 (all conditions) |
| Condition assignment | Prolific URL param (`?condition=A`) | Qualtrics Randomizer |
| Conditions | 4 (A/B/C/D) | 8 (L1E1I1 … L2E2I2) |
| Pilot N (pre-registered) | 40 (10/condition) | 80 (10/cell) |
| Full study N | 280 (70/condition) | 240 (30/cell); 160 if H2.3 dropped |
| Prolific places (full) | 4 × 70 = 280 (no buffer needed per study) | ~304 (20% buffer, all cells) |
| Stimulus type | Static HTML (iframe) | Interactive React prototype (iframe) |
| Browser fallback | Not applicable | Flag `browser_fallback = 1`; monitoring required |
| Prior study exclusion | Cross-study dedup within Study 1 only | Study 1 all 4 Prolific IDs excluded |
| Calibration block | Not applicable | I2 conditions only (CAL1, CAL2, feedback) |
| Screen-out redirect | Per-study code (4 codes) | Single code (all SC1/SC2 paths) |
| Over-quota redirect | Not applicable | Single over-quota code (8 Qualtrics Quotas) |
| Estimated time | 12 min | 14 min |
| Payment | £2.00/participant | £2.00–£2.20/participant |

---

## Appendix — Prolific Study Configuration Summary

| Parameter | Pilot | Full study (H2.3 included) | Full study (H2.3 dropped) |
|-----------|-------|---------------------------|--------------------------|
| Study type | Survey | Survey | Survey |
| Number of Prolific studies | 1 | 1 | 1 |
| Internal name | PIUP Study 2 — Pilot (N=80) | PIUP Study 2 — Full (N=240) | PIUP Study 2 — Full (N=160) |
| External title | "Short Study: How You Interact with a Prototype Website Interface (10–14 min)" | same | same |
| Estimated time | 14 minutes | 14 minutes | 14 minutes |
| Reward | £2.00–£2.20/participant | £2.00–£2.20/participant | £2.00–£2.20/participant |
| Prolific places | 96 (12/cell × 8) | 304 (38/cell × 8) | 192 (48/cell × 4) |
| Language filter | English (fluent) | English (fluent) | English (fluent) |
| Country filter | US only | US only | US only |
| Age filter | 18+ no upper bound | 18+ no upper bound | 18+ no upper bound |
| CS/SE exclusion | SC2 in-survey only | SC2 in-survey only | SC2 in-survey only |
| Prior Study 1 exclusion | Prolific "previous studies" filter (all 4 Study 1 IDs) | same | same |
| DM4 prior receipt study | In-survey flag only (NOT a Prolific screener) | same | same |
| Condition assignment | Qualtrics Randomizer | Qualtrics Randomizer | Qualtrics Randomizer |
| Quota enforcement | 8 Qualtrics Quotas (pilot quota: 10/cell) | 8 Qualtrics Quotas (30/cell) | 4 Qualtrics Quotas (40/cell) |
| OSF pre-reg required | Yes — must be live before launch | Yes | Yes |

---

## Appendix — Study Description for Ethics / IRB File (if needed)

> Participants will be recruited online via Prolific Academic. Eligible participants are English-speaking US-resident adults (18+) who have completed at least one online election, poll, or survey in the past 12 months, and who are not employed or studying in software engineering or computer science. Participants who previously participated in Study 1 of this series on Prolific are excluded via platform filter. Participants will interact with a prototype web interface displaying a post-submission screen and answer comprehension questions, trust ratings, save-intention ratings, and one open-ended question. In I2 (calibration) conditions, participants first complete two comprehension questions with immediate correct-answer feedback before interacting with the prototype. Estimated time: 10–14 minutes. Compensation: £2.00–£2.20 per participant (approximately £8.57–£9.43/hour). No identifying information is collected. Prolific participant IDs are pseudonymous and will not be linked to names.

---

## Known Gap: DM4 Prolific Screener Discrepancy

The Qualtrics setup guide (`qualtrics-setup-guide-study2-2026-06-28.md`) Step 15 "Before launch" checklist includes:

> `- [ ] Prolific screener includes: custom screener: prior receipt study = No`

**This is inconsistent with the pre-registration (§4.1)**, which classifies DM4 = "Yes" as a **sensitivity flag, not an exclusion criterion**. Setting a Prolific custom screener for this item would convert DM4 from a sensitivity flag into a pre-enrollment exclusion — a protocol deviation from the registered design.

**Correct approach (pre-registration compliant):**
- Use Prolific's "previous studies" filter to exclude Study 1 Prolific participants (the registered exclusion).
- Ask DM4 in-survey (already in the instrument). Flag `prior_receipt_study = 1` in the analysis script. Run pre-specified sensitivity checks at analysis time.
- Do NOT add a Prolific custom screener for DM4.

**If Jony wants to use a Prolific screener to exclude prior receipt study participants** (more conservative than the pre-registration): file an OSF amendment to §4.1 converting DM4 from a sensitivity flag to a pre-enrollment exclusion before adding the Prolific screener. Without an amendment, the screener would be an unregistered deviation.

---

*Created tick-4432. Companion to `qualtrics-setup-guide-study2-2026-06-28.md`. Waiting on Study 1 H4 outcome and Study 2 OSF pre-registration upload before use.*
