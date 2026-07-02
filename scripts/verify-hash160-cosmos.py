#!/usr/bin/env python3
"""
verify-hash160-cosmos.py — ADR-038 test vectors

Generates and verifies the Cosmos/Bitcoin standard hash160 derivation:

    hash160 = ripemd160( sha256( SEC1_compressed_pubkey[33] ) )

This is the derivation implemented in:
  - derive_hash160_cosmos() in contracts/src/merkle.nr (after ADR-038 upgrade)
  - generate-m2-snapshot.ts (after coordinated upgrade)

The test vectors here are canonical inputs for the Noir circuit unit tests in
m2-sig-tests/src/main.nr. Once the ripemd160 dependency is added (Nargo.toml),
add a `#[test]` that calls derive_hash160_cosmos with these exact byte arrays
and asserts the hash160 output.

Cross-check: privkey=1 produces hash160 751e76e8...f1433bd6 which encodes as
Bitcoin P2PKH address 1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH — a widely-known
test vector confirming the derivation is correct.

Usage:
    python3 scripts/verify-hash160-cosmos.py

No extra dependencies — uses stdlib only (hashlib with RIPEMD-160 support).
Python >=3.6 required; RIPEMD-160 available in hashlib when OpenSSL is present
(standard on Linux/macOS; on Windows may need: pip install pyca/cryptography).

Connections:
    docs/adr-038-m2-ripemd160-upgrade-2026-07-02.md
    m2-sig-tests/src/main.nr
    contracts/src/merkle.nr
"""

import hashlib
import sys

# ---------------------------------------------------------------------------
# secp256k1 arithmetic (stdlib only, no external lib)
# ---------------------------------------------------------------------------

_P  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
_Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
_Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8


def _point_add(P, Q):
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and y1 != y2:
        return None
    if P == Q:
        lam = (3 * x1 * x1 * pow(2 * y1, _P - 2, _P)) % _P
    else:
        lam = ((y2 - y1) * pow(x2 - x1, _P - 2, _P)) % _P
    x3 = (lam * lam - x1 - x2) % _P
    y3 = (lam * (x1 - x3) - y1) % _P
    return x3, y3


def _scalar_mul(k, P):
    R, Q = None, P
    while k > 0:
        if k & 1:
            R = _point_add(R, Q)
        Q = _point_add(Q, Q)
        k >>= 1
    return R


# ---------------------------------------------------------------------------
# Core derivation
# ---------------------------------------------------------------------------

def derive_hash160_cosmos(pubkey_x_bytes: bytes, pubkey_y_bytes: bytes) -> bytes:
    """
    Implements the Cosmos-standard hash160 derivation:

        compressed = (0x02 if y even else 0x03) || x_bytes[32]
        hash160    = ripemd160( sha256( compressed ) )

    This matches Noir's derive_hash160_cosmos() in contracts/src/merkle.nr
    (post ADR-038 upgrade).

    Args:
        pubkey_x_bytes: 32-byte big-endian x coordinate
        pubkey_y_bytes: 32-byte big-endian y coordinate

    Returns:
        20-byte hash160
    """
    assert len(pubkey_x_bytes) == 32, "pubkey_x must be 32 bytes"
    assert len(pubkey_y_bytes) == 32, "pubkey_y must be 32 bytes"

    # SEC1 prefix: 0x02 if y is even (low bit of y[31] == 0), else 0x03
    # Matches the Noir check: if (pubkey_y[31] & 1) == 0 { 0x02 } else { 0x03 }
    prefix = 0x02 if (pubkey_y_bytes[31] & 1) == 0 else 0x03
    compressed = bytes([prefix]) + pubkey_x_bytes  # 33 bytes

    sha256_of_pk = hashlib.sha256(compressed).digest()

    h = hashlib.new("ripemd160")
    h.update(sha256_of_pk)
    return h.digest()


def privkey_to_pubkey(privkey_int: int) -> tuple[bytes, bytes]:
    """Scalar multiply G by privkey_int; return (x_bytes[32], y_bytes[32])."""
    Px, Py = _scalar_mul(privkey_int, (_Gx, _Gy))
    return Px.to_bytes(32, "big"), Py.to_bytes(32, "big")


# ---------------------------------------------------------------------------
# Cross-check: Bitcoin P2PKH address encoding
# ---------------------------------------------------------------------------

_BASE58_ALPHABET = b"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"


