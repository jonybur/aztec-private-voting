// merkle.nr
//
// Merkle membership proof for BABY token holder eligibility.
//
// Proves: "I know an address+balance such that hash(address, balance) is
// a leaf in the Merkle tree committed to by `root`, and balance >= min_balance."
//
// Used in the Babylon governance demo to prove BABY holdings from a
// Cosmos-side snapshot without bridging tokens.

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
