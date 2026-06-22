# Allowlist Merkle Tree Generator

Reference for the off-chain tooling that builds the AztecAddress allowlist
Merkle tree committed to in a `cast_vote_allowlist` vote.

---

## Overview

`cast_vote_allowlist` proves in-circuit that the caller's AztecAddress is a
member of a committed Merkle tree. The tree is built off-chain from a list of
eligible AztecAddresses and its root is stored in `VoteConfig.token_address`.

This document specifies the **exact leaf and tree hash scheme** so that the
in-circuit `compute_aztec_leaf` (merkle.nr) and the off-chain generator agree.

---

## Leaf format

```
leaf = SHA-256( address_bytes[32] )

where:
  address_bytes[0]    = 0x00  (zero padding)
  address_bytes[1..32] = address.to_field().to_be_bytes()[0..31]
```

This matches `compute_aztec_leaf` in `contracts/src/merkle.nr`:

```noir
pub fn compute_aztec_leaf(address_field: Field) -> [u8; 32] {
    let field_bytes: [u8; 31] = address_field.to_be_bytes();
    let mut addr_bytes = [0u8; 32];
    addr_bytes[0] = 0;
    for i in 0..31 { addr_bytes[i + 1] = field_bytes[i]; }
    sha256_var(addr_bytes, 32)
}
```

TypeScript equivalent:

```ts
import { sha256 } from "@noble/hashes/sha256";
import { AztecAddress } from "@aztec/aztec.js";

function computeAztecLeaf(address: AztecAddress): Buffer {
  const addrBytes = Buffer.alloc(32);
  // Zero byte at index 0 (padding)
  addrBytes[0] = 0x00;
  // Remaining 31 bytes from address field (big-endian)
  const fieldBytes = address.toField().toBuffer(); // 32-byte BE
  fieldBytes.copy(addrBytes, 1, 1, 32);            // drop leading byte
  return Buffer.from(sha256(addrBytes));
}
```

---

## Internal nodes

Inner nodes are hashed as:

```
parent = SHA-256( left_child[32] || right_child[32] )
```

This matches `verify_merkle_path` in merkle.nr.

Padding leaves for a non-power-of-2 list: pad with `SHA-256([0x00; 32])` to
reach the next power of 2.

---

## Root encoding

The 32-byte SHA-256 root cannot be stored directly in an Aztec `AztecAddress`
field (which holds 31 bytes). Drop byte 0 (always 0x00 for well-formed SHA-256
roots) and encode as a Field:

```ts
function encodeRootAsField(root: Buffer): bigint {
  // Drop byte 0 (must be 0x00; enforce this or root is out of range).
  if (root[0] !== 0x00) throw new Error("Root byte 0 is non-zero; truncation unsafe");
  return BigInt("0x" + root.slice(1).toString("hex"));
}
```

Store the result as `VoteConfig.token_address`:

```ts
const rootField = encodeRootAsField(merkleRoot);
const config: VoteConfig = {
  // ...
  eligibilityMode: ELIGIBILITY_MODE_ALLOWLIST,
  tokenAddress: AztecAddress.fromField(new Fr(rootField)),
  minTokenBalance: 0n, // unused in allowlist mode
};
```

In-circuit, `encode_field_as_root(config.token_address.to_field())` reconstructs
the 32-byte root.

---

## Merkle path witness

When a voter calls `cast_vote_allowlist`, the front-end must supply:

```ts
merkle_path:    [[u8; 32]; 20]  // sibling hashes, bottom to top
merkle_indices: [bool; 20]      // false = caller is left child, true = right
```

Use a standard depth-20 Merkle tree library; ensure the sibling hash at each
level matches the SHA-256 internal-node scheme above.

---

## Deployment checklist

1. Collect eligible AztecAddress list (off-chain governance / admin).
2. Compute leaves via `computeAztecLeaf`.
3. Build depth-20 Merkle tree; record root.
4. Encode root as Field; set `tokenAddress` in VoteConfig.
5. Deploy the contract (`eligibilityMode = ELIGIBILITY_MODE_ALLOWLIST = 2`).
6. Distribute Merkle paths to eligible voters (can be public — paths reveal
   nothing about who voted, only membership).

---

## Privacy notes

- The Merkle **path** is a private witness — an external observer cannot
  determine which address the prover used.
- The `token_address` field (storing the root) is **public** in VoteConfig,
  so the full list of eligible voters is public if the tree is auditable.
  For private allowlists, store only a commitment to the list off-chain.
- Double-voting is prevented by Aztec's `SingleUseClaim` nullifier, which is
  derived from the protocol's private keys — not the address — so claiming
  cannot be linked back to an allowlist entry.

---

## Related files

- `contracts/src/merkle.nr` — `compute_aztec_leaf`, `verify_aztec_allowlist`
- `contracts/src/main.nr` — `cast_vote_allowlist`
- `contracts/src/eligibility.nr` — `ELIGIBILITY_MODE_ALLOWLIST = 2`
- `docs/security-review-2026-06-22.md` — F1-HIGH finding this resolves

---

*Created 2026-06-22. Leaf format is a versioned commitment — changing it
breaks existing deployed allowlists.*
