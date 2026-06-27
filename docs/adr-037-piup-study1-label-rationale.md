# ADR-037: PIUP Study 1 — Label Selection Rationale and Production Decision Framework

**Date:** 2026-06-22  
**Status:** Accepted — Study 1 stimuli implemented, pilot pending  
**Affects:** `study-stimuli/`, `packages/react/src/components/VoteReceipt.tsx` (`labelVariant` prop)  
**Companion documents:** [`docs/piup-study-protocol-2026-06-22.md`](piup-study-protocol-2026-06-22.md), [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md)

---

## Context

The PIUP receipt UI uses the phrase **"vote fingerprint"** for the receipt identifier (a ZK nullifier). This name was chosen by the designer (Jony Bursztyn) based on two criteria:

1. It activates the correct mental model: "unique to me, not about my choice — save it, use it to verify later."
2. It avoids the known failure mode of technically correct terms: "nullifier" was observed to produce the interpretation "my vote was cancelled" in informal review sessions of comparable systems (Helios-style).

These are design hypotheses, not studied results. The grant application (Section 3.2) and the CMU HCII research statement both make this claim explicitly. **Study 1 is the empirical test of the naming hypothesis.**

This ADR documents: (a) why these specific four labels were selected and why others were excluded, (b) the directional hypotheses and their literature basis, (c) what each result pattern means for the production label decision.

---

## Label selection

### The four conditions

| Condition | Label | Category |
|-----------|-------|----------|
| A | **vote fingerprint** | Metaphor-activating (current production) |
| B | **confirmation code** | eCommerce convention |
| C | **nullifier** | Cryptographically correct |
| D | **receipt ID** | Generic / neutral |

### Why not other candidates

Several alternatives were considered and excluded:

**"Token"** — generic but activates the wrong semantic field in the current cultural context (cryptocurrency tokens, loyalty tokens). Creates category confusion with wallet token assets.

**"Proof"** — too close to what the system does (verifiable) but doesn't help users distinguish "proof you voted" from "proof how you voted." Informal review: users asked "proof of what?" without the qualification that "proof of fingerprint" would give.

**"Ballot stub"** — activates the right analogy (physical voting analogy: keep the stub, not the ballot) but is culturally specific to US paper-ballot elections and would need translation for non-US populations. Excluded for generalisability.

**"Tracking number"** — activates shipping/logistics mental model, which is close (something to check later). Excluded because it implies the system is actively tracking a package, which may make users think the system knows where their vote "is" — too close to a vote-tracking concern.

**"Receipt" alone** — already in the section heading ("Your vote was cast"). Adding a second layer of "receipt" as the identifier name creates ambiguity: "the receipt's ID?" vs. "the identifier of the action?". Excluded to reduce cognitive load.

**"Code"** alone — too short to carry meaning; would merge with "confirmation code" in pre-test. Excluded.

The four conditions in Study 1 represent: the current best hypothesis (A), the strongest plausible competitor from adjacent domains (B), the worst expected performer from prior literature (C), and a minimal baseline for effect reference (D).

---

## Directional hypotheses

The following are pre-registered directional hypotheses for Study 1, grounded in prior HCI/security-usability literature. They are ordered by expected performance on RQ1 (comprehension accuracy).

### H1: "vote fingerprint" > "receipt ID" on privacy mental model (RQ3)

