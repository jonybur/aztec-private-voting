# Aztec Grants Wave 3 — Application

**Project:** Aztec Private Voting  
**Repo:** github.com/jonybur-oc/aztec-private-voting  
**Asking:** $25,000  
**Category:** Tooling + HCI research

---

## What this is

Private ballot infrastructure for DAOs. A Noir contract + four React components that handle the full voter lifecycle: eligibility proof, ballot submission, receipt, result verification, and facilitator tooling.

## The differentiator

The receipt.

Every existing private voting system — MACI, Shutter, the NounsDAO Aztec experiment — hands the voter a hex string or a "your vote was recorded" toast. Neither communicates what actually happened. The voter is left with either blind trust or a transaction hash they can't act on.

We treated the receipt as the product.

After a voter casts a private ballot, they get a `<VoteReceipt />` component built around one design principle: prove the vote was counted without proving how the voter voted. The receipt uses a "vote fingerprint" (the nullifier, renamed for comprehension), download-by-default persistence, a collapsed verification explainer, and copy written to avoid the words "cryptographic," "zero-knowledge," and "nullifier."

The full design rationale — including the specific copy decisions, the alternatives we rejected, and the open problems we did not solve — is in [`docs/receipt-design.md`](docs/receipt-design.md). This is the research contribution nobody else has made. The Noir contract and React components are table stakes for the category; the receipt design is what makes private voting legible to non-technical DAO participants.

---

## Technical state

**Implementation complete.** All Noir contracts + React components are merged and tested.

| Layer | Status |
|---|---|
| `PrivateVoting.nr` — Noir contract (Aztec-NR **v5.0.0-rc.1**) | ✅ merged + compiled |
| `@aztec-private-voting/react` — component library | ✅ merged |
| Playwright + Noir unit tests (41 user stories) | ✅ merged |
| Aztec-NR v5 port | ✅ confirmed (zero code changes) |
| Alpha testnet deployment | ⚠️ **Redeploying to v5** (state reset Jun 18) |
| BABY token Merkle governance demo (Babylon team) | ✅ **LIVE** |

The contracts compile cleanly against **Aztec-NR v5.0.0-rc.1** (released June 15, 2026 — first testnet RC). Zero contract code changes were required across any version from v4.3 to v5.0.0-rc.1. All import paths, function attribute macros, state variables, and trait derives are identical. The Aztec team disclosed a critical vulnerability in Alpha v4 in March 2026; we are already on v5.

**v5 testnet upgrade complete (Jun 18 2026):** New endpoint `https://v5.testnet.rpc.aztec-labs.com` is live. The upgrade included a testnet state reset — the v4 contract `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981` (deployed 2026-05-18) is no longer accessible. Redeployment to v5 is in progress; the contract address in this document will be updated before forum submission.

---

## Contracts (PrivateVoting.nr)

```
constructor(admin, VoteConfig)          public initializer
cast_vote(choice, eligibility_proof, nullifier)  private → enqueues record_vote
record_vote(...)                        public, only_self — validates timing, eligibility, nullifier, increments tally
finalize_vote()                         public, post-deadline, checks quorum
verify_vote_counted(nullifier) -> bool  public view, reads nullifier map
get_vote_count(), get_final_tally(idx), is_finalized(), get_config()  public views
```

Eligibility modes: open (anyone), token-gated (balance proof), allowlist (merkle witness).

---

## Components

```
<VoteEligibilityProof />   generates a ZK proof of voting rights, silent on happy path
<PrivateBallot />          the vote interface — submits encrypted ballot
<VoteReceipt />            the key piece — plain-language receipt with vote fingerprint
<VoteResult />             tally reveal with verifier for individual fingerprints
<VoteAdmin />              configuration UI for governance facilitators
```

---

## Why Aztec

I was on the team that built zk.money. Aztec's programmable privacy is the right layer — it's the only EVM-adjacent environment where you can genuinely hide vote choice on-chain while keeping tallies public and verifiable.

---

## The live case study

**KelpDAO / rsETH ($71M exploit, Arbitrum governance)**  
A 49-day public vote on politically explosive loss socialization, with state-actor-adjacent threat actors watching every wallet. Voters who can be identified will be pressured. The current governance tooling has no answer for this.

**Babylon: BABY token private governance (live, June 2026)**  
A full private governance demo using actual BABY token holder data. A ZK Merkle membership circuit (Noir, Barretenberg UltraHonk) proves BABY holder eligibility over a live snapshot of 108,637 Babylon Genesis holders — without revealing the voter's address or balance. The entire proof runs in the browser; no server involvement. Live: [umbra-babylon-demo.vercel.app](https://umbra-babylon-demo.vercel.app).

This exercises the Merkle-allowlist eligibility mode end-to-end with real holder data at production scale. It validates the architecture for Cosmos-native governance: snapshot on the source chain, ZK proof on Aztec, no bridging, tokens never move.

