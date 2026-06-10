# Umbra - Roadmap

Rewritten 2026-06-10 after a full audit, the PSE/Shutter "State of Private Voting 2026"
report (read in full), and the receipt-freeness literature review.

## Positioning

A managed service and UX layer for private onchain DAO governance votes, run by a
facilitator with no cryptographic background, with a receipt artifact that proves a
vote was counted without revealing the choice.

What the PSE report establishes (verified against the report itself):
- Snapshot+Shutter is already a toggle-managed service, but privacy is temporary -
  every individual vote is revealed after close. Not coercion resistant.
- Vocdoni operates a voting SaaS (app.vocdoni.io) aimed at off-chain organisations;
  DAVINCI (its onchain protocol) is pre-mainnet.
- MACI V3 is the mature full-anonymity option but rates "Low" on ease of
  integration/deployment and requires a self-run trusted coordinator.
- Enclave (CRISP), Kite, Cicada, Aragon/Aztec, Shutter Permanent are all
  low-maturity / not shipped.
- Report Future Work #4: plug-and-play private voting modules for DAO tooling do
  not exist. #6: demand from DAOs is not yet strong - demand generation is part
  of the product problem, not a given.

The defensible gap: a managed service for PERMANENT-anonymity onchain DAO
governance with facilitator and receipt UX. Do not claim more than this.

## The privacy ladder

Be explicit about which rung we are on. Claims in docs, UI copy, and the grant must
match the current rung, never the target rung.

- L0 (before 2026-06-10): vote_choice was a public argument of record_vote AND the
  nullifier was poseidon2(voteId, walletAddress) - computable by anyone who knows a
  wallet address. Wallet -> choice was linkable. The "only the tally is revealed"
  claim was false.
- L1 (current, after the nullifier fix): anonymous plaintext ballot. The uniqueness
  nullifier is derived in-circuit from the caller's nullifier secret key, so no
  observer can link a wallet to a ballot. Per-ballot choices are still publicly
  visible (unlinkable), and the running tally is public. This is the same privacy
  class as Freedom Tool in the PSE report: Private Vote yes, Running Tally Privacy
  no, Coercion Resistance no. IMPORTANT: the vote fingerprint indexes into a public
  transaction whose args include the choice - a voter who shares their fingerprint
  reveals their choice. The receipt must be treated as private by the voter until L2.
- L2 (target): encrypted ballots, hidden running tally, receipt-freeness. The
  fingerprint becomes safe to show to anyone.

## Milestones

### M0 - Privacy honesty (done in working tree, 2026-06-10)
- In-circuit nullifier derivation from the wallet's nullifier secret key.
- Synthetic eligibility set replaces the live Babylon holder snapshot.
- UI copy, docs, STRATEGY.md corrected to L1 claims.

### M1 - Real demo against testnet (D1)
The demo must do what it claims before anyone sees it.
- Re-deploy PrivateVoting (with cast_vote_babylon) to Aztec testnet; update
  deployments/alpha-testnet.json.
- Wire real browser proving (@noir-lang/noir_js + @aztec/bb.js) replacing the
  simulated 3s delay in demo/pages/babylon.tsx.
- Keplr/Leap wallet connection (currently stubbed).
- Merkle path served from the snapshot (static hosting is fine for synthetic data).
- E2E suite green with E2E_TESTNET_READY=1.
- Fix packages/react typecheck (missing test type deps).

### M2 - Tally privacy design spike (the L2 decision)
Write an openspec proposal comparing, against the PSE report's 26-property rubric:
  (a) Aztec-native: ballots as encrypted notes to a tallier role; tallier decrypts
      and posts the tally with a correctness proof. MACI-class trust (tallier sees
      ballots); receipt-freeness via key-change or ballot re-randomization.
  (b) Timelock encryption (Aragon/Aztec PoC lineage; drand/timelock.zone
      dependency; report rates the approach low-maturity but architecturally clean -
      note it gives running-tally privacy but NOT receipt-freeness by itself).
  (c) Protocol adapter: run the cryptographic layer on MACI V3 or DAVINCI and keep
      Umbra purely as the facilitator/receipt/ops layer (consistent with the
      protocol-agnostic strategy; fastest path to honest receipt-freeness claims -
      DAVINCI's re-randomization + stealth overwrite is the strongest per the report).
Also in M2 scope: Babylon-mode ownership. The current cast_vote_babylon nullifier
derives from public snapshot data (address + balance), so snapshot holders'
participation is checkable. A real deployment needs an in-circuit Cosmos
secp256k1 signature proving address ownership, with a holder-secret-derived
nullifier.

Decision gate: pick one. Do not use the words "receipt-free" or "coercion" in any
user-facing artifact until the chosen design ships.

### M3 - Facilitator product
- Six-step vote configuration flow against the real contract.
- Vote lifecycle operations: create, monitor quorum, finalize, publish a
  verification artifact (tally + how to check it).
- Public receipt verification page (enter fingerprint, see counted/not-counted).

### M4 - Horizon and grant
Horizon (github.com/AztecProtocol/horizon) is Aztec's PRD launchpad, not a product:
it contains a "Private Voting Module for DAOs" PRD and expects projects built from
the Wonderland Aztec Boilerplate, contributed back as community implementations.
- Map Umbra against the Horizon private-voting PRD; document deltas.
- Align repo conventions with the boilerplate where cheap.
- Submit Umbra to Horizon's projects as a reference implementation; use this as
  grant evidence (GRANT.md already references the Horizon PRD).

### M5 - Pilot (demand generation)
Per report Future Work #6, demand must be manufactured, not assumed.
- Identify 20-30 DAOs with contested votes (close margins / low turnout on
  Snapshot or Tally).
- Offer one concierge-run private vote (Umbra as operator).
- Success metric: one completed contested vote with a published verification
  artifact and a facilitator who is not us.

## Done
| Feature | Date |
|---------|------|
| Noir contract (main.nr, eligibility.nr) | 2026-04-30 |
| Voter flow (APV-01-11), facilitator flow (APV-12-18) | 2026-04-30 |
| Test suite (37 unit + contract + e2e) | 2026-04-30 |
| Testnet deploy (pre-Babylon entrypoint) | 2026-05-18 |
| v5 nightly port | 2026-05-25 |
| Babylon Merkle eligibility circuit + demo | 2026-06-10 |
| Synthetic eligibility set (no real holder data) | 2026-06-10 |
| Docs set v1 (index, receipt, components, integration) | 2026-06-10 |
| In-circuit nullifier derivation (L1 privacy) | 2026-06-10 |

## Key context
- Aztec Wave 3 grant: $25K target. GRANT.md needs a claims pass to match the
  privacy ladder (it still implies stronger properties than L1).
- Deployed testnet contract (pre-Babylon): deployments/alpha-testnet.json.
- The umbra-babylon-demo.vercel.app deployment is being taken down; redeploy from
  demo/ after M1.
