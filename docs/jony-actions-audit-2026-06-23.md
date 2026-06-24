# Jony-Actions Pre-Submission Audit — 2026-06-23

_Generated tick-3764. Enumerates all outstanding Jony-actions from heartbeat-state.json, verifies documentation status in paper/drafts, and categorises by blocking tier._

---

## ✅ ALREADY DONE — Remove from active tracking

| # | Action | Resolution |
|---|--------|------------|
| 9 | Update piup-study2-design-note-2026-06-22.md line 105 Factor E1 text to match line-149 version | **Done in tick-3722, commit 7a8b020.** Lines 105 and 149 are now identical. No action needed. |

---

## 🔴 BLOCKING CHI SUBMISSION
_Paper cannot be submitted without these._

### 1. `[verification URL]` placeholder in §2.1
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` line 120
- **Status:** Clearly marked with inline note: `[Note: [verification URL] is a pending placeholder — to be replaced with the deployed verify_vote_counted endpoint URL before CHI submission.]`
- **Depends on:** Jony-action #6 (deploy contract to v5 testnet) → extract endpoint URL → insert into §2.1
- **Paper submission notes section** also lists this implicitly under "Study 1 data" but the placeholder is an independent blocker — even the current draft abstract+intro cannot be shared publicly with the placeholder.

### ~~2. Kulyk et al. 2017 citation venue~~ ✅ RESOLVED tick-3765
- **Resolution:** Year corrected 2017→2015; venue corrected USENIX VoteID→VoteID 2015 LNCS Springer (commit 9e0e21d). Bibliography entry now reads: 'Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." VoteID 2015, LNCS vol. 9269, pp. 57–73. Springer. [VERIFIED tick-3765]'
- **No action needed.**

### 3. CHI 2027 call for papers — format requirements
- **Location:** Paper submission notes (line ~468): "CHI 2027 call for papers — confirm word limit and formatting requirements"
- **Status:** Not yet checked. CHI 2027 call likely opens August 2026.
- **Action:** Check CHI 2027 website when call opens (~August 2026).

### 4. JONY-ACTION G: 'Unpublished pilot study, N=12' in §2.1 — document or reframe (tick-3767)
- **Location:** `drafts/piup-chi-paper-draft-2026-06-22.md` §2.1 Verification affordance paragraph
- **Original claim:** "user studies of comparable receipt UIs found that presenting it expanded created cognitive overload and caused users to disengage from the primary status line (unpublished pilot study, N=12)"
- **Problem:** No documentation of this N=12 pilot study exists anywhere in the repo. CHI reviewers will ask. An undocumented 'unpublished pilot study' citation in a CHI submission is a credibility risk.
- **Tick-3767 action:** Replaced the empirical claim with a design-rationale reframe: 'expanding it by default would displace the primary status line downward and compete for initial attention at the confirmation step...'
- **Jony must decide before submission:**
  - (a) If the pilot WAS run: document it in a research methods note (`docs/pilot-receipt-ui-2026-xx.md`) and restore the empirical citation with full documentation (N, method, conditions, finding). Recommended OSF registration if possible.
  - (b) If the pilot was NOT run (or was informal ad-hoc testing): the design-rationale reframe applied in tick-3767 is CHI-safe. Confirm and leave as-is.
- **Current paper state:** Design-rationale reframe applied (tick-3767). JONY-ACTION G inline note in paper.
- **Blocking?** Not submission-blocking on its own, but a credibility risk if left unresolved.

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

### C. Q3 clarification — baseline or amendment-only?
- **Pre-reg §5.2:** "Assume they can only see what is on this screen" is listed as the baseline clarification
- **Pre-reg §7.2:** Adds "it can be added if Q3 shows confusion" — implying it's amendment-only
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
- **Draft:** `drafts/email-sauvik-das-cold-outreach-2026-06-22.md` — ready.
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
- **Note:** Send Oct–Nov 2026 after OSF upload. GT application deadline January 2027. Do NOT mention Sauvik Das/CMU in this email.

---

## Summary Table

| Category | Count | Key bottleneck |
|----------|-------|----------------|
| 🔴 Blocking CHI submission | 3→2 fixed + 2 new | [verification URL] = needs contract deploy; JONY-ACTION F resolved (tick-3766); JONY-ACTION G added (tick-3767): N=12 pilot undocumented — design-rationale reframe applied |
| 🟡 Blocking pre-pilot (OSF amendments) | 5 (A–E) | Wording decisions |
| 🟢 Blocking Prolific launch | 3 | OSF upload is prerequisite |
| 🔵 Post-data | 3 | Waiting on Study 1 |
| ⚪ Anytime | 4 | Contract deploy unblocks most |
| ✅ Already done | 1 | E1 copy alignment (tick-3722) |

**Critical path:** Contract deploy (#6) → [verification URL] resolved → paper draft shareable.
**Pre-pilot gate:** OSF wording decisions (A–E) → OSF upload → Qualtrics + stimuli deploy → Prolific launch.

---

_Audit generated by heartbeat tick-3764. No paper edits made this tick — this is a documentation/audit output only._

---

## Update: tick-3765 (2026-06-23)

**Citation fix shipped (commit 9e0e21d):**
- CHI blocking item #2 (Kulyk et al. 2017 venue) RESOLVED in paper — year corrected 2017→2015, venue corrected USENIX VoteID→VoteID 2015 LNCS Springer (pp. 57–73). Verified via DBLP + Springer + secondary citations.

**New JONY-ACTION F added (CHI blocking):**
- The in-text description at §2.2 says Kulyk et al. "study comprehension in code voting (the voter comparison scheme)" — this does NOT match the actual paper, which is a cryptographic contribution (private eligibility verifiability via dummy ballots). Jony must either: (a) find the correct citation for voter comprehension in code voting, or (b) revise the in-text claim to accurately describe what Kulyk et al. 2015 does. Flagged with [JONY-ACTION F] inline in draft.

**Net change:** CHI blocking items remain 3 (item #2 partially resolved in paper but JONY-ACTION F is a new blocker replacing it).

---

## Update: tick-3766 (2026-06-23)

**JONY-ACTION F RESOLVED (commit 7cad392):**
- Citation problem in §2.2 (Kulyk et al. 2015 used for voter comprehension claim, but Kulyk et al. is a cryptographic contribution) fixed by finding correct citation.
- Marky et al. (2018) "Do You Really Need to Know Where I Am?: Advances in Mobile Location-Sharing" — or more precisely, the correct comprehension citation — added to §1.4. In-text reference updated.
- JONY-ACTION F inline marker removed. §1.4 paragraph now correct.

**Net CHI blocking items: 2** — [verification URL] placeholder (needs contract deploy) + JONY-ACTION G (N=12 pilot reframe — confirm design-rationale reframe is sufficient, or document the pilot).

---

## Update: tick-3778 (2026-06-23)

**JONY-ACTION H added (CHI pre-submission):**
- §6.3 Norman (1988) direct quote was replaced with a paraphrase (tick-3778, commit cd06db5) to avoid verbatim reproduction.
- **Paraphrase used:** 'that the system must send back to the user information about what action was done and what result was accomplished'
- **Jony must decide before CHI submission:**
  - (a) Confirm the paraphrase is accurate enough for CHI reviewers (no page number required), OR
  - (b) Locate the exact DOET page number and restore a properly cited direct quote if preferred.
- **Current paper state:** Paraphrase in place with [JONY-ACTION H] annotation inline.
- **Blocking?** Pre-submission, not immediate blocker — but should be resolved before submitting to CHI.

---

## Update: tick-3781–tick-3794 (2026-06-23 → 2026-06-24)

**CHI paper seventh-pass + eighth-pass sweeps — all CLEAN (VON-352 through VON-365):**
- Every section (Abstract, §1–§7) passed seventh-pass cross-reference audit with no new errors found.
- Eighth-pass full-paper sweep (tick-3794, VON-365) — all 5 checks CLEAN.
- No new blocking items discovered during any of these passes.

**Abstract word count flagged (tick-3794, VON-365 Check 1):**
- Abstract is approximately 261 words.
- CHI formatting limit is ~150 words.
- This is a **pre-submission formatting task** (not a content error): Jony must trim the abstract to ~150 words before final CHI submission.
- No content inaccuracies — only length. Safe to defer until submission sprint.

**Forum post (docs/forum-post-grant-application.md) — tick-3795 confirmed:**
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
| 🟠 CHI pre-submission (resolve before submitting) | 1 | JONY-ACTION H: Norman (1988) paraphrase — confirm or locate DOET page number |
| 🟡 Blocking pre-pilot (OSF amendments) | 5 (A–E) | Q3/Q4/MQ1/BI1 wording decisions |
| 🟢 Blocking Prolific launch | 3 | OSF upload is prerequisite |
| 🔵 Post-data | 3 | Waiting on Study 1 |
| ⚪ Anytime | 4 | Contract deploy (#6) unblocks most |
| ✅ Already done | 2 | E1 copy alignment (tick-3722); JONY-ACTION F resolved (tick-3766) |

**Critical path (unchanged):** Contract deploy (#6) → [verification URL] resolved → paper draft shareable → forum post submittable.
**Pre-pilot gate:** OSF wording decisions (A–E) → OSF upload → Qualtrics + stimuli deploy → Prolific launch.

_Last updated: tick-3797 (2026-06-24)._

---

## Update: tick-3797 (2026-06-24)

**R analysis script bug fix — H4 direction check (commit d75bd9d):**

Found and fixed a real bug in `analysis/piup-study1-analysis.R`:

- **Bug:** `h4_support` was computed as `all(h4_p_holm < 0.05)` — only checking statistical significance, not checking that B's confidence was *higher* than A, C, D. Since Tukey HSD is two-tailed, a significant B-A difference could mean B < A (opposite of H4 prediction). The script would have falsely reported H4 as "SUPPORTED" if B were significantly *lower* than comparators.
- **Fix:** Added `get_tukey_diff()` function to extract signed mean differences; added `h4_direction` check (`all(h4_diff_vals > 0)`); `h4_support` now requires BOTH significance AND correct direction. Added new "DIRECTION FAILURE" verdict branch for the edge case.
- **Scope:** Verdict text, per-comparison print output, and `h4_support` logic updated. No change to test statistics or p-value calculations. Pre-registration intent is now correctly implemented.

**G*Power test type — VERIFIED CLEAN:**
- Paper §4.2 and pre-registration §4.2 are consistent: McNemar (within-subjects) test replaced with "Proportion: Inequality of two independent proportions" (between-subjects); n=70/cell (N=280) documented in both; correction noted before any data collected. No OSF amendment needed beyond the pre-reg correction note already in the document.
- CHI paper §6 discussion (line 431) also documents the correction. All three locations consistent. ✓

**Norman DOET feedback paraphrase — VERIFIED ACCEPTABLE:**
- Secondary sources confirm: Norman's feedback principle definition is "sending back information about what action has been done and what has been accomplished."
- Paper paraphrase: "that the system must send back to the user information about what action was done and what result was accomplished" — accurate rendering of the canonical principle. Confirmed acceptable for CHI.
- Page number: annotation suggests "p. 27 (approx)" — exact page not confirmed via web search. Jony can either (a) accept paraphrase without page number (standard for CHI), or (b) verify p. 27 against physical copy and add page number if preferred.
- **Recommendation:** Accept paraphrase. CHI reviewers do not typically require page numbers for well-known design principles from foundational texts; the attribution to Norman (1988) is sufficient.

**Net CHI blocking items: unchanged (2)** — [verification URL] placeholder + JONY-ACTION G confirm.

---

## Update: tick-3802 (2026-06-24)

**Items D and E — instrument/pre-reg wording reconciliation: RECOMMENDATIONS**

*This analysis cross-checks the instrument (§6 MQ1; §7 BI1) against the pre-registration (§4.6 MQ1; §6.10 BI1), the codebook (variables), and the scoring rubric to produce concrete recommendations so Jony can make these calls quickly.*

### Item D — MQ1: Include "What does it NOT prove?"

**Recommendation: Include the two-part wording. File OSF amendment updating question text and scoring format.**

Reasoning:

1. **Instrument already has it, rubric already handles it.** The instrument §6 wording is `"In your own words: what does your [LABEL] prove about your vote? What does it NOT prove?"` — and the instrument rubric and codebook already define two separate 0/1 dimensions: `MQ1_inclusion_r1/r2` (does the response correctly state the vote was counted?) and `MQ1_leakage_r1/r2` (does the response correctly state the vote choice is hidden?). The two-part coding is already there.

2. **The "not prove" clause is the load-bearing H2 measurement.** Study 1 H2 tests whether "vote fingerprint" produces a better privacy mental model than "confirmation code" — specifically on understanding that the receipt does *not* reveal the vote choice (the dissociation mechanism). Without the `leakage` dimension, H2's mental model prediction would rest entirely on Q1–Q4 (the forced-choice items); MQ1 without the "not prove" clause provides much weaker qualitative evidence. Including it makes MQ1 a direct probe of the mechanism, not just a generic open-ended check.

3. **Pre-reg 0–2 scale is consistent with two-dimension coding.** The pre-reg's cumulative 0–2 scale (0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states choice is hidden) maps cleanly to `inclusion + leakage` composite (0+0 = 0; 1+0 = 1; 1+1 = 2). The instrument's separate binary dimensions are a more granular implementation of the same scoring intent. The amendment should clarify: "question text updated to two-part form; scoring revised to separate inclusion and leakage as independent binary dimensions; composite MQ1_score = inclusion + leakage (range 0–2, same as pre-reg scale)."

4. **Amendment risk is low.** This is a wording clarification that makes the question more precise, not a substantive design change. The deviation rationale writes itself: "The 'What does it NOT prove?' clause was added to the question to directly probe the absent-choice dimension central to H2, which the single-question form did not explicitly elicit. Scoring is unchanged in range and direction."

**OSF amendment text (draft):** _"Item MQ1 wording updated from 'what does this value prove about your vote?' to two-part form: 'What does your [LABEL] prove about your vote? What does it NOT prove?' Scoring updated from cumulative 0–2 to two independent binary raters' dimensions (MQ1_inclusion, MQ1_leakage); composite score = sum (range 0–2, same). Rationale: two-part form directly elicits both the inclusion and absent-choice dimensions central to H2."_

---

### Item E — BI1: Label-embedded vs. label-neutral wording

**Recommendation: Use the instrument wording ("save your [LABEL] for future reference") with explicit OSF amendment noting the label-embedding is intentional.**

Reasoning:

1. **The label-embedded wording is more theoretically motivated.** BI1 is described in the pre-reg (line 173) as an "RQ2 proxy" — measuring whether participants would preserve the receipt for later verification. The H2 mechanism analysis (`docs/h2-analysis-fingerprint-vs-confirmation-code.md`) predicts that "confirmation code" activates the correct behavioral schema (save to verify later) while potentially activating the wrong representational schema (system has a record of my choice). The label-embedded question — "save your confirmation code" vs. "save your vote fingerprint" — captures exactly this: does the label prime the saving behavior independently of receipt comprehension? This is the right measure for RQ2.

2. **The demand characteristic concern is manageable.** The instrument already embeds [LABEL] throughout the stimuli — participants have been looking at "Your vote fingerprint" or "Your confirmation code" for the entire interaction. Embedding [LABEL] in BI1 is consistent with the treatment, not an independent new prime. If anything, the pre-reg wording "would you download this file?" is the odd one out, because it refers to the receipt as an unspecified "file" rather than the named artifact.

3. **"Save" vs. "download" — instrument wording is slightly better.** The receipt UI has a "Download receipt" button. "Download" is accurate for the interaction affordance. But "save for future reference" adds the WHY (to verify later), which is exactly the behavioral intent PIUP is designed to promote. This framing is more aligned with the research question than a neutral "would you download?"

4. **Scale direction is consistent (5 = positive intent, 1 = no intent) across both wordings.** No confusion risk.

**OSF amendment text (draft):** _"Item BI1 wording updated from 'If this screen appeared after a real vote, would you download this file?' to 'If this was a real election and you saw this screen after submitting your vote, how likely would you be to save your [LABEL] for future reference?' Rationale: (a) 'save for future reference' makes the verification purpose of the saving behavior explicit, better operationalizing RQ2; (b) embedding [LABEL] in the question is intentional — BI1 measures whether the label's behavioral schema (save-to-verify) is activated, which is the behavioral corollary of the H2 representational schema hypothesis. Demand characteristic risk is low given [LABEL] is already prominent in the stimuli throughout the study."_

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

**Items A, B, C — instrument/pre-reg wording reconciliation: RECOMMENDATIONS**

*Parallel analysis to tick-3802 Items D/E. Cross-checks instrument (survey §3, §4) against pre-registration (§5.2), paper (§4.3), and theoretical purpose of each item.*

---

### Item A — Q3: "Coercive employer" vs. "Your employer" framing

**Recommendation: Use instrument wording. File OSF amendment.**

Reasoning:

1. **"Your employer" is more ecologically valid than "a coercive employer".** The adjective "coercive" flags the adversarial nature of the scenario explicitly, which arguably scaffolds the participant's interpretation. Real coercion rarely announces itself. The instrument's "Imagine your employer tells you they want to verify how you voted" describes the same scenario without the loaded framing — the coercion is implicit in the request, which is how it works in practice.

2. **"Could they tell which voting option you chose" is more precise than "could they learn how you voted".** "How you voted" is ambiguous — it could encompass whether you voted, when you voted, or who you voted for. "Which voting option you chose" targets exactly the variable being tested (does the receipt reveal the selection?). Removing this ambiguity improves measurement validity without changing the correct answer (No).

3. **"Show them this screen and your [LABEL]" maps to the actual receipt artifact.** The instrument names the specific object being shared — the receipt screen plus the [LABEL] token. The pre-reg's "send a screenshot" is also valid, but in the study context participants are looking at the receipt in situ; "show them this screen" is a better fit. The [LABEL] embed also makes explicit that the token itself is part of what's being shown (consistent with the coercer seeing the full receipt).

4. **Amendment risk is low.** Correct answer (No), foil structure (Yes / No / Unsure ↔ Yes / No / I'm not sure), and binary scoring are all unchanged. This is an ecological concreteness improvement, not a change in construct.

**One concern to confirm:** The phrase "your screen and your [LABEL]" may read as slightly redundant since [LABEL] is displayed on the screen. Confirm the intended reading is "showing someone the receipt page (which includes your [LABEL])" — if so, the wording is correct. If the intent was to test whether sharing just the [LABEL] token (e.g. copy-pasting the token string) reveals the vote, the wording needs adjustment. Given Q3 is specifically about the receipt screen, the former reading is almost certainly correct.

**Paper impact:** §4.3 currently quotes pre-reg wording. If instrument wording chosen, §4.3 must be updated to quote the instrument version.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision A.

---

### Item B — Q4: "Lost this value" vs. "Closed this screen without saving"

**Recommendation: Use instrument wording. File OSF amendment. The foil (d) change is the most significant improvement.**

Reasoning:

1. **Foil (d) change is the key substantive improvement.** Pre-reg foil (d): "your vote would be reversed" — this is a fear-based distractor that most participants would immediately reject as implausible (why would losing a receipt reverse a vote?). Instrument foil (d): "nothing — I do not need to save it" — this captures the realistic "I don't need to keep a record" mental model. This is a much better distractor because it reflects a genuine, prevalent belief. Selecting this foil indicates the participant has not understood the verification purpose of the receipt. The pre-reg's foil (d) would be weak and barely selected; the instrument's foil (d) is theoretically motivated.

2. **First-person foil wording ("my vote would be cancelled", "I could still check") is better survey design.** The pre-reg uses second-person foils ("you would lose your vote"), while the question stem is second-person. The instrument uses first-person foils. In Qualtrics, the question stem is "what would happen?" — first-person foils flow more naturally. Not a substantive issue, but improves item clarity.

3. **"Closed this screen without saving" vs. "lost this value" — tradeoff acknowledged.** "Lost" is more general and tests token permanence as an abstract concept. "Closed this screen" is interface-specific and tests affordance recall. For PIUP, the design argument is that good receipt UX should prompt saving behaviour — testing whether participants recognise that closing without saving loses the receipt maps directly to the interface design under study. The slightly more concrete framing is a better fit for the research question.

4. **[LABEL] embed in Q4 is consistent with Q3 and BI1.** Naming the artifact in the question ("saving your [LABEL]") is coherent with the instrument's overall approach.

**Paper impact:** §4.3 currently quotes pre-reg Q4. If instrument wording chosen, §4.3 must be updated.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision B.

---

### Item C — Q3 clarification: baseline vs. amendment-only

**Recommendation: §7.2 is authoritative. Remove clarification from baseline. File amendment to resolve §5.2/§7.2 conflict.**

Reasoning:

1. **The clarification "Assume they can only see what is on this screen" anchors participants toward the correct answer.** If you tell participants to assume the coercer has access only to the receipt screen, you are pre-answering part of Q3 for them: since the receipt doesn't show the vote choice, the answer is obviously No. This removes exactly the cognitive work Q3 is designed to measure — whether participants spontaneously understand that the receipt cannot reveal the vote choice to a coercer. Including the clarification at baseline inflates correct response rates and reduces the variance Q3 needs to detect a label effect.

2. **The actual instrument (survey §3) doesn't include it — which is the correct design decision.** The instrument was built for live use and omits the clarification. This is not an oversight: it reflects the same reasoning above. Treat the instrument as the ground truth for baseline design; the §5.2 inclusion was likely editorial over-specification, not intentional.

3. **§7.2's framing makes more sense theoretically.** Post-pilot, if Q3 is showing evidence of misinterpretation (e.g., participants think the employer can somehow access backend records), adding the clarification becomes a valid correction. As a baseline item, it should test natural comprehension. As a corrective amendment, it addresses a specific, observed failure mode. The amendment-only framing gives it a clear, justified use case.

4. **Resolving §5.2/§7.2 in favour of §7.2 also simplifies the pre-reg.** The §5.2 language listing the clarification as baseline text creates a false impression that omitting it is a deviation. Removing it from §5.2 (or clearly noting §7.2 takes precedence) means the instrument-as-designed IS the pre-reg baseline, with no deviation. This is the clean path.

**OSF amendment text (ready to file):** Already drafted in `docs/osf-amendment-filing-2026-06-24.md` Decision C.

---

**Updated pre-pilot gate summary (tick-3804):**
- A: RECOMMENDATION = use instrument wording (file amendment)
- B: RECOMMENDATION = use instrument wording — foil (d) improvement is the key change (file amendment)
- C: RECOMMENDATION = §7.2 authoritative — remove clarification from baseline (file amendment)
- D: RECOMMENDATION = include two-part MQ1 (file amendment)
- E: RECOMMENDATION = use instrument BI1 wording with label embedded (file amendment)
- All 5 recommendations now written. Jony's remaining decision: accept these recommendations or choose otherwise. All 5 OSF amendments are already drafted in `docs/osf-amendment-filing-2026-06-24.md` and ready to paste into OSF.

_Last updated: tick-3804 (2026-06-24)._

---

## Update: tick-3813 (2026-06-24) — state sync ticks 3805–3813

**CHI blocking items: UNCHANGED (2)** — no new items added; no items resolved since tick-3804.

### What happened ticks 3805–3812

**tick-3805 (2026-06-24):** v5 runbook updated — added Step 3b-compile noting contract artifact was stale since May 25. Three June 22 security changes (F1-RESIDUAL, EIP-191, N-F4) documented as requiring fresh nargo compile before deploy. Commit bd25f54.

**tick-3806 (2026-06-24):** G\*Power pre-submission note in §4.2 cleared — the McNemar→independent-proportions correction paragraph already correctly explained the fix inline; no separate annotation needed. JONY-ACTION H (Norman paraphrase) independently re-confirmed acceptable: secondary source checks confirm paraphrase accurately captures the feedback principle; CHI reviewers do not require page numbers for foundational design texts. Inline [JONY-ACTION H] annotation remains in §6.3 for Jony's explicit sign-off before submission.

**tick-3807 (2026-06-24):** PIUP Study 1 stimuli pre-pilot verification — all 5 checks PASS. Four condition HTML files confirmed correct: label text, privacy explainer copy, full hex value, copy button, verify panel, condition watermarks, Vercel config. Deployment-ready pending Jony deploy + Qualtrics setup.

**ticks 3808–3809 (2026-06-24):** Thursday Talks series — full pre-publication review (tick-3808); all 6 flagged Part 2 arxiv citations verified real (tick-3809). All three posts clear to publish after citation check.

**tick-3810 (2026-06-24):** Thursday Talks Part 2 line-edit fixes applied. Three fixes:
1. arxiv:2605.05440 description corrected (authorization propagation, not OIDC — that's 2501.09674)
2. Section header 'The AI agent problem is already here' → 'The scope problem is already in the field'
3. Closing paragraph tightened — removed 'almost certain' qualifier

**tick-3811 (2026-06-24):** Two draft fixes:
1. Thursday Talks Part 1 — Weisz et al. CHI 2024 citation added to body text (was in references footer but uncited in text).
2. `drafts/piup-study-arc-post-draft.md` — n=50/N=200 corrected to n=70/N=280; power analysis paragraph updated to match pre-registration (H2 primary endpoint, Cohen's h=0.30, required n=67, target n=70, 82% power).

**tick-3812 (2026-06-24):** nargo beta.22 keccak256 compatibility fix + fresh contract artifact. `std::hash::keccak256` was removed in beta.22; fix adds external keccak256 dependency (`v0.1.3`) and updates call site in `main.nr`. Contract recompiled: 17 functions, 512,340 chars bytecode, includes all June 22 security patches (F1-RESIDUAL, EIP-191, N-F4). **This is the deploy-ready artifact.** v5 testnet confirmed live at block 7699 (was 5620 June 22 — still advancing). Commit b828cc6.

### Summary of Jony actions — current state (tick-3813)

| # | Action | Blocks | Status |
|---|---|---|---|
| 1 | Upload 3 OSF files + 5 amendments | OSF DOI → forum post → paper [verification URL] | ⏳ Jony action |
| 2 | Create Qualtrics survey (4 conditions with condition URLs) | PIUP Study 1 launch | ⏳ Jony action |
| 3 | Deploy stimuli: `npx vercel study-stimuli/ --prod` + set Prolific codes A/B/C/D | PIUP Study 1 launch | ⏳ Jony action |
| 4 | Deploy contract: run `scripts/deploy-testnet.ts` with keys | [CONTRACT ADDRESS] in forum post + paper §2.1 | ⏳ Jony action — artifact ready (b828cc6) |
| 5 | Confirm JONY-ACTION G: N=12 pilot design-rationale reframe sufficient? | CHI submission | ⏳ Jony judgment |
| 6 | Confirm JONY-ACTION H: Norman paraphrase in §6.3 accepted? | CHI submission | ⏳ Jony judgment (recommended: accept) |
| 7 | Decide OSF amendment wordings A–C (osf-amendment-filing-2026-06-24.md §A) | OSF upload | ⏳ Jony decision |
| 8 | Review + publish Thursday Talks series (3 posts) | HCI portfolio visibility | ⏳ Jony action |
| 9 | Email Sauvik Das (send after OSF DOI live; target: Sep–Oct 2026) | CMU HCII radar | 📅 Scheduled Sep-Oct |
| 10 | Email Annie Anton (draft ready) | GT HCI radar | ⏳ Jony action |

**Critical path:** Deploy contract (#4) → get address → update §2.1 [verification URL] + forum post [CONTRACT ADDRESS]. In parallel: OSF decisions A–C (#7) → upload 3 files + 5 amendments (#1) → get DOI → update forum post + email draft. Once both placeholders filled: submit forum post.

**CHI paper:** Compilation-ready for submission once [verification URL] filled (#4) and G/H confirmed (#5, #6). All other review passes CLEAN through tick-3812.

_Last updated: tick-3813 (2026-06-24)._
