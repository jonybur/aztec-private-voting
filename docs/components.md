# Component and hook reference

Everything exported from `@aztec-private-voting/react`, grouped by flow stage. All components take a `VoteConfig` (defined below) describing the vote and the contract it lives at. Components are unstyled apart from `apv-*` class names; import `@aztec-private-voting/react/src/styles.css` for the default styles.

## Shared types

```ts
type EligibilityMode = 'open' | 'token' | 'allowlist';

interface VoteConfig {
  voteId: string;
  title: string;
  description: string;
  options: string[];
  startTime: number;        // ms epoch
  endTime: number;          // ms epoch
  quorum: number;
  eligibilityMode: EligibilityMode;
  tokenAddress?: string;    // required when eligibilityMode === 'token'
  minTokenBalance?: string; // required when eligibilityMode === 'token'
  allowlistRoot?: string;   // required when eligibilityMode === 'allowlist'
  contractAddress: string;
}

interface EligibilityProof {
  voteId: string;
  proof: string;
  generatedAt: number;
}

// Exported as VoteReceiptData (the component is named VoteReceipt)
interface VoteReceipt {
  voteId: string;
  voteTitle: string;
  receiptId: string;        // the vote fingerprint, 0x-prefixed hex
  txHash: string;
  timestamp: number;
  contractAddress: string;
}

interface VoteTally {
  voteId: string;
  totalVotes: number;
  quorum: number;
  quorumMet: boolean;
  finalized: boolean;
  results: VoteOptionResult[];
  finalizedTxHash?: string;
}

interface VoteOptionResult {
  option: string;
  count: number;
  percentage: number;
}

interface AztecConnection {
  pxeUrl: string;
  walletAddress: string;
}
```

## Provider and connection

### `<AztecProvider />`

Context provider every hook requires. Hooks throw if used outside it.

```ts
interface AztecProviderProps {
  client: AztecClient | null;
  loading?: boolean;        // default false
  error?: string | null;    // default null
  children: ReactNode;
}

interface AztecClient {
  pxe: PXE;
  wallet: AccountWalletWithSecretKey;
}
```

```tsx
<AztecProvider client={state.client} loading={state.loading} error={state.error}>
  <App />
</AztecProvider>
```

### `useAztec(): { client: AztecClient | null; loading: boolean; error: string | null }`

Reads the raw context. Throws if there is no `<AztecProvider>` above.

### `useAztecClient(): AztecClient`

Like `useAztec` but throws if the client is not connected yet. Used by the action hooks (`useVote`, `useDeployVote`, `useFinalizeVote`, `useVerifyReceipt`).

### `useBrowserAztecClient(options: BrowserAztecOptions)`

Connects to a PXE in the browser and builds the client state to feed `<AztecProvider>`.

```ts
interface BrowserAztecOptions {
  pxeUrl: string;
  createWallet: (pxe: PXE) => Promise<AccountWalletWithSecretKey>;
}
// returns { client, loading, error } - the same shape AztecProvider accepts
```

```tsx
const state = useBrowserAztecClient({ pxeUrl, createWallet });
return <AztecProvider {...state}>{children}</AztecProvider>;
```

### `setPrivateVotingArtifact(artifact: ContractArtifact): void`

Registers the compiled `PrivateVoting` artifact. Must be called once at startup before any hook touches the contract; otherwise contract loading throws with instructions. The artifact is the JSON produced by `npm run build:contracts` (`contracts/target/private_voting-PrivateVoting.json`).

## Eligibility

### `<VoteEligibilityProof />`

Checks eligibility and reports the result through callbacks. Renders status text (connecting / checking / eligible / ineligible / error); silent components are the parent's job to compose.

```ts
interface VoteEligibilityProofProps {
  config: VoteConfig;
  onEligible: (proof: EligibilityProof) => void;
  onIneligible: (reason: string) => void;
}
```

```tsx
<VoteEligibilityProof config={config} onEligible={setProof} onIneligible={setReason} />
```

### `useEligibility(config: VoteConfig)`

```ts
type EligibilityStatus = 'connecting' | 'checking' | 'eligible' | 'ineligible' | 'error';
// returns { status: EligibilityStatus; proof: EligibilityProof | null; reason: string | null }
```

Note: in the current implementation the returned `proof` is a placeholder field (`'0x01'` for open mode, the token address or allowlist root otherwise), not a browser-generated ZK proof. See [integration.md](integration.md), "Current gaps".

## Ballot

### `<PrivateBallot />`

The voting form: radio options, a submit button, deadline guards (renders a closed/not-open message outside the voting window), and translated contract errors.

```ts
interface PrivateBallotProps {
  config: VoteConfig;
  eligibilityProof: EligibilityProof;
  onVoteCast: (receipt: VoteReceiptData) => void;
}
```

```tsx
<PrivateBallot config={config} eligibilityProof={proof} onVoteCast={setReceipt} />
```

### `useVote(config: VoteConfig)`

```ts
type VoteStatus = 'idle' | 'submitting' | 'cast' | 'error';

interface CastVoteInput {
  choice: number;                    // option index
  eligibilityProof: EligibilityProof;
}

// returns {
//   castVote: (input: CastVoteInput) => Promise<VoteReceiptData | null>;
//   status: VoteStatus;
//   error: string | null;           // translated to voter-facing copy
//   receipt: VoteReceiptData | null;
// }
```

