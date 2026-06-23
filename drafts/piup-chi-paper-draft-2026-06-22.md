# Protective Absence: Designing Coercion-Resistant Receipts for Private Cryptographic Voting

_Draft for CHI 2027 submission · Jony Bursztyn · 2026-06-22_
_Status: Abstract + Introduction complete. Sections 3-7 are structural placeholders; fill after Study 1 data._
_Word count target: 9,000-10,000 (CHI full paper). Current draft: ~4,500 words structured._

---

## Abstract

Every submission confirmation in computing encodes an implicit claim: "the system received what you sent." In private cryptographic voting systems, this convention becomes a coercion attack surface. If a voting receipt shows the submitted choice, the receipt can be demanded as proof of compliance - converting a voluntary act into a coercible one.

We present the **Proof-of-Inclusion UX Pattern (PIUP)**, a design class for submission systems that must confirm participation without confirming content. The pattern centers on *protective absence*: the deliberate omission of the confirmed choice, paired with an explicit design-intent signal that distinguishes purposeful omission from system failure. Where Norman's feedback principle states that good feedback confirms what was done, PIUP inverts this: correct feedback proves that the action is *protected from display*.

We describe the pattern's instantiation in Aztec Private Voting - a Noir ZK contract + React component library for private DAO governance - and report two empirical studies validating its core design hypotheses. **Study 1** (N=280, Prolific, pre-registered) is a 4-condition between-subjects experiment comparing identifier labels ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") on privacy mental model quality. **Study 2** (N=240, planned) is a 2×2×2 factorial (Label × Explanation × Calibration Intervention) testing whether absent-choice explanation is the load-bearing receipt element, and whether a calibration intervention can reduce confidence miscalibration produced by familiar eCommerce labels. We report Study 1 results and the Study 2 pre-analysis plan.

PIUP formalises three invariants - surrogate independence, surrogate privacy in transit, and minimal receipt content - and identifies one named limitation: vote choice remains visible in public calldata at the protocol layer, a constraint not resolvable through UI design.

---

## 1. Introduction

When KelpDAO put the loss-socialisation decision from a $71M protocol exploit to a governance vote in 2023, every voter's wallet address was public on-chain. This is not an edge case - it is the default condition for blockchain governance: all participation is pseudonymous at best, traceable by design, and indexable by anyone running a node. In high-stakes organisational votes, pseudonymity under observation is coercive. Voters who can be identified can be pressured.

Zero-knowledge proof systems offer a partial technical resolution. Aztec's ZK rollup makes it possible in principle for a voter to prove eligibility and submit a ballot without revealing the ballot's contents in public calldata. At the private state layer, the cryptographic part - hiding the choice - is solved: the system publishes a nullifier (a unique commitment derived from the ballot) and the tally, but not the individual vote directions. The current implementation retains a named limitation at the calldata layer (§1.1); from the state-layer perspective, the vote is private.

From the user interface's perspective, a problem persists.

After a private vote, users receive a confirmation. Standard confirmation UI - across every digital domain they have encountered - mirrors the submitted content. Your eCommerce order confirmation shows the items. Your appointment confirmation shows the time and date. Your form submission shows the submitted values. The confirmation is evidence of what was submitted. This is, per Norman's description of feedback in _The Design of Everyday Things_ (1988), the correct behavior: the system tells you what happened.

In private voting, the correct behavior is the opposite. A receipt that shows the submitted choice creates a coercion surface exactly equivalent to transparent voting: the voter can be asked to produce it. A receipt that shows only a cryptographic identifier - the nullifier hash, or some UI-friendly variant of it - confirms participation without confirming direction. The vote choice is absent from the receipt. This absence is the privacy guarantee.

The design problem is that absence, by default, reads as failure.

Across usability-security research from Whitten and Tygar's foundational evaluation of PGP (1999) through Felt et al.'s work on Android permissions (2012) to Egelman and Schechter's framework for security warnings (2013), a consistent finding emerges: users interpret interface absence as system error unless the absence is explicitly marked as intentional. A receipt that shows no vote choice, without explanation, will be read as: "the system didn't record my vote," "the vote failed," or "this is a bug." The technical guarantee becomes an experiential failure.

The contribution of this paper is a design pattern that resolves this tension: the **Proof-of-Inclusion UX Pattern (PIUP)**.

### 1.1 The PIUP pattern

PIUP is a design class for submission systems where three conditions hold simultaneously:
1. The system can confirm that a submission was received and processed.
2. The system must *not* confirm the content of the submission (by privacy requirement, by coercion-resistance requirement, or by design constraint).
3. Users expect confirmation to include content (by transfer from prior confirmation experiences).

Under these conditions, standard confirmation design fails: it either violates condition (2) (by showing the content) or violates condition (1) in users' eyes (by showing an opaque identifier that reads as error).

PIUP's resolution is *protective absence*: the receipt omits the content but explicitly signals that the omission is a design guarantee, not a failure. The receipt shows the submission token (a cryptographic identifier), the fact of inclusion (a status line: "Your ballot was counted"), a protective framing ("Your vote choice is not shown. This is intentional - it protects your privacy"), and a verification affordance (a collapsed mechanism for confirming inclusion at a later time; §2.1). The omitted choice is named before the user notices it is missing, in a sequence that establishes purpose before triggering the failure-inference.

Three formal invariants characterize the pattern:

**Invariant 1 (Surrogate independence).** The submission token (the identifier on the receipt) must not be derivable from the submission content, the user's identity, or any publicly observable system state; it must not allow anyone holding only the token to determine the submitted choice. Formally: `token = f(random_seed)` where `f` produces a value in a space large enough to make collision negligible and `token` is computationally independent of `choice`. The token must be verifiable against a public ledger - `isInLedger(token) → bool` - without that lookup revealing the content (§2.1).

**Invariant 2 (Surrogate privacy in transit).** Because the token travels with the content during submission, any observable record of the submission can link token to content. The token must be treated as private until the content is definitionally public (vote closes, auction reveals). After that event, the link in the execution record is no longer actionable for coercion.

**Invariant 3 (Minimal receipt content).** The receipt artifact must contain only what is needed to enable future verification: the token and a verification endpoint. No additional field is added without a justification against the coercion-resistance requirement. Specifically, the receipt must not contain the submission content, the user's identity, or any derivative that allows an observer to infer either.

**Named limitation.** In the Aztec Private Voting instantiation, the vote choice appears in the public calldata of the `record_vote` function, which is called after the private `cast_vote`. This is a constraint of the current Aztec v5 contract architecture: public functions cannot receive private inputs as calldata arguments. A sufficiently motivated attacker with access to the full transaction graph can, in principle, correlate a voter's receipt identifier (fingerprint) with their choice by indexing `record_vote` calls — because `record_vote` takes both `receipt_id` and `vote_choice` as plaintext calldata arguments (the nullifier, the double-vote-prevention mechanism, is a separate value in the private kernel output and is distinct from the fingerprint; see §3.1). PIUP's receipt design does not resolve this; it narrows the coercion surface by making the receipt itself non-coercive. The protocol-layer limitation is documented in the receipt's verification explainer and discussed in §3.3 (L1 privacy gap) and §6.5.

### 1.2 Naming the absent thing

The identifier on the PIUP receipt - what PIUP calls the *submission token* - has an internal technical name in ZK systems: the nullifier. A nullifier in Aztec's UTXO model is a value derived from a note that, when published, proves the note was consumed without revealing the note's contents or metadata.

"Your nullifier: `a3f9...`" is technically correct and, for non-expert users, functionally misleading. Informal walkthroughs consistently produced one of two failure readings: "nullifier" sounds like a cancellation (the vote was nullified), or like a legal term implying invalidation. Neither reading supports the correct mental model. The term is opaque to experts and actively misleading to non-experts - a combination that, per Whitten and Tygar, reliably produces usability failures in security-critical contexts.

The naming question - what to call the identifier on the receipt - is the entry point to Study 1.

Four candidate labels were identified through design iteration:
- **"Vote fingerprint"** - the metaphor of uniqueness-without-disclosure. A fingerprint identifies without describing. The intent: cue users that the identifier is evidence of participation, not evidence of content.
- **"Confirmation code"** - the standard eCommerce convention. Familiar, trusted, but - the design hypothesis - potentially activating the wrong representational schema.
- **"Nullifier"** - technically precise, expected to underperform on the mental model questions.
- **"Receipt ID"** - generic, neutral, a near-zero-information baseline.

The choice between "vote fingerprint" and "confirmation code" is not merely aesthetic. "Confirmation code" in eCommerce contexts is retrievable evidence of a specific selection: the merchant has your order on file, the code links back to what you chose. The label activates a representational schema - "confirmation = record of what was submitted" - that is correct in every prior context the user has encountered, and wrong in PIUP. "Vote fingerprint," by contrast, carries the metaphor of uniqueness-without-content: a fingerprint identifies a person but tells you nothing about their beliefs, choices, or statements.

