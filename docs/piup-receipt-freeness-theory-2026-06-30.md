# PIUP and Receipt-Freeness: Theoretical Positioning

**Date:** 2026-06-30  
**Status:** Internal analysis  
**Author:** tick-4339  
**Purpose:** Clarify precisely what the Proof-of-Inclusion UX Pattern (PIUP) achieves with respect to cryptographic receipt-freeness; position it against MACI's coercion-resistant approach. Intended to support Jony's PhD application materials and grant documentation.

---

## 1. Why this matters

The PIUP is described in `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` as addressing the "receipt-freeness problem in cryptographic voting theory (Benaloh and Tuinstra, 1994)." The GT and CMU application materials characterise the contribution as "applying receipt-freeness to UX." 

That framing is mostly right but imprecise in a way a PhD advisor or grant reviewer would probe. This document states precisely:

- What Benaloh-Tuinstra receipt-freeness requires
- What MACI achieves with respect to it
- What the PIUP achieves and does not achieve
- What the PIUP adds that is genuinely novel

The honest conclusion is that the PIUP is not a cryptographic receipt-freeness mechanism — it is a **UX pattern for communicating the partial receipt-freeness properties achievable in a token-gated pseudonymous system**. That is a defensible and publishable contribution; it just needs to be stated precisely.

---

## 2. Benaloh-Tuinstra receipt-freeness (1994)

Benaloh and Tuinstra defined receipt-freeness in the context of physical and computational voting:

> A voting scheme is *receipt-free* if a voter cannot construct a proof of how she voted that is convincing to a coercer.

The canonical threat is the **vote buyer** (or coercer): an adversary who offers to pay a voter conditional on the voter proving how they voted. If the voter can construct such a proof, coercion is economically rational; if she cannot, the coercer's offer is unenforceable.

Receipt-freeness has two dimensions:

**Passive receipt-freeness**: The system does not issue a receipt that encodes the vote choice. The voter cannot show the receipt to a coercer as proof of vote direction. This is achievable in a wide range of systems.

**Active receipt-freeness** (the stronger form): The voter cannot construct *any* proof of vote direction — not a system-issued receipt, but also not a self-generated transcript of the voting session (screen recording, browser proof logs, ZK proof re-use). This is substantially harder to achieve and requires that the voter cannot extract a "forced abstention" witness from the voting protocol itself.

Benaloh-Tuinstra's original concern was physical ballots (a voter writes their choice on a slip they conceal); the computational analogue is that any information the voter's client generates during the voting session is a potential coercion witness.

---

## 3. What MACI achieves

