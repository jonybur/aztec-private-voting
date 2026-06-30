# Protective Absence: Designing Coercion-Resistant Receipts for Private Cryptographic Voting

_Draft for CHI 2027 submission · Jony Bursztyn · 2026-06-22_
_Status: Abstract + Introduction complete. Sections 3-7 are structural placeholders; fill after Study 1 data._
_Word count target: 9,000-10,000 (CHI full paper). Current draft: ~4,500 words structured._

---

## Abstract

Submission confirmations carry an implicit claim: the system received what you sent. In private cryptographic voting, this creates a coercion surface - a receipt showing the submitted choice can be demanded as compliance proof.

We present the **Proof-of-Inclusion UX Pattern (PIUP)**, a design class for systems that must confirm participation without revealing content. PIUP centers on *protective absence*: deliberate omission of the submitted choice, paired with a signal marking omission as intentional. This inverts Norman's feedback principle - correct feedback proves the action is *protected from display*.

We instantiate PIUP in Aztec Private Voting and report two empirical studies: Study 1 (N=280, pre-registered, 4-condition between-subjects) on identifier label effects on privacy mental models; Study 2 (N=240, planned, 2×2×2 factorial) on explanation and calibration. PIUP formalises three invariants (surrogate independence, surrogate privacy in transit, minimal receipt content) and one named limitation: in the current Aztec Private Voting implementation, vote choice appears in public calldata - addressable at the application layer (§1.1), not through UI design. [Fixed tick-4136: 'M2 contract' → 'current Aztec Private Voting implementation'; '(M3)' → '(§1.1)'. Abstract swapped to 152-word version tick-4277 (originally marked [FORMATTING-TRIM - tick-3796]); long 261-word draft archived in git history. CHI reader would not know what M3 means without reading §1.1; the §1.1 cross-reference is cleaner for standalone reading.]

---

## 1. Introduction

When Mango Markets put the loss-socialisation decision from a $116M protocol exploit to a governance vote in October 2022, every voter's wallet address was public on-chain. This is not an edge case - it is the default condition for blockchain governance: all participation is pseudonymous at best, traceable by design, and indexable by anyone running a node. In high-stakes organisational votes, pseudonymity under observation is coercive. Voters who can be identified can be pressured.

Zero-knowledge proof systems offer a partial technical resolution. Aztec's ZK rollup allows a voter to prove eligibility and submit a ballot without revealing the ballot's contents in public calldata. At the private state layer, ZK achieves what it is designed for: the system records a nullifier and the aggregate tally — no persistent state links the voter to their choice. A named limitation remains at the calldata layer: the vote choice appears as a plaintext argument in the contract's public accounting step, visible at submission time (§1.1). State-level storage of the choice is eliminated; calldata exposure at the moment of submission is not.

From the user interface's perspective, a problem persists.

After a private vote, users receive a confirmation. Standard confirmation UI - across every digital domain they have encountered - mirrors the submitted content. Your eCommerce order confirmation shows the items. Your appointment confirmation shows the time and date. Your form submission shows the submitted values. The confirmation is evidence of what was submitted. This is, per Norman's description of feedback in _The Design of Everyday Things_ (1988), the correct behavior: the system tells you what happened.

In private voting, the correct behavior is the opposite. A receipt that shows the submitted choice creates a coercion surface exactly equivalent to transparent voting: the voter can be asked to produce it. A receipt that shows only a cryptographic identifier - the nullifier hash, or some UI-friendly variant of it - confirms participation without confirming direction. The absent choice is the privacy guarantee.

The design problem is that absence, by default, reads as failure.

Usability-security research documents multiple failure modes when users encounter unexpected security interface states: inferring system failure from absent confirmation [Whitten and Tygar 1999], ignoring present permission warnings [Felt et al. 2012], and dismissing warnings as inapplicable [Egelman and Schechter 2013]. In the receipt context, the operative failure mode is the first. A receipt that shows no vote choice, without explanation, will be read as: "the system didn't record my vote," "the vote failed," or "this is a bug." The technical guarantee becomes an experiential failure.

The contribution of this paper is a design pattern that resolves this tension: the **Proof-of-Inclusion UX Pattern (PIUP)**.

### 1.1 The PIUP pattern

PIUP is a design class for submission systems where three conditions hold simultaneously: (1) the system can confirm that a submission was received and processed; (2) the system must *not* confirm the content of the submission (by design); and (3) users expect confirmation to include content (by transfer from prior confirmation experiences).

Under these conditions, standard confirmation design fails: it either violates condition (2) (by showing content) or violates condition (1) (by showing an opaque identifier that reads as error).

PIUP's resolution is *protective absence*: the receipt omits the content but explicitly signals that the omission is a design guarantee, not a failure. Four components appear in order: a status line confirming the submission ("Your ballot was counted"), the submission token (a cryptographic identifier), a protective framing naming the absent content ("Your vote choice is not shown. This is intentional - it protects your privacy"), and a verification affordance for later inclusion checks (§2.1). The omitted choice is named before the user notices it is missing, establishing purpose before the failure-inference forms.

Three formal invariants characterize the pattern (full specification: §2.1): **Invariant 1 (Surrogate independence)** - the token must not be derivable from submission content, user identity, or observable state, and must be verifiable against a public ledger without revealing content. **Invariant 2 (Surrogate privacy in transit)** - the token must be kept private until the content is definitionally public (vote closes, auction reveals); after that event the link in the execution record is no longer actionable for coercion. **Invariant 3 (Minimal receipt content)** - the receipt must contain only the token and verification endpoint; no choice-revealing field is permitted.

**Named limitation.** The current Aztec Private Voting implementation exposes `vote_choice` in `record_vote` public calldata; PIUP narrows the UX coercion surface but does not protect against calldata observation. M3 resolves this at the application layer without protocol changes (§3.3, §6.5).

### 1.2 Naming the absent thing

The identifier on the PIUP receipt — what PIUP calls the *submission token* — occupies the conceptual role ZK voting literature assigns to a *nullifier*: a value proving participation without revealing content.

"Your nullifier: `a3f9...`" is technically correct and, for non-expert users, actively misleading: walkthroughs produced consistent failure readings - "nullifier" sounds like a cancellation or a legal invalidation. The term is opaque to experts and misleading to non-experts - a combination that, per Whitten and Tygar, reliably produces usability failures in security-critical contexts.

Four candidate labels were tested through design iteration: **"vote fingerprint"** (uniqueness-without-disclosure), **"confirmation code"** (standard eCommerce convention), **"nullifier"** (technically precise), and **"receipt ID"** (generic baseline).

The key contrast is fingerprint vs. confirmation code. "Confirmation code" in eCommerce contexts activates a representational schema - *confirmation = record of what was submitted* - correct in every prior context the user has encountered, wrong in PIUP. H2 predicts that the two labels will perform similarly on overall accuracy but diverge on privacy-model questions (Q2: whether the token proves vote choice; Q3: whether a third party could learn how the voter voted). Confirmation code is predicted to produce higher incorrect-answer rates on Q2 and Q3 because the activated schema directly contradicts the correct answer (pre-registered test specifications: §4.5; schema-import mechanism: §6.2). If confirmation code outperforms fingerprint on the privacy questions, the production default should change.

### 1.3 Contributions

This paper makes four contributions: (1) **PIUP** - a formally-characterized design class with three invariants and one named limitation for coercion-resistant confirmation in privacy-preserving submission systems (§2.1, §6.5); (2) **Aztec Private Voting** - a Noir ZK smart contract and React component library implementing PIUP on the Aztec v5 testnet (§3); (3) **Study 1** - a pre-registered 4-condition between-subjects experiment (N=280) on identifier label effects on privacy mental models (§4); and (4) **Study 2** — a pre-analysis plan for a 2×2×2 factorial (L × E × I; 8 cells, N=240) testing explanation and calibration effects (§5).

### 1.4 Scope and relation to prior work

PIUP applies beyond voting: sealed-bid auctions, whistleblower submissions, and anonymous peer review face the same constraint - confirmation must not confirm content.

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

**Protective framing.** An explicit signal that the absent content is a design guarantee, not a system failure. Two requirements: (a) name the absent content *before* the user notices it is missing - before the failure-inference forms; (b) attribute the absence to a system property, not a limitation: *"Your vote choice is not shown. This is intentional - the receipt proves you voted without revealing your choice."* Omitting this component triggers the default absent-content inference (error, incomplete transaction) [Whitten and Tygar 1999].

**Verification affordance.** A persistent but non-intrusive mechanism for the user to confirm inclusion at a later time: *"When the vote closes, you can paste your vote fingerprint at [verification URL] to confirm it was counted."* Collapsed by default, it functions as a second-pass tool that does not compete for initial attention at the confirmation step. [Compressed tick-4282] [Compressed tick-4311]

### 2.2 Design alternatives considered and rejected

Three alternative designs were explored during system development and rejected on coercion-resistance grounds.

**Alternative 1: Show the vote choice, require authentication to view the receipt.** The receipt would contain the full submission, but be protected behind a credential (e.g., wallet signature). Rejected on Invariant 3 grounds: this design encodes the vote choice in the receipt (gated by authentication but present in the receipt document), directly violating the minimal-content constraint - no choice-revealing field may appear in the receipt. The gating does not eliminate the coercion surface; it shifts the coercion target from receipt content to receipt access. A coercer who cannot obtain the receipt can instead coerce the voter into signing an authentication message. The attack surface shifts; it does not shrink.

**Alternative 2: Use a random UUID as the submission token, without protocol binding.** A random 128-bit UUID would satisfy the independence sub-condition of Invariant 1 - it is not derivable from content, identity, or observable state - and could be stored locally. Rejected on Invariant 1 grounds: Invariant 1 requires not only independence but verifiability against a public ledger (`isInLedger(token) → bool`). A token that is not verifiable against a public commitment proves nothing to the voter or to a third party. The voter has a random number; they have no way to distinguish a genuine token from one generated by a compromised frontend. PIUP requires that the token be verifiable against the submission event, not merely random.

