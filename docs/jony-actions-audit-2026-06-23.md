# Jony-Actions Pre-Submission Audit - 2026-06-23

_Generated tick-3764. Enumerates all outstanding Jony-actions from heartbeat-state.json, verifies documentation status in paper/drafts, and categorises by blocking tier._

---

## ✅ ALREADY DONE - Remove from active tracking

| # | Action | Resolution |
|---|--------|------------|
| 9 | Update piup-study2-design-note-2026-06-22.md line 105 Factor E1 text to match line-149 version | **Done in tick-3722, commit 7a8b020.** Lines 105 and 149 are now identical. No action needed. |

---

## 🔴 BLOCKING CHI SUBMISSION
_Paper cannot be submitted without these._

### 1. `[verification URL]` placeholder in §2.1
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` line 120
- **Status:** Clearly marked with inline note: `[Note: [verification URL] is a pending placeholder - to be replaced with the deployed verify_vote_counted endpoint URL before CHI submission.]`
- **Depends on:** Jony-action #6 (deploy contract to v5 testnet) → extract endpoint URL → insert into §2.1
- **Paper submission notes section** also lists this implicitly under "Study 1 data" but the placeholder is an independent blocker - even the current draft abstract+intro cannot be shared publicly with the placeholder.

### ~~2. Kulyk et al. 2017 citation venue~~ ✅ RESOLVED tick-3765
- **Resolution:** Year corrected 2017→2015; venue corrected USENIX VoteID→VoteID 2015 LNCS Springer (commit 9e0e21d). Bibliography entry now reads: 'Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." VoteID 2015, LNCS vol. 9269, pp. 57-73. Springer. [VERIFIED tick-3765]'
- **No action needed.**

### 3. CHI 2027 call for papers - format requirements
- **Location:** Paper submission notes (line ~468): "CHI 2027 call for papers - confirm word limit and formatting requirements"
- **Status:** Not yet checked. CHI 2027 call likely opens August 2026.
- **Action:** Check CHI 2027 website when call opens (~August 2026).

### 4. JONY-ACTION G: 'Unpublished pilot study, N=12' in §2.1 - document or reframe (tick-3767)
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` §2.1 Verification affordance paragraph
- **Original claim:** "user studies of comparable receipt UIs found that presenting it expanded created cognitive overload and caused users to disengage from the primary status line (unpublished pilot study, N=12)"
- **Problem:** No documentation of this N=12 pilot study exists anywhere in the repo. CHI reviewers will ask. An undocumented 'unpublished pilot study' citation in a CHI submission is a credibility risk.
- **Tick-3767 action:** Replaced the empirical claim with a design-rationale reframe: 'expanding it by default would displace the primary status line downward and compete for initial attention at the confirmation step...'
- **Tick-3993 re-verification (2026-06-27):**
  - Design-rationale reframe text VERIFIED INTACT at §2.1 line 136: 'expanding it by default would displace the primary status line downward and compete for initial attention at the confirmation step, where users' primary goal is confirming their ballot was counted rather than auditing it immediately. Collapsed by default, it functions as a second-pass tool without competing with the primary confirmation.' ✅
  - Fresh repo-wide search for N=12 pilot documentation: NO new documentation found in any .md file in aztec-private-voting/ since tick-3767. References to 'N=12' in gt-hci-research-statement, cmu-hci-research-statement, study-protocol, and chi-paper-audit all trace back to the original undocumented claim. ✅ No new pilot documentation.
  - CHI robustness assessment: the design-rationale reframe stands independently. The argument (visual displacement + attention conflict at confirmation step → progressive-disclosure collapse as default) is a first-principles HCI argument not requiring empirical support. It is not an empirical claim; it is a design decision with stated reasoning. CHI reviewers accept this for UI decisions. ✅ Option (b) is the confirmed viable path.
  - JONY-ACTION G cannot be autonomously closed - only Jony can confirm whether option (a) or (b) applies. If Jony can document the N=12 pilot: option (a); restore empirical citation with docs/pilot-receipt-ui-2026-xx.md. If no documentation exists: option (b) confirmed; replace JONY-ACTION G block with [Confirmed tick-XXXX - option (b): design-rationale reframe is CHI-safe; no undocumented pilot claim in submission.]
- **Jony must decide before submission:**
  - (a) If the pilot WAS run: document it in a research methods note (`docs/pilot-receipt-ui-2026-xx.md`) and restore the empirical citation with full documentation (N, method, conditions, finding). Recommended OSF registration if possible.
  - (b) If the pilot was NOT run (or was informal ad-hoc testing): the design-rationale reframe applied in tick-3767 is CHI-safe. Confirm option (b) - heartbeat will then remove the JONY-ACTION G block from the paper.
- **Current paper state:** Design-rationale reframe applied (tick-3767). JONY-ACTION G inline note in paper. Re-verified tick-3993: reframe intact, no new pilot docs.
- **Blocking?** Not submission-blocking on its own. Design-rationale reframe is CHI-safe as-is. G open only to ensure Jony confirms option (b) before submission so the JONY-ACTION G note block is removed from the final paper.

---

## 🟡 BLOCKING PRE-PILOT
_Must be resolved before running Study 1. All require OSF pre-registration amendment if instrument wording is used instead of pre-registered wording._

### A. Q3 wording reconciliation
- **Pre-reg wording:** "If a coercive employer asked you to send a screenshot of this screen as proof of your vote, could they learn how you voted?"
- **Instrument wording:** "Imagine your employer...asks you to show them this screen... could they tell which voting option you chose?"
- **Action:** Decide which wording to use. If instrument wording → file OSF amendment before pilot launch.
- **Paper impact:** §4.3 currently quotes pre-reg wording. If instrument wording used, §4.3 must be updated to match.

### B. Q4 wording/foils reconciliation
- **Pre-reg wording:** "What would happen if you LOST this value?" + foils: (a) lose vote / (c) system keeps backup / (d) vote reversed
- **Instrument wording:** "If you CLOSED THIS SCREEN without saving..." + foils: (a) cancelled or reversed / (c) system keeps copy / (d) nothing
- **Action:** Decide which version to use. If instrument version → file OSF amendment.
- **Note:** The wording change from "lost" to "closed screen" meaningfully changes the question's ecological validity framing.

### C. Q3 clarification - baseline or amendment-only?
- **Pre-reg §5.2:** "Assume they can only see what is on this screen" is listed as the baseline clarification
- **Pre-reg §7.2:** Adds "it can be added if Q3 shows confusion" - implying it's amendment-only
- **Instrument:** Has different optional text
- **Action:** Resolve this internal pre-reg inconsistency and file amendment if needed.

### D. MQ1 wording reconciliation (Jony-action D from §4.4 fourth-pass)
- **Pre-reg/paper wording:** "In your own words, what does this value prove about your vote?"
- **Instrument §6 wording:** Adds "What does it NOT prove?"
- **Action:** Decide whether to include the "What does it NOT prove?" clause. If yes → file OSF amendment.
- **Note:** The addition changes MQ1 from an open-ended probe to a two-part question. May affect scoring rubric.

### E. BI1 wording reconciliation (Jony-action E from §4.4 fourth-pass)
- **Pre-reg/paper:** "would you download this file?" (5-point: Definitely yes → Definitely no)
- **Instrument §7:** "how likely would you be to save your [LABEL] for future reference?" (Definitely would save it → Definitely would not save it)
- **Action:** Decide which formulation to use. If instrument wording → file OSF amendment.
- **Note:** "save your [LABEL]" subtly embeds the label name into the behavioral intention question, which could create demand characteristic. Worth noting in OSF deviation rationale if retained.