MACI (Minimum Anti-Collusion Infrastructure, Buterin 2019; implemented as PSE's MACI V3) targets **active receipt-freeness** via key updates:

- The voter registers a keypair with the MACI contract.
- At any point before the voting deadline, the voter can replace their keypair.
- The voter casts a ballot (encrypted to the tally authority's public key) with their current key.
- If the key is updated after voting, the earlier ballot is voided — only the last ballot under the most recent key counts.
- The coercer does not know whether the voter has updated their key after "proving" how they voted.

The critical property: a voter under coercion can cast a ballot in front of the coercer (proving they voted as instructed), then secretly update their key and re-vote. The coercer cannot distinguish a real committed vote from a later-overridden one, because tally outputs are only revealed after all ballots are processed by the operator.

MACI's receipt-freeness is **conditional on the operator being honest and the key-update mechanism being available**. If the operator colludes with the coercer, MACI fails. If the voter cannot access the key-update path (network censorship), MACI fails. Under reasonable assumptions, MACI achieves strong receipt-freeness.

**Limitations of MACI for token-gated pseudonymous voting:**

1. **Key sale is unaddressable.** If the coercer purchases the voter's wallet outright (not just observes them voting), no mechanism prevents coercion. MACI's authors acknowledge this explicitly.

2. **Token-gated eligibility doesn't compose cleanly.** MACI's eligibility model (poll-period registration) works well for identity systems; for token-gated systems (hold X tokens to vote), the token position itself is observable on-chain. A coercer can see whether the voter's address holds eligible tokens and can monitor the tally for indirect inference.

3. **No usable receipt artifact.** MACI does not produce a receipt that the voter can later use to verify their ballot was counted. The MACI-v3 spec notes this as a desired extension. From the voter's perspective: trust that the tally is correct (via ZK proof of tally correctness), but no individual-level verification.

---

## 4. What the PIUP achieves

The PIUP targets a different and weaker property than MACI. Its explicit design context (stated in `receipt.md` §Threat model) is:

> For token-based, pseudonymous eligibility, receipt-freeness — not full coercion resistance — is the realistic ceiling.

The PIUP's receipt-freeness guarantee is:

**What holds:** The system does not issue a receipt that encodes the vote choice. The vote fingerprint (receipt_id) is a random surrogate with no informational content beyond membership in the "counted" set. A coercer who obtains the fingerprint cannot learn the vote direction from it.

**What does not hold:** The voter can construct a self-generated proof of vote direction. The voting session necessarily involves a browser interaction where the vote choice is visible; the Aztec contract's public `record_vote` call carries both `vote_choice` and `receipt_id` as public arguments. A voter who records their session or retains the transaction hash has a coercion witness. The PIUP does not and cannot address this.

This is **passive receipt-freeness**, not active receipt-freeness. The distinction is:

| Property | PIUP achieves? | MACI achieves? |
|---|---|---|
| System receipt does not encode choice | ✅ Yes | ✅ Yes |
| Voter cannot self-generate a coercion proof | ❌ No | ✅ Yes (conditionally) |
| Voter can verify individual ballot inclusion | ✅ Yes (via fingerprint) | ❌ No |
| Non-technical voter can understand what was verified | ✅ Yes (designed for) | ❌ No |
| Key-sale coercion is addressed | ❌ No | ❌ No |

The PIUP trades active receipt-freeness (which requires cryptographic infrastructure for key updates and operator honesty) for **individual verifiability with usable UX**. This is not a weaker version of MACI — it is a different design choice for a different deployment context.

---

## 5. The actual novel contribution

The novel contribution of the PIUP is not in the cryptography — random surrogates for receipts are implied by receipt-freeness theory and used in various protocol designs. The novel contribution is the **UX treatment of the constrained receipt-freeness guarantee**:

1. **Naming the design class.** Before PIUP, there was no named design pattern for receipts in systems with partial receipt-freeness. Designers faced a binary: claim receipt-freeness (misleading if incomplete) or claim none (abandoning usable verification). The PIUP names the middle ground: a receipt that proves inclusion without encoding content, with explicit documentation of where the receipt-freeness guarantee ends.

2. **Surrogates with the right mental model.** The key UX insight is that the surrogate (vote fingerprint) needs a user-facing name that activates the correct mental model: *saves and uses it later to verify, does not share it with others until the vote closes*. The word "fingerprint" achieves this; "token," "ID," "hash," and "nullifier" do not (based on usability analogies from comparable systems).

3. **Explicit threat model in user-facing copy.** The receipt UI includes copy that explains both what the fingerprint proves and what it does not prove, at a reading level that does not require cryptographic background. No existing private voting system does this. The threat model is usually documented only in protocol papers; the PIUP moves it to the user interface.

4. **Three formal invariants.** The PIUP document states three invariants that any implementation must satisfy for the pattern to hold (surrogate independence, surrogate privacy in transit, minimal receipt content). These can be used as a design checklist independent of the cryptographic backend — the pattern works with Aztec, MACI, Shutter, or any system with a "counted set."

---

## 6. How this should be described in PhD application materials

The honest framing for the GT and CMU applications is:

> The PIUP identifies and names a design class for receipt artifacts in systems with partial receipt-freeness — specifically, token-gated pseudonymous voting where key-sale coercion is out of scope. The pattern isolates what receipt-freeness guarantees are achievable (a receipt that does not encode the vote choice) from what is not achievable (preventing voters from self-generating coercion witnesses) and designs the user experience around that boundary explicitly. The contribution is not a new cryptographic guarantee; it is a principled mapping from a constrained cryptographic property to a user-facing design artifact, with three invariants, a threat model written for non-experts, and an HCI rationale for surrogate naming based on mental model activation.

This is defensible under scrutiny. It does not overclaim receipt-freeness (which would be wrong); it does not underclaim ("just a receipt design") which would undersell the theoretical grounding.

---

## 7. Where the PIUP sits in the broader voting security literature

The security properties relevant to voting systems form a well-documented lattice:

```
Strongest                                                    Weakest
─────────────────────────────────────────────────────────────────────
Full coercion resistance (Chaum's blind-vote; practically undeployed)
       │
Active receipt-freeness (MACI under honest operator)
       │
Passive receipt-freeness + individual verifiability ← PIUP sits here
       │
Passive receipt-freeness only (most token-gated systems)
       │
No receipt-freeness (most DAO governance votes today)
─────────────────────────────────────────────────────────────────────
```

The PIUP operates at the "passive receipt-freeness + individual verifiability" level — stronger than the current DAO governance baseline (which offers no receipt-freeness and no individual verifiability) and weaker than MACI (which offers active receipt-freeness but no individual verifiability and lower deployment tractability).

The claim is not "the PIUP is better than MACI." The claim is: **for the deployment context where DAOs with token-gated pseudonymous voting want individual ballot verification without requiring the operator infrastructure MACI needs, the PIUP is the correct design.**

---

## 8. Open questions for future research

These are genuine open problems that could form part of a PhD research agenda:

**Q1: Can individual verifiability and active receipt-freeness coexist?**  
The two properties appear in tension: verifiability requires the voter to hold a witness linking them to the "counted" set; active receipt-freeness requires that no such linkable witness exists. MACI's approach resolves this by making the witness "one-time" and unverifiable by third parties. Can a similar construction produce an individually-verifiable receipt without breaking active receipt-freeness?

**Q2: Is the "vote fingerprint" naming robust across cultures and languages?**  
The naming rationale in `receipt-design.md` is based on English-language mental model analogies. Usability studies (Study 1) will test comprehension of the fingerprint metaphor in a US English-speaking Prolific sample. Cross-cultural and cross-language generalisability is untested.

**Q3: How does social proof affect the trade-off between verifiability and pressure?**  
Study 3 tests whether showing a "N voters have verified" counter increases verification rates. But the counter also creates a social signal that *not verifying* is non-normative, which could increase coercion pressure on voters who have not verified. The interaction between social proof for usability and coercion pressure is unexplored in the voting security literature.

**Q4: What is the right UX for the temporal privacy constraint?** *(Addressed by Study 4)*  
The PIUP's receipt-freeness holds only if the fingerprint is kept private until the tally closes (otherwise the fingerprint → transaction → choice lookup is possible). The current receipt UI handles this with copy ("don't share until the vote closes"). Is copy sufficient? Would a UI that prevents sharing before the deadline (e.g., a share button that becomes active only after finalization) be more robust? And would that create usability problems for voters who want to confirm immediately?

Study 4 (pre-registered 2×2 vignette, N=160; `docs/piup-study4-osf-prereg-2026-07-01.md`) directly addresses this question. The UI-lock condition disables copy/share until vote close; the countdown-only condition uses copy instruction alone ("sharing is safe after vote close"). The primary DV is self-reported sharing intent (7-point scale); the interaction hypothesis is that the lock's sharing-intent reduction is larger under high adversarial pressure than moderate pressure — where a technical constraint ("I cannot") is harder for a coercer to override than a normative one ("I should not"). The secondary DV measures perceived deniability: does the voter believe "the app won't let me" is a convincing and socially acceptable response to a coercer? Study 4 provides the first experimental evidence on whether UI-level temporal enforcement (Invariant 2) produces genuine coercion resistance at the social layer.

The remaining open question — whether the lock creates usability problems for voters who want to confirm immediately — is not addressed by Study 4 (which measures coercion resistance in adversarial scenarios, not verification convenience). This would require a separate usability study with non-adversarial verification tasks.

These questions are the natural research agenda following Studies 1–3; Q4 is now the subject of Study 4.

---

## Related documents

- `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` — the PIUP definition
- `docs/receipt-design.md` — the UX rationale
- `docs/receipt.md` — threat model and verification flow
- `docs/piup-study3-social-verification-2026-06-29.md` — Study 3 (social proof)
- `docs/piup-study4-temporal-coercion-vignette-2026-07-01.md` — Study 4 design (addresses Q4 above)
- `docs/piup-study4-osf-prereg-2026-07-01.md` — Study 4 pre-registration
- `docs/gt-hci-research-statement-draft-2026-06-22.md` — GT application
- `docs/cmu-hci-research-statement-draft-2026-06-22.md` — CMU application
- `GRANT.md` — Aztec Wave 3 grant application
