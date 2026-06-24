# Private Voting as HCI Research: A Research Framing

_Author: Jony Bursztyn · 2026-06-22_  
_Related: [`docs/receipt-design.md`](receipt-design.md), [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md)_

---

## Why this is an HCI problem, not a cryptography problem

The cryptographic problems in private voting are, in a meaningful sense, solved. The PSE/Shutter *State of Private Voting 2026* report — a survey of 12 protocols evaluated against 26 properties — finds that full ballot privacy, coercion resistance, and individual verifiability are all achievable with existing ZK proof systems. What the report identifies as the remaining open problems are: developer experience, demand generation, and facilitator tooling.

These are not cryptography problems. They are human factors problems.

This project started as a ZK voting contract (a cryptography problem) and has progressively revealed itself to be a UX design problem with cryptographic constraints. The design decisions that matter — what to call a nullifier, whether to include the vote choice in the receipt, whether to collapse the verification instructions by default — are not derivable from the cryptographic specification. They require understanding how people form mental models of privacy, what trust they extend to digital systems, and what copy will produce the behavior "save this, come back and verify later."

This document is a research framing. It argues that the receipt design in this project is an HCI research contribution, not just a product design decision, and proposes the evaluation work that would establish it as such.

---

## The research problem

**Problem statement:** Users of private voting systems need a mechanism for confirming that their vote was counted — without that mechanism revealing their vote. This requirement is formally called *receipt-freeness* (Benaloh and Tuinstra, 1994). Its protocol-level solution (ZK proofs over private state) is well understood. Its *UX* solution is not.

Existing work on the usability of verifiable voting systems (Adida et al. 2008 on Helios; Bell et al. 2013 on STAR-Vote) has documented the failure modes: users do not understand cryptographic proofs, do not verify after the fact even when verification is available, and form mental models that are often wrong in security-relevant ways. This work has not proposed a design pattern that resolves the tension.

The **Proof-of-Inclusion UX Pattern (PIUP)** documented in this project is a candidate solution. The claim is:

> A randomized surrogate identifier ("fingerprint"), paired with a plain-language receipt that explicitly states the absent-choice design and provides deferred verification affordance, produces better security-oriented behavior than cryptographic proof artifacts — without requiring the user to understand the underlying ZK mechanism.

This is a falsifiable, empirically testable claim. Whether it is true is a research question, not a product question.

---

## CHI contribution type

The ACM CHI community recognizes several contribution types for design research. This work fits primarily as:

**Artifact contribution + design guidelines.** The contribution is:

1. A named design pattern (PIUP) with stated invariants, implementation examples, and known failure modes
2. A design vocabulary — "fingerprint" rather than "nullifier," "privacy by absent content" rather than "cryptographic guarantee" — with documented rationale for each choice
3. A worked implementation in a deployed ZK voting system (Aztec Private Voting) that can serve as an evaluation target

The contribution is *not* a user study result, because no user study has been run. The honest position is that this is a *design* contribution that generates research questions for future empirical work. The PIUP is a proposal, not a proven solution.

---

## Related work (precise positioning)

This work sits at the intersection of three research areas:

### Security and privacy UX

The "Why Johnny Can't Encrypt" tradition (Whitten and Tygar, 1999; Garfinkel, 2005; Felt et al., 2012 on Android permission dialogs) has established that technically correct privacy-preserving systems fail when their feedback violates users' mental models. The PIUP design decisions are direct responses to this literature:

- The "fingerprint" metaphor was chosen because it produces the correct mental model ("this is uniquely mine; matching it doesn't reveal anything about me") faster than technically correct alternatives.
- The absent-choice receipt design eliminates the primary coercion vector at the UI layer — but this makes the receipt feel incomplete to users who expect a confirmation to include what they confirmed.

The tension between *feeling confirmatory* and *being coercion-resistant* is the specific design problem this work is addressing. No prior work has stated this tradeoff clearly or proposed a design resolution.

### Verifiable systems and trust

Everett et al. (2008) and Acemyan et al. (2014) studied voter verification behavior in VVPAT (paper trail) systems. Key finding: most voters do not verify, even when verification is simple, because they trust the system without needing to check. This has two implications for the PIUP:

- The receipt's verification affordance (collapsed by default; "how to verify" as secondary action) may be correct precisely because most voters will not use it. The receipt's primary job is psychological confirmation, not cryptographic audit.
- For the subset of voters who *do* verify, the quality of the verification flow matters enormously — a verification failure (network error, confusing feedback) may produce more distrust than no verification affordance at all.

This creates a design tension that the PIUP does not fully resolve: optimizing for the majority (psychological confirmation) may degrade the experience for the auditing minority.

### Cryptography as UX constraint

Cameron et al. (2022) on mental models in end-to-end encrypted messaging (Signal, WhatsApp) and Ruoti et al. (2019) on PGP usability establish that cryptographic properties — when they are real constraints that affect user behavior — need to be surfaced in the UI, but surfaced in ways that produce correct security behaviors without correct technical understanding.

