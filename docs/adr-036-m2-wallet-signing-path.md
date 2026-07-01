# ADR-036: M2 Wallet Signing Path — EIP-191 vs. ADR-036 vs. Raw

**Date:** 2026-06-22  
**Status:** Accepted — Path C (EIP-191) implemented (tick-4365)  
**Affects:** `contracts/src/main.nr` (`cast_vote_babylon_v2`), `packages/react/src/hooks/useM2Signing.ts`  
**Blocking:** Testnet redeployment, Wave 3 grant submission

---

## Context

The M2 circuit (`cast_vote_babylon_v2`) proves secp256k1 key ownership by
verifying an in-circuit ECDSA signature. The circuit currently expects the
frontend to pass the **raw 32-byte SHA-256 challenge** as the signed digest:

```
challenge = sha256(encode_field(title_hash) || encode_field(root_field))
```

The circuit calls:
```noir
let sig_valid = ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, challenge);
```

Here, `challenge` IS the 32-byte message digest passed to the ECDSA verifier —
i.e., the circuit treats `challenge` as an already-hashed message.

**The problem:** No production wallet signs a raw 32-byte digest without
wrapping it first. Both major wallet stacks add a prefix:

| Wallet stack | Signing API | What actually gets signed |
|---|---|---|
| Cosmos (Keplr, Leap) | `signArbitrary(chainId, signer, data)` | `sha256(ADR-036-protobuf-envelope(data))` |
| EVM (MetaMask, Ledger) | `personal_sign(data)` | `keccak256("\x19Ethereum Signed Message:\n32" \|\| data)` |

The raw 32-byte path (`mode='raw'` in `useM2Signing.ts`) works for CLI and
integration tests. It is **not viable for any production browser wallet**.

---

## Decision: Three Paths

### Path A — Update circuit to verify ADR-036 SignDoc (Cosmos wallets)

The circuit receives the signed ADR-036 message hash and reconstructs the
SignDoc in-circuit to verify it matches the expected challenge.

**What Keplr signs under ADR-036:**
```
sig = ecdsa(sha256(protobuf(SignDoc {
  chain_id: "...",
  account_number: "0",
  sequence: "0",
  memo: "",
  fee: { gas: "0", amount: [] },
  msgs: [{ type: "sign/MsgSignData", value: { signer, data: base64(challenge) } }]
})))
```

**Circuit changes required:**
- Add `verify_adr036_signature(chain_id, signer_bech32, data, sig, pubkey)` function
- In-circuit: base64-encode `challenge` bytes, insert into hardcoded protobuf
  template, sha256-hash the result, then call `ecdsa_secp256k1::verify_signature`
- Requires in-circuit base64 encoding (~12-byte alphabet lookup × 43 output chars)
  and protobuf field serialization — variable-length fields, type+length varint prefixes

**Gate cost estimate:**
- Base64 encode 32 bytes → 44 chars: ~2,000 constraints
- Protobuf serialize full SignDoc with templated fields: ~8,000–15,000 constraints
  (string field lengths vary with signer bech32 and chain_id)
- SHA-256 of ~300-byte SignDoc: ~10,000 constraints
- **Total overhead over raw: ~20,000–30,000 constraints** (~20-30% on top of the
  ~100k from the secp256k1 verify itself)

**Additional risks:**
- ADR-036 has no canonical spec — Keplr and Leap have had diverging `chain_id`
  behaviour (Keplr sometimes passes `""` for cosmos-sdk chains, sometimes the
  actual chain ID). The circuit must match the wallet's exact output.
- Keplr's `signArbitrary` JSON-encodes the message field as a string, not bytes,
  before passing to the protobuf layer. Wallet source inspection required before
  finalising the in-circuit template.
- Nargo/Barretenberg `sha256_var` supports variable-length inputs up to a
  maximum N. Ensure the SignDoc length with real chain IDs stays under the bound.

**Verdict:** Correct for Cosmos-native voter populations (Babylon stakers) but
carries real implementation risk from wallet API inconsistencies. Not the right
primary path for a grant demo targeting the EVM-native DAO governance market.

---

### Path B — Raw secp256k1 (current implementation)

No circuit changes. The frontend uses `@noble/curves/secp256k1` to sign the
raw 32-byte challenge directly, with no wallet wrapper.

```ts
// useM2Signing.ts — mode='raw'
const sig = secp256k1.sign(challenge, privateKeyBytes, { lowS: true });
```

