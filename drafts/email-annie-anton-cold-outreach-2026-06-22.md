# Cold Email Draft — Annie Antón (Georgia Tech IC)

_Author: Jony Bursztyn · 2026-06-22_  
_Status: DRAFT — fill in [PLACEHOLDERS] before sending_  
_Related: `docs/gt-hci-research-statement-draft-2026-06-22.md`, `docs/piup-study1-preregistration-2026-06-22.md`_

---

## Before sending

Checklist:
- [ ] Fill in your email address
- [ ] Confirm GitHub repo visibility is public: `github.com/jonybur-oc/aztec-private-voting`
- [ ] Upload OSF artifacts and get the DOI — the email references a pre-registration; it should be live, not pending
- [ ] Attach your research statement PDF (1 PDF, ≤ 2 pages)
- [ ] Verify current GT IC PhD application deadline for Fall 2027 (typically January)
- [ ] Confirm Antón's current email: `aanton@gatech.edu` (GT standard format; verify against her faculty page)
- [ ] Send from your personal email, not a work address
- [ ] Do NOT mention Sauvik Das or CMU in this email

---

## Subject line

```
Prospective PhD applicant — pre-registered UX study on privacy-correct system feedback (ZK voting)
```

---

## Email body

```
Dear Professor Antón,

I'm a prospective PhD applicant for Fall 2027 at Georgia Tech IC. I'm writing because the
design problem I've spent the past year on sits at the output side of the question your
research program addresses — and I think the two halves belong in the same conversation.

Your work asks: given a privacy requirement, how do we specify software behavior that
correctly implements it? I built a private voting system on Aztec Network — a ZK rollup
that guarantees ballot secrecy on-chain — and found that question was only the first half.
After the cryptographic specification was correct, the unsolved question was: how does the
user-facing feedback produce correct user mental models of the privacy property the system
has implemented? Specifically: a voting receipt must confirm the vote was counted without
revealing the vote. That inversion of standard confirmation semantics — every other receipt
shows what was confirmed; this one deliberately cannot — caused early users to read the
absent vote choice as a system failure rather than a design-enforced privacy guarantee.
The design I arrived at (the Proof-of-Inclusion UX Pattern) uses an explicit absent-choice
explanation alongside a surrogate identifier. The core claim is that this explanation
produces correct mental models of the system's privacy behavior in non-technical voters. It
is now pre-registered on OSF: a 4-condition between-subjects Prolific study (n=70 per condition, N=280),
14 confirmatory tests across 4 Holm-corrected hypothesis families. The system is live on
Aztec v5 testnet; the pre-registration and full analysis scripts are in the public repo.

The reason this feels like a GT IC problem — and specifically yours — is that a formally
specified, cryptographically correct privacy system is not *fully* correct if users behave
in ways that defeat its privacy property. Voters who misread the absent vote choice as
failure may demand a receipt that shows their vote — the exact coercion vector the ZK
guarantee was designed to close. Your requirement-engineering tradition defines what
"correct" system behavior looks like against a privacy specification; what I'm working on
is defining what "correct" user behavior looks like against a correctly-behaving system.
The two problems are load-bearing for each other, and I haven't seen them treated as such
in either the requirements engineering or HCI-security literatures.

I've attached my research statement, which lays out the three-study evaluation arc and its
connection to prior work in both privacy requirements engineering and security/privacy UX.
If the framing seems like a fit for your current work, I'd welcome a 20-minute conversation
or written feedback before I apply in January.

Best,
Jony Bursztyn
[your email] | github.com/jonybur-oc/aztec-private-voting
OSF pre-registration: [OSF DOI once uploaded]
```

---

## Annotation: why this email is structured this way

**Subject line:** "Privacy-correct system feedback" is Antón's language (her work uses
"privacy-correct" to describe systems that correctly implement privacy requirements). Using
it in the subject line signals that Jony has read her work carefully, not just her faculty
bio. "ZK voting" gives the concrete domain.

**Paragraph 1 — One sentence orientation + the claim:** Establishes the GT IC / Fall 2027
context immediately, then makes the single framing move in one sentence: "output side of the
question your research program addresses." This is not flattery; it is a claim about how the
two research programs relate. It invites the reader to see if the claim holds up.