**Alternative 3: Omit the protective framing, rely on user inference from absence.** Prior work on absent-content interpretation [Whitten and Tygar 1999] finds that users interpret absent expected content as failure unless absence is explicitly marked as intentional. In the receipt context, a voter who sees no vote choice and no explanation will conclude their vote was not recorded or that the transaction failed - a worse outcome than a coercible receipt, which at least confirms participation while revealing choice. The protective framing is a load-bearing component, not decorative copy.

---

## 3. System: Aztec Private Voting

Aztec Private Voting is a Noir ZK smart contract and React component library implementing the PIUP on the Aztec v5 testnet. It provides the canonical instantiation of the pattern described in Section 2 and is the system on which Studies 1 and 2 are run.

### 3.1 The Noir contract

The contract is structured as a single `PrivateVoting` Noir program with four principal entrypoints:

**`cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** - private entrypoint; generates a ZK proof enforcing double-vote prevention via a `SingleUseClaim` nullifier in the private kernel, then enqueues `record_vote`.

**`record_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field)`** - public entrypoint (`#[only_self]`). Increments the tally for `vote_choice`, validates `receipt_id` uniqueness, marks `receipts[receipt_id] = true`. The `receipt_id` is the content-independent vote fingerprint: `Fr.random()` in the standard path; a deterministic field element derived from the holder's snapshot leaf or signing-key signature in the Babylon eligibility paths (§3.5).

**`finalize_vote()`** - callable after `end_time` if `vote_count >= quorum`; sets `is_finalized = true`, gating `get_final_tally` visibility. Callers poll `is_finalized()` or `verify_vote_counted()` for state.

**`verify_vote_counted(receipt_id: Field) → bool`** - public view; returns `receipts[receipt_id]`. Any receipt holder can confirm their ballot was counted without revealing vote content.

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

Three findings were resolved before the study - one HIGH severity and two LOW:

*F1-RESIDUAL (HIGH - gated vote bypass).* On TOKEN/ALLOWLIST contracts, the generic `cast_vote` entrypoint could be called with `eligibility_proof = 1`, bypassing the Merkle gate. Resolved by asserting `eligibility_mode == OPEN` in `cast_vote`; gated entrypoints perform the in-circuit Merkle proof before enqueuing `record_vote`.

*F2 (Quorum bypass).* `quorum = 0` allows vacuous finalization; resolved by `assert(config.quorum > 0)` in the constructor.

*F3 (Receipt-ID collision).* `receipt_id = 0` would block subsequent voters; resolved by `assert(receipt_id != 0)` in all entrypoints and React hooks.

Two design limitations are documented and not resolved at the prototype stage:

*L1 privacy gap.* `vote_choice` and `receipt_id` are plaintext public arguments in `record_vote`; an observer can build a `receipt_id → vote_choice` map. The receipt UI warns against sharing until vote close. The M3 architecture resolves this at the application layer (M3 spec §5.3); this limitation applies to the current pre-M3 deployment.

*Receipt-freeness is partial.* No re-encryption mix is implemented; "coercion-resistant" is withheld from user-facing copy until resolved.

### 3.4 React component library and `VoteReceipt.tsx`

The system ships a React component library (`packages/react/`) providing the voter-facing UI including the PIUP instantiation. The key component is `VoteReceipt.tsx`, which renders the four PIUP components described in Section 2.1, listed in their actual rendering order:

- The status line: *"Your vote was cast"*
- The vote fingerprint (abbreviated hex: `shortenHex(receipt.receiptId, 6, 4)`; full value accessible via copy button)
- The protective framing: *"Your vote choice is not shown on this receipt. This is intentional - this fingerprint proves your ballot was counted without revealing what you voted for. Save it to verify after the vote closes, and keep it private until then."*
- The verification affordance: a collapsed *"How to verify"* section with a three-step explainer and a link to the `verify_vote_counted` endpoint

The component's download action writes a JSON receipt file via `serializeReceipt()`; the file contains the fingerprint, vote metadata, and transaction hash but not the vote choice (Invariant 3). Per §3.3, calldata observers can recover the choice via `txHash`; voters should treat receipts as private until vote close. The fingerprint (`Fr.random()`, 254-bit field element) is independent of wallet, vote ID, and choice - satisfying Invariant 1.

### 3.5 M2 ownership proof (defense-in-depth)

M2 adds in-circuit secp256k1 signature verification (EIP-191 personal_sign), closing the pre-computation attack surface (ADR-036). The proof compiles to 339 ACIR + 348 Brillig opcodes; 7/7 Noir tests pass. `VoteReceipt.tsx` handles all eligibility modes identically.

---

## 4. Study 1: Label Choice and Privacy Mental Model

### 4.1 Research questions and hypotheses

**RQ1.** Which identifier label ("vote fingerprint," "confirmation code," "nullifier," "receipt ID") produces the most accurate comprehension of what the PIUP receipt proves?

**RQ2.** Does the fingerprint/confirmation-code distinction produce a dissociation on privacy-specific items vs. overall accuracy?

**RQ3.** Does the familiar eCommerce label ("confirmation code") produce higher confidence ratings despite comparable or lower accuracy - a calibration failure - compared to the less familiar "vote fingerprint"?

**H1 (pre-registered confirmatory; m = 2):** A > D on Q2 and Q3 (fingerprint > neutral baseline on the privacy-model questions; pre-registered directional magnitude: ≥ 10 pp on each).
**H2 (pre-registered confirmatory; m = 3; primary endpoint):** A > B on Q2 (primary endpoint) and Q3 (secondary); A ≈ B on overall accuracy composite (TOST, ±10 pp). Q2(A>B) is the single pre-specified primary endpoint for the study; pre-registered directional magnitudes: ≥ 10 pp on Q2 (primary), ≥ 8 pp on Q3 (secondary) (pre-reg §H2).
**H3 (pre-registered confirmatory; m = 6):** C < all others on Q1 ("does this prove your vote was counted?") and on overall accuracy composite - reversal risk from "nullified" reading; 6 pre-registered tests (Q1(C<A), Q1(C<B), Q1(C<D), composite C<each); pre-registered directional magnitudes: Cond C < 45% on Q1, Cond A ≥ 65% on Q1.
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

