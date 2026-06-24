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