The PIUP's core design move — "the receipt does not contain your vote; this is the feature, not the limitation" — is this kind of surfacing. Whether it succeeds depends on whether users understand why absent-content is protective, not just that it is. This is an empirical question.

---

## The design space: why this is generalizable

The PIUP is not specific to voting. The problem class has this structure:

1. A user submits private content to a public or semi-public system
2. The system records that a submission occurred, without revealing the content
3. The user may later need to confirm their submission was received

This structure appears in: anonymous whistleblower systems, sealed-bid auctions, blind peer review, private asset deposits, sealed academic submissions. In each case, the same design questions arise:

- What identifier does the receipt contain, and what does it reveal?
- How does the user understand the distinction between "your submission was counted" and "your submission's content is known"?
- What verification affordance exists, and when does the user actually use it?

No prior work in HCI has studied this problem class in the abstract. The PIUP is a first attempt at naming the pattern and specifying its invariants across the class.

---

## Evaluation agenda

The following user study program would establish whether the PIUP design decisions produce the claimed behaviors. The three studies form a sequential arc: isolate the label effect first, then test the explanation effect and calibration interventions, then measure real-world verification behavior.

| Study | Central question | Method | Status |
|-------|-----------------|--------|--------|
| 1 | Does identifier label affect privacy mental model? | 4-condition between-subjects screenshot study (Prolific, N=280) | Pre-registered; OSF upload + pilot pending |
| 2 | Does absent-choice explanation affect trust and save behavior? Can calibration reduce over-confidence? | 2×2 L×E between-subjects interactive prototype study + calibration factor I (Prolific, N=240) | Design note written; finalise after Study 1 pilot |
| 3 | Do users actually return to verify? What predicts verification? | Longitudinal field study in live DAO deployment | Deferred until Study 2 complete |

### Study 1: Receipt label and privacy mental model

**Question:** Does the identifier label on a private voting receipt — fingerprint, confirmation code, nullifier, or receipt ID — affect the user's mental model of what that receipt proves?

**Method:** 4-condition between-subjects screenshot study on Prolific (n=70 per condition, N=280). Participants see a static receipt image after a simulated vote. Four comprehension questions (Q1–Q4) test whether they believe: the system knows their choice, showing the receipt would reveal their vote, the identifier proves how they voted, and the receipt's absence of their choice is a failure or a feature. One open-text probe (Q5). Primary endpoint: Q2 ("does this prove how I voted?") for conditions A vs B (fingerprint vs. confirmation code).

**Pre-registered hypotheses (4 families, 14 tests, Holm correction):** H1 — fingerprint/confirmation code outperform nullifier on Q2/Q3. H2 — fingerprint and confirmation code are accuracy-equivalent overall (±10pp TOST composite), but diverge on Q2/Q3 specifically. H3 — control condition scores lower than all labelled conditions on Q1. H4 — confirmation code produces highest confidence with moderate accuracy (calibration failure).

**Status:** Pre-registered. OSF artifacts committed to repo (pre-reg, R analysis script, survey instrument, Qualtrics setup guide). Pilot: N=40, 10 per condition, before full launch. See [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) and [`analysis/piup-study1-analysis.R`](../analysis/piup-study1-analysis.R).

### Study 2: Absent-content interpretation and trust calibration

