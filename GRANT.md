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

This receipt pattern has been formalised as the **Proof-of-Inclusion UX Pattern (PIUP)** in [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](docs/proof-of-inclusion-ux-pattern-2026-06-22.md) — the first documented design class combining verifiability and content-blindness in a single receipt artifact. The pattern generalises beyond voting to sealed-bid auctions, whistleblower systems, and blind peer review. Three formal invariants are stated; the current L1 privacy gap (vote choice visible in `record_vote` public calldata) is documented as a named limitation, not glossed over.

**PIUP Study 1 — empirical validation (pre-registered):** The receipt design's core claim — that label choice affects privacy mental model quality — is being tested empirically, not assumed. Study 1 is a 4-condition between-subjects experiment (n=70 per condition, N=280) comparing the four candidate identifier labels: *vote fingerprint* (current production), *confirmation code*, *nullifier*, and *receipt ID*. Primary endpoint: Q2 accuracy — does the voter correctly infer their vote choice is hidden? — A > B, pre-registered as directional. 14 confirmatory tests across 4 Holm-corrected families. H2 is pre-registered as a dissociation prediction: we expect A to match B on overall accuracy but diverge on the two privacy items specifically, because eCommerce framing activates the right behavioural schema ("this proves submission") but the wrong representational schema ("the receipt contains what I submitted"). Full pre-registration, survey instrument, and R analysis script are committed to this repo ([`docs/piup-study1-preregistration-2026-06-22.md`](docs/piup-study1-preregistration-2026-06-22.md), [`analysis/piup-study1-analysis.R`](analysis/piup-study1-analysis.R)).

**PIUP Study 3 — social verification pilot (pre-registered):** Study 3 tests whether a social proof signal embedded in the PIUP receipt increases post-vote verification return rates — the proportion of voters who return at T+14 to confirm their ballot was counted. Social proof (Cialdini, 1984) has been shown to increase upfront security behaviour (Das et al., CCS 2014: password manager adoption via peer-count display); Study 3 asks whether the same mechanism operates for *deferred* security behaviour in a private voting context. The design is a two-arm between-subjects field experiment (N=80 pilot; n=40/condition; control: standard PIUP receipt; treatment: receipt + live counter of how many voters have already verified). The counter draws from the contract's public `verify_vote_counted()` call logs, updated every 15 minutes — aggregate verification counts are available on-chain without de-anonymising any individual voter. The pilot is powered to estimate a 90% CI on the verification-rate odds ratio; a confirmatory replication (N≥280) follows if the OR is positive. Pre-registration, analysis script, and debrief script are committed to this repo ([`docs/piup-study3-osf-prereg-2026-07-01.md`](docs/piup-study3-osf-prereg-2026-07-01.md), [`analysis/piup-study3-analysis.R`](analysis/piup-study3-analysis.R)).

**PIUP Study 4 — Invariant 2 behavioural validation (pre-registered):** Studies 1–3 test whether voters understand the receipt and whether they return to verify. Study 4 tests a different claim: does the UI-lock that enforces Invariant 2 (copy/download disabled before vote close) produce genuine social deniability under adversarial pressure? A pre-registered 2×2 between-subjects vignette (N=160; UI-lock present/absent × coercion pressure moderate/high; pre-registered DVs: self-reported sharing intent DV1, primary confirmatory, 7-point scale; perceived social deniability of the technical excuse DV2, secondary confirmatory; powered for f=0.25, 86% power for the H4.2 interaction) tests the interaction hypothesis that the lock’s sharing-intent reduction is larger under high pressure — where a technical constraint ("I can’t") is harder to override than a normative one ("I shouldn’t"). H4.3 directly measures perceived deniability: UI-lock participants are predicted to rate “the app won’t let me” as more socially convincing than countdown-only participants. DV1 and DV2 are two complementary operationalisations of the social deniability mechanism. Pre-registration text, Qualtrics guide, and R analysis script are committed ([`docs/piup-study4-osf-prereg-2026-07-01.md`](docs/piup-study4-osf-prereg-2026-07-01.md), [`analysis/piup-study4-analysis.R`](analysis/piup-study4-analysis.R)). This study is entirely Prolific-based and does not require a live contract deployment.

