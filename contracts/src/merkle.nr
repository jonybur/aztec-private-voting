// merkle.nr
//
// Merkle membership proofs for two use cases:
//
// 1. Generic AztecAddress allowlist (ALLOWLIST eligibility mode)
//    Proves: "I know an AztecAddress that is a leaf in the committed allowlist
//    Merkle tree." Used with cast_vote_allowlist. No external chain required.
//    Leaf format: sha256(address_field_bytes[32])
//
// 2. Babylon BABY token snapshot eligibility
//    Proves: "I know an address+balance such that hash(address, balance) is
//    a leaf in the Merkle tree committed to by `root`, and balance >= min_balance."
//    Used in the Babylon governance demo to prove BABY holdings from a
//    Cosmos-side snapshot without bridging tokens.

use sha256::sha256_var;

// Depth of the Merkle tree - supports up to 2^20 = ~1M holders
global MERKLE_DEPTH: u32 = 20;

// Verify that (leaf, path, indices) produces the given root.
// path: sibling hashes at each level, bottom to top
// indices: 0=leaf is left child, 1=leaf is right child
pub fn verify_merkle_path(
    leaf: [u8; 32],
    path: [[u8; 32]; 20],
    indices: [bool; 20],
    root: [u8; 32],
) {
    let mut current = leaf;

    for i in 0..MERKLE_DEPTH {
        let sibling = path[i];
        let is_right = indices[i];

        // hash(left, right) where ordering depends on index bit
        let mut input = [0u8; 64];
        if is_right {
            // current is right child - sibling is left
            for j in 0..32 { input[j] = sibling[j]; }
            for j in 0..32 { input[32 + j] = current[j]; }
        } else {
            // current is left child - sibling is right
            for j in 0..32 { input[j] = current[j]; }
            for j in 0..32 { input[32 + j] = sibling[j]; }
        }

        current = sha256_var(input, 64);
    }

    // Assert computed root matches the committed root
    assert(current == root, "Merkle proof invalid: computed root does not match");
}

// Compute the leaf hash for an address+balance pair.
// Matches the TypeScript implementation in synthetic-snapshot.ts:
//   leaf = sha256(address_bytes || balance_bytes_be)
pub fn compute_leaf(address_bytes: [u8; 45], balance: u64) -> [u8; 32] {
    // Pack address (45 bytes for bbn1... bech32) + balance (8 bytes big-endian)
    let mut input = [0u8; 53];
    for i in 0..45 { input[i] = address_bytes[i]; }

    // balance as big-endian u64
    input[45] = ((balance >> 56) & 0xff) as u8;
    input[46] = ((balance >> 48) & 0xff) as u8;
    input[47] = ((balance >> 40) & 0xff) as u8;
    input[48] = ((balance >> 32) & 0xff) as u8;
    input[49] = ((balance >> 24) & 0xff) as u8;
    input[50] = ((balance >> 16) & 0xff) as u8;
    input[51] = ((balance >>  8) & 0xff) as u8;
    input[52] = ((balance      ) & 0xff) as u8;

    sha256_var(input, 53)
}

// Full eligibility check: prove membership AND balance threshold
pub fn verify_baby_eligibility(
    address_bytes: [u8; 45],    // bbn1... address as UTF-8 bytes
    balance: u64,               // claimed balance in ubbn
    min_balance: u64,           // minimum required (from VoteConfig)
    path: [[u8; 32]; 20],       // Merkle path siblings
    indices: [bool; 20],        // path directions
    root: [u8; 32],             // committed Merkle root
) -> [u8; 32] {
    // 1. Balance must meet minimum
    assert(balance >= min_balance, "Insufficient BABY balance for this vote");

    // 2. Compute leaf and verify Merkle membership
    let leaf = compute_leaf(address_bytes, balance);
    verify_merkle_path(leaf, path, indices, root);

    // Return the leaf so the caller can derive a per-holder nullifier from it.
    leaf
}

