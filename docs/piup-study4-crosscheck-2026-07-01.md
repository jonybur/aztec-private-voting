# PIUP Study 4 — Pre-Registration Cross-Check Report

**Date:** 2026-07-01 (tick-4390)
**Author:** OpenClaw Agent
**Purpose:** Systematic cross-check of `piup-study4-osf-prereg-2026-07-01.md` against `piup-study4-temporal-coercion-vignette-2026-07-01.md` and `qualtrics-setup-guide-study4-2026-07-01.md`. Parallel to `docs/piup-study1-crosscheck-2026-07-01.md` and `docs/piup-study2-crosscheck-2026-06-30.md`.
**Result:** 6 gaps found. 1 critical (survey flow error), 2 moderate, 3 minor. Fixable items applied in tick-4390.

---

## Summary

| # | Severity | Location | Description | Fixed |
|---|----------|----------|-------------|-------|
| 1 | **CRITICAL** | Qualtrics guide §3 survey flow | `attention_fail = 1` branch placed before the Randomizer — fires before Block 6 where it is set. Branch will never trigger. | ✅ Branch position corrected in guide §3 |
| 2 | MODERATE | Pre-reg §5 | Attention check referenced in §4 ("see §5") but §5 has no Attention Check subsection — item undefined in the pre-reg document | ✅ §5 subsection added in pre-reg |
| 3 | MODERATE | Pre-reg §12 checklist | "Analysis script written and deposited on OSF" listed as required — no `piup-study4-analysis.R` exists in `analysis/` | ✅ `analysis/piup-study4-analysis.R` created in tick-4390 |
| 4 | MINOR | Pre-reg §3.3 vs. Qualtrics §7 | Vignette wording: pre-reg starts "Imagine a colleague…" / "Imagine your manager…"; Qualtrics drops "Imagine" prefix — technically a wording deviation | ✅ Pre-reg updated to match Qualtrics (drop "Imagine") + Amendment 4-A text drafted |
| 5 | MINOR | Pre-reg §3.4 | DV3 labelled "DV3 / attention filter" — misleading, since incorrect-DV3 answers are NOT excluded. The actual attention filter is the embedded Likert in Block 6. | ✅ Label fixed to "DV3 (comprehension check)" in §3.4 |
| 6 | MINOR | Pre-reg §8 | "Four static PNGs (one per cell)" — but the P factor (pressure level) appears only in vignette text, not in the stimulus image. D0P1 and D0P2 are visually identical; D1P1 and D1P2 are visually identical. 2 distinct visual stimuli, used for 2 cells each. | ✅ §8 clarified: 2 distinct visual stimuli, each used in 2 cells |

---

## Gap 1 — CRITICAL: Attention-fail branch placed before Randomizer (never fires)

### Qualtrics guide §3 survey flow (as-found):
```
[Embedded Data — top-level]
[Branch: attention_fail = 1]        ← ⚠️ HERE — before Randomizer
  → [Screen-out block]
[Randomizer — evenly present one of 4 branches]
[Block 1: Consent]
...
[Block 6: Moderator + covariates + attention check]
```

### Why this is wrong:
`attention_fail` is initialised to `0` in Embedded Data. It is only SET to `1` in the Branch after Block 6 (§9 of the Qualtrics guide: "After Block 6, add a Branch in Survey Flow: IF QR6_ATTN ≠ 7 → Set attention_fail = 1 → Jump to Screen-Out block"). The Branch at the top of the survey flow checks `attention_fail = 1` before any participant has had a chance to fail it — the check will always be false and the screen-out route will never be taken.

### Root cause:
The survey flow overview in §3 appears to have been written before the Block-6 post-processing logic was fully specified. The branch stub was included as a placeholder for the exclusion route without aligning its position with where the attention_fail flag is actually set.

### Fix applied (tick-4390):
Survey flow in §3 corrected to place attention-fail routing AFTER Block 6:

```
[Embedded Data — top-level]
[Randomizer — evenly present one of 4 branches]
[Block 1: Consent]
[Block 2: Cover story + receipt display]
[Block 3: Comprehension check (DV3)]
[Block 4: Vignette scenario]
[Block 5: Primary outcomes — DV1 then DV2]
[Block 6: Moderator + covariates + attention check]
[Branch: QR6_ATTN ≠ 7 → Set attention_fail = 1 → Screen-Out block]  ← correct position
[Branch: Q_TotalDuration < 180 AND attention_fail = 0 → Screen-Out block]
[Block 7: Debrief]
[End of Survey]
```

