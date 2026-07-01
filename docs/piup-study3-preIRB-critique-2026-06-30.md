# PIUP Study 3: Pre-IRB Design Critique

**Date:** 2026-06-30  
**Status:** Internal review — pre-IRB  
**Author:** Tick-4287 automated review  
**Connects to:** `piup-study3-social-verification-2026-06-29.md`, `piup-study3-power-analysis-2026-06-29.md`

This document records open questions, methodological vulnerabilities, and items that must be resolved before Study 3 can be submitted for IRB review. Issues are categorised by severity.

---

## 🔴 High priority — must fix before IRB submission

### H1: Citation error — Das et al. (2014) venue [CORRECTION tick-4340]

**⚠️ This section was itself incorrect. It has been superseded by the tick-4340 web-verified finding below.**

Both the original H1 assessment (tick-4287) and the tick-4319 "fix" introduced errors. The final verified state is:

**Correct canonical citation (verified via socialcybersecurity.org and ACM DL third-party citations):**

> Das, S., Kramer, A. D. I., Dabbish, L. A., & Hong, J. I. (2014). Increasing security sensitivity with social proof: A large-scale experimental confirmation. In *Proceedings of the 21st ACM Conference on Computer and Communications Security (CCS '14)* (pp. 739–749). ACM. https://doi.org/10.1145/2660267.2660271

**Error history:**
- Original study docs (pre-tick-4287): had wrong venue (SOUPS 2014) and wrong author (Kim T. H.-J.).
- This critique (tick-4287): correctly identified SOUPS venue as wrong; **incorrectly** concluded that Kramer was not a co-author and that Kim T. H.-J. was correct.
- Tick-4319 "fix": changed both study docs to use Kim T. H.-J. — introduced wrong author.
- Tick-4340 web verification: confirmed Kramer IS the correct second author. The SOUPS 2014 paper by Das et al. is a *different* paper ("The Effect of Social Influence on Security Sensitivity"; Das, Kim H.J., Dabbish, Hong; USENIX SOUPS 2014) and was cited in another context.

**Status: ✅ RESOLVED (tick-4340)** — Both study docs now use the correct author (Kramer). Both use correct venue (CCS '14). H1 is closed.

---

### H2: Dangling reference — Nissen et al. (2025) [RESOLVED tick-4364]

**⚠️ Status: ✅ RESOLVED (tick-4364)** — Verified against current `piup-study3-social-verification-2026-06-29.md`. Nissen et al. (2025) IS cited in the document body (§7 Ethical considerations, "Partial disclosure with debrief" paragraph): *"consistent with the privacy-preserving design in Nissen et al. (2025) who found that counter-strategies are more effective when coercer visibility is low."* The reference appears in both body and references list. H2 is closed.

~~`piup-study3-social-verification-2026-06-29.md` includes in its references:

> Nissen, C., Hilt, T., Budurushi, J., Volkamer, M., and Kulyk, O. (2025). Voting under pressure: Perceptions of counter-strategies in internet voting. *E-VOTE-ID 2025*. LNCS vol. 16028, pp. 158–174.

This citation does not appear anywhere in the document body. Either it was intended to support a claim that was later edited out, or it was added speculatively. IRB reviewers will notice. Either cite it (it's potentially useful in §2 Motivation for the coercion discussion) or remove it from the references.~~

~~**Suggested use:** Nissen et al. (2025) could be cited in §7 Ethical considerations or §2 Motivation when discussing the coercion-surface implications of showing a public verification counter. The counter is privacy-preserving with respect to *who* verified, but could interact with coercion strategies — Nissen et al.'s framework for counter-strategies in internet voting may be relevant here. If it isn't being actively used, remove it.~~

---

### H3: "Non-deception" claim is overstated [RESOLVED tick-4364]

**⚠️ Status: ✅ RESOLVED (tick-4364)** — Verified against current `piup-study3-social-verification-2026-06-29.md`. §7 Ethical considerations uses "**Partial disclosure with debrief:**" (bold label, not "Non-deception"). The paragraph explicitly states: *"Participants are not informed of the two-condition design at T0 to prevent demand effects. This constitutes incomplete disclosure, which is justified by the minimal-risk nature of the manipulation and mitigated by full debrief at T+14."* Both the heading and the required sentence are in place. H3 is closed.

~~§7 Ethical considerations states: "The count is real and accurate. Participants in the treatment condition see genuine social behavior, not a simulated one."

This is true. But the section leads with a heading "Non-deception," which is misleading. Participants in *both conditions* are told the study is about "how voters use their receipts after an election." They are not told (a) that there are two versions of the receipt, or (b) that a between-subjects manipulation is occurring. This is deception by omission — standard and defensible in behavioural research, but it needs to be named correctly.

**IRB reviewers will flag this.** The section should be renamed "Partial disclosure" or "Incomplete disclosure with debrief" and should explicitly acknowledge that participants are not told about the two-condition design. The current framing ("non-deception") could trigger a request for revision if reviewers interpret it as claiming no deception at all.

**Fix:** Rename the section and add a sentence: *"Participants are not informed of the two-condition design at T0 to prevent demand effects. This constitutes incomplete disclosure, which is justified by the minimal-risk nature of the manipulation and mitigated by full debrief at T+14."*~~

---

## 🟡 Medium priority — address before pre-registration

### M1: Negative social proof at low-n elections

The study will be run in a single election (~80 voters). Early in the verification window (days 1–3 after the vote), the counter may read "0 voters have verified their vote" or "2 voters have verified." This creates the risk of **negative social proof**: if almost nobody has verified yet, the counter may actively demotivate verification ("nobody else is bothering, why should I?"). Cialdini's work is explicit that low-n social proof backfires.

**This is a real design vulnerability.** Three possible mitigations:
1. **Suppress the counter until a floor is reached** (e.g., "verification opens in X days" until ≥10 participants have verified). But this requires specifying the floor in advance and pre-registering it.
2. **Use a proportional framing** ("15% of voters have verified — verification is open until [date]") which is more interpretively positive at low baselines. But the social verification doc explicitly rejects percentage framing (§3, last paragraph) due to base-rate anchoring when n is small.
3. **Set the verification window to open only after voting closes**, displaying the counter only at T+3 or later. This decouples the social proof exposure from the T0 baseline (when n = 0) and is consistent with the design note about T0 delivery.

This needs to be specified in the design doc and pre-registered. What is the minimum floor? When does the counter activate? IRB reviewers and pre-registration reviewers will ask.

---

### M2: Condition persistence across devices

§3 Design states: "The receipt endpoint is parameterized by voter session." This implies the condition is encoded in the receipt URL or voter session token. Two questions:

1. If a participant accesses their receipt from a different device (e.g., voted on laptop, checks receipt on phone), do they see the same condition? If the condition is in the receipt URL (which is the PIUP design — the receipt is a downloaded artifact), then yes. If it depends on browser session state, then no.

2. What happens to the social proof counter's value if a participant refreshes the receipt page 14 days later? The counter will be higher. Does seeing a higher counter at T+14 (when they're deciding whether to verify) confound the T0 condition exposure, or does it reinforce it?

Both questions need a sentence in the design doc. The first is a data-integrity issue; the second is a threat to construct validity (the "treatment" varies over time).

---

### M3: 90% CI choice needs explicit justification

The analysis plan (§6) specifies a **90% confidence interval** rather than the conventional 95%. This choice is reasonable — a 90% CI for a pilot is standard, and pre-specifying a decision rule around it (lower bound ≥ 1.5 → proceed to replication) is defensible. However:

- Pre-registration reviewers may interpret 90% CI as equivalent to one-tailed α = .05, which could be seen as relaxing the α threshold without justification.
- The interpretation rules (lower bound ≥ 1.5 → proceed; includes 1.0 → uncertain; upper bound < 1.0 → suppress) need to be pre-registered verbatim, not just stated in the design doc.

**Add a justification sentence** in §6: *"A 90% CI is chosen (rather than 95%) consistent with pilot-study convention (Lakens, 2021) and to reflect the exploratory nature of the estimate; the interval is used to calibrate a future powered study, not as a confirmatory inferential test."*

Cite: Lakens, D. (2021). Improving your statistical inferences. *Open Educational Resources*. https://lakens.github.io/statistical_inferences/

---

### M4: Debrief procedure is underspecified

§7 states participants are "debriefed at T+14" but does not describe the debrief content, format, or what happens if a participant objects to having been in an undisclosed two-condition study. IRB requires a debrief script or at minimum a description of what the debrief covers.

**Minimum required:**
- What participants are told (two conditions, the purpose of the counter manipulation, what the study is testing)
- Opportunity for participants to withdraw their data after debrief
- A contact for questions post-debrief
- Acknowledgment that the study is about understanding voting behaviour, not about the participant's individual vote (reinforcing privacy)

---

## 🟢 Low priority — design improvements (post-IRB or pre-registration)

### L1: Consider adding a T+7 contact event

§8 notes (without pre-registering it) that a T+7 social proof reminder could be tested. If this is being considered as part of the Study 3 protocol, it needs to be either:
- Pre-registered as a third arm (Control / Treatment-T0-only / Treatment-T0+T7) — which requires 3-arm power calculations (substantially larger n), or
- Explicitly excluded from Study 3 and proposed as a separate Study 3b.

Currently the document mentions it as speculation without committing either way. IRB reviewers will ask whether the T+7 reminder is part of the study or not.

**Recommendation:** Add a sentence to §8 explicitly stating the T+7 reminder is *not* part of Study 3 and will be evaluated only after the Study 3 pilot results establish whether a T0-only manipulation has any effect.

---

### L2: Comprehension check instrument — cross-study alignment

The study specifies "same Q1–Q4 rubric from Study 1" for the comprehension check at T+14 (§5, secondary measures). But Study 1 used these questions in a controlled lab context where participants had 5 minutes with the interface. At T+14 in a field study, participants are recalling impressions from two weeks ago.

The questions themselves may be the same, but the *conditions* under which they're answered are very different. This should be acknowledged as a threat to cross-study comparability, and the comprehension measure should be labelled as "exploratory" not just because of power but because of contextual confounds. Study 1 findings (which label/condition produces accurate mental models) may not directly predict Study 3 comprehension check outcomes.

---

### L3: Ethics note on the ground-truth verification log

§5 Process measure notes that the passive log is "opt-in only (see Study 2 ethics note)." The Study 2 ethics note should be explicitly cross-referenced with a section and page number when the Study 3 doc is finalised, rather than a loose parenthetical. IRB reviewers following the cross-reference will need to find the exact text.

---

## Pre-IRB readiness checklist

_Updated tick-4319 (2026-06-30): all items verified against current document state._

Before submitting to IRB, the following must be in place:

- [x] Das et al. (2014) citation corrected in both Study 3 documents (H1) — ✅ **RESOLVED (tick-4340, supersedes tick-4319)**: Both docs now have correct citation: CCS '14, **Kramer** et al. (tick-4319 incorrectly substituted Kim T. H.-J.; tick-4340 web-verified and reverted to Kramer).
- [x] Nissen et al. (2025) cited in body text or removed from references (H2) — ✅ **RESOLVED**: Cited at §7 of social-verification doc ("consistent with the privacy-preserving design in Nissen et al. (2025) who found...").
- [x] §7 reframed as "partial disclosure" not "non-deception" (H3) — ✅ **RESOLVED**: §7 heading is "Partial disclosure with debrief" in social-verification doc.
- [x] Negative social proof floor specified and pre-registered (M1) — ✅ **RESOLVED**: Floor set at **≥5 verified participants** (changed from initially-considered ≥10 in tick-4408; rationale: ≥10 not reachable at conservative baseline p₁=0.10, N=80 → 8 expected verifications; ≥5 is reachable while avoiding negative social proof at n=0). Specified in §3.2 of pre-reg (`piup-study3-osf-prereg-2026-07-01.md`) and §7.7 manipulation failure clause.
- [x] Condition persistence across devices documented (M2) — ✅ **RESOLVED**: Documented in §3 ("Condition persistence across devices (M2)").
- [x] 90% CI choice explicitly justified with citation (M3) — ✅ **RESOLVED**: Lakens (2021) justification sentence in §6 of social-verification doc.
- [x] Debrief script drafted (M4) — ✅ **RESOLVED**: Full script at `piup-study3-debrief-script-2026-06-30.md` with 5 screens, withdrawal pipeline, administration notes, IRB submission pathway.
- [x] T+7 reminder inclusion/exclusion decision committed (L1) — ✅ **RESOLVED**: Explicit pre-registered exclusion in §3 ("No T+7 reminder (L1 — pre-registered exclusion commitment)").
- [x] Comprehension instrument labelled as exploratory due to context shift (L2) — ✅ **RESOLVED**: L2 context-shift note added to §5 secondary measures ("adapted... L2 context-shift note").
- [ ] Study 2 ethics note cross-reference made explicit (L3) — ⏳ **PARTIALLY RESOLVED**: §5 references `piup-study2-design-note-2026-06-22.md §7` by name; no page/anchor number possible in Markdown. Acceptable for internal doc; tighten when converting to IRB submission format.

**Revised estimated work before IRB submission: ~30 minutes** (L3 cross-reference only; all other items resolved). The study design is substantively sound.

---

## Summary verdict

The Study 3 design is methodologically coherent and the pilot/feasibility framing is the correct pragmatic choice given the power constraints. The theoretical contribution (social proof for *deferred* security behaviour across a two-week gap) is genuine and publishable.

**Updated assessment (tick-4319):** All high-priority (H1–H3) and medium-priority (M1–M4) items identified in this critique are resolved in the current document versions. The original critique was generated against an in-progress version of the docs; the fixes were applied before the docs were finalised. The only remaining item (L3) is a minor cross-reference tightening that requires no structural change — only specific anchor syntax when the doc is converted to IRB submission format.

**Verification (tick-4364, 2026-07-01):** Re-verified H2 and H3 against the live document. H2 (Nissen et al. 2025): citation appears in body text (§7, "Partial disclosure with debrief" paragraph) and in references list — not dangling. H3 (Non-deception): §7 uses bold label "**Partial disclosure with debrief:**" and includes the required sentence about incomplete disclosure. Both checklist items confirmed correct. The H2/H3 body sections in this critique were marked RESOLVED accordingly. No structural changes required to the study doc.

No significant revision session is needed. The social-verification and debrief-script docs are IRB-ready pending:
1. OSF pre-registration upload (Jony action)
2. IRB protocol number and PI contact fields in debrief script (Jony action)
3. L3 cross-reference tightening at IRB submission time (trivial)