// M2 leaf format: sha256(hash160[20] || balance_be[8]).
//
// hash160 is the 20-byte address commitment derived from the holder's
// secp256k1 public key. In production this is ripemd160(sha256(pubkey))
// (standard Cosmos derivation). For the M2 prototype we use the SHA-256d
// fallback; see derive_hash160_sha256d below.
//
// The snapshot generator (scripts/synthetic-snapshot.ts) MUST use the
// same leaf format and derivation to produce matching Merkle roots.
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

// M2 eligibility check: Merkle membership + balance threshold using the v2 leaf.
// Returns the leaf bytes so the caller can derive the nullifier.
pub fn verify_baby_eligibility_v2(
    hash160: [u8; 20],
    balance: u64,
    min_balance: u64,
    path: [[u8; 32]; 20],
    indices: [bool; 20],
    root: [u8; 32],
) -> [u8; 32] {
    assert(balance >= min_balance, "Insufficient BABY balance for this vote");
    let leaf = compute_leaf_v2(hash160, balance);
    verify_merkle_path(leaf, path, indices, root);
    leaf
}

// Derive a 20-byte address commitment from a secp256k1 public key using
// the SHA-256d fallback (Fallback B from design spec §9 Risk 1).
//
// Standard Cosmos: hash160 = ripemd160( sha256( compressed_pubkey[33] ) )
// This fallback:   hash160 = sha256( sha256( pubkey_x[32] || pubkey_y[32] ) )[12..32]
//
// PROTOTYPE DEVIATION: this produces different addresses from real Cosmos
// bbn1… addresses. Both the snapshot generator (synthetic-snapshot.ts)
// and this circuit MUST use the same scheme. Replace with ripemd160 once
// noir-ripemd160 crate compatibility is confirmed for nargo >=0.30.
// See docs/m2-secp256k1-ownership-proof-design.md §9 Risk 1.
pub fn derive_hash160_sha256d(pubkey_x: [u8; 32], pubkey_y: [u8; 32]) -> [u8; 20] {
    // Concatenate x || y (64 bytes, no 04 prefix).
    let mut pk_bytes = [0u8; 64];
    for i in 0..32 { pk_bytes[i] = pubkey_x[i]; }
    for i in 0..32 { pk_bytes[32 + i] = pubkey_y[i]; }

    // Double-hash: sha256(sha256(pk_bytes)).
    let inner = sha256_var(pk_bytes, 64);
    let outer = sha256_var(inner, 32);

    // Take last 20 bytes as the address commitment (matches Bitcoin-style
    // hash160 output width; last-20 rather than first-20 is arbitrary —
    // consistency with synthetic-snapshot.ts matters, not the direction).
    let mut hash160 = [0u8; 20];
    for i in 0..20 { hash160[i] = outer[12 + i]; }
    hash160
}

// ---------------------------------------------------------------------------
// Generic AztecAddress allowlist Merkle membership
// ---------------------------------------------------------------------------

// Compute a Merkle leaf from an AztecAddress field.
//
// The AztecAddress is serialised as 32 bytes (zero-padded big-endian,
// matching the encoding used for Merkle roots throughout this module).
// Leaf = sha256( address_bytes[32] )
//
// The off-chain allowlist generator MUST use the same scheme:
//   const addrBytes = Buffer.alloc(32);
//   addrBytes.writeUInt8(0, 0);
//   Buffer.from(address.toBuffer()).copy(addrBytes, 1);
//   leaf = sha256(addrBytes);
//
// Changing this function breaks existing deployed allowlists; treat as
// a versioned commitment.
pub fn compute_aztec_leaf(address_field: Field) -> [u8; 32] {
    // Encode the 31-byte field as 32 bytes (zero-pad at index 0), matching
    // encode_field_as_root so the off-chain and in-circuit encodings agree.
    let field_bytes: [u8; 31] = address_field.to_be_bytes();
    let mut addr_bytes = [0u8; 32];
    addr_bytes[0] = 0;
    for i in 0..31 { addr_bytes[i + 1] = field_bytes[i]; }
    sha256_var(addr_bytes, 32)
}

