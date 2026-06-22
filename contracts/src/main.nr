mod eligibility;
mod merkle;

use aztec::macros::aztec;

#[aztec]
pub contract PrivateVoting {
    use aztec::macros::{
        functions::{external, initializer, only_self, view},
        storage::storage,
    };
    use aztec::protocol::{
        address::AztecAddress,
        traits::{Deserialize, Packable, Serialize, ToField},
    };
    use aztec::state_vars::{Map, Owned, PublicImmutable, PublicMutable, SingleUseClaim};

    use crate::eligibility::{
        verify_eligibility,
        ELIGIBILITY_MODE_OPEN,
        ELIGIBILITY_MODE_TOKEN,
        ELIGIBILITY_MODE_ALLOWLIST,
    };
    use sha256::sha256_var;
    use std::ecdsa_secp256k1;
    use std::hash::keccak256;
    use crate::merkle::{
        derive_hash160_sha256d,
        encode_field_as_root,
        hash_bytes_as_field,
        verify_aztec_allowlist,
        verify_baby_eligibility,
        verify_baby_eligibility_v2,
        verify_token_eligibility,
    };

    global MAX_OPTIONS: u32 = 8;

    #[derive(Eq, Packable, Serialize, Deserialize)]
    pub struct VoteConfig {
        pub title_hash: Field,
        pub options_count: u8,
        pub start_time: u64,
        pub end_time: u64,
        pub quorum: u64,
        pub eligibility_mode: u8,
        pub token_address: AztecAddress,
        pub min_token_balance: u64,
    }

    #[storage]
    struct Storage<Context> {
        admin: PublicImmutable<AztecAddress, Context>,
        config: PublicImmutable<VoteConfig, Context>,
        // voter => single use claim ensuring each wallet votes at most once.
        // The claim's protocol nullifier is derived from the caller's keys in
        // the private kernel, so it is not linkable to the wallet by observers.
        vote_claims: Owned<SingleUseClaim<Context>, Context>,
        // receipt_id => recorded. Receipt ids are client-generated random
        // fields (or, in Babylon mode, derived from the snapshot leaf) and
        // back the verify_vote_counted receipt check.
        receipts: Map<Field, PublicMutable<bool, Context>, Context>,
        tally: Map<u8, PublicMutable<u64, Context>, Context>,
        vote_count: PublicMutable<u64, Context>,
        is_finalized: PublicMutable<bool, Context>,
    }

    #[external("public")]
    #[initializer]
    fn constructor(admin: AztecAddress, config: VoteConfig) {
        assert(config.options_count > 1, "need at least 2 options");
        assert(config.options_count as u32 <= MAX_OPTIONS, "too many options");
        assert(config.end_time > config.start_time, "end before start");
        assert(config.quorum > 0, "quorum must be at least 1");
        // Security hardening (N-F4): in TOKEN mode a zero min_token_balance would
        // admit every address in the snapshot (balance >= 0 is always true).
        // Enforce a positive threshold at deploy time so the deployer cannot
        // accidentally create an open vote while intending token gating.
        if config.eligibility_mode == ELIGIBILITY_MODE_TOKEN {
            assert(
                config.min_token_balance > 0,
                "token mode: min_token_balance must be > 0",
            );
        }
        self.storage.admin.initialize(admin);
        self.storage.config.initialize(config);
    }

    // Voter casts a private ballot. Double voting is prevented by a private
    // single-use claim per wallet: its protocol nullifier is derived from the
    // caller's keys inside the private kernel, so no observer can link a
    // wallet to a ballot. The receipt_id is a client-generated random field
    // used only for the receipt check; it must not be derived from the wallet.
    //
    // Eligibility restriction (F1-RESIDUAL fix, 2026-06-22): this entrypoint
    // is only callable on OPEN mode contracts. TOKEN-gated and ALLOWLIST-gated
    // votes must use cast_vote_token or cast_vote_allowlist respectively, which
    // perform in-circuit Merkle membership proofs before enqueuing record_vote.
    // Without this guard, any caller could bypass gating by calling
    // cast_vote(choice, 1, receipt_id) — proof=1 satisfies the eligibility.nr
    // stub, so the mode-specific entrypoints are bypass-able from cast_vote.
    // See: docs/security-review-2026-06-22.md, F1-RESIDUAL amendment.
    //
    // Known limitation (L1 privacy): vote_choice is a public argument of the
    // enqueued record_vote call, so per-ballot choices are publicly visible
    // (anonymous, but plaintext). A voter who shares their receipt_id reveals
    // their choice. Hidden tallies are the M2 roadmap item.
    #[external("private")]
    fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
        assert(receipt_id != 0, "receipt_id must be non-zero");
        // Security (F1-RESIDUAL): block cast_vote on gated contracts.
        // TOKEN and ALLOWLIST mode votes must use cast_vote_token /
        // cast_vote_allowlist — those paths perform the actual in-circuit
        // Merkle proof. This assertion is redundant for correctly-deployed
        // open votes but is a critical guard against misuse on gated contracts.
        let config = self.storage.config.read();
        assert(
            config.eligibility_mode == ELIGIBILITY_MODE_OPEN,
            "cast_vote: gated votes require cast_vote_token or cast_vote_allowlist",
        );
        self.storage.vote_claims.at(self.msg_sender()).claim();
        self.enqueue_self.record_vote(vote_choice, eligibility_proof, receipt_id);
    }

    // Token-gated governance entrypoint: voter proves their AztecAddress holds
    // >= min_token_balance tokens at the snapshot committed in VoteConfig.
    //
    // This replaces the F1-HIGH stub in verify_eligibility (proof != 0) for
    // TOKEN mode with a real in-circuit ZK Merkle balance proof.
    //
    // Snapshot model: the deployer takes a snapshot of token holders at vote
    // creation time and commits the Merkle root in config.token_address. This
    // avoids real-time token contract integration while preserving the full
    // privacy guarantee: the circuit never touches on-chain token state.
    //
    // Private witnesses (never visible on-chain):
    //   token_balance  - claimed balance at snapshot
    //   merkle_path    - sibling hashes from leaf to root (depth 20)
    //   merkle_indices - direction bits (0=left, 1=right) at each level
    //
    // Public inputs (committed in VoteConfig):
    //   merkle_root    - stored in token_address field (31-byte Field encoding)
    //   min_token_balance - minimum required balance
    //   vote_choice    - public (same L1 privacy note as cast_vote)
    //   receipt_id     - client-generated random; non-zero; backs verify_vote_counted
    //
    // Leaf format:  sha256( address_bytes[32] || balance_be[8] )  (40 bytes)
    //   where address_bytes = [0x00] || caller_field.to_be_bytes()[0..31]
    //
    // Off-chain snapshot generator MUST use the same leaf scheme; see
    // merkle.nr compute_token_leaf.
    //
    // Double-voting is prevented by the protocol's SingleUseClaim nullifier,
    // derived from the caller's protocol keys inside the private kernel
    // (not from the Merkle leaf), so it is not linkable to the address.
    //
    // Known limitation: vote_choice is a public argument of the enqueued
    // record_vote call (same L1 privacy gap as cast_vote). See cast_vote.
    #[external("private")]
    fn cast_vote_token(
        vote_choice: u8,
        receipt_id: Field,
        token_balance: u64,
        merkle_path: [[u8; 32]; 20],
        merkle_indices: [bool; 20],
    ) {
        assert(receipt_id != 0, "receipt_id must be non-zero");

        let config = self.storage.config.read();
        assert(
            config.eligibility_mode == ELIGIBILITY_MODE_TOKEN,
            "cast_vote_token: contract not in token mode",
        );

        // Verify the caller's AztecAddress holds >= min_token_balance at the
        // committed snapshot. The Merkle root is encoded in config.token_address
        // (same 31-byte Field encoding as the allowlist root).
        let caller_field = self.msg_sender().to_field();
        let root_field = config.token_address.to_field();
        let _ = verify_token_eligibility(
            caller_field,
            token_balance,
            config.min_token_balance,
            merkle_path,
            merkle_indices,
            root_field,
        );

        // Use the protocol's single-use claim to prevent double-voting.
        // The nullifier is derived from the caller's private keys in the
        // private kernel — not from the Merkle leaf — so observers cannot
        // link the nullifier back to the token holder entry.
        self.storage.vote_claims.at(self.msg_sender()).claim();

        // Eligibility proven above; pass 1 as the dummy proof field.
        self.enqueue_self.record_vote(vote_choice, 1, receipt_id);
    }

    // Allowlist governance entrypoint: voter proves their AztecAddress is a
    // member of the committed allowlist Merkle tree.
    //
    // This replaces the F1-HIGH stub in verify_eligibility (proof != 0) with
    // a real in-circuit ZK membership proof for ALLOWLIST mode votes.
    //
    // Private witnesses (never visible on-chain):
    //   merkle_path    - sibling hashes from leaf to root (depth 20)
    //   merkle_indices - direction bits (0=left, 1=right) at each level
    //
    // Public inputs (committed in VoteConfig):
    //   merkle_root    - stored in token_address field (31 bytes encoded as Field)
    //   vote_choice    - public (same L1 privacy note as cast_vote)
    //   receipt_id     - client-generated random; non-zero; backs verify_vote_counted
    //
    // Leaf format:  sha256( address_field_bytes[32] )
    //   where address_field_bytes = [0x00] || address.to_field().to_be_bytes()[0..31]
    //
    // Off-chain allowlist generator MUST use the same leaf scheme; see
    // merkle.nr compute_aztec_leaf and docs/allowlist-generator.md.
    //
    // Double-voting is prevented by the protocol's SingleUseClaim nullifier,
    // which is derived from the caller's protocol keys inside the private
    // kernel (not from the Merkle leaf), so it is not linkable to the address.
    //
    // Known limitation: vote_choice is a public argument of the enqueued
    // record_vote call (same L1 privacy gap as cast_vote). See cast_vote
    // comment for full context.
    #[external("private")]
    fn cast_vote_allowlist(
        vote_choice: u8,
        receipt_id: Field,
        merkle_path: [[u8; 32]; 20],
        merkle_indices: [bool; 20],
    ) {
        assert(receipt_id != 0, "receipt_id must be non-zero");

        let config = self.storage.config.read();
        assert(
            config.eligibility_mode == ELIGIBILITY_MODE_ALLOWLIST,
            "cast_vote_allowlist: contract not in allowlist mode",
        );

        // Verify that the caller's AztecAddress is in the committed allowlist.
        // The Merkle root is encoded in config.token_address (same 31-byte
        // Field encoding used for the Babylon Merkle root; see encode_field_as_root).
        let caller_field = self.msg_sender().to_field();
        let root_field = config.token_address.to_field();
        let _ = verify_aztec_allowlist(caller_field, merkle_path, merkle_indices, root_field);

        // Use the protocol's single-use claim to prevent double-voting.
        // The claim's nullifier is derived from the caller's private keys
        // in the private kernel — not from the Merkle leaf — so observers
        // cannot link the nullifier to the allowlist entry.
        self.storage.vote_claims.at(self.msg_sender()).claim();

        // Eligibility proven above; pass 1 as the dummy proof field.
        self.enqueue_self.record_vote(vote_choice, 1, receipt_id);
    }

    // Babylon governance entrypoint: voter proves BABY token holding via
    // a Merkle membership proof over the snapshot taken at vote creation.
    //
    // Private witnesses (never visible on-chain):
    //   address_bytes - bbn1... cosmos address as UTF-8 (45 bytes)
    //   balance       - claimed ubbn balance at snapshot
    //   merkle_path   - sibling hashes from leaf to root (depth 20)
    //   merkle_indices - direction bits (0=left, 1=right) at each level
    //
    // Public inputs (committed in the VoteConfig):
    //   merkle_root   - stored in token_address field (32-byte encoding)
    //   min_balance   - stored in min_token_balance (ubbn)
    //
    // The Merkle root is stored in the config's token_address field as a
    // Field element (lower 31 bytes of the 32-byte SHA-256 root).
    #[external("private")]
    fn cast_vote_babylon(
        vote_choice: u8,
        address_bytes: [u8; 45],
        balance: u64,
        merkle_path: [[u8; 32]; 20],
        merkle_indices: [bool; 20],
    ) {
        let config = self.storage.config.read();

        // Reconstruct the committed Merkle root from the config.
        // The deployer encodes the root as: token_address = Field(root[1..32])
        // (first byte dropped to fit in a Field - matches encode_root_as_field
        //  in synthetic-snapshot.ts)
        let root_field = config.token_address.to_field();
        let root_bytes = encode_field_as_root(root_field);

        // Verify BABY membership + balance threshold inside the circuit.
        let leaf = verify_baby_eligibility(
            address_bytes,
            balance,
            config.min_token_balance,
            merkle_path,
            merkle_indices,
            root_bytes,
        );

        // Per-holder nullifier derived in-circuit from the snapshot leaf:
        // one vote per snapshot entry. Known limitation: the leaf is computed
        // from public snapshot data (address + balance), so an observer with
        // the snapshot can tell WHETHER a holder voted. Fixing this requires
        // an in-circuit ownership proof (Cosmos secp256k1 signature) with a
        // holder-secret-derived nullifier - see ROADMAP.md M2.
        let holder_nullifier = hash_bytes_as_field(leaf);

        // Eligibility already proven above - pass 1 as the dummy proof field.
        self.enqueue_self.record_vote(vote_choice, 1, holder_nullifier);
    }

    // M2 Babylon governance entrypoint: proves BABY token holding with an
    // in-circuit secp256k1 ownership proof.
    //
    // This closes the snapshot-forwarding attack present in cast_vote_babylon:
    // M1 nullifiers are computable by any observer who has the public snapshot
    // (published for audit), because the nullifier is derived from the leaf
    // hash of (address, balance) — both public. M2 requires a valid secp256k1
    // signature over a vote-specific challenge to produce a proof, so an
    // attacker without the holder's Cosmos private key cannot vote on their
    // behalf, regardless of snapshot access.
    //
    // Private witnesses (never visible on-chain):
    //   balance        - claimed ubbn balance at snapshot
    //   merkle_path    - sibling hashes from leaf to root (depth 20)
    //   merkle_indices - direction bits (0=left, 1=right) at each level
    //   pubkey_x       - secp256k1 public key x-coordinate (32 bytes BE)
    //   pubkey_y       - secp256k1 public key y-coordinate (32 bytes BE)
    //   sig            - ECDSA signature r||s (64 bytes) over vote challenge
    //
    // Address derivation: SHA-256d fallback (Fallback B from design spec §9
    // Risk 1). The snapshot Merkle tree MUST be generated with the same scheme.
    // Production path: replace derive_hash160_sha256d with ripemd160(sha256(pk))
    // once noir-ripemd160 crate compatibility is confirmed.
    //
    // Challenge = sha256( title_hash_encoded[32] || merkle_root_encoded[32] )
    // Both values are committed in VoteConfig; unique per deployed vote.
    // The wallet signs this 32-byte digest using the holder's secp256k1 key.
    //
    // WARNING (§9 Risk 2): secp256k1 ECDSA in-circuit uses non-native field
    // arithmetic (~80k-120k Barretenberg gates). Proving time ~2-4s browser
    // (M2 hardware); measure before launch. Acceptable for governance votes.
    //
    // Related: docs/m2-secp256k1-ownership-proof-design.md
    #[external("private")]
    fn cast_vote_babylon_v2(
        vote_choice: u8,
        balance: u64,
        merkle_path: [[u8; 32]; 20],
        merkle_indices: [bool; 20],
        pubkey_x: [u8; 32],
        pubkey_y: [u8; 32],
        sig: [u8; 64],
    ) {
        let config = self.storage.config.read();

        // 1. Reconstruct committed Merkle root from config.
        //    Root is encoded in token_address field (lower 31 bytes of SHA-256).
        let root_field = config.token_address.to_field();
        let root_bytes = encode_field_as_root(root_field);

        // 2. Compute vote-specific challenge to prevent signature replay
        //    across different votes. Both title_hash and the Merkle root are
        //    committed in the immutable VoteConfig, so this challenge is
        //    unique per vote and cannot be forged by an attacker.
        //    challenge = sha256( title_hash_encoded[32] || root_bytes[32] )
        let title_bytes = encode_field_as_root(config.title_hash);
        let mut challenge_input = [0u8; 64];
        for i in 0..32 { challenge_input[i] = title_bytes[i]; }
        for i in 0..32 { challenge_input[32 + i] = root_bytes[i]; }
        let challenge = sha256_var(challenge_input, 64);

        // 3. EIP-191 wrapping for MetaMask / EVM wallet compatibility.
        //    ADR-036 Path C (see docs/adr-036-m2-wallet-signing-path.md).
        //    MetaMask personal_sign prepends "\x19Ethereum Signed Message:\n32"
        //    before the 32-byte payload, then keccak256-hashes the 60-byte result.
        //    The circuit replicates this so the voter can sign with MetaMask,
        //    Ledger, or any EIP-191-compatible EVM wallet.
        //
        //    msg_hash = keccak256("\x19Ethereum Signed Message:\n32" || challenge)
        //             = keccak256(eip191_prefix[28] || challenge[32])
        //
        //    std::ecdsa_secp256k1 gate cost: ~100k; keccak256 adds ~5k.
        //    IMPORTANT: Barretenberg requires low-S form (s <= n/2, BIP-62).
        //    The wallet/frontend MUST normalize s before passing to this circuit.
        //    Ethers v6 signMessage() normalises automatically. See m2-sig-tests/.
        let eip191_prefix: [u8; 28] = [
            0x19, 0x45, 0x74, 0x68, 0x65, 0x72, 0x65, 0x75,
            0x6d, 0x20, 0x53, 0x69, 0x67, 0x6e, 0x65, 0x64,
            0x20, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65,
            0x3a, 0x0a, 0x33, 0x32
        ];
        let mut eip191_msg: [u8; 60] = [0; 60];
        for i in 0..28 { eip191_msg[i] = eip191_prefix[i]; }
        for i in 0..32 { eip191_msg[28 + i] = challenge[i]; }
        let msg_hash = keccak256(eip191_msg, 60);
        let sig_valid = ecdsa_secp256k1::verify_signature(pubkey_x, pubkey_y, sig, msg_hash);
        assert(sig_valid, "invalid secp256k1 signature: not the key owner (EIP-191)");

        // 4. Derive 20-byte address commitment from the public key.
        //    PROTOTYPE: SHA-256d fallback, not standard Cosmos hash160.
        //    Replace with ripemd160(sha256(compressed_pubkey)) for production.
        let hash160 = derive_hash160_sha256d(pubkey_x, pubkey_y);

        // 5. Verify Merkle membership with the M2 leaf format.
        //    Proves (hash160, balance) is in the committed snapshot.
        let _ = verify_baby_eligibility_v2(
            hash160,
            balance,
            config.min_token_balance,
            merkle_path,
            merkle_indices,
            root_bytes,
        );

        // 6. Derive holder nullifier from signature material.
        //    Under RFC 6979, (r, s) is deterministic given (privkey, challenge).
        //    An attacker without privkey cannot compute the correct sig, so
        //    they cannot pre-compute or steal this nullifier.
        //    Including both r and s prevents second-preimage on s alone.
        let holder_nullifier = hash_bytes_as_field(sha256_var(sig, 64));

        // 7. Enqueue the public vote record.
        self.enqueue_self.record_vote(vote_choice, 1, holder_nullifier);
    }

    // The public half of cast_vote. Validates timing, eligibility, the
    // receipt uniqueness guard, and increments the per-option counter.
    #[external("public")]
    #[only_self]
    fn record_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
        let config = self.storage.config.read();
        assert((vote_choice as u32) < (config.options_count as u32), "invalid choice");

        let now = self.context.timestamp();
        assert(now >= config.start_time, "voting not started");
        assert(now < config.end_time, "voting ended");
        assert(self.storage.is_finalized.read() == false, "already finalized");

        verify_eligibility(eligibility_proof, config);

        let already_used = self.storage.receipts.at(receipt_id).read();
        assert(already_used == false, "receipt already used");
        self.storage.receipts.at(receipt_id).write(true);

        let prev = self.storage.tally.at(vote_choice).read();
        self.storage.tally.at(vote_choice).write(prev + 1);

        let count = self.storage.vote_count.read();
        self.storage.vote_count.write(count + 1);
    }

    #[external("public")]
    fn finalize_vote() {
        let config = self.storage.config.read();
        let now = self.context.timestamp();
        assert(now >= config.end_time, "voting still open");
        assert(self.storage.is_finalized.read() == false, "already finalized");
        assert(self.storage.vote_count.read() >= config.quorum, "quorum not met");
        self.storage.is_finalized.write(true);
    }

    #[external("public")]
    #[view]
    fn verify_vote_counted(receipt_id: Field) -> pub bool {
        self.storage.receipts.at(receipt_id).read()
    }

    #[external("public")]
    #[view]
    fn get_vote_count() -> pub u64 {
        self.storage.vote_count.read()
    }

    #[external("public")]
    #[view]
    fn get_final_tally(option_index: u8) -> pub u64 {
        assert(self.storage.is_finalized.read(), "not finalized");
        self.storage.tally.at(option_index).read()
    }

    #[external("public")]
    #[view]
    fn is_finalized() -> pub bool {
        self.storage.is_finalized.read()
    }

    #[external("public")]
    #[view]
    fn get_config() -> pub VoteConfig {
        self.storage.config.read()
    }

    // Get Merkle root stored in this vote config (for the Babylon governance demo).
    // Returns the token_address field which encodes the BABY snapshot Merkle root.
    #[external("public")]
    #[view]
    fn get_merkle_root() -> pub Field {
        self.storage.config.read().token_address.to_field()
    }
}
