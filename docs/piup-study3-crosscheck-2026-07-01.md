# PIUP Study 3 — Pre-Registration Cross-Check Report

**Date:** 2026-07-01 (tick-4429)  
**Author:** OpenClaw Agent  
**Purpose:** Systematic cross-check of `piup-study3-osf-prereg-2026-07-01.md` against `analysis/piup-study3-analysis.R`, `analysis/piup-study3-drycheck.R`, `docs/piup-study3-debrief-script-2026-06-30.md`, and `drafts/piup-chi-paper-draft-2026-06-22.md` §7. Parallel to `docs/piup-study1-crosscheck-2026-07-01.md` (5 gaps found) and `docs/piup-study2-crosscheck-2026-06-30.md` (5 gaps found).  
**Result:** 4 gaps found. 1 critical (already fixed), 2 moderate, 1 minor.

---

## Summary

| # | Severity | Location | Description | Fixed |
|---|----------|----------|-------------|-------|
| 1 | **CRITICAL** | Pre-reg §4 | §4 says "Study 3 is embedded in the same election as Study 2" — directly contradicts §9 (corrected tick-4427), which accurately states Studies 2 and 3 use different paradigms and cannot share an election | ✅ Fixed in tick-4429 — §4 Population rewritten |
| 2 | MODERATE | Pre-reg §5 / DV3 | DV3 (verification comprehension) item wording not specified; "abbreviated Q1–Q4 rubric adapted from Study 1" with no actual question text, no composite scoring rule | ⏳ Jony decision required — see Gap 2 |
| 3 | MODERATE | Pre-reg §5 / DV3 | DV3 scoring rule not defined — analysis script treats `dv3_comprehension` as a single 0/1 binary column; pre-reg says "Q1–Q4 composite" but gives no composite specification | ⏳ Jony decision required — see Gap 3 |
| 4 | MINOR | Pre-reg §1 inline citation | "Das et al., 2014, CCS: password manager adoption via peer-count display" — paper title and topic may be imprecise; actual title is "Increasing security sensitivity with social proof: A large-scale experimental confirmation" (security behaviors broadly, not specifically password-manager adoption) | ✅ CONFIRMED NOT AN ISSUE — see Gap 4 |

---

## Gap 1 — CRITICAL (FIXED tick-4429): §4 vs §9 inconsistency about Study 2 embedding

### The problem

**§4 Population (pre-fix):**
> "Study 3 is embedded in the same election as Study 2; participants overlap with the Study 2 pool. No additional recruitment is required beyond the Study 2 election."

**§9 (corrected tick-4427):**
> "Because Study 2 uses a simulated Vercel prototype and Study 3 requires a live contract deployment, they cannot be embedded in the same election."

§9 was rewritten at tick-4427 to correctly reflect the paradigm difference: Study 2 is a controlled Vercel prototype (consequentially inert votes; Prolific participants) while Study 3 is a live-election field experiment (real votes; real DAO participants). These studies cannot share an election because one uses a fake prototype and the other uses a real deployed contract.

§4 was not updated at tick-4427. An OSF reviewer reading §4 would conclude Study 3 reuses the Study 2 pool; reading §9 they would conclude the opposite. The contradiction would flag the pre-reg as internally inconsistent.

### Root cause

§9 was the only section addressed by tick-4427's amendment. §4's Population section retained the stale description from the original pre-reg design (when Study 2 was conceived as a field experiment, before it was redesigned as a controlled Vercel prototype).

### Fix applied (tick-4429)

§4 Population rewritten to:
- Remove "embedded in the same election as Study 2; participants overlap with the Study 2 pool"
- State: "separate from Study 2; see §9"
- Clarify that participants are real DAO voters (no Prolific)
- Add pre-data amendment note consistent with §9's amendment record

Amendment logged inline as pre-data, pre-OSF; no hypothesis, DV, or analysis change.

---

## Gap 2 — MODERATE: DV3 item wording absent from pre-reg

### The problem

**Pre-reg §5 DV3 definition:**
> "Abbreviated Q1–Q4 rubric adapted from Study 1 (L2 context-shift note: in Study 1, Q1–Q4 measure label-level privacy mental models; here the rubric is adapted to measure comprehension of verification purpose — whether the participant correctly understands that verifying confirms counting but not vote content). Labelled 'adapted' in all study materials. Predicted null condition difference."

