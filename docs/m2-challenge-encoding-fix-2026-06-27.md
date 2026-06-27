# M2 Challenge Encoding Fix — title_hash 32-byte Encoding

_Author: Jony Bursztyn · 2026-06-27 (tick-4009)_  
_Status: FIXED in this commit_  
_Severity: HIGH (pre-deployment; M2 path not yet live)_  
_Related: `docs/m2-secp256k1-ownership-proof-design.md §Challenge format`, `packages/react/src/hooks/useM2Signing.ts`_

---

## 1. The bug

`cast_vote_babylon_v2` computes a vote-specific challenge as:

```noir
challenge = sha256( title_hash_encoded[32] || root_bytes[32] )
```

**Before this fix**, the circuit encoded `title_hash` using `encode_field_as_root`:

```noir
// WRONG — before fix
let title_bytes = encode_field_as_root(config.title_hash);
```

`encode_field_as_root` takes only 31 bytes of the field element and pads with `0x00` at byte 0:

```noir
pub fn encode_field_as_root(f: Field) -> [u8; 32] {
    let field_bytes: [u8; 31] = f.to_be_bytes();  // ← truncates to 248 bits
    let mut root = [0u8; 32];
    root[0] = 0;                                   // ← always zero
    for i in 0..31 { root[i + 1] = field_bytes[i]; }
    root
}
```

Meanwhile, the TypeScript `buildM2Challenge` in `useM2Signing.ts` used `fieldToBytes32`:

```typescript
combined.set(fieldToBytes32(titleHash), 0);  // full 32 bytes
```

`fieldToBytes32` produces the **full 32-byte big-endian representation**, including the high byte.

---

## 2. The impact

`title_hash` is a poseidon2 hash — a BN254 field element uniformly distributed in `[0, p)`.
The BN254 prime `p ≈ 2^254`. Field elements `≥ 2^248` have a non-zero byte at position 0
in their 32-byte big-endian representation.

Fraction of field elements ≥ 2^248:

```
(p - 2^248) / p ≈ (2.189×10^76 - 4.523×10^74) / 2.189×10^76 ≈ 97.9%
```

**For ~97.9% of possible vote titles**, the circuit's `encode_field_as_root` produces a different
`challenge` than the TypeScript's `fieldToBytes32`. Consequence: the ECDSA signature produced
by MetaMask (via `personal_sign` over the TypeScript-computed challenge) would fail verification
in the circuit, causing `cast_vote_babylon_v2` to revert with:

```
"invalid secp256k1 signature: not the key owner (EIP-191)"
```

This is a proof-soundness bug (no false positives; the proof would just fail), not a security
vulnerability, but it would render ~97.9% of M2 vote deployments permanently broken at the
user-facing level: every voter would receive a signature rejection regardless of their key.

---

## 3. Why it wasn't caught

- `encode_field_as_root` was designed for Merkle root fields (`root_field`), which are always
  `< 2^248` by construction (the root is produced by `hash_bytes_as_field(sha256[...])`, which
  drops the SHA-256 output's byte 0 to fit in 31 bytes). For those, `encode_field_as_root`
  and `fieldToBytes32` produce the same result (`[0x00, ...]`).

- The Merkle root reuse made the mismatch invisible during the design phase.

- The `m2-sig-tests/` Noir tests verify `ecdsa_secp256k1::verify_signature` directly using
  a fixed 32-byte challenge — they do not go through `encode_field_as_root` or `fieldToBytes32`.

- `cast_vote_babylon_v2` has not been deployed to testnet (only `cast_vote` for open-mode
  votes has been exercised on the alpha testnet). The mismatch would first appear at
  the point of running an M2 governance vote.

---

## 4. The fix (applied in this commit)

**Circuit (`contracts/src/main.nr`)**:

```noir
// FIXED: use to_be_bytes::<32>() for title_hash — no truncation
// BN254 fields fit in 32 bytes (254 bits < 256 bits), no range check needed.
let title_bytes: [u8; 32] = config.title_hash.to_be_bytes();
```

`to_be_bytes::<32>()` on a BN254 field element is always valid (254 < 256 bits) and produces
the same 32 bytes that `fieldToBytes32` produces in TypeScript. No range check is added.

**TypeScript `buildM2Challenge`** (`packages/react/src/hooks/useM2Signing.ts`): no code change.
`fieldToBytes32` was already correct. Comment updated to explain the encoding choice.

**Design doc** (`docs/m2-secp256k1-ownership-proof-design.md`): challenge format section updated
to describe the corrected, asymmetric encoding rules.

---

## 5. Why root_field is unaffected

`root_field` is produced by `hash_bytes_as_field(sha256_output)`, which drops byte 0 of the
32-byte SHA-256 output and encodes bytes 1..31 as a big-endian integer. The result is always
`< 2^248`. For such values:

```
fieldToBytes32(rootField) == [0x00, rootField.to_be_bytes_31()]
                          == encode_field_as_root(root_field)
```

No change is needed for `root_field`. The circuit's `encode_field_as_root(root_field)` already
matches TypeScript's `fieldToBytes32(rootField)` for all inputs in this case.

---

## 6. Verification checklist

Before M2 testnet deployment, verify:

- [ ] Compile circuit with `nargo check` after fix — `to_be_bytes::<32>()` accepted by compiler
- [x] Write a Noir test in `m2-sig-tests/src/main.nr` that uses title_hash with high byte ≠ 0
      (done tick-4009: `encoding_fix_correct_challenge_passes` + `encoding_fix_wrong_challenge_fails`;
       title_hash = `0x2faabb...19`, challenge = sha256(title_correct || zeros32),
       sig verified against correct challenge ✅; fails against encode_field_as_root path ✅;
       test vectors generated by Python ecdsa RFC 6979, privkey=1, low-S normalized)
- [ ] Run `buildM2Challenge` in TypeScript with the same title_hash + rootField
  and confirm the challenge hex matches the Noir test vector
  (Expected: challenge = `778cd3360542b8ec90434ab1d6aaa5f68b780b012e425b3c132a598d2c2901ac`)
- [ ] End-to-end test: deploy M2 vote with a title whose poseidon2 hash has high byte ≠ 0,
  cast a vote with MetaMask EIP-191, confirm proof generates and transaction lands

---

## 7. Summary table

| Input | Before fix | After fix | TypeScript |
|---|---|---|---|
| `title_hash` | `encode_field_as_root` (31+pad, drops high byte) | `to_be_bytes::<32>()` (full 32 bytes) | `fieldToBytes32` (full 32 bytes) |
| `root_field` | `encode_field_as_root` (31+pad, correct since < 2^248) | unchanged | `fieldToBytes32` (= 0+31 bytes since < 2^248) |

Both inputs now agree between circuit and TypeScript for all possible field values. ✅