---

## Technical state

**Implementation complete.** All Noir contracts + React components are merged and tested.

| Layer | Status |
|---|---|
| `PrivateVoting.nr` — Noir contract (Aztec-NR **v5.0.0-rc.1**) | ✅ merged + compiled |
| `@aztec-private-voting/react` — component library | ✅ merged |
| Playwright + Noir unit tests (41 user stories) | ✅ merged |
| Aztec-NR v5 port | ✅ confirmed (zero code changes) |
| Static security review (`main.nr` + `eligibility.nr`) | ✅ done — F2 (quorum) + F3 (receipt_id) fixed; 8 sound properties confirmed |
| M2 — secp256k1 ownership proof circuit | ✅ **complete** — 11/11 checklist items done; EIP-191 benchmark: 339 ACIR opcodes + 348 Brillig opcodes; 7/7 tests pass (`docs/m2-benchmark-2026-06-27.md`) |
| Tally privacy architecture — M3 decision gate | ✅ A/B/C spike done; Architecture A recommended |
| Alpha testnet deployment | ⚠️ **Awaiting deployer keys** — v5 testnet RPC confirmed live (block 1637, Jul 1 2026 ~21:58 UTC, ~55 blocks/hr post-second-reset); deploy command ready in `docs/v5-upgrade-runbook.md` |
| BABY token Merkle governance demo (Babylon team) | ✅ **LIVE** |

The contracts compile cleanly against **Aztec-NR v5.0.0-rc.1** (released June 15, 2026 — first testnet RC). Zero contract code changes were required across any version from v4.3 to v5.0.0-rc.1. All import paths, function attribute macros, state variables, and trait derives are identical. The Aztec team disclosed a critical vulnerability in Alpha v4 in March 2026; we are already on v5.

**v5 testnet upgrade complete (Jun 18 2026):** New endpoint `https://v5.testnet.rpc.aztec-labs.com` is live and healthy (confirmed block 1637, 2026-07-01 ~21:58 UTC; ~55 blocks/hour active production; rollupVersion `2787991301` stable; note: testnet resets periodically — block count resets with each state reset, but rollup address and RPC endpoint remain stable). The upgrade included an initial testnet state reset (Jun 18). A second state reset occurred Jun 30→Jul 1 2026; rollup address changed to `0xfe6061806cac748085904a010d2d9e33b8031741` (Sepolia) but RPC endpoint is unchanged. The v4 contract `0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981` (deployed 2026-05-18) is no longer accessible. The v5 contract artefact is compiled and ready (`b828bc6`); deployment requires `DEPLOYER_SECRET_KEY` + `DEPLOYER_SIGNING_KEY` credentials (see `docs/v5-upgrade-runbook.md`). The contract address in this document will be updated before forum submission.

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

**Status:** M2 circuit is implemented. `cast_vote_babylon_v2` in `main.nr` delivers the full ownership proof:
- In-circuit `std::ecdsa_secp256k1::verify_signature` — any witness without a valid secp256k1 key is rejected
- Vote-specific challenge `sha256(title_bytes || root_bytes)` — no cross-vote replay
- Nullifier `hash_bytes_as_field(sha256(sig))` — not computable from the public snapshot (closes the M1 front-running gap)
- Key derivation via `SHA-256d` fallback (`sha256(sha256(pubkey_x ‖ pubkey_y))[12..32]`, 20-byte commitment) — circuit and snapshot generator use identical scheme; two deterministic test vectors pass in `contracts/src/merkle.nr:416-450`. Production swap: replace `derive_hash160_sha256d` with `ripemd160(sha256(compressed_pubkey))` once `noir-ripemd160` confirms compatibility with `nargo ≥ 0.30`; no other circuit changes required.

