# Umbra

Umbra is private ballot infrastructure for DAOs: a React component library (`@aztec-private-voting/react`) and an Aztec Noir contract (`PrivateVoting`) for running secret-ballot votes where only the aggregate tally is meant to be revealed. After casting a ballot, the voter receives a receipt built around a "vote fingerprint" - an artifact that proves their vote was recorded and counted, never how they voted. The receipt UX is the project's research contribution; the cryptography is standard Aztec/Noir.

## Architecture

```
React app
  <VoteEligibilityProof /> -> <PrivateBallot /> -> <VoteReceipt /> -> <VoteResult />
  <VoteAdmin /> / <VoteFacilitator />            (facilitator side)
        |
  hooks (useEligibility, useVote, useTally, useVerifyReceipt, ...)
        |
  aztec wiring (AztecProvider, loadVotingContract, @aztec/aztec.js)
        |
  PrivateVoting contract (Noir, Aztec Alpha testnet)
```

The components are thin views over hooks; the hooks talk to the contract through `@aztec/aztec.js` (pinned to `0.85.0-alpha-testnet.11`). The contract artifact is not bundled - the integrator compiles it (`npm run build:contracts`) and registers it once at startup with `setPrivateVotingArtifact`.

### The private/public split of cast_vote

`cast_vote(vote_choice, eligibility_proof, receipt_id)` is the contract's private entrypoint. It consumes a private single-use claim per wallet (the double-vote guard, unlinkable to the wallet by observers) and enqueues the public function `record_vote`, which validates timing, eligibility and receipt uniqueness, then increments the per-option counter and the vote count. `finalize_vote` can be called by anyone after the deadline once quorum is met; `verify_vote_counted(receipt_id)` is a public view that returns whether a given fingerprint is in the set of counted votes.

An important consequence of the current design: because `record_vote` is a public function, its arguments - including the vote choice - are part of public execution, and the running tally lives in public storage. The "only the final tally is revealed" property is enforced at the application layer (the `get_final_tally` view refuses to answer before finalization), not against an observer who inspects public execution directly. See [receipt.md](receipt.md) for the full threat model.

## What is built today

- The `PrivateVoting` Noir contract, compiled with nargo `v4.3.0-nightly.20260429` and deployed to Aztec Alpha testnet on 2026-05-18 at `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981` (see `deployments/alpha-testnet.json`).
- Six React components and seven hooks covering the full flow: eligibility, ballot, receipt, result/verifier, vote deployment, and a facilitator dashboard.
- A Next.js demo app (`demo/`) with active-vote, closed-vote and admin pages, plus three test suites (Vitest, nargo, Playwright).

## What is not built yet

- Browser proof generation is not wired in the demo. `useEligibility` returns a placeholder field (for example `0x01` in open mode) rather than a real ZK eligibility proof; the contract's `verify_eligibility` checks that field, not a proof generated in the browser.
- The vote choice is currently visible in public execution (see above). An end-to-end private tally (encrypted or note-based) is not implemented.
- The fingerprint is a client-generated random field element (`Fr.random()`), so it is not derivable from a wallet address by an observer. The double-vote guard is a separate private single-use claim keyed to the caller's keys inside the private kernel. However, the fingerprint travels with the vote choice as a public argument to `record_vote` — so a voter who shares their fingerprint lets that third party look up the corresponding public call and read the choice. The fingerprint must be kept private by the voter until the tally is revealed (see [receipt.md](receipt.md) limitation (e)).
- No managed service exists. Umbra today is a library and a demo, not a hosted product. The longer-term direction is a managed service for permanent-anonymity onchain DAO governance voting with facilitator and receipt UX; nothing of that service is built.
- Aztec Alpha v4 has a known vulnerability (disclosed March 2026, patch expected with v5). The testnet deployment is for demonstration only; do not use it for production governance.

## Documentation

- [receipt.md](receipt.md) - what the vote fingerprint is, what the receipt proves and deliberately does not prove, the threat model, and known limitations.
- [components.md](components.md) - API reference for every exported component and hook.
- [integration.md](integration.md) - installing the library, provider setup, wiring a vote against the testnet contract, environment variables, and current gaps.
- [receipt-design.md](receipt-design.md) - the original receipt UX design rationale (copy decisions, related work, open questions).
- [testing.md](testing.md) - how to run the three test suites.
- [deployment.md](deployment.md) - testnet deployment run book.