This framing produces the H2 *dissociation* prediction: "confirmation code" and "vote fingerprint" are predicted to perform similarly on overall accuracy (both produce correct behavioural schema: save it, verify later) but to diverge specifically on the privacy-model questions (Q2: "does this prove which option you voted for?"; Q3: "could someone learn how you voted from a screenshot of this receipt?"). Confirmation code is predicted to produce higher rates of incorrect answers on Q2 and Q3, because the representational schema it activates - "the confirmation contains what I confirmed" - directly contradicts the correct answer.

H2 is the most theoretically interesting hypothesis in Study 1 (pre-registered test specifications: §4.5), and the most uncertain. The schema-import mechanism that motivates H2 — why "confirmation code" activates a representational schema that contradicts the correct privacy model — is discussed in §6.2. If confirmation code outperforms fingerprint on the privacy questions, the production default should change.

### 1.3 Contributions

This paper makes three contributions:

**Design artifact (PIUP).** The Proof-of-Inclusion UX Pattern: a named, formally-characterized design class for coercion-resistant confirmation in privacy-preserving submission systems. Three invariants define the pattern; one named limitation bounds its scope. Invariants: §2.1. Named limitation: §1.1, §3.3.

**System instantiation.** Aztec Private Voting - a Noir ZK smart contract and React component library implementing PIUP on the Aztec v5 testnet. The system provides a working implementation of all three invariants and the receipt UI described in this paper. The `VoteReceipt` component is the canonical PIUP instantiation. Section 3.

**Empirical validation.** Study 1 (N=280, pre-registered): a 4-condition between-subjects experiment establishing which identifier label produces the most accurate privacy mental model. Study 2 (N=240, planned): a 2×2×2 factorial (L × E × I; 8 cells, n=30/cell) testing explanation effects and calibration interventions for the label × mental model relationship. Section 4 (Study 1), Section 5 (Study 2 pre-analysis plan).

### 1.4 Scope and relation to prior work

PIUP is generalizable beyond voting. Any system where a submission receipt must be coercion-resistant - sealed-bid auctions, whistleblower submissions, secure drop systems, anonymous peer review - faces the same design constraint: confirmation must not confirm content. PIUP names the constraint and provides a tested design response.

Prior work in e-voting usability has focused on voter *verification* — can voters correctly check that their ballot was included? — rather than on voter *comprehension* of what the inclusion proof proves. STAR-Vote (Bell et al. 2013) and Helios (Adida et al. 2009) provide cryptographically verifiable receipts; neither evaluates how users interpret what the receipt does not show. Marky et al. (2018) conduct a 95-participant remote e-voting study at CHI evaluating three approaches to the Benaloh Challenge (cast-as-intended verification); their study measures whether voters successfully complete verification and their perceived workload, not voters' representational models of what the receipt proves or withholds. Kulyk et al. (2015) extend Helios to provide private eligibility verifiability (hiding voter participation via dummy ballots); their work addresses cryptographic transparency, not receipt representational semantics. No prior work directly examines what voters *believe* a cryptographic receipt reveals about their vote choice.

Prior work in security receipt design - Everett et al.'s (2008) usability evaluation of verification codes in real elections - evaluates whether voters *use* the verification affordance, not whether they correctly understand the privacy property that makes the receipt safe to use. This paper addresses the prior gap: does the receipt's label and copy cause users to correctly model the one thing the receipt is designed not to prove?

---

## 2. The PIUP Design Pattern

### 2.1 Formal specification

The Proof-of-Inclusion UX Pattern applies to any system satisfying three conditions simultaneously: (1) the system can confirm that a submission was received and processed; (2) the system must *not* confirm the content of the submission; and (3) users approach the interaction with prior confirmation experiences that lead them to expect content in the confirmation.

Under these conditions, the receipt is built from four components, listed in the order they appear in the rendered receipt:

**Status line.** A direct statement that the submission was received and processed: *"Your ballot was counted"* or equivalent. [VERIFIED tick-3767: tense aligned with §1.3 example; actual implementation text is 'Your vote was cast' (§3.4/VoteReceipt.tsx line 80); §2.1 is pattern-canonical, §3.4 is implementation-specific — both correct.] The status line must appear before any other receipt content. Per Egelman and Schechter (2013), users who encounter unexpected content sequences will pattern-match from prior experience; placing the status line first anchors the user's interpretation before the absent content becomes salient.

**Submission token.** A surrogate identifier for the submission event, given to the user as the receipt's primary artifact. The token must satisfy three invariants:

*Invariant 1 (Surrogate independence).* The token must not be derivable from the submission content, the user's identity, or any publicly observable system state; it must not allow anyone holding only the token to determine the submitted choice. Formally: `token = f(random_seed)` where `f` produces a value in a space large enough to make collision negligible and `token` is computationally independent of `choice`. The token must be verifiable against a public ledger - `isInLedger(token) → bool` - without that lookup revealing the content.

*Invariant 2 (Surrogate privacy in transit).* Because the token travels with the content during submission, any observable record of the submission can link token to content. The token must be treated as private until the content is definitionally public (vote closes, auction reveals). After that event, the link in the execution record is no longer actionable for coercion.

*Invariant 3 (Minimal receipt content).* The receipt artifact must contain only what is needed to enable future verification: the token and a verification endpoint. No additional field is added without a justification against the coercion-resistance requirement. Specifically, the receipt must not contain the submission content, the user's identity, or any derivative that allows an observer to infer either.

**Protective framing.** An explicit signal that the absent content is a design guarantee, not a system failure. The framing must (a) name the absent content before the user notices it is missing - before the failure-inference can form - and (b) attribute the absence to a property of the system, not to a limitation: *"Your vote choice is not shown here. This is intentional - the receipt is designed to prove you voted without revealing what you voted for."* Without this component, users apply the default interpretation for absent confirmation content: error, incomplete transaction, or untrustworthy system [Whitten and Tygar 1999; Egelman and Schechter 2013].

**Verification affordance.** A persistent but non-intrusive mechanism for the user to confirm inclusion at a later time: *"When the vote closes, you can paste your vote fingerprint at [verification URL] to confirm it was counted."* [Note: `[verification URL]` is a pending placeholder — to be replaced with the deployed `verify_vote_counted` endpoint URL before CHI submission.] The affordance is collapsed by default; expanding it by default would displace the primary status line downward and compete for initial attention at the confirmation step, where users' primary goal is confirming their ballot was counted rather than auditing it immediately. Collapsed by default, it functions as a second-pass tool without competing with the primary confirmation. [JONY-ACTION G: The original draft cited 'unpublished pilot study, N=12' for this design decision. No documentation of this pilot was found in the repo (tick-3767 search). Before CHI submission: (a) if the pilot was run and documented, restore the empirical citation; (b) if it was not run, the design-rationale reframe above is CHI-safe. Do not leave an undocumented 'unpublished pilot study' claim in the final submission.]

### 2.2 Design alternatives considered and rejected

Three alternative designs were explored during system development and rejected on coercion-resistance grounds.

**Alternative 1: Show the vote choice, require authentication to view the receipt.** The receipt would contain the full submission, but be protected behind a credential (e.g., wallet signature). Rejected: the authentication credential itself becomes the coercion target. A coercer who cannot obtain the receipt can instead coerce the voter into signing an authentication message. The attack surface shifts from receipt content to receipt access; it does not shrink.

**Alternative 2: Use a random UUID as the submission token, without protocol binding.** A random 128-bit UUID would satisfy the independence sub-condition of Invariant 1 - it is not derivable from content, identity, or observable state - and could be stored locally. Rejected on Invariant 1 grounds: Invariant 1 requires not only independence but verifiability against a public ledger (`isInLedger(token) → bool`). A token that is not verifiable against a public commitment proves nothing to the voter or to a third party. The voter has a random number; they have no way to distinguish a genuine token from one generated by a compromised frontend. PIUP requires that the token be verifiable against the submission event, not merely random.

**Alternative 3: Omit the protective framing, rely on user inference from absence.** Prior work on absent-content interpretation [Whitten and Tygar 1999; Egelman and Schechter 2013] consistently finds that users interpret absent expected content as failure unless absence is explicitly marked as intentional. In the receipt context, a voter who sees no vote choice and no explanation will conclude their vote was not recorded or that the transaction failed. This creates a distinct failure mode that is, from a participation standpoint, worse than a coercible receipt: a coercible receipt at least confirms that the ballot was counted (at the cost of revealing the choice); absent framing provides no confirmation at all, leaving the user to believe their participation was ineffective and potentially attempt to vote again. This comparison is a design inference not directly tested by the cited absent-content literature; Study 1's Q1 measure ("vote was counted") is designed to test one leg of this — whether users with protective framing correctly identify that their vote was counted — but cannot isolate the framing contribution (Study 1 includes no without-framing baseline), and the direct coercible-vs.-absent comparison remains a design claim. The protective framing is a load-bearing component, not decorative copy.

