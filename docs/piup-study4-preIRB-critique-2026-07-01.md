# PIUP Study 4: Pre-IRB Design Critique

**Date:** 2026-07-01 (created); last updated tick-4415  
**Status:** Internal review — pre-IRB (issues 1, 3, 4, 7, 8, 9 resolved tick-4414; issues 5, 6 verified already present in pre-reg tick-4415; only Jony-only items 2 + 10 remain)  
**Author:** Tick-4414 automated review  
**Connects to:** `piup-study4-temporal-coercion-vignette-2026-07-01.md`, `piup-study4-osf-prereg-2026-07-01.md`, `piup-study4-debrief-script-2026-07-01.md`, `qualtrics-setup-guide-study4-2026-07-01.md`

This document records open questions, methodological vulnerabilities, and items that must be resolved before Study 4 can be submitted for IRB review. Issues are categorised by severity. It is a parallel document to `piup-study3-preIRB-critique-2026-06-30.md`.

---

## Summary table

| # | Severity | Location | Description | Status |
|---|----------|----------|-------------|--------|
| 1 | **🔴 HIGH** | Debrief script vs. Qualtrics guide §10 | Withdrawal option (Screen 4 of debrief script) is absent from the Qualtrics implementation. IRB requires a withdrawal mechanism. | ✅ Fixed tick-4414: Qualtrics guide §10 now implements full 5-screen debrief with QR7_WITHDRAW question |
| 2 | **🔴 HIGH** | Debrief script Screen 5 | IRB placeholders unfilled: `[PI name]`, `[PI email]`, `[Institution]`, `[IRB protocol number]`, `[IRB contact]`. Cannot be filed without these. | ⏳ Jony-only: placeholders annotated [FILL BEFORE IRB SUBMISSION] in guide §10 Screen 5 |
| 3 | **🔴 HIGH** | Debrief script Screen 4 | Confirmation email promise ("within 48 hours") is unimplemented — no automated mechanism. Either implement or replace with Prolific-native withdrawal protocol. | ✅ Fixed tick-4414: Email promise replaced with manual-contact wording ("contact [PI email] within 48h") in debrief script Screens 4, 6B, and administration notes |
| 4 | **🟡 MOD** | Qualtrics guide §10 vs. debrief script | Qualtrics §10 shows a simplified single-screen debrief; the IRB-reviewed debrief script has 5+ screens with Screen 4 (withdrawal), Screen 5 (privacy + contact), and Screen 6 (acknowledgment). The guide needs to implement the full debrief. | ✅ Fixed tick-4414: Qualtrics guide §10 rewritten with all 6 screens, QR7_WITHDRAW, embedded data fields, survey flow, and variable reference |
| 5 | **🟡 MOD** | Pre-reg §9 / design doc §10 | "Minimal risk" classification needs explicit justification for the high-pressure job-threat scenario (`pressure_cond = P2`). IRB reviewers will probe whether "threatening job security" in the vignette crosses into moderate-risk territory. | ✅ Already in pre-reg §9 (verified tick-4414): full justification including Egelman & Felt 2012 citation |
| 6 | **🟡 MOD** | Design / survey flow | DV3 (comprehension check: "did the receipt reveal your vote?") is administered in Block 3, before the vignette scenario in Block 4. Participants who correctly answer No may be primed to believe sharing is lower-risk, potentially attenuating DV1 (sharing intent) and the UI-lock effect. This ordering is probably unavoidable but must be flagged as a limitation. | ✅ Already in pre-reg §9 (verified tick-4414): sequencing note + limitation explanation added |
| 7 | **🟡 MOD** | Qualtrics guide §10 | "You were in **[Condition description — set from embedded data]**" — the mechanism for inserting this (Piped Text vs. Display Logic) is described but the field names for the debrief-string variable are not defined. IRB application will need exact Qualtrics variable references. | ✅ Fixed tick-4414: `receipt_label` and `pressure_label` embedded data fields defined in §10 with exact Piped Text syntax (`${e://Field/receipt_label}`) |
| 8 | **🟢 LOW** | Qualtrics guide §4 / design doc §8 | Page timer enforcement: guide says "participants cannot continue until the timer expires," but the JavaScript provided only shows a warning; it does not prevent advance by itself. If participants can still click Next, the 30-second minimum is not enforced. Qualtrics native Page Timer (Survey > Options > Timing) or a button-disable approach should be used. | ✅ Verified tick-4414: JavaScript already calls `this.disableNextButton()` on load and `enableNextButton()` after 30s — button is hard-disabled, not a soft warning. Guide §5 clarified to confirm this is intentional. |
| 9 | **🟢 LOW** | Pre-reg §4 exclusion criteria | Minimum viewing-time exclusion (< 30s on Block 2) and minimum completion-time exclusion (< 180s total) are both listed but the relationship is unclear. A participant who sat on the receipt screen for 31 seconds but completed everything else very fast could still trip the 3-minute total. The pre-reg should clarify that both are independent exclusion gates (either alone triggers replacement). | ✅ Already in pre-reg §4 (verified tick-4414): "The two timing criteria are independent — either alone triggers replacement; they are not joint criteria" |
| 10 | **🟢 LOW** | Amendment 4-A | Amendment 4-A ("Imagine" prefix removal) is logged in the pre-reg Amendment Log but has not been filed on OSF. Must be filed before data collection AND before IRB submission to keep the protocol documents in sync. | ⏳ Jony-only: OSF filing required before IRB submission |