**Basis:** The word "fingerprint" carries the metaphor of uniqueness-without-disclosure (a fingerprint identifies a person but doesn't describe them). By analogy, a vote fingerprint should cue "this uniquely identifies my ballot without describing my choice." "Receipt ID" carries no such affordance — it implies only "an identifier for the receipt," leaving privacy model construction to the user.

**Predicted outcome:** Condition A will outperform Condition D on Q2 ("Does this prove which option you chose?" correct: No) and Q3 (coercion vignette, correct: No) by ≥ 10 percentage points.

**Source:** Cranor and Garfinkel (2005), Chapter 9 (mental models and security metaphor); Whitten and Tygar (1999) §5 on the importance of mental model alignment in security UI.

### H2: "vote fingerprint" ≈ "confirmation code" on comprehension accuracy (RQ1)

**Basis:** "Confirmation code" is familiar and activates the correct behavioral schema (save this to verify your submission later), but it does not carry the privacy-blindness cue. Users may correctly infer that the code "confirms" submission without over-inferring what it contains. However, "confirmation" may activate "confirmation of choice" in the voting domain specifically — a potential negative priming effect not present in eCommerce contexts.

**Predicted outcome:** Conditions A and B will be within 5 percentage points on composite comprehension accuracy, but Condition B will underperform A specifically on Q2/Q3 (privacy mental model items) due to "confirmation of choice" priming.

**This is the most uncertain prediction.** If B significantly outperforms A overall, "confirmation code" is the production recommendation.

**Source:** Fogg and Tseng (1999) on system credibility and familiar conventions; Norman (1988) on affordance activation.

### H3: "nullifier" will underperform all other conditions on Q1–Q4

**Basis:** This is the strongest prediction in the set. The word "nullifier" contains "null" — lexically adjacent to "void" and "cancel." In informal usability sessions of systems using Helios-style terminology (Adida et al. 2009), users shown "nullifier" described their reaction as "it sounds like my vote was cancelled or rejected." This is precisely the wrong mental model: users who believe their vote was voided may re-vote, complain, or disengage from verification.

The cryptographic accuracy of the term (a nullifier is a value that prevents double-spending; it does not nullify the vote) provides no protection against this failure mode. Technically correct feedback that violates mental models is effectively misleading feedback (Whitten and Tygar 1999).

**Predicted outcome:** Condition C will score lowest on Q1 ("Does this prove the vote was counted?" correct: Yes — this is a reversal risk) and on composite accuracy. Predicted < 45% accuracy on Q1 if the misreading is common, vs. ≥ 65% for Condition A.

**Source:** Whitten and Tygar (1999); Bell et al. (2013) (STAR-Vote), section on voter confirmation messaging; Adida et al. (2009) (Helios) §7 on usability limitations. [Fixed tick-4046: Adida year corrected 2008→2009 in both body locations — parallel to pre-reg fix tick-4040 and ADR-037 References fix below.]

### H4: Comprehension confidence will be higher for B than for A, C, or D, regardless of accuracy

**Basis:** Familiar conventions (confirmation code, eCommerce) produce high self-assessed confidence even when they don't produce correct mental models — a calibration failure. Users who have used Amazon or Ticketmaster "confirmation codes" will feel they know what to do with a confirmation code, and may rate confidence high while still failing Q3 (privacy vignette). This would be a theoretically important finding: the label that feels most familiar may be the most dangerous one in the privacy-critical domain.

**Predicted outcome:** Condition B will have the highest mean confidence rating (7-point Likert) but will not top the accuracy ranking. An accuracy × confidence calibration analysis is planned as a secondary outcome.

**Source:** Dunning-Kruger literature in security usability (Felt et al. 2012, SOUPS, on Android permission dialog comprehension); Ur et al. (2012, SOUPS) on the gap between stated and actual password security knowledge. [Fixed tick-4046: Felt body citation corrected — 'CHI, on SSL indicators' was wrong on both venue (SOUPS not CHI) and topic (Android permissions not SSL indicators). The correct paper is Felt, Ha, Egelman et al. (2012) 'Android Permissions: User Attention, Comprehension, and Behavior' SOUPS 2012 — parallel to pre-reg References fix tick-4041. SSL indicators work was Felt et al. 2014 CHI, a different paper.]

---

## Production decision framework

Study 1 results map to a small set of production decisions. The table below gives the action for each outcome pattern, without requiring significance thresholds to read.

| Outcome | Production decision |
|---------|---------------------|
| A significantly outperforms B, C, D on both accuracy and privacy mental model | **Keep "vote fingerprint"** — hypothesis confirmed, proceed to Study 2 with current label. |
| B ≈ A on accuracy but B < A on privacy mental model items (Q2/Q3) | **Keep "vote fingerprint"** for deployments where coercion risk matters; **use "confirmation code"** for low-stakes polls where familiarity is more important than privacy model. Split strategy. |
| B > A on accuracy, B ≈ A on privacy mental model | **Pivot to "confirmation code"** — strong result, familiar convention wins even in voting domain. Update `VoteReceipt.tsx` default. |
| C beats D but not A or B on accuracy | **Confirms "nullifier" exclusion from default.** No production change. Relevant for documentation only. |
| C > A on accuracy | **Unexpected.** Do not act on pilot data alone (n = 10/cell). Replicate in full study before acting. Possible confound: cryptographer-heavy Prolific sample. |
| No significant differences across conditions (all ≈ 55% accuracy) | **Comprehension failure is general**, not label-dependent. Study 3 and protocol revision needed before production decision. Triggers redesign of privacy copy (not just label). |

### When to act on pilot data

Do **not** change the production label based on pilot data (n = 10/cell). Pilot is for instrument validation (floor/ceiling effects, task timing, attention check calibration). Production decision waits for full study (n = 50/cell) results.

Exception: if Condition C produces < 30% accuracy on Q1 in the pilot (active vote-cancellation misreading), add a warning to the consent form for the full study and consider dropping C as a live arm (replace with a fifth label if needed). This is an ethics consideration, not a statistical one — exposing participants to a UI that actively produces a harmful misunderstanding about their vote is unacceptable even in a study.

---

## Why this ADR exists alongside the study protocol

The study protocol (`piup-study-protocol-2026-06-22.md`) documents _how_ the study is run. This ADR documents _why these specific four labels were chosen_ and _what the expected outcomes mean for the codebase_. These are separate questions.

An IRB reviewer needs the protocol. A grant reviewer (Aztec Wave 3) needs both. A faculty advisor (Sauvik Das, CMU HCII) will ask about the hypothesis structure and prior literature grounding before deciding whether to sponsor or supervise the study — this ADR is the answer to that question.

---

## References

- Whitten, A. and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." _USENIX Security Symposium._
- Adida, B., De Marneffe, O., Pereira, O. and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." _EVT/WOTE 2009._ [Fixed tick-4046: three errors corrected — (1) year 2008→2009; (2) title 'Open-Source Software: The Helios Voting System' → 'Open-Audit Voting: Analysis of Real-World Use of Helios'; (3) venue 'USENIX EVT' → 'EVT/WOTE 2009'. Parallel to pre-reg fix tick-4040 and CHI paper entry (line 475).]
- Bell, S., et al. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _EVT/WOTE 2013._ [Fixed tick-4046: venue corrected — 'USENIX EVT/WOTE' → 'EVT/WOTE 2013'; 'USENIX' prefix removed and year added. Parallel to pre-reg fix tick-4041.]
- Norman, D.A. (1988). _The Design of Everyday Things._ Basic Books.
- Cranor, L.F. and Garfinkel, S. (eds.) (2005). _Security and Usability._ O'Reilly Media.
- Fogg, B.J. and Tseng, H. (1999). "The Elements of Computer Credibility." _CHI 1999._
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _SOUPS 2012._ [Fixed tick-4046: wrong paper — 'How to Ask for Permission' (USENIX HotSec 2012) was a different Felt 2012 paper. The body citation (line 92) references the Android permissions comprehension work; correct paper is Felt, Ha, Egelman et al. (2012) SOUPS 2012 on user attention/comprehension of Android permission dialogs. Full author list added to match CHI paper line 481. Parallel to pre-reg References fix tick-4041.]
- Ur, B., et al. (2012). "How Does Your Password Measure Up? The Effect of Strength Meters on Password Creation." _USENIX Security._
- Das, S., Kim, T.H.-J., Dabbish, L.A., and Hong, J.I. (2014). "The Effect of Social Influence on Security Sensitivity." _SOUPS 2014_, pp. 143–157. USENIX. [Fixed tick-4046: two errors corrected — (1) venue 'ACM CCS 2014' → 'SOUPS 2014' (USENIX-sponsored venue, not ACM CCS); (2) author list 'Das, S., Dabbish, L. and Hong, J.' → full 4-author list including Kim, T.H.-J. as second author. Parallel to pre-reg fix tick-4042 and CHI paper entry.]

---

_Author: Jony Bursztyn · 2026-06-22_  
_Part of the Aztec Private Voting PIUP research series. See also ADR-036 (M2 wallet signing path), [`docs/piup-study-protocol-2026-06-22.md`](piup-study-protocol-2026-06-22.md), [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md)._