Generates a random fingerprint client-side, sends `cast_vote(choice, eligibilityField, receiptId)`, and resolves to a `VoteReceiptData` on success or `null` on failure.

## Receipt

### `<VoteReceipt />`

The post-vote receipt: confirmation, the vote fingerprint (shortened, with copy button), the privacy claim, a primary "Download receipt" action, and a collapsed "How to verify" explainer.

```ts
interface VoteReceiptProps {
  receipt: VoteReceiptData;
  onDownload?: (receipt: VoteReceiptData) => void; // overrides the built-in JSON download
  onVerify?: (receipt: VoteReceiptData) => void;   // overrides the verifier link behavior
  verifierUrl?: string;                            // opened in a new tab if onVerify is not set
}
```

```tsx
<VoteReceipt receipt={receipt} verifierUrl="/closed" />
```

### `useVerifyReceipt(config: VoteConfig)`

```ts
type VerifyStatus = 'idle' | 'checking' | 'done' | 'error';

// returns {
//   verify: (fingerprint: string) => Promise<void>;
//   status: VerifyStatus;
//   result: boolean | null;  // true: counted, false: not found (when status === 'done')
//   error: string | null;
// }
```

Validates the fingerprint is 0x-prefixed hex, then simulates `verify_vote_counted` on the contract.

### `downloadReceipt(receipt: VoteReceiptData): void` and `serializeReceipt(receipt: VoteReceiptData): string`

`serializeReceipt` produces the receipt JSON (`version: 1`, `kind: 'aztec-private-voting-receipt'`, plus the receipt fields). `downloadReceipt` triggers a browser download of that JSON as `vote-receipt-<voteId>-<timestamp>.json`.

## Result

### `<VoteResult />`

Tally display with per-option bars, quorum status, an optional finalize-transaction link, a built-in receipt verifier, and an auditor panel shown after finalization.

```ts
interface VoteResultProps {
  config: VoteConfig;
  showVerificationLink?: boolean;  // default true - the "Verify your vote was counted" toggle
  txExplorerBase?: string;         // prefix for transaction links
  contractExplorerBase?: string;   // prefix for contract links in the auditor panel
  showAuditorPanel?: boolean;      // default true (renders only once finalized)
}
```

```tsx
<VoteResult config={config} txExplorerBase="https://explorer.example/tx/" />
```

### `useTally(config: VoteConfig)`

```ts
type TallyStatus = 'loading' | 'ready' | 'error';
// returns { tally: VoteTally | null; status: TallyStatus; error: string | null; refresh: () => void }
```

Reads `is_finalized` and `get_vote_count`; per-option counts come from `get_final_tally(i)` and are only populated after finalization (zero before).

## Admin and facilitator

### `<VoteAdmin />`

Six-step wizard (title, options, eligibility, timing, quorum, review) that deploys a new `PrivateVoting` contract. Validates each step (at least two unique options, token/allowlist fields present, end after start, quorum >= 1; up to 8 options).

```ts
interface VoteAdminProps {
  onDeployed: (config: VoteConfig) => void;
}
```

```tsx
<VoteAdmin onDeployed={(config) => router.push(`/vote/${config.contractAddress}`)} />
```

### `useDeployVote()`

```ts
type DeployStatus = 'idle' | 'deploying' | 'deployed' | 'error';
type DeployDraft = Omit<VoteConfig, 'voteId' | 'contractAddress'>;

// returns {
//   deploy: (draft: DeployDraft) => Promise<VoteConfig | null>;
//   status: DeployStatus;
//   error: string | null;
// }
```

Deploys the contract with the connected wallet as admin and returns a complete `VoteConfig` (the deployed address becomes both `voteId` and `contractAddress`).

### `<VoteFacilitator />`

Dashboard for the vote operator: live vote count (count only - no per-option data before finalization), quorum and deadline status, and a finalize button that unlocks after the deadline once quorum is met. Shows the final tally after finalization.

```ts
interface VoteFacilitatorProps {
  config: VoteConfig;
  onFinalized?: (txHash: string) => void;
  pollIntervalMs?: number;   // vote-count polling, default 10000
}
```

```tsx
<VoteFacilitator config={config} onFinalized={(txHash) => log(txHash)} />
```

### `useVoteCount(config: VoteConfig, options?: { intervalMs?: number })`

```ts
type VoteCountStatus = 'loading' | 'ready' | 'error';
// returns { count: number | null; status: VoteCountStatus; error: string | null; refresh: () => void }
```

Polls `get_vote_count` (default every 10 seconds).

### `useFinalizeVote(config: VoteConfig)`

```ts
type FinalizeStatus = 'idle' | 'finalizing' | 'finalized' | 'error';
// returns {
//   finalize: () => Promise<string | null>;  // resolves to the tx hash
//   status: FinalizeStatus;
//   error: string | null;                    // translated (still open / already finalized / quorum not met)
//   txHash: string | null;
// }
```

## Formatting utilities

- `formatTimestamp(ms: number): string` - "May 18, 2026 at 06:03 PM" style.
- `shortenHex(hex: string, head = 6, tail = 4): string` - `0x1a8efe...a981`.
- `percent(part: number, total: number): number` - percentage rounded to one decimal; 0 when total is 0.