---

## Issue 1 — 🔴 HIGH: Withdrawal option absent from Qualtrics implementation

### Background

`piup-study4-debrief-script-2026-07-01.md` defines a 5-screen debrief with Screen 4 presenting a formal data withdrawal option:

> "**Do you wish to withdraw your data from this study?**  
> - ◯ **No — I'm happy for my responses to be used.**  
> - ◯ **Yes — Please delete my data.** My responses will not be used."

This withdrawal option is a standard IRB requirement when any partial disclosure is used: participants must be given a genuine opportunity to withdraw after learning the study's true purpose.

### Problem

`qualtrics-setup-guide-study4-2026-07-01.md` §10 shows a single descriptive-text debrief block with no withdrawal question, no Screen 4, and no mechanism for flagging withdrawal intent. The guide ends with a redirect to the Prolific completion URL. IRB reviewers comparing the IRB application (which will reference the debrief script) against the Qualtrics survey structure will find the withdrawal mechanism missing.

### Required fix

The Qualtrics guide §10 must implement the full debrief script:

1. **Screen 1:** "What this study was really about" (can use the simplified §10 text).
2. **Screen 2:** Condition reveal with Display Logic per `ui_cond` + `pressure_cond`.
3. **Screen 3:** Hypothetical confirmation + partial-disclosure rationale.
4. **Screen 4:** Withdrawal question — multiple-choice item (`QR7_WITHDRAW`): "No — happy to continue" / "Yes — please delete my data."
   - Add embedded data: `data_withdrawal = ${q://QR7_WITHDRAW/ChoiceGroup/SelectedChoices}` (or set `data_withdrawal = 1` via Branch if response = "Yes").
   - Both branches proceed to completion code (do not block).
5. **Screen 5:** Privacy note + contact details (with filled-in IRB placeholders).
6. **Screen 6:** Acknowledgment checkbox + completion code.

**Researcher post-study action:** After data export, flag all responses where `data_withdrawal = 1` for deletion before analysis. This step must be documented in the data management section of the IRB application.

---

## Issue 2 — 🔴 HIGH: IRB placeholder fields unfilled in debrief script

### Problem

Screen 5 of the debrief script contains five unfilled placeholders:

```
> **Principal investigator:** [PI name]  
> **Email:** [PI email]  
> **Institution:** [Institution]  
> **IRB protocol number:** [IRB number]

You may also contact the IRB office directly at [IRB contact] ...
```

The IRB protocol number cannot be known before IRB submission, but all other fields (`[PI name]`, `[PI email]`, `[Institution]`, `[IRB contact]`) must be filled before the IRB application is submitted.

