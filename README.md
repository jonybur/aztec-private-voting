# Aztec Private Voting

Private ballot infrastructure for DAOs. Four React components + Aztec Noir contracts.

## What this is

A voting primitive for DAOs that want secret ballots with verifiable tallies. Members vote privately - only the final result is revealed. Built on [Aztec Network](https://aztec.network) and Noir.

## What this is not

- A full governance platform (use Tally, Boardroom, or Snapshot for that).
- A replacement for public voting in all cases.
- Production-ready - this is research code.

## The receipt problem

The hardest part of private voting UX is the receipt — the moment after a voter clicks submit. Every existing system (MACI, Shutter, the NounsDAO experiment) hands back a hex string or a "your vote was recorded" toast. Neither communicates what actually happened.

We treat the receipt as the product. The `<VoteReceipt />` component is built around one design principle: prove the vote was counted without proving how the voter voted. It uses a "vote fingerprint" (the nullifier, renamed for comprehension), download-by-default persistence, and copy written to avoid the words "cryptographic", "zero-knowledge", and "nullifier".

This design is formalised as the **Proof-of-Inclusion UX Pattern (PIUP)** — the first documented design class combining verifiability and content-blindness in a single receipt artifact. Three formal invariants are stated in [`docs/proof-of-inclusion-ux-pattern-2026-06-22.md`](docs/proof-of-inclusion-ux-pattern-2026-06-22.md). The core label-choice claim (does "vote fingerprint" produce better privacy mental models than "confirmation code" or "receipt ID"?) is the subject of Study 1: a pre-registered 4-condition between-subjects experiment (N=280, pre-registration complete — [`docs/piup-study1-preregistration-2026-06-22.md`](docs/piup-study1-preregistration-2026-06-22.md)).

See [`docs/receipt-design.md`](docs/receipt-design.md) for the full design rationale, the specific copy decisions, and the open questions we did not solve.

## Repo layout

```
contracts/                     Noir contracts (PrivateVoting + helpers)
  src/
    main.nr                    contract entrypoint (PrivateVoting)
    eligibility.nr             eligibility verification (open / token-gated / allowlist)
  Nargo.toml                   uses Aztec-NR v5.0.0-nightly
packages/
  react/                       component library
    src/
      components/              VoteReceipt, PrivateBallot, ...
      hooks/                   useVote, useEligibility, useTally, ...
      aztec/                   PXE/wallet wiring
      index.ts
demo/                          Next.js demo app (active / closed / admin)
docs/
  receipt-design.md            the design contribution
```

## Install

This is a workspace repo. From the root:

```sh
npm install
```

The library itself can be installed from a checked-out repo or, once published, from npm:

```sh
npm install @aztec-private-voting/react @aztec/aztec.js
```

## Usage

```tsx
import {
  AztecProvider,
  useBrowserAztecClient,
  setPrivateVotingArtifact,
  VoteEligibilityProof,
  PrivateBallot,
  VoteReceipt,
  VoteResult,
  VoteAdmin,
} from '@aztec-private-voting/react';
import '@aztec-private-voting/react/src/styles.css';

import artifact from './private_voting-PrivateVoting.json';
setPrivateVotingArtifact(artifact);

function App() {
  const state = useBrowserAztecClient({
    pxeUrl: process.env.NEXT_PUBLIC_AZTEC_PXE_URL!,
    createWallet: createDemoWallet,
  });

  return (
    <AztecProvider {...state}>
      <ActiveVote />
    </AztecProvider>
  );
}
```

A full working example - eligibility check, ballot, receipt, and tally - is in `demo/`.

## Contracts

To compile the Noir contracts:

```sh
npm run build:contracts
```

This produces `contracts/target/private_voting-PrivateVoting.json`. Copy that JSON into `demo/public/` (or wherever your app loads contract artifacts from) before running the demo.

To deploy a fresh `PrivateVoting` contract to Aztec Alpha testnet:

```sh
# Option A — one-shot (bridges Sepolia fee juice + deploys in one command):
export L1_PRIVATE_KEY=0x<your-sepolia-key>   # needs ~0.01 SepoliaETH
bash scripts/bridge-and-deploy.sh

# Option B — if fee juice is already bridged:
npm run deploy:testnet
```

Full run book in [docs/deployment.md](docs/deployment.md). Both options write the deployed address to `deployments/alpha-testnet.json`, which the demo reads automatically.

### Aztec testnet deployment

| Field                | Value                                                           |
| -------------------- | --------------------------------------------------------------- |
| Network              | Aztec v5 testnet (`https://v5.testnet.rpc.aztec-labs.com`) — L1: Sepolia (chain 11155111) |
| `PrivateVoting`      | Compiled artifact ready (`b828bc6`); deployment pending `DEPLOYER_SECRET_KEY` + `DEPLOYER_SIGNING_KEY` credentials — see [`docs/v5-upgrade-runbook.md`](docs/v5-upgrade-runbook.md) |
| Noir version         | Aztec-NR v5.0.0-rc.1 (released 2026-06-15; zero contract changes required from v4.3) |
| ℹ️ Note             | Aztec Alpha v4 had a known vulnerability (disclosed March 2026); the v4 contract `0x1a8ef...` is no longer accessible after the v5 testnet reset. The v5 RPC is live (confirmed block 1977, 2026-07-02 ~04:43 UTC; second testnet reset occurred Jun 30→Jul 1 2026, block counter restarted but rollup address and RPC endpoint unchanged). |

## Running the demo locally

```sh
cd demo
cp .env.example .env.local
# fill in NEXT_PUBLIC_AZTEC_PXE_URL and NEXT_PUBLIC_VOTE_CONTRACT_ADDRESS
npm run dev
```

Open <http://localhost:3000> for the active vote, `/closed` for the result + verifier, `/admin` to deploy a new vote.

## Components

- `<VoteEligibilityProof />` - generates a ZK proof of voting rights, silent on the happy path.
- `<PrivateBallot />` - the vote interface. Submits an encrypted ballot.
- `<VoteReceipt />` - the key piece. Plain-language receipt with the vote fingerprint.
- `<VoteResult />` - tally reveal with built-in verifier for individual receipts.
- `<VoteAdmin />` - configuration UI for governance facilitators.

## Grant

Applying to Aztec Grants Wave 3. Full application in [`GRANT.md`](GRANT.md).

If you're building governance tooling on Aztec, reach out — we're interested in integrations.
