/**
 * useM2Signing — unit tests
 *
 * Tests challenge construction, raw secp256k1 signing, and the EIP-191
 * message wrapping that matches the updated Noir circuit (ADR-036 Path C).
 * Does NOT test the Keplr stub (it intentionally throws).
 * Does NOT test eip191Sign in browser context (requires window.ethereum).
 *
 * These tests run in Node via vitest and do not require a DOM or wallet.
 */

import { describe, it, expect } from 'vitest';
import { buildM2Challenge, fieldToBytes32 } from './useM2Signing';

// ─────────────────────────────────────────────────────────────────────────────
// Challenge construction
// ─────────────────────────────────────────────────────────────────────────────

describe('buildM2Challenge', () => {
  it('produces a 32-byte output', async () => {
    const challenge = await buildM2Challenge(0n, 0n);
    expect(challenge).toHaveLength(32);
  });

  it('is deterministic', async () => {
    const titleHash = 123456789n;
    const rootField = 987654321n;
    const a = await buildM2Challenge(titleHash, rootField);
    const b = await buildM2Challenge(titleHash, rootField);
    expect(a).toEqual(b);
  });

  it('changes when titleHash changes', async () => {
    const root = 1n;
    const a = await buildM2Challenge(1n, root);
    const b = await buildM2Challenge(2n, root);
    expect(a).not.toEqual(b);
  });

  it('changes when rootField changes', async () => {
    const title = 42n;
    const a = await buildM2Challenge(title, 100n);
    const b = await buildM2Challenge(title, 101n);
    expect(a).not.toEqual(b);
  });

  it('matches a known vector (zero inputs → sha256 of 64 zero bytes)', async () => {
    // sha256(new Uint8Array(64)) — precomputed reference
    const { sha256 } = await import('@noble/hashes/sha256');
    const expected = sha256(new Uint8Array(64));
    const actual = await buildM2Challenge(0n, 0n);
    expect(actual).toEqual(expected);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// fieldToBytes32
// ─────────────────────────────────────────────────────────────────────────────

describe('fieldToBytes32', () => {
  it('encodes 0n as 32 zero bytes', () => {
    const b = fieldToBytes32(0n);
    expect(b).toEqual(new Uint8Array(32));
  });

  it('encodes 1n as ...0x01 in the last byte', () => {
    const b = fieldToBytes32(1n);
    expect(b[31]).toBe(1);
    expect(b.slice(0, 31)).toEqual(new Uint8Array(31));
  });

  it('encodes 256n = 0x100 in bytes 30–31', () => {
    const b = fieldToBytes32(256n);
    expect(b[30]).toBe(1);
    expect(b[31]).toBe(0);
  });

  it('round-trips a large field element', () => {
    // Aztec BN254 field prime - 1
    const BN254_PRIME = 0x30644e72e131a029b85045b68181585d2833e84879b9709142e1f3bd52fdf01n;
    const b = fieldToBytes32(BN254_PRIME);
    // Reconstruct from bytes
    let recovered = 0n;
    for (const byte of b) {
      recovered = (recovered << 8n) | BigInt(byte);
    }
    expect(recovered).toBe(BN254_PRIME);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// Raw signing
// ─────────────────────────────────────────────────────────────────────────────

// Known test private key (do NOT use in production)
const TEST_PRIVKEY_HEX = 'b94f5374fce5edbc8e2a8697c15331677e6ebf0b000000000000000000000001';

describe('raw secp256k1 signing (via @noble/curves)', () => {

  async function signChallenge(
    privKeyHex: string,
    titleHash: bigint,
    rootField: bigint,
  ) {
    const { secp256k1 } = await import('@noble/curves/secp256k1');
    const challenge = await buildM2Challenge(titleHash, rootField);
    const privBytes = Uint8Array.from(Buffer.from(privKeyHex, 'hex'));
    const sig = secp256k1.sign(challenge, privBytes, { lowS: true });
    const pubUncomp = secp256k1.getPublicKey(privBytes, false);
    return { sig, pubUncomp, challenge };
  }

  it('produces a valid secp256k1 signature that verifies', async () => {
    const { secp256k1 } = await import('@noble/curves/secp256k1');
    const { sig, pubUncomp, challenge } = await signChallenge(TEST_PRIVKEY_HEX, 42n, 999n);

    // Verify using the same library (sanity check before trusting circuit)
    const pubComp = secp256k1.getPublicKey(
      Uint8Array.from(Buffer.from(TEST_PRIVKEY_HEX, 'hex')),
      true,
    );
    const valid = secp256k1.verify(sig, challenge, pubComp);
    expect(valid).toBe(true);
  });

  it('enforces BIP-62 low-S (s <= n/2)', async () => {
    const { secp256k1 } = await import('@noble/curves/secp256k1');
    const SECP256K1_N = secp256k1.CURVE.n;
    const { sig } = await signChallenge(TEST_PRIVKEY_HEX, 1n, 2n);
    expect(sig.s <= SECP256K1_N / 2n).toBe(true);
  });

  it('pubkey_x and pubkey_y are each 32 bytes', async () => {
    const { pubUncomp } = await signChallenge(TEST_PRIVKEY_HEX, 0n, 0n);
    expect(pubUncomp).toHaveLength(65);
    expect(pubUncomp[0]).toBe(0x04);
    // x = bytes 1–32, y = bytes 33–64
    const x = Array.from(pubUncomp.slice(1, 33));
    const y = Array.from(pubUncomp.slice(33, 65));
    expect(x).toHaveLength(32);
    expect(y).toHaveLength(32);
  });

  it('sig r and s are each 32-byte bigints', async () => {
    const { sig } = await signChallenge(TEST_PRIVKEY_HEX, 7n, 13n);
    // r and s must fit in 32 bytes (< 2^256)
    const MAX_32_BYTES = (1n << 256n) - 1n;
    expect(sig.r <= MAX_32_BYTES).toBe(true);
    expect(sig.s <= MAX_32_BYTES).toBe(true);
  });

  it('challenge changes per vote (replay prevention)', async () => {
    const a = await buildM2Challenge(1n, 100n);
    const b = await buildM2Challenge(2n, 100n);
    expect(a).not.toEqual(b);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// EIP-191 wrapping — matches the updated Noir circuit (ADR-036 Path C)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Compute the EIP-191 wrapped message hash that the updated Noir circuit verifies.
 * Matches: keccak256("\x19Ethereum Signed Message:\n32" || challenge)
 * Uses @noble/hashes/sha3 keccak_256 (available via @aztec/foundation transitive dep).
 */
async function wrapEip191(challenge: Uint8Array): Promise<Uint8Array> {
  const { keccak_256 } = await import('@noble/hashes/sha3');
  const EIP191_PREFIX = new Uint8Array([
    0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
    0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
    0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
    0x3a, 0x0a, 0x33, 0x32,
  ]);
  const wrapped = new Uint8Array(60);
  wrapped.set(EIP191_PREFIX);
  wrapped.set(challenge, 28);
  return keccak_256(wrapped);
}

describe('EIP-191 wrapping (ADR-036 Path C — matches Noir circuit)', () => {
  it('prefix is exactly 28 bytes: \\x19 + "Ethereum Signed Message:\\n32"', () => {
    const expected = new TextEncoder().encode('\x19Ethereum Signed Message:\n32');
    expect(expected).toHaveLength(28);
    // spot-check first and last bytes
    expect(expected[0]).toBe(0x19);
    expect(expected[27]).toBe(0x32); // '2' in ASCII
  });

  it('wrapped message is 60 bytes (28 prefix + 32 challenge)', async () => {
    const challenge = await buildM2Challenge(0n, 0n);
    // 28 prefix + 32 challenge = 60
    const EIP191_PREFIX = new Uint8Array([
      0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
      0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
      0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
      0x3a, 0x0a, 0x33, 0x32,
    ]);
    const wrapped = new Uint8Array(60);
    wrapped.set(EIP191_PREFIX);
    wrapped.set(challenge, 28);
    expect(wrapped).toHaveLength(60);
    expect(wrapped.slice(0, 28)).toEqual(EIP191_PREFIX);
    expect(wrapped.slice(28)).toEqual(challenge);
  });

  it('keccak256(eip191(challenge)) produces 32 bytes', async () => {
    const challenge = await buildM2Challenge(1n, 2n);
    const msgHash = await wrapEip191(challenge);
    expect(msgHash).toHaveLength(32);
  });

  it('eip191 wrapping is deterministic', async () => {
    const challenge = await buildM2Challenge(42n, 99n);
    const a = await wrapEip191(challenge);
    const b = await wrapEip191(challenge);
    expect(a).toEqual(b);
  });

  it('different challenges produce different eip191 hashes', async () => {
    const a = await wrapEip191(await buildM2Challenge(1n, 0n));
    const b = await wrapEip191(await buildM2Challenge(2n, 0n));
    expect(a).not.toEqual(b);
  });

  it('secp256k1 signature over eip191 hash verifies correctly', async () => {
    const { secp256k1 } = await import('@noble/curves/secp256k1');
    const challenge = await buildM2Challenge(7n, 13n);
    const msgHash = await wrapEip191(challenge);
    const privKey = Uint8Array.from(Buffer.from(TEST_PRIVKEY_HEX, 'hex'));
    const sig = secp256k1.sign(msgHash, privKey, { lowS: true });
    const pubKey = secp256k1.getPublicKey(privKey, true);
    expect(secp256k1.verify(sig, msgHash, pubKey)).toBe(true);
  });

  it('raw sha256 challenge and eip191 hash are different (circuit mismatch test)', async () => {
    // Guards against accidentally wiring the raw challenge into the EIP-191 circuit.
    const challenge = await buildM2Challenge(1n, 1n);
    const msgHash = await wrapEip191(challenge);
    // msgHash is keccak256 of the wrapped input; challenge is sha256 of the input.
    // These should differ (different hash functions on different inputs).
    expect(Buffer.from(challenge).toString('hex')).not.toBe(
      Buffer.from(msgHash).toString('hex'),
    );
  });
});
