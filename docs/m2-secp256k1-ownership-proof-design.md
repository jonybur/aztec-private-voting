# M2: In-Circuit secp256k1 Ownership Proof — Design Specification

**Date:** 2026-06-22  
**Status:** Design (pre-implementation)  
**Author:** @jonybur-oc

---

## 1. Problem statement

The current `cast_vote_babylon` entrypoint proves Merkle *membership* — that a
`(bbn1…address, balance)` pair is a leaf in the committed snapshot tree — but
does not prove *ownership* of that Cosmos address. The per-holder nullifier is:

```noir
let holder_nullifier = hash_bytes_as_field(leaf);
```

`leaf = sha256(address_bytes || balance)` is computed from fully public snapshot
data. Any observer who has the snapshot (it is published for transparency) can
enumerate all 108,637 holders and pre-compute every valid nullifier. They can
then submit ballots on behalf of holders before the legitimate holder votes,
exhausting that holder's single-use claim.

**M2 closes this gap** by requiring an in-circuit secp256k1 signature check.
Without the holder's Cosmos private key, an attacker cannot produce a valid
proof, regardless of what they know about the snapshot.

---

## 2. Solution overview

The voter signs a vote-specific challenge with their Cosmos secp256k1 private
key. The signature and compressed public key are passed as private witnesses to
`cast_vote_babylon`. The circuit:

1. Verifies the secp256k1 signature against the vote challenge.
2. Derives the Cosmos `hash160 = ripemd160(sha256(pubkey))` from the public key.
3. Asserts `hash160` matches the Merkle leaf's address commitment.
4. Derives the nullifier from signature material — not from the public leaf.

An attacker with the snapshot can compute Merkle proofs for any holder but
cannot produce a valid secp256k1 signature without the holder's private key.
The circuit rejects any witness that lacks a valid signature.

---

## 3. Snapshot format change (M2 leaf)

**M1 leaf** (current):  
```
leaf = sha256(address_bytes_bech32[45] || balance_be[8])
```

`address_bytes_bech32` is the UTF-8 bech32 string "bbn1…" (42 chars, padded to
45 bytes). Bech32 decode in-circuit is possible but expensive — 32 × 5-bit
character lookups plus a bit-packing loop.

**M2 leaf** (proposed):  
```
leaf = sha256(hash160[20] || balance_be[8])
```

`hash160 = ripemd160(sha256(compressed_pubkey))` is the raw 20-byte Cosmos
address (the witness program before bech32 encoding). This removes bech32
decode from the circuit entirely. The Merkle tree is regenerated at M2
snapshot time using this simpler leaf format.

**Trade-off:** M1 and M2 snapshot files are not interchangeable. Clients must
know which format the deployed vote uses. This is recorded in `VoteConfig` via
a new `snapshot_version: u8` field (0 = M1 bech32, 1 = M2 hash160). The
`cast_vote_babylon` circuit dispatches on this field.

---

## 4. New circuit interface

```noir
#[external("private")]
fn cast_vote_babylon_v2(
    vote_choice: u8,
    // existing Merkle witnesses
    balance: u64,
    merkle_path: [[u8; 32]; 20],
    merkle_indices: [bool; 20],
    // M2 ownership witnesses (all private, never visible on-chain)
    pubkey: [u8; 33],       // compressed secp256k1 public key (02/03 prefix + 32 bytes)
    sig_r: [u8; 32],        // ECDSA signature R value
    sig_s: [u8; 32],        // ECDSA signature S value
)
```

`address_bytes` is removed from the witness list. The address is derived inside
the circuit as `hash160 = ripemd160(sha256(pubkey))`, which is then used to
compute the Merkle leaf.

---

## 5. Challenge construction

The signed message must be vote-specific to prevent replay across different
votes (a signature from one vote cannot be reused in another):

```
challenge = sha256(contract_address_bytes[32] ++ vote_id_bytes[32])
```

Where:
- `contract_address_bytes` = the deployed contract's AztecAddress, zero-padded
  to 32 bytes big-endian.