**Question:** Do users interpret the absence of vote choice in the receipt as a failure (the system didn't record it) or a design decision (the system intentionally omitted it)? And can an accuracy-feedback calibration intervention close the gap for over-confident users?

**Method:** 2×2 L×E between-subjects factorial experiment on Prolific (N=240, 8 cells × 30), with an additional calibration factor I crossing L × E.

- **Factor L (Label):** vote fingerprint vs. confirmation code
- **Factor E (Explanation):** explicit absent-choice explanation present vs. absent
- **Factor I (Intervention):** accuracy-feedback calibration before receipt display vs. no calibration

Unlike Study 1 (static screenshots), Study 2 uses an **interactive prototype** — participants interact with a simulated voting flow and receive a receipt. This enables behavioral intention measures (download-click proxy for save intention) and within-session calibration.

**Primary measures:** M1 — absent-content accuracy on Q-AC ("is your vote shown in this receipt?"); M2 — trust score (McKnight M2 scale, 4-item); M3 — save intention (self-report + download affordance click proxy); M4 — confidence miscalibration (confidence − accuracy residual).

**Pre-specified hypotheses (H2.1–H2.4):** H2.1 — E factor main effect on Q-AC accuracy. H2.2 — L × E interaction (confirmation code closes gap to fingerprint when explanation present). H2.3 — I factor reduces confidence miscalibration without reducing save intention. H2.4 — correct absent-content interpretation predicts save intention, moderated by calibration.

**Status:** Design note written. Not yet pre-registered — finalise after Study 1 pilot data, using H4 outcome to calibrate Study 2 primary endpoint selection (contingency table specified in design note). See [`docs/piup-study2-design-note-2026-06-22.md`](piup-study2-design-note-2026-06-22.md).

### Study 3: Deferred verification behavior

**Question:** Do users actually return to verify after the vote closes? What predicts verification — the UI design, the vote stakes, or individual characteristics?

**Method:** Longitudinal field study in a real DAO deployment. Measure: verification rate (fingerprint pastes), time to verification, correlation with vote outcome (winners vs. losers). A public contract function allows this measurement without de-anonymizing voters.

**Implication:** If verification rate is near zero regardless of UI design, the receipt's primary job is psychological, not audit. This would shift the design priority away from verification affordance and toward receipt-permanence (printability, password-manager integration).

---

## Open research questions

1. **The surrogation problem.** The PIUP gives users an opaque identifier that represents their submission. Opaque identifiers are notoriously hard to manage (compare: password management failure modes). What is the natural decay rate for receipt retention? At what point do most voters no longer have access to their fingerprint?

2. **Coercion via UI observation.** The receipt protects against after-the-fact coercion (show me your receipt). It does not protect against concurrent observation (the coercer watches the screen). What UI patterns (e.g., blur during vote, no-screenshot affordance, rapid close) reduce concurrent observation risk without making the voting experience aversive?

3. **Transfer to other problem domains.** Does the PIUP design vocabulary ("fingerprint," "your submission was counted, not your content") transfer to non-voting domains? Do users form the correct mental model in a whistleblower submission system or a sealed-bid auction, or does the voting context carry domain-specific trust that does not generalize?

4. **Expert vs. lay user divergence.** The receipt design was optimized for non-technical users. Crypto-literate users (DAO participants, DeFi users) may form better mental models from technically correct terminology. Is there a design that serves both populations, or does the receipt need to adapt to user expertise?

---

## Why now

The convergence of three conditions makes this a tractable research moment:

1. **ZK proofs in production browsers.** Browser-side ZK proof generation (via WASM, as used in this project) has moved from research prototypes to deployed products in 2025–2026. This makes field studies of actual ZK voting users feasible for the first time.

2. **DAO governance as a natural lab.** DAOs conduct hundreds of contested votes per year, on publicly observable infrastructure, with pseudonymous voters who have strong preferences about outcomes. This is a natural experiment environment for studying verification behavior and receipt retention without recruiting from a lab pool.

3. **The gap is documented.** The PSE report explicitly flags UX/product as the remaining unsolved problem. The research agenda is not speculative — it is directly responsive to a gap statement from a major survey of the field.

---

## The Georgia Tech connection

Georgia Tech HCI's Security and Privacy research area engages exactly this problem class: the gap between technically correct privacy mechanisms and user behavior. Prior work in this area (Das et al., 2014 on nudges for privacy; Felt et al. on permission UX) has established the research program: when users make suboptimal privacy decisions, is it because of the system's feedback, the user's mental model, or something about the decision context?

The PIUP and the evaluation agenda above fit cleanly into this program. The specific contribution is a design space that has not been previously formalized: private submission receipts in ZK-powered systems. The specific research opportunity is that this design space is now observable in the wild, in deployed production systems, for the first time.

---

## What this document is for

This document is intended to be adapted for:

1. **A research statement** for a Georgia Tech HCI PhD application — framing the aztec-private-voting work as a research contribution rather than a product portfolio item
2. **A workshop paper submission** at CHI, SOUPS (Security and Usability of Systems), or the ACM CCS Privacy track — a 4-page design paper that names the PIUP, states the contribution claims, and proposes the evaluation agenda
3. **A conversation with potential faculty advisors** — providing a crisp statement of "here is the research question I care about, here is the prior work, here is the evaluation I would run" that demonstrates research literacy without claiming results not yet produced

The work is real. The implementation exists and is deployed. The design decisions are documented with rationale. The gap between "I built this" and "this is research" is the framing in this document: naming the problem class, positioning against prior work, and proposing the evaluation that would turn design decisions into knowledge claims.

---

## References

- Benaloh, J., and Tuinstra, D. "Receipt-free secret ballot elections." STOC, 1994.
- Adida, B., et al. "Helios: Web-based Open-Audit Voting." USENIX Security, 2008.
- Bell, S., et al. "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." EVT/WOTE, 2013.
- Whitten, A., and Tygar, J. "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." USENIX Security, 1999.
- Cranor, L., and Garfinkel, S. *Security and Usability.* O'Reilly, 2005.
- Das, S., et al. "The role of social influence in security feature adoption." CSCW, 2014.
- Felt, A.P., et al. "Android permissions: User attention, comprehension, and behavior." SOUPS, 2012.
- Everett, S., et al. "Measuring the usability and security of permuted elections on real voters." SOUPS, 2008.
- McKnight, D.H., et al. "Developing and validating trust measures for e-commerce." Information Systems Research, 2002.
- PSE/Shutter Network. *State of Private Voting 2026.* January 2026.
- Amershi, S., et al. "Guidelines for Human-AI Interaction." CHI, 2019.
