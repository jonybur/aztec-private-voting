// The receipt id is a client-generated random field element. It is recorded
// by the contract and backs the verify_vote_counted receipt check. It must
// never be derived from the wallet: double voting is prevented by the
// contract's private single-use claim, not by this value.
//
// Privacy note (L1): the receipt id appears in the same public transaction as
// the vote choice, so the voter must treat it as private - sharing it reveals
// the choice. See docs/receipt.md and openspec/ROADMAP.md (M2).
export async function generateReceiptId(): Promise<bigint> {
  const { Fr } = await import('@aztec/aztec.js');
  return Fr.random().toBigInt();
}

export function fingerprintFromReceiptId(receiptId: bigint): string {
  return `0x${receiptId.toString(16).padStart(64, '0')}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// M2 (cast_vote_babylon_v2) receipt derivation
// ─────────────────────────────────────────────────────────────────────────────
//
// cast_vote_babylon_v2 does NOT accept a client-generated receipt_id.
// Instead, the contract derives the holder nullifier (used as the receipt key)
// directly from the ECDSA signature:
//
//   Noir circuit (contracts/src/main.nr, step 6):
//     holder_nullifier = hash_bytes_as_field( sha256_var(sig, 64) )
//
// where sig is sig_r[32] || sig_s[32] (64 bytes), and:
//
//   hash_bytes_as_field (contracts/src/merkle.nr):
//     Drop h[0]; interpret h[1..31] as a 248-bit big-endian Field element.
//
// The front-end must compute the same value to give the voter a receipt
// fingerprint they can use with verify_vote_counted.
//
// Using a random receiptId here would cause an ABI mismatch (the circuit
// has no receipt_id parameter) AND give the voter a fingerprint that
// verify_vote_counted cannot find (stored key is sig-derived, not random).
//
// Security: holder_nullifier has 248-bit pre-image security (SHA-256
// truncated by 8 bits). RFC 6979 determinism ensures the same key/vote
// cannot produce a different nullifier under an honest wallet.
// See docs/security-review-babylon-m2-2026-06-24.md M2-F4.

/**
 * Compute the holder nullifier for a cast_vote_babylon_v2 transaction.
 *
 * Matches the Noir circuit step 6:
 *   holder_nullifier = hash_bytes_as_field( sha256_var(sig_r || sig_s, 64) )
 *
 * @param sig_r  32-byte ECDSA signature R component
 * @param sig_s  32-byte ECDSA signature S component (low-S normalised)
 * @returns      248-bit bigint Field element — use as receipt_id in verify_vote_counted
 */
export async function holderNullifierFromSig(
  sig_r: number[],
  sig_s: number[],
): Promise<bigint> {
  if (sig_r.length !== 32 || sig_s.length !== 32) {
    throw new Error(
      `sig_r and sig_s must each be 32 bytes; got ${sig_r.length} and ${sig_s.length}`,
    );
  }

  const { sha256 } = await import('@noble/hashes/sha256');

  // Concatenate r || s (64 bytes) — matches sha256_var(sig, 64) in Noir.
  const sigBytes = new Uint8Array(64);
  sigBytes.set(sig_r);
  sigBytes.set(sig_s, 32);
  const h = sha256(sigBytes); // 32-byte SHA-256 output

  // hash_bytes_as_field: drop h[0], interpret h[1..31] as 248-bit big-endian int.
  // Matches Noir: for i in 0..31 { f = f * 256 + h[i+1] }
  let f = 0n;
  for (let i = 0; i < 31; i++) {
    // h[i + 1]: skip first byte, accumulate remaining 31 bytes
    f = f * 256n + BigInt(h[i + 1] ?? 0);
  }
  return f;
}
