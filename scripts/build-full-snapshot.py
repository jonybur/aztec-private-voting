#!/usr/bin/env python3
"""
build-full-snapshot.py

Fetches ALL BABY holders from Babylon Genesis RPC, builds a full Merkle tree,
and generates a real Prover.toml for the baby-proof circuit.

Usage:
  python3 scripts/build-full-snapshot.py
  python3 scripts/build-full-snapshot.py --voter bbn1p009fpqdd4kcpknzy5swe2804fmpasd8mmkwlp

Outputs:
  snapshot/full-holders.json     — sorted list of all holders
  snapshot/merkle-root-full.json — real Merkle root from full snapshot
  snapshot/prover-<addr>.json    — Merkle path for one voter
  baby-proof/Prover.toml         — ready for nargo prove
"""

import sys
import json
import hashlib
import struct
import time
import os
import urllib.request
import urllib.parse
from datetime import datetime, timezone

RPC_URL = "https://babylon-api.polkachu.com"
PAGE_LIMIT = 1000
MIN_BALANCE = 1_000_000  # 1 BABY in ubbn
MERKLE_DEPTH = 20
SNAPSHOT_DIR = os.path.join(os.path.dirname(__file__), "..", "snapshot")
BABY_PROOF_DIR = os.path.join(os.path.dirname(__file__), "..", "baby-proof")

def sha256(data: bytes) -> bytes:
    return hashlib.sha256(data).digest()

def hash_leaf(address: str, balance: int) -> bytes:
    addr_buf = address.encode("utf-8").ljust(45, b"\x00")[:45]
    bal_buf = struct.pack(">Q", balance)
    return sha256(addr_buf + bal_buf)

def hash_pair(left: bytes, right: bytes) -> bytes:
    return sha256(left + right)

def build_merkle_tree(leaves: list[bytes], depth: int = MERKLE_DEPTH) -> tuple[list[bytes], int]:
    # Always use a fixed-depth tree (2^depth) to match the Noir circuit's MERKLE_DEPTH
    size = 1 << depth  # 2^depth = 1,048,576 for depth=20
    tree = [b"\x00" * 32] * (size * 2 - 1)
    for i, leaf in enumerate(leaves):
        if i >= size:
            raise ValueError(f"Too many leaves ({len(leaves)}) for depth {depth} (max {size})")
        tree[size - 1 + i] = leaf
    for i in range(size - 2, -1, -1):
        tree[i] = hash_pair(tree[2 * i + 1], tree[2 * i + 2])
    return tree, size

def get_merkle_path(tree: list[bytes], leaf_index: int, size: int, depth: int = MERKLE_DEPTH) -> tuple[list[bytes], list[int]]:
    path = []
    indices = []
    idx = size - 1 + leaf_index
    while idx > 0 and len(path) < depth:
        is_right = idx % 2 == 0
        sibling_idx = idx - 1 if is_right else idx + 1
        path.append(tree[sibling_idx])
        indices.append(1 if is_right else 0)
        idx = (idx - 1) // 2
    # pad
    while len(path) < depth:
        path.append(b"\x00" * 32)
        indices.append(0)
    return path, indices

def fetch_all_holders() -> list[dict]:
    holders = []
    next_key = None
    page = 0

    while True:
        url = f"{RPC_URL}/cosmos/bank/v1beta1/denom_owners/ubbn?pagination.limit={PAGE_LIMIT}"
        if next_key:
            url += f"&pagination.key={urllib.parse.quote(next_key)}"

        for attempt in range(3):
            try:
                req = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"})
                with urllib.request.urlopen(req, timeout=30) as r:
                    data = json.load(r)
                break
            except Exception as e:
                if attempt == 2:
                    raise
                print(f"  retry {attempt+1}: {e}")
                time.sleep(1)

        for entry in data.get("denom_owners", []):
            balance = int(entry.get("balance", {}).get("amount", "0"))
            if balance >= MIN_BALANCE:
                holders.append({"address": entry["address"], "balance": balance})

        page += 1
        next_key = data.get("pagination", {}).get("next_key")
        total = data.get("pagination", {}).get("total", "?")
        print(f"  page {page}: {len(holders)} holders (total on chain: {total})", flush=True)

        if not next_key:
            break

    return holders

def buf_to_array(b: bytes) -> list[int]:
    return list(b[:32]) + [0] * max(0, 32 - len(b))