def _base58check_encode(payload: bytes) -> str:
    checksum = hashlib.sha256(hashlib.sha256(payload).digest()).digest()[:4]
    full = payload + checksum
    n = int.from_bytes(full, "big")
    result = []
    while n > 0:
        n, r = divmod(n, 58)
        result.append(_BASE58_ALPHABET[r : r + 1])
    result = b"".join(reversed(result))
    leading_zeros = len(full) - len(full.lstrip(b"\x00"))
    return ("1" * leading_zeros) + result.decode()


def hash160_to_bitcoin_p2pkh(hash160_bytes: bytes) -> str:
    """Encode hash160 as Bitcoin mainnet P2PKH address (version byte 0x00)."""
    return _base58check_encode(bytes([0x00]) + hash160_bytes)


# ---------------------------------------------------------------------------
# Test vectors
# ---------------------------------------------------------------------------

# Canonical test vectors for derive_hash160_cosmos().
# Each entry is: (privkey_int, expected_hash160_hex, notes)
# Cross-referenced with Bitcoin P2PKH addresses as the canonical verification.
#
# NOTE: The Noir circuit receives raw pubkey coordinates (32 bytes each),
# not the privkey. Use the pubkey_x / pubkey_y fields as Prover.toml inputs.

VECTORS = [
    # privkey=1: secp256k1 generator point G — even y (prefix 0x02)
    # Bitcoin P2PKH: 1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH (widely-known test vector)
    {
        "privkey":           1,
        "pubkey_x":          "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        "pubkey_y":          "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8",
        "prefix":            "02",
        "y_parity":          "even",
        "compressed_pubkey": "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        "sha256_of_compressed": "0f715baf5d4c2ed329785cef29e562f73488c8a2bb9dbc5700b361d54b9b0554",
        "hash160":           "751e76e8199196d454941c45d1b3a323f1433bd6",
        "bitcoin_p2pkh":     "1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH",
        "notes":             "Generator point G; y even; widely-used Bitcoin test vector",
    },
    # privkey=2: 2G — even y (prefix 0x02)
    {
        "privkey":           2,
        "pubkey_x":          "c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5",
        "pubkey_y":          "1ae168fea63dc339a3c58419466ceaeef7f632653266d0e1236431a950cfe52a",
        "prefix":            "02",
        "y_parity":          "even",
        "compressed_pubkey": "02c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5",
        "sha256_of_compressed": "b1c9938f01121e159887ac2c8d393a22e4476ff8212de13fe1939de2a236f0a7",
        "hash160":           "06afd46bcdfd22ef94ac122aa11f241244a37ecc",
        "bitcoin_p2pkh":     "1cMh228HTCiwS8ZsaakH8A8wze1JR5ZsP",
        "notes":             "2G; y even",
    },
    # privkey=3: 3G — even y (prefix 0x02)
    {
        "privkey":           3,
        "pubkey_x":          "f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9",
        "pubkey_y":          "388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e672",
        "prefix":            "02",
        "y_parity":          "even",
        "compressed_pubkey": "02f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9",
        "sha256_of_compressed": "eae10cdd2f289bdad44615809cb422d2fabe9622ed706ad5d9d3ffd2cdd1c001",
        "hash160":           "7dd65592d0ab2fe0d0257d571abf032cd9db93dc",
        "bitcoin_p2pkh":     "1CUNEBjYrCn2y1SdiUMohaKUi4wpP326Lb",
        "notes":             "3G; y even",
    },
    # privkey=10: 10G — ODD y (prefix 0x03) — critical test for prefix branch
    {
        "privkey":           10,
        "pubkey_x":          "a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e247c7",
        "pubkey_y":          "893aba425419bc27a3b6c7e693a24c696f794c2ed877a1593cbee53b037368d7",
        "prefix":            "03",
        "y_parity":          "odd",
        "compressed_pubkey": "03a0434d9e47f3c86235477c7b1ae6ae5d3442d49b1943c2b752a68e2a47e247c7",
        "sha256_of_compressed": "7c5390f1a98ff45ba7568617d38ff43bf66c3fc5bb3891d751f7befb887e1537",
        "hash160":           "185140bb54704a9e735016faa7a8dbee4449bddc",
        "bitcoin_p2pkh":     "13DaZ9nfmJLfzU6oBnD2sdCiDmf3M5fmLx",
        "notes":             "10G; y ODD — exercises 0x03 prefix branch in derive_hash160_cosmos()",
    },
]


# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

