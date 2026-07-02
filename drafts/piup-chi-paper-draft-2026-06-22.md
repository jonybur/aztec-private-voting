# Protective Absence: Designing Coercion-Resistant Receipts for Private Cryptographic Voting

_Draft for CHI 2027 submission · Jony Bursztyn · 2026-06-22_
_Status: All sections written. §4.6 Results pending Study 1 data collection (2026-Q3 pilot). Submission-clean pending OSF amendments O+T. Four-study arc: §7 updated tick-4397; abstract + §1.3 updated tick-4402. Study 4 DV1/DV2 dual-operationalisation propagated to abstract + §1.3 + §7 at tick-4418. §7 conclusion para 3 compressed –140w at tick-4467._
_Word count: ~11,683 words (body incl. refs, excl. tables + annotations; tick-4467 –140w from §7 conclusion para 3 compression). §4.6 fill-in adds +245–405w → final ~11,928–12,088w: trim pass unlikely needed at lower end; light trim (~88w) needed only if §4.6 fills at upper bound. CHI cap 12,000 incl. refs, excl. tables. Open actions: JONY-ACTION O (OSF Amendment 5) + JONY-ACTION T (OSF Amendment 14)._

---

## Abstract

Submission confirmations carry an implicit claim: the system received what you sent. In private cryptographic voting, this creates a coercion surface — a receipt showing the submitted choice can be demanded as compliance proof.

We present the **Proof-of-Inclusion UX Pattern (PIUP)**, a design class for systems that must confirm participation without revealing content. PIUP centers on *protective absence*: deliberate omission of the submitted choice, paired with a signal marking omission as intentional. This inverts Norman's feedback principle — correct feedback proves the action is *protected from display*.

We instantiate PIUP in Aztec Private Voting and report four pre-registered studies. Study 1 (N=280, 4-condition between-subjects) tests identifier label effects on privacy mental models. Study 2 (N=240, 2×2×2 factorial) tests explanation and calibration effects. Study 3 (N≥80, two-arm field pilot) tests whether a social-verification counter increases post-vote verification return rates. Study 4 (N=160, 2×2 vignette) tests whether a UI-level temporal lock on the submission token produces genuine coercion deniability under adversarial pressure; pre-registered DVs: sharing intent (DV1, primary confirmatory) and perceived social deniability of the technical excuse (DV2, secondary confirmatory). PIUP formalises three invariants (surrogate independence, surrogate privacy in transit, minimal receipt content) and one named limitation: in the current Aztec Private Voting implementation, vote choice appears in public calldata — addressable at the application layer (§1.1), not through UI design.

---

## 1. Introduction

When Mango Markets put the loss-socialization decision from a $116M protocol exploit to a governance vote in October 2022, every voter's wallet address was public on-chain. This is not an edge case — it is the default condition for blockchain governance: all participation is pseudonymous at best, traceable by design, and indexable by anyone running a node. In high-stakes organizational votes, pseudonymity under observation is coercive. Voters who can be identified can be pressured.

Zero-knowledge proof systems offer a partial technical resolution. Aztec's ZK rollup allows a voter to prove eligibility and submit a ballot without revealing the ballot's contents in public calldata. At the private state layer, ZK achieves what it is designed for: the system records a nullifier and the aggregate tally — no persistent state links the voter to their choice. A named limitation remains at the calldata layer: the vote choice appears as a plaintext argument in the contract's public accounting step, visible at submission time (§1.1). State-level storage of the choice is eliminated; calldata exposure at the moment of submission is not.

From the user interface's perspective, a problem persists.

After a private vote, users receive a confirmation. Standard confirmation UI — across every digital domain they have encountered — mirrors the submitted content. Your eCommerce order confirmation shows the items. Your appointment confirmation shows the time and date. Your form submission shows the submitted values. The confirmation is evidence of what was submitted. This is, per Norman's description of feedback in _The Design of Everyday Things_ (1988), the correct behavior: the system tells you what happened.

In private voting, the correct behavior is the opposite. A receipt that shows the submitted choice creates a coercion surface exactly equivalent to transparent voting: the voter can be asked to produce it. A receipt that shows only a cryptographic identifier — the nullifier hash, or some UI-friendly variant of it — confirms participation without confirming direction. The absent choice is the privacy guarantee.

The design problem is that absence, by default, reads as failure.

Usability-security research documents multiple failure modes when users encounter unexpected security interface states: inferring system failure from absent confirmation (Whitten and Tygar, 1999), ignoring present permission warnings (Felt et al., 2012), and dismissing warnings as inapplicable (Egelman and Schechter, 2013). In the receipt context, the operative failure mode is the first. A receipt that shows no vote choice, without explanation, will be read as: "the system didn't record my vote," "the vote failed," or "this is a bug." The technical guarantee becomes an experiential failure.

The contribution of this paper is a design pattern that resolves this tension: the **Proof-of-Inclusion UX Pattern (PIUP)**.

### 1.1 The PIUP pattern

PIUP is a design class for submission systems where three conditions hold simultaneously: (1) the system can confirm that a submission was received and processed; (2) the system must *not* confirm the content of the submission (by design); and (3) users expect confirmation to include content (by transfer from prior confirmation experiences).

Under these conditions, standard confirmation design fails: it either violates condition (2) (by showing content) or violates condition (1) (by showing an opaque identifier that reads as error).

PIUP's resolution is *protective absence*: the receipt omits the content but explicitly signals that the omission is a design guarantee, not a failure. Four components appear in order: a status line confirming the submission ("Your ballot was counted"), the submission token (a cryptographic identifier), a protective framing naming the absent content ("Your vote choice is not shown. This is intentional - it protects your privacy"), and a verification affordance for later inclusion checks (§2.1). The omitted choice is named before the user notices it is missing, establishing purpose before the failure-inference forms.

Three formal invariants characterize the pattern (full specification: §2.1): **Invariant 1 (Surrogate independence)** — the token must not be derivable from submission content, user identity, or observable state, and must be verifiable against a public ledger without revealing content. **Invariant 2 (Surrogate privacy in transit)** — the token must be kept private until the content is definitionally public (vote closes, auction reveals); after that event the link in the execution record is no longer actionable for coercion. **Invariant 3 (Minimal receipt content)** — the receipt must contain only the token and verification endpoint; no choice-revealing field is permitted.

**Named limitation.** The current Aztec Private Voting implementation exposes `vote_choice` in `record_vote` public calldata; PIUP narrows the UX coercion surface but does not protect against calldata observation. M3 resolves this at the application layer without protocol changes (§3.3, §6.5).

### 1.2 Naming the absent thing

The identifier on the PIUP receipt — what PIUP calls the *submission token* — occupies the conceptual role ZK voting literature assigns to a *nullifier*: a value proving participation without revealing content.

"Your nullifier: `a3f9...`" is technically correct and, for non-expert users, actively misleading: our design walkthroughs produced consistent failure readings — "nullifier" sounds like a cancellation or a legal invalidation. The term is opaque to experts and misleading to non-experts — a combination that, per Whitten and Tygar, reliably produces usability failures in security-critical contexts.

Four candidate labels were tested through design iteration: **"vote fingerprint"** (uniqueness-without-disclosure), **"confirmation code"** (standard eCommerce convention), **"nullifier"** (technically precise), and **"receipt ID"** (generic baseline).

The key contrast is fingerprint vs. confirmation code. "Confirmation code" in eCommerce contexts activates a representational schema — *confirmation = record of what was submitted* — correct in every prior context the user has encountered, wrong in PIUP. H2 predicts that the two labels will perform similarly on overall accuracy but diverge on privacy-model questions (Q2: whether the token proves vote choice; Q3: whether a third party could learn how the voter voted). Confirmation code is predicted to produce higher incorrect-answer rates on Q2 and Q3 because the activated schema directly contradicts the correct answer (pre-registered test specifications: §4.5; schema-import mechanism: §6.2). If confirmation code outperforms fingerprint on the privacy questions, the production default should change.

### 1.3 Contributions

This paper makes six contributions: (1) **PIUP** — a formally-characterized design class with three invariants and one named limitation for coercion-resistant confirmation in privacy-preserving submission systems (§2.1, §6.5); (2) **Aztec Private Voting** — a Noir ZK smart contract and React component library implementing PIUP on the Aztec v5 testnet (§3); (3) **Study 1** — a pre-registered 4-condition between-subjects experiment (N=280) on identifier label effects on privacy mental models (§4); (4) **Study 2** — a pre-registered 2×2×2 factorial (L × E × I; 8 cells, N=240) on explanation and calibration effects (§5); (5) **Study 3** — a pre-registered two-arm field pilot (N≥80) testing whether a social-verification counter increases post-vote verification return rates (§6.5, §7); and (6) **Study 4** — a pre-registered 2×2 vignette experiment (N=160; UI-lock D × coercion pressure P) testing whether a UI-level temporal lock on the submission token produces genuine coercion deniability under adversarial pressure; two pre-registered DVs: sharing intent (DV1, primary confirmatory) and perceived social deniability of the technical excuse (DV2, secondary confirmatory) (§6.5, §7).

### 1.4 Scope and relation to prior work

PIUP applies beyond voting: sealed-bid auctions, whistleblower submissions, and anonymous peer review face the same constraint — confirmation must not confirm content.

Prior e-voting usability work evaluates voter *verification* (ballot inclusion checking) rather than voter *comprehension* of what the inclusion proof proves or withholds. STAR-Vote (Bell et al. 2013), Helios (Adida et al. 2009), Marky et al. (2018), and Kulyk et al. (2015) measure task completion, workload, or cryptographic eligibility-hiding, not receipt representational semantics. Carback et al. (2010) evaluate whether voters *use* the Scantegrity II affordance, not whether they correctly model the privacy property. No prior work directly examines what voters *believe* a cryptographic receipt reveals about their vote choice.

---

## 2. The PIUP Design Pattern

### 2.1 Formal specification

PIUP applies to any system satisfying three conditions simultaneously: (1) the system can confirm that a submission was received and processed; (2) the system must *not* confirm the content of the submission; and (3) users bring prior confirmation experience that leads them to expect content in the confirmation.

Under these conditions, the receipt is built from four components, listed in the order they appear in the rendered receipt:

**Status line.** A direct statement that the submission was received and processed: *"Your ballot was counted"* or equivalent. The status line must appear before any other receipt content; status-first placement anchors interpretation before absent content becomes salient (Egelman and Schechter, 2013; see §1.1).