This description gives the construct but not the items. Study 1 pre-reg §5.2 provides the full wording for each of Q1–Q4 (8–20 words per item, with foils). The Study 3 pre-reg gives no question text for the adapted items.

### Why it matters

- An OSF reviewer will note the absence of item wording and ask for it.
- "Adapted Q1–Q4 rubric" is not a complete specification: the Study 3 context (verification comprehension) differs significantly from Study 1's context (receipt label + privacy mental models). The adaptation from label-effect questions to verification-purpose questions is non-trivial.
- The analysis script uses `dv3_comprehension: integer 0 | 1` as a pre-collapsed binary column — this assumes the adaptation has already been specified and scored, but the pre-reg never defines what "correct" means for the adapted items.
- Without item wording in the pre-reg, Jony cannot build the T+14 survey instrument for Study 3 without making undocumented decisions.

### Required fix

**JONY-DECISION: Specify DV3 adapted items before OSF filing.**

Two options:

**Option A — Add full item wording to pre-reg §5 (recommended)**  
Specify each of the 4 adapted items with question text, foils, correct answer, and scoring rule (e.g., "1 if all 4 items correct; 0 otherwise" or "1 if ≥3 of 4 correct"). Reference Study 1 §5.2 for the original items and note which changes were made (e.g., "vote fingerprint" label omitted; "verify" meaning adapted). Log as pre-data amendment if OSF filing has already begun.

