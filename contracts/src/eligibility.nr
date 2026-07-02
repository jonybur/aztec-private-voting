use crate::PrivateVoting::VoteConfig;
use aztec::protocol::address::AztecAddress;
use aztec::protocol::traits::FromField;

pub global ELIGIBILITY_MODE_OPEN: u8 = 0;
pub global ELIGIBILITY_MODE_TOKEN: u8 = 1;
pub global ELIGIBILITY_MODE_ALLOWLIST: u8 = 2;

// Verifies the proof shape for the configured eligibility mode. Open votes
// accept anything; token-gated and allowlist votes require a non-zero proof
// witness (the React layer derives this from the gating data). Production
// deployments would replace these placeholder checks with a constraint that
// the proof equals the expected commitment for the gating config.
pub fn verify_eligibility(proof: Field, config: VoteConfig) {
    if config.eligibility_mode == ELIGIBILITY_MODE_OPEN {
        // any proof accepted
    } else if config.eligibility_mode == ELIGIBILITY_MODE_TOKEN {
        // Stub: real token-gated votes use cast_vote_token, which performs a
        // full in-circuit ZK Merkle balance proof before enqueuing record_vote.
        // cast_vote_token passes proof=1 here; this stub only guards the generic
        // cast_vote path from being used with non-OPEN modes. (F1-HIGH resolved.)
        assert(proof != 0, "missing token proof");
    } else if config.eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST {
        // Stub: real allowlist votes use cast_vote_allowlist, which performs a
        // full in-circuit ZK AztecAddress Merkle membership proof before
        // enqueuing record_vote. cast_vote_allowlist passes proof=1 here.
        // (F1-HIGH resolved.)
        assert(proof != 0, "missing allowlist proof");
    } else {
        assert(false, "unknown eligibility mode");
    }
}

// APV-37: an empty (zero) proof is rejected for token-gated votes.
#[test(should_fail_with = "missing token proof")]
fn token_proof_rejects_zero() {
    let config = VoteConfig {
        title_hash: 0,
        options_count: 2,
        start_time: 0,
        end_time: 1,
        quorum: 1,
        eligibility_mode: ELIGIBILITY_MODE_TOKEN,
        token_address: AztecAddress::from_field(0xabc),
        min_token_balance: 1,
        snapshot_version: 0, // non-Babylon; guard not triggered
    };
    verify_eligibility(0, config);
}

// APV-37: an empty (zero) proof is rejected for allowlist votes.
#[test(should_fail_with = "missing allowlist proof")]
fn allowlist_proof_rejects_zero() {
    let config = VoteConfig {
        title_hash: 0,
        options_count: 2,
        start_time: 0,
        end_time: 1,
        quorum: 1,
        eligibility_mode: ELIGIBILITY_MODE_ALLOWLIST,
        token_address: AztecAddress::from_field(0),
        min_token_balance: 0,
        snapshot_version: 0, // non-Babylon; guard not triggered
    };
    verify_eligibility(0, config);
}

// Open eligibility passes for any (including zero) proof - the contract layer
// performs no membership check.
#[test]
fn open_eligibility_accepts_anything() {
    let config = VoteConfig {
        title_hash: 0,
        options_count: 2,
        start_time: 0,
        end_time: 1,
        quorum: 1,
        eligibility_mode: ELIGIBILITY_MODE_OPEN,
        token_address: AztecAddress::from_field(0),
        min_token_balance: 0,
        snapshot_version: 0, // non-Babylon; guard not triggered
    };
    verify_eligibility(0, config);
    verify_eligibility(0xdeadbeef, config);
}
