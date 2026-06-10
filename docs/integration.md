# Integration guide

How to wire `@aztec-private-voting/react` into an app against the live testnet contract. The reference integration is the demo app in `demo/`; this guide follows the same path and flags where the demo deviates from the library's typed API.

## Install

This is a workspace repo. From the root:

```sh
npm install
```

To consume the library in your own app (from a checked-out repo, or from npm once published):

```sh
npm install @aztec-private-voting/react @aztec/aztec.js
```

The library pins `@aztec/aztec.js` and `@aztec/foundation` to `0.85.0-alpha-testnet.11`. Do not upgrade Aztec SDK versions without checking the changelog; the API changes frequently.

## Compile and register the contract artifact

The library does not bundle the contract artifact. Compile it and register it once at startup:

```sh
npm run build:contracts
# produces contracts/target/private_voting-PrivateVoting.json
```

```ts
import { setPrivateVotingArtifact } from '@aztec-private-voting/react';
import { loadContractArtifact } from '@aztec/aztec.js/abi';

const raw = await fetch('/private_voting-PrivateVoting.json').then((res) => res.json());
setPrivateVotingArtifact(loadContractArtifact(raw));
```

The demo copies the JSON into `demo/public/` and loads it in `demo/components/AztecBoot.tsx`. If you skip registration, the first contract call throws with instructions.

## Provider setup

All hooks require an `<AztecProvider>` ancestor. The library ships `useBrowserAztecClient` to build the provider state from a PXE URL and a wallet factory:

```tsx
import { AztecProvider, useBrowserAztecClient } from '@aztec-private-voting/react';
import type { BrowserAztecOptions } from '@aztec-private-voting/react';

function Root({ children, createWallet }: {
  children: React.ReactNode;
  createWallet: BrowserAztecOptions['createWallet'];
}): JSX.Element {
  const state = useBrowserAztecClient({
    pxeUrl: process.env.NEXT_PUBLIC_AZTEC_PXE_URL!,
    createWallet,
  });
  return (
    <AztecProvider client={state.client} loading={state.loading} error={state.error}>
      {children}
    </AztecProvider>
  );
}
```

`createWallet` has the signature `(pxe: PXE) => Promise<AccountWalletWithSecretKey>`; supplying the wallet is the integrator's job (the library does not pick an account scheme for you).

Note a known inconsistency: the demo's `AztecBoot` does not use this typed path. It calls `useBrowserAztecClient({ nodeUrl, createWallet })` with a `createDemoWallet(nodeUrl)` built on `EmbeddedWallet` from `@aztec/wallets`, using `as any` dynamic imports - which does not match the declared `BrowserAztecOptions` (`pxeUrl`, PXE-based factory). Treat the typed API above as the documented surface and the demo bootstrap as a workaround pending alignment.

## Wiring a vote end-to-end

A `PrivateVoting` contract is live on Aztec Alpha testnet (deployed 2026-05-18, recorded in `deployments/alpha-testnet.json`):

```
0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981
```

The contract stores only a hash of the title and the option count, so the display strings live in your app's `VoteConfig`:

```tsx
import { useState } from 'react';
import {
  PrivateBallot,
  VoteEligibilityProof,
  VoteReceipt,
} from '@aztec-private-voting/react';
import type {
  EligibilityProof,
  VoteConfig,
  VoteReceiptData,
} from '@aztec-private-voting/react';

const config: VoteConfig = {
  voteId: '0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981',
  contractAddress: '0x1a8efeffe391793756a08b92672856134d13ae5b7b600cffe50fa5eff7daa981',
  title: 'Should the treasury fund this initiative? (50 ETH)',
  description: 'A request from the ecosystem grants committee.',
  options: ['For', 'Against', 'Abstain'],
  startTime: 1779127406000,
  endTime: 1779732206000,
  quorum: 5,
  eligibilityMode: 'open',
};

function ActiveVote(): JSX.Element {
  const [proof, setProof] = useState<EligibilityProof | null>(null);
  const [receipt, setReceipt] = useState<VoteReceiptData | null>(null);
  const [ineligibleReason, setIneligibleReason] = useState<string | null>(null);

  if (receipt) {
    return <VoteReceipt receipt={receipt} verifierUrl="/closed" />;
  }
  if (!proof) {
    return (
      <VoteEligibilityProof
        config={config}
        onEligible={setProof}
        onIneligible={setIneligibleReason}
      />
    );
  }
  return (
    <>
      {ineligibleReason ? <p>{ineligibleReason}</p> : null}
      <PrivateBallot config={config} eligibilityProof={proof} onVoteCast={setReceipt} />
    </>
  );
}
```

