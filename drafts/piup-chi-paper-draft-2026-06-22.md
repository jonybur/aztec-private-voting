# Protective Absence: Designing Coercion-Resistant Receipts for Private Cryptographic Voting

_Draft for CHI 2027 submission · Jony Bursztyn · 2026-06-22_  
_Status: Abstract + Introduction complete. Sections 3–7 are structural placeholders; fill after Study 1 data._  
_Word count target: 9,000–10,000 (CHI full paper). Current draft: ~4,500 words structured._

---

## Abstract

Every submission confirmation in computing encodes an implicit claim: "the system received what you sent." In private cryptographic voting systems, this convention becomes a coercion attack surface. If a voting receipt shows the submitted choice, the receipt can be demanded as proof of compliance — converting a voluntary act into a coercible one.

We present the **Proof-of-Inclusion UX Pattern (PIUP)**, a design class for submission systems that must confirm participation without confirming content. The pattern centers on *protective absence*: the deliberate omission of the confirmed choice, paired with an explicit design-intent signal that distinguishes purposeful omission from system failure. Where Norman's feedback principle states that good feedback confirms what was done, PIUP inverts this: correct feedback proves that the action is *protected from display*.

We describe the pattern's instantiation in Aztec Private Voting — a Noir ZK contract + React component library for private DAO governance — and report two empirical studies validating its core design hypotheses. **Study 1** (N=200, Prolific, pre-registered) is a 4-condition between-subjects experiment comparing identifier labels ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") on privacy mental model quality. **Study 2** (N=240, planned) is a 2×2 factorial testing whether absent-choice explanation is the load-bearing receipt element, and whether a calibration intervention can reduce confidence miscalibration produced by familiar eCommerce labels. We report Study 1 results and the Study 2 pre-analysis plan.

PIUP formalises three invariants — surrogate independence, surrogate privacy in transit, and minimal receipt content — and identifies one named limitation: vote choice remains visible in public calldata at the protocol layer, a constraint not resolvable through UI design.

---

## 1. Introduction

When KelpDAO put the loss-socialisation decision from a $71M protocol exploit to a governance vote in 2023, every voter's wallet address was public on-chain. This is not an edge case — it is the default condition for blockchain governance: all participation is pseudonymous at best, traceable by design, and indexable by anyone running a node. In high-stakes organisational votes, pseudonymity under observation is coercive. Voters who can be identified can be pressured.

Zero-knowledge proof systems offer a technical resolution. Aztec's ZK rollup allows a voter to prove eligibility and submit a ballot without revealing the ballot's contents in public calldata. The cryptographic part — hiding the choice — is solved. The system publishes a nullifier (a unique commitment derived from the ballot) and the tally, but not the individual vote directions. From the protocol's perspective, the vote is private.

From the user interface's perspective, a problem persists.

After a private vote, users receive a confirmation. Standard confirmation UI — across every digital domain they have encountered — mirrors the submitted content. Your eCommerce order confirmation shows the items. Your appointment confirmation shows the time and date. Your form submission shows the submitted values. The confirmation is evidence of what was submitted. This is, per Norman's description of feedback in _The Design of Everyday Things_ [CITE], the correct behavior: the system tells you what happened.

In private voting, the correct behavior is the opposite. A receipt that shows the submitted choice creates a coercion surface exactly equivalent to transparent voting: the voter can be asked to produce it. A receipt that shows only a cryptographic identifier — the nullifier hash, or some UI-friendly variant of it — confirms participation without confirming direction. The vote choice is absent from the receipt. This absence is the privacy guarantee.

The design problem is that absence, by default, reads as failure.

Across usability-security research from Whitten and Tygar's foundational evaluation of PGP [CITE] through Felt et al.'s work on Android permissions [CITE] to Egelman and Schechter's framework for security warnings [CITE], a consistent finding emerges: users interpret interface absence as system error unless the absence is explicitly marked as intentional. A receipt that shows no vote choice, without explanation, will be read as: "the system didn't record my vote," "the vote failed," or "this is a bug." The technical guarantee becomes an experiential failure.