### Required fix

Fill in: PI name = Jony Bursztyn; PI email = [Jony's institutional email]; Institution = [affiliated institution]; IRB contact = [institution's IRB office]. Leave `[IRB number]` as a placeholder to be filled after approval; annotate clearly as "to be inserted post-approval."

---

## Issue 3 — 🔴 HIGH: Confirmation email promise is unimplemented

### Problem

Screen 4 of the debrief script says:

> "If you select 'Yes,' you will receive a confirmation email within 48 hours confirming that your data has been removed."

There is no mechanism described anywhere in the Qualtrics guide or the study protocol for:
- Collecting participant email addresses (Prolific studies do not expose these by default)
- Sending a confirmation email
- Tracking the status of data deletion

This promise is undeliverable as written. IRB reviewers may flag it as a false assurance, which is worse than no promise at all.

### Recommended fix (two options)

**Option A (simpler — recommended):** Remove the email confirmation promise. Replace with:

> "If you select 'Yes,' your Prolific ID will be flagged for exclusion from all analyses before the study dataset is finalised. To confirm your exclusion or ask questions, contact the PI at [PI email] citing your Prolific ID."

This is deliverable, honest, and standard for Prolific-based studies. Update the debrief script and Qualtrics guide accordingly.

**Option B (if an email mechanism is genuinely needed):** Add an optional email field to Screen 4 (after the withdrawal choice), explicitly marked as optional and used only for withdrawal confirmation. This adds participant data complexity and an additional GDPR-adjacent consideration for non-US participants. Not recommended unless IRB specifically requires it.

---

## Issue 4 — 🟡 MODERATE: Qualtrics guide §10 shows simplified debrief only

### Problem

The Qualtrics guide §10 implements a compressed single-screen debrief — essentially a minimal summary of what the study was about — rather than the full debrief script's 5-screen flow. When the IRB application is reviewed, the debrief text submitted to IRB (from the debrief script) and the Qualtrics implementation (from the guide) will not match. IRB reviewers may require consistency.

### Required fix

The Qualtrics guide should reference the debrief script explicitly as the canonical text:

> "The debrief is implemented across multiple Qualtrics screens as specified in `piup-study4-debrief-script-2026-07-01.md`. Screen 1 through Screen 6 map to the blocks described there. The debrief script is the IRB-reviewed version; do not use the abbreviated §10 text above as a substitute."

Then update the abbreviated §10 text to be a summary/reference, not an implementation spec.

---

## Issue 5 — 🟡 MODERATE: Minimal-risk classification needs explicit justification for P2

### Problem

The pre-reg §9 states: "Risk classification: Minimal risk." The design doc §10 notes: "IRB risk level: Minimal risk. No participant is actually exposed to employer pressure; scenario language is comparable to standard employment-vignette research."

The high-pressure vignette (P2) reads: "Your manager calls you in and says: 'We need to verify how our team voted on this issue. If you can't show me your vote receipt right now, I'll need to question your commitment to the team.' You still have the vote receipt screen open on your computer."

This scenario involves explicit job-threat framing. IRB reviewers at some institutions may require a more detailed justification for why this is minimal risk rather than more-than-minimal risk, particularly if the study population includes workers in precarious employment (e.g., gig workers on Prolific whose income depends on platform approval ratings).

### Required addition to pre-reg §9

Add the following justification paragraph:

> **Minimal-risk justification for high-pressure scenario (P2):** The job-threat scenario ("I'll need to question your commitment to the team") is delivered in hypothetical-present tense with explicit instructions that it is fictional. No participant is in an actual employment relationship with the study; no actual job consequences exist. The scenario language is calibrated to be stressful enough to engage a genuine coercion response (necessary for ecological validity) while clearly hypothetical. This is methodologically consistent with prior vignette research using employment-coercion scenarios in security and privacy contexts (Egelman & Felt, 2012). The Prolific study description and consent form describe the study as involving "a short workplace scenario"; participants self-select to continue. The study does not target people in specific vulnerable employment circumstances; no occupation filters are applied in Prolific. At most institutions, vignette research using hypothetical workplace scenarios qualifies for expedited review under the "no more than minimal risk" standard.

