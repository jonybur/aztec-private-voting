# Cover Letter — Georgia Tech Interactive Computing PhD Application

_Author: Jony Bursztyn · Draft 2026-06-29_  
_Related: [`docs/gt-hci-research-statement-draft-2026-06-22.md`](gt-hci-research-statement-draft-2026-06-22.md)_  
_Target: School of Interactive Computing, Georgia Institute of Technology_  
_Advisor of interest: **Annie Antón**, Professor, GT IC_

---

## Cover Letter

*(~420 words — adapt to any word limits; typically 1 page)*

---

Dear Graduate Admissions Committee,

I am applying to the PhD program in Interactive Computing at Georgia Tech because my research sits at the intersection of a UX design problem and a formal privacy specification problem — and Professor Annie Antón's work on specifying and verifying privacy-correct software behavior is the natural home for the bridge between them.

My name is Jony Bursztyn. I am a software engineer and researcher who has spent the past two years building a private voting system on Aztec Network, a ZK rollup that allows smart contracts to hold private state without revealing it. The cryptographic machinery was, in a meaningful sense, solved: zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and double-vote prevention simultaneously. What was not solved was the question of what to put on the receipt — how to communicate to a non-technical voter that their vote was counted, without the receipt revealing what the vote was. That design tension is not resolvable by a cryptographer. It requires human factors work.

The design I arrived at — the **Proof-of-Inclusion UX Pattern (PIUP)** — is the subject of my research statement. The short version: I found that receipts containing vote summaries create coercion vectors, while receipts containing only cryptographic artifacts confuse users into thinking the system has failed. The PIUP resolves this with a randomized surrogate identifier ("fingerprint") and explicit absent-choice framing: *"Your vote was counted. This receipt does not contain your vote — that is the privacy feature, not a limitation."* This is a falsifiable design claim that, as of today, has not been empirically tested.

The connection to Professor Antón's program is direct. Her work asks: given a privacy regulation or requirement, how do we produce software behavior that is provably complete and correct? The PIUP work is the adjacent question on the output side: given a system that has *correctly implemented* a privacy property at the protocol layer, how do we design the feedback that produces correct mental models of that property in non-technical users? The two questions are load-bearing for each other. A formally correct private voting system is not *fully* correct if users behave in ways that defeat its privacy property — sharing a receipt under coercion, misreading an absent vote summary as an error, failing to retain the identifier for deferred verification. What "correct" user behavior looks like is determined precisely by the formal privacy specification; and whether a UX design achieves it is an empirical question. That connection — between formal privacy specifications and the user behaviors they presuppose — is the intellectual project I would want to pursue at GT IC.

I have a working ZK voting system deployed on Aztec Network v5 testnet, a documented design pattern with stated invariants, a pre-registered Study 1 ready for pilot, and a three-study evaluation agenda described in my research statement. I am ready to begin empirical work and would welcome the opportunity to discuss this with Professor Antón.

Sincerely,  
Jony Bursztyn

---

## Notes for Jony

### What this letter does differently from the research statement
- The research statement is a 750-word academic case: research gap, design contribution, three-study agenda.
- This cover letter is ~420 words and is **personal**: who you are, what you built, why GT specifically, and why Antón. It should feel like a direct pitch, not an academic abstract.

### Antón-specific connection argument
The argument in ¶4 is the load-bearing connection: Antón specifies privacy-correct software behavior; the PIUP work asks whether the UX feedback produces privacy-correct *user behavior*. The two are adjacent problems with a clean intellectual bridge. This is the argument that makes the application coherent rather than generic.

- **Do not mention Sauvik Das** anywhere in the GT application — he is at CMU HCII, not GT IC.
- **Do not mention** the Babylon governance context from the Aztec repo; describe the voting system as DAO governance / private collective decision-making.

### Adapting for word limits
- If 1 page (strict): cut ¶2 ("My name is Jony…") down to one sentence introducing yourself and your project. The four paragraphs can become three.
- ¶3 (PIUP design) can be compressed to two sentences if needed — the full argument is in the research statement.
- ¶4 (Antón connection) should not be cut; this is the core differentiation from generic applicants.

### When to send this
- After completing the online application form.
- Most GT IC PhD applications require a Statement of Purpose (= research statement above), not a separate cover letter. However:
  - **Emailing Antón directly before applying is recommended.** The cover letter body ¶¶1-4 (minus the salutation to the committee) can be repurposed as a cold-contact email to Antón. Send a concise 3-paragraph version with: who you are, the PIUP project, and the formal-spec-to-UX-behavior bridge. Keep email under 300 words.
  - If the application portal has a "personal statement" field separate from "statement of purpose," use this letter body there.

### Cold-contact email template (for Antón)
Adapting the above to ~250-word email to `aanton@cc.gatech.edu`:

---

**Subject:** PhD application — ZK private voting + privacy spec / UX behavior bridge

Professor Antón,

I'm applying to GT IC for Fall 2027 and wanted to reach out before submitting. My research is on the UX side of a problem your work addresses from the specification side.

I've spent the past two years building a private voting system on Aztec Network (ZK rollup). The cryptographic privacy properties are formally specified and implemented; what I found is that they don't produce correct privacy behavior in non-technical users unless the UX feedback is carefully designed. A receipt that includes a vote summary creates a coercion vector; a receipt with only cryptographic artifacts reads as an error. I designed a pattern — the Proof-of-Inclusion UX Pattern (PIUP) — to resolve this: a randomized surrogate identifier ("fingerprint") paired with explicit absent-choice framing. The claim is falsifiable and untested; I have a pre-registered Study 1 ready for pilot.

The connection to your program: your work asks whether software behavior is provably complete and correct against a privacy requirement. The PIUP work asks whether UX feedback produces user behavior that is correct against that same requirement. What "correct" user behavior looks like is determined by the formal spec; whether a UI design achieves it is an empirical question. That bridge is what I want to study.

I've attached my research statement and would be glad to send the working paper.

Best,  
Jony Bursztyn

---

_(300 words. Send as plain text. Link to OSF pre-registration and GitHub repo optionally as footnotes.)_

---

## Related documents

- [`docs/gt-hci-research-statement-draft-2026-06-22.md`](gt-hci-research-statement-draft-2026-06-22.md) — full research statement
- [`docs/cmu-hci-research-statement-draft-2026-06-22.md`](cmu-hci-research-statement-draft-2026-06-22.md) — CMU version (Sauvik Das / SPUD Lab)
- [`docs/hci-research-framing-2026-06-22.md`](hci-research-framing-2026-06-22.md) — 15KB full research framing
- [`docs/piup-study1-preregistration-2026-06-22.md`](piup-study1-preregistration-2026-06-22.md) — OSF pre-registration (Study 1)