---

## 3. System: Aztec Private Voting

Aztec Private Voting is a Noir ZK smart contract and React component library implementing the PIUP on the Aztec v5 testnet. It provides the canonical instantiation of the pattern described in Section 2 and is the system on which Studies 1 and 2 are run.

### 3.1 The Noir contract

The contract is structured as a single `PrivateVoting` Noir program with four principal entrypoints:

**`cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** - the private entrypoint. Called client-side; generates a ZK proof. The proof enforces double-vote prevention via a `SingleUseClaim` nullifier derived from the voter's Aztec spending keys inside the private kernel. The nullifier is not the vote fingerprint; it is the mechanism that prevents reuse of the voter's claim. After the private proof is generated, `cast_vote` enqueues a call to `record_vote`.

**`record_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** - the public entrypoint, callable only by the contract's own private entrypoints (enforced by the `#[only_self]` decorator; all `cast_vote*` functions enqueue it via `self.enqueue_self`). Increments the tally counter for `vote_choice`, validates that `receipt_id` has not been previously used, and marks `receipts[receipt_id] = true`. The `receipt_id` is the user-visible vote fingerprint; it is content-independent (not derived from the vote choice). In the standard `cast_vote` path it is a client-generated random field (`Fr.random()`; see §3.4); in the Babylon eligibility paths (`cast_vote_babylon`, `cast_vote_babylon_v2`) it is a deterministic nullifier derived from the holder's snapshot leaf or signing-key signature respectively (see §3.5).

**`finalize_vote()`** - callable after `end_time` if `vote_count >= quorum`. Sets `is_finalized = true`. The tally is the aggregate count, already written incrementally by `record_vote` - `finalize_vote` does not write the tally, it only gates its public visibility via `get_final_tally`'s `assert(is_finalized)`. No event is emitted; callers poll `is_finalized()` or `verify_vote_counted()` to check vote state. Individual choices are not recorded against individual identifiers.

**`verify_vote_counted(receipt_id: Field) → bool`** - public view function. Returns `receipts[receipt_id]`. This is the verification affordance: any holder of a receipt_id can confirm their submission was recorded without the contract revealing anything about the submission's content.

The contract runs on the Aztec v5 testnet. Deployment configuration is detailed in `docs/v5-upgrade-runbook.md`.

### 3.2 Eligibility modes

The system supports three eligibility configurations, deployed as separate contract instances rather than runtime-selected modes (to avoid cross-mode eligibility bypass; see §3.3):

**Open (`cast_vote`).** Any Aztec wallet can vote. The `eligibility_proof` parameter is ignored; the only constraint is that the wallet has not previously voted (enforced by `SingleUseClaim`). Suitable for governance votes where access is defined by token holdership at a snapshot date, enforced off-chain by DAO tooling.

**Token-gated (`cast_vote_token`).** The caller must prove, in-circuit, that they hold a token balance above a configured minimum at a committed snapshot. The eligibility proof is a Merkle membership proof against a `sha256`-keyed balance tree, with leaf format `sha256([0x00] || address_field_bytes[31] || balance_be[8])`. The Merkle root is encoded into the `tokenAddress` deployment parameter using a top-byte-drop scheme documented in `docs/deployment.md`. Balance threshold is enforced inside the circuit before Merkle verification.

**Allowlist (`cast_vote_allowlist`).** The caller must prove membership in a committed set of eligible addresses. The eligibility proof is a Merkle membership proof against a depth-20 SHA-256 Merkle tree with leaf format `sha256([0x00] || address_field_bytes[31])`. The allowlist root is committed at deployment. Suitable for known-participant governance (board votes, committee elections).

A separate deployment per eligibility mode was chosen rather than a runtime flag because a single contract supporting multiple modes creates a cross-mode eligibility bypass surface: a voter who fails the token gate could, in principle, call the generic `cast_vote` entrypoint if eligibility is enforced only inside `record_vote`. The direct guard against this bypass is a runtime assert in the generic `cast_vote` path: `assert(config.eligibility_mode == ELIGIBILITY_MODE_OPEN)`. A TOKEN or ALLOWLIST mode deployment rejects any call to `cast_vote` outright, forcing the caller onto the gated entrypoints where the in-circuit Merkle proof is required. The gated entrypoints additionally assert their own expected mode before performing the Merkle check — preventing them from being invoked on wrong-mode contract instances, which is a separate (reverse) misuse case rather than the bypass case described above.

### 3.3 Security properties

A static circuit analysis and trust-boundary audit was conducted across the generic voting paths (`main.nr`, `eligibility.nr`). Eight properties were confirmed sound:

| Property | Enforcement mechanism |
|---|---|
| Wallet-to-ballot unlinkability | `SingleUseClaim` nullifier in Aztec private kernel |
| No vote after end\_time | `assert(now < config.end_time)` in `record_vote` |
| No finalization before end\_time | `assert(now >= config.end_time)` in `finalize_vote` |
| Tally only shown post-finalization | `assert(is_finalized)` in `get_final_tally` |
| `record_vote` not callable externally | `#[only_self]` decorator |
| Options count bounds | `> 1` and `<= 8` in constructor |
| No `is_finalized` bypass | Separate check in `record_vote` prevents post-finalize votes |
| Timing boundary correctness | At `t == end_time`: cast fails, finalize succeeds |

Three findings were resolved before the study - one HIGH severity and two LOW:

*F1-RESIDUAL (HIGH - gated vote bypass).* After `cast_vote_token` and `cast_vote_allowlist` were added as the F1-HIGH resolution, the generic `cast_vote` entrypoint remained callable on TOKEN and ALLOWLIST mode contracts. A voter who failed the token gate could still call `cast_vote(choice, 1, receipt_id)` - passing `eligibility_proof = 1` satisfies the `verify_eligibility` stub (`proof != 0`), bypassing the Merkle gate entirely. Resolved by adding a mode guard in `cast_vote`: `assert(config.eligibility_mode == ELIGIBILITY_MODE_OPEN, ...)`. Token and allowlist votes must use their respective dedicated entrypoints, which perform the in-circuit Merkle proof before enqueuing `record_vote`.

*F2 (Quorum bypass).* A `quorum = 0` deployment would allow `vote_count >= 0` to be vacuously true, permitting finalization with zero ballots. Resolved by adding `assert(config.quorum > 0)` in the constructor.

*F3 (Receipt-ID collision).* A `receipt_id = 0` submission would succeed and mark `receipts[0] = true`; any subsequent voter submitting `receipt_id = 0` would have their `SingleUseClaim` nullifier spent but their `record_vote` rejected, producing a silent vote loss. Resolved by adding `assert(receipt_id != 0)` in `cast_vote` and a corresponding client-side validation in the React hooks.

Two design limitations are documented and not resolved at the prototype stage:

*L1 privacy gap.* The `vote_choice` and `receipt_id` are plaintext public arguments in `record_vote` (a public function). An observer of the Aztec execution layer can build a `receipt_id → vote_choice` map. A voter who reveals their fingerprint, or shares the downloaded receipt file (which also contains the on-chain transaction hash — a direct `record_vote` lookup path; see §3.4), gives a knowledgeable observer the ability to recover their choice. The receipt UI addresses this with explicit copy noting that the receipt should not be shared until the vote finalizes; the protocol-level fix (encrypted ballots — Architecture A in the M2 spike) is on the M2 roadmap.

*Receipt-freeness is partial.* The contract does not implement a re-encryption mix. The commitment not to use the term "coercion-resistant" in user-facing copy until this is resolved is maintained in the receipt component.

### 3.4 React component library and `VoteReceipt.tsx`

The system ships a React component library (`packages/react/`) providing the voter-facing UI including the PIUP instantiation. The key component is `VoteReceipt.tsx`, which renders the four PIUP components described in Section 2.1, listed in their actual rendering order:

- The status line: *"Your vote was cast"*
- The vote fingerprint (rendered as a formatted hex string with a copy button)
- The protective framing: *"Your vote choice is not shown on this receipt. This is intentional — this fingerprint proves your ballot was counted without revealing what you voted for. Save it to verify after the vote closes, and keep it private until then."*
- The verification affordance: a collapsed *"How to verify"* section with a three-step explainer and a link to the `verify_vote_counted` endpoint