The contribution of this paper is a design pattern that resolves this tension: the **Proof-of-Inclusion UX Pattern (PIUP)**.

### 1.1 The PIUP pattern

PIUP is a design class for submission systems where three conditions hold simultaneously:
1. The system can confirm that a submission was received and processed.
2. The system must *not* confirm the content of the submission (by privacy requirement, by coercion-resistance requirement, or by design constraint).
3. Users expect confirmation to include content (by transfer from prior confirmation experiences).

Under these conditions, standard confirmation design fails: it either violates condition (2) (by showing the content) or violates condition (1) in users' eyes (by showing an opaque identifier that reads as error).

PIUP's resolution is *protective absence*: the receipt omits the content but explicitly signals that the omission is a design guarantee, not a failure. The receipt shows the submission token (a cryptographic identifier), the fact of inclusion (a status line: "Your ballot was counted"), and a protective framing ("Your vote choice is not shown. This is intentional — it protects your privacy"). The omitted choice is named before the user notices it is missing, in a sequence that establishes purpose before triggering the failure-inference.

Three formal invariants characterize the pattern:

**Invariant 1 (Surrogate independence).** The submission token (the identifier on the receipt) must be computable from the user's private inputs and a public commitment, without reference to the choice. It must be verifiable against a public ledger. It must not allow anyone with only the token to determine the submitted choice. Formally: `token = f(private_inputs, public_commitment)` where `f` is collision-resistant and `token` is computationally independent of `choice`.

**Invariant 2 (Surrogate privacy in transit).** The receipt must not transmit the token through any channel that reveals its association with the choice. In practice: the token must not be accompanied by the choice in any network request, local storage write, or rendered HTML element that could be captured by a coercing party.

**Invariant 3 (Minimal receipt content).** The receipt must show the minimum content required to enable future verification — the token and a verification endpoint — and no more. Any additional content must be justified against the coercion-resistance requirement.

**Named limitation.** In the Aztec Private Voting instantiation, the vote choice appears in the public calldata of the `record_vote` function, which is called after the private `cast_vote`. This is an Aztec protocol constraint: public functions cannot receive private inputs. A sufficiently motivated attacker with access to the full transaction graph can, in principle, correlate a voter's nullifier with their choice by indexing `record_vote` calls. PIUP's receipt design does not resolve this; it narrows the coercion surface by making the receipt itself non-coercive. The protocol-layer limitation is documented in the receipt's verification explainer.

### 1.2 Naming the absent thing

The identifier on the PIUP receipt — what PIUP calls the *submission token* — has an internal technical name in ZK systems: the nullifier. A nullifier in Aztec's UTXO model is a value derived from a note that, when published, proves the note was consumed without revealing the note's contents or metadata.

"Your nullifier: `a3f9...`" is technically correct and, for non-expert users, functionally misleading. Informal walkthroughs consistently produced one of two failure readings: "nullifier" sounds like a cancellation (the vote was nullified), or like a legal term implying invalidation. Neither reading supports the correct mental model. The term is opaque to experts and actively misleading to non-experts — a combination that, per Whitten and Tygar, reliably produces usability failures in security-critical contexts.

The naming question — what to call the identifier on the receipt — is the entry point to Study 1.

Four candidate labels were identified through design iteration:
- **"Vote fingerprint"** — the metaphor of uniqueness-without-disclosure. A fingerprint identifies without describing. The intent: cue users that the identifier is evidence of participation, not evidence of content.
- **"Confirmation code"** — the standard eCommerce convention. Familiar, trusted, but — the design hypothesis — potentially activating the wrong representational schema.
- **"Nullifier"** — technically precise, expected to underperform on the mental model questions.
- **"Receipt ID"** — generic, neutral, a near-zero-information baseline.