- `vote_id_bytes` = the vote's `title_hash` field from `VoteConfig`, 32 bytes.
  Alternatively, a monotonic vote sequence number committed in the config.

The 64-byte concatenated input is SHA-256 hashed to produce a 32-byte challenge
field. This challenge is passed to the secp256k1 verifier as the message digest.

**Frontend responsibility:** The wallet (Keplr/Leap) signs `challenge` using
the holder's Cosmos secp256k1 key via `signBytes` or `signArbitrary`. The
resulting `(r, s)` pair and compressed pubkey are passed to the circuit.

---

## 6. In-circuit steps

```noir
// Step 1: Verify secp256k1 signature on challenge
let challenge = compute_challenge(contract_address, config.title_hash);
// std::ec::secp256k1 — Noir stdlib (verified available in noir ≥ 0.19)
let sig = secp256k1::Signature { r: sig_r, s: sig_s };
let pk  = secp256k1::PublicKey::from_compressed(pubkey);
assert(pk.verify_dsa_sig(sig, challenge), "invalid secp256k1 signature");

// Step 2: Derive hash160 from public key
let sha2_of_pk = sha256_var(pubkey, 33);       // SHA-256(pubkey)
let hash160    = ripemd160(sha2_of_pk);         // RIPEMD-160(SHA-256(pubkey))
// See §Risk 1 for RIPEMD-160 availability

// Step 3: Verify Merkle membership with M2 leaf
let leaf = compute_leaf_v2(hash160, balance);   // sha256(hash160 || balance_be)
verify_merkle_path(leaf, merkle_path, merkle_indices, root_bytes);

// Step 4: Derive holder nullifier from signature material
// sig_s is unique per (privkey, challenge) under RFC 6979;
// including sig_r prevents trivial nullifier collisions.
let nullifier_input: [u8; 64] = concat_bytes(sig_r, sig_s);
let holder_nullifier = hash_bytes_as_field(sha256_var(nullifier_input, 64));

self.enqueue_self.record_vote(vote_choice, 1, holder_nullifier);
```

**Why `sha256(sig_r || sig_s)` for the nullifier:**
- `sig_s` under RFC 6979 is deterministic given `(privkey, challenge)`.
- `sig_r` is also deterministic (derived from the RFC 6979 nonce).
- Combined, `(r, s)` is unique per `(privkey, challenge)`.
- An attacker without `privkey` cannot compute the correct `(r, s)` pair,
  so cannot compute the nullifier before the legitimate holder votes.
- Including `sig_r` prevents a theoretical second-preimage on `sig_s` alone.

---

## 7. `compute_leaf_v2` in merkle.nr

```noir
// M2 leaf: sha256(hash160[20] || balance_be[8])
pub fn compute_leaf_v2(hash160: [u8; 20], balance: u64) -> [u8; 32] {
    let mut input = [0u8; 28];
    for i in 0..20 { input[i] = hash160[i]; }
    input[20] = ((balance >> 56) & 0xff) as u8;
    input[21] = ((balance >> 48) & 0xff) as u8;
    input[22] = ((balance >> 40) & 0xff) as u8;
    input[23] = ((balance >> 32) & 0xff) as u8;
    input[24] = ((balance >> 24) & 0xff) as u8;
    input[25] = ((balance >> 16) & 0xff) as u8;
    input[26] = ((balance >>  8) & 0xff) as u8;
    input[27] = ((balance      ) & 0xff) as u8;
    sha256_var(input, 28)
}
```

---

## 8. TypeScript snapshot generator changes

`scripts/synthetic-snapshot.ts` must be updated to produce M2 leaves:

