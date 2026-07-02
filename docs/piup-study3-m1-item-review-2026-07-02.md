# PIUP Study 3 — M1 Technology Self-Efficacy Item Review

**Date:** 2026-07-02 (tick-4438)  
**Status:** Decision memo — **Jony must confirm item wording before OSF filing**  
**Author:** OpenClaw Agent  
**Resolves:** `docs/piup-study3-survey-instrument-2026-07-01.md §3.3` open action M1-W  
**Parallel to:** `docs/piup-study3-dv3-specification-2026-07-02.md` (same format, same purpose)  
**Connects to:** `docs/piup-study3-osf-prereg-2026-07-01.md §5`, `analysis/piup-study3-analysis.R` (M1 scoring at §7.1, §7.4)

---

## Summary

The Study 3 pre-registration specifies M1 as a "4-item adapted Compeau-Higgins scale (1–5 each, mean composite)" without verbatim item text. The survey instrument contains four recommended items with a ⚠️ JONY DECISION REQUIRED note. This document:

1. Maps each recommended item to its Compeau & Higgins (1995) source item
2. Evaluates adaptation quality for the receipt-verification context
3. Identifies one improvement and provides a refined M1-3
4. Provides ready-to-paste pre-reg §5 amendment text

**Decision required:**
- [ ] Confirm items as written, OR approve the M1-3 refinement (§2 below)
- [ ] File OSF amendment (see §4)

---

## 1. Compeau & Higgins (1995) source mapping

Compeau & Higgins (1995) define Computer Self-Efficacy (CSE) as confidence in completing a software task across varying support conditions. The 10-item scale measures different scaffolding levels, not a unidimensional difficulty axis. Four items are conventionally selected for short-form use (Compeau & Higgins, 1995; adapted in subsequent HCI studies).

| Study 3 item | Source condition (Compeau & Higgins, 1995) | CSE dimension |
|---|---|---|
| M1-1: *"…even if no one was available to help me"* | Item 1: *"…if there was no one around to tell me what to do as I go"* | Autonomous operation — no human support |
| M1-2: *"…even if I had never done anything like it before"* | Item 2: *"…if I had never used a package like it before"* | No prior experience |
| M1-3: *"…if I had brief written instructions available"* | Item 3: *"…if I had only the software manuals for reference"* | Minimal instructional scaffolding |
| M1-4: *"…by trying them on my own"* | Not a direct Compeau-Higgins item — closest to Items 4–5 (observed execution; own experimentation) | Self-directed trial |

**Assessment:** M1-1 and M1-2 are clean adaptations of the two most-cited Compeau-Higgins items. M1-3 and M1-4 require minor scrutiny (see §2).

---

## 2. Item-by-item evaluation

### M1-1 ✅ Clean

> *"I could use the receipt verification link even if no one was available to help me."*

- **Source alignment:** Direct adaptation of Compeau-Higgins Item 1 (no human support condition).
- **Receipt context:** Accurate. The verification step is completed alone, asynchronously. "No one available" is the modal use case (voters verify at home, days after the election).
- **Face validity:** High. The item measures whether participants believe they could complete the verification task independently — directly relevant to whether self-efficacy moderates social-proof effects on DV1.
- **Scale label fit:** "Not confident at all" → "Very confident" is appropriate for a 1–5 item measuring capability confidence.
- **Verdict:** ✅ Confirm as written.

---

### M1-2 ✅ Clean

> *"I could verify my vote receipt even if I had never done anything like it before."*

- **Source alignment:** Direct adaptation of Compeau-Higgins Item 2 (no prior experience condition).
- **Receipt context:** Accurate. Real DAO voters have likely never verified a vote receipt before; prior experience is not a reliable predictor for this population.
- **Face validity:** High. Measures novel-task self-efficacy — relevant to the "never verified before" baseline assumption for Study 3's pilot population.
- **Note on terminology:** "verify my vote receipt" is the correct Study 3 verb phrase (as opposed to "use the receipt verification link" in M1-1). Both are equivalent referents; the slight rewording across items is intentional (per instrument §3.3, items are not randomised, so lexical variety is acceptable and avoids anchoring).
- **Verdict:** ✅ Confirm as written.

---

### M1-3 ⚠️ Minor refinement recommended

> **Current:** *"I could use the receipt verification link if I had brief written instructions available."*  
> **Source:** Compeau-Higgins Item 3: *"…if I had only the software manuals for reference."*