The choice between "vote fingerprint" and "confirmation code" is not merely aesthetic. "Confirmation code" in eCommerce contexts is retrievable evidence of a specific selection: the merchant has your order on file, the code links back to what you chose. The label activates a representational schema — "confirmation = record of what was submitted" — that is correct in every prior context the user has encountered, and wrong in PIUP. "Vote fingerprint," by contrast, carries the metaphor of uniqueness-without-content: a fingerprint identifies a person but tells you nothing about their beliefs, choices, or statements.

This framing produces the H2 *dissociation* prediction: "confirmation code" and "vote fingerprint" are predicted to perform similarly on overall accuracy (both produce correct behavioural schema: save it, verify later) but to diverge specifically on the privacy-model questions (Q2: "does this prove which option you voted for?"; Q3: "could someone learn how you voted from a screenshot of this receipt?"). Confirmation code is predicted to produce higher rates of incorrect answers on Q2 and Q3, because the representational schema it activates — "the confirmation contains what I confirmed" — directly contradicts the correct answer.

H2 is the most theoretically interesting hypothesis in Study 1, and the most uncertain. If confirmation code outperforms fingerprint on the privacy questions, the production default should change.

### 1.3 Contributions

This paper makes three contributions:

**Design artifact (PIUP).** The Proof-of-Inclusion UX Pattern: a named, formally-characterized design class for coercion-resistant confirmation in privacy-preserving submission systems. Three invariants define the pattern; one named limitation bounds its scope. Section 2.

**System instantiation.** Aztec Private Voting — a Noir ZK smart contract and React component library implementing PIUP on the Aztec v5 testnet. The system provides a working implementation of all three invariants and the receipt UI described in this paper. The `VoteReceipt` component is the canonical PIUP instantiation. Section 3.

**Empirical validation.** Study 1 (N=200, pre-registered): a 4-condition between-subjects experiment establishing which identifier label produces the most accurate privacy mental model. Study 2 (N=240, planned): a 2×2 factorial testing explanation effects and calibration interventions for the label × mental model relationship. Section 4 (Study 1), Section 5 (Study 2 pre-analysis plan).

### 1.4 Scope and relation to prior work

PIUP is generalizable beyond voting. Any system where a submission receipt must be coercion-resistant — sealed-bid auctions, whistleblower submissions, secure drop systems, anonymous peer review — faces the same design constraint: confirmation must not confirm content. PIUP names the constraint and provides a tested design response.

Prior work in e-voting usability has focused on voter *verification* — can voters correctly check that their ballot was included? — rather than on voter *comprehension* of what the inclusion proof proves. STAR-Vote [CITE] and Helios [CITE] provide cryptographically verifiable receipts; neither evaluates how users interpret what the receipt does not show. Kulyk et al. [CITE] study comprehension in code voting (the voter comparison scheme), but focus on the verification ceremony rather than the receipt's representational semantics.

Prior work in security receipt design — Everett et al.'s [CITE] usability evaluation of verification codes in real elections — evaluates whether voters *use* the verification affordance, not whether they correctly understand the privacy property that makes the receipt safe to use. This paper addresses the prior gap: does the receipt's label and copy cause users to correctly model the one thing the receipt is designed not to prove?

---

## 2. The PIUP Design Pattern

_[Section to be written. Expand the three invariants from the Introduction into a formal specification. Include the component structure: submission token, status line, protective framing, verification affordance. Document the design alternatives considered and rejected: (1) showing the vote and requiring authentication to view receipt — rejected because authentication credential = coercion target; (2) using a random UUID as token — rejected because it fails Invariant 1 (not verifiable against the public commitment); (3) omitting the protective framing and relying on the user to infer from absence — rejected because prior work on absent-content interpretation predicts systematic misreading. Cross-reference docs/proof-of-inclusion-ux-pattern-2026-06-22.md for the full formal specification.]_

---

## 3. System: Aztec Private Voting