def generate_prover_toml(voter_addr: str, voter_balance: int, path: list[bytes], indices: list[int], root: bytes, min_balance: int) -> str:
    addr_bytes = list(voter_addr.encode("utf-8").ljust(45, b"\x00")[:45])
    path_arrays = ",\n".join(f"    [{', '.join(str(x) for x in buf_to_array(p))}]" for p in path)
    root_str = ", ".join(str(x) for x in buf_to_array(root))
    now = datetime.now(timezone.utc).isoformat()
    return f"""# Prover.toml - baby-proof Noir circuit (FULL SNAPSHOT)
# Voter:   {voter_addr}
# Balance: {voter_balance / 1_000_000:.6f} BABY ({voter_balance} ubbn)
# Min bal: {min_balance / 1_000_000:.1f} BABY
# Root:    0x{root.hex()}
# Source:  Full Babylon Genesis snapshot ({datetime.now(timezone.utc).strftime('%Y-%m-%d')})
# Generated: {now}
#
# Run: cd baby-proof && nargo prove
# Run: cd baby-proof && nargo verify

address_bytes = [{', '.join(str(x) for x in addr_bytes)}]
balance = "{voter_balance}"
path = [
{path_arrays}
]
indices = [{', '.join(str(x) for x in indices)}]

# Public inputs
root = [{root_str}]
min_balance = "{min_balance}"
"""

def main():
    voter_addr = None
    for i, arg in enumerate(sys.argv):
        if arg == "--voter" and i + 1 < len(sys.argv):
            voter_addr = sys.argv[i + 1]

    os.makedirs(SNAPSHOT_DIR, exist_ok=True)

    # Check for cached holders
    holders_file = os.path.join(SNAPSHOT_DIR, "full-holders.json")
    if os.path.exists(holders_file):
        print(f"Loading cached holders from {holders_file}...")
        with open(holders_file) as f:
            holders = json.load(f)
        print(f"  Loaded {len(holders)} holders")
    else:
        print("Fetching all BABY holders from Babylon Genesis...")
        holders = fetch_all_holders()
        holders.sort(key=lambda h: h["address"])
        print(f"\nTotal holders with balance >= {MIN_BALANCE} ubbn: {len(holders)}")
        with open(holders_file, "w") as f:
            json.dump(holders, f)
        print(f"Saved to {holders_file}")

    # Build Merkle tree
    print(f"\nBuilding Merkle tree over {len(holders)} holders...")
    t0 = time.time()
    leaves = [hash_leaf(h["address"], h["balance"]) for h in holders]
    tree, size = build_merkle_tree(leaves)
    root = tree[0]
    print(f"  Done in {time.time() - t0:.2f}s")
    print(f"  Merkle root: 0x{root.hex()}")
    print(f"  Tree size:   {size} leaves ({len(holders)} real, {size - len(holders)} padding)")

    # Save root metadata
    root_data = {
        "root": f"0x{root.hex()}",
        "rootAsField": f"0x{root.hex()[2:]}",  # drop leading 0 byte if needed
        "block": "latest",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "totalHolders": len(holders),
        "minBalance": str(MIN_BALANCE),
        "denomination": "ubbn",
        "treeSize": size,
        "treeDepth": MERKLE_DEPTH,
    }
    root_file = os.path.join(SNAPSHOT_DIR, "merkle-root-full.json")
    with open(root_file, "w") as f:
        json.dump(root_data, f, indent=2)
    print(f"  Root saved: {root_file}")

    # Find voter
    if voter_addr is None:
        # Pick the first holder in sorted order as default demo voter
        voter_addr = holders[0]["address"]

    voter_idx = next((i for i, h in enumerate(holders) if h["address"] == voter_addr), None)
    if voter_idx is None:
        print(f"\nVoter not found in snapshot: {voter_addr}")
        print("Using first holder instead...")
        voter_idx = 0
        voter_addr = holders[0]["address"]

    voter_balance = holders[voter_idx]["balance"]
    print(f"\nGenerating Merkle path for voter:")
    print(f"  Address: {voter_addr}")
    print(f"  Balance: {voter_balance / 1_000_000:.6f} BABY ({voter_balance} ubbn)")
    print(f"  Index:   {voter_idx} / {len(holders)}")

    path, indices = get_merkle_path(tree, voter_idx, size)

    # Verify locally
    current = leaves[voter_idx]
    for sib, idx in zip(path, indices):
        if idx == 1:
            current = hash_pair(sib, current)
        else:
            current = hash_pair(current, sib)
    assert current == root, f"Path verification FAILED: {current.hex()} != {root.hex()}"
    print("  Path verified locally ✅")

    # Save path
    path_data = {
        "address": voter_addr,
        "balance": voter_balance,
        "leaf": leaves[voter_idx].hex(),
        "path": [p.hex() for p in path],
        "indices": indices,
        "root": f"0x{root.hex()}",
    }
    path_file = os.path.join(SNAPSHOT_DIR, f"prover-{voter_addr[:20]}.json")
    with open(path_file, "w") as f:
        json.dump(path_data, f, indent=2)
    print(f"  Path saved: {path_file}")

    # Generate Prover.toml
    toml = generate_prover_toml(voter_addr, voter_balance, path, indices, root, MIN_BALANCE)
    toml_file = os.path.join(BABY_PROOF_DIR, "Prover.toml")
    with open(toml_file, "w") as f:
        f.write(toml)
    print(f"\nProver.toml written to {toml_file}")
    print("\nNext steps:")
    print("  cd baby-proof && nargo prove")
    print("  cd baby-proof && nargo verify")

if __name__ == "__main__":
    main()
