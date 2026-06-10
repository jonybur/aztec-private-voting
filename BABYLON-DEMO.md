# Umbra × Babylon — Private Governance Demo

Private BABY token voting using ZK proofs. No bridging. No token movement.
BABY holders vote privately by proving their balance was in the snapshot — their address and choice are never revealed on-chain.

---

## Architecture

```
Babylon Genesis RPC
      │
      ▼
[babylon-snapshot.ts]  ←── queries /cosmos/bank/v1beta1/denom_owners/ubbn
      │  builds Merkle tree over all BABY holders at snapshot block
      │  outputs: merkle-root.json, merkle-tree.json, merkle-paths/<address>.json
      ▼
Ethereum / IPFS
      │  Merkle root stored on-chain (in VoteConfig.token_address field)
      │  Full tree hosted on IPFS (for voter path lookups)
      ▼
Browser (React demo)
      │  Voter connects Keplr/Leap wallet
      │  Fetches their Merkle path from IPFS
      │  Runs Noir circuit (WASM) in browser:
      │    verify_baby_eligibility(address, balance, min_balance, path, indices, root)
      │  Submits proof + encrypted vote to Aztec contract
      ▼
Aztec contract (cast_vote_babylon)
      │  Verifies Merkle proof inside the Noir circuit (private)
      │  Records nullifier (public)
      │  Increments tally (public)
      ▼
Tally revealed after vote closes
```

**Key property:** The Merkle proof is a private witness. Observers see only that a valid proof was submitted (via the nullifier), not which address voted or what they chose.

---

## Components

### 1. Noir circuit (`contracts/src/merkle.nr`)

```noir
pub fn verify_baby_eligibility(
    address_bytes: [u8; 45],   // bbn1... cosmos address (UTF-8)
    balance: u64,              // ubbn at snapshot
    min_balance: u64,          // required minimum
    path: [[u8; 32]; 20],      // Merkle siblings (depth 20 = 1M holders)
    indices: [u1; 20],         // direction bits
    root: [u8; 32],            // committed Merkle root
)
```

Proves: "I know an address+balance such that `sha256(address || balance)` is a leaf in the tree committed to by `root`, and `balance >= min_balance`."

Leaf hash: `sha256(address_utf8_bytes || balance_u64_be)`  
Tree hash: `sha256(left || right)` (standard binary Merkle)

### 2. Aztec contract entrypoint (`cast_vote_babylon`)

```noir
fn cast_vote_babylon(
    vote_choice: u8,
    nullifier: Field,
    address_bytes: [u8; 45],
    balance: u64,
    merkle_path: [[u8; 32]; 20],
    merkle_indices: [u1; 20],
)
```

The Merkle root is stored in `VoteConfig.token_address` (encoded as a Field). The circuit reconstructs and verifies it privately before queuing the public tally update.

### 3. Snapshot script (`scripts/babylon-snapshot.ts`)

Queries the Babylon Genesis Cosmos SDK bank module for all `ubbn` holders, builds the Merkle tree, and outputs:

- `snapshot/merkle-root.json` — root hash + `rootAsField` for VoteConfig
- `snapshot/merkle-tree.json` — full tree (host on IPFS)
- `snapshot/merkle-paths/<bbn1...>.json` — individual proof for each voter

### 4. Demo frontend (`demo/pages/babylon.tsx`)

React page that walks a voter through:
1. Connect Keplr/Leap wallet
2. Fetch Merkle path from IPFS
3. Generate ZK proof in browser (Noir WASM)
4. Submit private ballot
5. Receive vote fingerprint receipt

---

## Quickstart

### Run the local demo (no Babylon RPC needed)

```bash
# Verify the Merkle circuit logic locally
cd aztec-private-voting
npx ts-node scripts/babylon-demo.ts

# Try a specific voter address
npx ts-node scripts/babylon-demo.ts --voter bbn1demo_voter_bob_000000000000000000000ab
```

This runs the full TypeScript implementation of the Noir circuit logic against a 5-holder synthetic snapshot. Output includes the exact witness inputs for the Noir prover.

### Generate a live snapshot

```bash
npx ts-node scripts/babylon-snapshot.ts \
  --rpc https://rpc.nodejumper.io/babylon \
  --min-balance 1000000 \
  --out ./snapshot
```

Public Babylon Genesis RPC endpoints:
- `https://rpc.nodejumper.io/babylon`
- `https://babylon-rpc.polkachu.com`
- `https://babylon.rpc.kjnodes.com`