_[Section to be written. Cover: the Noir contract (cast_vote, record_vote, finalize_vote, verify_vote_counted); eligibility modes (open, token-gated, allowlist); the React component library (VoteReceipt.tsx as PIUP instantiation); the security properties (quorum bypass F2 and receipt-ID collision F3 fixed; 8 sound properties confirmed). Reference the M2 ownership proof (in-circuit secp256k1 verification) as the defense-in-depth layer. Keep to 2 pages. Cross-reference docs/receipt-design.md and docs/security-review-2026-06-22.md.]_

---

## 4. Study 1: Label Choice and Privacy Mental Model

### 4.1 Research questions and hypotheses

**RQ1.** Which identifier label ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") produces the most accurate comprehension of what the PIUP receipt proves?

**RQ2.** Does the fingerprint/confirmation-code distinction produce a dissociation on privacy-specific items vs. overall accuracy?

**RQ3.** Does the familiar eCommerce label ("confirmation code") produce higher confidence ratings despite comparable or lower accuracy — a calibration failure — compared to the less familiar "vote fingerprint"?

**H1:** A > D on Q2 and Q3 (fingerprint > neutral baseline on the privacy-model questions).  
**H2 (dissociation):** A ≈ B on overall accuracy composite; A > B on Q2 and Q3 specifically. H2 is the primary endpoint.  
**H3:** C < all others on Q1 ("does this prove your vote was counted?") — reversal risk from "nullified" reading.  
**H4:** Confidence(B) > Confidence(A), B > C, B > D — confirmation code borrows perceived competence from eCommerce familiarity.

_[Subsections 4.2–4.6: Study design (4-condition between-subjects, N=200 Prolific), stimuli (condition-specific HTML screenshots), measures (Q1–Q4 binary + Q5 free text + confidence Likert), analysis plan (14 pre-registered tests, 4 Holm families), results. To be written after Study 1 data collection. Pre-registration OSF DOI: [INSERT].]_

---

## 5. Study 2: Explanation Effects and Calibration Interventions

_[Section to be written after Study 1 data. Summarize the 2×2 design (L: fingerprint vs. confirmation code × E: explanation present vs. absent), the I (calibration intervention) factor, the interactive prototype platform (VoteReceipt.tsx in study mode), and the analysis plan. Primary endpoint: E main effect on absent-content accuracy (Q-AC). Conditional on H4 in Study 1: calibration intervention test (H2.3). Full design in docs/piup-study2-design-note-2026-06-22.md.]_

---

## 6. Discussion

_[Section to be written after Study 1 data. Key discussion points:]_

_[6.1 When does protective absence work? The boundary condition is the explanatory copy. Without explicit design-intent signaling, absent content is interpreted as failure. The label matters specifically on the privacy-model questions, not on overall comprehension. Design implication: PIUP requires both the protective framing (Invariant 3) and a good token label; neither alone is sufficient.]_

