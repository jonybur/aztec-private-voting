# M3 Tally Privacy: Implementation Specification

**Date:** 2026-06-27  
**Status:** Implementation-ready spec — pending Jony's M3 go-decision  
**Author:** heartbeat agent  
**Prereq:** Architecture A selected (m2-tally-privacy-design-spike-2026-06-22.md §9)  
**Scope:** Closes the Named Limitation: vote_choice visible in public calldata

---

## 1. The problem being solved

Every `cast_vote` path ends with:

```rust
self.enqueue_self.record_vote(vote_choice, eligibility_proof, receipt_id);
```

`record_vote` is `#[external("public")]`, meaning Aztec executes it as the public
half of the transaction. Its arguments — including `vote_choice: u8` — appear as
plaintext in L1 calldata. Any observer indexing `record_vote` calls can read:

```
record_vote(vote_choice=1, eligibility_proof=1, receipt_id=0xa3f9...)
```

The receipt's surrogate independence guarantee (Invariant 1) holds at the receipt
layer: `receipt_id` does not reveal `vote_choice`. But the calldata record links
`receipt_id` to `vote_choice` at the same transaction, before the receipt is even
delivered to the voter. The receipt's non-coercibility claim is correct for the
receipt artefact itself; the L1 calldata is a separate coercion surface.

M3 closes this by encrypting `vote_choice` inside the Aztec private kernel
and removing it from public calldata entirely.

---

## 2. Architecture A mechanism (recap from design spike)

**Before M3 (current):**
```
cast_vote (private) → enqueue record_vote(vote_choice) (public)
                                        ^^^^^^^^^^^^^ L1 calldata
```

**After M3:**
```
cast_vote (private) → store BallotNote(vote_choice) encrypted to coordinator
                    → enqueue record_vote_m3()          ← no vote_choice arg
                                        
finalize_tally (coordinator-private, post-deadline) → read BallotNote pool
                                                     → enqueue record_tally(choice, n) 
```

The coordinator's PXE decrypts the ballot note pool. Only the coordinator ever
sees individual choices. The public record shows only: "a valid vote was cast
for this receipt_id." The running tally stays hidden until `finalize_tally` runs.

---

## 3. New storage fields

```rust
#[storage]
struct Storage<Context> {
    // ... existing fields unchanged ...

    // M3: coordinator Aztec address (set at constructor; receives BallotNotes)
    coordinator: PublicImmutable<AztecAddress, Context>,

    // M3: encrypted ballot note storage — notes emitted to coordinator's address.
    // BallotNote contains: vote_choice (u8), randomness (Field), receipt_id (Field).
    // Use Owned<PrivateSet<...>> so notes are indexed by recipient address;
    // coordinator reads their notes via .at(coordinator_address).
    ballots: Owned<PrivateSet<BallotNote, Context>, Context>,

    // M3: running tally is no longer public during the vote window.
    // Replace: tally: Map<u8, PublicMutable<u64, Context>, Context>
    // With:    tally: Map<u8, PublicMutable<u64, Context>, Context>  [unchanged type]
    // The tally Map entries remain 0 until finalize_tally is complete.
    // get_final_tally already requires is_finalized == true — this is sufficient.

    // M3: vote_count remains public (needed for quorum check + UX progress).
    // This leaks participation rate but not direction — acceptable.
}
```

No new public state is needed. The existing `tally` map is re-purposed: entries
remain zero until the coordinator runs `finalize_tally` after the vote closes.

---

## 4. BallotNote schema

```rust
// BallotNote — encrypted to the coordinator's incoming viewing key.
// Stored in `ballots: PrivateSet<BallotNote>`.
//
// Fields:
//   vote_choice  - the voter's choice (u8, range-checked in record_vote_m3)
//   randomness   - Fr::random() blinding factor (prevents note correlation)
//   receipt_id   - links this note to the receipt already in `receipts` map
//                  (allows coordinator to associate note with on-chain receipt)
//   header       - NoteHeader (required by Aztec note interface)
//
// The note is emitted as an encrypted log to the coordinator's address at
// cast_vote time, inside the Aztec private kernel. It is not readable by
// anyone without the coordinator's private incoming viewing key.
#[derive(Note)]
pub struct BallotNote {
    vote_choice: u8,
    randomness: Field,
    receipt_id: Field,
    #[partial_header]
    header: NoteHeader,
}

impl BallotNoteInterface for BallotNote {
    fn get_note_type_id() -> Field {
        // Unique identifier for this note type; conventionally the contract address.
        comptime { compute_note_type_id("BallotNote") }
    }

    fn compute_nullifier(self, context: &mut PrivateContext, note_hash_counter: u32) -> Field {
        // Nullifier = poseidon2(note_hash, spending_key_as_field)
        // Prevents double-nullification by the coordinator at finalization time.
        let note_hash = self.compute_note_hash(note_hash_counter);
        let secret = context.request_nsk_app(self.get_note_type_id());
        std::hash::poseidon2::Poseidon2::hash([note_hash, secret], 2)
    }
}
```