// Verify that `address_field` is a member of the committed allowlist Merkle
// tree whose root is stored as `root_field` (encoded via encode_field_as_root).
//
// Returns the leaf hash so the caller can bind it to downstream commitments.
//
// Usage in cast_vote_allowlist:
//   let root_field = config.token_address.to_field();
//   let _ = verify_aztec_allowlist(
//       self.msg_sender().to_field(),
//       merkle_path, merkle_indices, root_field,
//   );
pub fn verify_aztec_allowlist(
    address_field: Field,
    path: [[u8; 32]; 20],
    indices: [bool; 20],
    root_field: Field,
) -> [u8; 32] {
    let root = encode_field_as_root(root_field);
    let leaf = compute_aztec_leaf(address_field);
    verify_merkle_path(leaf, path, indices, root);
    leaf
}

// ---------------------------------------------------------------------------
// Field / bytes encoding helpers
// ---------------------------------------------------------------------------

// Encode a Field (31 bytes) back into a 32-byte hash.
// Inverse of encode_root_as_field in synthetic-snapshot.ts:
//   out[0] = 0x00 (padding), out[1..32] = field bytes
pub fn encode_field_as_root(f: Field) -> [u8; 32] {
    let field_bytes: [u8; 31] = f.to_be_bytes();
    let mut root = [0u8; 32];
    root[0] = 0;
    for i in 0..31 {
        root[i + 1] = field_bytes[i];
    }
    root
}

// Encode a 32-byte hash as a Field using bytes [1..32] (drop byte 0),
// matching the root encoding above.
pub fn hash_bytes_as_field(h: [u8; 32]) -> Field {
    let mut f: Field = 0;
    for i in 0..31 {
        f = f * 256 + (h[i + 1] as Field);
    }
    f
}

// ---------------------------------------------------------------------------
// Unit tests — allowlist leaf computation
// ---------------------------------------------------------------------------

// compute_aztec_leaf produces the same output for the same input (determinism).
#[test]
fn compute_aztec_leaf_deterministic() {
    let addr: Field = 0xdeadbeefcafe;
    let leaf_a = compute_aztec_leaf(addr);
    let leaf_b = compute_aztec_leaf(addr);
    assert(leaf_a == leaf_b, "leaf not deterministic");
}

// Different addresses produce different leaves (collision resistance test).
#[test]
fn compute_aztec_leaf_differs_by_address() {
    let addr_a: Field = 0x1111111111111111;
    let addr_b: Field = 0x2222222222222222;
    let leaf_a = compute_aztec_leaf(addr_a);
    let leaf_b = compute_aztec_leaf(addr_b);
    // The two SHA-256 outputs must differ (with overwhelming probability).
    assert(leaf_a != leaf_b, "distinct addresses produced the same leaf");
}

// compute_aztec_leaf output is non-zero (sha256 of non-zero input is non-zero).
#[test]
fn compute_aztec_leaf_nonzero() {
    let zero_leaf = compute_aztec_leaf(0);
    let nonzero_leaf = compute_aztec_leaf(42);
    // SHA-256 of any fixed-length input is non-zero; both should differ from
    // an array of 32 zeros.
    let empty: [u8; 32] = [0; 32];
    assert(zero_leaf != empty, "sha256 output was unexpectedly all-zero");
    assert(nonzero_leaf != empty, "sha256 output was unexpectedly all-zero");
}

// encode_field_as_root round-trips through hash_bytes_as_field.
#[test]
fn encode_decode_field_round_trips() {
    let original: Field = 0xabcdef1234567890;
    let encoded = encode_field_as_root(original);
    let decoded = hash_bytes_as_field(encoded);
    assert(decoded == original, "encode/decode round-trip failed");
}