---

## Issue 6 — 🟡 MODERATE: DV3 before vignette creates comprehension-priming sequence

### Problem

The pre-registered survey flow places DV3 (comprehension check: "did the receipt tell you how you voted?") in Block 3, before the vignette scenario in Block 4. Participants who correctly answer DV3 as "No" have already confirmed the receipt does not reveal their vote. When they then read the vignette coercion scenario, they may frame their sharing-intent response (DV1) in light of this knowledge: "I know the receipt doesn't show how I voted, so sharing it is less risky."

This knowledge priming would operate **across both conditions** (D0 and D1), so it does not threaten internal validity for the D × P interaction (H4.2). However, it may attenuate the main effect of the UI-lock (H4.1) by lowering sharing intent in both conditions (if participants reason "sharing is safe anyway"). It also does not affect H4.3 (deniability belief).

### Assessment

This ordering is probably unavoidable. If the vignette is shown before DV3, participants would read the coercion scenario before seeing the receipt — dramatically reducing ecological validity. And if DV3 is omitted, you lose the pre-registered sensitivity analysis for comprehension filter. The current order (receipt → DV3 → vignette → DVs) is the best available sequence.

### Required action

Add a note to the pre-reg §9 (limitations) acknowledging this sequencing and its potential direction-of-effect on DV1:

> **Note on Block 3 → Block 4 sequencing:** DV3 (receipt-comprehension check) is administered before the vignette scenario. Participants who answer DV3 correctly may enter the vignette knowing the receipt does not reveal their vote, which could lower sharing intent in both conditions. This is a pre-specified limitation; it does not threaten the D × P interaction (H4.2) because the priming is constant across conditions, but may attenuate the H4.1 main effect by making sharing seem lower-risk before the adversarial pressure is introduced.

---

## Issue 7 — 🟡 MODERATE: Condition debrief Piped Text implementation not fully specified

### Problem

`qualtrics-setup-guide-study4-2026-07-01.md` §10 says the condition description is inserted via Qualtrics Piped Text, either through Display Logic on `ui_cond` + `pressure_cond` or via "a single question with Piped Text referencing an Embedded Data field set earlier to the debrief string." However, no embedded data field name for the debrief string is defined anywhere in the Qualtrics guide or the pre-reg. If Display Logic is used instead, this requires four separate Descriptive Text questions (one per condition) with Display Logic rules — which is fine but must be documented.

`piup-study4-debrief-script-2026-07-01.md` Screen 2 shows `[RECEIPT_TYPE]` and `[PRESSURE_TYPE]` as template placeholders with the note "*(Note: Qualtrics fills this in automatically.)*" The mechanism is referenced but not defined.

### Required fix

In the Qualtrics guide, make the condition-debrief implementation explicit. Recommended approach (Display Logic, simpler than Piped Text for this use case):

```
Block 7 — Debrief — Screen 2 contains four Descriptive Text items:
  Item 1: Display Logic: ui_cond = D0 AND pressure_cond = P1
    → "Your receipt: Option D (countdown, no lock). Your scenario: Moderate pressure (colleague)."
  Item 2: Display Logic: ui_cond = D0 AND pressure_cond = P2
    → "Your receipt: Option D (countdown, no lock). Your scenario: High pressure (manager)."
  Item 3: Display Logic: ui_cond = D1 AND pressure_cond = P1
    → "Your receipt: Option B (UI-lock). Your scenario: Moderate pressure (colleague)."
  Item 4: Display Logic: ui_cond = D1 AND pressure_cond = P2
    → "Your receipt: Option B (UI-lock). Your scenario: High pressure (manager)."
```

---

## Issue 8 — 🟢 LOW: Page timer enforcement may be advisory only

### Problem

The Qualtrics guide §4 states: "Participants who advance before 30 seconds see a warning and cannot continue until the timer expires." The provided JavaScript code shows a banner message but does not include a button-disable mechanism. Qualtrics' built-in `Qualtrics.SurveyEngine.preventForwardNavigation()` or button-enable logic would be needed to actually prevent advancing.

