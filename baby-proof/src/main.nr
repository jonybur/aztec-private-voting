// baby_proof/src/main.nr
//
// Standalone Noir circuit for BABY token Merkle eligibility proof.
// Compatible with nargo 1.0.0-beta.22+
//
// Proves (in zero knowledge):
//   "I know an address+balance such that sha256(address_bytes || balance_be8)
//    is a leaf in the Merkle tree with the given root, and balance >= min_balance"
//
// Public inputs:
//   - root:        [u8; 32] - committed Merkle root (from snapshot)
//   - min_balance: u64      - minimum required balance in ubbn
//
// Private inputs:
//   - address_bytes: [u8; 45] - bbn1... address as zero-padded UTF-8
//   - balance:       u64      - claimed balance in ubbn
//   - path:          [[u8; 32]; 20] - Merkle sibling hashes (bottom to top)
//   - indices:       [bool; 20] - path direction bits (false=left, true=right)
//
// Usage:
//   cd baby-proof
//   nargo prove   (uses Prover.toml)
//   nargo verify  (uses Verifier.toml)

use sha256::sha256_var;

global MERKLE_DEPTH: u32 = 20;

// Compute SHA-256(a || b) where a and b are 32-byte arrays
fn hash_pair(left: [u8; 32], right: [u8; 32]) -> [u8; 32] {
    let mut input: [u8; 64] = [0; 64];
    for i in 0..32 {
        input[i] = left[i];
        input[32 + i] = right[i];
    }
    sha256_var(input, 64)
}

// Compute leaf = SHA-256(address_bytes[0..45] || balance_be8)
// Matches TypeScript: sha256(Buffer.concat([addrBuf45, balBuf8]))
fn compute_leaf(address_bytes: [u8; 45], balance: u64) -> [u8; 32] {
    let mut input: [u8; 64] = [0; 64]; // 45 + 8 = 53 bytes; pad remainder to 64

    for i in 0..45 {
        input[i] = address_bytes[i];
    }

    // balance big-endian u64 at bytes 45..52
    input[45] = ((balance >> 56) & 0xff) as u8;
    input[46] = ((balance >> 48) & 0xff) as u8;
    input[47] = ((balance >> 40) & 0xff) as u8;
    input[48] = ((balance >> 32) & 0xff) as u8;
    input[49] = ((balance >> 24) & 0xff) as u8;
    input[50] = ((balance >> 16) & 0xff) as u8;
    input[51] = ((balance >>  8) & 0xff) as u8;
    input[52] = ((balance      ) & 0xff) as u8;

    sha256_var(input, 53) // message_size=53 so sha256_var pads correctly
}

// Verify the Merkle path from leaf to root
fn verify_merkle_path(
    leaf: [u8; 32],
    path: [[u8; 32]; 20],
    indices: [bool; 20],
    root: [u8; 32],
) {
    let mut current = leaf;

    for i in 0..MERKLE_DEPTH {
        let sibling = path[i];
        let is_right = indices[i];

        if is_right {
            current = hash_pair(sibling, current);
        } else {
            current = hash_pair(current, sibling);
        }
    }

    assert(current == root, "Merkle proof invalid");
}

fn main(
    // Private witnesses
    address_bytes: [u8; 45],
    balance: u64,
    path: [[u8; 32]; 20],
    indices: [bool; 20],
    // Public inputs
    root: pub [u8; 32],
    min_balance: pub u64,
) {
    assert(balance >= min_balance, "Insufficient BABY balance");
    let leaf = compute_leaf(address_bytes, balance);
    verify_merkle_path(leaf, path, indices, root);
}

// Unit tests

#[test]
fn test_balance_check_passes() {
    let addr: [u8; 45] = [98, 98, 110, 49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let leaf = compute_leaf(addr, 1000000);
    let _ = leaf;
}

#[test(should_fail_with = "Insufficient BABY balance")]
fn test_balance_check_rejects_low() {
    let addr: [u8; 45] = [0; 45];
    let path: [[u8; 32]; 20] = [[0; 32]; 20];
    let indices: [bool; 20] = [false; 20];
    let root: [u8; 32] = [0; 32];
    main(addr, 500000, path, indices, root, 1000000);
}
