# M2: Tally Privacy Design Spike

**Date:** 2026-06-22  
**Status:** Decision-gate document — for planning session review  
**Author:** @jonybur-oc  
**Decision gate:** Pick one architecture. Do not proceed with M3 until this is resolved.

---

## 1. The decision

The current system is L1 — anonymous plaintext ballots. Running tally is public.
M2 means moving to at least one of: hidden running tally (L2a), receipt-freeness
(L2b), or both. These are separable but usually bundled.

Three architectures reach L2 from different angles. This document evaluates them
against the PSE/Shutter "State of Private Voting 2026" property rubric, then
gives a recommendation.

---

## 2. Evaluation framework (PSE rubric, selected properties)

The PSE report defines 26 properties across five categories. Below are the twelve
that materially differ between the three architectures. Properties where all three
are equivalent (e.g. eligibility verifiability, double-vote prevention, smart
contract compatibility, weighting support) are omitted.

| # | Property | What it means here |
|---|---------|---------------------|
| P1 | **Ballot secrecy** | Does an observer see the choice during the vote window? |
| P2 | **Running tally privacy** | Is the in-progress tally hidden until finalize? |
| P3 | **Receipt-freeness** | Can a voter prove to a coercer how they voted? |
| P4 | **Coercion resistance** | Can a voter cast a final ballot that overrides a coerced one? |
| P5 | **Universal verifiability** | Can anyone audit the final count without trusting the operator? |
| P6 | **Individual verifiability** | Can a voter confirm their ballot was counted? |
| P7 | **Coordinator trust** | What must the coordinator be trusted not to do? |
| P8 | **Prover-side burden** | What must the voter's browser do cryptographically? |
| P9 | **Deployment maturity** | Is the underlying component production-ready? |
| P10 | **Integration lift** | Estimated dev work to integrate into existing Umbra stack? |
| P11 | **L1 data leak** | Does any choice-revealing data appear on L1 (Ethereum)? |
| P12 | **Liveness dependency** | What external systems must stay online for voting to work? |

---

## 3. Architecture A — Aztec-native encrypted ballots

**Mechanism:** `cast_vote` stores the voter's choice as an Aztec private note
encrypted to a coordinator (tallier) Aztec account. After the vote window closes,
the coordinator decrypts each note and publishes the aggregated tally with a ZK
correctness proof (or a Merkle audit trail). Receipt-freeness is attempted via
one of: (i) key-change — voter can rotate their note decryption key mid-vote
so that a proof-of-choice to a coercer becomes invalid; (ii) ballot
re-randomization — voter can submit a new ballot that overwrites the first.

**Against the rubric:**

| Property | Score | Notes |
|----------|-------|-------|
| P1 Ballot secrecy | ✅ Strong | Choice is inside an Aztec private note; L1 sees only an encrypted payload |
| P2 Running tally privacy | ✅ Strong | Coordinator cannot tally until the window closes (or can be designed so) |
| P3 Receipt-freeness | ⚠️ Partial | Key-change and re-randomization both work in theory but require the voter to act *before* coercion happens; a voter who shares their decryption key is still coercible. Real receipt-freeness requires the coordinator to run a re-encryption mix, which is an additional component |
| P4 Coercion resistance | ⚠️ Partial | Ballot overwrite (re-randomization) gives limited resistance if the coercer can see the final submitted note on L1; key-change requires voter to know they're being coerced |
| P5 Universal verifiability | ⚠️ Coordinator-dependent | The correctness proof depends on the coordinator publishing a valid proof after decryption; if the coordinator refuses, the tally is unverifiable |
| P6 Individual verifiability | ✅ | Aztec note commitment is in the private state tree; voter can prove their note exists |
| P7 Coordinator trust | ❌ HIGH | Coordinator sees all individual ballots. This is MACI-class trust: "MACI is honest but curious." The coordinator can conduct the tally correctly and still know how everyone voted. |
| P8 Prover-side burden | ✅ Low | Ballot encryption is a single note store; no extra proving beyond M1 |
| P9 Deployment maturity | ✅ High | Aztec private notes are the core Aztec primitive; fully supported on v5 |
| P10 Integration lift | ✅ Low | Replaces `record_vote` increments with note-store pattern; all existing infrastructure (receipt, eligibility, VoteResult) stays |
| P11 L1 data leak | ✅ None | Encrypted note + nullifier only; no choice data on L1 |
| P12 Liveness dependency | ✅ Low | Aztec network only; coordinator is an Aztec account (not an external service) |

