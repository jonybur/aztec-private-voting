# F2 atomicity analysis — does a public-half revert consume the private nullifier?

_Author: Jony Bursztyn · 2026-06-22_  
_Follow-up to: `docs/security-review-2026-06-22.md`_  
_Scope: open path (`cast_vote`) and Babylon path (`cast_vote_babylon`)_

---

## The question

The security review (tick-3597) identified F2 — receipt-collision vote-blocking — and marked it as
the single most important thing to verify on testnet:

> **If a public-half revert in `record_vote` consumes the private `vote_claims` nullifier →
> F2 is HIGH and the receipt guard must be redesigned before the grant demo. If not → F2 is LOW
> and F1 becomes the headline.**

This document analyses the question from the contract structure and Aztec's execution model,
identifies the boundary between the two paths, and provides a targeted testnet verification plan.

---

## Aztec's private-public atomicity

In Aztec v5, a transaction that mixes private and public execution is **atomic**. Private
execution runs off-chain in the PXE and produces:
- a proof of correct private execution,
- a set of *pending* side effects: nullifier insertions, note commitments, and enqueued public calls.

These pending side effects are **not committed to state until the sequencer finalises the full
transaction**, including all enqueued public calls. If any enqueued public call reverts, the
entire transaction fails: no nullifiers are inserted, no notes are committed. This is analogous to
Ethereum's transaction atomicity — a revert in an inner call rolls back all state in the tx.

This is the key property. Whether F2 is permanent depends on whether the victim can retry.

---

## Open path (`cast_vote`)

```nr
fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    self.storage.vote_claims.at(self.msg_sender()).claim();   // (1) private: nullifier queued
    self.enqueue_self.record_vote(vote_choice, eligibility_proof, receipt_id);  // (2) public enqueued
}
```

**Attack:** an observer sees a pending tx with `receipt_id = R` and front-runs with the same
`receipt_id`. The victim's `record_vote` reverts with "receipt already used".

**With atomicity:** the revert rolls back the entire victim tx, including the `vote_claims`
nullifier queued at step (1). The nullifier is **not** inserted. The voter's
`SingleUseClaim` is intact — they can submit again with a fresh `receipt_id`.

**Severity update for open path:** F2 open path → **LOW** (retry attack, not permanent blocking).

The attacker can sustain a griefing campaign by front-running every retry, but:
- each retry costs the attacker gas too,
- Aztec's private mempool limits observability of enqueued public call args,
- a receipt_id is 254 bits — the attacker must see it before it lands.

Whether the attacker can reliably observe `receipt_id` before inclusion depends on Aztec v5 mempool
semantics and sequencer visibility. **This is the open testnet question for the open path.**

---

## Babylon path (`cast_vote_babylon`) — different threat model

```nr
fn cast_vote_babylon(
    vote_choice: u8,
    address_bytes: [u8; 45],
    balance: u64,
    merkle_path: [[u8; 32]; 20],
    merkle_indices: [bool; 20],
) {
    // ... Merkle proof verification in-circuit ...
    let holder_nullifier = hash_bytes_as_field(leaf);
    self.enqueue_self.record_vote(vote_choice, 1, holder_nullifier);  // receipt_id = holder_nullifier
}
```

The Babylon path diverges in two ways that change the threat model completely.

### Divergence 1 — no `vote_claims` consumption

The Babylon path does **not** call `self.storage.vote_claims.at(self.msg_sender()).claim()`.
The private half runs a circuit proof of Merkle membership and enqueues `record_vote`.
There is no wallet-keyed nullifier insertion in the private half.

With atomicity: if `record_vote` reverts, the tx fails, but since there was no private nullifier
insertion, the voter's state is identical to before — they can retry. **Good.**

### Divergence 2 — deterministic receipt_id

The receipt_id in the Babylon path is `holder_nullifier = hash_bytes_as_field(leaf)`, where:

```nr
leaf = sha256(address_bytes ++ balance_bytes)   // (simplified; see merkle.nr for exact encoding)
```

Both `address_bytes` (the bech32 Cosmos address) and `balance` (the ubbn snapshot balance) are
**public snapshot data**. The snapshot is committed at vote creation (the Merkle root is stored
in `config.token_address`). Any observer can enumerate all snapshot entries and compute
`holder_nullifier` for every holder.