---

## 5. Contract changes

### 5.1 Constructor — add coordinator

```rust
// Old:
fn constructor(admin: AztecAddress, config: VoteConfig)

// New:
fn constructor(admin: AztecAddress, coordinator: AztecAddress, config: VoteConfig) {
    // ... existing init ...
    self.storage.coordinator.initialize(coordinator);
}
```

The coordinator can be the same as `admin` for single-operator deployments (the
facilitator model). Separating the roles enables future multi-party setups.

### 5.2 cast_vote (private) — store BallotNote instead of enqueuing vote_choice

```rust
#[external("private")]
fn cast_vote(vote_choice: u8, eligibility_proof: Field, receipt_id: Field) {
    // ... existing eligibility checks unchanged ...

    // M3 CHANGE: store encrypted ballot note to coordinator instead of
    // enqueuing vote_choice as a public argument.
    let coordinator = self.storage.coordinator.read_private();
    let note = BallotNote {
        vote_choice,
        randomness: Fr::random(),
        receipt_id,
        header: NoteHeader::empty(),
    };
    // Insert the note into the coordinator's slot and deliver it on-chain.
    // Aztec v4.3.1 API: .at(recipient).insert(note).deliver(delivery_mode)
    // — confirmed in aztec-nr v4.3.1 docs (NFT bridge tutorial).
    // vote_choice does NOT appear in public calldata.
    use aztec::messages::message_delivery::MessageDelivery;
    self.storage.ballots.at(coordinator).insert(note).deliver(MessageDelivery.ONCHAIN_CONSTRAINED);

    // Enqueue the (now vote_choice-free) public accounting step.
    self.enqueue_self.record_vote_m3(receipt_id);
}
```

**Same change applies to** `cast_vote_token`, `cast_vote_allowlist`,
`cast_vote_babylon`, `cast_vote_babylon_v2` — all replace:
```rust
self.enqueue_self.record_vote(vote_choice, ..., receipt_id)
```
with:
```rust
// note storage + emit ...
self.enqueue_self.record_vote_m3(receipt_id)
```

### 5.3 record_vote_m3 (public) — receipt-only accounting

```rust
// M3 replacement for record_vote.
// Records receipt inclusion and increments vote_count.
// Does NOT receive or store vote_choice — choice is never in public calldata.
#[external("public")]
#[only_self]
fn record_vote_m3(receipt_id: Field) {
    let config = self.storage.config.read();
    let now = self.context.timestamp();
    assert(now >= config.start_time, "voting not started");
    assert(now < config.end_time, "voting ended");
    assert(self.storage.is_finalized.read() == false, "already finalized");

    // Receipt uniqueness guard — unchanged from record_vote.
    let already_used = self.storage.receipts.at(receipt_id).read();
    assert(already_used == false, "receipt already used");
    self.storage.receipts.at(receipt_id).write(true);

    // Increment vote_count (participation count; leaks only participation rate).
    let count = self.storage.vote_count.read();
    self.storage.vote_count.write(count + 1);

    // NOTE: tally.at(vote_choice) is NOT incremented here.
    // The per-option counters are updated by the coordinator at finalize_tally time.
}
```

### 5.4 finalize_tally (coordinator-private) — decrypt notes and accumulate

