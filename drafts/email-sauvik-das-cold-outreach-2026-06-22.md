# Cold Email Draft — Sauvik Das (CMU HCII / SPUD Lab)

_Author: Jony Bursztyn · 2026-06-22 (updated tick-4477, 2026-07-02 — Study 2 now pre-registered; 3-study → 4-study arc; "designed, not yet run" → "pre-registered")_  
_Status: DRAFT — fill in [PLACEHOLDERS] before sending_  
_Related: `docs/cmu-hci-research-statement-draft-2026-06-22.md`, `docs/piup-study1-preregistration-2026-06-22.md`_

---

## Before sending

Checklist:
- [ ] Fill in your email address
- [ ] Confirm GitHub repo visibility is public: `github.com/jonybur-oc/aztec-private-voting`
- [ ] Upload OSF artifacts first and get the DOI — the email references a pre-registration; it should be live, not pending
- [ ] Attach your research statement PDF as an attachment (1 PDF, ≤ 2 pages)
- [ ] Verify current HCII application deadline for Fall 2027 (typically December)
- [ ] Send from your personal email, not a work address

---

## Subject line

```
Prospective PhD applicant — pre-registered UX study on privacy mental models in ZK voting receipts
```

---

## Email body

```
Dear Professor Das,

I'm a prospective PhD applicant for Fall 2027 at CMU HCII. I'm writing because the research
problem I've been working on for the past year connects directly to your program's work on
how UI design shapes users' mental models of security and privacy.

The problem: I built a private voting system on Aztec Network — a ZK rollup that hides ballot
contents on-chain. After the cryptography was done, I found the receipt design was the open
question nobody had answered. A voting receipt must confirm the vote was counted; it must not
reveal the vote. That inversion of normal confirmation semantics — a bank receipt shows the
transaction; this one deliberately can't — caused early users to interpret absent vote choice as
system failure rather than a privacy guarantee. The design I arrived at (called the
Proof-of-Inclusion UX Pattern, or PIUP) uses an explicit absent-choice explanation alongside a
surrogate identifier. The core claim is that this explanation produces correct privacy mental
models faster than technically correct alternatives. That claim is now pre-registered on OSF:
Study 1 is a 4-condition between-subjects Prolific study (n=70 per condition, N=280), 14 confirmatory tests across
4 Holm-corrected hypothesis families. The system is live on Aztec v5 testnet.

The reason I want to pursue this specifically at the SPUD Lab is a prediction I'm calling H4.
H4 predicts that users shown a "confirmation code" label will report the highest confidence
ratings while scoring only moderately on accuracy — borrowing perceived competence from
eCommerce conventions without validating the underlying model. This is a different mechanism
from the social-proof effect your 2014 CCS work identified, but it's in the same family: a
UI convention changes user confidence in ways that aren't anchored to actual security
understanding. Study 2 (pre-registered) tests whether an accuracy-feedback calibration
intervention can close the confidence-accuracy gap before the receipt is displayed — and
whether it does so without reducing receipt-saving behavior. I expect the SPUD Lab's behavioral
methodology would sharpen the analysis.

I've attached my research statement (the full 4-study arc with methodology). If this sounds
like a fit for your current work, I'd welcome a 20-minute conversation — or feedback on the
framing before I apply in December.

Best,
Jony Bursztyn
[your email] | github.com/jonybur-oc/aztec-private-voting
OSF pre-registration: [OSF DOI once uploaded]
```

---

## Annotation: why this email is structured this way

**Subject line:** Faculty receive dozens of generic "I admire your research" emails from
prospective students. The subject line names a concrete artifact (pre-registered study) and a
specific domain (ZK voting receipts). Specificity signals that the work is real and the
connection to Das's program is not fabricated.

**Paragraph 1 — One sentence orientation:** Establishes context (prospective student, Fall 2027,
CMU HCII) and makes the claim that this is a genuine research-fit connection rather than a
mass-email. Does not say "I am passionate about HCI" or "I have read all your papers."

**Paragraph 2 — The problem and artifact:** Leads with the design problem, not the researcher.
Does not list credentials first. The specific claim — absent vote choice interpreted as system
failure — is concrete and novel. Ends with the OSF pre-registration, which is the
differentiating artifact. Most cold emails from prospective PhD students have no pre-registered
work. This one does.

**Paragraph 3 — The SPUD Lab connection:** Names Das's CCS 2014 paper ('Increasing Security Sensitivity With Social Proof: A Large-Scale Experimental Confirmation') specifically — this is verified real (doi:10.1145/2660267.2660271) and
describes the relationship to H4. The framing is "related but distinct mechanism" — this
positions Jony as someone who read the work carefully, not someone who made a vague analogy.
Study 2 is described as benefiting from Das's methodology, which is the correct pitch: not
"I will contribute to your lab" (arrogant for an email) but "your methodology would improve
my work" (accurate and appropriate).

**Paragraph 4 — The ask:** Two options given: a conversation, or feedback on the framing.
Both are specific and low-commitment for Das. "If this sounds like a fit" signals that Jony
understands fit is Das's call, not his.

**Length:** 4 paragraphs, approximately 380 words in the email body. This is the right length:
long enough to establish credibility, short enough to be read in 2 minutes.

---

## What NOT to include (common mistakes avoided)

- ❌ "I have always been fascinated by privacy and security" — generic opener
- ❌ Full list of past projects / work experience — that's what the CV is for
- ❌ Full methods section for Study 1 — that's what the research statement attachment is for
- ❌ Claiming Das is "my first choice" — sounds like negotiation prep, not research interest
- ❌ "I look forward to hearing from you" as a closing — states the obvious, adds nothing
- ❌ Mentioning GRANT.md or Aztec grant application — this is a PhD inquiry, not a funding pitch
- ❌ Any mention of Babylon, Babylon V2, or BTC vaults — entirely off-limits context

---

## Alternative subject line (if no OSF DOI yet)

```
Prospective PhD applicant — UX study on privacy mental models in ZK voting receipts (pre-reg pending OSF)
```

Send with the original subject once the OSF upload is complete. Do not send until the
pre-registration is at least submitted to OSF — "pre-registered" in an email to a faculty
member who may know what that means is a claim that needs to be verifiable immediately.

---

## Timing

Best day/time to send: Tuesday–Thursday, 9–11 AM Eastern. Avoid Mondays (inbox backlog)
and Fridays (pre-weekend purge). Das is at Pittsburgh time (ET).

Fall 2027 application: HCII application typically opens October, deadline December 1.
Send this email September–October to be on Das's radar before applications open. Do not
send in June — the gap between email and application is too long and the contact will be cold
by December.

**Action: set a reminder for 2026-09-15 to send this email, after confirming OSF DOI is live.**