**Submission token.** A surrogate identifier for the submission event, given to the user as the receipt's primary artifact. The token must satisfy three invariants:

*Invariant 1 (Surrogate independence).* The token must not be derivable from the submission content, the user's identity, or any publicly observable system state; it must not allow anyone holding only the token to determine the submitted choice. Formally: `token = f(seed)`, `seed ← random`, `token ⊥ choice`; the token must be verifiable (`isInLedger(token) → bool`) without that lookup revealing the content.

*Invariant 2 (Surrogate privacy in transit).* Because the token travels with content during submission, any observable record of the submission can link token to content. The token must remain private until the content is definitionally public (vote closes, auction reveals); see Named Limitation (§1.1, §3.3).

*Invariant 3 (Minimal receipt content).* The receipt artifact must contain only what is needed to enable future verification: the token and a verification endpoint. No additional field is added without a justification against the coercion-resistance requirement.

**Protective framing.** An explicit signal that the absent content is a design guarantee, not a system failure. Two requirements: (a) name the absent content *before* the user notices it is missing — before the failure-inference forms; (b) attribute the absence to a system property, not a limitation: *"Your vote choice is not shown. This is intentional - the receipt proves you voted without revealing your choice."* Omitting this component triggers the default absent-content inference (error, incomplete transaction) (Whitten and Tygar, 1999).

**Verification affordance.** A persistent but non-intrusive mechanism for the user to confirm inclusion at a later time: *"When the vote closes, you can paste your vote fingerprint at [verification URL] to confirm it was counted."* Collapsed by default, it functions as a second-pass tool that does not compete for initial attention at the confirmation step.

### 2.2 Design alternatives considered and rejected

Three alternative designs were explored during system development and rejected on coercion-resistance grounds.

**Alternative 1: Show the vote choice, require authentication to view the receipt.** The receipt would contain the full submission, but be protected behind a credential (e.g., wallet signature). Rejected on Invariant 3 grounds: this design encodes the vote choice in the receipt (gated by authentication but present in the receipt document), directly violating the minimal-content constraint — no choice-revealing field may appear in the receipt. The gating does not eliminate the coercion surface; it shifts the coercion target from receipt content to receipt access. A coercer who cannot obtain the receipt can instead coerce the voter into signing an authentication message. The attack surface shifts; it does not shrink.

**Alternative 2: Use a random UUID as the submission token, without protocol binding.** A random 128-bit UUID would satisfy the independence sub-condition of Invariant 1 — it is not derivable from content, identity, or observable state — and could be stored locally. Rejected on Invariant 1 grounds: Invariant 1 requires not only independence but verifiability against a public ledger (`isInLedger(token) → bool`). A token that is not verifiable against a public commitment proves nothing to the voter or to a third party. The voter has a random number; they have no way to distinguish a genuine token from one generated by a compromised frontend. PIUP requires that the token be verifiable against the submission event, not merely random.

**Alternative 3: Omit the protective framing, rely on user inference from absence.** Prior work on absent-content interpretation (Whitten and Tygar, 1999) finds that users interpret absent expected content as failure unless absence is explicitly marked as intentional. In the receipt context, a voter who sees no vote choice and no explanation will conclude their vote was not recorded or that the transaction failed — a worse outcome than a coercible receipt, which at least confirms participation while revealing choice. The protective framing is a load-bearing component, not decorative copy.

**Alternative 4: Selective disclosure — allow the voter to prove their choice to trusted parties using a zero-knowledge proof of content.** This extends the receipt with a cryptographic mechanism: the voter holds a witness that, combined with the submission token, generates a ZK proof of the specific vote content, disclosed only to chosen recipients. Rejected on coercion-resistance grounds: selective disclosure reintroduces the coercion surface it appears to remove. If the voter *can* prove their choice to a trusted party, they can prove it to a coercer on demand. The *capacity* to prove is itself coercive; the only coercion-resistant receipt is one from which vote content cannot be proved at all — which is exactly what Invariant 1 requires. Selective disclosure eliminates passive receipt-freeness (§6.5): the voter *can* prove their choice to any party who demands it, including a coercer. The *capacity* to prove is itself coercive; no social excuse substitutes for genuine technical inability. PIUP's Invariant 1 enforces the artifact-layer guarantee: the receipt is technically incapable of proving choice, so no mechanism — social, legal, or cryptographic — can extract content confirmation from the receipt itself.

### 2.3 Pattern scope and generalization

PIUP applies to any submission system satisfying the three conditions in §2.1. Three domains beyond e-voting share the same constraint structure:

**Sealed-bid auctions.** After submitting a bid, the participant receives a confirmation. The confirmation must prove the bid was received without revealing the bid amount before reveal time — a direct instantiation of conditions (1)-(3). The submission token is the bid commitment; the protective framing names the amount as intentionally absent; the verification affordance enables post-reveal inclusion checking.

**Whistleblower submissions.** Systems such as SecureDrop confirm that a document was received without revealing content, source identity, or submission metadata to unauthorized parties. The PIUP pattern applies directly: the submission token is a channel pseudonym or intake reference; the protective framing names content as intentionally absent to distinguish successful submission from silent failure.

**Anonymous peer review.** Submission acknowledgement should not allow back-inference of reviewer identity through timing, acknowledgement sequence, or metadata correlation. Condition (3) is weaker here — authors do not strongly expect submission content in a confirmation — but conditions (1) and (2) apply, making PIUP a relevant template for double-blind review systems with active metadata-privacy guarantees.

Across these domains, the three invariants translate directly: the token must not be derivable from submission content (Invariant 1), must remain private until the coercion window closes (Invariant 2), and the receipt must contain only token and verification endpoint (Invariant 3). The protective framing component is most load-bearing where absent content was most strongly expected by users based on prior experience — making the voting receipt the most demanding design target and the strongest test case for the pattern.

---

## 3. System: Aztec Private Voting

Aztec Private Voting is a Noir ZK smart contract and React component library implementing the PIUP on the Aztec v5 testnet. It provides the canonical instantiation of the pattern described in §2 and is the system on which Studies 1 and 2 are run.

### 3.1 The Noir contract

The contract is structured as a single `PrivateVoting` Noir program with four principal entrypoints:

**`cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** — private entrypoint; generates a ZK proof enforcing double-vote prevention via a `SingleUseClaim` nullifier in the private kernel, then enqueues `record_vote`.

**`record_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** — public entrypoint (`#[only_self]`). Increments the tally for `vote_choice`, validates `receipt_id` uniqueness, marks `receipts[receipt_id] = true`. The `receipt_id` is the content-independent vote fingerprint: `Fr.random()` in the standard path; a deterministic field element derived from the holder's snapshot leaf or signing-key signature in the Babylon eligibility paths (§3.5).

**`finalize_vote()`** — callable after `end_time` if `vote_count >= quorum`; sets `is_finalized = true`, gating `get_final_tally` visibility. Callers poll `is_finalized()` or `verify_vote_counted()` for state.

**`verify_vote_counted(receipt_id: Field) → bool`** — public view; returns `receipts[receipt_id]`. Any receipt holder can confirm their ballot was counted without revealing vote content.

**Execution model.** Aztec separates private and public execution phases; this split is the mechanism underlying the wallet-to-ballot unlinkability guarantee (§3.3, Row 1). `cast_vote` is a private function: it executes entirely client-side on the voter's device. The Noir circuit generates a zkSNARK proof that the caller satisfies all casting constraints — eligibility (in gated modes), double-vote prevention via `SingleUseClaim`, and timing bounds — without revealing which wallet signed the transaction. The voter's device submits an opaque proof and nullifier hash to the Aztec sequencer; the sequencer verifies proof validity and executes the enqueued `record_vote` in the public phase. Because the public transaction contains no wallet identifier — only a receipt ID, vote choice, and nullifier hash — network observers cannot link a public tally increment to a specific wallet. The `SingleUseClaim` nullifier is derived from the voter's secret key and the contract address via the Aztec private kernel; inserting it into the kernel's nullifier tree prevents a second proof from the same key without exposing key material or voting history to any third party, including the contract deployer.

The contract is deployed on the Aztec v5 testnet (`docs/v5-upgrade-runbook.md`).

### 3.2 Eligibility modes

The system supports three eligibility configurations, deployed as separate contract instances rather than runtime-selected modes (to avoid cross-mode eligibility bypass; see §3.3):

**Open (`cast_vote`).** Any Aztec wallet can vote. The `eligibility_proof` parameter is ignored; the only constraint is that the wallet has not previously voted (enforced by `SingleUseClaim`). Suitable for governance votes where access is defined by token holdership at a snapshot date, enforced off-chain by DAO tooling.

**Token-gated (`cast_vote_token`).** The caller must prove in-circuit token balance above a configured minimum at a committed snapshot, via a depth-20 sha256-keyed Merkle membership proof; root encoded in the `tokenAddress` deployment parameter (`docs/deployment.md`).

**Allowlist (`cast_vote_allowlist`).** The caller must prove membership in a committed eligible-address set via depth-20 SHA-256 Merkle proof; root encoding mirrors the token-gated mode. Suitable for known-participant governance.

Separate deployments prevent cross-mode eligibility bypass: on TOKEN/ALLOWLIST contracts, `cast_vote` asserts `eligibility_mode == OPEN`, forcing callers onto gated entrypoints where in-circuit Merkle proof is required. Gated entrypoints also assert their expected mode, preventing wrong-mode invocation.

### 3.3 Security properties

Circuit analysis and trust-boundary audit across `main.nr` and `eligibility.nr` confirmed eight sound properties:

| Property | Enforcement mechanism |
|---|---|
| Wallet-to-ballot unlinkability | `SingleUseClaim` nullifier in Aztec private kernel |
| No vote after end\_time | `assert(now < config.end_time)` in `record_vote` |
| No finalization before end\_time | `assert(now >= config.end_time)` in `finalize_vote` |
| Tally only shown post-finalization | `assert(is_finalized)` in `get_final_tally` |
| `record_vote` not callable externally | `#[only_self]` decorator |
| Options count bounds | `> 1` and `<= 8` in constructor; `vote_choice < options_count` enforced at call-time in `record_vote` |
| No `is_finalized` bypass | Separate check in `record_vote` prevents post-finalize votes |
| Timing boundary correctness | At `t == end_time`: cast fails, finalize succeeds |