---

## Gap 2 — MODERATE: Attention check not defined in pre-reg §5

### Pre-reg §4 (as-found):
> "- Failed attention check (must select 'Strongly agree' on embedded item; **see §5**)"

### Pre-reg §5 (as-found):
Lists: DV1, DV2, DV3 (comprehension check), M1 (Technology self-efficacy), C1 (Prior voting app experience).  
No "Attention Check" subsection — the "see §5" reference is a broken cross-reference.

### Qualtrics guide §9:
Attention check is defined there: "For quality purposes, please select **Strongly agree** for this item" (1–7 Likert; correct response = 7; exclusion if QR6_ATTN ≠ 7).

### Fix applied (tick-4390):
Pre-reg §5 extended with a new "Attention Check" subsection after C1:
```
### Attention Check

**Item:** "For quality purposes, please select Strongly agree for this item."

**Scale:** 1–7 Likert (1 = Strongly disagree, 7 = Strongly agree)

**Correct response:** 7 (Strongly agree).

**Exclusion:** Participants who do not select 7 are excluded and replaced (§4).
```

---

## Gap 3 — MODERATE: No Study 4 analysis script

### Pre-reg §12 (as-found):
> - [ ] Analysis script written and deposited on OSF prior to data collection

### State of `analysis/` directory:
```
piup-study1-analysis.R
piup-study1-drycheck.R
piup-study2-analysis.R
piup-study2-drycheck.R
piup-study2-power-simulation.R
```
No `piup-study4-analysis.R`.

### Fix applied (tick-4390):
`analysis/piup-study4-analysis.R` created with:
- Exclusion flag derivation (attention check, completion time, comprehension sensitivity flag)
- Factor coding (D, P as factors)
- H4.2 primary: two-way ANOVA on DV1 (D × P), F-test + η² partial
- Simple effects within H4.2: one-tailed t-tests D1 vs. D0 within P1, D1 vs. D0 within P2
- H4.1: one-tailed t-test D1 vs. D0 (collapsed over P), Cohen's d
- H4.3: one-tailed t-test D1 vs. D0 on DV2, Cohen's d
- H4.4: moderated regression (D × P × M1 three-way interaction)
- Sensitivity analyses SA-1 (comprehension filter), SA-2 (M1 covariate), SA-3 (C1 covariate), SA-4 (ANCOVA M1+C1)
- Null result / TOST protocol (§7.3)

---

## Gap 4 — MINOR: "Imagine" prefix in vignette wording

### Pre-reg §3.3 P1 (as-found):
> "**Imagine** a colleague at work mentions they're trying to understand…"

### Qualtrics §7 P1 (as-found):
> "A colleague at work mentions they're trying to understand…" (no "Imagine")

### Pre-reg §3.3 P2 (as-found):
> "**Imagine** your manager calls you in and says…"

### Qualtrics §7 P2 (as-found):
> "Your manager calls you in and says…" (no "Imagine")

### Assessment:
The difference is minor (present-tense vs. "imagine" framing) and semantically equivalent — both convey a hypothetical scenario. However, the pre-reg is the canonical document; if the instrument deviates it should be logged.

### Fix applied (tick-4390):
Pre-reg §3.3 updated to drop the "Imagine" prefix — matching the Qualtrics instrument. Amendment 4-A text drafted:

> **Amendment 4-A — Vignette opening-word change (pre-data):** Vignette texts in instrument omit the "Imagine" prefix used in pre-reg §3.3. P1: "Imagine a colleague at work..." → "A colleague at work...". P2: "Imagine your manager calls you in..." → "Your manager calls you in...". Scenario meaning and hypothetical framing unchanged. No effect on DV1/DV2 scoring or hypotheses.

---

## Gap 5 — MINOR: DV3 mislabelled as "attention filter"

### Pre-reg §3.4 (as-found):
> "**Comprehension check (DV3 / attention filter).** 'Based on what you saw, did the receipt you received tell you or anyone else how you voted?' (Yes / No / Not sure). Correct answer: No."

