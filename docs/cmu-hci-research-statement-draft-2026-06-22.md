# Research Statement — CMU HCII PhD Application

_Author: Jony Bursztyn · Draft 2026-06-22_  
_Adapted from: [`docs/gt-hci-research-statement-draft-2026-06-22.md`](gt-hci-research-statement-draft-2026-06-22.md)_  
_Advisor target: **Sauvik Das** · SPUD Lab · CMU HCII (https://sauvikdas.com)_

---

## Research Statement

*(~780 words — adapt for word limits; ~730 words if "beyond voting" paragraph cut)*

---

I came to human–computer interaction research through a cryptography problem that refused to stay one. Two years ago I began building a private voting system on Aztec Network — a ZK rollup that allows smart contracts to manipulate private state without revealing it. The cryptographic machinery was, in a meaningful sense, solved: zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and double-vote prevention simultaneously. What was not solved — and what I spent six months discovering was not solvable with a proof system — was the question of what to put on the receipt.

A voting receipt must confirm that a vote was counted. It must not reveal what the vote was. Those two requirements are in tension at the UI layer in a way they are not at the protocol layer. The ZK proof handles the cryptographic half; no existing design pattern handles the user-facing half. When I showed early prototypes to non-technical participants, I found that receipts containing vote summaries created coercion vectors (a coercer could demand to see the receipt), while receipts containing only cryptographic artifacts — hash outputs, Merkle paths — confused users into thinking the system had failed. Neither design produced the behavior "save this, come back later and verify."

The design I arrived at — which I call the **Proof-of-Inclusion UX Pattern (PIUP)** — uses a randomized surrogate identifier ("fingerprint") paired with plain-language text that explicitly states the absent-choice design: *"Your vote was counted. This receipt does not contain your vote — that is the privacy feature, not a limitation."* The claim is that this framing produces correct mental models of receipt-freeness faster, and better security-oriented behavior (receipt retention, deferred verification), than technically correct alternatives. This claim is falsifiable and, as of today, untested.

That gap — between a design decision I made based on reasoning and prior work, and knowledge of whether that decision is correct — is what motivates my application to CMU HCII.

My research interests sit at the intersection of security feedback design and user mental models of privacy. I am specifically interested in what Whitten and Tygar (1999) called the "usability of security" problem as it applies to a new class of system: ZK-powered applications, in which the system can make strong privacy guarantees but communicating those guarantees requires users to form correct models of mathematical operations they have not encountered before. This is a harder version of the problem Felt et al. studied in Android permissions (2012) — not "does the user read the warning," but "does the user correctly understand that an absence of information in a confirmation message is itself a guarantee."

The three studies follow directly from the PIUP's core claims. Study 1 — pre-registered on OSF and ready for pilot — is a four-condition between-subjects online survey (Prolific, N=280) isolating the effect of identifier label ("fingerprint" vs. "confirmation code" vs. "nullifier" vs. "receipt ID") on comprehension of receipt semantics: does label choice affect whether users correctly believe the identifier cannot reveal their vote? The confirmatory plan pre-registers 14 tests across four hypothesis families (H1–H4), with the primary endpoint on a two-item mental model probe and Holm-corrected family-level α. Study 2, whose design is contingent on Study 1's H4 outcome, is a 2×2×2 factorial (identifier label × absent-choice explanation × calibration intervention) — interactive prototype, Prolific, N=240 (8 cells × 30). It tests what Study 1 cannot: whether users correctly interpret absent vote content as a design choice rather than an error, whether comprehension converts to behavioral intention (self-reported save likelihood, observed download interaction), and whether an accuracy-feedback calibration intervention at receipt display time closes the overconfidence gap the H4 prediction identifies. Study 3 is a longitudinal field study in an actual DAO deployment — measuring deferred verification behavior (do users return to verify after a vote closes?) and what design variables predict it. The Aztec Private Voting contract exposes a public function that allows verification-rate measurement without de-anonymizing voters, which makes this field study tractable in a way that prior work on verifiable voting (Helios, STAR-Vote) did not have available.

Beyond voting, the underlying problem class is general: any system that records that a private submission occurred without recording the content faces the same design questions about receipt design, identifier choice, and verification affordance. Whistleblower submission systems, sealed-bid auctions, blind peer review — all have this structure. The PIUP is a first attempt to name the pattern across the class; whether the design guidelines generalize is a research question in its own right. The absent-choice explanation in PIUP is structurally analogous to the privacy nutrition labels that Cranor and colleagues have developed — both aim to communicate what is *not* disclosed rather than what is — and I would want to build on that line of work.

CMU HCI is where I want to pursue this work because of the SPUD Lab's program of research connecting social context to security and privacy outcomes. Das et al.'s 2014 SOUPS work on social nudges for security adoption (the Facebook study) <!-- [Fixed tick-4052] CCS→SOUPS: Das et al. 'Increasing Security Sensitivity With Social Proof' was published at SOUPS 2014, not CCS. CCS 2014 is the wrong venue. Consistent with pre-reg (tick-4042), study-protocol (tick-4048), ADR-037 (tick-4046), study2-design-note (tick-4050) fixes. --> is particularly relevant to the longitudinal field study I described above: deferred verification behavior may not be purely individual — users may verify when they see others doing so, or when the social cost of not verifying becomes visible. That social dimension is absent from the verifiable voting literature and would be a novel contribution. The CyLab Privacy and Security group, and Cranor's work on communicating privacy through structured disclosure, provides a second point of connection: the PIUP's "privacy by absent content" framing is an untested instance of structured privacy disclosure applied to ZK systems, and I would want to situate it there.

I have a working implementation, a documented design rationale, a named pattern with stated invariants, and a proposed evaluation agenda. What I do not have is the methodological depth to run the studies well, the peer community to stress-test the research framing, or the institutional access to recruit and compensate participants. That is what a PhD is for.

---

## CMU-specific adaptation notes

### Advisor targeting
- **Primary:** Sauvik Das · SPUD Lab · Associate Professor, CMU HCII (https://sauvikdas.com)
  - _Verified current as of June 2026_ — moved from Georgia Tech; now at CMU HCII and CyLab
  - Research fit: security feedback design, mental models of privacy, social proof for security behavior
  - Cite specifically: Das et al., "Increasing Security Sensitivity With Social Proof: A Large-Scale Experimental Confirmation," SOUPS 2014 <!-- [Fixed tick-4052] CCS→SOUPS: wrong venue in advisor-targeting note -->
- **Secondary:** Lorrie Faith Cranor · CyLab / HCII (privacy nutrition labels, P3P usability)
  - The PIUP absent-choice explanation is structurally a privacy nutrition label for ZK receipts — make this explicit in any cover letter or SOP supplement

### Do NOT mention
- Georgia Tech, GT Interactive Computing, or any GT faculty — this is the CMU statement
- "Apu Das" — fabricated name, does not exist anywhere
- Any Babylon-specific governance context (the voting system is presented as generic ZK voting infrastructure)

### Word limit
- ~780 words as written. Standard HCII SOP is 500–1,000 words (check current requirements)
- If cutting: remove the "beyond voting / privacy nutrition labels" paragraph (~75 words) first — the SPUD Lab / social nudge angle is load-bearing for advisor fit, do not cut that
- The Cranor connection can move to a cover letter supplement if space is tight

### Tone
- Statement reads as technically literate but accessible. HCII is a CHI-oriented program — do not expand the ZK/Aztec technical detail
- The three-study agenda is the academic substance; it must stay intact
- Do not claim results not yet produced (studies have not run; the statement correctly positions PIUP as a design contribution that generates research questions)

### Contact / application logistics
- Sauvik Das email: reach out before applying; mention the SOUPS 2014 social nudge work explicitly <!-- [Fixed tick-4052] CCS→SOUPS: wrong venue in contact logistics note -->
- CMU HCII application portal: https://hcii.cmu.edu/academics/phd/apply
- SPUD Lab page: https://sauvikdas.com/lab
- CyLab directory: https://www.cylab.cmu.edu/directory/bios/das-sauvik.html

### Cold-contact email template (for Sauvik Das)

**Subject:** PhD application — ZK voting receipt UX + social verification behavior

Professor Das,

I'm applying to CMU HCII for Fall 2027 and wanted to reach out first. My research is on the UX design side of a problem your SOUPS 2014 social nudge work speaks to directly.

I've spent the past two years building a private voting system on Aztec Network (a ZK rollup). The cryptographic privacy properties work: ZK proofs guarantee ballot privacy and individual verifiability simultaneously. What I found is that these properties don't produce correct user behavior unless the UX feedback is carefully designed. A receipt showing a vote summary creates a coercion vector; a receipt showing only cryptographic artifacts is read as a system failure. I designed a pattern — the Proof-of-Inclusion UX Pattern (PIUP) — that uses a randomized surrogate identifier ("fingerprint") and explicit absent-choice framing: *"Your vote was counted. This receipt does not contain your vote — that is the privacy feature, not a limitation."* The pattern generates falsifiable claims about comprehension, security behavior, and — most directly relevant to your work — deferred verification behavior.

That last one is the connection I'd want to explore with you. Study 3 of my proposed agenda is a field study measuring whether users actually return to verify after a vote closes. From the verifiable voting literature, we have essentially no data on this. Your 2014 SOUPS work suggests the answer may be social: users may verify when they see others doing so, or when not verifying carries a visible social cost. The ZK contract I deployed exposes a public verification-rate measurement without de-anonymizing voters — which makes that field study tractable for the first time. Whether social context drives deferred security behavior in private systems is a question I don't think anyone has studied, and it sits squarely in the SPUD Lab's program.

I have a working implementation on Aztec testnet, a pre-registered Study 1 ready for pilot, and a full three-study agenda in my research statement. Happy to share that or the OSF pre-registration.

Best, Jony Bursztyn

---

_(~280 words. Send to: sauvik@cmu.edu — verify current address before sending. Link OSF pre-registration and GitHub repo optionally as footnotes. Do not mention Georgia Tech or Annie Antón.)_

---

## Related documents in this repo

- [`docs/gt-hci-research-statement-draft-2026-06-22.md`](gt-hci-research-statement-draft-2026-06-22.md) — GT version (do not use for CMU; advisor references are wrong for GT as of June 2026)
- [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md) — full 15KB framing (related work detail, evaluation agenda, references)
- [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](proof-of-inclusion-ux-pattern-2026-06-22.md) — PIUP pattern specification
- [`docs/receipt-design.md`](receipt-design.md) — implementation-level receipt design decisions
- [`GRANT.md`](../GRANT.md) — Aztec grant application (technical framing of the same work)