Three findings were resolved before the study — one HIGH severity and two LOW:

*F1-RESIDUAL (HIGH - gated vote bypass).* On TOKEN/ALLOWLIST contracts, the generic `cast_vote` entrypoint could be called with `eligibility_proof = 1`, bypassing the Merkle gate. Resolved by asserting `eligibility_mode == OPEN` in `cast_vote`; gated entrypoints perform the in-circuit Merkle proof before enqueuing `record_vote`.

*F2 (LOW - quorum bypass).* `quorum = 0` allows vacuous finalization; resolved by `assert(config.quorum > 0)` in the constructor.

*F3 (LOW - receipt-ID collision).* `receipt_id = 0` would block subsequent voters; resolved by `assert(receipt_id != 0)` in all entrypoints and React hooks.

Two design limitations are documented and not resolved at the prototype stage:

*L1 privacy gap.* `vote_choice` and `receipt_id` are plaintext public arguments in `record_vote`; an observer can build a `receipt_id → vote_choice` map. The threat vector is the public Aztec mempool and archive nodes: any observer with sequencer or archiver access can read `record_vote` calldata before vote close and construct the per-receipt map. After `is_finalized = true`, the aggregate tally is public and per-receipt correlation is harmless — a voter sharing a receipt after close reveals only that they participated, not their choice (which the tally already discloses at the aggregate level). The UI therefore scopes the privacy warning to the pre-finalization window: voters are advised to keep receipts private until the vote closes, at which point sharing for auditability purposes is safe. The M3 architecture resolves the underlying gap by moving `vote_choice` out of calldata: under M3, only a committed or encrypted form is submitted publicly, and the per-receipt map cannot be constructed without the tally key (§6.5). This limitation applies only to the current pre-M3 prototype.

*Receipt-freeness is partial.* No re-encryption mix is implemented; "coercion-resistant" is withheld from user-facing copy until resolved.

### 3.4 React component library and `VoteReceipt.tsx`

The system ships a React component library (`packages/react/`) providing the voter-facing UI including the PIUP instantiation. The key component is `VoteReceipt.tsx`, which renders the four PIUP components described in §2.1, listed in their actual rendering order:

- The status line: *"Your vote was cast"*
- The vote fingerprint (abbreviated hex: `shortenHex(receipt.receiptId, 6, 4)`; full value accessible via copy button)
- The protective framing: *"Your vote choice is not shown on this receipt. This is intentional - this fingerprint proves your ballot was counted without revealing what you voted for. Save it to verify after the vote closes, and keep it private until then."*
- The verification affordance: a collapsed *"How to verify"* section with a three-step explainer and a link to the `verify_vote_counted` endpoint

The component's download action writes a JSON receipt file via `serializeReceipt()`; the file contains the fingerprint, vote metadata, and transaction hash but not the vote choice (Invariant 3). Per §3.3, calldata observers can recover the choice via `txHash`; voters should treat receipts as private until vote close. The fingerprint (`Fr.random()`, 254-bit field element) is independent of wallet, vote ID, and choice — satisfying Invariant 1.

### 3.5 M2 ownership proof (defense-in-depth)

M2 adds in-circuit secp256k1 signature verification (EIP-191 personal_sign), closing the pre-computation attack surface (ADR-036). The proof compiles to 339 ACIR + 348 Brillig opcodes; 7/7 Noir tests pass. `VoteReceipt.tsx` handles all eligibility modes identically.

---

## 4. Study 1: Label Choice and Privacy Mental Model

### 4.1 Research questions and hypotheses

**RQ1.** Which identifier label ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") produces the most accurate comprehension of what the PIUP receipt proves?

**RQ2.** Does the fingerprint/confirmation-code distinction produce a dissociation on privacy-specific items vs. overall accuracy?

**RQ3.** Does the familiar eCommerce label ("confirmation code") produce higher confidence ratings despite comparable or lower accuracy — a calibration failure — compared to the less familiar "vote fingerprint"?

**H1 (pre-registered confirmatory; m = 2):** A > D on Q2 and Q3 (fingerprint > neutral baseline on the privacy-model questions; pre-registered directional magnitude: ≥ 10 pp on each).
**H2 (pre-registered confirmatory; m = 3; primary endpoint):** A > B on Q2 (primary endpoint) and Q3 (secondary); A ≈ B on overall accuracy composite (TOST, ±10 pp). Q2(A>B) is the single pre-specified primary endpoint for the study; pre-registered directional magnitudes: ≥ 10 pp on Q2 (primary), ≥ 8 pp on Q3 (secondary) (pre-reg §H2).
**H3 (pre-registered confirmatory; m = 6):** C lower than ≥ 2 of {A, B, D} on Q1 ("does this prove your vote was counted?") after Holm correction — reversal risk from "nullified" reading; 6 pre-registered tests (Q1(C<A), Q1(C<B), Q1(C<D), composite C<each; composite pairings conditional on omnibus significance); pre-registered directional magnitudes: Cond C < 45% on Q1, Cond A ≥ 65% on Q1.
**H4 (pre-registered confirmatory; m = 3):** Confidence(B) > Confidence(A), B > C, B > D — confirmation code borrows perceived competence from eCommerce familiarity. A secondary pre-registered calibration analysis (Spearman accuracy-confidence correlation, not Holm-corrected) is described in §4.5.

### 4.2 Study design

Between-subjects, 4 × 1 factorial experiment. The single manipulated factor was the receipt identifier label. Participants were randomly assigned to one of four conditions:

| Condition | Label | Category |
|-----------|-------|----------|
| A | vote fingerprint | Metaphor-activating (current production) |
| B | confirmation code | eCommerce convention |
| C | nullifier | Cryptographically correct |
| D | receipt ID | Generic / neutral |

All other receipt elements (status line, protective framing, identifier value, copy button, download prompt, verification panel structure) were held constant; panel text references the label in two instructions (§4.3). Condition assignment used Prolific's study-conditions feature (four study links, condition code embedded as URL parameter in Qualtrics).