Example adapted item set (for Jony's review — NOT the pre-specified items; Jony must confirm these):

| Item | Adapted question (Study 3) | Study 1 original (Q1–Q4) | Correct |
|------|---------------------------|--------------------------|---------|
| DV3-1 | Does the verification function confirm that your vote was counted? | Q1 (inclusion recognition) | Yes |
| DV3-2 | If you share your receipt ID with a third party, can they learn how you voted? | Q2 (choice-blindness inference) | No |
| DV3-3 | If someone asked you to show them your receipt, could they learn which option you chose? | Q3 (coercion scenario) | No |
| DV3-4 | What does successful verification prove? | Q4 (functional understanding) | Counting, not choice |

**Option B — Reference a named instrument doc (if a separate DV3 instrument exists)**  
If a T+14 survey instrument for Study 3 exists (analogous to `piup-study1-survey-instrument-2026-06-22.md`), create that document and reference it in §5 as the DV3 source. The pre-reg should either contain the items or point to a committed file.

**Action:** Before OSF filing, add DV3 item wording to §5 or create a Study 3 T+14 instrument document. Without this, the DV3 measurement is underspecified.

---

## Gap 3 — MODERATE: DV3 composite scoring rule not defined

### The problem

DV3 is described as "Q1–Q4 composite accuracy" but:
- The pre-reg does not specify whether "correct" on DV3 requires all 4 items correct (strict composite), a majority, or a single key item
- The analysis script uses `dv3_comprehension: integer 0 | 1` as a single pre-collapsed binary — consistent with a strict composite (all-correct = 1) but not stated
- Pre-reg §7.5 says "χ² test on Q1–Q4 composite accuracy (DV3) across conditions" — this refers to the composite as a single binary endpoint, but without a scoring rule the composite is undefined

### Required fix

**JONY-DECISION: Specify the DV3 composite scoring rule.**

Recommended: "A participant is coded DV3 = 1 if all 4 adapted Q1–Q4 items are answered correctly; DV3 = 0 otherwise." This matches the analysis script's binary treatment of `dv3_comprehension` and parallels Study 1's composite accuracy definition.

If a majority rule is preferred (≥3 of 4 correct = 1), update the analysis script accordingly.

Add the scoring rule to §5 DV3 definition. This can be a one-sentence addition; log as part of the item-wording amendment (Gap 2 fix) if filing together.

---

## Gap 4 — MINOR (NOT AN ISSUE): Das et al. CCS '14 inline description

### Investigation

**Pre-reg §1 says:**  
"Das et al., 2014, CCS: password manager adoption via peer-count display"

**Reference entry (§12):**  
"Das, S., Kramer, A. D. I., Dabbish, L. A., & Hong, J. I. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. In *Proceedings of the 21st ACM Conference on Computer and Communications Security (CCS '14)* (pp. 739–749). ACM."

The inline description "password manager adoption via peer-count display" is a simplified characterisation. The paper covers security-sensitivity broadly (including password manager adoption) via peer-count social proof. The core claim — that peer counts displayed to users increase security behaviour adoption — is accurately characterised. The authorship (Das, Kramer, Dabbish, Hong — not Kim) was verified at tick-4338.

**Verdict:** Not a material error. The inline description is a reasonable abbreviation of the paper's scope. The reference entry is correct and the CCS venue is verified. No fix required.

---

## Items confirmed correct (no issues)

| Item | Status |
|------|--------|
| Counter floor value: ≥5 in pre-reg §3.2 and §7.7 | ✅ Matches analysis script lines 119, 124, 431–438 (quality check tick-4401/4408) |
| §7.8 DV2 timing heterogeneity SA-3 | ✅ Added to pre-reg and analysis script at tick-4408 |
| SA-1 (partial verifiers recoded as 0) | ✅ Pre-reg §7.2 matches analysis script §3 |
| SA-2 (per-protocol opt-in log subsample) | ✅ Pre-reg §7.3 matches analysis script §4 |
| Exploratory self-efficacy moderation (§7.4) | ✅ Pre-reg RQ3a matches analysis script §6 (tertile split if p < .10) |
| KM threshold: ≥40 log opt-ins (§7.6) | ✅ Pre-reg §7.6 matches analysis script §8 |
| Manipulation failure protocol (§7.7) | ✅ Pre-reg §7.7 matches analysis script §10 |
| 90% CI inferential framework (no NHST threshold) | ✅ Consistent across pre-reg §6 table and analysis script §2 |
| Cialdini (1984) citation | ✅ Full reference in §12 references; correctly cited in §1 and §3.2 |
| Das CCS '14 authorship (Kramer, not Kim) | ✅ Verified tick-4338; pre-reg §12 uses correct authorship |
| Nissen et al. (2025) citation | ✅ Included in §12 references; quality check confirmed (tick-4401) |
| Pre-reg §9 Study 2/3 paradigm separation | ✅ Corrected tick-4427 |
| Analysis script drycheck (all 8 sections PASS) | ✅ Committed at `624d92e` (tick-4406); verified tick-4407 |

---

## Pre-pilot gate status (Study 3)

| Gate item | Status |
|---|---|
| Analysis script drycheck | ✅ PASS (tick-4407) |
| §4 Population inconsistency | ✅ Fixed tick-4429 |
| Counter floor alignment | ✅ RESOLVED (tick-4408) |
| DV2 timing heterogeneity (SA-3) | ✅ Pre-specified (tick-4408) |
| DV3 item wording | ⏳ PENDING — Jony must specify adapted items and scoring rule before OSF filing |
| T+14 survey instrument (Study 3) | ⏳ PENDING — no instrument document exists yet; needed for DV3, DV4, C1 |
| Study 2 pre-reg filed on OSF | ⏳ Jony-only prerequisite (per registration checklist) |
| Study 1 H4 outcome | ⏳ Needed to calibrate Study 3 voter pool estimate |
| OSF pre-registration upload | ⏳ Pending above fixes + study 2 sequencing |

**Current state (tick-4429): Critical §4 gap fixed. Remaining blockers:**
1. **Gap 2 + 3 (MODERATE):** DV3 item wording and scoring rule — Jony must specify before OSF filing
2. **T+14 instrument:** No Study 3 survey instrument document exists (analogous to `piup-study1-survey-instrument-2026-06-22.md`)
3. **Sequencing:** Study 1 pilot → Study 2 pre-reg filed → Study 3 pre-reg filed

---

_Created: 2026-07-01 (tick-4429). Based on audit of: pre-reg §§1–12, analysis script (470 lines), drycheck script (586 lines), debrief script Screens 1–4, CHI paper §7 Study 3 description. Parallel to piup-study1-crosscheck (5 gaps) and piup-study2-crosscheck (5 gaps)._
