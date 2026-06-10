# The receipt

The receipt is what the voter sees after casting a private ballot. It has one claim to make: your vote was counted, and nothing in the receipt reveals how you voted. This page covers what the receipt is, what it proves, what it deliberately does not prove, how verification works, and the threat model. The original design rationale (copy decisions, usability reasoning, related work) is in [receipt-design.md](receipt-design.md).

## What the receipt is

The receipt is a proof-of-inclusion artifact. It lets the voter check two things after the vote closes:

- **Recorded as cast** - the ballot transaction landed onchain (the receipt carries the transaction hash).
- **Tallied as recorded** - the vote fingerprint appears in the contract's set of counted votes (`verify_vote_counted` returns true).

It is rendered by `<VoteReceipt />` and persisted by download as a JSON file:

```json
{
  "version": 1,
  "kind": "aztec-private-voting-receipt",
  "voteId": "...",
  "voteTitle": "...",
  "receiptId": "0x...",
  "txHash": "0x...",
  "timestamp": 1714238400000,
  "contractAddress": "0x..."
}
```

The file contains no vote choice and no wallet address. It is stored only on the voter's device; the system keeps no copy.

## The vote fingerprint

The value at the center of the receipt is a receipt id. In all user-facing copy it is called the **vote fingerprint**.

In the current implementation the fingerprint is a client-generated random field element (`packages/react/src/aztec/receipt-id.ts`). It carries no information about the voter: it is not derived from the wallet, the vote id, or the choice. Double voting is prevented separately, by a private single-use claim inside the proof (`vote_claims` in the contract) whose protocol nullifier is derived from the caller's keys in the private kernel - so no observer can link a wallet to a ballot, and the fingerprint does not need to be deterministic.

## What the receipt proves, and what it does not

Proves:

- A ballot was accepted by the contract (transaction hash).
- That ballot was counted exactly once (the fingerprint is in the counted set, and the contract rejects duplicates at submission).

Deliberately does not prove:

- **Which option was chosen.** The receipt never binds to the vote choice. This is the design's one-sentence claim: the fingerprint proves your vote was counted, never how you voted. If the receipt contained the choice, anyone who could obtain the receipt - an employer, a counterparty, a vote buyer - would learn the vote. The voter remembers their own choice; the system remembers the tally; the receipt connects the two through inclusion only.
- **Who the voter is.** The receipt JSON contains no address. (But see limitation (d) below: the fingerprint is computable from the address.)

The receipt is not a coercion-resistance mechanism and the documentation does not claim coercion resistance. See the threat model.

## Verification flow

Verification is a public view function on the contract: `verify_vote_counted(receipt_id) -> bool`. The React side exposes it through `useVerifyReceipt`:

```tsx
import { useVerifyReceipt } from '@aztec-private-voting/react';

const { verify, status, result, error } = useVerifyReceipt(config);
await verify('0x...'); // the fingerprint from the receipt
// result: true  -> counted
// result: false -> not found in the counted set
```

`<VoteResult />` includes a built-in verifier panel (toggle "Verify your vote was counted") that does exactly this: paste the fingerprint, get a yes or no. The check reveals nothing about the choice - it only reads membership in the counted set.

The receipt UI keeps "How to verify" collapsed by default and tells the voter three things: save the receipt now (it is only stored on your device), come back when the vote closes, paste the fingerprint into the verifier.

## Threat model

What the receipt does and does not defend against, stated explicitly:

**(a) The receipt never binds to the vote choice.** Nothing in the receipt JSON, the fingerprint derivation, or the verification flow involves the chosen option. Showing someone your receipt shows them that you voted, not how.

**(b) Receipt-freeness is conditional.** The receipt itself cannot be used to prove a choice, but receipt-freeness holds only if the voter cannot extract some other witness linking the receipt to the choice (for example, transaction-level data their own client produced, or replaying the proving inputs). We have not proven that no such witness is extractable in the current stack.

**(c) Coercion resistance is out of scope.** Attacks such as key sale (handing a coercer the wallet) and forced abstention (a coercer preventing the vote entirely) are not addressed. This is consistent with MACI's positioning: for token-based, pseudonymous eligibility, receipt-freeness - not full coercion resistance - is the realistic ceiling. A coercer who controls the key or observes the voting session controls the vote.

**(d) Participation is not checkable from public data.** The fingerprint is random and the double-vote guard is a private single-use claim derived from the caller's keys, so an observer who knows a wallet address cannot determine whether that wallet voted. (Exception: the Babylon demo entrypoint derives its per-holder nullifier from public snapshot data, so snapshot holders' participation is checkable there - see ROADMAP.md M2 for the ownership-proof fix.)

**(e) The current contract tallies in public state.** The private `cast_vote` enqueues the public `record_vote(vote_choice, eligibility_proof, receipt_id)`, so the choice and the fingerprint travel together as arguments to a public call and the running tally lives in public storage. Ballots are anonymous (nothing links them to a wallet) but their choices are plaintext. The practical consequence for the receipt: a voter who SHOWS their fingerprint to a third party lets that party find the transaction and read the choice. Until the encrypted tally ships (ROADMAP.md M2), the fingerprint must be treated by the voter as private, and the receipt UI says so.

## Known limitations

Condensed from the open questions in receipt-design.md, plus implementation realities:

- **Receipt loss.** The fingerprint is random and exists only in the receipt file; a voter who loses it cannot recompute it and falls back to trusting the public tally. Key-derived regeneration has tradeoffs (it also gives a coercer a regeneration path) and is deliberately not implemented.
- **Concurrent observation.** The choice exists briefly in browser memory during voting. Someone watching the screen or the session sees it. The receipt design addresses what the artifact reveals after the fact; it does nothing about observation during the vote.
- **Verification is bound to the contract address.** If the contract is migrated or upgraded, old receipts can no longer be verified against the new instance.
- **Unmeasured verification behavior.** Whether voters actually return to verify is untested. If most never do, the receipt's value is largely psychological.
- **Copy and accessibility testing.** The "fingerprint" metaphor and the privacy claim have only been through internal review, not comprehension testing at scale; screen-reader behavior on the hex value is untested in depth.
