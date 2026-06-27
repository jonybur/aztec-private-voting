# M3 Tally Privacy: API Feasibility Assessment

**Date:** 2026-06-27  
**Tick:** 4016 (even)  
**Status:** Open question §9.1 from `m3-tally-privacy-implementation-spec-2026-06-27.md` RESOLVED  
**Aztec version checked:** v5.0.0-rc.1  
**Method:** Direct inspection of `aztec-nr` source at that tag

---

## Summary

The M3 spec's §9.1 asked whether Aztec v5 supports creating notes for an
arbitrary coordinator recipient rather than the contract deployer's key.
**Answer: Yes — directly and cleanly via `Owned<PrivateSet>` + `at(coordinator)`.**
No workaround is needed.

The spec's hypothesised `emit_encrypted_log_with_keys(note, encryption_pub_key)`
API does not exist. The correct Aztec v5 API is simpler:

```rust
self.storage.ballots.at(coordinator_address).insert(ballot_note)
                                              .deliver(MessageDelivery::onchain_unconstrained())
```

---

## Findings

### 1. PrivateSet ownership model (Owned wrapper)

Source: `aztec-nr/aztec/src/state_vars/owned.nr` and `private_set.nr`

`Owned<PrivateSet<BallotNote, Context>, Context>` is the standard Aztec v5
pattern for per-account private state. The `Owned.at(address)` method
instantiates the PrivateSet with that address as owner:

```rust
// In Storage:
ballots: Owned<PrivateSet<BallotNote, Context>, Context>,

// In cast_vote (private):
let coordinator = self.storage.coordinator.read_private();
let msg = self.storage.ballots.at(coordinator).insert(ballot_note);
msg.deliver(MessageDelivery::onchain_unconstrained());
```

`PrivateSet.insert(note)` calls `create_note(context, self.owner, storage_slot, note)`
where `self.owner = coordinator_address`. The note hash is computed using the
coordinator's address as the owner, meaning only the coordinator's PXE can sync
and nullify it.

`NoteMessage::deliver(mode)` delivers to the note's owner (coordinator) by default.
`NoteMessage::deliver_to(recipient, mode)` can deliver to a different address — for
example, delivering to a compliance observer while the note is owned by the
coordinator.

### 2. BallotNote schema (Aztec v5 compliant)

Source: `aztec-nr/aztec/src/note/lifecycle.nr`, `note_interface.nr`

The note must implement `NoteType + NoteHash + Packable`. In Aztec v5, `NoteHash`
requires implementing `compute_note_hash(owner, storage_slot, randomness)` and
`compute_nullifier(...)`.

Aztec v5 does not use the `#[derive(Note)]` attribute the spec assumed. The correct
pattern is trait-based:

```rust
pub struct BallotNote {
    pub vote_choice: u8,
    pub receipt_id: Field,
    // Randomness is not stored explicitly in the struct; it is passed to
    // create_note() automatically via random() oracle and stored separately.
}

impl NoteHash for BallotNote {
    fn compute_note_hash(
        self,
        owner: AztecAddress,
        storage_slot: Field,
        randomness: Field,
    ) -> Field {
        // Standard poseidon2 hash of all fields + owner + slot + randomness.
        std::hash::poseidon2::Poseidon2::hash(
            [
                self.vote_choice as Field,
                self.receipt_id,
                owner.to_field(),
                storage_slot,
                randomness,
            ],
            5,
        )
    }
}

impl Packable for BallotNote {
    fn pack(self) -> [Field; 2] {
        [self.vote_choice as Field, self.receipt_id]
    }
    fn unpack(fields: [Field; 2]) -> BallotNote {
        BallotNote { vote_choice: fields[0] as u8, receipt_id: fields[1] }
    }
}
```

Note: the spec's `#[partial_header]` / `NoteHeader` fields are Aztec v4 patterns.
In v5, the note header is managed by the framework internally; the struct contains
only the application fields.

### 3. Delivery mode selection

Source: `aztec-nr/aztec/src/messages/delivery/mod.nr` and `offchain_messages.nr`

Three delivery modes are available:

| Mode | DA guarantee | Gas | Tag derivation | Risk for ballot notes |
|------|-------------|-----|----------------|----------------------|
| `offchain()` | None | Lowest | n/a | ⚠️ HIGH: if coordinator doesn't receive the offchain message, ballot is lost forever |
| `onchain_unconstrained()` | Via protocol logs | Medium | `address_secret` | ✅ Safe: coordinator syncs from on-chain logs; note is recoverable |
| `onchain_constrained()` | Via protocol logs + handshake nullifier | Highest | Non-interactive handshake registry | ⚠️ Overkill: adds handshake complexity; constrained tagging means log squashing can break note recovery |

**Recommendation: `MessageDelivery::onchain_unconstrained()` for ballot notes.**

Rationale: ballot notes must be recoverable (coordinator availability failure ≠
ballot loss). The `onchain_unconstrained()` mode writes the encrypted log to L1
via the Aztec protocol log, giving the coordinator a guaranteed sync path via
node indexing. `offchain()` bypasses DA and risks permanent ballot loss if the
delivery channel fails.

### 4. finalize_tally pattern (coordinator calls pop_notes)

Source: `aztec-nr/aztec/src/state_vars/private_set.nr`

