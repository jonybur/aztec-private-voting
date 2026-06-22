# Research Statement — Georgia Tech HCI PhD Application

_Author: Jony Bursztyn · Draft 2026-06-22_  
_Based on: [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md)_

---

## Research Statement

*(~750 words — adapt for word limits)*

---

I came to human–computer interaction research through a cryptography problem that refused to stay one. Two years ago I began building a private voting system on Aztec Network — a ZK rollup that allows smart contracts to manipulate private state without revealing it. The cryptographic machinery was, in a meaningful sense, solved: zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and double-vote prevention simultaneously. What was not solved — and what I spent six months discovering was not solvable with a proof system — was the question of what to put on the receipt.

A voting receipt must confirm that a vote was counted. It must not reveal what the vote was. Those two requirements are in tension at the UI layer in a way they are not at the protocol layer. The ZK proof handles the cryptographic half; no existing design pattern handles the user-facing half. When I showed early prototypes to non-technical participants, I found that receipts containing vote summaries created coercion vectors (a coercer could demand to see the receipt), while receipts containing only cryptographic artifacts — hash outputs, Merkle paths — confused users into thinking the system had failed. Neither design produced the behavior "save this, come back later and verify."

The design I arrived at — which I call the **Proof-of-Inclusion UX Pattern (PIUP)** — uses a randomized surrogate identifier ("fingerprint") paired with plain-language text that explicitly states the absent-choice design: *"Your vote was counted. This receipt does not contain your vote — that is the privacy feature, not a limitation."* The claim is that this framing produces correct mental models of receipt-freeness faster, and better security-oriented behavior (receipt retention, deferred verification), than technically correct alternatives. This claim is falsifiable and, as of today, untested.

That gap — between a design decision I made based on reasoning and prior work, and knowledge of whether that decision is correct — is what motivates my application to Georgia Tech HCI.

My research interests sit at the intersection of security feedback design and user mental models of privacy. I am specifically interested in what Whitten and Tygar (1999) called the "usability of security" problem as it applies to a new class of system: ZK-powered applications, in which the system can make strong privacy guarantees but communicating those guarantees requires users to form correct models of mathematical operations they have not encountered before. This is a harder version of the problem Felt et al. studied in Android permissions (2012) — not "does the user read the warning," but "does the user correctly understand that an absence of information in a confirmation message is itself a guarantee."

The three studies I would pursue in a PhD program follow directly from the PIUP's core claims. First, a mental model elicitation study: think-aloud protocol with 20–30 non-technical participants, measuring whether the "fingerprint" framing produces the correct model that the identifier does not reveal vote content. Second, a 2×2 between-subjects experiment contrasting absent-choice explanation (present vs. absent) and identifier label ("fingerprint" vs. "confirmation code") on trust score and receipt save rate. Third, a longitudinal field study in an actual DAO deployment — measuring deferred verification behavior (do users return to verify after a vote closes?) and what design variables predict it. The Aztec Private Voting contract exposes a public function that allows verification-rate measurement without de-anonymizing voters, which makes this field study tractable in a way that prior work on verifiable voting (Helios, STAR-Vote) did not have available.

Beyond voting, the underlying problem class is general: any system that records that a private submission occurred without recording the content faces the same design questions about receipt design, identifier choice, and verification affordance. Whistleblower submission systems, sealed-bid auctions, blind peer review — all have this structure. The PIUP is a first attempt to name the pattern across the class; establishing whether the design guidelines generalize is a research question in its own right.

Georgia Tech HCI is where I want to pursue this work because of the Security and Privacy HCI research program and its track record of work that connects formal security properties to empirically measured user behavior. The questions I care about — what feedback structure produces correct mental models of privacy guarantees, and how system designers can improve security-oriented behavior without requiring technical literacy — are exactly the questions that tradition has the methods and disposition to answer rigorously.

I have a working implementation, a documented design rationale, a named pattern with stated invariants, and a proposed evaluation agenda. What I do not have is the methodological depth to run the studies well, the peer community to stress-test the research framing, or the institutional access to recruit and compensate participants. That is what a PhD is for.

---

## Notes for adaptation

- **Word limit:** Most GT statements are 500–1,000 words. This draft is ~730. Cut the "beyond voting" paragraph if tight on space.
- **Faculty targeting:** If you are applying to work with Apu Das specifically, add a sentence in the final paragraph naming the lab and a specific prior paper of theirs that your work extends. Example: "Das et al.'s 2014 work on social influence in security adoption suggests that the verification behavior I observe in field studies may have a social component — an angle I would want to explore in the longitudinal study."
- **Lorrie Cranor connection:** If applying to CMU as a backup, swap the GT paragraph for the CyLab Privacy and Security group + Cranor's work on privacy nutrition labels — the absent-choice explanation in the PIUP is structurally similar to a privacy nutrition label for ZK proofs.
- **Tone check:** The statement reads as technically literate but non-specialist. If applying to a more technically oriented program (e.g., Security track), the Aztec/ZK detail can be expanded; if applying to a CHI-oriented program, the three-study agenda is the lede and the ZK implementation is supporting context.
- **The honest position:** The statement does not claim results that have not been produced. It claims a design contribution (the PIUP), a research gap (receipt-freeness as a UX design problem), and a research agenda. This is the correct honest position for a first-year application.

---

## Related documents in this repo

- [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md) — full 15KB framing (related work detail, evaluation agenda, references)
- [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md) — PIUP pattern specification
- [`docs/receipt-design.md`](receipt-design.md) — implementation-level receipt design decisions
- [`GRANT.md`](../GRANT.md) — Aztec grant application (technical framing of the same work)