The component also provides a primary download action that writes a JSON receipt file. The file is produced by `serializeReceipt()` in `receipt.ts`, which spreads the `VoteReceipt` object — containing the fingerprint (`receiptId`), vote ID, vote title, transaction hash (`txHash`), timestamp, and contract address — after two format envelope fields (`version: 1`, `kind: "aztec-private-voting-receipt"`). The receipt file does not contain the vote choice. This follows Invariant 3 at the content layer: a voter who saves their receipt holds a file that does not encode their choice. Note that the transaction hash field names the on-chain `record_vote` transaction; per the L1 privacy limitation noted in §3.3, an observer who holds both the receipt and access to on-chain calldata can, in principle, use the transaction hash to look up the corresponding `record_vote` call and recover the choice. Voters should treat the receipt as private until vote close, consistent with the privacy guidance in the receipt's protective framing.

The fingerprint is generated by `generateReceiptId()` in `packages/react/src/aztec/receipt-id.ts`, which calls `Fr.random()` to produce a 254-bit random field element. The value is not derived from the voter's wallet, the vote ID, or the vote choice, satisfying Invariant 1 at the client layer.

### 3.5 M2 ownership proof (defense-in-depth)

The M2 milestone added in-circuit secp256k1 ownership verification for Babylon-compatible governance. From the PIUP's perspective, the M2 proof is defense-in-depth: it ensures that the wallet asserting eligibility - by providing a secp256k1 signature over the vote title hash and the Merkle root - is the same wallet that holds the required token, preventing eligibility transfer attacks where one wallet generates an eligibility proof on behalf of another. The M2 path uses EIP-191-compatible message encoding (implemented in `useM2Signing.ts`), which produces `sig_r` and `sig_s` as separate 32-byte components. The caller hook (`useVoteBabylonV2.ts`) combines these into the `sig[64]` format (`r||s`, 64 bytes) expected by the in-circuit secp256k1 verifier. The M2 path does not change the receipt design; `VoteReceipt.tsx` handles all eligibility modes identically.

---

## 4. Study 1: Label Choice and Privacy Mental Model

### 4.1 Research questions and hypotheses

**RQ1.** Which identifier label ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") produces the most accurate comprehension of what the PIUP receipt proves?

**RQ2.** Does the fingerprint/confirmation-code distinction produce a dissociation on privacy-specific items vs. overall accuracy?

**RQ3.** Does the familiar eCommerce label ("confirmation code") produce higher confidence ratings despite comparable or lower accuracy - a calibration failure - compared to the less familiar "vote fingerprint"?

**H1:** A > D on Q2 and Q3 (fingerprint > neutral baseline on the privacy-model questions).
**H2 (dissociation):** A ≈ B on overall accuracy composite (TOST, ±10 pp); A > B on Q2 (primary endpoint) and Q3 (secondary). Q2(A>B) is the single pre-specified primary endpoint for the study.
**H3:** C < all others on Q1 ("does this prove your vote was counted?") and on overall accuracy composite - reversal risk from "nullified" reading; 6 pre-registered tests (Q1(C<A), Q1(C<B), Q1(C<D), composite C<each).
**H4:** Confidence(B) > Confidence(A), B > C, B > D - confirmation code borrows perceived competence from eCommerce familiarity.

### 4.2 Study design

Between-subjects, 4 × 1 factorial experiment. The single manipulated factor was the receipt identifier label. Participants were randomly assigned to one of four conditions:

| Condition | Label | Category |
|-----------|-------|----------|
| A | vote fingerprint | Metaphor-activating (current production) |
| B | confirmation code | eCommerce convention |
| C | nullifier | Cryptographically correct |
| D | receipt ID | Generic / neutral |

All other receipt elements - the status line, the protective framing copy, the hex-formatted identifier value, the copy button, and the download prompt - were held constant across conditions. The verification panel structure (toggle button and instructions framework) was also held constant; the panel text references the label name in two instructions, as detailed in §4.3.

**Participants.** Recruitment was through Prolific (online panel). Inclusion criteria: US-resident adults, age 18+, English as first language or fluent, self-reporting at least one online vote, poll, or official election in the past 12 months, no prior participation in this study. Exclusion criteria: self-reported software engineers (to prevent domain-expert contamination of the comprehension measures), participants failing both attention checks, and participants completing the study in fewer than 90 seconds (indicating non-serious completion).

Target sample: n = 70 per condition (N = 280 total), preceded by an instrument-validation pilot of n = 10 per condition (N = 40).

**Power.** For the H2 primary confirmatory endpoint (Q2 accuracy, A vs. B, one-tailed, p₁ = 0.65 vs. p₂ = 0.50, expected difference 15 pp), α = 0.05, power = 0.80 requires n = 67 per cell (G\*Power 3.1.9.7, test: "Proportion: Inequality of two independent proportions", Cohen's h = 0.30). The target sample is n = 70 per cell (N = 280), providing approximately 82% power for the H2 primary endpoint. *Pre-registration note: the original OSF pre-registration computed n = 49 using "Proportion: Inequality of two dependent proportions" (McNemar test, a within-subjects test); this does not apply to the between-subjects design of Study 1. The sample size and test name are corrected here; the correction was made before any data were collected.* For the omnibus 4-condition chi-squared test (df = 3, effect size w ≈ 0.18 based on expected condition proportions), 80% power requires approximately n = 82 per cell; at n = 70 the omnibus power is approximately 0.67. The H2 pairwise endpoint is the primary confirmatory test; the omnibus is a descriptive-secondary test. If pilot results suggest the Q2 effect is substantially smaller than 15 pp, n will be expanded to n = 75/cell (N = 300) before full launch. No interim stopping rules for efficacy or futility are pre-registered; the pilot (N = 40) is for instrument validation only.

### 4.3 Stimuli

Each participant was shown a single static screenshot of the post-vote receipt screen under their assigned condition. The four stimuli (condition-a-fingerprint.html, condition-b-confirmation-code.html, condition-c-nullifier.html, condition-d-receipt-id.html) are identical in structure, layout, and copy except for the receipt identifier label, its ARIA label, and two label-name references within the collapsed verification panel ("check that your [label] appears"; "Paste your [label]"). All other visible receipt copy was held constant. The held-constant elements include: the submission status line ("Your vote was cast"), the protective framing sentence ("This receipt does not contain your vote choice. It proves your ballot was counted without revealing how you voted."), the hex-formatted identifier value, the copy button, and the download prompt. Note that the stimuli use a simplified protective framing that does not include the explicit design-intent signal ("This is intentional") present in the production VoteReceipt.tsx (§3.4) and the canonical PIUP framing (§2.1); Study 1 tests the label effect under this constant simplified framing, while Study 2 isolates the explanation itself as an independent variable (§5). The screenshot method controls stimulus presentation across participants and eliminates variability introduced by an interactive voting flow; the primary ecological validity cost is the absence of choice-commitment context (see §6.5).

Stimuli were committed to the repository at commit `fb710f5` before any participant data were collected. Any post-registration change to the stimuli HTML constitutes a pre-registered amendment and is noted in the deviations log.

### 4.4 Measures

**Comprehension accuracy (primary; binary correct/incorrect per item).**

*Q1 (Inclusion inference):* "Does this value prove that your vote was counted?" Correct answer: Yes; foils: No, Unsure. Tests whether participants correctly infer the ballot-inclusion event from the receipt.

*Q2 (Choice-blindness, H2 primary endpoint):* "Does this value prove which option you chose?" Correct answer: No; foils: Yes, Unsure. Tests whether participants understand that the identifier encodes no vote-choice information.

*Q3 (Coercion-scenario privacy model):* "If a coercive employer asked you to send them a screenshot of this screen as proof of your vote, could they learn how you voted?" Correct answer: No; foils: Yes, Unsure. A clarification is displayed: "Assume they can only see what is on this screen." Tests application of the privacy model to a concrete coercion scenario; this wording is fixed by the pre-registration and cannot be changed without amendment.

*Q4 (Behavioral consequence of receipt loss):* "What would happen if you lost this value?" Correct answer: You could still verify that your vote was counted, but you would not have proof that the receipt is yours; foils: you would lose your vote; the system keeps a backup; your vote would be reversed. Tests understanding that the vote is durable and not rescindable via the receipt.

*Composite accuracy:* Proportion correct on Q1-Q4 (range 0-1.0). This is the primary RQ1 measure.

*Q5 (open-ended, scored separately):* "Why might the system choose not to show you your vote choice on this screen?" Scored 0–2: 0 = no correct privacy concept (e.g., attributed to technical error, storage constraints, or expressed confusion); 1 = references privacy, anonymity, ballot secrecy, or protection from coercion or surveillance, without fully explaining the mechanism; 2 = mentions both (a) a privacy or anonymity purpose and (b) a reason why the system does not store or reveal the voter's specific choice (e.g., "the system wasn't designed to record your choice"; "to prevent coercion"; the two concepts may be expressed together). Full rubric: survey instrument §11. Scored by two independent raters; inter-rater reliability threshold: Cohen's κ ≥ 0.70. Q5 is excluded from composite accuracy and analysed separately (§4.5).

**Confidence (secondary; 7-point Likert).** After each comprehension item Q1-Q4, participants rated their confidence (1 = not at all confident, 7 = completely confident). Q5 is open-ended and receives no confidence rating. Confidence composite = mean across Q1-Q4.

**Mental model quality (exploratory; free text).** After Q1-Q4, participants answered: "In your own words, what does this value prove about your vote?" Scored 0-2: 0 = no correct element; 1 = correctly states inclusion without choice; 2 = explicitly states that vote choice is hidden from the system. Two raters; κ ≥ 0.70 required.

**Behavioral intent.** "If this screen appeared after a real vote, would you download this file?" (5-point: Definitely yes → Definitely no.)

**Covariates (collected but not pre-specified as primary analyses):** age (categorical), prior voting experience, technology self-efficacy (3-item Hargittai scale), and two Prolific attention checks.

### 4.5 Analysis plan

The study pre-registers 14 confirmatory tests across four Holm families. Holm-Bonferroni sequential correction is applied within each family independently; no cross-family correction is applied.

| Family | Pre-registered tests | m |
|--------|----------------------|---|
| H1 (fingerprint > receipt ID on privacy items) | Q2(A>D), Q3(A>D) | 2 |
| H2 (dissociation: fingerprint vs. confirmation code) | Q2(A>B) one-tailed, Q3(A>B) one-tailed, TOST composite A≈B ±10 pp | 3 |
| H3 (nullifier underperforms) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<each) | 6 |
| H4 (confirmation code overconfidence) | confidence(B>A), confidence(B>C), confidence(B>D) | 3 |