When the coordinator's wallet calls `finalize_tally`, `context.msg_sender()`
is the coordinator's address. The coordinator's PXE has already synced the
BallotNotes from the on-chain logs. `pop_notes` finds and nullifies them:

```rust
#[external("private")]
fn finalize_tally(max_notes: u32) {
    let config = self.storage.config.read_private();
    let now = self.context.timestamp();
    assert(now >= config.end_time, "voting still open");

    let coordinator = self.storage.coordinator.read_private();
    assert(self.context.msg_sender() == coordinator, "only coordinator");

    let options = NoteGetterOptions::new().set_limit(max_notes);
    // pop_notes: reads AND nullifies in one circuit pass.
    let notes = self.storage.ballots.at(coordinator).pop_notes(options);

    for i in 0..max_notes {
        if i < notes.len() {
            let note = notes.get_unchecked(i);
            self.enqueue_self.record_tally_increment(note.vote_choice);
        }
    }
}
```

`pop_notes` is preferable to `get_notes` + `remove` because it requires fewer
constraints (avoids a second read-request check). The spec's loop over
`Option<BallotNote>` is not needed — `BoundedVec` from `pop_notes` is the correct
return type.

### 5. Constructor and Storage changes

```rust
#[storage]
struct Storage<Context> {
    // ... existing fields unchanged ...
    coordinator: PublicImmutable<AztecAddress, Context>,
    ballots: Owned<PrivateSet<BallotNote, Context>, Context>,
}

#[external("public")]
#[initializer]
fn constructor(admin: AztecAddress, coordinator: AztecAddress, config: VoteConfig) {
    // ... existing checks unchanged ...
    self.storage.admin.initialize(admin);
    self.storage.config.initialize(config);
    self.storage.coordinator.initialize(coordinator);
    // Note: Owned<PrivateSet> does not need explicit initialization;
    // it is indexed by owner address at runtime via `.at(coordinator)`.
}
```

### 6. cast_vote changes (corrected from spec)

```rust
#[external("private")]
fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    // ... existing eligibility and claim checks unchanged ...

    let coordinator = self.storage.coordinator.read_private();
    let ballot_note = BallotNote { vote_choice, receipt_id };

    // Create note owned by coordinator; deliver via on-chain log.
    // vote_choice is NEVER in public calldata — it exists only in the
    // encrypted note, readable only by the coordinator's PXE.
    self.storage.ballots
        .at(coordinator)
        .insert(ballot_note)
        .deliver(MessageDelivery::onchain_unconstrained());

    // Public accounting: receipt only, no vote_choice.
    self.enqueue_self.record_vote_m3(receipt_id);
}
```

The same change applies to `cast_vote_token`, `cast_vote_allowlist`,
`cast_vote_babylon`, `cast_vote_babylon_v2`.

---

## Spec corrections (to apply to m3-implementation-spec before coding)

| §9.1 spec assumption | Corrected Aztec v5 pattern |
|---------------------|---------------------------|
| `emit_encrypted_log_with_keys(note, encryption_pub_key)` | `Owned<PrivateSet>.at(coordinator).insert(note).deliver(mode)` |
| `#[derive(Note)]` attribute | Implement `NoteHash + Packable` traits manually |
| `NoteHeader` / `#[partial_header]` in struct | Not used in v5; framework manages internally |
| `BallotNote::compute_nullifier(self, context, counter)` | `NoteHash::compute_note_hash` is the primary trait method; nullifier is derived by the kernel from the note hash + spending key |
| `NoteGetterOptions` loop over `Option<BallotNote>` | Use `pop_notes` → `BoundedVec<BallotNote, MAX_READ_REQUESTS>` |
| `Fr::random()` inline in cast_vote | `random()` oracle is called internally by `create_note`; not needed in application code |

---

## §9.1 Status: CLOSED

**The §9.1 open question is resolved.**

Aztec v5 supports coordinator-recipient ballot notes via the standard
`Owned<PrivateSet>.at(coordinator_address)` pattern. No fallback (hash commitment
+ off-chain choice) is needed. The implementation can proceed exactly as
Architecture A describes once Jony gives the M3 go-decision.

**Estimated implementation time: unchanged** — 2–3 days for an experienced Noir
developer once the go-decision is made. The corrected API patterns above are
drop-in replacements for the spec's hypothesised calls.

---

## §9.2 Status: CONFIRMED (pagination model correct)

`pop_notes` uses `NoteGetterOptions.set_limit(max_notes)`. The Aztec kernel
limit (`MAX_NOTE_HASH_READ_REQUESTS_PER_CALL`) bounds `max_notes`. The coordinator
must call `finalize_tally` in multiple transactions if `vote_count > kernel_limit`.
The `tally_sum == vote_count` guard in `finalize_vote` correctly catches incomplete
accumulation — spec §9.2 analysis is accurate.

---

## §9.3 Status: CONFIRMED (coordinator availability risk)

Delivery via `onchain_unconstrained()` mitigates this: even if the coordinator's
PXE sync fails during the vote window, they can re-sync from the Aztec archive
node at any time using the on-chain encrypted logs. Key loss is the irreducible
risk; the multi-sig mitigation in the spec is still the recommended production
hardening.

---

_Assessment by heartbeat tick-4016. Inspected aztec-nr source at tag v5.0.0-rc.1.
Ready to hand to Jony alongside the M3 go-decision request._
