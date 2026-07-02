# Deploying to Aztec Alpha testnet

End-to-end run book for getting a `PrivateVoting` contract live on Aztec Alpha testnet and pointing the demo at it.

## Prerequisites

| Tool                | Version             | Notes                                                                 |
| ------------------- | ------------------- | --------------------------------------------------------------------- |
| Node                | >= 20               | Workspace requires it.                                                |
| `nargo`             | matching `v5.0.0-nightly` | Used by `npm run build:contracts`. Install via `aztec-up`.       |
| Aztec PXE           | matching SDK pin    | Run locally pointed at the testnet node, or use a hosted PXE.         |

Funded testnet account: a Schnorr account with enough fee tokens to pay deployment + a finalize tx.

## 1. Compile the contract

```sh
npm run build:contracts
```

Produces `contracts/target/private_voting-PrivateVoting.json`.

## 2. Start a PXE pointed at testnet

```sh
aztec start --pxe nodeUrl=https://rpc.testnet.aztec-labs.com
```

The PXE will listen on `http://localhost:8080`.

## 3. Edit the deploy config

`scripts/deploy.config.json` controls what the contract is initialised with:

```json
{
  "title": "Should the treasury fund this initiative? (50 ETH)",
  "description": "...",
  "options": ["For", "Against", "Abstain"],
  "startTimeOffsetSeconds": 0,
  "durationSeconds": 604800,
  "quorum": 5,
  "eligibilityMode": "open"
}
```

For token gating:
```json
{
  "...": "...",
  "eligibilityMode": "token",
  "tokenAddress": "0x...",
  "minTokenBalance": "100"
}
```

> **⚠️ TOKEN MODE — `tokenAddress` encodes the Merkle root, not a contract address (N-F3)**
>
> In token-gated mode, `tokenAddress` does **not** hold a real token contract address.
> It holds the 248-bit encoded Merkle root of the token-balance snapshot, produced by
> `encode_root_as_field` in `scripts/synthetic-snapshot.ts`. The circuit reads it back
> via `encode_field_as_root` in `contracts/src/merkle.nr` — the top byte of the 32-byte
> SHA-256 root is dropped (zero-padded), which is sufficient for a Merkle commitment.
> Always generate this value with the snapshot helper; never paste a real contract address here.
>
> Also: **`minTokenBalance` must be ≥ 1** — setting it to `0` would admit any address
> present in the snapshot regardless of balance. The constructor enforces this at deploy
> time: a `minTokenBalance` of `0` will revert with `"token mode: min_token_balance must be > 0"`.

For an allowlist:
```json
{
  "...": "...",
  "eligibilityMode": "allowlist",
  "allowlistRoot": "0x..."
}
```

> **⚠️ ALLOWLIST MODE — `allowlistRoot` encodes the Merkle root, not a contract address (N-F3)**
>
> Same encoding as token mode: `allowlistRoot` is the 248-bit field encoding of the
> SHA-256 Merkle root of the eligibility set. It is stored internally in `config.token_address`
> by the deploy script. Generate it with the allowlist snapshot helper; do not substitute
> a real contract address.

> **⚠️ ALLOWLIST MODE — Multi-wallet sybil is a deployer invariant, not a circuit guarantee (N-F6)**
>
> The circuit enforces **one vote per listed Aztec address**. It does NOT enforce one vote
> per real-world person. A participant controlling multiple Aztec wallet addresses (A, B, C)
> can cast one ballot from each address — if all three appear in the allowlist.
>
> **The deployer is solely responsible for the 1-person → 1-address invariant.**
>
> Strategies to uphold it:
> - **Identity-linked allowlists**: derive the set from an on-chain identity registry
>   (e.g. Proof of Humanity, WorldID, ENS + proof of uniqueness) where each verified
>   human maps to exactly one address.
> - **Curated sets**: for small-committee or DAO-treasury votes, publish the allowlist
>   publicly before the vote opens so participants can challenge duplicates.
> - **Social/governance commitment**: include in the vote description a statement that
>   each participant agreed to bind one address; sybil attempts become attributable.
>
> If the deployer cannot enforce 1-person → 1-address, they should use TOKEN mode with
> a snapshot that caps each address at a known balance, or OPEN mode with a quorum
> threshold high enough that sybil inflation is detectable from the tally.

## 4. Run the deploy script

```sh
AZTEC_PXE_URL=http://localhost:8080 \
DEPLOYER_SECRET_KEY=0x... \
DEPLOYER_SIGNING_KEY=0x... \
npm run deploy:testnet
```

The script:
1. Connects to the PXE.
2. Bootstraps a Schnorr account from the secret + signing key.
3. Hashes the title with poseidon2.
4. Calls `Contract.deploy(wallet, artifact, [admin, voteConfig], 'constructor')`.
5. Writes the deployment metadata to `deployments/alpha-testnet.json`.