**The issue:** "Brief written instructions" understates the help level. Compeau-Higgins Item 3 specifically tests scaffolding with *manuals* — a concrete, specific, standalone reference document. "Brief written instructions" is vaguer and could be interpreted as anything from a single-sentence note to a detailed guide. This ambiguity may reduce inter-item variance and slightly inflate M1-3 scores (participants interpret "brief written instructions" as minimal scaffolding, which feels easy, rather than as a manual, which implies more effort).

More practically: in the receipt context, "brief written instructions" describes exactly what the PIUP receipt *already provides* (the verification instruction text on the receipt UI). A participant who has already seen the receipt UI may interpret M1-3 as trivially easy ("Yes, I saw the instructions on the screen") rather than measuring self-efficacy under instructional scaffolding.

**Recommended refinement (M1-3R):**

> *"I could use the receipt verification link if I had a short step-by-step guide to follow."*

**Why this is better:**
1. "Step-by-step guide" is more specific than "brief written instructions" — it implies a structured external document, closer to the Compeau-Higgins manual intent.
2. It does not map onto the in-UI receipt instructions that participants have already seen (avoiding the "I already have this" confound).
3. "Short step-by-step guide" is clear to non-technical participants.
4. Correct answer on a 1–5 scale is unaffected; scoring code unchanged.

**Option A (refined):** *"I could use the receipt verification link if I had a short step-by-step guide to follow."*  
**Option B (keep original):** *"I could use the receipt verification link if I had brief written instructions available."* — Acceptable; slightly confounded.

**Recommendation: Option A.** The refinement is pre-data and minor enough not to require a standalone amendment entry, but should be included in the M1 amendment text (§4) as verbatim item specification (any deviation from the instrument is an amendment by definition).

---

### M1-4 ✅ Minor note, confirm as written

> *"I could figure out the verification steps on my own by trying them."*

- **Source:** Not a direct Compeau-Higgins item. Closest analogues are Items 4 (observed someone use it first) and 10 (used similar packages before) — both about prior exposure. M1-4 tests a distinct dimension: self-directed trial-and-error, which is closer to Bandura's (1977) *enactive mastery* source of self-efficacy.
- **Construct validity concern:** Because this item is not from the Compeau-Higgins scale, including it as one of four items in a "Compeau-Higgins adapted" composite could raise a reviewer question. However, 4-item short forms of well-validated scales routinely substitute items for context-specific adaptations; the pre-reg's "adapted" label covers this.
- **Receipt context:** High face validity. Verification is a multi-step task (copy fingerprint, navigate to URL, paste, confirm). "Figuring out the steps by trying" captures hands-on efficacy — a distinct and complementary dimension to M1-1 (autonomous), M1-2 (novel), and M1-3 (guided).
- **Potential redundancy check:** M1-1 ("no one available") and M1-4 ("on my own by trying") could correlate highly. If internal consistency is low (α < 0.70) at pilot N, report Cronbach's α and note the item-total correlation for M1-4 in the pilot readiness check. This is a post-pilot diagnostic, not a pre-data concern.
- **Verdict:** ✅ Confirm as written, with the note above flagged for pilot α check.

---

## 3. Scoring rule (no decision needed — confirm as written)

The analysis script already implements M1 scoring correctly:

```r
# piup-study3-analysis.R (§7.1 and §7.4)
df$m1_composite <- rowMeans(df[, c("m1_eff1", "m1_eff2", "m1_eff3", "m1_eff4")], na.rm = TRUE)
df$m1_c <- df$m1_composite - mean(df$m1_composite, na.rm = TRUE)  # mean-centred
```

The pre-reg specifies "mean composite (1–5 each)." This matches the script. No amendment needed for the scoring rule.

**Missing item handling (pre-specify):** If any item is missing (technical dropout between DV2 and M1 collection), use pairwise complete means. Add this to the pre-reg amendment text (§4) as a one-sentence clarification. This is not a change to the scoring rule — it is an implementation detail that avoids a post-data decision.

---

## 4. Amendment text for pre-reg §5

The following text adds M1 verbatim item wording to the pre-reg. File as a pre-data OSF amendment, combined with the DV3 amendment (tick-4437) if filing together.

### Replacement text for pre-reg §5 M1 block