If the page timer is advisory only (warning, but participant can still click Next), then the pre-registered claim of a "minimum 30-second viewing time" may not be enforced in practice. Participants flagged by the `Q_TotalDuration < 180` criterion would still be excluded, but those who rushed through Block 2 in under 30s but completed the rest slowly may not be caught.

### Required fix

Add button-disable logic to the JavaScript snippet:

```javascript
// Disable Next button until 30 seconds have elapsed
var nextBtn = document.getElementById('NextButton');
if (nextBtn) nextBtn.disabled = true;
setTimeout(function() {
  var nextBtn = document.getElementById('NextButton');
  if (nextBtn) {
    nextBtn.disabled = false;
    // Optionally hide the warning banner
    var banner = document.getElementById('timerWarning');
    if (banner) banner.style.display = 'none';
  }
}, 30000);
```

Alternatively, use Qualtrics native Survey Timing to enforce minimum display time. Document which approach is used.

---

## Issue 9 — 🟢 LOW: Exclusion criteria for timing not fully disambiguated

### Problem

The pre-reg §4 lists two time-based exclusion criteria:

1. "Completed the receipt-display page in under 30 seconds" (Block 2 page timer)
2. "Completed the survey in under 3 minutes total (Q_TotalDuration < 180 seconds)"

These are two distinct exclusion paths, but the pre-reg does not state whether they are OR (either triggers replacement) or AND (both must be true). Given that the page timer (criterion 1) is enforced in Qualtrics to prevent advance, criterion 1 may not need to appear as a separate post-hoc exclusion — if the JavaScript enforcement works, no valid response should have Block 2 completion < 30s. Criterion 2 (total duration) is a catch-all.

### Required fix

Clarify in pre-reg §4:

> "**Exclusion criterion — Minimum viewing time:** Qualtrics enforces a 30-second minimum on the receipt-display page (Block 2); participants cannot advance before 30 seconds. This enforcement means post-hoc exclusion based on Block-2 page time is not expected to apply. If the page timer fails (due to browser JavaScript issues), the `Q_TotalDuration < 180` criterion catches most rapid completions. Both exclusions are independent and either alone triggers replacement; they are not joint criteria."

---

## Issue 10 — 🟢 LOW: Amendment 4-A not filed on OSF

### Problem

Amendment 4-A (vignette "Imagine" prefix removal) is logged in the pre-reg §11 Amendment Log with the note "Pre-data (noted; OSF filing pending before data collection)." It has not been filed on OSF as of this critique (tick-4414). IRB reviewers comparing the pre-reg text to the vignette instrument may notice the discrepancy between the pre-reg §3.3 and the Qualtrics survey flow (§7 in the Qualtrics guide) if the amendment has not been applied.

### Required fix

File Amendment 4-A on OSF with the pre-registration. The amendment text is already written (in the Amendment Log and in `piup-study4-crosscheck-2026-07-01.md` Gap 4). OSF filing is a Jony-only action.

---

## Items confirmed clean

The following items were audited and found satisfactory:

| Item | Status |
|------|--------|
| Attention-fail branch position (was critical in crosscheck) | ✅ FIXED — Branch placed after Block 6 in survey flow |
| Pre-reg §5 attention check definition | ✅ ADDED — Subsection present |
| Analysis script `piup-study4-analysis.R` | ✅ EXISTS — dry-check passes (all 9 sections, tick-4414) |
| DV3 label ("attention filter" → "comprehension check") | ✅ FIXED in §3.4 |
| Stimulus PNG count (4 cells = 2 visual variants) | ✅ CLARIFIED in §8 |
| "Minimal risk" classification for partial disclosure | ✅ PRE-REG CORRECT — cover story is partial, not false |
| Prolific completion code for withdrawn participants | ✅ COVERED — debrief Screen 4 states code is shown regardless of withdrawal |
| Comprehension check (DV3) exclusion policy | ✅ CORRECT — DV3 incorrect = flagged for SA, not excluded |
| IRB risk level for deception via partial disclosure | ✅ ACCEPTABLE — standard for behavioural vignette research |
| Power calculation (N=160, 40/cell, f=0.25, 86%) | ✅ CONSISTENT with design doc §4 and pre-reg §6 |
| Holm-Bonferroni policy: none across independent hypotheses | ✅ CORRECT per pre-reg §7.5 |
| TOST null-result protocol | ✅ SCRIPTED — verified in dry-check §9 |