```rust
// Called by the coordinator after end_time.
// Decrypts all BallotNotes from `ballots` PrivateSet, then enqueues
// public tally increments for each decrypted note.
//
// Security: this function is NOT #[only_self]. The coordinator calls it
// from their PXE. The note nullifiers prevent double-tallying.
// Range-check on vote_choice prevents the coordinator from submitting
// an out-of-range choice (the public record_tally_increment asserts bounds).
#[external("private")]
fn finalize_tally(max_notes: u32) {
    let config = self.storage.config.read_private();
    let now = self.context.timestamp();
    assert(now >= config.end_time, "voting still open");

    // Read up to max_notes BallotNotes from the coordinator's PrivateSet.
    // Aztec PXE automatically decrypts these for the coordinator.
    // Coordinator reads their own note slot.
    // .at(coordinator) scopes to the coordinator's address; .pop_notes() nullifies
    // each returned note to prevent double-tally.
    let coordinator_addr = self.storage.coordinator.read_private();
    let options = NoteGetterOptions::new()
        .set_limit(max_notes);
    let notes = self.storage.ballots.at(coordinator_addr).pop_notes(options);

    // pop_notes already nullifies each returned note — no explicit .remove() needed.
    for i in 0..max_notes {
        let note_option = notes[i];
        if note_option.is_some() {
            let note = note_option.unwrap_unchecked();
            // Enqueue public tally increment.
            self.enqueue_self.record_tally_increment(note.vote_choice);
        }
    }
}

// Public half of finalize_tally — increments per-option counter.
// Called once per ballot note; enqueued from finalize_tally private call.
#[external("public")]
#[only_self]
fn record_tally_increment(vote_choice: u8) {
    let config = self.storage.config.read();
    assert((vote_choice as u32) < (config.options_count as u32), "invalid choice");
    // No timing check here — tally accumulation happens post-deadline by design.
    let prev = self.storage.tally.at(vote_choice).read();
    self.storage.tally.at(vote_choice).write(prev + 1);
}
```

### 5.5 finalize_vote — guard on tally completion

```rust
// M3 note: finalize_vote no longer increments tally — that is done by
// finalize_tally. finalize_vote asserts that tally accumulation is complete
// by comparing vote_count against sum of all tally entries.
// (Alternatively: add is_tally_complete: PublicMutable<bool> and set it
// in the last record_tally_increment call when sum == vote_count.)
#[external("public")]
fn finalize_vote() {
    let config = self.storage.config.read();
    let now = self.context.timestamp();
    assert(now >= config.end_time, "voting still open");
    assert(self.storage.is_finalized.read() == false, "already finalized");
    assert(self.storage.vote_count.read() >= config.quorum, "quorum not met");

    // M3: Verify tally sum == vote_count (coordinator has tallied all ballots).
    let mut tally_sum: u64 = 0;
    for i in 0..MAX_OPTIONS as u8 {
        if (i as u32) < (config.options_count as u32) {
            tally_sum += self.storage.tally.at(i).read();
        }
    }
    assert(tally_sum == self.storage.vote_count.read(), "tally incomplete: run finalize_tally first");

    self.storage.is_finalized.write(true);
}
```

---

## 6. What the L1 record looks like before and after

### Before M3 (current L1 calldata for a typical vote):

```
cast_vote (private kernel)
  → nullifier: 0x7f3a...           ← double-vote prevention; not linkable
  → encrypted_log: [opaque]         ← nothing sensitive
  → record_vote(
      vote_choice=1,               ← ❌ VISIBLE: voter chose option 1
      eligibility_proof=1,
      receipt_id=0xa3f9...
    )
```

### After M3 (L1 calldata):

```
cast_vote (private kernel)
  → nullifier: 0x7f3a...           ← unchanged
  → encrypted_log: [BallotNote]    ← opaque ciphertext to coordinator; choice hidden
  → record_vote_m3(
      receipt_id=0xa3f9...         ← ✅ only receipt_id; no choice
    )
```

An observer watching L1 sees: "A vote was cast for receipt 0xa3f9. I cannot tell
which option was chosen."

---

## 7. Property change table (vs current M2)

| Property | Current (M2) | After M3 | Notes |
|----------|-------------|----------|-------|
| P1 Ballot secrecy during window | ❌ | ✅ | vote_choice no longer in calldata |
| P2 Running tally privacy | ❌ | ✅ | tally only written at finalize_tally post-deadline |
| P3 Receipt-freeness | ⚠️ Partial | ⚠️ Partial | Voter can still show note decryption path to coercer; full RF requires mix |
| P4 Coercion resistance | ❌ | ⚠️ Low | Calldata path closed; note decryption path still exists |
| P5 Universal verifiability | ✅ | ✅ | finalize_tally + record_tally_increment are public + auditable |
| P6 Individual verifiability | ✅ | ✅ | verify_vote_counted(receipt_id) unchanged |
| P7 Coordinator trust | ⚠️ | ❌ HIGH | Coordinator sees all choices during finalize_tally; this is the trade-off |
| P8 Prover-side burden | ✅ Low | ✅ Low | BallotNote insert is a single note emit; no extra prover work |
| P11 L1 data leak | ❌ | ✅ | vote_choice removed from public calldata entirely |