**Paragraph 2 — The problem and artifact:** Leads with Antón's framing ("your work asks:
...") before introducing the problem — this positions the email as a research conversation
rather than a self-introduction. The specific failure mode (absent vote choice interpreted
as failure) is concrete and novel. The pre-registration signals rigor without being pedantic
about methods in an email. The system being live on testnet signals the work is real.

**Paragraph 3 — The GT/Antón connection (the argument):** This is the most important
paragraph. It makes the specific claim: a formally correct privacy system is not fully
correct if users defeat its privacy property. That claim puts privacy requirements
engineering (Antón's field) and security/privacy UX (the PIUP work) in the same frame.
The closing sentence — "I haven't seen them treated as such in either literature" — is the
contribution claim. It is not hedged, because it is accurate: privacy requirements
engineering papers don't include user studies; security/privacy UX papers don't cite
requirements engineering foundations. The gap is real.

**Paragraph 4 — The ask:** Same structure as the Das email: two options (conversation or
written feedback), both specific and low-commitment. "Before I apply in January" places
a deadline without being demanding — it explains why the email is being sent now.

**Length:** 4 paragraphs, approximately 390 words in the email body. Matches the Das email
length. Long enough to establish the argument; short enough to be read in 2 minutes.

---

## Key differences from the Sauvik Das email

| | Sauvik Das (CMU) | Annie Antón (GT) |
|---|---|---|
| **Program anchor** | Social influence on security behavior | Privacy requirement specification |
| **Connection claim** | H4 is in the family of Das's social-proof confidence research | PIUP is the output-side complement to Antón's input-side specification work |
| **Primary artifact** | H4 prediction + calibration intervention | Pre-registration + load-bearing relationship claim |
| **Study cited** | Study 2 (designed) as needing SPUD Lab methodology | Study 1 (pre-registered) as evidence of rigor |
| **Tone** | More behavioral, methodology-focused | More theoretical, framing-focused |

The Das email leads with the behavioral prediction (H4). The Antón email leads with the
structural argument (load-bearing relationship between specification and UX). Both are
correct for their recipients.

---

## What NOT to include (common mistakes avoided)

- ❌ "I have always been passionate about privacy policy" — generic
- ❌ Mentioning Sauvik Das or CMU — do not signal dual-application; keep it clean
- ❌ Listing all five security findings from the audit — too technical, wrong audience
- ❌ "I admire your work on IBIS/RE" — sounds like CV padding; name the connection, not admiration
- ❌ Any mention of Babylon, BTC vaults, Babylon governance — entirely off-limits
- ❌ Mentioning the Aztec grant application — may read as "I want funding" rather than "I want a PhD"
- ❌ Claiming GT is "my first choice" — she doesn't need to know if this is true or not

---

## Antón faculty research context (for calibration)

- **Research:** Privacy requirement engineering, privacy policy analysis, specifying
  and verifying privacy-correct software behavior, federal privacy regulation compliance
- **Known as:** "IBIS-based requirements engineering," P-PATS (Privacy Policy Analysis
  Tools and Systems), privacy specification for online services
- **Advisory roles:** NIST Information Security & Privacy Advisory Board, Future of
  Privacy Forum Advisory Board, Obama's Commission on Enhancing Cybersecurity
- **Former role:** Chair of GT School of Interactive Computing; now Professor
- **GT IC faculty page:** https://ic.gatech.edu/people/annie-anton

---

## Timing

Best day/time to send: Tuesday–Thursday, 9–11 AM Eastern (Atlanta, ET).
Avoid Mondays (inbox backlog) and Fridays (pre-weekend purge).

GT IC application: typically opens September–October, deadline **January 1–15**.
Send this email **October–November** to be on Antón's radar before applications open.
Earlier than the Das email (September) because GT deadline is later (January).

**Note:** Send the Das email (CMU) in September; send this email (GT) in October–November.
The two emails are independent; do not reference each other in either.

**Action: set a reminder for 2026-10-15 to send this email, after confirming OSF DOI is live.**

---

## If Antón doesn't respond

Two fallback GT IC faculty who work in adjacent areas:
- **Sonia Chiasson** — privacy/security UX, accessible privacy tools (if still at GT; verify)
- **Vivek Balaraman** — privacy engineering and compliance (verify current GT affiliation)
- **GVU Center advisors** — if neither primary nor secondary responds, approach the GVU
  Center directly through its PhD recruitment channel

Do not cold-email more than two GT faculty. If neither responds, apply anyway with Antón
named as preferred advisor and note in the statement that you have not corresponded with her.