This mirrors `demo/pages/index.tsx` (which builds the same `VoteConfig` from `deployments/alpha-testnet.json` via `demo/lib/sampleVote.ts`). For the closed-vote side, render `<VoteResult config={config} />`; for the operator side, `<VoteFacilitator config={config} />`; to deploy a fresh vote, `<VoteAdmin onDeployed={...} />`. See [components.md](components.md).

## Environment variables

From `demo/.env.example` (copy to `demo/.env.local`):

| Variable | Purpose |
| --- | --- |
| `NEXT_PUBLIC_AZTEC_PXE_URL` | PXE endpoint. Run a local PXE (`aztec start --pxe nodeUrl=https://rpc.testnet.aztec-labs.com`) or use a hosted one. Example default: `http://localhost:8080`. |
| `NEXT_PUBLIC_AZTEC_NODE_URL` | Aztec Alpha testnet node URL (`https://rpc.testnet.aztec-labs.com`). The demo's `AztecBoot` requires this one and fails fast without it. |
| `NEXT_PUBLIC_VOTE_CONTRACT_ADDRESS` | Address of a deployed `PrivateVoting` contract. If unset (or left as `0x...`), the demo falls back to the address in `deployments/alpha-testnet.json`. |

## Running the e2e suite

The Playwright specs in `demo/e2e/` drive the real app against a live contract, so they are skipped unless explicitly enabled:

```sh
cd demo && npm run test:e2e:install   # one-time browser install
E2E_TESTNET_READY=1 npm run test:e2e -w demo
```

Every spec calls `requiresTestnet()` (`demo/e2e/_skip.ts`), which executes `test.skip` when `E2E_TESTNET_READY` is unset. Prerequisites: a deployed contract, and `demo/.env.local` populated as above. The Vitest suite (`npm run test -w @aztec-private-voting/react`) and the Noir tests (`cd contracts && nargo test`) need no infrastructure.

## Current gaps

What an integrator cannot do yet:

- **Real eligibility proofs.** `useEligibility` does not generate ZK proofs in the browser; it returns a placeholder field (`'0x01'` in open mode, the token address or allowlist root otherwise) which the contract's `verify_eligibility` checks as a field value. Token-gated and allowlist eligibility are therefore not cryptographically enforced through this path.
- **Ballot privacy against chain observers.** Ballots are anonymous (the double-vote guard is a private claim, the fingerprint is random), but the choice is an argument to the public `record_vote` call and the tally is public storage. Only the application layer (the `get_final_tally` gate, the UI) withholds results before finalization; an encrypted tally is roadmap item M2.
- **Participation privacy.** The fingerprint is `poseidon2(voteId, walletAddress)`, so anyone with a wallet address can check whether it voted. See [receipt.md](receipt.md), threat model item (d).
- **Production wallets.** The demo uses an ephemeral embedded wallet with a localStorage secret; there is no integration with user-held wallets, and the demo's bootstrap bypasses the library's typed `BrowserAztecOptions` (see Provider setup).
- **A managed service.** Nothing is hosted. Integrating means running your own frontend, PXE access, and deployment pipeline.
- **Production deployment.** Aztec Alpha v4 has a known vulnerability (disclosed March 2026; patch expected with v5). The testnet contract is for demonstration only.