An attacker with the snapshot can pre-compute every Babylon voter's `receipt_id` before anyone
has voted. If `record_vote` reverts on the victim's tx, the victim can retry — but their
`receipt_id` is **always the same value**, because it is deterministic from public data. If the
attacker has already registered it, every retry fails. **Permanent blocking is real in the
Babylon path**, regardless of atomicity.

**Severity for Babylon path:** F2 Babylon → **HIGH** (permanent blocking of targeted holders,
attacker only needs snapshot data, no mempool observation required).

---

## New finding — unbound caller in Babylon (F2+, HIGH)

The blocking attack above assumes the attacker registers the victim's `holder_nullifier` by
submitting a valid `cast_vote_babylon` for that holder. This is possible because
`cast_vote_babylon` does **not verify that the tx submitter controls the Cosmos address** in
`address_bytes`.

All inputs to the Babylon circuit are computable from the public snapshot:
- `address_bytes` — bech32 address from snapshot
- `balance` — ubbn balance from snapshot
- `merkle_path` + `merkle_indices` — derivable by rebuilding the Merkle tree from the snapshot

There is no signature, no secret, no wallet binding between the tx submitter and the Cosmos
address they claim. The private circuit proves "this (address, balance) pair is a leaf in the
committed Merkle tree" — it does NOT prove "I am the owner of this Cosmos address."

**Consequence:** an attacker can:
1. Enumerate the snapshot.
2. For each holder, compute their leaf, Merkle proof, and `holder_nullifier`.
3. Submit `cast_vote_babylon(vote_choice_of_their_choice, ...)` for each holder.
4. All transactions succeed — the attacker has registered a vote for every snapshot holder.
5. No legitimate holder can vote: their `receipt_id` is already used.
6. The attacker chose the vote direction for every Babylon voter.

This is not a griefing attack. It is **adversarial vote assignment**: full control over every
Babylon holder's ballot without needing any secret the holder controls.

**This is the M2 problem stated explicitly.** The ROADMAP's M2 item — "in-circuit Cosmos
secp256k1 ownership proof with a holder-secret-derived nullifier" — closes exactly this.
Without M2, the Babylon path's vote integrity guarantee depends entirely on the attacker not
acting before voters do (first-writer-wins over a public snapshot).

---

## Revised severity table

| Finding | Path | Prior severity | Revised severity | Reason |
|---------|------|----------------|------------------|--------|
| F1 receipt_id privacy (unenforced) | Open | HIGH | **HIGH** | Unchanged. Client-honesty assumption undocumented. |
| F2 receipt-collision blocking | Open | MEDIUM | **LOW** | Atomicity means nullifier rolls back; victim can retry. |
| F2 receipt-collision blocking | Babylon | MEDIUM | **HIGH** | Deterministic receipt_id; victim can't change it; permanent block possible. |
| F2+ unbound caller | Babylon | (not filed) | **HIGH** | Any attacker can vote on behalf of any holder, choosing their vote direction. |
| F3 did-they-vote leak | Babylon | LOW/INFO | **LOW/INFO** | Unchanged. |

---

## What this means for the grant deliverable

F1 is a design framing issue — worth naming as a trust assumption in the forum post, not a blocker.

F2+ (unbound caller in Babylon) is the headline finding. The grant forum post should acknowledge
this explicitly: the Babylon path demonstrates the problem that M2 solves, not a production-ready
Cosmos voting integration. This is honest and defensible — research code identifying its own trust
boundary is stronger than research code that pretends it doesn't have one.

The framing: "M1 proves private voting is constructible on Aztec. M2 closes the remaining gap:
proving Cosmos address ownership inside the circuit, so no public-snapshot attacker can intercept
a Babylon holder's ballot."

---

## Testnet verification plan

One targeted testnet run confirms the atomicity assumption for the open path. The test scenario:

```
1. Deploy PrivateVoting (open mode, short window).
2. Wallet A casts a vote with receipt_id = R.
   - Intercept the transaction before inclusion (or use a test harness to submit two txs atomically):
     Wallet B submits cast_vote_babylon (or direct record_vote via test helper) with same receipt_id R first.
3. Observe: does Wallet A's tx revert? Does Wallet A's vote_claims nullifier appear in the nullifier tree?
4. If the nullifier is absent → atomicity confirmed, F2 open path = LOW.
5. If the nullifier is present despite the revert → F2 open path = HIGH, receipt guard needs redesign.
```