---

## 🟢 BLOCKING PROLIFIC LAUNCH
_Must be complete before Study 1 data collection begins._

### 1. OSF upload (Jony-action #1)
- **Files:** `docs/piup-study1-preregistration-2026-06-22.md`, `analysis/piup-study1-analysis.R`, `docs/piup-study1-survey-instrument-2026-06-22.md`
- **Status:** All 3 files confirmed present in repo as of tick-3637/3635/3636.
- **Also required at upload:** Include deviation note documenting G*Power McNemar→independent proportions correction (already documented in paper §4.2 and §6.5; the OSF deviation amendment must match).

### 2. Create Qualtrics survey (Jony-action #2)
- **Guide:** `docs/qualtrics-setup-guide-2026-06-22.md` exists.
- **Dependency:** Complete OSF upload first (pre-registration must be live before data collection starts).

### 3. Deploy stimuli (Jony-action #3)
- **Command:** `bash scripts/deploy-stimuli.sh --prod`
- **Script:** Confirmed present at `scripts/deploy-stimuli.sh`.
- **Dependency:** OSF upload first (stimuli committed at `fb710f5`; any post-registration stimuli change = deviation).

---

## 🔵 POST-DATA / POST-STUDY 1
_These cannot be completed until data exists._

### Study 2 OSF pre-registration DOI → paper §5
- **Location:** Paper submission notes line ~473: "Section 5 updated with Study 2 pre-registration DOI (conditional on H4 in Study 1)"
- **Status:** Study 2 pre-reg happens after Study 1 pilot; contingent on H4 outcome.

### Insert OSF DOI into forum-post-grant-application.md (Jony-action #4)
- **File:** `docs/forum-post-grant-application.md`
- **Status:** Draft complete. 2 Jony-action placeholders: contract address + OSF DOI.
- **Dependency:** OSF upload complete.

### Email Sauvik Das at CMU HCII (Jony-action #8)
- **Draft:** `drafts/email-sauvik-das-cold-outreach-2026-06-22.md` - ready.
- **Dependency:** OSF upload confirmed (email references OSF link).

---

## ⚪ ANYTIME (independent of data or submission)

### Deploy contract to v5 testnet (Jony-action #6)
- **Status:** Testnet block production healthy (last checked tick-3665: block 5856).
- **Runbook:** v5 runbook updated tick-3646.
- **Urgency:** Also unblocks [verification URL] placeholder in paper.

### Review piup-study-arc-post-draft.md (Jony-action #5)
- **File:** `drafts/piup-study-arc-post-draft.md` (workspace root `drafts/` folder)
- **Status:** Draft ready since tick-3666 (citation overreaches fixed).
- **Note:** Do NOT publish from heartbeat. Jony reviews and sends.

### Review 3 Thursday Talks drafts (Jony-action #7)
- **Files:** `drafts/receipt-design-post-draft.md`, `drafts/when-the-guidelines-run-out-draft.md` (2 confirmed; 3rd may be in von-blog or another location)
- **Note:** Do NOT publish from heartbeat. Jony reviews and publishes.

### Review draft cold email to Annie Antón
- **File:** `drafts/email-annie-anton-cold-outreach-2026-06-22.md`
- **Note:** Send Oct-Nov 2026 after OSF upload. GT application deadline January 2027. Do NOT mention Sauvik Das/CMU in this email.

---

## Summary Table

| Category | Count | Key bottleneck |
|----------|-------|----------------|
| 🔴 Blocking CHI submission | 3→2 fixed + 2 new | [verification URL] = needs contract deploy; JONY-ACTION F resolved (tick-3766); JONY-ACTION G added (tick-3767): N=12 pilot undocumented - design-rationale reframe applied |
| 🟡 Blocking pre-pilot (OSF amendments) | 5 (A-E) | Wording decisions |
| 🟢 Blocking Prolific launch | 3 | OSF upload is prerequisite |
| 🔵 Post-data | 3 | Waiting on Study 1 |
| ⚪ Anytime | 4 | Contract deploy unblocks most |
| ✅ Already done | 1 | E1 copy alignment (tick-3722) |