**Participants.** Recruitment was through Prolific. Inclusion criteria: US-resident adults (18+), English-fluent (platform filter), self-reporting at least one online election, poll, or survey in the past 12 months, no prior participation (Prolific deduplication). Exclusion criteria: self-reported software engineering professionals (software developer, engineer, or programmer by primary occupation) or CS/SE students - both screened via Prolific screener (SC2) before study entry, preventing domain-expert contamination of the comprehension measures [JONY-ACTION O: File OSF Amendment 5 — CS/SE student screener extension (before CHI submission)] (the SC2 screener's extension of the professional exclusion to CS/SE students was made before pilot launch and is documented in the OSF amendment log as Amendment 5); participants failing both attention checks (single-check failure is not disqualifying - participants who fail only one check are retained; pre-reg §3) [JONY-ACTION T: File OSF Amendment 14 — correct attention check descriptions in pre-reg §3 (AC1: select "Strongly Disagree"; AC2: select third item = Carrot) before CHI submission]; and participants completing the study in fewer than 90 seconds (indicating non-serious completion; pre-reg §3).

Target sample: n = 70 per condition (N = 280 total), preceded by an instrument-validation pilot of n = 10 per condition (N = 40). No institutional IRB review was required under 45 CFR §46.104(d)(2); Prolific's standard participant protections and informed consent process apply.

**Power.** For the H2 primary confirmatory endpoint (Q2 accuracy, A vs. B, one-tailed, p1 = 0.65 vs. p2 = 0.50, expected difference 15 pp), α = 0.05, power = 0.80 requires n = 67 per cell (G\*Power 3.1.9.7, Faul et al., 2009; test: "Proportion: Inequality of two independent proportions", Cohen's h = 0.30). The target sample is n = 70 per cell (N = 280), providing approximately 82% power for the H2 primary endpoint. *Pre-registration note: original pre-reg computed n = 49 using McNemar (within-subjects); corrected pre-data to n = 67/cell (independent proportions, G\*Power). [Amendment 1: osf-amendment-filing-2026-06-24.md; all 14 hypotheses unchanged.]* For the omnibus chi-squared (df = 3, w ≈ 0.18), 80% power requires n ≈ 82/cell; at n = 70, omnibus power ≈ 0.67 (H2 pairwise is the primary test; omnibus is descriptive-secondary). If pilot Q2 effect < 15 pp, n expands to 75/cell before full launch. No interim stopping rules; pilot (N = 40) is for instrument validation only.

### 4.3 Stimuli

Each participant was shown a single static screenshot of the post-vote receipt screen under their assigned condition. The four stimuli (condition-a-fingerprint.html, condition-b-confirmation-code.html, condition-c-nullifier.html, condition-d-receipt-id.html) are identical in structure, layout, and copy except for the receipt identifier label, its ARIA label, two label-name references within the collapsed verification panel ("check that your [label] appears"; "Paste your [label]"), and a small study-administration badge rendered in the lower-right corner of each stimulus ("Cond. A" through "Cond. D"). The badge encodes no label information - the letter-to-condition mapping was not disclosed to participants, and no participant-facing instruction referenced it. All other visible receipt copy was held constant. Held constant: status line ("Your vote was cast"), protective framing ("This receipt does not contain your vote choice. It proves your ballot was counted without revealing how you voted."), identifier value, copy button, download prompt. Note that the stimuli use a simplified protective framing that does not include the explicit design-intent signal ("This is intentional") present in the production VoteReceipt.tsx (§3.4) and the canonical PIUP framing (§2.1); Study 1 tests the label effect under this constant simplified framing, while Study 2 isolates the explanation itself as an independent variable (§5). The screenshot method controls stimulus presentation across participants and eliminates variability introduced by an interactive voting flow; the primary ecological validity cost is the absence of choice-commitment context (see §6.5).

Stimuli were committed to the repository at commit `fb710f5` before any participant data were collected. Any post-registration change to the stimuli HTML constitutes a pre-registered amendment and is noted in the deviations log.

### 4.4 Measures

Eight items assessed comprehension accuracy, confidence, and save intention. Table 2 lists abbreviated wording; full item text, response options, scoring rubrics, and amendment history are in the OSF supplementary instrument.

**Table 2. Study 1 measures.**

| Item | Abbreviated wording | Scoring | Hypothesis | Status |
|---|---|---|---|---|
| Q1 - Inclusion | "Does having your [LABEL] prove your vote was counted?" | Binary; correct: Yes | H1, H3 | Confirmatory |
| Q2 - Choice-blindness | "Does having your [LABEL] prove which voting option you chose?" | Binary; correct: No | H1, H2 primary | Confirmatory |
| Q3 - Coercion scenario | "If you showed a third party your [LABEL], could they tell which voting option you chose?" | Binary; correct: No | H1, H2 secondary | Confirmatory |
| Q4 - Receipt loss | "If you closed without saving your [LABEL], what would happen?" | Binary; correct: vote survives; [LABEL] is personal proof | - | Confirmatory |
| Composite accuracy | Proportion correct on Q1-Q4 | 0-1.0 | H2 (TOST) | Confirmatory |
| Q5 - Open-ended | "Why might this voting system choose NOT to show you which option you voted for?" | 0-2, two raters, κ ≥ 0.70; rubric: OSF §11 | Pre-reg secondary | Pre-registered |
| MQ1 - Mental model | "What does your [LABEL] prove about your vote?" | 0-2 additive (Inclusion + Non-leakage), two raters, κ ≥ 0.70 | - | Exploratory |
| Confidence | Post-Q1-Q4: "How confident are you in your answer?" (1-7) | Mean Q1-Q4 composite | H4 | Confirmatory |
| BI1 - Save intent | "How likely would you be to save this code?" | 5-point (1 = Definitely would not, 5 = Definitely would) | Study 2 RQ4 preview | Exploratory |
| Label affect | "What is your first impression of the term '[LABEL]'?" | Valence -3 to +3 | - | Exploratory |

Q1-Q4: three-option forced choice; binary score = correct answer selected. Q5 and MQ1: two independent raters, κ ≥ 0.70 required (adjudicate below threshold). Confidence composite = mean rating across Q1-Q4. Composite accuracy (proportion correct Q1-Q4) is the primary RQ1 measure and H2 TOST endpoint; Q5 and MQ1 are scored separately.

Covariates (collected; not pre-specified as primary analyses): age (DM1, categorical), prior voting experience (DM3), and technology background (DM2: "Have you ever written code professionally or as part of a degree?"). Two Prolific attention checks are applied as exclusion criteria.

### 4.5 Analysis plan

The study pre-registers 14 confirmatory tests across four Holm families. Holm-Bonferroni sequential correction is applied within each family independently; no cross-family correction is applied.

| Family | Pre-registered tests | m |
|--------|----------------------|---|
| H1 (fingerprint > receipt ID on privacy items) | Q2(A>D), Q3(A>D) | 2 |
| H2 (dissociation: fingerprint vs. confirmation code) | Q2(A>B) one-tailed, Q3(A>B) one-tailed, TOST composite A≈B ±10 pp | 3 |
| H3 (nullifier underperforms) | Q1(C<A), Q1(C<B), Q1(C<D), composite(C<A), composite(C<B), composite(C<D) [composite pairings conditional on omnibus significance; pre-reg §6.6] | 6 |
| H4 (confirmation code overconfidence) | confidence(B>A), confidence(B>C), confidence(B>D) | 3 |

**H1** (m = 2). Two one-tailed chi-squared tests on Q2 and Q3 accuracy, A vs. D. Both must survive Holm correction within the family. Pre-registered directional magnitude: ≥ 10 pp on each question (see §4.1; pre-reg §H1).

**H2** (m = 3; primary endpoint). H2-primary: Q2 accuracy, A vs. B, one-tailed chi-squared (α = 0.05); this is the single pre-specified primary endpoint. H2-secondary: Q3 accuracy, A vs. B, one-tailed. H2-tertiary: TOST (Lakens, 2017) on composite accuracy (Q1-Q4), A vs. B; equivalence bounds ±10 pp on the proportion difference (α = 0.05 per one-sided test; pre-reg §6.5). If equivalence not established: Cohen's h and 90% CI of (p_A - p_B) reported (pre-reg §6.5). Directional magnitudes: ≥ 10 pp Q2, ≥ 8 pp Q3 (pre-reg §H2). H2 outcome: **supported** if Q2(A > B) significant AND composite equivalent; **null** if Q2 non-significant AND equivalent; **reversed** if Q2 non-significant AND post-hoc Q2(B > A) significant (two-tailed, α = 0.05) AND equivalent (or B > A composite). All three pre-registered H2 patterns are actionable production decisions, not success/failure dichotomies (see §6.2).

**H3** (m = 6). Three unconditional one-tailed chi-squared tests on Q1 accuracy (C vs. A, B, D; pre-reg §6.6) plus a 4-condition composite-accuracy omnibus ; if omnibus significant, Holm-corrected composite pairings for C proceed. Support criterion: C lower than at least 2 of {A, B, D} on Q1 after Holm correction. Directional magnitudes: C < 45%, A ≥ 65% on Q1 (pre-reg §H3). An ethics clause pre-specifies that if the pilot shows < 30% Q1 accuracy in Condition C, a fifth label may substitute for C before the full launch; label substitution does not alter the m = 6 Holm family or the H3 alpha level (§6.5).

**H4** (m = 3). One-way ANOVA on confidence composite; if significant, Tukey HSD for B vs. A, C, D. **Calibration analysis (secondary/descriptive; not Holm-corrected):** Spearman r between Q1-Q4 accuracy (0-4) and confidence composite, per condition; H4 predicts Condition B shows lower calibration (weaker accuracy-confidence r) than A. H4 outcome: **supported** if ANOVA significant AND all three Tukey comparisons (B > A, C, D) survive Holm correction; **null** if ANOVA non-significant; **partial** if ≤ 2 comparisons survive; **direction reversal** if B < at least one condition. H4-supported triggers calibration note in PIUP documentation and co-primary I-factor analysis in Study 2 (pre-reg §13).

**Q5 (pre-registered secondary; pre-reg §6.8).** Kruskal-Wallis across 4 conditions; if significant, Dunn's post-hoc (Holm); κ ≥ 0.70 required (raters adjudicate below threshold). 25-response random sample per condition included in write-up. Q5/M6 cross-study comparisons are approximate (§5.4).

**Mental model quality (exploratory).** Mean score and distribution (0/1/2) by condition; κ ≥ 0.70 required. Not part of the composite accuracy score; all comparisons exploratory.

**Behavioral intent (descriptive).** Mean BI1 score and distribution (5 = Definitely would save → 1 = Definitely would not) per condition; all comparisons descriptive. Study 1 BI1 provides a preview; save behaviour is a primary confirmatory endpoint in Study 2 (RQ4; §5.1).

**Label affect (exploratory).** Mean valence (-3 to +3) and distribution by condition; all comparisons exploratory.

**Confidence interval standard.** All proportions: Wilson 95% CI. All means: 95% CI from t-distribution. All odds ratios: log-scale 95% CI.

### 4.6 Results

_[To be written after Study 1 data collection. Pre-registration OSF DOI: [INSERT]. Pilot target: 2026-Q3; full launch conditional on instrument validation. Reporting structure: (1) Participant flow table - 4 conditions (A: fingerprint, B: confirmation code, C: nullifier, D: receipt ID), final N=280 (n=70/cell), demographics DM1 (age), DM2 (technology background), DM3 (prior voting experience), pre-specified exclusion protocol applied (software engineers, both attention checks failed, response time < 90 s); (2) omnibus chi-squared result; (3) per-hypothesis family in H1-H4 order; (4) Q5 open-text analysis - when drafting this item: if any cross-study comparison to Study 2 M6 scores is included, apply the approximate-comparison qualifier established at §4.5 and §5.4 (tick-4078/4079): direct Q5/M6 score-level comparisons are approximate because the Part 2 criterion at score-2 differs by design (Q5 Part 2 = mechanism reason; M6 Part 2 = intentional-design OR harmful-consequence); (5) exploratory comparisons.]_

---

## 5. Study 2: Explanation Effects and Calibration Interventions

Study 1 isolates the label effect while holding explanatory copy constant. Study 2 isolates the explanation as the independent variable, crossing it with the theoretically central label contrast and a calibration intervention.

### 5.1 Research questions

**RQ1 (Explanation effect).** Does an explicit absent-choice explanation in the receipt increase correct absent-content interpretation, trust, and self-reported save intention, compared to a receipt with no explanation? (See §6.1, §6.3.)

**RQ2 (Label × Explanation interaction).** Is the explanation effect moderated by label - specifically, does "confirmation code" produce lower absent-content accuracy without explanation (schema import unchecked), closing the gap to "vote fingerprint" when explanation is added? (See §6.1, §6.2.)

**RQ3 (Calibration intervention).** Does an accuracy-feedback intervention before the receipt increase correct absent-content interpretation and reduce confidence miscalibration without reducing save intention? (See §6.2, §6.3.)

**RQ4 (Save behavior).** Does correct absent-content interpretation predict save intention? Is this relationship moderated by calibration? (See §6.1.)

### 5.2 Design

2×2×2 between-subjects factorial experiment.

**Factor L (Label; 2 levels):** L1 = "vote fingerprint"; L2 = "confirmation code." "Nullifier" and "Receipt ID" are excluded - Study 1 characterised both (§4.1-4.3).

**Factor E (Explanation; 2 levels):** E1 = explanation present: "Your vote choice is not shown on this receipt. This is intentional. Keeping your vote private means your receipt can be shared, checked, or subpoenaed without revealing how you voted. Your [label] is the only thing you need - matching it later proves your ballot was counted, nothing more." E2 = explanation absent: the receipt shows the identifier, "Your vote was cast," the download prompt, and verification instructions. A minimal privacy note ("Your vote is private and verifiable") is retained in E2 to avoid a privacy-awareness confound; only the absent-choice explanation is omitted (design note §6.1).

**Factor I (Calibration intervention; 2 levels):** I1 = no intervention; participant sees the receipt directly. I2 = calibration intervention: two comprehension questions with correct-answer feedback presented before the receipt. I is crossed with L × E, producing 8 cells; N = 30 per cell (N = 240 total).

**Power (preliminary estimates).** H2.1 (Q-AC accuracy, E main effect; 50% → 70%, OR ≈ 2.3, one-tailed, α = 0.05): ≈84% power at n = 30/cell (design note §10.1). H2.2 (M2 trust, L × E interaction; f ≈ 0.22): ≈80% power (design note §10.2). H2.3 (t-test on M4 residual, one-tailed, L2 cells only; d = 0.50; n = 60/I level, pooling E1+E2 within L2): ≈86% power (design note §10.3) [Fixed tick-4292: 'TOST on M4 residual' - the ≈86% power is for the directional t-test on M4 (d=0.50, n=60/group, one-tailed), not TOST; consistent with §5.5 H2.3 fix this tick]; Study 2b (L2 only, N = 80) pre-planned if inconclusive. Final estimates revised after Study 1 pilot data.

### 5.3 Platform

Study 2 uses the actual `VoteReceipt.tsx` component from the Aztec Private Voting React package, hosted on Vercel in study mode. Static screenshots (Study 1) are insufficient because the download affordance must be clickable and the I2 intervention requires pre-receipt interaction. Hosting the production component increases ecological validity for trust and behavioral-intention measures. Study mode logs: download-button click (no file written), verification-section expansion, and intervention response accuracy.

### 5.4 Measures

**Primary confirmatory endpoint.** Absent-content interpretation (Q-AC): "Looking at that receipt: does it show which voting option you chose?" (Correct: No, my vote choice is not shown; foils: Yes, my vote choice is shown / It's not clear.) Administered after a transition screen that hides the receipt; "that receipt" is a retrospective reference recalled from memory.

**Additional primary measures (design note §7.1).** Save intention (M3): 7-point Likert (1 = Definitely will not, 7 = Definitely will), supplemented by observed download-button click. Trust composite (M2): 4-item adapted McKnight (2002) scale - integrity items TI1 ("I believe this receipt accurately reflects what happened with my vote") and TI2 ("I trust that the [label] is unique to my ballot"); competence items TC1 ("I feel confident I could use this receipt to prove my ballot was counted") and TC2 ("I understand what this receipt is for"); composite = mean of four items; α ≥ 0.70 required.

**Secondary measure - all conditions (survey instrument §11).** Confidence-accuracy residual (M4): single-item confidence rating - "How confident are you in your answer above?" (7-point; 1 = not at all confident, 7 = completely confident; placed immediately after Q-AC, before the trust scale; N = 240) - yielding M4_residual = (M4_raw - 1)/6 - Q-AC binary accuracy. Positive residual = overconfidence; negative = underconfidence. M4 is collected from all N = 240 participants (not I2 only); this is required for the H2.3 conditional t-test (I1-L2 vs. I2-L2) to be feasible. [Fixed tick-4292: prior heading said 'I2 only' (Amendment 7, tick-4246 changed M4 scope from I2-only retrospective CAL-probe confidence to all-conditions post-receipt Q-AC confidence, but §5.4 of the CHI paper was not updated); prior question wording 'your answers were correct at the time' stale - survey instrument §11 canonical wording is 'in your answer above'. Cross-check: piup-study2-survey-instrument-2026-06-28.md §11; piup-study2-preregistration-draft-2026-06-29.md §5.4.]

**Supplementary measure.** Open-ended absent-choice explanation (M6 / Q-OE): "In your own words, why doesn't this receipt show which voting option you chose?" Scored 0-2 by two independent raters (κ ≥ 0.70 required before any M6 analysis; rubric in design note §7.2); if κ ≥ 0.70: Kruskal-Wallis across 8 conditions (Dunn's post-hoc, Holm); if κ < 0.70: M6 analysis not reported (pre-reg §6.7). Random 15 responses per condition as illustrative examples. M6 is not confirmatory. The Part 2 score-2 criterion differs from Study 1 Q5 by design (M6 accepts intentional-design or harmful-consequence framing; Q5 requires a mechanism reason), so direct cross-study score comparisons are approximate. [Compressed tick-4281] [Fixed tick-4307 (Amendment 23 - CHI §5 cross-check vs pre-reg Amendments 19-22): pre-reg §6.7 specifies κ ≥ 0.70 required before including Q-OE in *any* analysis; analysis script's kappa_ok gate (Amendment 20/tick-4304) enforces this for KW + Dunn's. CHI §5.4 previously said 'κ ≥ 0.70' but read as if Kruskal-Wallis ran unconditionally. Added explicit gate + skip clause to match pre-reg §6.7 and script behaviour.]

### 5.5 Primary analysis

The primary analysis axis is contingent on Study 1 outcomes (full decision table in design note §3).

**H2.1 (RQ1; primary).** One-tailed chi-squared on Q-AC accuracy (E1 pooled vs. E2 pooled × correct/incorrect, pooling across L and I; α = 0.05; direction: E1 > E2); quantity: OR with 95% Wilson CI. Participants receiving a static screenshot due to browser rendering failure (browser_fallback = 1; ~3% expected) are retained in the primary analytic sample; H2.1 and H2.4 are each re-run excluding them as pre-specified sensitivity checks (design note §9.3).

**H2.2 (RQ2; secondary).** Two-way between-subjects ANOVA (L × E) on M2 trust composite, pooling across I; if the interaction F is significant (α = 0.05), simple effects of E within L1 and L2 separately (Welch's t). If not significant: 90% CI on the interaction contrast. Pre-specified on M2; an ordinal Q-AC pattern ("confirmation code" underperforms without explanation, gap closes with explanation) is predicted but not confirmatory.

**H2.3 (RQ3; pre-specified conditional secondary).** If Study 1 H4 is supported (§4.5): two-sample t-test on M4 confidence-accuracy residual in L2 cells (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05; n = 60 per I level, pooling E1+E2 within L2; quantity: Cohen's d + 95% CI. With a no-harm test on M3 save intention: TOST equivalence (equivalence bounds ±0.5 SD; Lakens, 2017; α = 0.05 per one-sided test; `TOSTER::tsum_TOST`, var.equal = FALSE); if equivalence not established (p_max ≥ 0.05): report M3 Cohen's d + 90% CI (pre-reg §6.4). [Fixed tick-4307 (Amendment 23 - CHI §5 cross-check vs pre-reg Amendments 19-22): pre-reg §6.4 specifies M3 null-path reporting (Cohen's d + 90% CI when TOST equivalence not established); Amendment 19 (tick-4303) added the null-path code block to the analysis script. CHI §5.5 did not describe this fallback path at all - only described the TOST, not what to report when it fails. Added to match pre-reg §6.4. Cross-check: piup-study2-preregistration-draft-2026-06-29.md §6.4; piup-study2-analysis.R H2.3 M3 null-path block.] [Fixed tick-4292: prior text said 'TOST on M4 confidence-accuracy residual (equivalence bounds ±0.5 SD; Lakens, 2017)' - incorrect on two counts. (1) M4 test is a one-tailed t-test (I1 > I2), not TOST; TOST tests equivalence, but H2.3 tests a directional reduction in miscalibration (I2 should reduce M4 residual vs I1). (2) The equivalence bounds ±0.5 SD and Lakens 2017 citation belong with M3 save intention (TOST/no-harm test), not M4. Cross-check: piup-study2-preregistration-draft-2026-06-29.md §3 H2.3 and §6.4: 'M4 residual: Two-sample t-test (I1-L2 vs. I2-L2), one-tailed (I1 > I2), α = 0.05. Report Cohen's d + 95% CI. M3 save intention: TOST equivalence test (I1-L2 vs. I2-L2), bounds ±0.5 SD, α = 0.05 per one-sided test.' Analysis script confirms: H2.3 M4 uses t.test(..., alternative='greater'); M3 uses TOSTER::tsum_TOST.]

**H2.4 (RQ4).** Logistic regression of observed download click on Q-AC accuracy, with L, E, I as covariates (main effects, no interactions); quantity: OR for Q-AC accuracy. Pre-specified sensitivity: re-run excluding browser-fallback participants (design note §9.3).

H2.1-H2.4 are independent pre-specified predictions; no cross-hypothesis correction applied. A single pre-specified test is performed per hypothesis; no within-family multiplicity adjustment is required (design note §9.2). Exploratory comparisons across all L × E × I cells are descriptive only. [Compressed tick-4281]

### 5.6 Status

Study 2 pre-registration DRAFT is complete (`docs/piup-study2-preregistration-draft-2026-06-29.md`, 14 design amendments incorporated as of 2026-06-30). The DRAFT is OSF-ready pending two gates: (a) Study 1 pilot data (N = 40) to calibrate baseline Q-AC accuracy estimates for H2.1 power (pre-reg §4 sampling plan), and (b) Study 1 H4 outcome from the full launch (N = 280) to resolve the H2.3 conditional secondary dependency and set final N (240 if H4 supported; 160 if not). Until OSF upload, Study 2 contribution (C4) is described as a "pre-analysis plan" (§1). If Study 2 is uploaded to OSF before CHI submission, update C4 heading to "Pre-registered study design (Study 2, N=240)" with OSF DOI, and update §5.6, §6.2, and §7 accordingly. Full design specification: `docs/piup-study2-design-note-2026-06-22.md`. [Updated tick-4293: status advanced from design-note stage to pre-registration DRAFT complete (14 amendments, 2026-06-30); OSF gates unchanged.]

---

## 6. Discussion

_[§6.1-6.5 written from design framing (no Study 1 data required). §6.6 results discussion pending Study 1 data collection. When writing §6.6: (a) §7 conclusion checked tick-4079 - no cross-study Q5/M6 score comparison language present, no qualifier needed there. (b) If §6.6 makes any cross-study Q5 (Study 1) / M6 (Study 2) open-text comparison, apply the approximate-comparison qualifier established at §4.5 and §5.4 (tick-4078): the 0-2 scale structure is shared, but the Part 2 criterion at score-2 differs by design (Q5 Part 2 = mechanism reason; M6 Part 2 = intentional-design OR harmful-consequence), so direct score-level comparisons across studies are approximate. The qualifier language from §4.5 is: 'direct cross-study Q5/M6 score-level comparisons are approximate (see §5.4).']_

### 6.1 When does protective absence work?

The PIUP's central design hypothesis is that a receipt which omits the vote choice can produce correct user behavior - saving the identifier, returning to verify - without triggering the failure-reading (the vote was not recorded). For this to hold, two conditions must be met simultaneously: the receipt must carry an explicit design-intent signal that distinguishes protective omission from system failure, and the submission token must carry a label-metaphor consistent with the correct privacy mental model.

Neither condition alone is sufficient.

An absent-choice receipt without design-intent framing falls into the failure mode documented by Whitten and Tygar (1999) for cryptographic systems: when systems produce outputs users cannot interpret, users conclude something has gone wrong, not that the system is protecting them. Even security-aware users dismiss unexpected security feedback when it does not align with their threat model - acting from bounded rationality, they conscientiously bypass it (Egelman and Schechter, 2013). [P RESOLVED - Option (a) applied tick-4216: E&S mechanism corrected from 'error-attribution' (which is W&T's mechanism) to 'threat-model dismissal / bounded rationality' (E&S 2013 actual finding: 'misunderstandings about the threat model led participants to believe that the warnings did not apply to them; acting out of bounded rationality, participants made conscientious decisions to ignore the warnings'). Closes JONY-ACTION P (tick-4113).] The Protective framing component - "Your vote choice is not shown. This is intentional - it protects your privacy" - resolves this by naming the absent content before the user notices it is missing, establishing design purpose before the failure-inference can form.

However, protective framing addresses only one axis of the mental-model problem. The label on the submission token carries an independent schema effect on the privacy-model questions specifically. A user whose mental model is "the confirmation code links back to my vote choice, as in eCommerce" has the *behavioral* model approximately correct (save the identifier; use it later to verify) while having the *privacy* model wrong (the code reveals my choice to anyone who has it). The framing may not fully override the representational schema that "confirmation code" activates - a question Study 2's L × E test addresses directly (§5.5). "Vote fingerprint" carries uniqueness-without-content semantics (a fingerprint identifies without describing), with no implication that the identifier encodes what was voted.

The design implication is that Invariants 1-3 are necessary but not sufficient for correct privacy-mental-model formation. The Protective framing component handles the failure-inference problem; the token label handles the schema-import problem. In the PIUP receipt, both must be correct simultaneously: absent-content framing without a privacy-appropriate label leaves the privacy-model questions vulnerable; a privacy-appropriate label without absent-content framing leaves the failure-inference unaddressed. The pattern requires both components; neither is sufficient alone (design inference; Study 1 holds protective framing constant and includes no without-framing baseline - §2.2, §6.5). [Fixed tick-3986 - JONY-ACTION X RESOLVED: added parenthetical co-locating the §2.2 Alt3 design-inference disclosure and §6.5 limitations at the 'neither is sufficient alone' site, so a CHI reviewer reading §6.1 in isolation sees the documented scope boundary without needing to locate §2.2 separately. The parenthetical mirrors the §2.2 language ('Study 1 includes no without-framing baseline') and cites both §2.2 (canonical design-inference disclosure) and §6.5 (ecological validity scope limitation). The §5.5 forward pointer for the label-framing L×E interaction remains in the prior sentence and is not displaced by this fix.] [Compressed tick-4277: ~707 → ~350 clean words. W&T/E&S paragraph, framing paragraph, and schema-import paragraph consolidated; core claim, design implication, and all [Fixed]/[P RESOLVED] annotations preserved.]

### 6.2 The confirmation code paradox

A consistent finding in the trust literature is that familiarity produces confidence: users who encounter recognisable interface patterns extend more trust than to unfamiliar conventions (McKnight et al., 2002). [Fixed tick-3995 - JONY-ACTION N RESOLVED option (a): dropped Lee and See (2004) from line 395 co-citation. McKnight et al. (2002) is the more direct citation for the 'familiarity produces confidence' claim in UI contexts (eCommerce trust, trusting beliefs, trusting intentions). Lee and See (2004) is an automation trust framework (aircraft autopilots, robots, medical systems); the link to UI familiarity effects is a theoretical extension, not Lee & See's primary contribution. Retaining Lee and See at line 399 only - where it is a clean, direct characterisation of the miscalibration/over-reliance framework ('over-reliance occurs when users apply a mental model that does not accurately reflect the system's actual behavior') - gives each citation a precise, unambiguous use. If Jony prefers option (b) instead (add bridging qualifier at line 395, e.g., 'familiarity and experience effects Lee and See document in automation contexts'), revert this fix and add the qualifier.] For most design decisions this is a resource - if a familiar convention correctly describes the system's behaviour, using it reduces friction without cost.

In privacy-critical contexts, familiar conventions carry a hidden cost. In eCommerce, "confirmation code" activates a complete trust complex (McKnight et al., 2002): the trusting belief that the code is retrievable evidence of a specific transaction, and the trusting intention to save it, present it if challenged, and match it to an order record. The schema is correct in eCommerce and wrong in private voting, where the correct schema is: confirmation = proof of counting, without encoding what was confirmed.

A user applying the eCommerce schema to a private voting receipt will be confident in their understanding while holding a wrong mental model on the privacy-specific questions - the over-reliance Lee and See (2004) describe in trust in automation: a mental model that does not accurately reflect the system's actual behaviour. The mismatch is invisible until a coercion scenario forces the receipt's privacy properties to matter.

The schema-import mechanism generates two pre-registered predictions. **H2 (dissociation; §4.5)** predicts that "confirmation code" and "vote fingerprint" perform comparably on the overall accuracy composite - both produce the correct behavioural schema (save it; use it to verify later) - while diverging specifically on Q2 and Q3, where the eCommerce-evidence schema directly contradicts the correct answer. Three H2 outcome patterns are pre-registered with production decisions (§4.5); all three are actionable, not success/failure dichotomies. [Fixed tick-4159 - §6.2 H2-reversed precision aligned with §4.5 canonical definition: added 'H2-primary non-significant' precondition and '(or B > A on composite)' fallback pathway. No protocol or analysis impact; §4.5 canonical definition unchanged.] **H4 (confidence miscalibration; §4.5)** operationalises a second consequence: "confirmation code" is predicted to produce higher self-reported confidence (B > A, B > C, B > D) despite the Q2/Q3 accuracy deficit, because the eCommerce schema is well-practised. If H4 is supported, the label simultaneously does the designer's work of reducing onboarding friction and the coercer's work of degrading the privacy mental model - without the deficit being apparent to the user.

This is the *familiarity tax*: familiar labels in privacy-critical contexts reduce onboarding friction but create a privacy-mental-model deficit that compounds under coercion or audit. The deficit is invisible to users (they feel confident) and to designers (the interface performs well on standard usability metrics) - precisely when it matters most. Familiar-convention adoption therefore requires an evaluation step beyond standard usability: not only "does this reduce cognitive load?" but "does this import a schema that contradicts the privacy model?" Study 2's L × E interaction test (§5) provides a pre-specified test of whether absent-choice explanation can close the accuracy gap; the formal endpoint (H2.2) is the trust composite (M2; §5.5). [Note (tick-3849, updated tick-3864; corrected tick-4020): This sentence completes the §6.2 forward-reference established by §5's RQ2 cross-reference '(See §6.1, §6.2)'. §6.1 (line 387) already carries the Study 2 L×E explicit reference ('a question Study 2's L × E test addresses directly (§5.5)'); §6.2 now carries a matching forward-reference. Tick-3849 original forward-reference framed the L×E test as a 'Q-AC accuracy gap' question, but H2.2 is formally pre-specified on M2 trust composite (design note §9.1), not Q-AC; the Q-AC framing was visible in the main text (after note-stripping it would survive into the CHI submission without the M2 qualifier). Tick-3864 fix: revised main text to (a) drop 'operationalises this uncertainty directly' (slightly overclaimed - L×E is secondary endpoint), (b) add the formal H2.2/M2 pre-specified endpoint as a sentence in the main text alongside the Q-AC ordinal framing, so the M2/Q-AC distinction survives note-stripping for submission. Tick-4020 correction: 'pre-registered' → 'pre-specified' throughout §5.5 and this §6.2 sentence - Study 2 is at design-note stage (§5.6), not OSF-pre-registered; consistent with JONY-ACTION U (§1.3 heading) and JONY-ACTION M (§7 wording) resolutions. If Study 2 is pre-registered before CHI submission, update back to 'pre-registered' + OSF DOI.] The question for designers of analogous systems - sealed-bid auction receipts, whistleblower submission receipts, anonymous peer review receipts - is whether any label activates the same eCommerce-evidence schema, and whether explanatory copy can override it on the specific items where the schemas diverge. [Compressed tick-4278]

### 6.3 The protective absence feedback inversion

Norman's (1988, p. 27) feedback principle holds that the system must send back to the user information about what action was done and what result was accomplished - a design resource in most contexts, where the relevant system state is something that *happened*. [Fixed tick-3994 - JONY-ACTION H RESOLVED: page number added. Norman (1988, p. 27) defines feedback as 'sending back to the user information about what action has actually been done, what result has been accomplished.' The paper's paraphrase is essentially verbatim (omitting 'actually' and 'has been' → 'was', no substantive change). Page number confirmed from DOET 1988 first edition p. 27 via secondary source verification (tick-3994). The prior Nielsen Heuristic #1 quote ('always keep the user informed about what is going on') has been removed and replaced with the correct Norman paraphrase + page number. No Nielsen (1994) citation required: the feedback-principle argument rests on Norman's definition, not the heuristic framing.] PIUP inverts this. The relevant state is something that was *protected from happening*: the vote choice was not recorded in the receipt. Absence is not self-explaining: a receipt that simply omits the vote choice gives the user nothing to interpret, producing the conceptual-model divergence Norman's own model predicts.

This is the *protective absence feedback problem*: how do you provide feedback for the correct absence of information? Two prior designs face the same structural inversion. The HTTPS lock icon communicates channel protection - an absence-of-eavesdropping signal - without conveying anything about content. Prior usability research documents how poorly users understand what the lock means (Felt et al., 2016): "secure channel" is routinely misread as "trustworthy site," importing protection from the wrong layer. Behavioural advertising opt-out mechanisms face the same inversion: the signal communicates system restraint rather than user action. Many participants confused opting out of behavioural targeting with blocking ads entirely (Leon et al., 2012). [JONY-ACTION S (tick-3887, RESOLVED tick-3899): 'most participants' was the draft claim. Checked: the Leon et al. 2012 CHI abstract uses 'many participants' ('led many participants to conclude that a tool was blocking OBA when they had not properly configured it'); the paper's Table 1 entry for Evidon's opt-out tool records 'All participants who used Evidon's opt-out tool similarly mis-' (all 7/7 for that tool). The aggregate figure across all 7 tools (N=45 total) is not stated as 'most' in the paper's own summary language - 'many' is the paper's framing. Softened to 'many participants' at this line as the conservative edit. RESOLVED: text now matches the paper's own register.] In both cases the protection is at one layer and users form their mental models from another.

What distinguishes PIUP is the severity of the counterintuitive demand. The absent content - the vote choice the user most wants to confirm - is exactly what is being protected. The most-wanted information is the most-protected, and the receipt's job is to signal the protection without supplying the content.

The Protective framing component is the design response. Where the HTTPS lock provides a small ambiguous icon, PIUP provides prose that names the absent thing, names the protection reason, and names the beneficiary in a single step - positioned in the primary receipt flow, after the submission token, before the user has finished reading the receipt. The protective absence feedback problem is addressed by treating the absence as a first-class receipt element, not as a secondary explanation for a gap the user might or might not notice. [Compressed tick-4278]

### 6.4 Generalisation beyond voting

The underlying design problem is domain-independent. The PIUP invariants apply to any system in which (1) a receipt must confirm that an action was recorded, (2) the action's content must be protected from disclosure in the receipt, and (3) the user must be left with a correct mental model of both the confirmation and the protection.

**Sealed-bid auctions.** In a sealed-bid auction, the bid receipt must confirm that a bid was submitted without revealing the bid amount. The PIUP invariants apply: Invariant 1 requires the submission token be independent of bid amount, bidder identity, and observable state, and be verifiable against a public ledger; Invariant 2 requires the token remain private until the auction reveal event, at which point the token-to-bid link is no longer actionable for coercion; Invariant 3 requires no bid-amount field in the receipt, with protective framing explaining the amount is withheld to preserve auction integrity. The label question recurs: "bid receipt," "submission token," and "bid confirmation" carry different schema loads.

**Whistleblower drops.** In secure document submission systems, the receipt must confirm that a document was received without confirming its contents. The PIUP invariants apply: Invariant 1 requires the token be independent of document content, submitter identity, and observable state, and be verifiable against a public ledger; Invariant 2 requires the token remain private until the content is definitionally public; Invariant 3 requires no content metadata appear in the receipt, with protective framing explaining that details are withheld to protect source anonymity. A domain-specific wrinkle: in employer-facing contexts, the adversary may already know the content and aim to confirm who submitted; protective framing must be precise about what the token does and does not reveal.

**Anonymous peer review.** In double-blind peer review, the submission receipt must confirm a review was recorded without confirming the reviewer's identity. Many conference systems provide a "your review has been submitted" confirmation with no submission token, leaving the reviewer with no durable proof of submission. A PIUP implementation issues an opaque token: Invariant 1 requires it be independent of review content, reviewer identity, and observable system state, and be verifiable against a public ledger; Invariant 2's transit-privacy timing window closes at the review decision; Invariant 3 requires no score, text excerpt, or rating appear in the receipt, with protective framing explaining that review content is withheld to preserve double-blind integrity.

**Common structure.** Across all three cases, the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event (auction reveal, content publication, or review decision), but the structural requirements - token independence, token privacy until that event, and minimal-content receipt - hold without change. The variation across domains is in token label semantics, protective framing text, and the threat model that motivates the protection. PIUP names a design category - the *coercion-surface receipt* - rather than a single context-specific pattern: any confirmation receipt that could be used under adversarial conditions to infer what the user chose, submitted, or authored falls within this category. [Compressed tick-4279: §6.4 ~936 → ~496 clean words; tick-4312: 554 → 497 clean words (cuts: opening context sentence -12w; Sealed-bid label sentence -13w; Whistleblower wrinkle -30w; Peer review verifiability gap clause -8w); annotation history (Fixed ticks 3862/3856/3866/3874/3852/4180) preserved in git]

### 6.5 Limitations

**Protocol exposure and receipt-freeness.** The current Aztec Private Voting implementation exposes `vote_choice` and `receipt_id` as plaintext arguments in `record_vote` public calldata. An observer monitoring on-chain calldata can construct a `receipt_id → vote_choice` map without access to the receipt itself. PIUP addresses the coercion surface at the UX layer - the receipt withholds the choice (Invariant 3), protective framing names the absence - but does not protect against calldata observation. Full receipt-freeness (Juels et al., 2005) additionally requires severing the identifier-to-choice link at the protocol layer; the current contract does not implement a re-encryption mix. Users whose threat model includes calldata surveillance are not protected by PIUP alone. The calldata exposure is resolved at the application layer in M3, which removes `vote_choice` from `record_vote`'s public arguments; the PIUP receipt invariants hold regardless of whether M3 is deployed. "Coercion-resistant" is withheld from user-facing copy pending this protocol fix (§3.3). This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference, not protocol threat-model awareness.

**Ecological validity.** Study 1 uses screenshot stimuli, removing the choice-commitment context present in real voting flows. Confidence ratings and save intention may be underestimated when participants assess a static receipt for a choice they did not actively make. Study 2 improves ecological validity substantially - participants cast a simulated vote before receiving the receipt - but three bounds remain: the vote is consequentially inert; the Prolific sample (US-based English-speaking online workers) may not represent DAO governance participant populations; and both studies measure receipt comprehension immediately after voting, not at the delayed-verification event that the downloaded receipt is intended to support. These bounds primarily constrain effect-size generalisation; internal validity of the factorial contrasts is not affected.

**Demand characteristics and label substitution.** In Condition C (nullifier label), Q1 reads: "Does having this *nullifier* prove that your vote was counted?" The word "nullifier" in the question stem may independently depress Q1-C accuracy - participants associating "nullifier" with "null, cancelled" may answer No based on the question text alone, not the receipt label. The Q1-C demand characteristic operates in the H3 prediction direction; the H3 analysis does not require isolating the two sources. If the pilot (n = 10/cell) shows < 30% Q1 accuracy in Condition C, a pre-registered ethics clause permits label substitution before the full launch; this decision is independent of and does not alter the H3 alpha level.

**Statistical power.** The pre-registration used G\*Power's McNemar (within-subjects) test in error; the corrected between-subjects calculation (Cohen's h = 0.30, one-tailed, α = 0.05) yields n = 67/cell for 80% power; the study targets n = 70/cell (≈82%). The omnibus 4-condition chi-squared is intentionally underpowered (≈67%); it is descriptive-secondary and does not adjudicate any of the 14 confirmatory hypotheses. For Study 2, all four confirmatory hypotheses (H2.1-H2.4) are adequately powered at pre-specified effect sizes (§5.2); H2.3 (TOST on save intention) achieves ≈86% power at d = 0.50 with n = 60 per I level. [Compressed tick-4277: 9-heading long §6.5 → 5-heading condensed version; annotation history preserved in git and OSF pre-reg docs; all 5 key disclosures (protocol exposure, ecological validity, demand characteristics, statistical power, scope) preserved; Study 1 demand characteristic and Study 2 ecological validity paragraphs merged into single compact entries.]

**Scope.** The PIUP invariants and empirical tests apply to single-vote binary or multi-option receipts. Ranked-choice, quadratic, and cumulative voting receipts introduce additional absent-content complexity - the receipt must confirm that a full preference ordering was recorded without revealing it - and are not addressed here. Generalisation to non-binary preference structures is a direction for future work.

---

## 7. Conclusion

_[Draft framing assumes H2-supported (Q2: A > B significant, composite A≈B equivalence established). If Study 1 yields H2-null or H2-reversed, revise the second paragraph per §4.5 outcome classification. The dissociation framing and §6.2 cross-reference remain correct regardless of H2 outcome; only the directional claim about fingerprint's advantage requires adjustment.]_

Private voting systems face a paradox at the confirmation layer. Correct behaviour - a receipt confirming recording without revealing content - looks like a system failure to users whose mental models were formed in eCommerce contexts, where receipts confirm content. This is not a usability problem that better copy can solve; it is a structural mismatch between the confirmation semantics of two domains.

The PIUP formalises the design response. The Status line anchors the receipt: the user sees confirmation that their ballot was recorded. Invariant 1 ensures the submission token is not derivable from the vote choice, the voter's identity, or any observable system state, and is verifiable against a public ledger. Invariant 2 requires the token be kept private until the vote closes. Invariant 3 ensures no choice-revealing field appears in the receipt. Protective framing addresses the hardest part: it explicitly names the absent content and reason for its absence before the user's default failure-inference can form. The Aztec Private Voting instantiation (§3) demonstrates all three invariants in a live ZK deployment: receipt_id/vote_choice separation is enforced at the contract layer, and VoteReceipt.tsx renders the full four-component PIUP receipt structure. [Compressed tick-4283]

The empirical case rests on two boundary conditions, both derived from Study 1. First, Protective framing is necessary but not sufficient. Without a token label whose representational schema does not import the eCommerce-evidence association (§6.2), framing cannot fully override the wrong mental model on privacy-specific items. If H2 is supported, "vote fingerprint" holds the privacy-model advantage on Q2 - whether the identifier proves which option was voted for (§4.5) - while the overall accuracy composite remains equivalent. If H4 is also supported, "confirmation code" simultaneously reduces onboarding friction and degrades the privacy mental model; the deficit is not apparent to the user. The label and framing must be correct simultaneously; neither is sufficient alone. [Compressed tick-4283; cut: Study 2 forward-ref sentence, tick-4313]

Second, the design problem generalised. Sealed-bid auctions, whistleblower drops, and anonymous peer review all require receipts that confirm recording without revealing content under adversarial conditions. The PIUP invariants apply to each domain; the timing constraint of Invariant 2 adapts to the domain's equivalent reveal event, but the structural requirements - token independence, token privacy until that event, and minimal-content receipt - hold without change. The pattern names a design category - the *coercion-surface receipt* (§6.4) - and provides an empirical method for evaluating candidate labels against privacy-mental-model accuracy, rather than general comprehension accuracy alone. [Compressed tick-4283; cut: 'variation across domains' elaboration, tick-4313]

The practical prescription follows from the boundary conditions. When designing a receipt for any context where the absent content is exactly what users most want confirmed, use the PIUP structure: confirm the recording; issue an opaque token with a label that does not import the content-evidence schema; name the absent thing before the user reads the gap as an error. The latent risk is not the user who understands that privacy requires absence - it is the user who has never seen a receipt that did not tell them what they chose.

---

## References

- Adida, B., de Marneffe, O., Pereira, O., and Quisquater, J.-J. (2009). "Electing a University President Using Open-Audit Voting: Analysis of Real-World Use of Helios." _EVT/WOTE 2009._ [JONY-ACTION DD RESOLVED - 4-author Adida-first list confirmed by Caltech Election Updates recap (2009-08-12) and Springer citation; USENIX BibTeX (3-author) is a database error.]
- Bell, S., Benaloh, J., Byrne, M., DeBeauvoir, D., Eakin, B., Fisher, G., Kortum, P., McBurnett, N., Montoya, J., Parker, M., Pereira, O., Stark, P., Wallach, D., and Winn, M. (2013). "STAR-Vote: A Secure, Transparent, Auditable, and Reliable Voting System." _EVT/WOTE 2013._ [VERIFIED tick-4155: USENIX archived page (Wayback Machine, 2024-12-05 snapshot) confirms 14 authors: Susan Bell, Josh Benaloh, Michael D. Byrne, Dana DeBeauvoir, Bryce Eakin, Gail Fisher, Philip Kortum, Neal McBurnett, Julian Montoya, Michelle Parker, Olivier Pereira (UCLouvain), Philip B. Stark, Dan S. Wallach, Michael Winn. Prior bibliography had 'Perez, O.' - INCORRECT; corrected to 'Pereira, O.' (Olivier Pereira, Université Catholique de Louvain). JONY-ACTION CC.]
- Egelman, S., and Schechter, S. (2013). "The Importance of Being Earnest [In Security Warnings]." _Financial Cryptography and Data Security (FC 2013)_, LNCS vol. 7859, pp. 52-59. Springer. DOI: 10.1007/978-3-642-39884-1_5. [VERIFIED tick-4207: DBLP (conf/fc/EgelmanS13) + CrossRef (DOI 10.1007/978-3-642-39884-1_5) confirm 2 authors (Serge Egelman, Stuart Schechter; Egelman first), title exact match, year 2013, venue Financial Cryptography and Data Security, LNCS 7859, pp. 52-59. All fields CLEAN ✅. Prior entry listed only 'FC 2013' without LNCS volume or pages - inconsistent with other LNCS Springer entries (Kulyk et al. 2015: LNCS 9269 pp. 57-73). Fixed to full LNCS format for consistency. No in-text citation change required: in-text uses 'Egelman and Schechter (2013)' throughout - author order Egelman-first confirmed correct.]
- Carback, R., Chaum, D., Clark, J., Conway, J., Essex, A., Herrnson, P.S., Mayberry, T., Popoveniuc, S., Rivest, R.L., Shen, E., Sherman, A.T., and Vora, P.L. (2010). "Scantegrity II Municipal Election at Takoma Park: The First E2E Binding Governmental Election with Ballot Privacy." _USENIX Security 2010._ [Added tick-3876: replaces Everett et al. (2008) per JONY-K resolution - this is the correct citation for 'confirmation codes in a real election evaluating verification affordance use.' The 2009 Takoma Park election used invisible-ink confirmation codes; 1,722 voters; voter use of the online verification affordance documented in the deployment report. Note tick-4147: 'a statistically significant number verified online' removed - 1,722 voters IS the full electorate (not a sample), so frequentist significance framing was structurally inappropriate; deployment reports document raw rates, not sampling inference.] [Note (tick-4218 - JONY-ACTION BB RESOLVED - option (a) applied): AUTHOR LIST CORRECTED ✅. Carback-first 12-author list applied. In-text 'Chaum et al.' → 'Carback et al.' (§1.4). Bibliography corrected: Conway, J.; Herrnson, P.S.; Mayberry, T. added; Ryan, P.Y.A. removed; Carback listed first. Source: DBLP conf/uss/CarbackCCCEHMPRSSV10 (verified tick-4154).
- [REMOVED tick-3876 per JONY-K resolution: Everett, S.P., Greene, K.K., Byrne, M.D., Wallach, D.S., Derr, K., Sandler, D., and Torous, T. (2008). "Electronic Voting Machines versus Traditional Methods: Improved Preference, Similar Performance" (not "Improving Voter Attitudes and Satisfaction" as previously listed - title was also wrong). _CHI 2008_, pp. 883-892. This paper is a DRE-vs.-paper-ballot usability comparison; it does NOT study verification codes and cannot support the §1.4 'usability evaluation of verification codes in real elections' claim.]
- Faul, F., Erdfelder, E., Buchner, A., and Lang, A.-G. (2009). "Statistical power analyses using G\*Power 3.1: Tests for correlation and regression analyses." _Behavior Research Methods_, 41(4), 1149-1160. DOI: 10.3758/brm.41.4.1149 [Fixed tick-4039: spurious author 'Abt, A.-G.' removed; correct author list is Faul, Erdfelder, Buchner, Lang (4 authors - confirmed via Springer and Semantic Scholar). 'Abt' was not an author of this paper and may have been introduced as a corrupted duplicate of 'Lang, A.-G.' (both sharing the same initials A.-G.). The reference in the paper body remains 'Faul et al., 2009' and is unaffected.] [VERIFIED tick-4210: CrossRef (DOI: 10.3758/brm.41.4.1149, retrieved 2026-06-29) confirms 4 authors in order: Franz Faul (F.), Edgar Erdfelder (E.), Axel Buchner (A.), Albert-Georg Lang (A.-G.) - all initials and order match bibliography entry ✅. Title: exact match ✅. Journal: Behavior Research Methods ✅. Volume 41, Issue 4, Pages 1149-1160 ✅. Year 2009 ✅. Tick-4039 spurious-author fix (removal of 'Abt, A.-G.') confirmed correct. 0 BUGS. CHI risk: NONE.]
- Felt, A.P., Ha, E., Egelman, S., Haney, A., Chin, E., and Wagner, D. (2012). "Android Permissions: User Attention, Comprehension, and Behavior." _SOUPS 2012._ DOI: 10.1145/2335356.2335360 [VERIFIED tick-4210: DBLP (conf/soups/FeltHEHCW12, retrieved 2026-06-29) confirms 6 authors in exact order: Adrienne Porter Felt (A.P.), Elizabeth Ha (E.), Serge Egelman (S.), Ariel Haney (A.), Erika Chin (E.), David A. Wagner (D.) - all initials and author order match bibliography entry ✅. Title: 'Android permissions: user attention, comprehension, and behavior.' (capitalisation variant from bibliography, content identical) ✅. Venue: SOUPS 2012 ✅. Prior state noted partial DBLP confirmation (4 authors); this tick confirms all 6 including Chin (Erika Chin) and Wagner (David A. Wagner). 0 BUGS. CHI risk: NONE.]
- Felt, A.P., Reeder, R.W., Ainslie, A., Harris, H., Walker, M., Thompson, C., Acer, M.E., Morant, E., and Consolvo, S. (2016). "Rethinking Connection Security Indicators." _USENIX SOUPS 2016._ [Fixed tick-3861: Prior entry listed 'Ha, E.' as third author - Erika Ha is an author of Felt et al. (2012) Android permissions paper, NOT the 2016 HTTPS indicators paper. The 2016 paper's actual author list (confirmed via USENIX SOUPS 2016 proceedings) is Felt, Reeder, Ainslie, Harris, Walker, Thompson, Acer, Morant, and Consolvo. Ha, E. was added to the 2016 entry in error, likely by copying from the 2012 entry during bibliography construction.] [VERIFIED tick-4157: DBLP (conf/soups/FeltRAHWTAMC16) confirms all 9 authors in exact order: Adrienne Porter Felt, Robert W. Reeder, Alex Ainslie, Helen Harris, Max Walker, Christopher Thompson, Mustafa Emre Acer, Elisabeth Morant, Sunny Consolvo. Venue: SOUPS 2016. Pages: 1-14. All fields CLEAN ✅. Tick-3861 Ha→absent fix confirmed correct: Ha is not in DBLP for this paper.]
- Leon, P., Ur, B., Shay, R., Wang, Y., Balebako, R., and Cranor, L. (2012). "Why Johnny Can't Opt Out: A Usability Evaluation of Tools to Limit Online Behavioral Advertising." _CHI 2012._ [VERIFIED tick-4157: DBLP (conf/chi/LeonUSWBC12, DOI: 10.1145/2207676.2207759) + CrossRef confirm 6 authors in exact order: Pedro Giovanni Leon, Blase Ur, Richard Shay, Yang Wang, Rebecca Balebako, Lorrie Faith Cranor. Venue: CHI 2012 (Austin, TX). Pages: 589-598. All fields CLEAN ✅.]
- Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic elections." In _Proceedings of the 4th ACM Workshop on Privacy in the Electronic Society (WPES '05)_, pp. 61-70. ACM. DOI: 10.1145/1102199.1102213. [DBLP: conf/wpes/JuelsCJ05; authors, title, venue, pages, DOI all VERIFIED tick-4198 + tick-4212.]
- Kulyk, O., Teague, V., and Volkamer, M. (2015). "Extending Helios Towards Private Eligibility Verifiability." _VoteID 2015_, LNCS vol. 9269, pp. 57-73. Springer. [VERIFIED tick-3765: year corrected 2017→2015; venue corrected USENIX VoteID→VoteID 2015 LNCS Springer] [CONTENT AUDIT tick-3859: §1.4 parenthetical 'dummy ballots' corrected to 'null votes cast by other eligible voters.' Semantic Scholar abstract confirms mechanism: 'real votes are hidden in a crowd of null votes that are cast by others but are indistinguishable from those of the eligible voter.' Privacy guarantee = crowd-anonymity through null votes from other eligible participants, not voter-created dummy ballots. Previous characterisation was imprecise; now corrected.]
- Marky, K., Kulyk, O., Renaud, K., and Volkamer, M. (2018). "What Did I Really Vote For? On the Usability of Verifiable E-Voting Schemes." _Proceedings of the 2018 CHI Conference on Human Factors in Computing Systems (CHI '18)_, pp. 1-13. ACM. DOI: https://doi.org/10.1145/3173574.3173750 [VERIFIED tick-3766: 95-participant Benaloh Challenge (cast-as-intended verification) usability study; authors + DOI + pages confirmed via Strathclyde repository; resolves JONY-ACTION F]
- Lakens, D. (2017). "Equivalence Tests: A Practical Primer for t Tests, Correlations, and Meta-Analyses." _Social Psychological and Personality Science 8(4):355-362._ [VERIFIED tick-4157: CrossRef (DOI: 10.1177/1948550617697177) confirms single author Daniël Lakens (Eindhoven University of Technology); journal Social Psychological and Personality Science; vol. 8, issue 4, pp. 355-362; year 2017. All fields CLEAN ✅.]
- Lee, J.D., and See, K.A. (2004). "Trust in Automation: Designing for Appropriate Reliance." _Human Factors 46(1):50-80._ DOI: 10.1518/hfes.46.1.50.30392 [Fixed tick-3995 - JONY-ACTION N RESOLVED: one use only (line 399, §6.2 - CLEAN). Co-citation at line 395 removed - option (a) applied. Lee and See is now used precisely once, for the miscalibration/over-reliance claim it is best known for. McKnight et al. (2002) covers line 395's familiarity→confidence claim alone. If Jony prefers option (b) (bridging qualifier at line 395), revert line 395 fix and add qualifier.] [VERIFIED tick-4210: CrossRef (DOI: 10.1518/hfes.46.1.50.30392, retrieved 2026-06-29) confirms 2 authors: John D. Lee (J.D.) and Katrina A. See (K.A.) - author order and initials match bibliography entry ✅. Title: 'Trust in Automation: Designing for Appropriate Reliance' - exact match ✅. Journal: Human Factors: The Journal of the Human Factors and Ergonomics Society (shorthand 'Human Factors' in bibliography is conventional and acceptable) ✅. Volume 46, Issue 1, Pages 50-80 ✅. Year 2004 ✅. 0 BUGS. CHI risk: NONE.]
- McKnight, D.H., Choudhury, V., and Kacmar, C. (2002). "Developing and Validating Trust Measures for E-Commerce: An Integrative Typology." _Information Systems Research 13(3):334-359._ DOI: 10.1287/isre.13.3.334.81 [VERIFIED tick-4208: DBLP (journals/isr/McKnightCK02) + CrossRef (DOI: 10.1287/isre.13.3.334.81) confirm all fields. Authors: D. Harrison McKnight (first), Vivek Choudhury, Charles J. Kacmar - 3 authors, McKnight first ✅. Title: exact match (minor: sources use 'e-Commerce' vs paper's 'E-Commerce' - capitalisation variant, no attribution impact) ✅. Venue: Information Systems Research ✅. Volume 13, Issue 3, Pages 334-359, Year 2002 ✅. 0 BUGS, 0 INFOs. CHI risk: NONE.]
- Norman, D.A. (1988). _The Design of Everyday Things._ Basic Books. [VERIFIED tick-4209: Wikipedia (DOET article, retrieved 2026-06-29) + jnd.org (Norman's own site) confirm: originally published 1988 by Basic Books under the title 'The Psychology of Everyday Things' (POET); retitled 'The Design of Everyday Things' (DOET) in the later paperback reprint (~1990). Author: Donald A. Norman (D.A. Norman) ✅. Year: 1988 ✅. Publisher: Basic Books ✅. INFO: The 1988 hardcover was titled POET, not DOET; however, this is universal HCI citation convention - virtually every HCI paper cites this book as 'Norman (1988) The Design of Everyday Things' regardless of edition. CHI reviewers will not flag this. Page reference p. 27 (feedback definition) previously confirmed via secondary source verification in JONY-ACTION H (tick-3994). 0 BUGS, 1 INFO (POET→DOET convention). CHI risk: NONE.]
- Whitten, A., and Tygar, J.D. (1999). "Why Johnny Can't Encrypt: A Usability Evaluation of PGP 5.0." _USENIX Security 1999._ [VERIFIED tick-4209: DBLP (conf/uss/WhittenT99, retrieved 2026-06-29) confirms 2 authors in order: Alma Whitten (A.), J. Doug Tygar (J.D.) - bibliography 'Whitten, A., and Tygar, J.D.' ✅. Title: exact match ✅. Year: 1999 ✅. Venue: 'USENIX Security Symposium 1999' (bibliography shorthand 'USENIX Security 1999') ✅. Paper open access (USENIX). No DOI in DBLP. INFO: page numbers (pp. 169-184) absent from bibliography entry - consistent with other USENIX entries in this bibliography (Chaum et al. 2010 also lacks pages). CHI risk: LOW. 0 BUGS, 1 INFO (missing pages - low priority).]

---

## Author Bio (for submission header)

**Jony Bursztyn** is a software engineer and independent researcher at the intersection of cryptography and human-computer interaction. He is the author of Aztec Private Voting ([github.com/jonybur-oc/aztec-private-voting](https://github.com/jonybur-oc/aztec-private-voting)), a Noir ZK voting contract and React component library, and of the Proof-of-Inclusion UX Pattern (PIUP) documented in this paper. His research focuses on how ZK systems can be designed so that their privacy guarantees are comprehensible to non-expert users.

---

## Submission notes (delete before submission)

**Target venue:** CHI 2027. Track: Technical/Empirical. Papers area: Privacy, Security, and Trust.

**CHI 2027 confirmed deadlines** (verified tick-4271, 2026-06-30 from chi2027.acm.org/authors/papers/):
- **Full paper deadline: Thursday, September 10, 2026** (no abstract pre-deadline; just submit the full paper)
- Reviews released: November 5, 2026
- Revise-and-resubmit phase: November 5 - December 3, 2026
- Resubmission deadline: December 3, 2026
- Final notification: December 17, 2026
- TAPS upload: January 14, 2027
- Conference: May 10-14, 2027 (Pittsburgh, PA)

**CHI 2027 word limit** (confirmed tick-4271):
- 5,000-8,000 words ENCOURAGED
- Submissions under 5,000 words = short papers
- Submissions above 12,000 words will be DESK-REJECTED if excessive length not justified

**⚠️ WORD COUNT ALERT (tick-4271):** Body text (annotations stripped) currently ~15,000 words - 3,000 over the 12,000 desk-rejection threshold. Significant editing required before submission. §6 Discussion alone is ~5,005 clean words (too long). Target: get body to 8,000-10,000 before submission (the R&R process allows further cuts after reviews; aim for 10,000 at first submission with a justified-length note if needed).

**Alternatively:** USENIX SOUPS 2027 (security + usability, more directly on-topic for the empirical studies). CHI is higher prestige and better for HCI PhD applications.

**Required before submission:**
1. Study 1 data (N=280; depends on OSF upload + Prolific launch - CRITICAL PATH: OSF amendments O+T must be filed by Jony to unblock pilot launch; deadline is September 10, only 72 days away as of June 30, 2026)
2. Sections 4.2-4.6 filled with actual results
3. Section 5 updated with Study 2 pre-registration DOI (conditional on H4 in Study 1)
4. Section 6 written from Study 1 data; then CUT to <10,000 words total
5. ✅ Kulyk et al. citation FIXED (tick-3765): year 2017→2015; venue USENIX VoteID→VoteID 2015 LNCS Springer. ✅ JONY-ACTION F RESOLVED (tick-3766): Marky et al. (2018) CHI added as correct citation for verifiable e-voting usability (95-participant Benaloh Challenge study). §1.4 paragraph updated: Marky et al. now cited for task-completion/workload focus (distinct from PIUP's privacy-mental-model focus); Kulyk et al. (2015) description confirmed accurate.
6. ✅ CHI 2027 word limit and formatting confirmed (tick-4271): 5,000-8,000 encouraged; 12,000 max. Body currently ~15,000 - needs cutting.

**Submission-ready target date:** September 10, 2026 (CHI 2027 deadline) with Study 1 results if pilot + full study can complete by ~August 2026. If Study 1 data is not available by September 10, the R&R phase (reviews November 5, resubmission December 3) may allow filling in results. Jony must decide: (a) race for September 10 with data, (b) submit without data as a 'paper in preparation' + use R&R, or (c) target SOUPS 2027 for a less constrained timeline.

**Writing sample use (before submission):** This draft (abstract + introduction) can be shared with potential PhD advisors from October 2026 onwards as a "paper in preparation." For Annie Antón (GT) and Sauvik Das (CMU), sharing the abstract + intro + the study arc blog post gives them both the technical framing and the accessible version. Do not share the incomplete sections (3-7 placeholders).