```typescript
import { ripemd160 } from '@noble/hashes/ripemd160';
import { sha256 }    from '@noble/hashes/sha256';

// Given a bech32 Cosmos address string, decode to 20-byte hash160
function addressToHash160(bech32Addr: string): Uint8Array {
  const { words } = bech32.decode(bech32Addr);
  return new Uint8Array(bech32.fromWords(words)); // 20 bytes
}

// Or compute from pubkey directly (preferred for M2):
function pubkeyToHash160(compressedPubkey: Uint8Array): Uint8Array {
  return ripemd160(sha256(compressedPubkey));
}

// M2 leaf
function computeLeafV2(hash160: Uint8Array, balance: bigint): Uint8Array {
  const buf = new Uint8Array(28);
  buf.set(hash160, 0);
  const view = new DataView(buf.buffer);
  view.setBigUint64(20, balance, false); // big-endian
  return sha256(buf);
}
```

The snapshot JSON schema gains a `version: 2` field. The contract's
`cast_vote_babylon_v2` verifies against the v2 Merkle root stored in
`VoteConfig.token_address`.

---

## 9. Risk register

### Risk 1: RIPEMD-160 in Noir

Noir's standard library (`noir_stdlib`) includes SHA-256, SHA-512, Keccak-256,
Blake2s, Pedersen, and Poseidon. **RIPEMD-160 is not confirmed in the Noir
stdlib as of v0.31/v0.32.**

**Fallback A — External Noir library:**  
Several community Noir packages implement RIPEMD-160 (e.g., `noir-ripemd160`
on GitHub). Drop-in if compatible with the target `nargo` version. Requires
dependency audit.

**Fallback B — SHA-256d address derivation (non-standard):**  
Replace `ripemd160(sha256(pk))` with `sha256(sha256(pk))[12:]` (last 20 bytes).
This is *not* standard Cosmos address derivation and produces different
addresses, so the snapshot must be generated with the same hash scheme. For a
research prototype this is acceptable; document the deviation clearly in
GRANT.md and deployment notes.

**Recommended path:** Attempt Fallback A first (check `nargo add` compatibility).
If blocked, use Fallback B and update `compute_leaf_v2` and the TypeScript
generator to match. The circuit logic is identical; only the hash function
name changes.

### Risk 2: secp256k1 verification proving time

Noir's `std::ec::secp256k1::verify_signature` requires elliptic curve
arithmetic over a non-native field (secp256k1 ≠ BN254 / Grumpkin which Aztec
uses internally). Non-native arithmetic is expensive in Barretenberg:
estimated 80k–120k gates for one secp256k1 ECDSA verify.

For UltraHonk (the prover Aztec uses), a 100k-gate circuit proves in ~2-3s in
the browser on M2-class hardware. For older hardware or low-power mobile,
this may reach 8-12s. **This is within acceptable range** for a governance vote
(voters tolerate longer waits for meaningful actions). Measure on the
demo hardware before the M2 sprint starts; if unacceptable, consider
ECDSA batching or a Schnorr variant (cheaper gate count).

### Risk 3: Wallet signing API

Cosmos wallets (Keplr, Leap) expose `signArbitrary(chainId, signer, message)`
which returns an ECDSA signature over `SHA256(message)`. The circuit needs
the message to be exactly the `challenge` bytes computed above. Some wallets
prepend a human-readable prefix before hashing; confirm the exact signing
scheme against the Keplr source before finalizing the challenge format.

The safest approach: sign the raw 32-byte challenge with `sign(challenge, privkey)`
via the wallet's `signBytes` API if available, bypassing any prefix injection.

### Risk 4: Receipt ID collision in record_vote

Unrelated to M2 but noted during this review: `receipt_id` in `cast_vote`
(the non-Babylon path) is client-generated random. If two voters happen to
generate the same random Field, the second voter's call will fail with
"receipt already used." The probability is 1/|Fr| ≈ 2^{-254} per pair —
negligible in practice — but worth a comment in the contract.

---

## 10. Implementation checklist