**Net change:** M3 closes P1 and P2 (the Named Limitation in the paper), at the
cost of P7 (coordinator trust). This is the Architecture A trade-off: running
tally privacy requires trusting the coordinator not to leak individual choices.

For the CHI paper scope, P7 is the **named trade-off** — honest framing of the
facilitator model. The coordinator is the service operator; DAO members trust the
facilitator already (they deploy the vote, set quorum, control timing). This is
not a new trust requirement; it formalises an existing one.

---

## 8. Impact on CHI paper (Named Limitation resolution)

The CHI paper's Named Limitation states:

> "In the current contract architecture, vote choice remains visible in public
> calldata at the protocol layer, a constraint not resolvable through UI design."

After M3, the correct statement is:

> "In the M2 (Cosmos token-gated) contract, vote choice appeared in public
> calldata. M3 resolves this by storing ballots as Aztec encrypted notes,
> accessible only to a designated coordinator. The coordinator trust model
> (P7) is the remaining limitation: the operator sees individual choices during
> tallying. Full receipt-freeness — where even the coordinator cannot link voter
> to choice — requires a re-encryption mix (M4 scope)."

**Impact on §1.1 Named Limitation paragraph (lines ~60-75):**
If M3 ships before CHI submission, the Named Limitation paragraph must be revised:
- Remove: "vote choice remains visible in public calldata, not resolvable through UI design"
- Add: M3 note-encryption architecture, coordinator trust model, and M4 scope boundary

**Impact on §6.5 limitations:**
Add a paragraph on coordinator trust (P7) as the post-M3 residual limitation.

**Impact on §2.1 Invariant 2:**
Invariant 2 timing clause (`vote_choice must be private until vote closes`)
is now satisfied at the protocol layer. The Named Limitation cross-reference
added in tick-3985 should be revised: it was added *because* of the gap; if M3
closes the gap, the cross-reference changes to "previously open, closed by M3."

---

## 9. Implementation challenges and open questions

### 9.1 PrivateSet recipient — RESOLVED (tick-4269)

**Confirmed API (Aztec v4.3.1 / aztec-nr nightly.20260429):**
```rust
Owned<PrivateSet<BallotNote, Context>, Context>
// emit:
self.storage.ballots.at(coordinator).insert(note).deliver(MessageDelivery.ONCHAIN_CONSTRAINED);
// read (coordinator's PXE):
self.storage.ballots.at(coordinator_addr).pop_notes(options);
```

The `Owned<PrivateSet<...>>` pattern allows notes to be indexed by recipient address.
`emit_encrypted_log_with_keys` is **not needed** — the `.at(recipient)` scope handles
recipient-keyed delivery natively. Confirmed from Aztec v4.3.1 NFT bridge tutorial
(source: docs.aztec.network/developers/nightly/docs/tutorials/js_tutorials/token_bridge):

```rust
// Aztec v4.3.1 pattern for recipient-addressed notes:
owners: Owned<PrivateSet<NFTNote, Context>, Context>,
// ...
self.storage.owners.at(to).insert(new_nft).deliver(MessageDelivery.ONCHAIN_CONSTRAINED);
```

The storage type in §3 and the emission call in §5.2 have been corrected accordingly.
**No open question remains for §9.1.**

### 9.2 finalize_tally pagination

The `ballots` PrivateSet may contain hundreds of notes. Aztec circuits have
note-read limits (typically 8–16 notes per kernel execution). `finalize_tally`
must be called in multiple transactions with `max_notes` <= the kernel limit,
accumulating the tally across calls. The `tally_sum == vote_count` guard in
`finalize_vote` catches incomplete accumulation.

The coordinator must call `finalize_tally` enough times to consume all notes
before calling `finalize_vote`. This is an operator procedure requirement.