**H1** (m = 2). Two one-tailed chi-squared tests on Q2 and Q3 accuracy, A vs. D. Both must survive Holm correction within the family.

**H2** (m = 3; primary endpoint). H2-primary: Q2 accuracy, A vs. B, one-tailed chi-squared (α = 0.05); this is the single pre-specified primary endpoint. H2-secondary: Q3 accuracy, A vs. B, one-tailed. H2-tertiary: two one-sided tests (TOST) on composite accuracy, A vs. B, equivalence bounds ±10 percentage points (α = 0.05 per one-sided test). H2 outcome classification: **supported** if H2-primary significant (A > B on Q2) AND H2-tertiary establishes equivalence; **null** if H2-primary non-significant AND equivalence established; **reversed** if H2-primary non-significant AND a post-hoc Q2(B > A) test is significant at α = 0.05 (two-tailed) AND equivalence established (or B > A on composite); **inconclusive** if none of the above apply (report effect sizes; expand n or revise design). All four outcome patterns are actionable (see §6.2).

**H3** (m = 6). Three one-tailed chi-squared tests (Q1 accuracy, C vs. A, B, D) plus a composite-accuracy omnibus; if the omnibus is significant, Holm-corrected pairwise extractions for C vs. each other condition. Support criterion: C significantly lower than at least 2 of the 3 other conditions on Q1 after Holm correction. An ethics clause pre-specifies that if the pilot shows < 30% Q1 accuracy in Condition C, a fifth label may substitute for C before the full launch.

**H4** (m = 3). One-way ANOVA on confidence composite; if significant, Tukey HSD for B vs. A, C, D. Calibration analysis: Spearman rank correlation between per-participant Q1–Q4 accuracy score (0–4) and per-participant confidence composite, computed per condition. H4 predicts the B correlation will be smaller (lower calibration) than A.

**Q5 analysis.** Kruskal-Wallis test across 4 conditions; if significant, Dunn's pairwise post-hoc (Holm). A random sample of 25 responses per condition (sampled randomly, before hypothesis testing) is included in the published write-up to illustrate the range of mental model articulation.

**Confidence interval standard.** All proportions: Wilson 95% CI. All means: 95% CI from t-distribution. All odds ratios: log-scale 95% CI.

### 4.6 Results

_[To be written after Study 1 data collection. Pre-registration OSF DOI: [INSERT]. Pilot target: 2026-Q3; full launch conditional on instrument validation. Reporting structure: (1) Participant flow table — 4 conditions (A: fingerprint, B: confirmation code, C: nullifier, D: receipt ID), final N=280 (n=70/cell), demographics DM1 (age), DM2 (technology background), DM3 (prior voting experience), pre-specified exclusion protocol applied (software engineers, both attention checks failed, response time < 90 s); (2) omnibus chi-squared result; (3) per-hypothesis family in H1-H4 order; (4) Q5 open-text analysis; (5) exploratory comparisons.]_

---

## 5. Study 2: Explanation Effects and Calibration Interventions

Study 1 isolates the label effect while holding the receipt's explanatory copy constant. This means Study 1 cannot answer a prior question: does the explicit absent-choice explanation ("Your vote is not shown here. This is intentional.") actually change comprehension, or is the label doing all the work? Study 2 isolates the explanation as the independent variable.

### 5.1 Research questions

**RQ1 (Explanation effect).** Does an explicit absent-choice explanation in the receipt increase correct absent-content interpretation, trust, and self-reported save intention, compared to a receipt with no explanation? (See §6.1, §6.3.)

**RQ2 (Label × Explanation interaction).** Is the explanation effect moderated by label? Specifically: does "confirmation code" produce lower absent-content accuracy in the no-explanation condition (schema import unchecked), but close the gap to "vote fingerprint" when explanation is added? (See §6.1, §6.2.)

**RQ3 (Calibration intervention).** Does an accuracy-feedback intervention - a two-question comprehension check with immediate correct-answer feedback, displayed before the receipt - increase correct absent-content interpretation and reduce confidence miscalibration without reducing save intention? (See §6.2, §6.3.)

**RQ4 (Save behavior).** Does correct absent-content interpretation predict save intention? Is this relationship moderated by calibration? (See §6.1.)

### 5.2 Design

2×2×2 between-subjects factorial experiment.

**Factor L (Label; 2 levels):** L1 = "vote fingerprint"; L2 = "confirmation code." The full 4-condition label space from Study 1 is reduced to the theoretically central contrast. "Nullifier" is excluded (Study 1 addressed its failure mode; no production path). "Receipt ID" is excluded (characterized as a generic baseline in Study 1).

**Factor E (Explanation; 2 levels):** E1 = explanation present: "Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [label] is the only thing you need — matching it later proves your ballot was counted, nothing more." E2 = explanation absent: the receipt shows the identifier, the counting-confirmation statement ("Your ballot was counted"), the download prompt, and the verification instructions, but no explicit absent-choice explanation sentence. A minimal privacy note ("Your vote is private and verifiable") is retained in E2 to avoid a privacy-awareness confound; only the absent-choice explanation is omitted (design note §6.1).

**Factor I (Calibration intervention; 2 levels):** I1 = no intervention; participant sees the receipt directly. I2 = calibration intervention; participant answers two comprehension questions before viewing the receipt, then receives correct-answer feedback (whether their answers were right, with a one-sentence explanation for each question). I is crossed with L × E, producing 8 cells; N = 30 per cell (N = 240 total).

### 5.3 Platform

Study 2 uses the actual `VoteReceipt.tsx` component from the Aztec Private Voting React package, hosted on Vercel in study mode. The static screenshot method from Study 1 is insufficient for the save-behavior measure and I2 conditions because (a) the download affordance must be clickable and observable, and (b) the intervention (I2) requires pre-receipt interaction. Hosting the production component increases ecological validity for the trust and behavioral-intention measures. Study mode logs: download button click (no file written), expansion of the verification section, and intervention response accuracy.

### 5.4 Measures