### Why misleading:
Pre-reg §4 (exclusion criteria) is explicit: "Participants meeting any exclusion criterion are replaced." DV3 incorrect answers do NOT trigger exclusion — they are kept in the ITT sample and flagged for sensitivity analysis (§4, last paragraph: "not excluded from the primary analysis (intent-to-treat principle) but are flagged for a pre-registered sensitivity re-analysis"). The actual *attention filter* is the embedded Likert item (QR6_ATTN) in Block 6. Calling DV3 an "attention filter" in §3.4 contradicts its non-exclusion status in §4 and could confuse IRB reviewers.

### Fix applied (tick-4390):
§3.4 label changed: "DV3 / attention filter" → "DV3 (comprehension check)".

---

## Gap 6 — MINOR: Pre-reg §8 implies 4 distinct visual stimuli

### Pre-reg §8 (as-found):
> "**Stimuli:** Four static PNGs (one per cell), captured from `VoteReceipt.tsx` with the following props:
> - Cell D0: `<VoteReceipt voteCloseTimestamp={ts} />` (countdown, download enabled)
> - Cell D1: `<VoteReceipt temporalLock="lock" voteCloseTimestamp={ts} />` (countdown, download disabled + padlock)"

### Issue:
The pre-reg then lists only 2 prop configurations (D0 and D1), but opens with "four static PNGs (one per cell)" — implying 4 visually distinct images. The pressure factor P (P1=moderate, P2=high) appears only in the vignette text (Block 4), not in the stimulus image. D0P1 and D0P2 are therefore visually identical; D1P1 and D1P2 are visually identical. There are 2 distinct visual stimuli, each used in 2 cells (via different vignette routing).

### Fix applied (tick-4390):
§8 updated to clarify: "Two distinct visual stimulus variants (one per D condition), used in two cells each":

> "**Stimuli:** Two distinct visual stimulus variants (one per D condition), each used in two cells. Screenshots are captured from `VoteReceipt.tsx`; files are named by cell (`cell-D0P1.png`, `cell-D0P2.png`, `cell-D1P1.png`, `cell-D1P2.png`) for routing clarity, but D0P1 ≅ D0P2 (visually identical) and D1P1 ≅ D1P2 (visually identical). The pressure factor P is operationalised through the vignette text (Block 4 / §3.3), not through the stimulus image."

---

## Pre-pilot readiness checklist (post-crosscheck)

Status as of tick-4390:

- [x] Survey flow attention-fail branch position — ✅ **Fixed in Qualtrics guide §3**
- [x] Pre-reg §5 attention check definition — ✅ **Subsection added**
- [x] Analysis script — ✅ **`analysis/piup-study4-analysis.R` created**
- [x] Vignette "Imagine" prefix deviation — ✅ **Pre-reg updated; Amendment 4-A text drafted**
- [x] DV3 "attention filter" misleading label — ✅ **Label fixed in §3.4**
- [x] Stimulus PNG count clarified — ✅ **§8 updated**
- [ ] IRB approval — ⏳ **Jony-only**
- [ ] OSF pre-registration filed — ⏳ **Jony-only (after IRB)**
- [ ] Stimulus PNGs generated from VoteReceipt.tsx — ⏳ **Jony-only (render locally)**
- [ ] Amendment 4-A filed on OSF with pre-registration — ⏳ **Jony-only**

**Study 4 is implementation-complete and crosscheck-clean.** The remaining items before data collection are Jony-only: IRB submission, OSF registration (with Amendment 4-A), and stimulus PNG generation.

---

## Summary verdict

Study 4 materials are structurally sound. The critical gap (attention-fail branch position, Gap 1) is a Qualtrics implementation error that would have silently failed to exclude inattentive responders — caught and corrected before launch. The analysis script gap (Gap 3) is required by the pre-reg checklist and has been remedied. The remaining gaps are minor wording alignments with no effect on hypotheses, DVs, or analysis.

Estimated pre-pilot work remaining: **Jony only** — IRB submission, OSF filing, stimulus screenshot generation.

_Created: 2026-07-01 (tick-4390). Crosscheck scope: pre-reg §§1-13, design doc §§1-6, Qualtrics guide §§1-15._