**What works:** Unit tests, Playwright tests, CLI scripts, developer demos.

**What doesn't work:** Any production browser wallet. No MetaMask, no Keplr,
no Ledger, no WalletConnect provider exposes a raw 32-byte signing API in the
browser. The voter would need to paste their private key into the UI — a
security non-starter.

**Verdict:** Keep as the `mode='raw'` test path. Not a production option.

---

### Path C — EIP-191 `personal_sign` (EVM wallets) ✅ Recommended

MetaMask, Ledger, WalletConnect, Coinbase Wallet, and Gnosis Safe all support
`personal_sign`. The signing spec is simple and fully standardised (EIP-191):

```
wallet signs: keccak256("\x19Ethereum Signed Message:\n32" || challenge_32bytes)
```

**Circuit changes required (minimal):**
Replace the current `challenge` input with a wrapping step:

```noir
// Before (raw challenge, current):
let sig_valid = ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, challenge);

// After (EIP-191 wrapped):
// prefix = b"\x19Ethereum Signed Message:\n32" — 28 bytes, compile-time constant
let prefix: [u8; 28] = [0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
                         0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
                         0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
                         0x3a, 0x0a, 0x33, 0x32];
let mut wrapped: [u8; 60] = [0; 60];
for i in 0..28 { wrapped[i] = prefix[i]; }
for i in 0..32 { wrapped[28 + i] = challenge[i]; }
let msg_hash: [u8; 32] = std::hash::keccak256(wrapped, 60);
let sig_valid = ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, msg_hash);
```

**Gate cost estimate:**
- `std::hash::keccak256` of 60 bytes: ~3,000–5,000 constraints
- **Total overhead over raw: <5% of the existing ~100k constraint circuit**

**Frontend change (useM2Signing.ts):**
```ts
// Replace:
const sigParts = rawSign(challenge, input.privateKeyHex!);

// With (EIP-191 via MetaMask):
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
// personal_sign encodes challenge as hex string; ethers handles the 0x prefix
const sig = await signer.signMessage(challenge); // ethers v6 auto-wraps EIP-191
const { r, s, v } = ethers.Signature.from(sig);
```

**Why EIP-191 is the right primary path:**

1. **Audience match.** The DAO governance market is overwhelmingly EVM-native.
   Compound, Nouns, Uniswap, MakerDAO — all MetaMask-first. The Aztec Wave 3
   grant reviewers and potential adopters are EVM developers. The Cosmos voter
   use case is important but is a secondary market compared to the EVM DAO space.

2. **Spec stability.** EIP-191 is a single-page, frozen standard. The in-circuit
   prefix is a compile-time constant. ADR-036 is a living Cosmos SDK document;
   Keplr's implementation has diverged from it. Fewer moving parts.

3. **Minimal circuit diff.** 10 lines of Noir vs. 50-100 lines of protobuf
   serialization logic. Smaller circuit changes have lower audit surface.

4. **Ledger support.** Hardware wallet support via Ledger + EIP-191 is
   production-grade. Raw signing on Keplr hardware wallets is not supported.

5. **Grant demo readiness.** A MetaMask-compatible demo can be shipped in days
   with the current `useM2Signing.ts` structure. Path A requires ADR-036
   reverse-engineering and wallet API validation before any circuit work can start.

---

## Recommendation

**Choose Path C.** Make EIP-191 `personal_sign` the production signing path
for the Wave 3 grant demo and testnet deployment.

**Preserve Path B** (`mode='raw'`) for CLI tooling, Playwright tests, and the
existing unit test vectors. Do not remove it.

**Defer Path A** (ADR-036) to a follow-on milestone if/when Cosmos-native voter
UX is a stated requirement. Document it as a named extension point in
`useM2Signing.ts` rather than the primary path.

---

## Implementation plan (Path C)

**Estimated effort: 1-2 days**

### 1. Circuit change — `contracts/src/main.nr`

In `cast_vote_babylon_v2`, replace the raw challenge verification with the
EIP-191 wrapped version. The challenge computation stays the same; only the
final ECDSA verification step changes.

```noir
// Add to imports:
use std::hash::keccak256;

// Replace in cast_vote_babylon_v2 verification block:
let eip191_prefix: [u8; 28] = [
    0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
    0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
    0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
    0x3a, 0x0a, 0x33, 0x32
];
let mut eip191_msg: [u8; 60] = [0; 60];
for i in 0..28 { eip191_msg[i] = eip191_prefix[i]; }
for i in 0..32 { eip191_msg[28 + i] = challenge[i]; }
let msg_hash = keccak256(eip191_msg, 60);
let sig_valid = ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, msg_hash);
assert(sig_valid, "invalid secp256k1 signature: not the key owner");
```