**Participants.** Recruitment was through Prolific. Inclusion criteria: US-resident adults (18+), English-fluent (platform filter), self-reporting at least one online election, poll, or survey in the past 12 months, no prior participation (Prolific deduplication). Exclusion criteria: self-reported software engineering professionals (software developer, engineer, or programmer by primary occupation) or CS/SE students — both screened via Prolific screener (SC2) before study entry, preventing domain-expert contamination of the comprehension measures [JONY-ACTION O: File OSF Amendment 5 - CS/SE student screener extension (before CHI submission)] (the SC2 screener's extension of the professional exclusion to CS/SE students was made before pilot launch and is documented in the OSF amendment log as Amendment 5); participants failing both attention checks (single-check failure is not disqualifying — participants who fail only one check are retained; pre-reg §3) [JONY-ACTION T: File OSF Amendment 14 - correct attention check descriptions in pre-reg §3 (AC1: select "Strongly Disagree"; AC2: select third item = Carrot) before CHI submission]; and participants completing the study in fewer than 90 seconds (indicating non-serious completion; pre-reg §3).

Target sample: n = 70 per condition (N = 280 total), preceded by an instrument-validation pilot of n = 10 per condition (N = 40). No institutional IRB review was required under 45 CFR §46.104(d)(2); Prolific's standard participant protections and informed consent process apply.

**Power.** For the H2 primary confirmatory endpoint (Q2 accuracy, A vs. B, one-tailed, p1 = 0.65 vs. p2 = 0.50, expected difference 15 pp), α = 0.05, power = 0.80 requires n = 67 per cell (G\*Power 3.1.9.7, Faul et al., 2009; test: "Proportion: Inequality of two independent proportions", Cohen's h = 0.30). The target sample is n = 70 per cell (N = 280), providing approximately 82% power for the H2 primary endpoint. *Pre-registration note: original pre-reg computed n = 49 using McNemar (within-subjects); corrected pre-data to n = 67/cell (independent proportions, G\*Power). [Amendment 1: osf-amendment-filing-2026-06-24.md; all 14 hypotheses unchanged.]* For the omnibus chi-squared (df = 3, w ≈ 0.18), 80% power requires n ≈ 82/cell; at n = 70, omnibus power ≈ 0.67 (H2 pairwise is the primary test; omnibus is descriptive-secondary). If pilot Q2 effect < 15 pp, n expands to 75/cell before full launch. No interim hypothesis testing is conducted during or after the pilot; the pilot serves instrument validation and, if the Q2 pilot effect is below 15 pp, triggers a pre-specified sample size expansion to n = 75/cell (§4.2) — this expansion is a pre-registered adaptive rule, not an interim stopping rule.

### 4.3 Stimuli

Each participant was shown a single static screenshot of the post-vote receipt screen under their assigned condition. The four stimuli (condition-a-fingerprint.html, condition-b-confirmation-code.html, condition-c-nullifier.html, condition-d-receipt-id.html) are identical in structure, layout, and copy except for the receipt identifier label, its ARIA label, two label-name references within the collapsed verification panel ("check that your [label] appears"; "Paste your [label]"), and a small study-administration badge rendered in the lower-right corner of each stimulus ("Cond. A" through "Cond. D"). The badge encodes no label information — the letter-to-condition mapping was not disclosed to participants, and no participant-facing instruction referenced it. All other visible receipt copy was held constant. Held constant: status line ("Your vote was cast"), protective framing ("This receipt does not contain your vote choice. It proves your ballot was counted without revealing how you voted."), identifier value, copy button, download prompt. Note that the stimuli use a simplified protective framing that does not include the explicit design-intent signal ("This is intentional") present in the production VoteReceipt.tsx (§3.4) and the canonical PIUP framing (§2.1); Study 1 tests the label effect under this constant simplified framing, while Study 2 isolates the explanation itself as an independent variable (§5). The screenshot method controls stimulus presentation across participants and eliminates variability introduced by an interactive voting flow; the primary ecological validity cost is the absence of choice-commitment context (see §6.5).

Stimuli were committed to the repository at commit `fb710f5` before any participant data were collected. Any post-registration change to the stimuli HTML constitutes a pre-registered amendment and is noted in the deviations log.

### 4.4 Measures

Eight items assessed comprehension accuracy, confidence, and save intention. Table 2 lists abbreviated wording; full item text, response options, scoring rubrics, and amendment history are in the OSF supplementary instrument.

**Table 2. Study 1 measures.**

| Item | Abbreviated wording | Scoring | Hypothesis | Status |
|---|---|---|---|---|
| Q1-Inclusion | "Does having your [LABEL] prove your vote was counted?" | Binary; correct: Yes | H1, H3 | Confirmatory |
| Q2-Choice-blindness | "Does having your [LABEL] prove which voting option you chose?" | Binary; correct: No | H1, H2 primary | Confirmatory |
| Q3-Coercion scenario | "Imagine your employer asks you to show them this screen as proof of your vote. If you showed a third party your screen and your [LABEL], could they tell which voting option you chose?" | Binary; correct: No | H1, H2 secondary | Confirmatory |
| Q4-Receipt loss | "If you closed without saving your [LABEL], what would happen?" | Binary; correct: vote survives; [LABEL] is personal proof | - | Confirmatory |
| Composite accuracy | Proportion correct on Q1-Q4 | 0-1.0 | H2 (TOST) | Confirmatory |
| Q5-Open-ended | "Why might this voting system choose NOT to show you which option you voted for?" | 0-2, two raters, κ ≥ 0.70; rubric: OSF §11 | Pre-reg secondary | Pre-registered |
| MQ1-Mental model | "What does your [LABEL] prove about your vote?" | 0-2 additive (Inclusion + Non-leakage), two raters, κ ≥ 0.70 | - | Exploratory |
| Confidence | Post-Q1-Q4: "How confident are you in your answer?" (1-7) | Mean Q1-Q4 composite | H4 | Confirmatory |
| BI1-Save intent | "How likely would you be to save this code?" | 5-point (1 = Definitely would not, 5 = Definitely would) | Study 2 RQ4 preview | Exploratory |
| Label affect | "What is your first impression of the term '[LABEL]'?" | Valence -3 to +3 | - | Exploratory |

Q1-Q4: three-option forced choice; binary score = correct answer selected. Q5 and MQ1: two independent raters, κ ≥ 0.70 required (adjudicate below threshold). Confidence composite = mean rating across Q1-Q4. Composite accuracy (proportion correct Q1-Q4) is the primary RQ1 measure and H2 TOST endpoint; Q5 and MQ1 are scored separately.

Covariates (collected; not pre-specified as primary analyses): age (DM1, categorical), prior voting experience (DM3), and technology background (DM2: "Have you ever written code professionally or as part of a degree?"). Two Prolific attention checks are applied as exclusion criteria.

### 4.5 Analysis plan

The study pre-registers 14 confirmatory tests across four Holm families. Holm-Bonferroni correction applied within each family; no cross-family correction.

| Family | Pre-registered tests | m |
|--------|----------------------|---|
| H1 (fingerprint > receipt ID on privacy items) | Q2(A>D), Q3(A>D) | 2 |
| H2 (dissociation: fingerprint vs. confirmation code) | Q2(A>B) one-tailed, Q3(A>B) one-tailed, TOST composite A≈B ±10 pp | 3 |
| H3 (nullifier underperforms) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<A), composite(C<B), composite(C<D) [composite pairings conditional on omnibus significance; pre-reg §6.6] | 6 |
| H4 (confirmation code overconfidence) | confidence(B>A), confidence(B>C), confidence(B>D) | 3 |

**H1** (m = 2). Two one-tailed chi-squared tests on Q2 and Q3 accuracy, A vs. D; both must survive Holm correction.

**H2** (m = 3; primary endpoint). H2-primary: Q2 accuracy, A vs. B, one-tailed chi-squared (α = 0.05). H2-secondary: Q3 accuracy, A vs. B, one-tailed. H2-tertiary: TOST (Lakens, 2017) on composite accuracy (Q1-Q4), A vs. B; equivalence bounds ±10 pp (α = 0.05 per one-sided test; pre-reg §6.5); if equivalence not established, Cohen's h and 90% CI reported. All three pre-registered H2 outcome patterns are actionable (§6.2).

**H3** (m = 6). Three unconditional one-tailed chi-squared tests on Q1 accuracy (C vs. A, B, D; pre-reg §6.6) plus a 4-condition composite-accuracy omnibus ; if omnibus significant, Holm-corrected composite pairings for C proceed. Support criterion: C lower than ≥ 2 of {A, B, D} on Q1 after Holm correction. An ethics clause (§6.5) allows a fifth label to substitute for C if pilot Q1(C) < 30%; the m = 6 Holm family and α level are unchanged.

**H4** (m = 3). One-way ANOVA on confidence composite; if significant, Tukey HSD for B vs. A, C, D. **Calibration analysis (secondary; not Holm-corrected):** Spearman ρ(accuracy, confidence) per condition; H4 predicts r_B < r_A. H4 outcome: **supported** if ANOVA significant AND all three Tukey comparisons (B > A, C, D) survive Holm correction; **null** if ANOVA non-significant; **partial** if ≤ 2 comparisons survive; **direction reversal** if B < at least one condition. H4-supported triggers calibration note in PIUP documentation and co-primary I-factor analysis in Study 2 (pre-reg §13).

**Q5 (pre-registered secondary; pre-reg §6.8).** Kruskal-Wallis across 4 conditions; if significant, Dunn's post-hoc (Holm); κ ≥ 0.70 required (raters adjudicate below threshold). 25-response random sample per condition included in write-up. Q5/M6 cross-study comparisons are approximate (§5.4).

**Mental model quality (exploratory).** Mean score and distribution (0/1/2) by condition; κ ≥ 0.70 required; all comparisons exploratory.

**Behavioral intent (descriptive).** Mean BI1 score and distribution (5 = Definitely would save → 1 = Definitely would not) per condition; all comparisons descriptive (Study 2 RQ4, §5.1, is the confirmatory endpoint).

**Label affect (exploratory).** Mean valence (-3 to +3) and distribution by condition; all comparisons exploratory.

**Confidence interval standard.** All proportions: Wilson 95% CI. All means: 95% CI from t-distribution. All odds ratios: log-scale 95% CI.

### 4.6 Results

_[§4.6 pre-written structural narrative: fill [SLOT] markers from piup-study1-analysis.R output once data collected. Full slot-to-variable mapping in docs/chi-paper-s1-results-fill-template-2026-06-30.md. OSF DOI: [INSERT before submission]. JONY-ACTION O+T must be filed before data collection. Q5/M6 cross-study comparisons: apply approximate-comparison qualifier (§4.5, §5.4) — Part 2 criterion differs by design.]_

**Participants.** We recruited [SLOT: n_recruited] participants via Prolific. After applying pre-registered exclusions — [SLOT: n_excluded_sc2] excluded for CS or SE background (SC2), [SLOT: n_excluded_attn] excluded for failing both attention checks, [SLOT: n_excluded_rt] excluded for response time under 90 s — the analytic sample comprised [SLOT: n_final] participants ([SLOT: n_A]/[SLOT: n_B]/[SLOT: n_C]/[SLOT: n_D] per condition; pre-registered target: n = 70 per condition). [SLOT: n_browser_fallback] participants triggered the browser-fallback flag and were retained in the primary sample; sensitivity analyses excluding them are reported below where pre-specified. [SLOT: n_prior_study] participants reported prior receipt-study participation and were retained in the primary sample with a pre-specified sensitivity check. Demographics: median age [SLOT: age_median] (IQR [SLOT: age_iqr]); [SLOT: pct_tech_bg]% reported a technology background (DM2); [SLOT: pct_prior_vote]% reported prior online election participation.

**Inter-rater reliability.** Q5 (open-ended reasoning): κ = [SLOT: kappa_Q5]. MQ1 (mental model quality): κ = [SLOT: kappa_MQ1]. [If either κ < 0.70: insert adjudication note and post-adjudication κ here.] Both measures require κ ≥ 0.70 before entering the primary analysis.

**Overall accuracy.** Table 3 shows composite Q1-Q4 accuracy by condition. The omnibus chi-squared test across all four conditions was [SLOT: omnibus_significant_or_not]: χ2([SLOT: df_omnibus]) = [SLOT: omnibus_stat], p = [SLOT: omnibus_p] (Cramér's V = [SLOT: omnibus_V]). [Note: omnibus at 80% power requires n ≈ 82/cell; at the pre-registered n = 70, power is approximately 0.67. A non-significant omnibus does not affect the pre-specified pairwise families H2 and H3.]

**H1-Fingerprint versus receipt ID on privacy items (m = 2).** Q2 accuracy (choice-blindness scenario): [SLOT: pct_Q2_A]% (condition A: fingerprint) versus [SLOT: pct_Q2_D]% (condition D: receipt ID); χ2(1) = [SLOT: h1_q2_stat], p (one-tailed) = [SLOT: h1_q2_p]; OR = [SLOT: h1_q2_or] [SLOT: h1_q2_ci]. Q3 accuracy (coercion scenario): [SLOT: pct_Q3_A]% (A) versus [SLOT: pct_Q3_D]% (D); χ2(1) = [SLOT: h1_q3_stat], p (one-tailed) = [SLOT: h1_q3_p]; OR = [SLOT: h1_q3_or] [SLOT: h1_q3_ci]. After Holm-Bonferroni correction (m = 2): [SLOT: H1_verdict - "both survive (H1 supported)" | "H1-Q2 survives only (partial)" | "neither survives (H1 null)" | "H1-reversed"].

**H2-Fingerprint versus confirmation code dissociation (m = 3; primary endpoint).** H2 is the primary pre-registered endpoint. H2-primary (Q2 accuracy, absent-content inference): [SLOT: pct_Q2_A]% (A: fingerprint) versus [SLOT: pct_Q2_B]% (B: confirmation code); difference [SLOT: h2_q2_diff] percentage points; χ2(1) = [SLOT: h2_q2_stat], p (one-tailed) = [SLOT: h2_q2_p]; OR = [SLOT: h2_q2_or] [SLOT: h2_q2_ci]. H2-secondary (Q3 accuracy, coercion scenario): [SLOT: pct_Q3_A]% (A) versus [SLOT: pct_Q3_B]% (B); χ2(1) = [SLOT: h2_q3_stat], p (one-tailed) = [SLOT: h2_q3_p]; OR = [SLOT: h2_q3_or] [SLOT: h2_q3_ci]. H2-tertiary (TOST, composite accuracy equivalence): composite A [SLOT: pct_acc_A]% versus composite B [SLOT: pct_acc_B]%; difference [SLOT: h2_tost_diff] pp (pre-registered equivalence bounds: ±10 pp); TOST p = [SLOT: h2_tost_p]; equivalence [SLOT: "established" | "not established - Cohen's h = [SLOT: h2_cohen_h], 90% CI [SLOT: h2_ci_90_lo] to [SLOT: h2_ci_90_hi]"].

After Holm-Bonferroni correction (m = 3): **H2 outcome: [SLOT: "supported (Q2 A > B significant AND composite equivalent)" | "null (Q2 non-significant AND equivalent)" | "reversed (B > A significant AND equivalent/B composite higher)" | "inconclusive (report Cohen's h and 90% CI)"]**. The H2 outcome determines the recommended receipt label in deployment (§6.2); all four possible verdicts are actionable without instrument redesign.

**H3-Nullifier underperforms on inclusion inference (m = 6).** Q1 accuracy (inclusion recognition) by condition: A [SLOT: pct_Q1_A]%, B [SLOT: pct_Q1_B]%, C [SLOT: pct_Q1_C]%, D [SLOT: pct_Q1_D]%. Pre-specified unconditional pairwise tests (C versus A, B, D; one-tailed; Holm correction across m = 6 family):

| Comparison | χ2(1) | _p_ (one-tailed) | OR [95% CI] | Holm corrected |
|---|---|---|---|---|
| Q1: C < A | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig / ns] |
| Q1: C < B | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig / ns] |
| Q1: C < D | [SLOT] | [SLOT] | [SLOT] | [SLOT: sig / ns] |
| composite: C < A | [SLOT - conditional on omnibus significant] | [SLOT] | [SLOT] | [SLOT] |
| composite: C < B | [SLOT] | [SLOT] | [SLOT] | [SLOT] |
| composite: C < D | [SLOT] | [SLOT] | [SLOT] | [SLOT] |