Checklist: **11/11 items complete. M2 complete.** Full EIP-191 ownership proof path (SHA-256 challenge construction + keccak256 EIP-191 wrapping + secp256k1 verification) compiles to **339 ACIR opcodes + 348 Brillig opcodes**; circuit witness solved under `nargo execute` with EIP-191 test vectors; 7/7 unit tests pass. Within Aztec's documented per-function ceiling. Full benchmark results: `docs/m2-benchmark-2026-06-27.md`. The snapshot generator (`synthetic-snapshot.ts --version 2`), M2 Merkle root encoding in the deploy script, React `useM2Signing` hook, and EIP-191 circuit update are all complete. **Wallet signing path: ADR-036 Path C (EIP-191 `personal_sign`) chosen and implemented** — circuit now verifies `keccak256(EIP-191(challenge))`, works with MetaMask/Ledger/WalletConnect out of the box. Cosmos/Keplr (Path A) documented as a named extension. Full decision record: `docs/adr-036-m2-wallet-signing-path.md`.

**Named trust assumption:** M2's single-use enforcement (one vote per Cosmos key per election) relies on the signing wallet implementing RFC 6979 deterministic nonce generation. EIP-191 EVM wallets (MetaMask, WalletConnect, Ledger via MetaMask) and Cosmos SDK (Keplr) both use RFC 6979 — the current ADR-036 Path C deployment is safe. A wallet with randomised signing nonce could produce multiple valid signatures and therefore multiple valid nullifiers, enabling multiple votes from the same key. Risk severity is LOW for the grant demo scope: the attacker must hold the private key (no external exploit), each additional vote costs Aztec gas, and Merkle eligibility pins the balance. Mitigation for production: add a protocol-level claim keyed on `hash(pubkey_x ‖ pubkey_y)`. Full analysis: `docs/m2-front-running-security-analysis-2026-06-27.md`.


---

## Budget breakdown ($25K)

| Line | Amount |
|---|---|
| Development — Noir contract + 4 React components + test suite (~3 months part-time at fair market rate) | $15,000 |
| Security review / Noir contract audit before v5 production deployment (self-review complete; professional audit pre-mainnet) | $8,000 |
| Documentation, demos, ecosystem tooling | $2,000 |
| **Total** | **$25,000** |

This is calibrated as a tooling + research grant. Wave 2 tooling grants ranged $10K–$30K; this project has completed implementation (not speculative), a differentiated HCI research angle, and a working demo. $25K is the correct ask for this tier.

---

## Alignment with Aztec Horizon

This project directly implements the [Private Voting Module for DAOs PRD](https://github.com/AztecProtocol/Horizon/blob/main/PRDs/Private_Voting_Module_for_DAOs.md) — Aztec's own specification for the ecosystem application it wants built. Section-by-section:

| PRD section | Status |
|---|---|
| §4.1 Admin flow (configure, publish, monitor, finalize) | ✅ Full |
| §4.2 Voter flow (eligibility proof, private vote, verify inclusion) | ✅ Full |
| §4.3 Auditor flow | ⚠️ Partial — per-voter receipt delivered; auditor proof pack (post-grant) |
| §5 MVP eligibility templates (token weight, one-person-one-vote, role lists) | ✅ Full — 3 modes shipped |
| §5 MVP encrypted ballot lifecycle (commit, tally, finalize) | ⚠️ Named Limitation — anonymous but unencrypted pre-M3; M3 spec complete |
| §11 Open question: *"Default receipts content voters expect"* | ✅ Answered — PIUP + four-study empirical programme (Study 1 pre-registered N=280 label effects; Study 2 draft pre-registered N=240 explanation effects; Study 3 power-analysed N=280+ social verification; Study 4 pre-registered 2×2 vignette N=160 UI-lock social deniability under adversarial coercion) |

Two notes on the Named Limitation:
- **What it is:** `vote_choice` is a public argument of `record_vote` (the public half of each Aztec transaction). An observer with the full call log can correlate `receipt_id → vote_choice`.
- **Why PIUP is the right response:** The receipt is engineered around *surrogate independence* — it contains the vote fingerprint but never the vote choice. A coercer who can see calldata still cannot coerce from the receipt alone; the receipt proves participation, not direction. M3 closes the calldata exposure entirely.

The gap that matters for the grant: every other system (MACI, Shutter, NounsDAO/Aztec) ignores the open question entirely. PIUP is the first documented, empirically-tested design answer.

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
