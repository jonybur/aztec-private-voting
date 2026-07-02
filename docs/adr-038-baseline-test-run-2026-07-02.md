# ADR-038 Pre-upgrade Baseline — Nargo Test Run (tick-4480)

**Date:** 2026-07-02 (tick-4480)
**nargo version:** 1.0.0-beta.22 (c57152f)
**Status:** ✅ ALL TESTS PASS — clean baseline confirmed

## Results

| Project | Tests | Status |
|---------|-------|--------|
| contracts (private_voting) | 20/20 | ✅ PASS |
| m2-sig-tests | 7/7 | ✅ PASS |
| baby-proof | 2/2 | ✅ PASS |
| **Total** | **29/29** | **✅ PASS** |

## Tests included

**contracts/src/merkle.nr (SHA-256d baseline):**
- derive_hash160_sha256d_deterministic ✅
- derive_hash160_sha256d_differs_by_key ✅
- derive_hash160_sha256d_known_vector ✅
- compute_leaf_v2_* (3 tests) ✅
- compute_token_leaf_* (3 tests) ✅
- baby_eligibility_v2_* (2 tests) ✅
- compute_aztec_leaf_* (3 tests) ✅
- encode_decode_field_round_trips ✅

**m2-sig-tests (EIP-191 + secp256k1 signing path):**
- eip191_m2_full_path_passes ✅
- valid_sig_passes_verification ✅
- invalid_sig_fails_verification ✅
- valid_sig_wrong_challenge_fails ✅
- valid_sig_wrong_pubkey_fails ✅
- encoding_fix_correct_challenge_passes ✅
- encoding_fix_wrong_challenge_fails ✅

**baby-proof (balance gate):**
- test_balance_check_passes ✅
- test_balance_check_rejects_low ✅

## Significance for ADR-038

After Jony approves ADR-038:
- Steps 1–4 (code changes to Nargo.toml + merkle.nr + main.nr + synthetic-snapshot.ts) can be applied
- Steps 1–4 will break the 3 `derive_hash160_sha256d_*` tests (expected — they test the prototype derivation)
- New `derive_hash160_cosmos_*` tests must be added with correct Cosmos test vectors
- The `m2-sig-tests` (7 tests) will be unaffected — they test signing path only, not address derivation
- The `baby-proof` (2 tests) will be unaffected
- Expected post-upgrade test count: 26+ (3 sha256d tests removed, ≥3 cosmos tests added)