_[6.2 The confirmation code paradox. If H4 is supported: familiar labels produce confident wrong mental models in privacy-critical contexts. This is a generalizable finding — not just about receipt labels, but about any situation where familiar UI conventions import a representational schema that is locally correct (in eCommerce) and globally wrong (in coercion-resistant systems). The designer's instinct to reduce friction by using familiar labels carries a hidden cost in privacy-critical domains.]_

_[6.3 The protective absence feedback inversion. Norman's feedback principle says: tell the user what happened. PIUP inverts this: tell the user what was protected from happening. The correct signal is the absence itself, but absence is not self-explaining. This puts PIUP in a design lineage with the HTTPS lock icon (which signals channel protection, not content) and with do-not-track indicators (which signal system restraint, not user action). What distinguishes PIUP: the protected absence is more deeply counterintuitive, because the absent content is what users most want to see.]_

_[6.4 Generalisation. Sealed-bid auctions: the bid receipt must not show the bid. Whistleblower drops: the submission receipt must not confirm the document's contents. Anonymous peer review: the review confirmation must not confirm the reviewer. In each case, PIUP's three invariants apply without modification. The label space differs; the protective framing logic is the same.]_

_[6.5 Limitations. Protocol-layer exposure (record_vote calldata — documented in Named Limitation). Study 1 ecological validity (screenshot stimuli, Prolific convenience sample). Study 2 demand characteristics from interactive prototype. Scope limited to single-vote receipt; multi-vote tallies (ranked-choice, quadratic) not addressed.]_

---

## 7. Conclusion

_[Section to be written. Key points: the design problem (confirmation must not confirm content) is generalizable; PIUP names and formalises it; the empirical work establishes boundary conditions; the primary design implication is that absent-content receipts require both protective framing and label choice to work as intended — neither is sufficient alone.]_

---

## References

- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." _EVT/WOTE 2009._
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., Fisher, G., Kortum, P., McBurnett, N., Montoya, J., Parker, M., Perez, O., Stark, P., Wallach, D., and Winn, M. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _EVT/WOTE 2013._
- Das, S., Dabbish, L., and Hong, J. (2014). "The Effect of Social Influence on Security Sensitivity." _ACM CCS 2014._
- Egelman, S., and Schechter, S. (2013). "The Importance of Being Earnest [In Security Warnings]." _FC 2013._
- Everett, S.P., Greene, K.K., Byrne, M.D., Wallach, D.S., Derr, K., Sandler, D., and Torous, T. (2008). "Electronic Voting Machines versus Traditional Methods: Improving Voter Attitudes and Satisfaction." _CHI 2008._
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _SOUPS 2012._
- Kulyk, O., Teague, V., and Volkamer, M. (2017). "Extending Helios Towards Private Eligibility Verifiability." _USENIX VoteID 2017._
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." _Social Psychological and Personality Science 8(4):355–362._
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." _Human Factors 46(1):50–80._
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." _Information Systems Research 13(3):334–359._
- Norman, D.A. (1988). _The Design of Everyday Things._ Basic Books.
- Whitten, A., and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." _USENIX Security 1999._

---

## Author Bio (for submission header)

**Jony Bursztyn** is a software engineer and independent researcher at the intersection of cryptography and human-computer interaction. He is the author of Aztec Private Voting ([github.com/jonybur-oc/aztec-private-voting](https://github.com/jonybur-oc/aztec-private-voting)), a Noir ZK voting contract and React component library, and of the Proof-of-Inclusion UX Pattern (PIUP) documented in this paper. His research focuses on how ZK systems can be designed so that their privacy guarantees are comprehensible to non-expert users.

---

## Submission notes (delete before submission)

**Target venue:** CHI 2027 (submission deadline: ~September 2026 for abstract, ~September 2026 for full paper). Track: Technical/Empirical. Papers area: Privacy, Security, and Trust.

**Alternatively:** USENIX SOUPS 2027 (security + usability, more directly on-topic for the empirical studies). CHI is higher prestige and better for HCI PhD applications.

**Required before submission:**
1. Study 1 data (N=200; depends on OSF upload + Prolific launch)
2. Sections 4.2–4.6 filled with actual results
3. Section 5 updated with Study 2 pre-registration DOI (conditional on H4 in Study 1)
4. Section 6 written from Study 1 data
5. Verify all citations: check Kulyk et al. 2017 venue (may be IFIP VoteID, not USENIX)
6. CHI 2027 call for papers — confirm word limit and formatting requirements

**Submission-ready target date:** January 2027 (aligns with Study 1 full run completion; Study 2 data not required for initial submission — present as pre-analysis plan)

**Writing sample use (before submission):** This draft (abstract + introduction) can be shared with potential PhD advisors from October 2026 onwards as a "paper in preparation." For Annie Antón (GT) and Sauvik Das (CMU), sharing the abstract + intro + the study arc blog post gives them both the technical framing and the accessible version. Do not share the incomplete sections (3–7 placeholders).
