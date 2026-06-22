# Security & Privacy Review — PrivateVoting contract

_Reviewer: Von Neumann · 2026-06-22 · scope: `contracts/src/main.nr` (+ eligibility/merkle context)_
_Status: review notes for Jony. Not a fix. Findings ranked by severity._

This is the kind of high-stakes, judgment-heavy review that doesn't reduce to a
ticket — it's a read of the trust model, not a lint. Three findings worth your
name on; one is a genuine design defect, not just a doc nit.

---

## F1 — [HIGH, privacy] `receipt_id` privacy invariant is unenforced by the contract

**Where:** `cast_vote` → `record_vote`, open (non-Babylon) path.

**The claim in the code:**
> "The receipt_id is a client-generated random field used only for the receipt
> check; it must not be derived from the wallet."

**The problem:** nothing in the contract enforces this. `record_vote` accepts any
`Field` as `receipt_id`, checks only that it hasn't been used, and writes it to a
**public** map (`receipts: Map<Field, PublicMutable<bool>>`). The entire ballot
privacy guarantee of the open path rests on a property the contract cannot see
and does not check.

**Attack / failure mode:** a buggy, forked, or malicious client sets
`receipt_id = hash(wallet_address)` (or any wallet-linked value). Every assertion
still passes; the vote counts; the receipt verifies. But now the public
`receipts` map contains a wallet-linkable entry, silently de-anonymising the
voter. The protocol nullifier (in `vote_claims`) is safe — but the receipt is the
leak, and it's the one piece the *user* is told to share to prove their vote
counted (`verify_vote_counted`). So the documented "prove it counted without
proving how you voted" guarantee can be broken by the client without anyone
on-chain noticing.

**Why it matters for the design thesis:** the receipt is explicitly "the product"
(README). A privacy guarantee whose enforcement lives in a code comment is not a
guarantee — it's a convention. For research code that's defensible; for a grant
deliverable it should be named as an explicit trust assumption.

**Options (ranked):**
1. Best: bind receipt_id to something the circuit controls — e.g. derive it
   in-circuit from a voter-chosen secret (not the wallet), so the contract's
   privacy doesn't depend on client honesty.
2. Cheaper: document it as a first-class **trust assumption** in
   `receipt-design.md` ("receipt privacy assumes an honest client RNG"), and make
   the reference client's RNG path auditable/tested.
3. Minimum: a `cast_vote`-level comment is not enough — at least add a test that
   asserts the reference client never derives receipt_id from wallet material.

---

## F2 — [MEDIUM, liveness] Receipt-collision vote-blocking (griefing)

**Where:** `record_vote` — `assert(already_used == false, "receipt already used")`.

**Open path:** receipt_ids are client-random 254-bit Fields, so accidental
collision is negligible. But the assertion means *whoever lands a given
receipt_id first wins it*. An adversary who can see a victim's pending receipt_id
(mempool / enqueued public call args are visible) can front-run with the same
receipt_id and make the victim's `record_vote` revert. The victim has already
burned their single-use `vote_claims` nullifier in the private half → **they can
be permanently blocked from voting** while appearing (to themselves) to have
tried.

**Babylon path is worse here:** `receipt_id = holder_nullifier =
hash_bytes_as_field(leaf)`, and the leaf is computed from **public snapshot data**
(address + balance). So the receipt_id is *deterministic and predictable* for
every snapshot entry. An adversary with the snapshot can pre-compute every
holder's receipt_id and pre-claim them, blocking targeted holders from voting —
without needing to see any mempool.

**Severity caveat:** depends on Aztec's enqueued-call visibility and whether the
private claim is consumed before the public revert. Worth confirming against v5
semantics — if the claim is *not* consumed on public revert, F2 drops to LOW.
**This is the single most important thing to verify on testnet.**

**Fix direction:** separate the double-vote guard (nullifier, already present and
correct) from the receipt guard. The receipt check shouldn't be able to revert a
vote whose eligibility + nullifier already passed. Consider recording the receipt
idempotently rather than asserting uniqueness, or derive the receipt so it can't
be pre-claimed by a third party.

---

## F3 — [LOW/INFO, privacy, already documented] Babylon "did-they-vote" leak

The code already names this:
> "the leaf is computed from public snapshot data ... an observer with the
> snapshot can tell WHETHER a holder voted."

Correctly identified, correctly deferred to M2. Elevating it here only because
it's the actual research contribution: closing it needs an **in-circuit Cosmos
secp256k1 ownership proof** with a holder-secret-derived nullifier, so the
nullifier no longer correlates to public snapshot data. That's the defensible,
AI-can't-do-this-for-you piece — and it's a clean Thursday Talk / working-notes
write-up: "the anonymity set of a token-gated private vote is bounded by your
snapshot, not your crypto."

---

## Non-findings (checked, OK)

- **Double-vote prevention (open path):** `SingleUseClaim` per wallet, nullifier
  derived in the private kernel from caller keys — sound, not observer-linkable.
- **Timing / finalization:** `start<end`, `now>=start`, `now<end`, finalize
  requires `now>=end` + quorum + not-already-finalized. Consistent.
- **Option bounds:** `vote_choice < options_count`, `options_count` in `[2,8]`.
- **`get_final_tally` gated on `is_finalized`** — no early tally leak via view.

---

## Recommended next action (smallest, highest-value)

Verify F2 on v5 testnet: does a public-half revert in `record_vote` consume the
private `vote_claims` nullifier? If yes → F2 is HIGH and the receipt guard must be
redesigned before the grant demo. If no → F2 is LOW and F1 becomes the headline.
One targeted testnet run answers it. Everything else here is design framing.
