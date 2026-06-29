# When the Receipt Can't Show What You Chose

_Jony Bursztyn · 2026-06-29_  
_Status: DRAFT — study arc accessible summary for PhD advisor sharing (Oct 2026 onwards)_  
_Related: [`drafts/piup-chi-paper-draft-2026-06-22.md`](piup-chi-paper-draft-2026-06-22.md), [`docs/gt-hci-research-statement-draft-2026-06-22.md`](../docs/gt-hci-research-statement-draft-2026-06-22.md)_

---

Every time you submit something online, the system confirms what you submitted. Your order confirmation lists the items. Your appointment confirmation shows the time. Your form submission echoes the values back. This is how confirmation UX works, and it works because the system knows what you did and has no reason to hide it.

Private voting systems break this convention on purpose.

A receipt that shows how you voted is a coercion surface. If you can produce evidence of your vote — a screenshot, a downloaded file, a confirmation email — then someone with power over you can demand that evidence. The privacy property collapses the moment the receipt is useful as proof of compliance. A private voting system whose receipt contains the submitted vote is, in the relevant sense, not private.

The technically correct solution is to put only a cryptographic artifact on the receipt — a hash derived from your identity and the vote, but not from the vote's content. The hash proves you participated. It does not prove what you chose. This is the right design, and it is also, consistently, what users read as a bug.

---

## The design problem I found myself in

I spent two years building Aztec Private Voting — a zero-knowledge voting contract deployed on a ZK rollup — and the cryptographic problems were solvable. The protocol could guarantee ballot privacy, individual verifiability, and double-vote prevention simultaneously. What I could not solve at the protocol layer was what to put on the receipt.

Every version I tried failed in one of two ways. Receipts that contained vote summaries created the coercion surface the protocol was designed to eliminate. Receipts that contained only the cryptographic hash — the "nullifier," in ZK voting terminology — left users convinced their vote had failed to register. The word "nullifier" made things worse: it sounds like the vote was nullified. Usability walkthroughs produced the same failure consistently. The user saw the hex string, saw no record of their choice, and concluded the system had broken.

This is a known pattern in security UX. Whitten and Tygar documented it in 1999 with PGP: when security interfaces produce unexpected output, users attribute the unexpected state to failure, not to design. The absent vote summary reads as error. The technical guarantee becomes an experiential failure.

---

## The design response: protective absence

The pattern I arrived at — the Proof-of-Inclusion UX Pattern, or PIUP — has one central idea: name the absent thing before the user notices it is missing.

The receipt contains four elements, in order:

1. **A status line.** "Your vote was cast." Before anything else, confirmation.
2. **A surrogate identifier.** Not the nullifier hash in raw form — a "vote fingerprint," abbreviated for readability. The fingerprint is generated randomly; it is not derived from the vote content, not from the voter's identity, and it can be verified later against the contract's public state.
3. **Protective framing.** "Your vote choice is not shown on this receipt. This is intentional — this fingerprint proves your ballot was counted without revealing what you voted for. Save it to verify after the vote closes, and keep it private until then."
4. **A verification affordance.** A collapsed "How to verify" explainer. Not the primary action — most voters will not use it — but there when they come back.

The framing in element 3 is doing the critical work. It names the absent thing, assigns it a purpose, and does so before the user's default failure-inference can form. "No vote summary" becomes "a design feature that protects you," rather than "a system error." Whether this actually works — whether protective absence produces better privacy mental models than alternatives, and which label produces the best mental model — is an empirical question. It is the question my research is designed to answer.

---

## The three-study arc

**Study 1** asks a prerequisite question: what do you call the surrogate identifier? Four candidate labels — *vote fingerprint*, *confirmation code*, *nullifier*, *receipt ID* — are compared across 280 participants in a pre-registered between-subjects experiment. The primary endpoint is privacy mental model quality: does the participant correctly understand that the identifier does not prove which option they voted for? The prediction is that "vote fingerprint" and "confirmation code" perform equivalently on overall accuracy (both produce the correct behavioral schema: save it, verify later), but diverge specifically on the privacy questions. "Confirmation code" activates an eCommerce representational schema — a confirmation code is evidence of what was confirmed — that is correct in every prior context and wrong here. "Vote fingerprint" carries a different metaphor: uniqueness without content. The study tests whether the metaphor choice matters.

**Study 2** asks whether explanation is the load-bearing element, or whether the label does the work on its own. A 2×2×2 factorial design crosses label (fingerprint vs. confirmation code), explanation (present vs. absent), and a calibration intervention (comprehension pre-check with immediate feedback, vs. none). If explanation closes the performance gap between labels, protective framing is rehabilitative — a familiar label can be corrected. If it does not, the label is doing work that framing cannot substitute. This is a design-consequential distinction.

**Study 3** asks a different question: of the voters who correctly understand the receipt, how many come back to verify? And does social proof — a live count of how many other voters have already verified in this election — increase the return rate? The verification affordance is only useful if voters use it; and ecological data from analogous security behaviors (Das et al., 2014) suggests social proof is one of the few reliable nudges for deferred security actions. Study 3 is designed to run concurrent with Study 2, using the same election, and will be framed explicitly as a pilot.

---

## What we'll know when it's done

The answer to "what should you call the identifier on a private voting receipt?" is currently an informed design judgment with a plausible mechanism story and no empirical support. After Study 1, it will be an empirically tested claim, pre-registered, with a complete privacy mental model measure and a stratification of which participant characteristics predict better comprehension. After Study 2, we will know whether protective framing can rehabilitate a familiar-but-schema-importing label. After Study 3, we will have a first estimate of whether social proof affects deferred verification behavior, with a powered replication lined up.

The point of the research is not the voting system. The point is a design class — receipts that must confirm recording without confirming content — that generalizes to sealed-bid auctions, whistleblower submission systems, anonymous peer review, and any domain where the absent thing is exactly what the user most expects the confirmation to contain. Private voting makes the stakes clear enough to test the design seriously.

That is the research I am doing.

---

_For the full technical treatment: [`drafts/piup-chi-paper-draft-2026-06-22.md`](piup-chi-paper-draft-2026-06-22.md)_  
_For the pre-registration: [`docs/piup-study1-preregistration-2026-06-22.md`](../docs/piup-study1-preregistration-2026-06-22.md)_  
_Study 2 design: [`docs/piup-study2-design-note-2026-06-22.md`](../docs/piup-study2-design-note-2026-06-22.md)_  
_Study 3 design: [`docs/piup-study3-social-verification-2026-06-29.md`](../docs/piup-study3-social-verification-2026-06-29.md)_