def verify_vector(v: dict, verbose: bool = False) -> bool:
    """Recompute hash160 for a vector entry and verify against expected."""
    privkey = v["privkey"]
    x_bytes, y_bytes = privkey_to_pubkey(privkey)

    if verbose:
        print(f"\n{'='*60}")
        print(f"privkey = {privkey}")
        print(f"  pubkey_x:  {x_bytes.hex()}")
        print(f"  pubkey_y:  {y_bytes.hex()}")
        print(f"  y parity:  {'even' if y_bytes[31] % 2 == 0 else 'odd'}")

    # Assert pubkey matches expected
    assert x_bytes.hex() == v["pubkey_x"], f"pubkey_x mismatch for privkey={privkey}"
    assert y_bytes.hex() == v["pubkey_y"], f"pubkey_y mismatch for privkey={privkey}"

    # Compute hash160
    computed_hash160 = derive_hash160_cosmos(x_bytes, y_bytes)
    expected_hash160 = bytes.fromhex(v["hash160"])

    # Verify compressed pubkey intermediate
    prefix = 0x02 if (y_bytes[31] & 1) == 0 else 0x03
    compressed = bytes([prefix]) + x_bytes
    assert compressed.hex() == v["compressed_pubkey"], \
        f"compressed mismatch for privkey={privkey}"
    assert v["prefix"] == hex(prefix)[2:].zfill(2), \
        f"prefix mismatch for privkey={privkey}"

    # Verify sha256 intermediate
    sha256_of_pk = hashlib.sha256(compressed).digest()
    assert sha256_of_pk.hex() == v["sha256_of_compressed"], \
        f"sha256 intermediate mismatch for privkey={privkey}"

    # Primary assertion
    assert computed_hash160 == expected_hash160, \
        f"hash160 mismatch for privkey={privkey}: " \
        f"got {computed_hash160.hex()}, expected {expected_hash160.hex()}"

    # Bitcoin P2PKH cross-check
    btc_addr = hash160_to_bitcoin_p2pkh(computed_hash160)
    assert btc_addr == v["bitcoin_p2pkh"], \
        f"Bitcoin P2PKH mismatch for privkey={privkey}: " \
        f"got {btc_addr}, expected {v['bitcoin_p2pkh']}"

    if verbose:
        print(f"  prefix:    0x{prefix:02x} ({v['y_parity']})")
        print(f"  sha256:    {sha256_of_pk.hex()}")
        print(f"  hash160:   {computed_hash160.hex()}")
        print(f"  bitcoin:   {btc_addr} ✓")
        print(f"  notes:     {v['notes']}")

    return True


def print_noir_prover_toml(v: dict) -> None:
    """Print Prover.toml input for this test vector (Noir circuit input format)."""
    x_arr = ", ".join(f"0x{b:02x}" for b in bytes.fromhex(v["pubkey_x"]))
    y_arr = ", ".join(f"0x{b:02x}" for b in bytes.fromhex(v["pubkey_y"]))
    h_arr = ", ".join(f"0x{b:02x}" for b in bytes.fromhex(v["hash160"]))
    print(f"\n# Noir Prover.toml input for privkey={v['privkey']} ({v['notes']})")
    print(f"pubkey_x = [{x_arr}]")
    print(f"pubkey_y = [{y_arr}]")
    print(f"# expected hash160: [{h_arr}]")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    noir_fmt = "--noir" in sys.argv

    print("verify-hash160-cosmos.py — ADR-038 test vector verification")
    print("=" * 60)

    all_pass = True
    for v in VECTORS:
        try:
            verify_vector(v, verbose=verbose)
            status = "PASS"
        except AssertionError as e:
            status = f"FAIL: {e}"
            all_pass = False

        if not verbose:
            y_tag = "(0x02 even)" if v["y_parity"] == "even" else "(0x03 ODD )"
            print(f"privkey={v['privkey']:>3} {y_tag}  hash160={v['hash160']}  [{status}]")

    if noir_fmt:
        print("\n" + "=" * 60)
        print("Noir Prover.toml inputs (add to m2-sig-tests after ADR-038 upgrade):")
        for v in VECTORS:
            print_noir_prover_toml(v)

    print()
    if all_pass:
        print(f"ALL {len(VECTORS)} VECTORS PASSED")
        print()
        print("These vectors are canonical inputs for the Noir circuit test in")
        print("m2-sig-tests/src/main.nr. After applying ADR-038 (adding the")
        print("ripemd160 dependency), add a #[test] that calls derive_hash160_cosmos()")
        print("with privkey=1 and privkey=10 inputs and asserts the hash160 outputs.")
        sys.exit(0)
    else:
        print("SOME VECTORS FAILED — do not apply ADR-038 until resolved")
        sys.exit(1)


if __name__ == "__main__":
    main()