- [x] Confirm `std::ecdsa_secp256k1` API in target Nargo version — Noir 0.30 stdlib confirmed; uses `(pubkey_x[32], pubkey_y[32], sig[64], hashed_msg[N])` interface *(tick-3605)*
- [x] Resolve RIPEMD-160 — stdlib absent; using Fallback B (SHA-256d: `sha256(sha256(x||y))[12:]`) with clear PROTOTYPE DEVIATION comments *(tick-3605)*
- [x] Add `compute_leaf_v2` to `merkle.nr` *(tick-3605)*
- [x] Add `derive_hash160_sha256d` helper to `merkle.nr` *(tick-3605)*
- [x] Add `verify_baby_eligibility_v2` to `merkle.nr` *(tick-3605)*
- [x] Add `cast_vote_babylon_v2` to `main.nr` *(tick-3605)* — uses `std::ecdsa_secp256k1::verify_signature`; challenge = `sha256(title_bytes || root_bytes)`; nullifier = `hash_bytes_as_field(sha256(sig))`
- [ ] Update `synthetic-snapshot.ts` to produce M2 leaves (`version: 2`) using same SHA-256d derivation
- [ ] Update `scripts/deploy-testnet.ts` to use M2 Merkle root encoding
- [ ] Update React layer to call `wallet.signArbitrary(challenge)` and pass `(pubkey_x, pubkey_y, sig)` to circuit input
- [x] Add Noir unit tests: valid signature + Merkle pass; invalid signature fail; wrong pubkey fail *(tick-3613, commit c3e11e6)*
  - 9 tests in `contracts/src/merkle.nr` (derive_hash160_sha256d, compute_leaf_v2, verify_baby_eligibility_v2)
  - 4 tests in `m2-sig-tests/` standalone package (secp256k1 valid/invalid/wrong-pubkey/wrong-challenge)
  - **Discovered: Barretenberg requires low-S form (s ≤ n/2, BIP-62). Wallet frontend must normalize s before passing to circuit.**
  - Test vector: secp256k1 G point (privkey=1), sha256(0x00×64) challenge
- [x] Compile with `nargo check` on a machine with nargo installed — flag and fix any type/API mismatches *(implicit: 20/20 tests pass under nargo 1.0.0-beta.22)*
- [ ] Measure proving time on target browser hardware
- [ ] Update GRANT.md M2 section with confirmed derivation approach and proving-time measurement

### Challenge format (implemented)
```
challenge = sha256( encode_field_as_root(config.title_hash) || encode_field_as_root(root_field) )
```
Both inputs are 32-byte field encodings (0x00 padding + 31 field bytes).
Change from original spec (which used contract_address || title_hash):
using title_hash || root achieves the same replay-prevention goal while
avoiding the `this_address()` API dependency in private context.

### SHA-256d address derivation (implemented)
```
hash160 = sha256( sha256( pubkey_x[32] || pubkey_y[32] ) )[12..32]
```
Same function must be implemented in `synthetic-snapshot.ts` and documented
in GRANT.md as a named deviation before grant submission.

---

## 11. What M2 does NOT solve

- **Concurrent observation coercion:** An attacker watching the voter's screen
  during signing knows which option they chose (it's visible in the UI).
  The ownership proof closes the snapshot-forwarding attack; it does not
  address shoulder-surfing or malware on the voter's device.
- **Front-running within the same block:** If an attacker intercepts the
  signed proof *after* it is submitted but before it lands on-chain, they
  could potentially replay it in the same block. Aztec's private kernel
  applies the single-use claim before the proof hits the sequencer, so
  ordering within a block is handled, but this is worth confirming against
  v5 sequencer semantics.
- **Vote direction privacy on-chain:** M1 limitation still applies — `vote_choice`
  is a public argument of the enqueued `record_vote` call. Choices are
  anonymous (unlinked to an address) but not hidden. Hidden tallies
  (encrypted choice, decrypt-on-finalize) are M3 scope.

---

## Related documents

- `docs/f2-atomicity-analysis-2026-06-22.md` — F2 receipt-collision analysis (separate attack)
- `docs/proof-of-inclusion-ux-pattern-2026-06-22.md` — UX framing for what M2 enables
- `GRANT.md` — M2 roadmap summary for grant reviewers
- `contracts/src/main.nr` — current `cast_vote_babylon` implementation
- `contracts/src/merkle.nr` — `verify_baby_eligibility`, `compute_leaf`