---

## IRB readiness checklist (post-critique)

Items marked ⛔ must be resolved before IRB submission.

- ✅ Fix 1: Add withdrawal question to Qualtrics §10 implementation — **done tick-4414**
- ⛔ Fix 2: Fill IRB placeholders in debrief script Screen 5 — **Jony-only** (annotated [FILL BEFORE IRB SUBMISSION])
- ✅ Fix 3: Replace confirmation-email promise with Prolific-native deletion protocol — **done tick-4414**
- ✅ Fix 4: Align Qualtrics guide debrief implementation with full debrief script — **done tick-4414**
- ✅ Fix 5: P2 minimal-risk justification — **already present in pre-reg §9** (verified tick-4415; false positive in original critique)
- ✅ Fix 6: DV3-priming sequencing note — **already present in pre-reg §9** (verified tick-4415; false positive in original critique)
- ✅ Fix 7: Specify Display Logic / Piped Text for condition debrief text — **done tick-4414** (`receipt_label`/`pressure_label` fields + Piped Text syntax defined)
- ✅ Fix 8: Add button-disable logic to page timer JavaScript — **done tick-4414** (`disableNextButton()` on load confirmed hard block)
- ✅ Fix 9: Clarify timing exclusions are independent OR gates in pre-reg §4 — **done tick-4414** (independence clause verified present)
- ⛔ Fix 10: File Amendment 4-A on OSF — **Jony-only** (must file before IRB submission and data collection)
- ⬜ IRB application: submit to relevant institution (GT/CMU) after above items addressed — **Jony-only**

**⛔ = must fix before IRB submission**  
**⬜ = should fix; study could proceed without but IRB may request**

**CURRENT STATE (tick-4415): 9/11 items complete. Remaining blockers are both Jony-only: Fix 2 (IRB contact info) and Fix 10 (OSF Amendment 4-A filing). All agent-fixable items are done.**

---

## Summary verdict

Study 4 is methodologically sound and the core design (2×2 vignette, DV1/DV2, H4.1-H4.4, analysis pipeline) is clean. All agent-fixable pre-IRB items are now resolved:

- Withdrawal mechanism fully implemented in Qualtrics (QR7_WITHDRAW + branch + embedded data)
- Full 6-screen debrief in Qualtrics guide §10 (aligns with IRB debrief script)
- Email promise removed; manual-contact wording used throughout
- receipt_label + pressure_label Piped Text fields defined with exact Qualtrics syntax
- Button-disable JavaScript confirmed hard-blocking (not advisory)
- Timing exclusions confirmed independent OR gates in pre-reg §4
- P2 minimal-risk justification present in pre-reg §9 (was already there before critique; not a new omission)
- DV3-priming sequencing limitation present in pre-reg §9 (was already there before critique; not a new omission)

**Remaining (both Jony-only):**
1. **Fix 2 (⛔ CRITICAL):** Fill IRB contact fields — PI name, email, institution, protocol number, IRB contact — in Qualtrics guide §10 Screen 5 (currently annotated [FILL BEFORE IRB SUBMISSION])
2. **Fix 10 (⛔ CRITICAL):** File Amendment 4-A on OSF before IRB submission and data collection

Once Fixes 2 and 10 are complete, Study 4 is ready for IRB submission.

_Created: 2026-07-01 (tick-4414). Last updated: tick-4415 (Issues 5+6 verified already-present; checklist finalised). Based on audit of: pre-reg §§1-12, design doc §§1-13, debrief script Screens 1-6, Qualtrics guide §§1-15, Study 4 dry-check (all 9 sections PASS, tick-4414)._
