# Aztec Grants Wave 3 Application: Private Voting + Receipt Design for DAOs

**Status:** READY TO POST — insert contract address before submitting  
**Contract address placeholder:** `[CONTRACT ADDRESS — deploy to v5 testnet first: cd aztec-private-voting && AZTEC_PXE_URL=https://v5.testnet.rpc.aztec-labs.com DEPLOYER_SECRET_KEY=<key> DEPLOYER_SIGNING_KEY=<key> npx tsx scripts/deploy-testnet.ts]`

---

## Forum Post (paste into forum.aztec.network → Applications)

**Title:** `[Grant Application] Aztec Private Voting — Noir contract + React components + receipt-design research`

---

**Hi Aztec community,**

I'm applying for a Wave 3 grant for [Aztec Private Voting](https://github.com/jonybur-oc/aztec-private-voting) — a Noir contract + React component library for private DAO governance, now running on Aztec-NR v5.

### The problem this solves

Every DAO governance tool I looked at — MACI, Shutter, the NounsDAO Aztec experiment — solves the cryptographic problem and ignores the product problem. After a private vote, voters get a transaction hash. Nobody explains what "your vote was counted but can't be traced back to you" actually means to a non-technical DAO participant. The result: either blind trust in an opaque system, or confusion that undermines participation.

The most concrete way I can say this: when building the receipt, I kept asking "what should go on it?" That question has no cryptographic answer. It's a design question. Nobody had answered it. So that's what this project does.

### What's built (implementation-complete)

**Noir contract (`PrivateVoting.nr`)** — Aztec-NR v5.0.0-rc.1, compiles cleanly, zero changes required from v4.3:
- `cast_vote` — private entry; eligibility proof + encrypted ballot
- `record_vote` — public only-self; validates timing, nullifier, increments tally
- `finalize_vote` — post-deadline quorum check
- `verify_vote_counted(nullifier)` — public view, lets any voter confirm their receipt
- Three eligibility modes: open, token-gated (ZK balance Merkle proof), allowlist (ZK address Merkle membership)
- Security review complete (May–June 2026): quorum bypass (F2) and receipt ID collision (F3) fixed; 8 sound properties confirmed

**React components (`@aztec-private-voting/react`)**:
- `<VoteEligibilityProof />` — generates ZK proof of voting rights, silent on happy path
- `<PrivateBallot />` — vote interface, submits encrypted ballot
- `<VoteReceipt />` — the key piece (see below)
- `<VoteResult />` — tally reveal with per-fingerprint verifier
- `<VoteAdmin />` — governance facilitator configuration UI

**Test suite** — 41 user stories, Playwright + Noir unit tests.

**Live testnet deployment** — `[CONTRACT ADDRESS]` (v5.testnet.rpc.aztec-labs.com — deploying now; will update before submitting)

### The receipt — the actual research contribution

`<VoteReceipt />` is built around one constraint: prove the vote was counted without proving how the voter voted.

The specific design decisions:
- **Vote fingerprint** instead of nullifier. Same underlying value; different framing. "Your vote fingerprint: `a3f9...`" reads as an identifier; "Your nullifier: `a3f9...`" reads as jargon. The download-by-default behavior comes from this framing — it's a document, not a hash.
- **Collapsed verification explainer** — the cryptographic explanation exists but is hidden behind a "how does this work?" toggle. Most voters don't need it. The voters who do can find it.
- **Protective absence** — the receipt explicitly names the absent thing before the user reaches for it. Sequence matters: *you voted → your choice is private → here is your fingerprint*. Without that ordering, voters interpret a missing vote choice as failure, not protection. This is a feedback inversion: Norman's feedback principle says confirm what was done — here, the correct confirmation proves the action is *protected from display*. The closest prior art is the HTTPS lock icon: it shows the channel is protected, not what was transmitted. The receipt is one layer deeper — users must read absent content as evidence of a guarantee.
- **No "cryptographic", "zero-knowledge", or "nullifier" in the main flow** — these words appear only in the toggle.

The full rationale — including design alternatives rejected and open problems not solved — is in [`docs/receipt-design.md`](docs/receipt-design.md). The pattern has been formalised as **PIUP (Proof-of-Inclusion UX Pattern)** in [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](docs/proof-of-inclusion-ux-pattern-2026-06-22.md): a design class for any system that must confirm submission without revealing content. Core principle: **protective absence** — the feedback loop inverts; the correct signal is evidence that the action is *protected* from display. Three formal invariants (surrogate independence, surrogate privacy in transit, minimal receipt content), one named limitation (vote choice still visible in `record_vote` public calldata — an Aztec protocol limitation, not a design choice).

**PIUP Study 1 — empirical validation (pre-registered):** The receipt design's core claim — that label choice affects privacy mental model quality — is being tested empirically, not assumed. Study 1 is a 4-condition between-subjects experiment (n=200 Prolific participants) comparing the four candidate identifier labels: *vote fingerprint* (current production), *confirmation code*, *nullifier*, and *receipt ID*. Primary endpoint: Q2 accuracy (does the voter correctly infer their vote choice is hidden?), A > B, pre-registered as directional. 14 confirmatory tests across 4 Holm-corrected families. H2 is pre-registered as a dissociation prediction: we expect A to match B on overall accuracy but diverge on the two privacy items specifically, because eCommerce framing activates the right behavioural schema ("this proves submission") but the wrong representational schema ("the receipt contains what I submitted"). Full pre-registration, survey instrument, and R analysis script are committed to this repo. OSF DOI: `[OSF DOI — upload docs/piup-study1-preregistration-2026-06-22.md before posting]`.