**Summary:** Architecture A achieves running tally privacy (P2) and ballot secrecy
(P1) cleanly. It reaches partial receipt-freeness (P3) — enough to claim "choice
not linkable during vote window" — but does not reach formal receipt-freeness
(P3 = ✅ full) without adding a re-encryption mix. The coordinator trust
requirement (P7 ❌) is the main trade-off: this is MACI-class, not DAVINCI-class.

---

## 4. Architecture B — Timelock encryption

**Mechanism:** Each ballot is encrypted under a timelock key (e.g. drand
threshold BLS, or Aztec's own time oracle if it ships). The encrypted ciphertext
is committed onchain. After the vote deadline, the timelock authority publishes
the decryption key; the coordinator (or anyone) decrypts all ballots and computes
the tally. Receipt-freeness is not addressed — timelock gives tally privacy but
not choice privacy after decryption.

The Aragon/Aztec PoC referenced in the PSE report uses a hybrid: votes stored as
Aztec notes until decryption key release, then bulk-decrypted. The PSE report
gives this architecture "Low maturity."

**Against the rubric:**

| Property | Score | Notes |
|----------|-------|-------|
| P1 Ballot secrecy | ✅ During vote window | After key release, every ballot is decryptable by anyone |
| P2 Running tally privacy | ✅ Strong | Ciphertexts are published but not decryptable until deadline |
| P3 Receipt-freeness | ❌ None | Post-deadline all choices are public; a voter can trivially prove their choice by showing their decrypted ballot |
| P4 Coercion resistance | ❌ None | After deadline, coercion is retroactively trivial |
| P5 Universal verifiability | ✅ Strong | After key release, anyone can recompute the tally from public ciphertexts |
| P6 Individual verifiability | ✅ | Same as A |
| P7 Coordinator trust | ✅ Low | Coordinator is just a decryptor; cannot cheat without the timelock key |
| P8 Prover-side burden | ✅ Low | IBE/BLS encryption is cheap |
| P9 Deployment maturity | ❌ Low | PSE report says "Low maturity." `drand`/`timelock.zone` is an external dependency; `timelock.zone` shut down in 2024 (replaced by `drand` v2 League of Entropy). The Aragon/Aztec PoC is unmaintained. No production instance of this pattern on an Aztec v5 mainnet exists. |
| P10 Integration lift | ⚠️ Medium | Requires drand client integration, key release oracle, bulk decryption step |
| P11 L1 data leak | ✅ None during window | ❌ After deadline: all choices public onchain |
| P12 Liveness dependency | ❌ High | drand network must be live at vote open (key commitment) AND at deadline (key release). If drand experiences an incident mid-vote, the vote cannot finalize |

**Summary:** Architecture B achieves running tally privacy (P2) cleanly — arguably
the cleanest of the three, since the decryption key simply does not exist until the
deadline. But it fundamentally trades tally privacy *during the window* for zero
privacy *after*. It does not deliver P3 or P4 under any design variant.
The liveness dependency on an external threshold network (P12 ❌) and the low
maturity score (P9 ❌) are serious blockers for a production DAO product that must
"just work."

The PSE report's own conclusion: timelock is "architecturally clean" but
"Low" on maturity and deployment ease. For Umbra — a *managed service* — the
external dependency is particularly bad: if drand fails, Umbra failed.

---

## 5. Architecture C — Protocol adapter (MACI V3 or DAVINCI)

**Mechanism:** Umbra provides only the UX layer — ballot submission, facilitator
flow, receipt artifact — while the cryptographic heavy lifting runs on an existing
protocol. Two sub-options from the PSE report:

**C1 — MACI V3 (PSE/EF maintained):**
MACI = Minimum Anti-Collusion Infrastructure. Voters submit encrypted ballots to
a coordinator's public key. Coordinator runs an off-chain multi-layered
re-encryption mix, producing a proof that the final tally is correct without
revealing individual votes. The coordinator never sees which voter submitted which
ballot (anonymous ballot submission) but can see the set of decrypted vote choices
(not linked to identities). Key-change mechanism: voter can submit a new
key-change message before the vote closes, which invalidates a coerced ballot.
MACI V3 supports onchain submission and a ZK proof of correct tallying.

**C2 — DAVINCI (Vocdoni):**
DAVINCI uses stealth overwrite + re-randomization: voters submit encrypted ballots,
and can overwrite them any number of times. The last ballot before deadline counts.
Because earlier ballots are overwritten (not just superseded), a coercer cannot
distinguish "showed me their real ballot" from "showed me a decoy then overwrote."
PSE report rates DAVINCI as "the strongest per-property score" on receipt-freeness,
but notes it is pre-mainnet.

**Against the rubric:**

| Property | MACI V3 | DAVINCI | Notes |
|----------|---------|---------|-------|
| P1 Ballot secrecy | ✅ | ✅ | Both encrypt ballots end-to-end |
| P2 Running tally | ✅ | ✅ | Tally hidden until close |
| P3 Receipt-freeness | ✅ Strong | ✅ Strongest | MACI: key-change breaks coercer proof; DAVINCI: stealth overwrite makes receipts unverifiable |
| P4 Coercion resistance | ⚠️ Partial | ✅ Strong | MACI key-change requires knowing you're being coerced; DAVINCI overwrite is post-hoc |
| P5 Universal verifiability | ✅ | ✅ | Both produce verifiable tally proofs |
| P6 Individual verifiability | ✅ | ✅ | Both; MACI V3 also confirms ballot inclusion |
| P7 Coordinator trust | ⚠️ MACI-class | ✅ Lower | MACI coordinator sees decrypted votes (unlinked to identity); DAVINCI coordinator sees re-randomized ballots only |
| P8 Prover-side burden | ❌ HIGH | ❌ HIGH | MACI: voter browser must run ECDH key derivation + re-encryption ZK circuit. DAVINCI similar. These are 5–30s operations on mobile. |
| P9 Deployment maturity | ✅ High | ⚠️ Low | MACI V3 is PSE-maintained, audited, used by Gitcoin QF rounds. DAVINCI is pre-mainnet. |
| P10 Integration lift | ❌ HIGH | ❌ HIGH | Umbra must become a front-end to a completely different contract/protocol. The existing Aztec Noir contracts are either replaced or wrapped. The receipt + facilitator layer can survive, but the ballot path is completely new. |
| P11 L1 data leak | ✅ | ✅ | Both keep choices off L1 |
| P12 Liveness dependency | ⚠️ Medium | ❌ High | MACI: coordinator server must stay live. DAVINCI: Vocdoni rollup must be running. Both have external dependencies outside Umbra's control. |

**On the integration lift:** The ROADMAP frames C as "keep Umbra as the
facilitator/receipt/ops layer." This is architecturally correct but soft-pedals
the work. Wrapping MACI V3 means:

- Replacing `cast_vote` (Aztec Noir private function) with a MACI ballot
  submission call (Ethereum MACI contract, different key derivation)
- Replacing the Aztec Merkle eligibility proof with MACI's signup process
- The receipt fingerprint changes semantics: the MACI "state index" is not a
  nullifier in the Aztec sense
- The existing `VoteReceipt`, `useVerifyReceipt` hook, and `verify_vote_counted`
  contract function need complete replacement

This is not a "wrapper" — it is a partial rebuild. It may be the right call, but
the planning session should go in with eyes open.

---

## 6. Property comparison table

| Property | A (Aztec-native) | B (Timelock) | C1 (MACI V3) | C2 (DAVINCI) |
|---------|-----------------|-------------|--------------|--------------|
| P1 Ballot secrecy | ✅ | ✅ during / ❌ after | ✅ | ✅ |
| P2 Running tally | ✅ | ✅ | ✅ | ✅ |
| P3 Receipt-freeness | ⚠️ Partial | ❌ None | ✅ | ✅ Best |
| P4 Coercion resistance | ⚠️ Partial | ❌ None | ⚠️ Partial | ✅ |
| P5 Universal verifiability | ⚠️ Coord-dep | ✅ | ✅ | ✅ |
| P6 Individual verifiability | ✅ | ✅ | ✅ | ✅ |
| P7 Coordinator trust | ❌ HIGH | ✅ Low | ⚠️ MACI-class | ✅ Low |
| P8 Prover-side burden | ✅ Low | ✅ Low | ❌ HIGH | ❌ HIGH |
| P9 Deployment maturity | ✅ | ❌ | ✅ | ❌ |
| P10 Integration lift | ✅ Low | ⚠️ Medium | ❌ HIGH | ❌ HIGH |
| P11 L1 data leak | ✅ None | ❌ Post-deadline | ✅ None | ✅ None |
| P12 Liveness dependency | ✅ Low | ❌ High | ⚠️ Medium | ❌ High |
| **Total ✅** | **8** | **5** | **7** | **8** |
| **Total ❌** | **1** | **4** | **2** | **2** |

---

## 7. UX and HCI implications

This is where the architectures diverge beyond protocol scorecard, and where
Umbra's actual research contribution lives.

**Architecture A** preserves the existing receipt semantics. The vote fingerprint
(nullifier) continues to work: `verify_vote_counted(nullifier) → bool` still
answers "was this ballot counted?" The receipt copy must change — "your choice
is private until the coordinator decrypts" is an L2a claim (running tally privacy),
distinct from receipt-freeness. But the receipt UX design from `docs/receipt-design.md`
survives almost intact.

**Architecture B** breaks the receipt UX entirely. If all choices become public
post-deadline, "this fingerprint proves your vote was counted without revealing
your choice" is false after the decryption key releases. The receipt would need a
timed disclaimer: "Until [deadline], your choice is private." This is a poor UX
pattern — the voter's privacy posture changes without them doing anything. A
managed service cannot stand behind a receipt that expires.

**Architecture C** (either sub-option) breaks the receipt semantics differently:
MACI's nullifier is a state index, not an Aztec note commitment. The voter's
evidence of inclusion is a MACI state root membership proof, not a compact hex
fingerprint. Re-designing the receipt for a MACI or DAVINCI back-end requires
re-doing most of `docs/receipt-design.md` — not a cosmetic change.

**HCI read:** Architecture A is the only one where the existing receipt design
survives without fundamental rework. If the HCI contribution is the receipt —
and per `docs/receipt-design.md` it is — then Architecture A lets M3 proceed
quickly, while C requires rethinking the UX research artifact from scratch.

---

## 8. Grant positioning implications

The GRANT.md grant claim is:
> "The only private DAO voting tool designed explicitly for the Aztec identity+privacy
> stack, composable with ZKPassport for nationality/compliance gates."

Architecture A strengthens this claim — it is built deeper into Aztec's private
state model than any existing alternative. The ZKPassport composability angle
(Aztec Labs' in-house acquisition) applies cleanly.

Architecture C (MACI) moves the contract logic to Ethereum L1, weakening the
Aztec-native story and breaking the ZKPassport composability claim. This is a
real strategic cost.

Architecture B is hard to position at all ("uses drand for tally privacy" is
less compelling than "Aztec private notes").

---

## 9. Recommendation

**Architecture A (Aztec-native encrypted ballots), with explicit scoping.**

Rationale:
1. Achieves L2a (running tally privacy) cleanly with low integration lift.
2. Preserves existing receipt UX — the HCI research artifact survives.
3. Maintains Aztec-native grant positioning + ZKPassport composability.
4. Avoids external liveness dependencies.
5. The partial receipt-freeness (P3 ⚠️) is honestly scoped: claim "choice
   private during vote window; coordinator cannot link identity to ballot post-close"
   — this is a real improvement on any existing DAO tool.

**What A does NOT deliver (be explicit in claims):**
- Full receipt-freeness: a voter can still prove their choice to a coercer by
  showing their note decryption key. Do not use the word "coercion-resistant"
  until a re-encryption mix is added.
- Coordinator-free trust: the tallier role must be run by a trusted party.
  Umbra can run this as part of the managed service model — coordinator trust
  is the *product* (the facilitator role is the thing being sold), not a flaw.
  Frame it honestly: "facilitator-operated tally, same trust model as any DAO
  multisig."

**Re: Architecture C as a future path:**
If Umbra ever needs full receipt-freeness (L2b), the correct path is C1 (MACI V3)
not C2 (DAVINCI, pre-mainnet). But this is a planning-session call after M2a
ships. Do not build it now.

---

## 10. Decision gate

| Decision | Options | Recommended |
|---------|---------|------------|
| M2 architecture | A, B, or C | **A** |
| Receipt-freeness claim | Full / Partial / None | **Partial** — "choice private during window" |
| Coordinator trust model | Fully trusted / MACI-class / Protocol-adapter | **Facilitator-operated tallier** (honest framing of A) |
| C1 as future option | Yes / No | **Yes — revisit after M2a ships** |

This document is for the planning session. The execution agent will implement
whichever architecture Jony selects and explicitly signs off on.

---

_End of design spike. See `docs/m2-secp256k1-ownership-proof-design.md` for the
parallel M2 Babylon-mode ownership component._
