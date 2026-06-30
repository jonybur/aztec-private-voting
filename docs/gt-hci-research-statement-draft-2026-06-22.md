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

The three studies follow directly from the PIUP's core claims. Study 1 — pre-registration complete and ready for OSF upload, with pilot launch planned once the filing is confirmed — is a four-condition between-subjects online survey (Prolific, N=280) isolating the effect of identifier label ("fingerprint" vs. "confirmation code" vs. "nullifier" vs. "receipt ID") on comprehension of receipt semantics: does label choice affect whether users correctly believe the identifier cannot reveal their vote? The confirmatory plan pre-registers 14 tests across four hypothesis families (H1–H4), with the primary endpoint on a two-item mental model probe and Holm-corrected family-level α. Study 2, whose design is contingent on Study 1's H4 outcome, is a 2×2×2 factorial (identifier label × absent-choice explanation × calibration intervention) — interactive prototype, Prolific, N=240 (8 cells × 30). It tests what Study 1 cannot: whether users correctly interpret absent vote content as a design choice rather than an error, whether comprehension converts to behavioral intention (self-reported save likelihood, observed download interaction), and whether an accuracy-feedback calibration intervention at receipt display time closes the overconfidence gap the H4 prediction identifies. Study 3 is a longitudinal field study in an actual DAO deployment — measuring deferred verification behavior (do users return to verify after a vote closes?) and what design variables predict it. The Aztec Private Voting contract exposes a public function that allows verification-rate measurement without de-anonymizing voters, which makes this field study tractable in a way that prior work on verifiable voting (Helios, STAR-Vote) did not have available.

Beyond voting, the underlying problem class is general: any system that records that a private submission occurred without recording the content faces the same design questions about receipt design, identifier choice, and verification affordance. Whistleblower submission systems, sealed-bid auctions, blind peer review — all have this structure. The PIUP is a first attempt to name the pattern across the class; establishing whether the design guidelines generalize is a research question in its own right.

Georgia Tech IC is where I want to pursue this work because of Annie Antón's research program on specifying and verifying privacy-correct software behavior. Antón's work asks: given a federal privacy regulation, how do we produce a software specification whose behavior is provably complete and correct? The PIUP problem is the adjacent question on the output side: given a system that has correctly implemented a privacy property — ballot secrecy, ZK-guaranteed — how do we design the user-facing feedback that produces correct mental models of that property in non-technical voters? The two questions are load-bearing for each other. A formally correct private voting system is not *fully* correct if users behave in ways that defeat its privacy property — sharing receipts under coercion, misinterpreting the absent vote summary as an error, failing to retain the identifier for later verification. The GVU Center's broader HCI tradition provides the methodological environment for the user-behavior work; Antón's privacy specification program provides the theoretical anchor for what "correct" user behavior would look like against a well-specified privacy requirement.

I have a working implementation, a documented design rationale, a named pattern with stated invariants, and a proposed evaluation agenda. What I do not have is the methodological depth to run the studies well, the peer community to stress-test the research framing, or the institutional access to recruit and compensate participants. That is what a PhD is for.

---

## Notes for adaptation

- **Word limit:** Most GT statements are 500–1,000 words. This draft is ~730. Cut the "beyond voting" paragraph if tight on space.
- **Faculty targeting — ✅ VERIFIED 2026-06-22 (updated tick-3644):**
  - The previous draft referenced "Apu Das" — fabricated name. **Sauvik Das** (who was previously at GT IC) is now at **CMU HCII**, not GT. Do NOT name him in a GT application.
  - **Recommended GT advisor: Annie Antón** — Professor (and former chair) of GT IC. Research: specification and verification of privacy-correct software systems; federal privacy/security regulation compliance; appointed to Obama's Commission on Enhancing Cybersecurity. Her angle (requirements → correct system behavior) complements the PIUP angle (UX → correct user mental models of that behavior). They are adjacent problems — a privacy system is only fully correct if its user-facing feedback produces correct user behavior.
  - **GT IC faculty page:** https://ic.gatech.edu/people/annie-anton
  - **Connection argument (use in statement):** Antón specifies what correct privacy behavior looks like at the software level; the PIUP work asks how to produce correct privacy *understanding* at the user level. The question of how UX feedback maps to or defeats a formal privacy specification is the bridge.
  - **Verified June 2026:** Antón is listed as Professor at GT IC. Research focus is currently on privacy policy compliance; she is affiliated with the NIST Information Security & Privacy Advisory Board and the Future of Privacy Forum Advisory Board.
  - **Recommendation:** Target CMU as primary (Sauvik Das + Cranor fit is stronger). Apply GT as secondary with Antón named. If you apply to GT, do NOT name Sauvik Das.
- **Sauvik Das citation template (for CMU application only):** See [`docs/cmu-hci-research-statement-draft-2026-06-22.md`](cmu-hci-research-statement-draft-2026-06-22.md)
- **Tone check:** The statement reads as technically literate but non-specialist. If applying to a more technically oriented program (e.g., Security track), the Aztec/ZK detail can be expanded; if applying to a CHI-oriented program, the three-study agenda is the lede and the ZK implementation is supporting context.
- **The honest position:** The statement does not claim results that have not been produced. It claims a design contribution (the PIUP), a research gap (receipt-freeness as a UX design problem), and a research agenda. This is the correct honest position for a first-year application.

---

## Related documents in this repo

- [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md) — full 15KB framing (related work detail, evaluation agenda, references)
- [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md) — PIUP pattern specification
- [`docs/receipt-design.md`](receipt-design.md) — implementation-level receipt design decisions
- [`GRANT.md`](../GRANT.md) — Aztec grant application (technical framing of the same work)