> **M1 — Technology self-efficacy (T0, self-report):** 4-item adapted Compeau-Higgins (1995) Computer Self-Efficacy scale, re-contextualized to the vote-receipt verification task. Items and scale:
>
> - **M1-1:** "I could use the receipt verification link even if no one was available to help me." (Adapted from Compeau & Higgins, 1995, Item 1: no human support condition.)
> - **M1-2:** "I could verify my vote receipt even if I had never done anything like it before." (Adapted from Compeau & Higgins, 1995, Item 2: no prior experience condition.)
> - **M1-3:** "I could use the receipt verification link if I had a short step-by-step guide to follow." (Adapted from Compeau & Higgins, 1995, Item 3: instructional scaffolding condition. Wording refined from "brief written instructions" to "short step-by-step guide" to avoid confounding with the in-UI receipt instructions already visible to participants at T0.)
> - **M1-4:** "I could figure out the verification steps on my own by trying them." (Novel item reflecting self-directed trial efficacy; not directly from the Compeau-Higgins 10-item bank but consistent with Bandura's [1977] enactive mastery dimension; introduced to complete the 4-item short form for the receipt verification domain.)
>
> **Scale:** 1 = Not confident at all … 5 = Very confident (5-point Likert).  
> **Scoring:** Mean composite across M1-1 to M1-4. Mean-centred in analysis (`m1_c`). If any item is missing for a participant, use pairwise complete means.  
> **Role:** Exploratory moderator only. Used in RQ3a (condition × self-efficacy interaction on DV1; §7.4). Not confirmatory. Internal consistency (Cronbach's α) will be reported as a pilot diagnostic.  
> **Administration:** T0, immediately after DV2, before ballot submission confirmation screen exits. Fixed item order (not randomised).

### OSF amendment log entry

> **Amendment [N] — M1 verbatim item wording (pre-data, pre-OSF filing):** Pre-reg §5 defined M1 as "4-item adapted Compeau-Higgins scale (1–5 each, mean composite)" without verbatim items. This amendment specifies all four items: M1-1 (no support), M1-2 (no prior experience), M1-3 (instructional scaffolding — refined wording from "brief written instructions" to "short step-by-step guide" to avoid confounding with visible receipt UI text), M1-4 (self-directed trial; novel item extending the Compeau-Higgins framework). Scoring rule (mean composite, mean-centred) and role (exploratory moderator) unchanged. (Pre-data, pre-OSF.) | [Jony Bursztyn]

---

## 5. Impact on other documents

| Document | Change required | Action |
|---|---|---|
| `docs/piup-study3-osf-prereg-2026-07-01.md §5` | Add M1 verbatim items + scoring detail + missing-item rule | Jony to paste and file on OSF |
| `docs/piup-study3-survey-instrument-2026-07-01.md §3.3` | Update M1-3 wording if Option A approved; remove ⚠️ JONY DECISION REQUIRED | Agent can apply once Jony confirms |
| `analysis/piup-study3-analysis.R` | No change — scoring code already correct | None |
| `docs/piup-study3-crosscheck-2026-07-01.md` | M1-W — mark resolved pending Jony confirmation | Agent to update once Jony confirms |
| `docs/qualtrics-setup-guide-study3-t14-2026-07-01.md` | N/A — M1 is T0 (embedded UI), not T+14 | None |

---

## 6. What Jony needs to do

**Before OSF filing:**

1. **Review M1-3 wording.** Choose: Option A (refined: "short step-by-step guide") or keep original ("brief written instructions"). **Recommend Option A.**
2. **Confirm M1-1, M1-2, M1-4** as written — no further input needed if agreed.
3. **Paste amendment text** from §4 into `piup-study3-osf-prereg-2026-07-01.md §5` (new M1 subsection, or appended to existing M1 definition).
4. **File on OSF** as a pre-data amendment — can be filed simultaneously with the DV3 amendment (tick-4437) as a single combined amendment, or as Amendment [N+1] separately.
5. **Reply to confirm** so the agent can: (a) update M1-3 wording in the instrument §3.3, (b) remove the ⚠️ note, (c) close M1-W in the instrument open actions table.

**Estimated time:** 5–10 minutes (review + paste + OSF file, combined with DV3 amendment).

---

## 7. Combined OSF filing recommendation

The DV3 amendment (tick-4437) and this M1 amendment (tick-4438) both target pre-reg §5 and are both pre-data. **Filing them as a single combined amendment is cleaner** than two separate log entries. Suggested combined title:

> **Amendment [N] — Study 3 pre-data instrument specification: DV3 verbatim items + scoring rule + M1 verbatim items (pre-data, pre-OSF filing)**

This keeps the OSF amendment log compact and is standard practice for related pre-data specification amendments.