The address printed at the end is what auditors will paste into the explorer and what voters will hit through the demo.

## 5. Point the demo at the deployment

Two ways:

- **Automatic** - the demo reads `deployments/alpha-testnet.json` at build time. After step 4 the address is already wired up; run `npm run dev:demo` and the active/closed/admin pages will use it.
- **Override** - set `NEXT_PUBLIC_VOTE_CONTRACT_ADDRESS=0x...` in `demo/.env.local`. Env var wins over the deployment file.

## 6. Verify the deployment

Open `/closed` after the deadline (or with a manually-finalized vote) and confirm:

- Tally bars render.
- "For auditors" panel shows totals match, double-vote claim, no-individual-choice claim, and links to the contract address + finalize tx.
- The "Verify your vote was counted" verifier round-trips a known-good fingerprint.

## 7. Update the README

Drop the deployed address into the **Contracts** section of `README.md`:

```markdown
## Contracts

Aztec Alpha Network deployment:
- `PrivateVoting`: `0x...`
- Deployed: YYYY-MM-DD
```

---

## 8. Babylon mode (M2) — deployment notes

The `cast_vote_babylon_v2` entrypoint adds secp256k1 ownership proofs for Babylon/Cosmos
snapshot holders. Two design-level constraints must be understood before deploying in
any governance context.

### M2-F2 — EVM wallet required; Keplr/Cosmos signing not yet supported

The circuit uses **EIP-191 `personal_sign`** to verify ownership of a secp256k1 keypair.
Wallets that support this include MetaMask, Ledger (via MetaMask or WalletConnect), and
most EVM-compatible signers. **Keplr and Leap are not compatible out of the box** — those
wallets use the Cosmos ADR-036 signing format (`sha256` prehash, not `keccak256`), which
produces a different message digest and will fail circuit verification.

**What this means for deployers:**
- Babylon/Cosmos snapshot holders need to sign with an EVM-compatible wallet that holds
  the same secp256k1 private key as their `bbn1…` address.
- Provide clear in-UI guidance: e.g., “Export your Babylon private key from Keplr, then
  import it into MetaMask to vote. Never share your private key with anyone else.”
- A future Cosmos/Keplr signing path (ADR-036 format) would only require a different
  message prehash (`sha256` instead of `keccak256`). The secp256k1 arithmetic and Merkle
  proof are identical. This is a named extension in ADR-036 §Path A.

> **⚠️ BABYLON MODE — EVM wallet required (M2-F2)**
>
> The Babylon voting circuit (`cast_vote_babylon_v2`) uses EIP-191 `personal_sign`.
> Voters **must** sign with MetaMask (or any EIP-191-compatible EVM wallet) holding the
> same secp256k1 key as their `bbn1…` Babylon address. Keplr and Leap use a different
> message format and are **not currently supported**. Native Cosmos signing (ADR-036) is
> a planned future extension.

---

### M2-F3 — Vote uniqueness is per Cosmos address, not per Aztec wallet

The Babylon paths do **not** use Aztec’s `SingleUseClaim` mechanism. Instead, uniqueness
is enforced by the `holder_nullifier` — a deterministic value derived from
`sha256(secp256k1_signature)`. Because the signature is deterministic given a fixed
`(privkey, challenge)` under RFC 6979, each distinct Cosmos private key can produce at
most one valid nullifier per vote.

**Consequence:** “one vote per entity” is **not** enforced. The guarantee is:

> “one vote per Cosmos address present in the snapshot.”

An entity controlling N different Cosmos addresses (N snapshot leaves) can cast N ballots,
each from a different Aztec wallet. This is the intended semantics for token-weighted
Babylon governance, where voting power is proportional to snapshot holdings.

**What this means for deployers:**
- Communicate clearly to participants that voting power derives from snapshot position,
  not Aztec wallet identity.
- If 1-person → 1-vote semantics are required (e.g. a committee vote), use `ALLOWLIST`
  mode (which does use `SingleUseClaim`) with an identity-linked allowlist instead of a
  Cosmos snapshot.
- Publish the snapshot root and the number of eligible snapshot leaves so participants
  can verify the voting population is correct before the vote opens.

> **⚠️ BABYLON MODE — one vote per Cosmos address, not per person (M2-F3)**
>
> The `cast_vote_babylon_v2` circuit grants one vote to each eligible Cosmos address in
> the snapshot. An entity holding multiple Babylon addresses can vote multiple times —
> once per address. This is correct for token-weighted governance. For 1-person → 1-vote
> semantics, use `ALLOWLIST` mode with an identity-verified allowlist.