**Mitigation:** Add a `tally_progress` counter: `PublicMutable<u64>` that
`record_tally_increment` increments. `finalize_vote` checks
`tally_progress == vote_count` instead of summing the tally map. Cheaper gas.

### 9.3 Coordinator availability assumption

If the coordinator is unavailable after the vote closes (key loss, service failure),
the tally cannot be finalized. This is an availability risk that does not exist in
the current architecture (any observer can compute the tally from public calldata).

**Mitigation:** Multi-sig coordinator (M+of+N Aztec accounts holding the viewing
key, threshold decryption). Or: add an emergency `admin_override_finalize` that
requires Jony's admin key + a time delay (e.g., 7 days post-deadline). The
override path reveals all choices to the admin, which is documented and acceptable
as an emergency fallback.

### 9.4 vote_choice visible to coordinator at finalization (P7)

The coordinator sees all individual choices when decrypting BallotNotes. This is
the fundamental Architecture A trade-off. For DAO governance, this is the same
trust level as a Snapshot off-chain vote moderator or a multisig co-signer.

For the paper: P7 is the **residual limitation** after M3. The HCI contribution
does not depend on resolving P7 — the receipt design closes the calldata coercion
surface (which is what a non-technical DAO voter experiences), and P7 is a
protocol-layer concern that affects a sophisticated attacker (the service operator
itself), not a coercer demanding a screenshot.

### 9.5 Receipt design impact (positive)

`verify_vote_counted(receipt_id)` is unchanged. The voter experience:
- Cast vote → receive receipt with `receipt_id`
- Can call `verify_vote_counted(receipt_id)` → `true` at any time
- Cannot be coerced via the receipt (receipt shows no choice)
- Cannot be coerced via L1 calldata (choice is no longer there)

The receipt design in `docs/receipt-design.md` survives M3 without changes.
The protective absence claim becomes stronger: the choice is absent from both
the receipt artifact AND the L1 transaction record.

---

## 10. Implementation steps (ordered)

| Step | Work | Complexity | Prerequisite |
|------|------|-----------|-------------|
| 1 | Add `BallotNote` type + `compute_nullifier` | Low | — |
| 2 | Add `coordinator` to `VoteConfig` / constructor | Low | — |
| 3 | Add `ballots: Owned<PrivateSet<BallotNote, Context>>` to Storage | Low | Steps 1-2 |
| 4 | Replace `record_vote` with `record_vote_m3` (remove vote_choice arg) | Low | — |
| 5 | Update all `cast_vote*` variants to store note + call `record_vote_m3` | Medium | Steps 1-4 |
| 6 | Implement `record_tally_increment` (public, only_self) | Low | — |
| 7 | Implement `finalize_tally` (coordinator-private) | Medium | Steps 5-6 |
| 8 | Update `finalize_vote` with tally-completeness guard | Low | Step 7 |
| 9 | ~~Verify `emit_encrypted_log_with_keys`~~ — **RESOLVED**: use `.at(coordinator).insert(note).deliver(...)` | Done | — |
| 10 | Update `m2-sig-tests` for new `cast_vote_babylon_v2` signature | Low | Step 5 |
| 11 | Update CHI paper Named Limitation text | Low | Steps above |
| 12 | Update `GRANT.md` privacy claims to reflect M3 | Low | Steps above |

Total estimated dev time: 2–3 days for an experienced Noir developer.

---

## 11. Grant and paper positioning after M3

**Before M3:** "Coercion surface is narrowed at the receipt layer; L1 calldata
is a documented residual limitation."

**After M3:** "Coercion surface is closed at both the receipt layer (by PIUP
design) and the L1 calldata layer (by encrypted note storage). The residual
limitation is coordinator trust — the same trust model as any managed governance
service. Full receipt-freeness requires a re-encryption mix (M4)."

This is a materially stronger grant claim. It moves the system from
"documents the limitation" to "closes the limitation," which is the difference
between a research prototype and a deployable system.

The CHI paper framing benefits similarly: Study 1 validates the receipt design
(PIUP) as a coercion-resistance mechanism. M3 demonstrates that the system
honours the pattern's own invariants at the protocol layer, not just at the UX
layer. This closes a potential reviewer objection ("the protocol undermines the
UX guarantee").

---

_End of M3 implementation spec. See `docs/m2-tally-privacy-design-spike-2026-06-22.md`
for the architecture selection rationale. Proceed to implementation after Jony's M3 go-decision._