The script outputs `snapshot/merkle-root.json` with `rootAsField` — use this as `token_address` when deploying the vote contract.

### Compile the Noir circuit

```bash
# Requires nargo v5.0.0-nightly.20260525+
cd aztec-private-voting/contracts
nargo compile
```

### Deploy to Aztec testnet

```bash
# Set the Merkle root from your snapshot
export MERKLE_ROOT_FIELD=0x$(cat snapshot/merkle-root.json | python3 -c "import sys,json; print(json.load(sys.stdin)['rootAsField'][2:])")
export MIN_BALANCE_UBBN=1000000  # 1 BABY

export L1_PRIVATE_KEY=0x<your-sepolia-key>
bash scripts/bridge-and-deploy.sh
```

### Run the demo frontend

```bash
cd demo
cp .env.example .env.local
# Edit .env.local — set NEXT_PUBLIC_VOTE_CONTRACT_ADDRESS from deployment
npm run dev
# Open http://localhost:3000/babylon
```

---

## How the Merkle root is stored in the contract

Aztec `Field` elements hold 31 bytes (BN254 field size). A SHA-256 Merkle root is 32 bytes. We encode:

```
root_as_field = root[1..32]  (drop byte 0, always low entropy for SHA-256)
```

The contract decodes:
```noir
fn encode_field_as_root(f: Field) -> [u8; 32] {
    let field_bytes = f.to_be_bytes::<31>();
    let mut root = [0u8; 32];
    root[0] = 0;
    for i in 0..31 { root[i + 1] = field_bytes[i]; }
    root
}
```

Both `babylon-snapshot.ts` (`encodeRootAsField`) and `contracts/src/main.nr` (`encode_field_as_root`) implement matching encode/decode.

---

## Security properties

| Property | How it's achieved |
|----------|-------------------|
| **Vote privacy** | `vote_choice` and `address_bytes` are private witnesses in the Noir circuit — never transmitted or stored |
| **Double-vote prevention** | Nullifier (derived from private key + vote) is stored publicly; reuse is rejected |
| **Eligibility without bridging** | Cosmos snapshot committed on Ethereum; BABY tokens never move |
| **Receipt-freeness** | Vote fingerprint is the nullifier hash — proves your ballot was counted without revealing your choice |
| **Snapshot integrity** | Merkle root published on-chain before voting opens; tree hosted on IPFS with content hash |

---

## What this reuses from Umbra

| Umbra component | Reused in Babylon demo |
|-----------------|----------------------|
| `contracts/src/main.nr` | Extended with `cast_vote_babylon` entrypoint |
| `eligibility.nr` | Token-gated mode (non-zero proof check) replaces the placeholder |
| `merkle.nr` | New — Cosmos snapshot Merkle membership proof |
| `babylon-snapshot.ts` | New — Cosmos SDK bank module snapshot |
| `demo/pages/babylon.tsx` | New — Keplr/Leap wallet UI |
| Nullifier / double-vote logic | Unchanged |
| Vote receipt design | Unchanged |

---

## Known limitations (demo scope)

- **Browser proving**: Full in-browser Noir WASM proof generation requires the compiled circuit artifact (`private_voting-PrivateVoting.json` + Barretenberg WASM). The `babylon.tsx` demo currently simulates the proof step with a 3-second delay. Production wiring: `@noir-lang/noir_js` + `@aztec/bb.js`.
- **Keplr integration**: The demo uses a hardcoded address for simplicity. Production would use `window.keplr.getOfflineSigner('bbn-1')`.
- **IPFS path serving**: For scale, merkle-paths should be served from IPFS or a CDN. The snapshot script writes them locally; host with `ipfs add -r snapshot/`.
- **Tree depth**: Fixed at 20 (1M holders). Babylon Genesis had ~40K stakers at launch — depth 16 would suffice but 20 gives headroom.

---

## Relevant files

```
contracts/src/
  main.nr             — PrivateVoting contract (cast_vote_babylon added)
  merkle.nr           — verify_baby_eligibility, compute_leaf, verify_merkle_path
  eligibility.nr      — open / token / allowlist eligibility modes

scripts/
  babylon-snapshot.ts — Cosmos RPC → Merkle tree
  babylon-demo.ts     — Local demo runner (no RPC needed)

demo/pages/
  babylon.tsx         — React frontend for voters

GRANT.md              — Aztec grant application
SPEC.md               — Full system specification
```