This is the answer to the open question in the [Horizon PRD for Private Voting](https://github.com/AztecProtocol/Horizon/blob/main/PRDs/Private_Voting_Module_for_DAOs.md): *"Default receipts content voters expect."*

### Why the KelpDAO/rsETH case matters

KelpDAO ran a 49-day public vote on loss socialisation from the $71M rsETH exploit on Arbitrum. Every voter's wallet was visible on-chain. Voters who could be identified were subject to pressure. The existing governance tooling had no answer.

This is the threat model `cast_vote` solves: hidden ballot on Aztec, public tally, verifiable receipt that confirms participation without confirming direction.

### M2 (in-circuit ownership proof) — status and one open decision

The current system proves a voter's *membership* in a snapshot (their (address, balance) pair is a leaf in the committed Merkle tree). It does not prove *ownership* of the signing keys. A well-resourced attacker with the public snapshot could pre-compute Merkle proofs for every holder.

M2 closes this: `cast_vote_babylon_v2` in `main.nr` adds an in-circuit `std::ecdsa_secp256k1::verify_signature` — any witness without valid secp256k1 key ownership is rejected. The nullifier is now `hash_bytes_as_field(sha256(sig))` — not computable from public snapshot data.

**Status (2026-06-22):** 10/11 checklist items complete. The snapshot generator (`synthetic-snapshot.ts --version 2`), deploy-script Merkle root encoding, and `useM2Signing` React hook are all done. One item remaining: production proving-time measurement on browser hardware.

**Signing path resolved (ADR-036 Path C):** M2 signing uses EIP-191 `personal_sign` (MetaMask/Ledger/WalletConnect) as the primary wallet path. The circuit now verifies `keccak256(EIP-191(challenge))` — ~10 additional Noir lines vs. ~100 for the Cosmos ADR-036 path, and works out of the box with any EVM wallet. Keplr/ADR-036 support is documented as a named extension (Path A) for Cosmos-native voter populations. See `docs/adr-036-m2-wallet-signing-path.md` for the full decision record.

### What I'm asking for

**$25,000** — breakdown:
- $15,000: Development (Noir contract + 4 React components + test suite, ~3 months part-time)
- $8,000: Professional security audit before v5 production deployment (self-review complete; audit pre-mainnet)
- $2,000: Documentation, demos, ecosystem tooling

**Beyond the money — three specific asks:**

1. **One async technical contact** on the protocol team — for anything not answered in the v5 docs during the final deployment sprint, and for feedback on the EIP-191 vs. ADR-036 circuit trade-off if the Cosmos-native path becomes a priority. 2–3 exchanges.

2. **Signal boost at launch** — a Discord mention or tweet when the component library ships publicly. Distribution is the hard problem for open source tooling.

3. **Receipt design feedback** — if anyone has opinions on the `docs/receipt-design.md` approach before v5 ships, I'd incorporate it. The Horizon PRD left this open; I'd rather not ship the wrong answer.

### Horizon PRD alignment

This directly implements the [Private Voting Module for DAOs PRD](https://github.com/AztecProtocol/Horizon/blob/main/PRDs/Private_Voting_Module_for_DAOs.md). Admin flow, voter flow, eligibility proofs, encrypted ballots, receipts, quorum rules — all implemented.

The PRD listed the receipt as an open question. The receipt design is this project's answer.

### Competitive landscape

The [PSE/Shutter *State of Private Voting 2026*](https://mirror.xyz/privacy-scaling-explorations.eth) report (January 2026) evaluated 12 protocols against 26 properties. No protocol in that report has a facilitator UX or a receipt artifact. That is the gap.

| Project | Cryptography | Facilitator UX | Receipt |
|---|---|---|---|
| MACI V3 | strongest coercion resistance | library only | ❌ |
| Shutter + Snapshot | threshold encryption | Snapshot integration | ❌ |
| DAVINCI (Vocdoni) | strongest overall | no facilitator UX | ❌ |
| Enclave (Gnosis Guild) | strong, mainnet Q1 2026 | no facilitator UX | ❌ |
| NounsDAO/Aztec | Aztec | research prototype | ❌ |
| **Aztec Private Voting** | **Aztec** | **✅** | **✅** |

### Background

I was on the team that built zk.money. Aztec's programmable privacy is the right layer for this — it's the only EVM-adjacent environment where you can genuinely hide vote choice on-chain while keeping tallies public and verifiable.

GitHub: @jonybur-oc  
Discord: @jonybur

Happy to demo, pair on integrations, or discuss extending the receipt-design work into a public paper.

---

## Post-submission checklist (for Jony)

- [ ] Deploy to v5 testnet: `AZTEC_PXE_URL=https://v5.testnet.rpc.aztec-labs.com DEPLOYER_SECRET_KEY=<key> DEPLOYER_SIGNING_KEY=<key> npx tsx scripts/deploy-testnet.ts`
- [ ] Replace `[CONTRACT ADDRESS]` in forum post with actual deployed address
- [ ] Confirm GitHub repo is public (or will be public at submission)
- [x] Decide on M2 signing path — **Path C (EIP-191) chosen and implemented** (`docs/adr-036-m2-wallet-signing-path.md`)
- [ ] Post to forum.aztec.network → Applications category
- [ ] Post to Aztec Discord #grants channel with forum link