The primary confirmatory endpoint is absent-content interpretation (Q-AC): "Looking at this receipt: does it show which candidate you voted for?" (Correct: No, my vote choice is not shown; foils: Yes, my vote choice is shown; It's not clear from what I see.) This item isolates the absent-choice inference directly, rather than the broader privacy model tested in Q2/Q3. Additional primary measures (design note §7.1): save intention (7-point scale: 1 = Definitely not, 7 = Definitely will; behaviorally supplemented by observed download-button click) and trust in the receipt system (4-item adapted McKnight scale (McKnight et al. 2002) — two integrity items: TI1 "I believe this receipt accurately reflects what happened with my vote," TI2 "I trust that the [label] is unique to my ballot"; two competence items: TC1 "I feel confident I could use this receipt to prove my ballot was counted," TC2 "I understand what this receipt is for"; composite = mean of four items; α ≥ 0.70 required). Conditional secondary measure (design note §7.2): confidence-accuracy residual (M4; I2 condition only): a single-item confidence rating — "How confident are you that your answers were correct?" on the same 7-point scale as Study 1 (1 = not at all confident, 7 = completely confident) — minus proportion correct on Q-AC and the two I2 pre-receipt probe questions; positive residual = over-confidence, negative = under-confidence.

### 5.5 Primary analysis

The primary analysis axis is contingent on Study 1 outcomes (full decision table in `docs/piup-study2-design-note-2026-06-22.md`). The default primary endpoint is the E main effect on Q-AC accuracy: does explanation-present vs. absent produce different rates of correct absent-choice inference? The L × E interaction is the secondary endpoint (H2.2; pre-registered on M2 trust composite, §9.1 of the design note): the explanation effect on trust is predicted to be larger for the "confirmation code" label than for the "vote fingerprint" label, because the eCommerce schema that the code imports requires framing copy to do corrective work that the fingerprint metaphor partially handles by itself. A corresponding ordinal pattern is predicted on Q-AC — "confirmation code" without explanation is expected to underperform "vote fingerprint" without explanation, with the gap closing when explanation is added — but H2.2 is pre-registered on M2, not Q-AC; this framing supports the schema-import / framing-override model proposed in §6.1-6.2. If Study 1's H4 is supported (confirmation code overconfidence; §4.5), the I-factor calibration analysis becomes a co-primary: does accuracy feedback reduce the confidence-accuracy residual in L2 cells without reducing save rate?

### 5.6 Status

Study 2 is currently at design-note stage; it will be finalised and pre-registered after Study 1 pilot data establish the instrument and provide preliminary effect-size estimates to inform Study 2 power analysis for the L × E interaction. Full design specification: `docs/piup-study2-design-note-2026-06-22.md`.

---

## 6. Discussion

_[§6.1-6.5 written from design framing (no Study 1 data required). §6.6 results discussion pending Study 1 data collection.]_

### 6.1 When does protective absence work?

The PIUP's central design hypothesis is that a receipt which omits the vote choice can produce correct user behavior - saving the identifier, returning to verify - without triggering the failure-reading (the vote was not recorded). For this to hold, two conditions must be met simultaneously: the receipt must carry an explicit design-intent signal that distinguishes protective omission from system failure, and the submission token must carry a label-metaphor that is consistent with the correct privacy mental model.

Neither condition alone is sufficient.

An absent-choice receipt without design-intent framing falls squarely into the failure mode documented by Whitten and Tygar (1999) for cryptographic systems: when systems produce outputs that users cannot interpret, users do not conclude that the system is protecting them - they conclude that something has gone wrong. Applied to the receipt context: a user who sees no vote choice, with no explanation, applies the most parsimonious inference. The vote was not recorded. The technical guarantee becomes an experiential failure. This failure mode is not limited to novice users. Egelman and Schechter (2013) find that even security-aware users, when confronted with feedback that violates expected conventions, tend toward behavioral normalization: they attribute the unexpected signal to error rather than design and proceed as if the system had confirmed the usual thing. The security property is invisible precisely to the users who most need to understand it.

The Protective framing component - "Your vote choice is not shown. This is intentional - it protects your privacy" - is designed to resolve this problem by naming the absent content before the user notices it is missing. The receipt does not wait for the user to ask "where is my vote choice?"; the answer is provided in the receipt body, in the sequence: (1) confirmation of counting, (2) submission token, (3) protective framing. The absent content is named at step 3 before the user has completed reading the receipt - before the failure-inference can form. This is the reverse of the standard security warning design, which responds to a risk that has already materialized. The PIUP framing is pre-emptive: it establishes the design intent before the user's default schema interprets the absence as failure.

However, the protective framing addresses only one axis of the mental-model problem. The label on the submission token carries an independent schema effect - one that operates specifically on the privacy-model questions rather than on overall comprehension accuracy. A user whose mental model is "the confirmation code links back to my vote choice, as it does in eCommerce" has the *behavioral* model approximately correct (save the identifier; use it later to verify) while having the *privacy* model wrong (the code reveals my choice to anyone who has it). The protective framing copy tells the user that the choice is not shown; it may not, by itself, fully override the representational schema that "confirmation" activates at the label level - a question Study 2's L × E test addresses directly (§5.5). A user reading "confirmation code" as the identifier may treat the protective framing as a description of a technical limitation - the system could not show the choice here - rather than as a description of a guarantee.

This creates a dependency between the two conditions. The label must not import a representational schema that the explanatory framing cannot override on the privacy-specific questions. "Vote fingerprint" carries uniqueness-without-content semantics: a fingerprint identifies without describing, and the metaphor carries no implication that the identifier is retrievable evidence of content. "Nullifier" and "receipt ID" carry no eCommerce-familiarity loading at all, though they sacrifice comprehensibility for different reasons. "Confirmation code" and, to a lesser degree, "receipt ID" prime the evidence-of-content schema that PIUP specifically needs to avoid.

The design implication is that Invariants 1-3 of the PIUP are necessary but not sufficient for correct privacy-mental-model formation. The Protective framing component handles the failure-inference problem. The token label handles the schema-import problem. In the PIUP receipt, both must be correct simultaneously: absent-content framing without a privacy-appropriate label leaves the privacy-model questions vulnerable; a privacy-appropriate label without absent-content framing leaves the failure-inference unaddressed. The pattern requires both components; neither is sufficient alone.

### 6.2 The confirmation code paradox

A consistent finding in the trust and usability literature is that familiarity produces confidence. Users who encounter interface patterns they recognise tend to extend more trust to them than to unfamiliar conventions (McKnight et al., 2002; Lee and See, 2004). For most interface design decisions, this is a design resource: if a familiar convention correctly describes the system's behavior, using it reduces friction without cost.

In privacy-critical contexts, familiar conventions carry a hidden cost. McKnight et al. (2002) distinguish between trusting beliefs - specific cognitions about a trustee's properties - and trusting intentions - willingness to depend on the trustee. In eCommerce, "confirmation code" activates both: users form the trusting belief that the code is retrievable evidence of a specific transaction, and extend the trusting intention appropriate to that belief (save it; present it if challenged; match it to your order record). The trust complex is calibrated to the eCommerce representational schema: confirmation = record of what was confirmed. This schema is correct in eCommerce and wrong in private voting, where the correct schema is: confirmation = proof of counting, without encoding what was confirmed.

A user applying the eCommerce schema to a private voting receipt will be confident in their understanding of the receipt - they have encountered this type of identifier hundreds of times - while holding a wrong mental model on the privacy questions specifically. This maps onto the miscalibration Lee and See (2004) describe in trust in automation: over-reliance occurs when users apply a mental model that does not accurately reflect the system's actual behavior — here, when the eCommerce schema that "confirmation code" activates does not match the receipt's privacy properties. The mismatch between the convention's original domain and its new application is not apparent until the user faces a situation in which the schemas diverge - in this case, a coercion scenario where the receipt's privacy properties matter.

The schema-import mechanism generates two distinct pre-registered predictions. **H2 (dissociation; see §4.5)** predicts that the accuracy difference is confined to the privacy-model questions: "confirmation code" and "vote fingerprint" are predicted to perform comparably on the overall accuracy composite - both produce the correct behavioral schema (save the identifier; use it to verify later) - while diverging specifically on Q2 ("does this prove which option you voted for?") and Q3 ("could someone learn how you voted from a screenshot?"), where the eCommerce-evidence schema directly contradicts the correct answer. The pre-specified outcome classification (§4.5) treats H2-supported (Q2 significant, A > B, AND composite equivalence established), H2-null (non-significant, equivalence established), H2-reversed (B > A on Q2 significant), and H2-inconclusive (neither directional pattern; expand n or revise design) as four distinct actionable production decisions, not as success/failure dichotomies. **H4 (confidence miscalibration; see §4.5)** operationalizes a second consequence: under H4, "confirmation code" is predicted to produce higher self-reported confidence than "vote fingerprint," "nullifier," and "receipt ID" (all three pairwise comparisons pre-registered: B > A, B > C, B > D) despite the accuracy deficit on Q2 and Q3. Confidence would be high because the eCommerce schema is well-practiced; accuracy on the privacy-specific items lower because the schema contradicts the correct answer. If H4 is supported, the label simultaneously does the designer's work of reducing onboarding friction and the coercer's work of producing a wrong mental model.

If H4 is supported, the implication extends beyond receipt labels to a general principle for privacy-critical interface design. Any familiar UI convention that activates a complete trust complex - a set of beliefs and behavioral intentions calibrated to a prior domain - carries the risk of schema-import failure in a new domain where the convention's semantics differ. This might be called the *familiarity tax*: using familiar labels in privacy-critical contexts reduces onboarding friction but creates a deficit in privacy-mental-model accuracy that compounds under coercion or audit. On this account, the deficit would be invisible to users (they feel confident), invisible to designers (the interface performs well on standard usability metrics), and potentially dangerous exactly when it matters most — a theoretical projection that H4 is designed to test empirically.

The practical implication is that familiar-convention adoption in privacy UX requires an evaluation step beyond standard usability: not only "does this reduce cognitive load?" but "does this import a representational schema that contradicts the privacy model, and can the protective framing override it?" For private voting receipts, the answer for "confirmation code" appears to be: schema import yes, override uncertain. The question for designers of analogous systems - sealed-bid auction receipts, whistleblower submission receipts, anonymous peer review receipts - is whether any label in their domain activates the same eCommerce-evidence schema, and whether the available explanatory copy is sufficient to override it on the specific items where the schema and the privacy model diverge.

### 6.3 The protective absence feedback inversion

Norman's (1988) central feedback principle - "always keep the user informed about what is going on" - is a design resource for most interface contexts. The principle assumes that the relevant system state is something that happened: a file was saved, a message was sent, a payment was processed. The correct design response is to tell the user what happened.

PIUP inverts this. The relevant system state is something that was protected from happening: the vote choice was not recorded in the receipt. The correct design signal is the absence itself - but absence is not self-explaining. A design that simply omits the vote choice and says nothing is not telling the user what was protected; it is giving the user nothing to interpret, which, under Norman's own model, produces error-prone behavior: the user's conceptual model diverges from the system model, and the gap is not visible to the user.

This creates what might be called the *protective absence feedback problem*: how do you provide feedback for the correct absence of information? Standard feedback design addresses this for error states - the system tells the user what went wrong. PIUP requires an analogous mechanism for protection states - the system must tell the user what was correctly withheld.

PIUP is not the first design to face this problem. The HTTPS lock icon communicates channel protection, not content - it signals that the connection is encrypted without telling the user anything about the content flowing through it. The indicator's meaning is the protected channel, an absence-of-eavesdropping signal. Prior usability research has documented how poorly users understand what the lock icon actually means (Felt et al., 2016); users commonly misread "secure channel" as "trustworthy site," importing the wrong layer of protection into their mental model. The indicator fails for the same structural reason as an unexplained absent-choice receipt: the protection is in the channel layer, but users form their mental models from the content layer. The lock says nothing about content, and users interpret it as a content guarantee anyway.

Behavioral advertising opt-out mechanisms face the same inversion. The signal - a privacy-preference setting - communicates system restraint rather than user action. The user has not blocked anything specific; the system is supposed to refrain from tracking. In practice, opt-out tools showed widespread misunderstanding among users who activated them (Leon et al., 2012): most participants confused opting out of behavioral targeting with blocking ads entirely. The pattern matches the structural inversion: the concept requires users to model a system refraining from an action, rather than the system taking one.

What distinguishes PIUP from both predecessors is the severity of the counterintuitive demand. The HTTPS lock asks users to understand channel encryption - an abstract technical property, but one that maps onto familiar analogies (sealed envelope, locked door). DNT asks users to model a system restraint - unnatural, but neutral in content terms. PIUP asks users to understand that the absent content - the vote choice they most want to confirm they cast correctly - is exactly what is being protected. The most-wanted information is the most-protected, and the receipt's job is to signal the protection, not supply the content.

The Protective framing component is the design response to this inversion. Where the HTTPS lock provides a small ambiguous icon and DNT provides a toggle with uncertain semantics, PIUP provides prose that names the absent thing, names the protection reason, and names the beneficiary in a single step. The framing is not a tooltip or a secondary explanation; it is positioned in the primary receipt flow, after the submission token, before the user has finished reading the receipt. The protective absence feedback problem is addressed by treating the absence as a first-class receipt element, not as a secondary explanation for a gap the user might or might not notice.

### 6.4 Generalisation beyond voting

The PIUP's three invariants were derived from the private voting context, but the underlying design problem is domain-independent. The invariants apply to any system in which (1) a receipt must confirm that an action was recorded, (2) the action's content must be protected from disclosure in the receipt, and (3) the user must be left with a correct mental model of both the confirmation and the protection.

**Sealed-bid auctions.** In a sealed-bid auction, the bid receipt must confirm that a bid was submitted without revealing the bid amount. A receipt that shows the bid defeats sealed-bid confidentiality; a receipt that shows nothing fails to confirm submission. The PIUP invariants apply to this domain: Invariant 1 requires that the submission token be independent of the bid amount and any observable state, and be verifiable against a public ledger — the bid receipt carries an opaque identifier satisfying these constraints, while the status line confirms that the bid was recorded; Invariant 2 requires that the token be kept private until the auction reveal event (the domain-specific adaptation of Invariant 2's transit-privacy timing constraint), at which point the link between token and bid in the execution record is no longer actionable for coercion; Invariant 3 requires that the bid receipt contain no bid-amount field, and the protective framing explains that the amount is withheld to preserve auction integrity. The label question recurs: "bid receipt," "submission token," and "bid confirmation" each carry different schema loads, and the eCommerce-order-confirmation analogy is directly active in auction contexts.

**Whistleblower drops.** In secure document submission systems, the submission receipt must confirm that a document was received without confirming the document's contents. A receipt that echoes the document title, file size, or any identifying metadata creates a coercion surface: a coercer who asks to see the submission receipt can confirm not only that a document was submitted but what was submitted. The PIUP invariants appear to apply: Invariant 1 requires that the submission token be independent of document content and observable state, and be verifiable against a public ledger; the status line confirms that the document was received; Invariant 2 requires that the token be kept private until the content is definitionally public; Invariant 3 requires that no content metadata appear in the receipt, and the protective framing explains that content details are withheld to protect source anonymity. The domain adds a threat-model wrinkle absent in voting: in some contexts - for instance, employer-facing disclosures, where the organisation may already possess the disclosed information - the adversary's primary goal is not to learn the content but to confirm that a specific person submitted it. In this threat model, the coercion question shifts: the receipt must not confirm receipt to a third party, even when that party already knows the content. The protective framing must be precise about what the token does and does not reveal in this specific sense.

**Anonymous peer review.** In double-blind peer review, the review-submission receipt must confirm that a review was recorded without confirming the reviewer's identity. Many conference management systems provide a "your review has been submitted" confirmation email with no submission token. This fulfils the notification function that the PIUP status-line component requires - the reviewer knows their submission was recorded - but omits the token independence constraint of Invariant 1, the privacy-in-transit requirement of Invariant 2, and the minimal-content constraint of Invariant 3; it provides no protective framing. The failure mode is not a privacy breach in the standard case (the email goes to the reviewer), but a verifiability gap: the reviewer has no durable proof of submission that does not also reveal their identity to a third party examining the confirmation. A PIUP implementation would issue an opaque submission token, confirm recording without author attribution, and explain that the reviewer's identity is protected by the token design.

**Common structure.** Across all three cases, the PIUP invariants apply to each domain; the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event (auction reveal, content publication, or review decision), but the structural requirements — token independence, token privacy until that event, and minimal-content receipt — hold without change. The variation across domains is in the token label, in the framing text, and in the threat model that motivates the protection. The generalisation suggests that PIUP names a design category - the *coercion-surface receipt* - rather than a single context-specific pattern. Any confirmation receipt that could be used under adversarial conditions to infer what the user chose, submitted, or authored falls within this category. The pattern's scope may extend to any domain where a confirmation receipt must protect content from disclosure while preserving the user's ability to verify that recording occurred.

### 6.5 Limitations

**Protocol-layer exposure.** The Aztec contract's `record_vote` function takes the vote choice as a plaintext argument in the calldata at submission time. A sufficiently motivated observer monitoring on-chain calldata can recover the vote choice regardless of what the receipt shows or withholds. This is a documented named limitation in the system's security review (§3.3, L1 privacy gap): the private voting guarantee applies at the state layer (nullifier and vote-tally storage), not at the calldata layer. The receipt design correctly withholds the choice from the receipt; it does not provide protection against calldata observation. Users whose threat model includes calldata surveillance are not protected by PIUP at the circuit layer. This limitation is relevant to ecological validity: participants assessing a receipt screenshot cannot evaluate the calldata exposure, and the study's comprehension questions do not address it.

**Study 1 ecological validity.** Study 1 uses screenshot stimuli rather than an interactive voting interface. Participants viewing a static receipt image may form different mental models from those formed during an actual voting flow, where the receipt appears as the final step in a sequence of choices the participant actively made. The screenshot method controls stimulus presentation but removes the choice-commitment context that makes the receipt's absent content personally salient. The ecological validity gap is most likely to affect the confidence ratings (secondary per-question Likert items, §4.4) and the behavioral-intention item: in a live voting flow, confidence ratings are anchored to a choice the participant actively made and personally cares about; in a screenshot study, they are anchored to a fictional choice in a simulated context. Note: Q4 as defined in §4.4 is a behavioral-consequence knowledge question ('what would happen if you lost this value?') - a knowledge item equally answerable from a screenshot - and is less susceptible to this ecological validity gap than the confidence ratings. The Prolific convenience sample introduces a further validity bound: participants are US-based English-speaking online workers who may not represent the full population of likely private voting system users.

**Study 2 demand characteristics.** Study 2 uses an interactive prototype in which participants cast a simulated vote before receiving a receipt. While this improves ecological validity over the static-screenshot predecessor, the simulated context may make demand characteristics more salient: participants who correctly infer the study's hypothesis may respond accordingly. The study mitigates demand characteristics through non-leading task instructions that do not draw attention to the download affordance ('You have just voted in a simulated election. Take a moment to review your receipt. Then answer the questions below.') and through identical button styling across all conditions (Study 2 pre-analysis plan §11.1). Two attention checks are used for inattentive-participant exclusion; an open-ended explanation item (Q-OE) is scored for comprehension quality. Neither specifically detects hypothesis-aware responding; no direct measure of participant hypothesis awareness is included. The mitigations do not provide full protection against demand-characteristic effects.

**Statistical power.** The original pre-registration power analysis used G\*Power's "Proportion: Inequality of two dependent proportions" (McNemar test), which is a within-subjects test and does not apply to the between-subjects design of Study 1. The corrected calculation ("Proportion: Inequality of two independent proportions", Cohen's h = 0.30, one-tailed, α = 0.05) yields n = 67 per cell for 80% power on the H2 primary endpoint; the study targets n = 70 per cell (N = 280) to provide approximately 82% power. The pre-registered sample size of n = 50 per cell would have provided approximately 69% power for H2 primary. The correction was made and documented in the paper before any data were collected; the OSF pre-registration required amendment before upload. For the omnibus 4-condition chi-squared test the study is intentionally underpowered (approximately 67% at n = 70); the omnibus is a descriptive-secondary test and is not used to adjudicate any of the 14 confirmatory hypotheses.

**Scope.** The PIUP and this study address single-vote binary or multi-option receipts. Ranked-choice, quadratic voting, and cumulative voting receipts present additional challenges: the receipt must confirm not merely that a vote was recorded but that the full preference ordering was recorded, and the absent content is richer and more individually identifying. The invariants hold in principle - the receipt confirms recording, issues a token, withholds the preference content - but the framing complexity increases substantially. Generalisation to non-binary preference structures is a direction for future work.

---

## 7. Conclusion

_[Draft framing assumes H2-supported (Q2: A > B significant, composite A≈B equivalence established). If Study 1 yields H2-null or H2-reversed, revise the second paragraph per §4.5 outcome classification. The dissociation framing and §6.2 cross-reference remain correct regardless of H2 outcome; only the directional claim about fingerprint's advantage requires adjustment.]_

Private voting systems face a paradox at the confirmation layer. Correct behaviour - a receipt that confirms counting without revealing content - looks like a system failure to users whose mental models were formed in eCommerce contexts, where receipts exist to confirm content. This is not a usability problem that better copy alone can solve; it is a structural mismatch between the confirmation semantics of two different domains.

The PIUP formalises the design response to this mismatch. The Status line component anchors the receipt: the user sees confirmation that their ballot was recorded. Invariant 1 (surrogate independence) ensures the submission token is not derivable from the vote choice and is verifiable against a public ledger. Invariant 2 (surrogate privacy in transit) requires the token be kept private until the vote closes. Invariant 3 (minimal receipt content) ensures no choice-revealing field appears in the receipt. The Protective framing component addresses the hardest part: it explicitly names the absent content and the reason for its absence, before the user's default failure-inference can form.

The empirical case for PIUP rests on two boundary conditions, both derived from Study 1. First, the Protective framing component is necessary but not sufficient. Without a token label whose representational schema does not import the eCommerce-evidence association, the framing cannot fully override the wrong mental model on privacy-specific items. If H2 is supported, "vote fingerprint" holds the privacy-model advantage specifically on the questions that distinguish PIUP-correct mental models from coercion-surface mental models - primarily on Q2, whether the identifier proves which option was voted for (the pre-specified primary endpoint; §4.5), and potentially Q3, whether a screenshot reveals the vote choice (H2-secondary; §4.5) - while the overall accuracy composite remains equivalent (H2-tertiary). If H4 is also supported (confidence miscalibration; §4.5; see §5.5 for Study 2 contingency), "confirmation code" produces higher self-reported confidence alongside this accuracy deficit: the familiar label simultaneously reduces onboarding friction and degrades the privacy mental model without the deficit being apparent to the user. In that scenario, "confirmation code" undermines the framing on exactly those questions, not because it fails to signal that something was confirmed, but because it imports a precision that private voting cannot support: confirmation of content. The label and the framing must be correct simultaneously; neither is sufficient alone.

Second, the design problem generalised. Sealed-bid auctions, whistleblower drops, and anonymous peer review all require receipts that confirm recording without revealing content under adversarial conditions. The PIUP invariants apply to each domain; the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event (auction reveal, content publication, or review decision), but the structural requirements — token independence, token privacy until that event, and minimal-content receipt — hold without change. The variation across domains is in token label semantics and protective framing text. The pattern names a design category - the *coercion-surface receipt* - and provides an empirical method for evaluating candidate labels against privacy-mental-model accuracy, rather than general comprehension accuracy alone.

The practical prescription follows from the boundary conditions. When designing a receipt for any context where the absent content is exactly what users most want confirmed, use a three-invariant structure: confirm the recording; issue an opaque token with a label that does not import the content-evidence schema; name the absent thing with a reason before the user reads the gap as an error. The latent risk, on this framing, is not the user who understands that privacy requires absence - it is the user who has never seen a receipt that did not tell them what they chose.

---

## References

- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." _EVT/WOTE 2009._
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., Fisher, G., Kortum, P., McBurnett, N., Montoya, J., Parker, M., Perez, O., Stark, P., Wallach, D., and Winn, M. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _EVT/WOTE 2013._
- Das, S., Dabbish, L., and Hong, J. (2014). "The Effect of Social Influence on Security Sensitivity." _ACM CCS 2014._
- Egelman, S., and Schechter, S. (2013). "The Importance of Being Earnest [In Security Warnings]." _FC 2013._
- Everett, S.P., Greene, K.K., Byrne, M.D., Wallach, D.S., Derr, K., Sandler, D., and Torous, T. (2008). "Electronic Voting Machines versus Traditional Methods: Improving Voter Attitudes and Satisfaction." _CHI 2008._
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _SOUPS 2012._
- Felt, A.P., Reeder, R.W., Ha, E., and Ainslie, A. (2016). "Rethinking Connection Security Indicators." _USENIX SOUPS 2016._
- Leon, P., Ur, B., Shay, R., Wang, Y., Balebako, R., and Cranor, L. (2012). "Why Johnny Can't Opt Out: A Usability Evaluation of Tools to Limit Online Behavioral Advertising." _CHI 2012._
- Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." _VoteID 2015_, LNCS vol. 9269, pp. 57–73. Springer. [VERIFIED tick-3765: year corrected 2017→2015; venue corrected USENIX VoteID→VoteID 2015 LNCS Springer]
- Marky, K., Kulyk, O., Renaud, K., and Volkamer, M. (2018). "What Did I Really Vote For? On the Usability of Verifiable E-Voting Schemes." _Proceedings of the 2018 CHI Conference on Human Factors in Computing Systems (CHI '18)_, pp. 1–13. ACM. DOI: https://doi.org/10.1145/3173574.3173750 [VERIFIED tick-3766: 95-participant Benaloh Challenge (cast-as-intended verification) usability study; authors + DOI + pages confirmed via Strathclyde repository; resolves JONY-ACTION F]
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." _Social Psychological and Personality Science 8(4):355-362._
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." _Human Factors 46(1):50-80._
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." _Information Systems Research 13(3):334-359._
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
1. Study 1 data (N=280; depends on OSF upload + Prolific launch)
2. Sections 4.2-4.6 filled with actual results
3. Section 5 updated with Study 2 pre-registration DOI (conditional on H4 in Study 1)
4. Section 6 written from Study 1 data
5. ✅ Kulyk et al. citation FIXED (tick-3765): year 2017→2015; venue USENIX VoteID→VoteID 2015 LNCS Springer. ✅ JONY-ACTION F RESOLVED (tick-3766): Marky et al. (2018) CHI added as correct citation for verifiable e-voting usability (95-participant Benaloh Challenge study). §1.4 paragraph updated: Marky et al. now cited for task-completion/workload focus (distinct from PIUP's privacy-mental-model focus); Kulyk et al. (2015) description confirmed accurate.
6. CHI 2027 call for papers - confirm word limit and formatting requirements

**Submission-ready target date:** January 2027 (aligns with Study 1 full run completion; Study 2 data not required for initial submission - present as pre-analysis plan)

**Writing sample use (before submission):** This draft (abstract + introduction) can be shared with potential PhD advisors from October 2026 onwards as a "paper in preparation." For Annie Antón (GT) and Sauvik Das (CMU), sharing the abstract + intro + the study arc blog post gives them both the technical framing and the accessible version. Do not share the incomplete sections (3-7 placeholders).