**Trust assumption (named — see M2 roadmap below):** The current Babylon path proves *membership* in the snapshot (a holder's (address, balance) pair is a leaf in the committed Merkle tree) but does not prove *ownership* of that Cosmos address. There is no in-circuit secp256k1 signature check binding the tx submitter to the Cosmos keys. A well-resourced attacker with the public snapshot could compute every holder's Merkle proof and submit ballots on their behalf before legitimate holders vote. The Babylon demo is a research prototype demonstrating the problem M2 solves, not a production governance tool. M2 closes this gap: an in-circuit Cosmos secp256k1 ownership proof, with a nullifier derived from a holder-held secret, makes each ballot unforwardable.

---

## Roadmap — M2: in-circuit ownership proof

The single open problem separating M1 (complete) from a production-ready Cosmos voting integration is the in-circuit ownership proof.

**What M2 requires:**
- Voter signs a challenge (vote-specific nonce or contract address) with their Cosmos secp256k1 private key.
- The signature is a private witness passed to `cast_vote_babylon`.
- Noir `std::ec::secp256k1` verifies the signature in-circuit; public key derived from `address_bytes` already passed as a private witness.
- Nullifier derived from the signature (or a holder-held secret), not from the public snapshot leaf — not pre-computable by an observer.

**What this achieves:**
- Attacker with the full snapshot cannot vote on behalf of any holder — they lack the secp256k1 private keys.
- Per-holder nullifier is no longer computable from public data — cannot be front-run.
- Vote direction remains hidden (no change to the existing private/public structure).

**Scope:** The Noir secp256k1 gadget is a ~2-week integration sprint. Main complexity: key derivation from a bech32 Cosmos address to a compressed public key (Cosmos uses secp256k1 with SHA-256 + RIPEMD-160 hashing). Both hash gadgets are available in the Noir standard library. M2 is one focused engineering sprint, not a redesign.

---

## Budget breakdown ($25K)

| Line | Amount |
|---|---|
| Development — Noir contract + 4 React components + test suite (~3 months part-time at fair market rate) | $15,000 |
| Security review / Noir contract audit before v5 production deployment | $8,000 |
| Documentation, demos, ecosystem tooling | $2,000 |
| **Total** | **$25,000** |

This is calibrated as a tooling + research grant. Wave 2 tooling grants ranged $10K–$30K; this project has completed implementation (not speculative), a differentiated HCI research angle, and a working demo. $25K is the correct ask for this tier.

---

## Alignment with Aztec Horizon

This project implements the [Private Voting Module for DAOs PRD](https://github.com/AztecProtocol/Horizon/blob/main/PRDs/Private_Voting_Module_for_DAOs.md) from the Aztec Horizon repository — Aztec's own curated library of ecosystem applications it wants built. The PRD specifies: admin flow, voter flow, eligibility proofs, encrypted ballots, receipts, quorum rules. Aztec Private Voting implements all of it.

The Horizon PRD lists receipts as an open question: *"Default receipts content voters expect."* `docs/receipt-design.md` answers that question in full, including specific UX decisions, alternatives rejected, and the coercion-resistance analysis. This is the contribution the PRD needed but did not specify.

---

## Competitive landscape

Source: PSE/Shutter *State of Private Voting 2026* (January 2026) — evaluated 12 protocols against 26 properties.

| Project | Cryptography | Product layer | Receipt UX |
|---|---|---|---|
| MACI V3 (PSE/EF) | strongest coercion resistance | library only, no product | no |
| Shutter + Snapshot | threshold encryption, 850+ DAOs | Snapshot integration | no — votes revealed post-close |
| DAVINCI (Vocdoni) | strongest overall, approaching mainnet | no facilitator UX | no |
| Enclave (Gnosis Guild) | strong, mainnet Q1 2026 | no facilitator UX | no |
| NounsDAO/Aztec experiment | Aztec | research prototype | no |
| **Aztec Private Voting** | **Aztec** | **DAO-usable managed service** | **yes — the research contribution** |

No protocol in the PSE report has a facilitator UX or a receipt artifact. That is the gap.

---

## Beyond funding

Three things that matter as much as the grant:

1. **One async technical contact** on the Aztec protocol team — for questions that aren't answered in docs (likely 2-3 exchanges during the v5 migration).
2. **Signal boost at launch** — a Discord mention or tweet when the component library ships. This is a tooling project; discoverability is the distribution problem.
3. **Feedback on the receipt design** — if anyone on the Aztec team has opinions on the `docs/receipt-design.md` approach before v5 ships, that input would improve the work. Optional, not required.

---

## Contact

GitHub: @jonybur-oc  
Discord: @jonybur (or ask in #grants)  

Built on Aztec-NR. Willing to demo, pair on integrations, or discuss extending the receipt-design research into a public paper.