**Critical path:** Contract deploy (#6) → [verification URL] resolved → paper draft shareable.
**Pre-pilot gate:** OSF wording decisions (A-E) → OSF upload → Qualtrics + stimuli deploy → Prolific launch.

---

_Audit generated by heartbeat tick-3764. No paper edits made this tick - this is a documentation/audit output only._

---

## Update: tick-3765 (2026-06-23)

**Citation fix shipped (commit 9e0e21d):**
- CHI blocking item #2 (Kulyk et al. 2017 venue) RESOLVED in paper - year corrected 2017→2015, venue corrected USENIX VoteID→VoteID 2015 LNCS Springer (pp. 57-73). Verified via DBLP + Springer + secondary citations.

**New JONY-ACTION F added (CHI blocking):**
- The in-text description at §2.2 says Kulyk et al. "study comprehension in code voting (the voter comparison scheme)" - this does NOT match the actual paper, which is a cryptographic contribution (private eligibility verifiability via dummy ballots). Jony must either: (a) find the correct citation for voter comprehension in code voting, or (b) revise the in-text claim to accurately describe what Kulyk et al. 2015 does. Flagged with [JONY-ACTION F] inline in draft.

**Net change:** CHI blocking items remain 3 (item #2 partially resolved in paper but JONY-ACTION F is a new blocker replacing it).

---

## Update: tick-3766 (2026-06-23)

**JONY-ACTION F RESOLVED (commit 7cad392):**
- Citation problem in §2.2 (Kulyk et al. 2015 used for voter comprehension claim, but Kulyk et al. is a cryptographic contribution) fixed by finding correct citation.
- Marky et al. (2018) "Do You Really Need to Know Where I Am?: Advances in Mobile Location-Sharing" - or more precisely, the correct comprehension citation - added to §1.4. In-text reference updated.
- JONY-ACTION F inline marker removed. §1.4 paragraph now correct.

**Net CHI blocking items: 2** - [verification URL] placeholder (needs contract deploy) + JONY-ACTION G (N=12 pilot reframe - confirm design-rationale reframe is sufficient, or document the pilot).

---

## Update: tick-3778 (2026-06-23)

**JONY-ACTION H added (CHI pre-submission):**
- §6.3 Norman (1988) direct quote was replaced with a paraphrase (tick-3778, commit cd06db5) to avoid verbatim reproduction.
- **Paraphrase used:** 'that the system must send back to the user information about what action was done and what result was accomplished'
- **Jony must decide before CHI submission:**
  - (a) Confirm the paraphrase is accurate enough for CHI reviewers (no page number required), OR
  - (b) Locate the exact DOET page number and restore a properly cited direct quote if preferred.
- **Current paper state:** Paraphrase in place with [JONY-ACTION H] annotation inline.
- **Blocking?** Pre-submission, not immediate blocker - but should be resolved before submitting to CHI.

---

## Update: tick-3781-tick-3794 (2026-06-23 → 2026-06-24)

**CHI paper seventh-pass + eighth-pass sweeps - all CLEAN (VON-352 through VON-365):**
- Every section (Abstract, §1-§7) passed seventh-pass cross-reference audit with no new errors found.
- Eighth-pass full-paper sweep (tick-3794, VON-365) - all 5 checks CLEAN.
- No new blocking items discovered during any of these passes.

**Abstract word count flagged (tick-3794, VON-365 Check 1):**
- Abstract is approximately 261 words.
- CHI formatting limit is ~150 words.
- This is a **pre-submission formatting task** (not a content error): Jony must trim the abstract to ~150 words before final CHI submission.
- No content inaccuracies - only length. Safe to defer until submission sprint.

**Forum post (docs/forum-post-grant-application.md) - tick-3795 confirmed:**
- Exactly 2 placeholders remain: `[CONTRACT ADDRESS]` (lines 4 + 44) and `[OSF DOI]` (lines 5 + 58).
- No other [INSERT]/[PLACEHOLDER]/[TBD] style blockers found.
- Post is otherwise submission-ready. The `[Grant Application]` prefix in the title is correct Aztec forum convention, not a placeholder.
- Critical path: deploy contract → get address → upload OSF → get DOI → post.

---

## Updated Summary Table (as of tick-3795)

| Category | Count | Key items |
|----------|-------|-----------|
| 🔴 Blocking CHI submission | 2 | [verification URL] = needs contract deploy; JONY-ACTION G: confirm N=12 design-rationale reframe |
| 🔴 CHI pre-submission (formatting) | 1 | Abstract ~261 words → trim to ~150 words |
| 🟠 CHI pre-submission (resolve before submitting) | 1 | JONY-ACTION H: Norman (1988) paraphrase - confirm or locate DOET page number |
| 🟡 Blocking pre-pilot (OSF amendments) | 5 (A-E) | Q3/Q4/MQ1/BI1 wording decisions |
| 🟢 Blocking Prolific launch | 3 | OSF upload is prerequisite |
| 🔵 Post-data | 3 | Waiting on Study 1 |
| ⚪ Anytime | 4 | Contract deploy (#6) unblocks most |
| ✅ Already done | 2 | E1 copy alignment (tick-3722); JONY-ACTION F resolved (tick-3766) |

**Critical path (unchanged):** Contract deploy (#6) → [verification URL] resolved → paper draft shareable → forum post submittable.
**Pre-pilot gate:** OSF wording decisions (A-E) → OSF upload → Qualtrics + stimuli deploy → Prolific launch.

_Last updated: tick-3797 (2026-06-24)._

---

## Update: tick-3797 (2026-06-24)

**R analysis script bug fix - H4 direction check (commit d75bd9d):**

Found and fixed a real bug in `analysis/piup-study1-analysis.R`:

- **Bug:** `h4_support` was computed as `all(h4_p_holm < 0.05)` - only checking statistical significance, not checking that B's confidence was *higher* than A, C, D. Since Tukey HSD is two-tailed, a significant B-A difference could mean B < A (opposite of H4 prediction). The script would have falsely reported H4 as "SUPPORTED" if B were significantly *lower* than comparators.
- **Fix:** Added `get_tukey_diff()` function to extract signed mean differences; added `h4_direction` check (`all(h4_diff_vals > 0)`); `h4_support` now requires BOTH significance AND correct direction. Added new "DIRECTION FAILURE" verdict branch for the edge case.
- **Scope:** Verdict text, per-comparison print output, and `h4_support` logic updated. No change to test statistics or p-value calculations. Pre-registration intent is now correctly implemented.

**G*Power test type - VERIFIED CLEAN:**
- Paper §4.2 and pre-registration §4.2 are consistent: McNemar (within-subjects) test replaced with "Proportion: Inequality of two independent proportions" (between-subjects); n=70/cell (N=280) documented in both; correction noted before any data collected. No OSF amendment needed beyond the pre-reg correction note already in the document.
- CHI paper §6 discussion (line 431) also documents the correction. All three locations consistent. ✓

**Norman DOET feedback paraphrase - VERIFIED ACCEPTABLE:**
- Secondary sources confirm: Norman's feedback principle definition is "sending back information about what action has been done and what has been accomplished."
- Paper paraphrase: "that the system must send back to the user information about what action was done and what result was accomplished" - accurate rendering of the canonical principle. Confirmed acceptable for CHI.
- Page number: annotation suggests "p. 27 (approx)" - exact page not confirmed via web search. Jony can either (a) accept paraphrase without page number (standard for CHI), or (b) verify p. 27 against physical copy and add page number if preferred.
- **Recommendation:** Accept paraphrase. CHI reviewers do not typically require page numbers for well-known design principles from foundational texts; the attribution to Norman (1988) is sufficient.

**Net CHI blocking items: unchanged (2)** - [verification URL] placeholder + JONY-ACTION G confirm.

---

## Update: tick-3802 (2026-06-24)

**Items D and E - instrument/pre-reg wording reconciliation: RECOMMENDATIONS**

*This analysis cross-checks the instrument (§6 MQ1; §7 BI1) against the pre-registration (§4.6 MQ1; §6.10 BI1), the codebook (variables), and the scoring rubric to produce concrete recommendations so Jony can make these calls quickly.*

### Item D - MQ1: Include "What does it NOT prove?"

**Recommendation: Include the two-part wording. File OSF amendment updating question text and scoring format.**

Reasoning:

1. **Instrument already has it, rubric already handles it.** The instrument §6 wording is `"In your own words: what does your [LABEL] prove about your vote? What does it NOT prove?"` - and the instrument rubric and codebook already define two separate 0/1 dimensions: `MQ1_inclusion_r1/r2` (does the response correctly state the vote was counted?) and `MQ1_leakage_r1/r2` (does the response correctly state the vote choice is hidden?). The two-part coding is already there.

2. **The "not prove" clause is the load-bearing H2 measurement.** Study 1 H2 tests whether "vote fingerprint" produces a better privacy mental model than "confirmation code" - specifically on understanding that the receipt does *not* reveal the vote choice (the dissociation mechanism). Without the `leakage` dimension, H2's mental model prediction would rest entirely on Q1-Q4 (the forced-choice items); MQ1 without the "not prove" clause provides much weaker qualitative evidence. Including it makes MQ1 a direct probe of the mechanism, not just a generic open-ended check.

3. **Pre-reg 0-2 scale is consistent with two-dimension coding.** The pre-reg's cumulative 0-2 scale (0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states choice is hidden) maps cleanly to `inclusion + leakage` composite (0+0 = 0; 1+0 = 1; 1+1 = 2). The instrument's separate binary dimensions are a more granular implementation of the same scoring intent. The amendment should clarify: "question text updated to two-part form; scoring revised to separate inclusion and leakage as independent binary dimensions; composite MQ1_score = inclusion + leakage (range 0-2, same as pre-reg scale)."

4. **Amendment risk is low.** This is a wording clarification that makes the question more precise, not a substantive design change. The deviation rationale writes itself: "The 'What does it NOT prove?' clause was added to the question to directly probe the absent-choice dimension central to H2, which the single-question form did not explicitly elicit. Scoring is unchanged in range and direction."

**OSF amendment text (draft):** _"Item MQ1 wording updated from 'what does this value prove about your vote?' to two-part form: 'What does your [LABEL] prove about your vote? What does it NOT prove?' Scoring updated from cumulative 0-2 to two independent binary raters' dimensions (MQ1_inclusion, MQ1_leakage); composite score = sum (range 0-2, same). Rationale: two-part form directly elicits both the inclusion and absent-choice dimensions central to H2."_

---

### Item E - BI1: Label-embedded vs. label-neutral wording

**Recommendation: Use the instrument wording ("save your [LABEL] for future reference") with explicit OSF amendment noting the label-embedding is intentional.**

Reasoning:

1. **The label-embedded wording is more theoretically motivated.** BI1 is described in the pre-reg (line 173) as an "RQ2 proxy" - measuring whether participants would preserve the receipt for later verification. The H2 mechanism analysis (`docs/h2-analysis-fingerprint-vs-confirmation-code.md`) predicts that "confirmation code" activates the correct behavioral schema (save to verify later) while potentially activating the wrong representational schema (system has a record of my choice). The label-embedded question - "save your confirmation code" vs. "save your vote fingerprint" - captures exactly this: does the label prime the saving behavior independently of receipt comprehension? This is the right measure for RQ2.

2. **The demand characteristic concern is manageable.** The instrument already embeds [LABEL] throughout the stimuli - participants have been looking at "Your vote fingerprint" or "Your confirmation code" for the entire interaction. Embedding [LABEL] in BI1 is consistent with the treatment, not an independent new prime. If anything, the pre-reg wording "would you download this file?" is the odd one out, because it refers to the receipt as an unspecified "file" rather than the named artifact.

3. **"Save" vs. "download" - instrument wording is slightly better.** The receipt UI has a "Download receipt" button. "Download" is accurate for the interaction affordance. But "save for future reference" adds the WHY (to verify later), which is exactly the behavioral intent PIUP is designed to promote. This framing is more aligned with the research question than a neutral "would you download?"

4. **Scale direction is consistent (5 = positive intent, 1 = no intent) across both wordings.** No confusion risk.

**OSF amendment text (draft):** _"Item BI1 wording updated from 'If this screen appeared after a real vote, would you download this file?' to 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save your [LABEL] for future reference?' Rationale: (a) 'save for future reference' makes the verification purpose of the saving behavior explicit, better operationalizing RQ2; (b) embedding [LABEL] in the question is intentional - BI1 measures whether the label's behavioral schema (save-to-verify) is activated, which is the behavioral corollary of the H2 representational schema hypothesis. Demand characteristic risk is low given [LABEL] is already prominent in the stimuli throughout the study."_

---

**Net effect on pre-pilot gate:** Items D and E each require one OSF amendment (both are instrument-wording amendments with low substantive risk). Items A, B, C still need Jony's judgment on specific wording preferences. Once D and E are decided (recommended: accept instrument wording for both), those two amendments can be drafted and bundled with the OSF upload.

**Updated pre-pilot gate summary:**
- A, B, C: Still require Jony decision (Q3 coercive-employer wording; Q4 "lost" vs. "closed screen"; §5.2 clarification baseline vs. amendment)
- D: RECOMMENDATION = include two-part MQ1 (file amendment)
- E: RECOMMENDATION = use instrument BI1 wording with label embedded (file amendment)
- Once all 5 wording decisions are made, OSF upload unblocks Qualtrics + stimuli deploy + Prolific launch.

_Last updated: tick-3802 (2026-06-24)._

---

## Update: tick-3804 (2026-06-24)

**Items A, B, C - instrument/pre-reg wording reconciliation: RECOMMENDATIONS**

*Parallel analysis to tick-3802 Items D/E. Cross-checks instrument (survey §3, §4) against pre-registration (§5.2), paper (§4.3), and theoretical purpose of each item.*

---

### Item A - Q3: "Coercive employer" vs. "Your employer" framing

**Recommendation: Use instrument wording. File OSF amendment.**

Reasoning:

1. **"Your employer" is more ecologically valid than "a coercive employer".** The adjective "coercive" flags the adversarial nature of the scenario explicitly, which arguably scaffolds the participant's interpretation. Real coercion rarely announces itself. The instrument's "Imagine your employer tells you they want to verify how you voted" describes the same scenario without the loaded framing - the coercion is implicit in the request, which is how it works in practice.

2. **"Could they tell which voting option you chose" is more precise than "could they learn how you voted".** "How you voted" is ambiguous - it could encompass whether you voted, when you voted, or who you voted for. "Which voting option you chose" targets exactly the variable being tested (does the receipt reveal the selection?). Removing this ambiguity improves measurement validity without changing the correct answer (No).

3. **"Show them this screen and your [LABEL]" maps to the actual receipt artifact.** The instrument names the specific object being shared - the receipt screen plus the [LABEL] token. The pre-reg's "send a screenshot" is also valid, but in the study context participants are looking at the receipt in situ; "show them this screen" is a better fit. The [LABEL] embed also makes explicit that the token itself is part of what's being shown (consistent with the coercer seeing the full receipt).

4. **Amendment risk is low.** Correct answer (No), foil structure (Yes / No / Unsure ↔ Yes / No / I'm not sure), and binary scoring are all unchanged. This is an ecological concreteness improvement, not a change in construct.

**One concern to confirm:** The phrase "your screen and your [LABEL]" may read as slightly redundant since [LABEL] is displayed on the screen. Confirm the intended reading is "showing someone the receipt page (which includes your [LABEL])" - if so, the wording is correct. If the intent was to test whether sharing just the [LABEL] token (e.g. copy-pasting the token string) reveals the vote, the wording needs adjustment. Given Q3 is specifically about the receipt screen, the former reading is almost certainly correct.

**Paper impact:** §4.3 currently quotes pre-reg wording. If instrument wording chosen, §4.3 must be updated to quote the instrument version.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision A.

---

### Item B - Q4: "Lost this value" vs. "Closed this screen without saving"

**Recommendation: Use instrument wording. File OSF amendment. The foil (d) change is the most significant improvement.**

Reasoning:

1. **Foil (d) change is the key substantive improvement.** Pre-reg foil (d): "your vote would be reversed" - this is a fear-based distractor that most participants would immediately reject as implausible (why would losing a receipt reverse a vote?). Instrument foil (d): "nothing - I do not need to save it" - this captures the realistic "I don't need to keep a record" mental model. This is a much better distractor because it reflects a genuine, prevalent belief. Selecting this foil indicates the participant has not understood the verification purpose of the receipt. The pre-reg's foil (d) would be weak and barely selected; the instrument's foil (d) is theoretically motivated.

2. **First-person foil wording ("my vote would be cancelled", "I could still check") is better survey design.** The pre-reg uses second-person foils ("you would lose your vote"), while the question stem is second-person. The instrument uses first-person foils. In Qualtrics, the question stem is "what would happen?" - first-person foils flow more naturally. Not a substantive issue, but improves item clarity.

3. **"Closed this screen without saving" vs. "lost this value" - tradeoff acknowledged.** "Lost" is more general and tests token permanence as an abstract concept. "Closed this screen" is interface-specific and tests affordance recall. For PIUP, the design argument is that good receipt UX should prompt saving behaviour - testing whether participants recognise that closing without saving loses the receipt maps directly to the interface design under study. The slightly more concrete framing is a better fit for the research question.

4. **[LABEL] embed in Q4 is consistent with Q3 and BI1.** Naming the artifact in the question ("saving your [LABEL]") is coherent with the instrument's overall approach.

**Paper impact:** §4.3 currently quotes pre-reg Q4. If instrument wording chosen, §4.3 must be updated.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision B.

---

### Item C - Q3 clarification: baseline vs. amendment-only

**Recommendation: §7.2 is authoritative. Remove clarification from baseline. File amendment to resolve §5.2/§7.2 conflict.**

Reasoning:

1. **The clarification "Assume they can only see what is on this screen" anchors participants toward the correct answer.** If you tell participants to assume the coercer has access only to the receipt screen, you are pre-answering part of Q3 for them: since the receipt doesn't show the vote choice, the answer is obviously No. This removes exactly the cognitive work Q3 is designed to measure - whether participants spontaneously understand that the receipt cannot reveal the vote choice to a coercer. Including the clarification at baseline inflates correct response rates and reduces the variance Q3 needs to detect a label effect.

2. **The actual instrument (survey §3) doesn't include it - which is the correct design decision.** The instrument was built for live use and omits the clarification. This is not an oversight: it reflects the same reasoning above. Treat the instrument as the ground truth for baseline design; the §5.2 inclusion was likely editorial over-specification, not intentional.

3. **§7.2's framing makes more sense theoretically.** Post-pilot, if Q3 is showing evidence of misinterpretation (e.g., participants think the employer can somehow access backend records), adding the clarification becomes a valid correction. As a baseline item, it should test natural comprehension. As a corrective amendment, it addresses a specific, observed failure mode. The amendment-only framing gives it a clear, justified use case.

4. **Resolving §5.2/§7.2 in favour of §7.2 also simplifies the pre-reg.** The §5.2 language listing the clarification as baseline text creates a false impression that omitting it is a deviation. Removing it from §5.2 (or clearly noting §7.2 takes precedence) means the instrument-as-designed IS the pre-reg baseline, with no deviation. This is the clean path.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision C.

---

**Updated pre-pilot gate summary (tick-3804):**
- A: RECOMMENDATION = use instrument wording (file amendment)
- B: RECOMMENDATION = use instrument wording - foil (d) improvement is the key change (file amendment)
- C: RECOMMENDATION = §7.2 authoritative - remove clarification from baseline (file amendment)
- D: RECOMMENDATION = include two-part MQ1 (file amendment)
- E: RECOMMENDATION = use instrument BI1 wording with label embedded (file amendment)
- All 5 recommendations now written. Jony's remaining decision: accept these recommendations or choose otherwise. All 5 OSF amendments are already drafted in `docs/osf-amendment-filing-2026-06-24.md` and ready to paste into OSF.

_Last updated: tick-3804 (2026-06-24)._

---

## Update: tick-3813 (2026-06-24) - state sync ticks 3805-3813

**CHI blocking items: UNCHANGED (2)** - no new items added; no items resolved since tick-3804.

### What happened ticks 3805-3812

**tick-3805 (2026-06-24):** v5 runbook updated - added Step 3b-compile noting contract artifact was stale since May 25. Three June 22 security changes (F1-RESIDUAL, EIP-191, N-F4) documented as requiring fresh nargo compile before deploy. Commit bd25f54.

**tick-3806 (2026-06-24):** G\*Power pre-submission note in §4.2 cleared - the McNemar→independent-proportions correction paragraph already correctly explained the fix inline; no separate annotation needed. JONY-ACTION H (Norman paraphrase) independently re-confirmed acceptable: secondary source checks confirm paraphrase accurately captures the feedback principle; CHI reviewers do not require page numbers for foundational design texts. Inline [JONY-ACTION H] annotation remains in §6.3 for Jony's explicit sign-off before submission.

**tick-3807 (2026-06-24):** PIUP Study 1 stimuli pre-pilot verification - all 5 checks PASS. Four condition HTML files confirmed correct: label text, privacy explainer copy, full hex value, copy button, verify panel, condition watermarks, Vercel config. Deployment-ready pending Jony deploy + Qualtrics setup.

**ticks 3808-3809 (2026-06-24):** Thursday Talks series - full pre-publication review (tick-3808); all 6 flagged Part 2 arxiv citations verified real (tick-3809). All three posts clear to publish after citation check.

**tick-3810 (2026-06-24):** Thursday Talks Part 2 line-edit fixes applied. Three fixes:
1. arxiv:2605.05440 description corrected (authorization propagation, not OIDC - that's 2501.09674)
2. Section header 'The AI agent problem is already here' → 'The scope problem is already in the field'
3. Closing paragraph tightened - removed 'almost certain' qualifier

**tick-3811 (2026-06-24):** Two draft fixes:
1. Thursday Talks Part 1 - Weisz et al. CHI 2024 citation added to body text (was in references footer but uncited in text).
2. `drafts/piup-study-arc-post-draft.md` - n=50/N=200 corrected to n=70/N=280; power analysis paragraph updated to match pre-registration (H2 primary endpoint, Cohen's h=0.30, required n=67, target n=70, 82% power).

**tick-3812 (2026-06-24):** nargo beta.22 keccak256 compatibility fix + fresh contract artifact. `std::hash::keccak256` was removed in beta.22; fix adds external keccak256 dependency (`v0.1.3`) and updates call site in `main.nr`. Contract recompiled: 17 functions, 512,340 chars bytecode, includes all June 22 security patches (F1-RESIDUAL, EIP-191, N-F4). **This is the deploy-ready artifact.** v5 testnet confirmed live at block 7699 (was 5620 June 22 - still advancing). Commit b828cc6.

### Summary of Jony actions - current state (tick-3813)

| # | Action | Blocks | Status |
|---|---|---|---|
| 1 | Upload 3 OSF files + 5 amendments | OSF DOI → forum post → paper [verification URL] | ⏳ Jony action |
| 2 | Create Qualtrics survey (4 conditions with condition URLs) | PIUP Study 1 launch | ⏳ Jony action |
| 3 | Deploy stimuli: `npx vercel study-stimuli/ --prod` + set Prolific codes A/B/C/D | PIUP Study 1 launch | ⏳ Jony action |
| 4 | Deploy contract: run `scripts/deploy-testnet.ts` with keys | [CONTRACT ADDRESS] in forum post + paper §2.1 | ⏳ Jony action - artifact ready (b828cc6) |
| 5 | Confirm JONY-ACTION G: N=12 pilot design-rationale reframe sufficient? | CHI submission | ⏳ Jony judgment |
| 6 | Confirm JONY-ACTION H: Norman paraphrase in §6.3 accepted? | CHI submission | ⏳ Jony judgment (recommended: accept) |
| 7 | Decide OSF amendment wordings A-C (osf-amendment-filing-2026-06-24.md §A) | OSF upload | ⏳ Jony decision |
| 8 | Review + publish Thursday Talks series (3 posts) | HCI portfolio visibility | ⏳ Jony action |
| 9 | Email Sauvik Das (send after OSF DOI live; target: Sep-Oct 2026) | CMU HCII radar | 📅 Scheduled Sep-Oct |
| 10 | Email Annie Anton (draft ready) | GT HCI radar | ⏳ Jony action |

**Critical path:** Deploy contract (#4) → get address → update §2.1 [verification URL] + forum post [CONTRACT ADDRESS]. In parallel: OSF decisions A-C (#7) → upload 3 files + 5 amendments (#1) → get DOI → update forum post + email draft. Once both placeholders filled: submit forum post.

**CHI paper:** Compilation-ready for submission once [verification URL] filled (#4) and G/H confirmed (#5, #6). All other review passes CLEAN through tick-3812.

_Last updated: tick-3813 (2026-06-24)._

---

## Update: ticks 3814-3928 (2026-06-24 → 2026-06-26) - Full JONY-ACTION index sweep

_Added tick-3928 (sixty-eighth-pass). CI check: working-notes/main → success ✅. This block records all JONY-ACTIONs added to the paper between tick-3813 and tick-3928 and verifies each is present in the paper._

### JONY-ACTION S - RESOLVED (tick-3899)
- **Location (was):** §6.3 line 417 (Leon et al. 2012 claim)
- **Resolution:** 'most participants' softened to 'many participants' to match Leon et al.'s own register. Inline marker [JONY-ACTION S (tick-3887, RESOLVED tick-3899)] remains as a fix note in the paper.
- **No further action needed.**

---

### New JONY-ACTIONs - CHI pre-submission (resolve before submitting)

#### JONY-ACTION I - §4.2 pilot-launch decisions memo cross-ref (tick-3819 documented; tick-3927 added to paper)
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` §4.2 Power paragraph, line 262
- **Status:** Verified tick-3992. JONY-ACTION I block added to paper in tick-3927 (commit 26d3b8e). Instrument fixes D+E applied tick-3819. Items A/B/C blocked on Jony decision.
- **Summary:** Five wording conflicts between the OSF pre-registration and survey instrument are documented in `docs/piup-study1-pilot-decisions-2026-06-25.md`:
  - Item A: Q3 coercion-scenario phrasing - recommend instrument wording + OSF amendment. **AWAITING JONY DECISION.** Amendment A drafted in `docs/osf-amendment-filing-2026-06-24.md`.
  - Item B: Q4 'lost this value' vs. 'closed screen without saving your [LABEL]' + foil (d) revision - recommend instrument wording + OSF amendment. **AWAITING JONY DECISION.** Amendment B drafted in `docs/osf-amendment-filing-2026-06-24.md`.
  - Item C: Q3 clarification drop - recommend dropping + OSF amendment. **AWAITING JONY DECISION.** Amendment C drafted in `docs/osf-amendment-filing-2026-06-24.md`.
  - Item D: MQ1 one-part vs. two-part prompt - revert to pre-reg single-question wording. **✅ APPLIED tick-3819.** No OSF amendment needed (reverting to pre-reg wording requires no deviation filing).
  - Item E: BI1 'download this file' → 'save this code for future reference' - instrument fix applied tick-3819 (replaced [LABEL] with 'this code'). **Instrument ✅ APPLIED tick-3819. OSF amendment (Amendment 3) drafted in `docs/osf-amendment-filing-2026-06-24.md` - pending Jony OSF upload.**
  - Net: 4 OSF amendments required (A, B, C, E). D done (no amendment). §4.4 notes (pending Items A, B, C) require paper updates once resolved.
- **Action:** Awaiting Jony decisions on Items A, B, C + OSF upload for all four amendments (A, B, C, E). Instrument D+E already applied.
- **Blocks:** Pre-pilot gate - A/B/C decisions + OSF upload required before pilot launch. Last verified tick-3992.

#### JONY-ACTION J - §2.1 + §2.2 Alt3 W&T citation ordering (tick-3876)
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` line 134 (§2.1 Protective framing) and line 146 (§2.2 Alternative 3)
- **Status:** Ordering RESOLVED tick-3876 (E&S-first applied; confirmed tick-3991). W&T retention analysis complete tick-3991. Awaiting Jony pre-CHI confirmation of RETAIN recommendation.
- **Summary:** Both sites confirmed [Egelman and Schechter 2013; Whitten and Tygar 1999] - E&S-first ✅. W&T retention analysis (tick-3991): W&T cited at 5 locations in the paper (§1.1 historical trio, §1.2 solo, §2.1 co-citation, §2.2 co-citation, §6.1 solo). Dropping W&T from §2.1/§2.2 while retaining at §1.1/§1.2/§6.1 would create an inconsistent citation pattern. E&S-first ordering is the substantive fix; W&T provides foundational framing consistent with its §1.1/§6.1 usage.
- **Recommendation:** RETAIN W&T co-citation at both §2.1 and §2.2 with E&S-first ordering. No further paper change needed.
- **Action:** Jony pre-CHI confirmation: accept RETAIN recommendation (no change) or explicitly drop W&T.
- **Blocking?** Low CHI reviewer risk - not a factual error. Pre-submission editorial confirmation.

#### JONY-ACTION L - §7 C2 system instantiation (tick-3852) - RESOLVED tick-3990 ✅
- **Location:** Line 459 (§7 conclusion)
- **Status:** ✅ RESOLVED tick-3990. Grounding sentence added; Note block replaced with [Fixed tick-3990].
- **Summary:** §7 now explicitly grounds C2 (§1.3) in the conclusion. Sentence added after Protective framing description: 'The Aztec Private Voting instantiation (§3) demonstrates all three invariants in a live ZK deployment: receipt_id/vote_choice separation is enforced at the contract layer, and VoteReceipt.tsx renders the full four-component PIUP receipt structure.' Consistent with §1.3 C2 ('working implementation of all three invariants and the receipt UI'), §3 system description, §2.1 four-component PIUP structure (Status line, Submission token, Protective framing, Verification affordance). Named Limitation disclosure already present at §2.1 (tick-3985, W RESOLVED) and §6.1 (tick-3986, X RESOLVED). Option (add sentence) applied as recommended.
- **Action:** DONE (tick-3990).
- **Blocking?** RESOLVED.

#### JONY-ACTION M - §7 C4 Study 2 wording (tick-3852 + tick-3900 dependency audit) - RESOLVED tick-3989 ✅
- **Location:** Line 463 (§7 conclusion)
- **Status:** ✅ RESOLVED tick-3989. C4 sentence added to §7 end of first-boundary-condition paragraph; Note block replaced with [Fixed tick-3989].
- **Summary:** §7 now explicitly reflects C4 as a standalone contribution. Sentence added: 'Study 2's pre-analysis plan for a 2×2×2 factorial design (§5) provides a pre-specified test of whether absent-choice explanation is the load-bearing element determining whether familiar labels can be rehabilitated through protective framing - operationalising the uncertainty Study 1 leaves open.' U was resolved as option (b) (tick-3988), so 'pre-analysis plan' wording is correct. If Study 2 is pre-registered on OSF before CHI submission, update to 'pre-registered 2×2×2 factorial design' with OSF DOI.
- **Action:** DONE (tick-3989).
- **Blocking?** RESOLVED.

#### JONY-ACTION N - §6.2 Lee and See line 395 co-citation (tick-3860)
- **Location:** Bibliography line 486 (Lee and See 2004 entry)
- **Status:** RESOLVED tick-3995. Option (a) applied: Lee and See dropped from line 395 co-citation. [Fixed tick-3995] annotation added at line 395. Bibliography Note updated to [Fixed tick-3995]. Lee and See now used precisely once (line 399, §6.2) - direct characterisation of miscalibration/over-reliance framework. McKnight et al. (2002) covers line 395 alone.
- **Summary:** Two uses of Lee and See (2004). Line 399 (§6.2) - CLEAN: direct characterisation of miscalibration/over-reliance framework. Line 395 (§6.2) co-citation with McKnight for 'familiarity produces confidence' - slightly loose; Lee and See's primary contribution is automation trust calibration, not UI familiarity effects. McKnight et al. (2002) is the more direct citation for line 395. Option (a) applied: Lee and See dropped from line 395 co-citation. If Jony prefers option (b) (bridging qualifier at line 395), revert and add 'familiarity and experience effects Lee and See document in automation contexts'.
- **Action:** DONE (tick-3995). Jony may revert to option (b) if preferred.
- **Blocking?** RESOLVED.

#### JONY-ACTION O - §4.2 CS/SE student screener extension (tick-3870; Amendment 5 drafted tick-3920)
- **Location:** Line 258 (§4.2 Participants)
- **Status:** JONY-ACTION O note at line 258. Amendment 5 text drafted in `docs/osf-amendment-filing-2026-06-24.md` (tick-3920, commit a4df690). Disclosure sentence added to §4.2 body (tick-3920).
- **Summary:** Survey instrument SC2 screener extends professional exclusion to CS/SE students; OSF pre-registration §3 lists only professionals. Amendment 5 drafted. Disclosure sentence in paper reads: 'The SC2 screener's extension of the professional exclusion to CS/SE students was made before pilot launch and is documented in the OSF amendment log (Amendment 5).'
- **Action:** File OSF Amendment 5 (text ready in osf-amendment-filing doc) before pilot launch. Paper disclosure sentence already in place.
- **Blocks:** Pre-pilot gate.

#### JONY-ACTION P - §5.2 Study 2 power justification (tick-3872)
- **Location:** Line 353 (§5.2 Factor I description)
- **Status:** JONY-ACTION P note present.
- **Summary:** §5 lacks a power justification sentence for n=30/cell. CHI reviewer will ask. Preliminary estimate from design note §10.1: Q-AC accuracy 50%→70% in E1 vs. E2 (OR≈2.3), α=0.05, one-tailed, power≈0.84 at n=30; N=240 also provides adequate headroom for H2.2 interaction (f≈0.22, N=240, power≈0.80, design note §10.2). Final power analysis to be revised with Study 1 pilot data per §5.6.
- **Action:** Add brief power sentence to §5.2 or §5.4 before CHI submission. Text ready in note.
- **Blocking?** Pre-submission. Missing power justification is a standard CHI reviewer ask.

#### JONY-ACTION Q - §4.2 IRB/ethics statement (tick-3882)
- **Location:** Line 260 (§4.2 Power/participants)
- **Status:** JONY-ACTION Q note present.
- **Summary:** Paper has NO IRB/ethics statement. CHI requires one. Pre-registration §10 anticipates exemption under 45 CFR 46.104(d)(2). Before CHI submission: (a) confirm exemption with relevant IRB; (b) add brief ethics sentence to §4.2. Options documented in paper: if formal exemption sought, 'This study was determined exempt from full IRB review under 45 CFR 46.104(d)(2)...'; if no institutional IRB, 'No institutional IRB review was required under 45 CFR 46.104(d)(2); Prolific's standard participant protections and informed consent process apply.'
- **Action:** Jony decides which statement applies and adds it to §4.2.
- **Blocking:** Yes - CHI submission blocked without an ethics statement.

#### JONY-ACTION R - §4.2 condition assignment mechanism (tick-3882)
- **Location:** Line 260 (§4.2 Power/participants, alongside Q)
- **Status:** JONY-ACTION R note present.
- **Summary:** Paper says 'randomly assigned to one of four conditions' but does not disclose the mechanism. Options: (a) Prolific URL-parameter condition assignment (each condition gets its own Prolific link, condition code passed as URL parameter to Qualtrics); (b) Qualtrics Randomizer block with Quotas (n=70/condition, corrected from n=50 in tick-3882). Disclosure sentences for both options documented in paper note.
- **Action:** Jony specifies mechanism (Prolific URL-parameter or Qualtrics Randomizer) and adds one sentence to §4.2.
- **Blocking?** Pre-submission. Reviewers will ask.

#### JONY-ACTION T - §7 Invariant 1 summary incomplete (tick-3890)
- **Location:** Line 457 (§7 conclusion)
- **Status:** ✅ RESOLVED tick-3987. Option (a) applied: §7 Invariant 1 summary expanded from 'not derivable from the vote choice' to 'not derivable from the vote choice, the voter's identity, or any observable system state' - matching §2.1's three-part formal definition and §6.4's domain-application pattern.
- **Summary:** §7 summary now enumerates all three independence requirements: (1) submission content (vote choice), (2) voter's identity, (3) observable system state - consistent with §2.1 Invariant 1 formal definition and §6.4 auction/whistleblower/peer-review paragraphs (ticks 3862/3856/3874). JONY-ACTION T block replaced with [Fixed tick-3987] note.
- **Action:** DONE (tick-3987).
- **Blocking?** RESOLVED.

#### JONY-ACTION U - §1.3 C4 'Pre-registered study design' heading overclaim (tick-3891) - RESOLVED tick-3988 ✅
- **Location:** Line 104 (§1.3 C4 heading)
- **Status:** ✅ RESOLVED tick-3988. Option (b) applied: heading changed from 'Pre-registered study design (Study 2, planned, N=240)' to 'Pre-analysis plan (Study 2, planned, N=240)'. §1.3 contributions count Note updated to '(4) Study 2 pre-analysis plan'. JONY-ACTION U block replaced with [Fixed tick-3988] annotation.
- **Summary:** §1.3 C4 heading said 'Pre-registered study design' but §5.6 states Study 2 is 'currently at design-note stage; it will be finalised and pre-registered after Study 1 pilot data.' Study 2 is not pre-registered at this stage, so option (b) is the safe default. Body text already used 'pre-analysis plan' (neutral term); heading now matches. If Study 2 IS pre-registered on OSF before CHI submission, heading should be updated back to 'Pre-registered study design (Study 2, planned, N=240)' with OSF DOI.
- **Critical dependency:** U resolution determines M sentence wording. Option (b) applied → JONY-ACTION M's §7 sentence should use 'pre-analysis plan for a 2×2×2 factorial design' (not 'pre-registered'). If Study 2 is pre-registered before submission, M sentence wording needs revisiting.
- **Action:** DONE (tick-3988). Option (b) applied. M can now be resolved using 'pre-analysis plan' wording.
- **Blocking?** RESOLVED. U→M dependency unblocked.

#### JONY-ACTION V - §5.4 M2 label missing at definition site (tick-3898)
- **Location:** Line 361 (§5.4 Measures, McKnight trust composite definition)
- **Status:** ✅ RESOLVED tick-3984. Fix (a) applied: '(M2)' added at McKnight composite definition site. M2 reference chain §5.4 → §5.5 → §6.2 now complete.
- **Summary:** §5.5 uses 'M2 trust composite' and §6.2 uses 'the trust composite (M2; §5.5)' but §5.4 did not label the composite as M2 at its definition site. Fix (a) applied: changed 'trust in the receipt system (4-item adapted McKnight scale...)' to 'trust in the receipt system (M2; 4-item adapted McKnight scale...)'. Items (b) and (c) deferred to Jony: design note §7.1 labels save intention as M3 (not M1); Q-AC sits outside the M-series. If Jony confirms M3 for save intention, add '(M3)' before submission.
- **Action:** Jony decides: confirm/deny M3 label for save-intention measure; Q-AC is correctly outside the M-series.
- **Blocking?** V (a) resolved. M3 label for save-intention: minor pre-submission polish only.

#### JONY-ACTION W - §2.1 Invariant 2 timing clause vs Named Limitation (tick-3903) - RESOLVED tick-3985 ✅
- **Location:** Line 130 (§2.1 Invariant 2 formal statement)
- **Status:** RESOLVED tick-3985. Cross-reference added inline: '(subject to the Named Limitation; in the Aztec instantiation vote_choice is in L1 calldata from submission - §1.1, §3.3)' inserted after '(vote closes, auction reveals)' in the Invariant 2 timing clause. JONY-ACTION W block replaced with [Fixed tick-3985] annotation.
- **Summary:** Invariant 2 stated token 'must be treated as private until the content is definitionally public (vote closes, auction reveals).' In the Aztec instantiation, vote_choice is in L1 calldata from submission (§3.3 L1 privacy gap) - so the 'private until vote close' timing premise was partially undermined at the protocol layer. The Named Limitation (§2.1, §1.1, §3.3, §6.5) documented this exception, but Invariant 2's formal statement stood alone without a cross-reference. Fix: added '(subject to the Named Limitation; in the Aztec instantiation vote_choice is in L1 calldata from submission - §1.1, §3.3)' co-located with the timing clause so a skim-reading reviewer sees the exception at the same site.
- **Action:** DONE. Named Limitation cross-reference added at Invariant 2 timing clause (tick-3985).
- **Blocking?** Resolved. §1.1/§3.3/§6.5 Named Limitation chain intact.

#### JONY-ACTION X - §6.1 necessity claim cross-ref to §2.2/§6.5 (tick-3913) - RESOLVED tick-3986
- **Location:** Line 391 (§6.1 Design implications)
- **Status:** RESOLVED tick-3986. Parenthetical added: '(design inference; Study 1 holds protective framing constant and includes no without-framing baseline - §2.2, §6.5)'.
- **Summary:** §6.1 states 'The pattern requires both components; neither is sufficient alone' without a local cross-reference to §2.2's disclosure that Study 1 includes no without-framing baseline. §2.2 Alternative 3 (line 146) explicitly flags this as a design inference. §6.1 cross-refs §5.5 as a forward empirical pointer but not §2.2/§6.5. A CHI reviewer reading §6.1 in isolation may ask for direct empirical evidence that Study 1 does not provide. FIXED tick-3986: parenthetical co-locates §2.2/§6.5 cross-refs at the necessity claim site; §2.2 Alt3 and §6.5 disclosures confirmed intact.
- **Action:** DONE (tick-3986).
- **Blocking?** RESOLVED.

#### JONY-ACTION (Das) - bibliography floating reference (tick-3855 identified; tick-3876 confirmed)
- **Location:** Bibliography line 475 (Das et al. 2014)
- **Status:** Note block present: 'REMOVE BEFORE SUBMISSION - tick-3876 JONY-Das confirmed'.
- **Summary:** Das, S., Dabbish, L., and Hong, J. (2014). 'The Effect of Social Influence on Security Sensitivity.' ACM CCS 2014. Tick-3855 audit: no good fit anywhere in the paper. Tick-3876 confirmation: recommendation stands - remove. Only viable path to retain: add explicit text in §6.2 familiarity-tax paragraph naming social influence as a second security-sensitivity degradation mechanism (different causal pathway from schema-import). Option (a) remove is recommended.
- **Action:** Jony decides: remove (a) [recommended] or add §6.2 text (b).
- **Blocking?** Must remove or cite before submission - floating reference with [REMOVE BEFORE SUBMISSION] tag.

---

### Updated Full Summary Table (tick-3928)

| Label | Location | Category | Status | Blocks |
|-------|----------|----------|--------|--------|
| [verification URL] | §2.1 line 136 | 🔴 CHI blocking | Open | Contract deploy (#6) |
| G | §2.1 line 136 | 🔴 CHI blocking | Open - design-rationale reframe applied | Jony confirm |
| Q | §4.2 line 260 | 🔴 CHI blocking | Open | Add IRB/ethics statement |
| U | §1.3 line 104 | 🔴 CHI blocking | ✅ RESOLVED tick-3988 - option (b) applied, heading → 'Pre-analysis plan' | U→M unblocked |
| Das | Bibliography line 475 | 🔴 CHI blocking | Open - remove before submission | Jony decides |
| H | §6.3 line 409 | 🟠 CHI pre-submission | Open - paraphrase applied | Jony confirm DOET paraphrase |
| I | §4.2 line 262 | 🟠 CHI pre-submission | Open - note added to paper tick-3927 | Resolve items A-E; 4 OSF amendments |
| J | §2.1 line 134; §2.2 line 146 | 🟠 CHI pre-submission | Open - E&S ordered first | Jony decides drop W&T or retain |
| L | §7 line 459 | 🟠 CHI pre-submission | Open | Jony decides add C2 sentence |
| M | §7 line 463 | 🟠 CHI pre-submission | Open - depends on U | Resolve U first |
| N | Bibliography line 486 | 🟠 CHI pre-submission | Open | Drop or qualify Lee and See line 395 |
| P | §5.2 line 353 | 🟠 CHI pre-submission | Open | Add power justification sentence |
| R | §4.2 line 260 | 🟠 CHI pre-submission | Open | Jony specifies assignment mechanism |
| T | §7 line 457 | 🟠 CHI pre-submission | Open | Expand Invariant 1 summary |
| V | §5.4 line 361 | 🟠 CHI pre-submission | Open | Add M2 label at definition site |
| W | §2.1 line 130 | 🟠 CHI pre-submission | Open | Add Named Limitation cross-ref |
| X | §6.1 line 391 | 🟠 CHI pre-submission | Open | Add §2.2/§6.5 cross-ref |
| A | §4.3 / instrument §3 | 🟡 Pre-pilot | Open | Q3 wording decision → OSF amendment |
| B | §4.3 / instrument §4 | 🟡 Pre-pilot | Open | Q4 wording + foil (d) → OSF amendment |
| C | §4.3 / pre-reg §5.2 | 🟡 Pre-pilot | Open | Q3 clarification baseline vs. amendment-only |
| O | §4.2 line 258 | 🟡 Pre-pilot | Disclosure in paper ✅; Amendment 5 drafted | File Amendment 5 before pilot launch |
| 1 | - | 🟢 Prolific launch | Open | OSF upload (3 files + 4-5 amendments) |
| 2 | - | 🟢 Prolific launch | Open | Create Qualtrics survey |
| 3 | - | 🟢 Prolific launch | Open | Deploy stimuli + set completion codes |
| 4 | forum post | 🔵 Post-upload | Open | Insert OSF DOI after upload |
| 5 | piup-study-arc-post-draft.md | ⚪ Anytime | Open | Jony reviews; do not publish from heartbeat |
| 6 | - | ⚪ Anytime | Open - artifact ready (b828bc6) | Deploy contract to v5 testnet |
| 7 | Thursday Talks drafts | ⚪ Anytime | Open - all 3 posts cleared tick-3815 | Jony reviews; do not publish from heartbeat |
| 8 | Email Sauvik Das | ⚪ Anytime | Open - reminder set 2026-09-15 | Send after OSF DOI live |
| F | §1.4/§2.2 | ✅ RESOLVED | tick-3766 commit 7cad392 | - |
| S | §6.3 line 417 | ✅ RESOLVED | tick-3899 - 'most' → 'many' (Leon et al. 2012) | - |
| Abstract | Abstract | 🔴 CHI formatting | Open - ~261 words, limit ~150 | Trim before submission |

**Open count:** 12 open JONY-ACTIONs (G, I, J, N, P, Q, R, [verification URL], Das, A, B, C + O partially done) + 3 Prolific launch + 4 post-upload/anytime. J ordering RESOLVED tick-3876 (E&S-first confirmed tick-3991); J awaiting Jony pre-CHI RETAIN confirmation (low-blocking). (H RESOLVED tick-3994; L RESOLVED tick-3990; M RESOLVED tick-3989; U RESOLVED tick-3988; T RESOLVED tick-3987; X RESOLVED tick-3986; W RESOLVED tick-3985; V RESOLVED tick-3984.)

**Critical path (unchanged):** Contract deploy (#6) → [verification URL] filled → paper §2.1 + forum post unblocked. OSF decisions A-E (#I) → upload + amendments (#1) → OSF DOI → forum post + email Das. CHI submission sprint: add Q (IRB), add R (mechanism), confirm G, clear Das, clear N; J (confirm W&T retain - recommendation in paper). O partially done.

_Last updated: tick-3995 (2026-06-27). JONY-ACTION N RESOLVED tick-3995: Lee and See (2004) dropped from line 395 co-citation (option a); [Fixed tick-3995] annotations added at line 395 and bibliography entry. Lee and See now used once (line 399, clean). Open: J (confirm W&T), I (A/B/C pending Jony + OSF), G (confirm option-b), (Das), A, B, C, O, P, Q, R + [verification URL] (11 items). N RESOLVED tick-3995; H RESOLVED tick-3994; L RESOLVED tick-3990; M RESOLVED tick-3989; U RESOLVED tick-3988; T RESOLVED tick-3987; X RESOLVED tick-3986; W RESOLVED tick-3985; V RESOLVED tick-3984._