**H3 outcome: [SLOT: "supported (C lower than ≥ 2 of {A, B, D} on Q1 after Holm)" | "partial (C lower than 1 of {A, B, D} on Q1 after Holm)" | "null"]**. [Ethics-clause note: if Q1 accuracy in condition C falls below 30%, a label-substitution recommendation is triggered per §4.2.]

**H4-Confirmation code and confidence miscalibration (m = 3).** One-way ANOVA on confidence composite across four conditions: F([SLOT: df_between], [SLOT: df_within]) = [SLOT: h4_F], p = [SLOT: h4_p], η2 = [SLOT: h4_eta2]. [If significant:] Tukey HSD post-hoc comparisons (B versus A, C, D; Holm correction m = 3):

| Comparison | Mean diff | 95% CI | _p_ (Tukey) | Holm corrected |
|---|---|---|---|---|
| B > A | [SLOT] | [SLOT] | [SLOT] | [SLOT] |
| B > C | [SLOT] | [SLOT] | [SLOT] | [SLOT] |
| B > D | [SLOT] | [SLOT] | [SLOT] | [SLOT] |

Mean confidence composite per condition: A [SLOT: conf_mean_A] (SD [SLOT]), B [SLOT: conf_mean_B] (SD [SLOT]), C [SLOT: conf_mean_C] (SD [SLOT]), D [SLOT: conf_mean_D] (SD [SLOT]). **H4 outcome: [SLOT: "supported (ANOVA sig AND all 3 Tukey survive Holm)" | "partial (ANOVA sig, ≤2 Tukey survive)" | "null"]**. [H4 outcome gates Study 2 H2.3 (calibration secondary): if H4 supported, H2.3 is live; if H4 null, H2.3 is dropped and Study 2 reduces to N = 160.]

Calibration analysis (pre-registered secondary, not in Holm family): Spearman ρ between accuracy score (0-4) and confidence composite per condition: A ρ = [SLOT], B ρ = [SLOT], C ρ = [SLOT], D ρ = [SLOT]. Reported descriptively; no NHST verdict.