### 2. Noir unit test update — `m2-sig-tests/`

Update the test vector generator to produce EIP-191-wrapped signatures:

```ts
// In the test harness (TypeScript side):
import { keccak256, toBytes } from 'viem';

const EIP191_PREFIX = new Uint8Array([
  0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
  0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
  0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
  0x3a, 0x0a, 0x33, 0x32
]);
const wrapped = new Uint8Array(60);
wrapped.set(EIP191_PREFIX);
wrapped.set(challenge, 28);
const msgHash = keccak256(wrapped); // returns 0x-prefixed hex
const { r, s } = secp256k1.sign(toBytes(msgHash), privateKey, { lowS: true });
```

The Prover.toml and circuit witness must be regenerated with the new
EIP-191-wrapped signatures.

### 3. React hook update — `packages/react/src/hooks/useM2Signing.ts`

Add `mode: 'eip191'` to `M2SignMode`:

```ts
export type M2SignMode = 'raw' | 'eip191' | 'keplr';
```

Implement the EIP-191 branch:
```ts
case 'eip191': {
  if (!window.ethereum) throw new Error('MetaMask not found');
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  // ethers v6 signMessage auto-applies EIP-191 wrapping
  // challenge must be passed as Uint8Array (not hex string) for exact byte treatment
  const rawSig = await signer.signMessage(challenge); // challenge: Uint8Array
  const { r, s } = ethers.Signature.from(rawSig);
  // Ensure low-S (BIP-62); ethers v6 normalises by default for signMessage
  sigParts = {
    pubkey_x: await getPublicKeyBytes(signer, 'x'),
    pubkey_y: await getPublicKeyBytes(signer, 'y'),
    sig_r: hexToBytes(r),
    sig_s: hexToBytes(s),
  };
  break;
}
```

Note: ethers v6's `signMessage(Uint8Array)` applies EIP-191 and returns the raw
65-byte ECDSA signature (r, s, v). The public key must be recovered or fetched
separately — use `provider.send('eth_getEncryptionPublicKey', [address])` or
recover from signature + hash using `ethers.recoverAddress`.

**Simpler alternative for demos:** use `eth_sign` directly via `window.ethereum`
with the pre-hashed EIP-191 message, then recover pubkey. Avoids ethers key
management complexity for the initial demo.

### 4. Deploy config update

Set signing mode in `scripts/deploy.config.babylon-v2.json`:
```json
{
  "signingPath": "eip191",
  "note": "Voters sign with MetaMask personal_sign. Path A (ADR-036/Keplr) deferred."
}
```

### 5. GRANT.md + forum post update

Update the ADR-036 section in `docs/forum-post-grant-application.md` to
remove the open question and state the chosen path. Add one sentence:

> M2 signing uses EIP-191 `personal_sign` (MetaMask/Ledger/WalletConnect) as
> the primary wallet path. ADR-036 Keplr support is a documented extension.

---

## Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| `std::hash::keccak256` API changes between Nargo versions | Low | Pinned to Nargo 1.0.0-beta.22; test against target version before merge |
| Low-S normalisation on EVM side | Medium | ethers v6 `signMessage` normalises; add assertion in Prover.toml test harness |
| Public key recovery complexity | Low | Use deterministic test key for unit tests; defer UX recovery to demo sprint |
| keccak256 gate count higher than estimated | Low | Circuit budget headroom: ~100k gates secp256k1 + 5k keccak ≪ Aztec private fn limit (~4M) |
| Cosmos users can't vote in EIP-191 mode | Certain | Known trade-off; document Path A clearly as a named extension for Cosmos expansion |

---

## References

- EIP-191: https://eips.ethereum.org/EIPS/eip-191
- ADR-036 (Cosmos SDK): https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-036-arbitrary-signature.md
- Noir `std::hash::keccak256` docs: https://noir-lang.org/docs/noir/standard_library/cryptographic_primitives/hashes
- `useM2Signing.ts` — Path A/B/C stub: `packages/react/src/hooks/useM2Signing.ts`
- M2 design spec: `docs/m2-secp256k1-ownership-proof-design.md`
- Security review (F2, F3 findings): `docs/security-review-2026-06-22.md`