For the Babylon path, a simpler static check suffices: no testnet required. The unbound-caller
finding is structural — the circuit has no constraint tying `address_bytes` to the tx submitter's
keys. This is visible from the Noir source and does not need a live confirmation.

**Recommended order:**
1. Write the unbound-caller finding into the grant forum post as a named trust assumption (no code change needed).
2. Verify atomicity on testnet for the open path (one deploy + two tx sequence).
3. Start M2 scoping: the Cosmos secp256k1 circuit gadget is the long-pole item.

---

## Relationship to F1

F1 (unenforced receipt privacy) and F2+ (unbound caller) are separate bugs that interact badly.
F1's attack is: a client derives `receipt_id` from wallet material, leaking identity via the
public `receipts` map. F2+'s attack is: a third party registers a holder's ballot first.

If both are exploited together: the attacker registers the victim's ballot with an
attacker-controlled `receipt_id` derived from attacker material, then shares that receipt_id with
the victim as "your vote fingerprint." The victim checks it, sees it verified, and believes their
vote was counted — but the attacker chose the direction and the receipt traces back to the attacker.

This combined attack does not apply to the current Babylon path (because the Babylon receipt_id is
`holder_nullifier`, not a caller-supplied value). But it is worth noting as a design constraint
for any future path that combines caller-supplied receipts with a public membership set.

---

_Next step: add trust-assumption language to the grant forum post draft
(`drafts/aztec-grant-forum-post.md`). The testnet atomicity check can run alongside the contract
deploy in the grant submission flow._

---

## Amendment — Atomicity confirmed from v5 source code (tick-4484, 2026-07-02)

**Status: open testnet question CLOSED. F2 open path = LOW (confirmed).**

The testnet atomicity question — "does a public-half revert consume the private nullifier?" —
has been resolved by inspecting the Aztec v5.0.0-rc.1 simulator source directly.

### Source evidence

File: `yarn-project/simulator/src/public/public_tx_simulator/public_tx_simulator.ts`
(commit tag: `v5.0.0-rc.1`)

The simulator executes transactions in this order:

```
1. insertNonRevertiblesFromPrivate(context)   ← always committed
2. SETUP phase                                ← always committed (or tx thrown out)
   ⬇ fork state
3. insertRevertiblesFromPrivate(context)      ← inside fork
4. APP_LOGIC phase (record_vote)              ← inside fork
   if APP_LOGIC reverts:
     discardForkedState()                     ← rolls back steps 3 + 4
   else:
     mergeForkedState()                       ← commits steps 3 + 4
5. TEARDOWN phase
```

The `SingleUseClaim` nullifier from `vote_claims.at(msg_sender()).claim()` is emitted in
`cast_vote` — a private app-logic function. Private app-logic nullifiers go into
`tx.revertibleAccumulatedDataFromPrivate.nullifiers` (as opposed to
`nonRevertibleAccumulatedDataFromPrivate`, which holds fee-payment and setup nullifiers).

Revertible private nullifiers are inserted at step 3, inside the fork. When `record_vote`
reverts (step 4), `discardForkedState()` rolls back both steps 3 and 4. The
`SingleUseClaim` nullifier is **not** inserted into the nullifier tree.

### Conclusion

**F2 open path: LOW (confirmed).** If `record_vote` reverts (e.g., "receipt already used"),
the `cast_vote` transaction fails atomically: the `vote_claims` nullifier is rolled back,
and the voter retains their single-use claim. They can resubmit with a fresh `receipt_id`.

The griefing attack (attacker front-runs with the same `receipt_id`) remains possible but:
- Has low impact: the victim can retry at a gas cost.
- Requires the attacker to be eligible (or be a compromised sequencer).
- Cannot permanently block a voter — they can always change their `receipt_id`.

**Scope note:** This amendment covers `cast_vote` and `cast_vote_token` / `cast_vote_allowlist`
(generic paths). The Babylon path (`cast_vote_babylon`) is unaffected — its F2+ HIGH finding
stands on different grounds (deterministic `holder_nullifier` not under the voter's control).

**No code change needed.** The F2 LOW rating was correct; this amendment provides the source
evidence that was previously missing.

See also: `docs/security-review-2026-06-22.md` §8 summary table.