**Q5-Open-ended reasoning (pre-registered secondary).** [Conditional on κ ≥ 0.70:] Mean Q5 score (0-2 rubric) by condition: A [SLOT] (SD [SLOT]), B [SLOT] (SD [SLOT]), C [SLOT] (SD [SLOT]), D [SLOT] (SD [SLOT]). Kruskal-Wallis: H([SLOT]) = [SLOT: KW_stat], p = [SLOT: KW_p]. [If significant: Dunn's post-hoc (Holm correction): [SLOT: surviving pairs].] A random sample of 25 responses per condition is included in OSF supplementary materials. [Any cross-study comparison to Study 2 M6 scores applies the approximate-comparison qualifier: Q5 Part 2 = mechanism reason; M6 Part 2 = intentional-design or harmful-consequence.]

**Exploratory analyses.** MQ1 (mental model quality, κ = [SLOT]): distribution of 0/1/2 per condition reported descriptively; no pre-specified NHST. BI1 (save intention, 1-5): mean per condition A [SLOT], B [SLOT], C [SLOT], D [SLOT]; previews Study 2 RQ4, no pre-registered test in Study 1. Label affect (valence -3 to +3): mean per condition A [SLOT], B [SLOT], C [SLOT], D [SLOT].

**Sensitivity analyses.** [If n_browser_fallback > 0:] Replication of H2-primary excluding browser-fallback participants (n = [SLOT] excluded): χ2(1) = [SLOT], p (one-tailed) = [SLOT]; verdict [SLOT: unchanged / changed]. [If n_prior_study > 0:] Replication of H2-primary excluding prior-study participants (n = [SLOT] excluded): χ2(1) = [SLOT], p = [SLOT]; verdict [SLOT].

---

## 5. Study 2: Explanation Effects and Calibration Interventions

Study 1 isolates the label effect while holding explanatory copy constant. Study 2 isolates the explanation as the independent variable, crossing it with the theoretically central label contrast and a calibration intervention.

### 5.1 Research questions

**RQ1 (Explanation effect).** Does an explicit absent-choice explanation in the receipt increase correct absent-content interpretation, trust, and self-reported save intention, compared to a receipt with no explanation? (See §6.1, §6.3.)

**RQ2 (Label × Explanation interaction).** Is the explanation effect moderated by label — specifically, does “confirmation code” produce lower absent-content accuracy without explanation (schema import unchecked), closing the gap to "vote fingerprint" when explanation is added? (See §6.1, §6.2.)

**RQ3 (Calibration intervention).** Does an accuracy-feedback intervention before the receipt increase correct absent-content interpretation and reduce confidence miscalibration without reducing save intention? (See §6.2, §6.3.)

**RQ4 (Save behavior).** Does correct absent-content interpretation predict observed save behavior (download click)? Is this relationship moderated by calibration? (See §6.1.)

### 5.2 Design

2×2×2 between-subjects factorial experiment.

**Factor L (Label; 2 levels):** L1 = "vote fingerprint"; L2 = "confirmation code." "Nullifier" and "Receipt ID" are excluded — Study 1 characterized both (§4.1-4.3).

**Factor E (Explanation; 2 levels):** E1 = explanation present: "Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [label] is the only thing you need - matching it later proves your ballot was counted, nothing more." E2 = explanation absent: the receipt shows the identifier, "Your vote was cast," the download prompt, and verification instructions. A minimal privacy note ("Your vote is private and verifiable") is retained in E2 to avoid a privacy-awareness confound; only the absent-choice explanation is omitted (design note §6.1).

**Factor I (Calibration intervention; 2 levels):** I1 = no intervention; participant sees the receipt directly. I2 = calibration intervention: two comprehension questions with correct-answer feedback presented before the receipt. I is crossed with L × E, producing 8 cells; N = 30 per cell (N = 240 total).

**Power (preliminary estimates).** H2.1 (Q-AC accuracy, E main effect; 50% → 70%, OR ≈ 2.3, one-tailed, α = 0.05): ≈84% power at n = 30/cell (design note §10.1). H2.2 (M2 trust, L × E interaction; f ≈ 0.22): ≈80% power (design note §10.2). H2.3 (t-test on M4 residual, one-tailed, L2 cells only; d = 0.50; n = 60/I level, pooling E1+E2 within L2): ≈86% power (design note §10.3); Study 2b (L2 only, N = 80) pre-planned if inconclusive. Final estimates revised after Study 1 pilot data.

### 5.3 Platform

Study 2 uses the actual `VoteReceipt.tsx` component from the Aztec Private Voting React package, hosted on Vercel in study mode. Static screenshots (Study 1) are insufficient because the download affordance must be clickable and the I2 intervention requires pre-receipt interaction. Hosting the production component increases ecological validity for trust and behavioral-intention measures. Study mode logs: download-button click (no file written), verification-section expansion, and intervention response accuracy.

### 5.4 Measures

**Primary confirmatory endpoint.** Absent-content interpretation (Q-AC): "Looking at that receipt: does it show which voting option you chose?" (Correct: No, my vote choice is not shown; foils: Yes, my vote choice is shown / It's not clear.) Administered after a transition screen that hides the receipt; "that receipt" is a retrospective reference recalled from memory. The recall-probe design is deliberate: administering Q-AC while the receipt remains visible would reduce the question to a reading task — a participant who has formed no stable mental model can still answer correctly by scanning the receipt for an absent field. The transition screen ensures the measure captures what the receipt communicates under ordinary reading conditions, not what a careful second pass of the stimulus reveals. This is the internal-validity constraint behind the delayed probe and the retrospective phrasing; it also distinguishes PIUP comprehension measurement from feature-detection tasks common in interface evaluation.

**Additional primary measures (design note §7.1).** Save intention (M3): 7-point Likert (1 = Definitely will not, 7 = Definitely will), supplemented by observed download-button click. Trust composite (M2): 4-item adapted McKnight (2002) scale — integrity items TI1 ("I believe this receipt accurately reflects what happened with my vote") and TI2 ("I trust that the [label] is unique to my ballot"); competence items TC1 ("I feel confident I could use this receipt to prove my ballot was counted") and TC2 ("I understand what this receipt is for"); composite = mean of four items; α ≥ 0.70 required.

**Secondary measure - all conditions (survey instrument §11).** Confidence-accuracy residual (M4): single-item confidence rating — "How confident are you in your answer above?" (7-point; 1 = not at all confident, 7 = completely confident; placed immediately after Q-AC, before the trust scale; N = 240) — yielding M4_residual = (M4_raw - 1)/6 - Q-AC binary accuracy. Positive residual = overconfidence; negative = underconfidence. M4 is collected from all N = 240 participants (not I2 only); this is required for the H2.3 conditional t-test (I1-L2 vs. I2-L2) to be feasible.

**Supplementary measure.** Open-ended absent-choice explanation (M6 / Q-OE): "In your own words, why doesn't this receipt show which voting option you chose?" Scored 0-2 by two independent raters (κ ≥ 0.70 required before any M6 analysis; rubric in design note §7.2); if κ ≥ 0.70: Kruskal-Wallis across 8 conditions (Dunn's post-hoc, Holm); if κ < 0.70: M6 analysis not reported (pre-reg §6.7). Random 15 responses per condition as illustrative examples. M6 is not confirmatory. The Part 2 score-2 criterion differs from Study 1 Q5 by design (M6 accepts intentional-design or harmful-consequence framing; Q5 requires a mechanism reason), so direct cross-study score comparisons are approximate.

### 5.5 Primary analysis

The primary analysis axis is contingent on Study 1 outcomes (full decision table in design note §3).

**H2.1 (RQ1; primary).** One-tailed chi-squared on Q-AC accuracy (E1 pooled vs. E2 pooled × correct/incorrect, pooling across L and I; α = 0.05; direction: E1 > E2); quantity: OR with 95% Wilson CI. Participants receiving a static screenshot due to browser rendering failure (browser_fallback = 1; ~3% expected) are retained in the primary analytic sample; H2.1 and H2.4 are each re-run excluding them as pre-specified sensitivity checks (design note §9.3).

**H2.2 (RQ2; secondary).** Two-way between-subjects ANOVA (L × E) on M2 trust composite, pooling across I; if the interaction F is significant (α = 0.05), simple effects of E within L1 and L2 separately (Welch's t). If not significant: 90% CI on the interaction contrast. Pre-specified on M2; an ordinal Q-AC pattern ("confirmation code" underperforms without explanation, gap closes with explanation) is predicted but not confirmatory.

**H2.3 (RQ3; pre-specified conditional secondary).** If Study 1 H4 is supported (§4.5): two-sample t-test on M4 confidence-accuracy residual in L2 cells (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05; n = 60 per I level, pooling E1+E2 within L2; quantity: Cohen's d + 95% CI. With a no-harm test on M3 save intention: TOST equivalence (equivalence bounds ±0.5 SD; Lakens, 2017; α = 0.05 per one-sided test; `TOSTER::tsum_TOST`, var.equal = FALSE); if equivalence not established (p_max ≥ 0.05): report M3 Cohen's d + 90% CI (pre-reg §6.4).

**H2.4 (RQ4).** Logistic regression of observed download click on Q-AC accuracy, with L, E, I as covariates (main effects, no interactions); quantity: OR for Q-AC accuracy. Pre-specified sensitivity: re-run excluding browser-fallback participants (design note §9.3). Pre-specified exploratory: re-run adding Q-AC × I interaction term; report interaction OR + 95% CI (tests whether calibration moderates the Q-AC → download relationship; not confirmatory).

H2.1-H2.4 are independent pre-specified predictions; no cross-hypothesis correction applied. A single pre-specified test is performed per hypothesis; no within-family multiplicity adjustment is required (design note §9.2). Exploratory comparisons across all L × E × I cells are descriptive only.

### 5.6 Status

Study 2 pre-registration DRAFT is complete (`docs/piup-study2-preregistration-draft-2026-06-29.md`, 23 design amendments incorporated as of 2026-06-30). The DRAFT is OSF-ready pending two gates: (a) Study 1 pilot data (N = 40) to calibrate baseline Q-AC accuracy estimates for H2.1 power (pre-reg §4 sampling plan), and (b) Study 1 H4 outcome from the full launch (N = 280) to resolve the H2.3 conditional secondary dependency and set final N (240 if H4 supported; 160 if not). Study 2 contribution is now C4 in the six-contribution list (§1.3, updated tick-4402; described as 'pre-registered 2×2×2 factorial'). If Study 2 is uploaded to OSF before CHI submission, add OSF DOI to C4 in §1.3 and update §5.6, §6.2, and §7 accordingly. Full design specification: `docs/piup-study2-design-note-2026-06-22.md`. [Updated tick-4293: status advanced from design-note stage to pre-registration DRAFT complete (14 amendments, 2026-06-30); OSF gates unchanged.] [Updated tick-4327: amendment count corrected 14→23 to reflect Amendments 15-23 incorporated 2026-06-30 via cross-check (tick-4321); all 23 amendments are pre-data; OSF gates unchanged.]

---

## 6. Discussion


### 6.1 When does protective absence work?

The PIUP's central design hypothesis is that a receipt which omits the vote choice can produce correct user behavior — saving the identifier, returning to verify — without triggering the failure-reading (the vote was not recorded). For this to hold, two conditions must be met simultaneously: the receipt must carry an explicit design-intent signal that distinguishes protective omission from system failure, and the submission token must carry a label-metaphor consistent with the correct privacy mental model.

Neither condition alone is sufficient.

An absent-choice receipt without design-intent framing falls into the failure mode documented by Whitten and Tygar (1999) for cryptographic systems: when systems produce outputs users cannot interpret, users conclude something has gone wrong, not that the system is protecting them. Even security-aware users dismiss unexpected security feedback when it does not align with their threat model — acting from bounded rationality, they conscientiously bypass it (Egelman and Schechter, 2013). The Protective framing component — "Your vote choice is not shown. This is intentional - it protects your privacy" — resolves this by naming the absent content before the user notices it is missing, establishing design purpose before the failure-inference can form.

However, protective framing addresses only one axis of the mental-model problem. The label on the submission token carries an independent schema effect on the privacy-model questions specifically. A user whose mental model is "the confirmation code links back to my vote choice, as in eCommerce" has the *behavioral* model approximately correct (save the identifier; use it later to verify) while having the *privacy* model wrong (the code reveals my choice to anyone who has it). The framing may not fully override the representational schema that "confirmation code" activates — a question Study 2's L × E test addresses directly (§5.5). "Vote fingerprint" carries uniqueness-without-content semantics (a fingerprint identifies without describing), with no implication that the identifier encodes what was voted.

The design implication is that Invariants 1-3 are necessary but not sufficient for correct privacy-mental-model formation. The Protective framing component handles the failure-inference problem; the token label handles the schema-import problem. In the PIUP receipt, both must be correct simultaneously: absent-content framing without a privacy-appropriate label leaves the privacy-model questions vulnerable; a privacy-appropriate label without absent-content framing leaves the failure-inference unaddressed. The pattern requires both components; neither is sufficient alone (design inference; Study 1 holds protective framing constant and includes no without-framing baseline — §2.2, §6.5).

### 6.2 The confirmation code paradox

Familiarity produces confidence (McKnight et al., 2002): when a convention correctly describes system behavior, it reduces friction without cost.

In privacy-critical contexts, familiar conventions carry a hidden cost. In eCommerce, "confirmation code" activates a trust complex: the belief that the code is retrievable evidence of a specific transaction — correct in every prior context the user has encountered, wrong in private voting, where the correct schema is *confirmation = proof of counting, not proof of content*. A user applying the eCommerce schema will be confident while holding a wrong mental model on the privacy-specific questions — the over-reliance Lee and See (2004) describe in trust automation — and the mismatch is invisible until a coercion scenario forces the receipt's privacy properties to matter.

The schema-import mechanism generates two pre-registered predictions (§4.5). **H2 (dissociation)** predicts that "confirmation code" and "vote fingerprint" perform comparably on the overall accuracy composite while diverging specifically on Q2 and Q3, where the eCommerce-evidence schema directly contradicts the correct answer. **H4 (confidence miscalibration)** predicts higher self-reported confidence for "confirmation code" (B > A, B > C, B > D) despite the Q2/Q3 accuracy deficit. If H4 is supported, the label simultaneously does the designer's work of reducing onboarding friction and the coercer's work of degrading the privacy mental model — without the deficit being apparent to the user.

This is the *familiarity tax*: familiar labels in privacy-critical contexts reduce onboarding friction but create a privacy-mental-model deficit that compounds under coercion or audit. The deficit is invisible to users (they feel confident) and to designers (the interface performs well on standard usability metrics) — precisely when it matters most. Familiar-convention adoption therefore requires an additional evaluation step: not only "does this reduce cognitive load?" but "does this import a schema that contradicts the privacy model?" Study 2 provides pre-specified tests of this question: H2.1 (primary; §5.5) tests the explanation main effect on absent-content accuracy (Q-AC, E pooled); H2.2 (secondary; §5.5) tests the label × explanation interaction on trust calibration — the formal H2.2 endpoint is M2 trust composite, while the corresponding Q-AC ordinal pattern (confirmation code underperforms without explanation, gap narrows with explanation) is pre-predicted under H2.2 but non-confirmatory.

### 6.3 The protective absence feedback inversion

Norman's (1988, p. 27) feedback principle holds that the system must send back to the user information about what action was done and what result was accomplished — a design resource in most contexts, where the relevant system state is something that *happened*. PIUP inverts this. The relevant state is something that was *protected from happening*: the vote choice was not recorded in the receipt. Absence is not self-explaining: a receipt that simply omits the vote choice gives the user nothing to interpret, producing the conceptual-model divergence Norman's own model predicts.

This is the *protective absence feedback problem*: how do you provide feedback for the correct absence of information? Two prior designs face the same structural inversion. The HTTPS lock icon communicates channel protection — an absence-of-eavesdropping signal — without conveying anything about content. Prior usability research documents how poorly users understand what the lock means (Felt et al., 2016): "secure channel" is routinely misread as "trustworthy site," importing protection from the wrong layer. Behavioural advertising opt-out mechanisms face the same inversion: the signal communicates system restraint rather than user action. Many participants confused opting out of behavioural targeting with blocking ads entirely (Leon et al., 2012). In both cases the protection is at one layer and users form their mental models from another.

What may distinguish PIUP's case is the nature of the counterintuitive demand. In the HTTPS and advertising opt-out cases, the protected resource (encrypted channel, suppressed tracking) is not content the user was actively seeking at that moment. In PIUP, the absent content — the vote choice the user most wants to confirm — is exactly what is being protected: the most-wanted information is the most-protected. Whether this produces a harder design challenge is an empirical question our studies are not powered to answer directly (Study 1 holds no comparison against HTTPS mental models), but it does position PIUP as a more demanding instance of the protective-absence problem: the receipt's job is to signal protection without supplying the one thing the user came for.

The Protective framing component is the design response. Where the HTTPS lock provides a small ambiguous icon, PIUP provides prose that names the absent thing, names the protection reason, and names the beneficiary in a single step — positioned in the primary receipt flow, after the submission token, before the user has finished reading the receipt. The protective absence feedback problem is addressed by treating the absence as a first-class receipt element, not as a secondary explanation for a gap the user might or might not notice.

### 6.4 Generalisation beyond voting

The underlying design problem is domain-independent. The PIUP invariants apply to any system in which (1) a receipt must confirm that an action was recorded, (2) the action's content must be protected from disclosure in the receipt, and (3) the user must be left with a correct mental model of both the confirmation and the protection.

**Sealed-bid auctions.** In a sealed-bid auction, the bid receipt must confirm that a bid was submitted without revealing the bid amount. The PIUP invariants apply: Invariant 1 requires the submission token be independent of bid amount, bidder identity, and observable state, and be verifiable against a public ledger; Invariant 2 requires the token remain private until the auction reveal event, at which point the token-to-bid link is no longer actionable for coercion; Invariant 3 requires no bid-amount field in the receipt, with protective framing explaining the amount is withheld to preserve auction integrity. The label question recurs: "bid receipt," "submission token," and "bid confirmation" carry different schema loads.

**Whistleblower drops.** In secure document submission systems, the receipt must confirm that a document was received without confirming its contents. The PIUP invariants apply: Invariant 1 requires the token be independent of document content, submitter identity, and observable state, and be verifiable against a public ledger; Invariant 2 requires the token remain private until the content is definitionally public; Invariant 3 requires no content metadata appear in the receipt, with protective framing explaining that details are withheld to protect source anonymity. A domain-specific wrinkle: in employer-facing contexts, the adversary may already know the content and aim to confirm who submitted; protective framing must be precise about what the token does and does not reveal.

**Anonymous peer review.** In double-blind peer review, the submission receipt must confirm a review was recorded without confirming the reviewer's identity. Many conference systems provide a "your review has been submitted" confirmation with no submission token, leaving the reviewer with no durable proof of submission. A PIUP implementation issues an opaque token: Invariant 1 requires it be independent of review content, reviewer identity, and observable system state, and be verifiable against a public ledger; Invariant 2's transit-privacy timing window closes at the review decision; Invariant 3 requires no score, text excerpt, or rating appear in the receipt, with protective framing explaining that review content is withheld to preserve double-blind integrity.

**Common structure.** Across all three cases, the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event (auction reveal, content publication, or review decision), but the structural requirements — token independence, token privacy until that event, and minimal-content receipt — hold without change. The variation across domains is in token label semantics, protective framing text, and the threat model that motivates the protection. A domain-level note on Invariant 1: the voting instantiation uses a public blockchain to make `isInLedger(token) → bool` verifiable by anyone without trust in a central operator. In sealed-bid auctions, whistleblower systems, and peer review, the authoritative record is typically a trusted-operator database rather than a public ledger; Invariant 1 is satisfied when the operator's record is integrity-protected (e.g., append-only logs with cryptographic sealing) and the lookup does not reveal submission content. Whether the record is publicly inspectable or requires operator mediation is an instantiation choice; the structural independence and minimal-content requirements hold regardless. PIUP names a design category — the *coercion-surface receipt* — rather than a single context-specific pattern: any confirmation receipt that could be used under adversarial conditions to infer what the user chose, submitted, or authored falls within this category.

### 6.5 Limitations

**Protocol exposure and receipt-freeness.** PIUP achieves *passive receipt-freeness* at the artifact layer: the receipt withholds the vote choice (Invariant 3) and protective framing names the absence, so the receipt itself cannot serve as a proof of how the voter voted. It does not achieve *active receipt-freeness* as defined by Benaloh and Tuinstra (1994): the current Aztec Private Voting implementation exposes `vote_choice` and `receipt_id` as plaintext arguments in `record_vote` public calldata, so an observer monitoring on-chain calldata can construct a `receipt_id → vote_choice` map without access to the receipt, and a voter who shares their fingerprint indirectly reveals their vote through this public link. Full coercion resistance (Juels, Catalano, and Jakobsson, 2005) — the stronger property that a voter cannot construct a vote-proof at all — is similarly not achieved at L1. The calldata exposure is resolved at the application layer in M3, which removes `vote_choice` from `record_vote`'s public arguments; the receipt-level passive guarantee (Invariants 1-3) holds regardless of whether M3 is deployed. "Coercion-resistant" is withheld from user-facing copy pending this protocol fix (§3.3). This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference, not protocol threat-model awareness.

**Ecological validity.** Study 1 uses screenshot stimuli, removing the choice-commitment context present in real voting flows. Confidence ratings and save intention may be underestimated when participants assess a static receipt for a choice they did not actively make. Study 2 improves ecological validity substantially — participants cast a simulated vote before receiving the receipt — but three bounds remain: the vote is consequentially inert; the Prolific sample (US-based English-speaking online workers) may not represent DAO governance participant populations; and both studies measure receipt comprehension immediately after voting, not at the delayed-verification event that the downloaded receipt is intended to support. These bounds primarily constrain effect-size generalisation; internal validity of the factorial contrasts is not affected.

**Demand characteristics and label substitution.** In Condition C (nullifier label), Q1 reads: "Does having this *nullifier* prove that your vote was counted?" The word "nullifier" in the question stem may independently depress Q1-C accuracy — participants associating "nullifier" with "null, cancelled" may answer No based on the question text alone, not the receipt label. The Q1-C demand characteristic operates in the H3 prediction direction; the H3 analysis does not require isolating the two sources. If the pilot (n = 10/cell) shows < 30% Q1 accuracy in Condition C, a pre-registered ethics clause permits label substitution before the full launch; this decision is independent of and does not alter the H3 alpha level.

**Statistical power.** The pre-registration used G\*Power's McNemar (within-subjects) test in error; the corrected between-subjects calculation (Cohen's h = 0.30, one-tailed, α = 0.05) yields n = 67/cell for 80% power; the study targets n = 70/cell (≈82%). The omnibus 4-condition chi-squared is intentionally underpowered (≈67%); it is descriptive-secondary and does not adjudicate any of the 14 confirmatory hypotheses. For Study 2, H2.1-H2.3 are adequately powered at pre-specified effect sizes (§5.2); H2.4 (logistic regression of observed download click on Q-AC accuracy) carries no formal power estimate — power depends on the baseline download-click rate, which is unavailable pre-data; H2.3 (M4 confidence residual t-test) achieves ≈86% power at d = 0.50 with n = 60 per I level; the no-harm TOST on M3 save intention is not independently powered but uses the same n = 60 per I level with equivalence bounds ±0.5 SD.

**Scope.** The PIUP invariants and empirical tests apply to single-vote binary or multi-option receipts. Ranked-choice, quadratic, and cumulative voting receipts introduce additional absent-content complexity — the receipt must confirm that a full preference ordering was recorded without revealing it — and are not addressed here. Generalisation to non-binary preference structures is a direction for future work.

**Invariant 2 behavioural validation.** Studies 1 and 2 test comprehension (does the voter understand what the receipt withholds?); Study 3 tests whether social proof increases post-vote verification return rates. None tests whether PIUP's Invariant 2 UX enforcement — the temporal UI-lock that disables download before vote close — produces the social deniability it is designed to afford. The social deniability claim is: a voter facing coercion can truthfully say "the app won't let me share this" (a technical fact, not a personal refusal), and this excuse is more effective than a normative one under adversarial pressure. This claim is unverified. A pre-registered 2×2 between-subjects vignette experiment (N = 160; UI-lock present/absent × coercion pressure moderate/high; primary outcome: sharing intent on a 7-point scale; powered for f = 0.25, 86% power) is the appropriate confirmatory test. The interaction hypothesis — that the UI-lock's sharing-intent reduction is larger under high-pressure scenarios — follows directly from the deniability mechanism: technical facts cannot be overridden by adversarial authority; normative resistance can. A secondary confirmatory test (H4.3) measures perceived deniability directly: participants rate how convincing the response "the app won't let me" would be in the coercion scenario; UI-lock cells (D1) are predicted to rate this excuse as more socially acceptable than countdown-only cells (D0). H4.2 and H4.3 together provide two complementary, independently testable operationalisations of the social deniability mechanism: behavioural intent (DV1) and social acceptability of the technical excuse (DV2). Study 4 is pre-registered; the design specification, Qualtrics implementation guide, analysis script, and Prolific setup guide are complete. The study is ready to launch following OSF pre-registration filing.

---

## 7. Conclusion

_[Draft framing assumes H2-supported (Q2: A > B significant, composite A≈B equivalence established). If Study 1 yields H2-null or H2-reversed, revise the second paragraph per §4.5 outcome classification. The dissociation framing and §6.2 cross-reference remain correct regardless of H2 outcome; only the directional claim about fingerprint's advantage requires adjustment.]_

Private voting systems face a paradox at the confirmation layer. Correct behaviour — a receipt confirming recording without revealing content — looks like a system failure to users whose mental models were formed in eCommerce contexts, where receipts confirm content. This is not a usability problem that better copy can solve; it is a structural mismatch between the confirmation semantics of two domains.

The PIUP formalises the design response. The Status line anchors the receipt: the user sees confirmation that their ballot was recorded. Invariant 1 ensures the submission token is not derivable from the vote choice, the voter's identity, or any observable system state, and is verifiable against a public ledger. Invariant 2 requires the token be kept private until the vote closes. Invariant 3 ensures no choice-revealing field appears in the receipt. Protective framing addresses the hardest part: it explicitly names the absent content and reason for its absence before the user's default failure-inference can form. The Aztec Private Voting instantiation (§3) demonstrates all three invariants in a working ZK testnet deployment: Invariant 3 is enforced at the receipt artifact layer — VoteReceipt.tsx renders the full four-component PIUP receipt structure and the downloaded JSON file omits vote_choice (the calldata-level linkage is the L1 gap documented in §6.5).

The empirical argument runs on two threads. First, label and protective framing must be simultaneously correct. Protective framing cannot fully override the wrong mental model on privacy-specific items when the token label's representational schema imports the eCommerce-evidence association (§6.2). If H2 is supported, "vote fingerprint" holds the privacy-mental-model advantage over "confirmation code" on the coercion-relevance item (§4.5) while the overall accuracy composite remains equivalent — a dissociation the user cannot self-detect. If H4 is also supported, "confirmation code" simultaneously reduces onboarding friction and degrades the privacy mental model; the deficit is not apparent to the user. The label and framing must be correct simultaneously; neither is sufficient alone. Study 2 (§5) tests whether explanation alone is the load-bearing element — whether a familiar label can be rehabilitated through protective framing without substitution. The second thread is generalisation: Studies 3 and 4 test the social-proof and coercion-deniability mechanisms that the receipt design embeds (§6.4–6.5), with participant populations and study contexts closer to real governance settings.

Second, the design problem generalises. Sealed-bid auctions, whistleblower drops, and anonymous peer review all require receipts that confirm recording without revealing content under adversarial conditions. The PIUP invariants apply to each domain; the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event, but the structural requirements — token independence, token privacy until that event, and minimal-content receipt — hold without change. The pattern names a design category — the *coercion-surface receipt* (§6.4) — and provides an empirical method for evaluating candidate labels against privacy-mental-model accuracy, rather than general comprehension accuracy alone.

The practical prescription follows from both threads. When designing a receipt for any context where the absent content is exactly what users most want confirmed, use the PIUP structure: confirm the recording; issue an opaque token with a label that does not import the content-evidence schema; name the absent thing before the user reads the gap as an error. The latent risk is not the user who understands that privacy requires absence — it is the user who has never seen a receipt that did not tell them what they chose.

---

## References

- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." _Electronic Voting Technology Workshop / Workshop on Trustworthy Elections (EVT/WOTE '09)._ USENIX Association.
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., Fisher, G., Kortum, P., McBurnett, N., Montoya, J., Parker, M., Pereira, O., Stark, P., Wallach, D., and Winn, M. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _Electronic Voting Technology Workshop / Workshop on Trustworthy Elections (EVT/WOTE '13)._ USENIX Association.
- Benaloh, J., and Tuinstra, D. (1994). "Receipt-Free Secret-Ballot Elections." _Proceedings of the 26th Annual ACM Symposium on Theory of Computing (STOC '94)_, pp. 544-553. ACM. DOI: 10.1145/195058.195407.
- Egelman, S., and Schechter, S. (2013). "The Importance of Being Earnest [In Security Warnings]." _Financial Cryptography and Data Security (FC 2013)_, LNCS vol. 7859, pp. 52-59. Springer. DOI: 10.1007/978-3-642-39884-1_5.
- Carback, R., Chaum, D., Clark, J., Conway, J., Essex, A., Herrnson, P.S., Mayberry, T., Popoveniuc, S., Rivest, R.L., Shen, E., Sherman, A.T., and Vora, P.L. (2010). "Scantegrity II Municipal Election at Takoma Park: The First E2E Binding Governmental Election with Ballot Privacy." _19th USENIX Security Symposium (USENIX Security 2010)_, pp. 291-306. USENIX Association.
- Faul, F., Erdfelder, E., Buchner, A., and Lang, A.-G. (2009). "Statistical power analyses using G\*Power 3.1: Tests for correlation and regression analyses." _Behavior Research Methods_, 41(4), 1149-1160. DOI: 10.3758/brm.41.4.1149
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _Symposium on Usable Privacy and Security (SOUPS '12)_, Article 3. ACM. DOI: 10.1145/2335356.2335360
- Felt, A.P., Reeder, R.W., Ainslie, A., Harris, H., Walker, M., Thompson, C., Acer, M.E., Morant, E., and Consolvo, S. (2016). "Rethinking Connection Security Indicators." _Twelfth Symposium on Usable Privacy and Security (SOUPS 2016)_, pp. 1-14. USENIX Association.
- Leon, P., Ur, B., Shay, R., Wang, Y., Balebako, R., and Cranor, L. (2012). "Why Johnny Can't Opt Out: A Usability Evaluation of Tools to Limit Online Behavioral Advertising." _Proceedings of the SIGCHI Conference on Human Factors in Computing Systems (CHI '12)_, pp. 589-598. ACM. DOI: 10.1145/2207676.2207759
- Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic elections." In _Proceedings of the 4th ACM Workshop on Privacy in the Electronic Society (WPES '05)_, pp. 61-70. ACM. DOI: 10.1145/1102199.1102213.
- Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." _VoteID 2015_, LNCS vol. 9269, pp. 57-73. Springer.
- Marky, K., Kulyk, O., Renaud, K., and Volkamer, M. (2018). "What Did I Really Vote For? On the Usability of Verifiable E-Voting Schemes." _Proceedings of the 2018 CHI Conference on Human Factors in Computing Systems (CHI '18)_, pp. 1-13. ACM. DOI: 10.1145/3173574.3173750
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." _Social Psychological and Personality Science 8(4):355-362._ DOI: 10.1177/1948550617697177
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." _Human Factors 46(1):50-80._ DOI: 10.1518/hfes.46.1.50.30392
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." _Information Systems Research 13(3):334-359._ DOI: 10.1287/isre.13.3.334.81
- Norman, D.A. (1988). _The Design of Everyday Things._ Basic Books.
- Whitten, A., and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." _8th USENIX Security Symposium (USENIX Security '99)_, pp. 169-184. USENIX Association.

---

## Author Bio (for submission header)

**Jony Bursztyn** is a software engineer and independent researcher at the intersection of cryptography and human-computer interaction. He is the author of Aztec Private Voting ([github.com/jonybur-oc/aztec-private-voting](https://github.com/jonybur-oc/aztec-private-voting)), a Noir ZK voting contract and React component library, and of the Proof-of-Inclusion UX Pattern (PIUP) documented in this paper. His research focuses on how ZK systems can be designed so that their privacy guarantees are comprehensible to non-expert users.

---

## Submission notes (delete before submission)

**Target venue:** CHI 2027. Track: Technical/Empirical. Papers area: Privacy, Security, and Trust.

**CHI 2027 confirmed deadlines** (verified tick-4271, 2026-06-30 from chi2027.acm.org/authors/papers/):
- **Full paper deadline: Thursday, September 10, 2026** (no abstract pre-deadline; just submit the full paper)
- Reviews released: November 5, 2026
- Revise-and-resubmit phase: November 5-December 3, 2026
- Resubmission deadline: December 3, 2026
- Final notification: December 17, 2026
- TAPS upload: January 14, 2027
- Conference: May 10-14, 2027 (Pittsburgh, PA)

**CHI 2027 word limit** (confirmed tick-4271):
- 5,000-8,000 words ENCOURAGED
- Submissions under 5,000 words = short papers
- Submissions above 12,000 words will be DESK-REJECTED if excessive length not justified

**📏 WORD COUNT - UPDATED tick-4468 (2026-07-02):** Body text (annotations + submission notes stripped, refs included): **~11,683 words** (tick-4467: –140w from §7 conclusion para 3 compression; tick-4418 base ~11,823). 17 references. UNDER the 12,000 desk-rejection threshold. §4.6 contains ~145 [SLOT] markers; when filled, word count rises +245–405 → final: ~11,928–12,088 words. **Light trim (~88w) only needed if §4.6 fills at upper bound; do not pre-cut.** Trim target (if needed): §4.6 narrative or §6.4 examples, NOT §6.1/§6.3/§7. DO NOT cut §6.1 (core design argument), §6.2 (trimmed), §6.3 (feedback inversion), §7 (conclusion), §4.5 (~440 words - done).

**Alternatively:** USENIX SOUPS 2027 (security + usability, more directly on-topic for the empirical studies). CHI is higher prestige and better for HCI PhD applications.

**Required before submission:**
1. Study 1 data (N=280; depends on OSF upload + Prolific launch-CRITICAL PATH: OSF amendments O+T must be filed by Jony to unblock pilot launch; deadline is September 10, only 72 days away as of June 30, 2026)
2. Sections 4.2-4.6 filled with actual results
3. Section 5 updated with Study 2 pre-registration DOI (conditional on H4 in Study 1)
4. Section 6 written from Study 1 data; then CUT to <10,000 words total
5. ✅ Kulyk et al. citation FIXED (tick-3765): year 2017→2015; venue USENIX VoteID→VoteID 2015 LNCS Springer. ✅ JONY-ACTION F RESOLVED (tick-3766): Marky et al. (2018) CHI added as correct citation for verifiable e-voting usability (95-participant Benaloh Challenge study). §1.4 paragraph updated: Marky et al. now cited for task-completion/workload focus (distinct from PIUP's privacy-mental-model focus); Kulyk et al. (2015) description confirmed accurate.
6. ✅ §6.5 receipt-freeness citation FIXED (tick-4341): §6.5 previously cited "Full receipt-freeness (Juels et al., 2005)" but Juels, Catalano, and Jakobsson (2005) is "Coercion-resistant electronic elections" - a stronger and distinct property. Receipt-freeness is defined by Benaloh and Tuinstra (1994). Fixed to: passive/active distinction (passive = artifact layer, active = Benaloh-Tuinstra 1994), with Juels et al. (2005) correctly retained for coercion resistance. Benaloh and Tuinstra (1994) added to bibliography (STOC '94, DOI 10.1145/195058.195407).
7. ✅ CHI 2027 word limit and formatting confirmed (tick-4271): 5,000-8,000 encouraged; 12,000 max. Body currently **~11,683 words (under limit)** [updated tick-4468 — prior 11,823 tick-4418; 11,787 tick-4397; 11,707 tick-4369; 11,535 post-trim tick-4332; 17 refs]. After §4.6 slot fill-in: ~11,928–12,088 — light trim (~88w) only needed if §4.6 fills at upper bound; lower-end fill clears under 12,000. Do not pre-cut: trim only after §4.6 is filled.

**Submission-ready target date:** September 10, 2026 (CHI 2027 deadline) with Study 1 results if pilot + full study can complete by ~August 2026. If Study 1 data is not available by September 10, the R&R phase (reviews November 5, resubmission December 3) may allow filling in results. Jony must decide: (a) race for September 10 with data, (b) submit without data as a 'paper in preparation' + use R&R, or (c) target SOUPS 2027 for a less constrained timeline.

**Writing sample use (before submission):** This draft (abstract + introduction) can be shared with potential PhD advisors from October 2026 onwards as a "paper in preparation." For Annie Antón (GT) and Sauvik Das (CMU), sharing the abstract + intro + the study arc blog post gives them both the technical framing and the accessible version. Do not share the incomplete sections (3-7 placeholders).
