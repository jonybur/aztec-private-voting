# Study 3 — Verification Counter Architecture Clarification

**Date:** 2026-07-02 (tick-4452)  
**Author:** OpenClaw Agent  
**Reviewer:** Jony Bursztyn (required before Study 3 deployment)  
**Connects to:** `packages/react/src/components/VoteReceipt.tsx`, `docs/piup-study3-social-verification-2026-06-29.md §3`, `docs/piup-study3-osf-prereg-2026-07-01.md §3.2`

---

## Summary

The JSDoc comment in `VoteReceipt.tsx` (line ~262) states that `socialProofCount` is
"polled from on-chain `verify_vote_counted()` call logs approximately every 15 minutes."

**This is architecturally incorrect.** `verify_vote_counted()` is declared `#[view]` in
`contracts/src/main.nr` — it is a read-only simulation with no transaction and no L1
event emission. View calls leave no on-chain record. There is no Aztec mechanism to
retrieve a historical count of how many times a view function was called.

This memo corrects the architecture, specifies the correct implementation path, and
flags the Study 3 pre-registration language that needs a parallel clarification before
OSF filing.

---

## 1. Why view functions cannot be counted on-chain

In Aztec (and in EVM), a `view` function:
- Executes locally (simulated by the caller's node, not broadcast to validators)
- Does NOT create a transaction hash
- Does NOT emit L1 events
- Does NOT write to contract storage
- Leaves no on-chain record that can be queried later

The Aztec PXE logs view calls locally, but these logs are not persisted on-chain and
are not accessible to other parties.

**Consequence:** The Study 3 social proof counter — "X voters have already verified
their receipt in this election" — cannot be sourced from on-chain data. Any count of
`verify_vote_counted()` calls must be tracked at the **application (host) layer**.

---

## 2. Correct architecture for Study 3

### 2.1 Host-side verification logging

The Study 3 deployment requires a host backend. When a participant visits the
verification page and calls `verify_vote_counted(receipt_id)`:

1. The host's frontend (served from Vercel or equivalent) calls a **host API endpoint**
   before or alongside the Aztec simulation:

   ```
   POST /api/verify  { receipt_id: "0x..." }
   ```

2. The host backend:
   a. Calls `verify_vote_counted(receipt_id)` on the Aztec node (view simulation)
   b. Logs the verification event in the host's database (timestamp, outcome,
      **no wallet address or vote choice** — aggregate only)
   c. Returns `{ counted: true/false, verificationCount: N }` to the frontend

3. The frontend renders the `SocialProofBanner` with the returned `verificationCount`.

### 2.2 What the host logs

The host stores, per election:
```json
{
  "electionId": "...",
  "verificationTimestamps": [1751420400, 1751421200, ...],
  "verificationCount": 7
}
```

**Privacy constraint:** The host must NOT log `receipt_id` values. Logging
`receipt_id` values would allow the host to correlate the verification attempt with
the ballot submission (which also uses `receipt_id`), partially de-anonymising the
voter. Only the aggregate count and timestamps are stored.

### 2.3 The 15-minute polling interval

The pre-reg §3.2 states "the social proof counter is updated approximately every 15
minutes." This is correct: the `SocialProofBanner` prop (`socialProofCount`) is
populated from a host-side API response that the host caches and refreshes every 15
minutes. The counter is not "live" per-call — it is the cached count from the most
recent 15-minute window. This avoids N+1 database hits on every receipt page load and
means participants in the same 15-minute window see the same count.

### 2.4 Alternative: on-chain event from a separate function

If a fully on-chain counter is required, the Noir contract would need a new function:

```noir
#[external("public")]
fn log_verification_call(receipt_id: Field) {
    // Reads the receipts map (no state change)
    // Emits an Aztec event (counted externally)
    let counted = self.storage.receipts.at(receipt_id).read();
    // Emit event: (receipt_id is NOT included in the event to preserve privacy)
    emit VerificationLogged { timestamp: context.timestamp() };
}
```

**This approach is NOT recommended for Study 3** because:
1. It requires a state-changing transaction for what should be a read operation
2. It costs gas on each verification call (friction for participants)
3. It changes the user experience (transaction confirmation UX)
4. It is unnecessary — host-side logging is architecturally simpler and sufficient
5. The event log on Aztec's current testnet is queryable but the tooling is nascent

**Recommendation: use host-side application logging (§2.1).**

---

## 3. Pre-registration language to clarify

`docs/piup-study3-osf-prereg-2026-07-01.md §3.2` (social proof counter spec) contains:

> "The counter draws from the contract's public `verify_vote_counted()` call logs,
> updated every 15 minutes."

This language implies on-chain sourcing. Before OSF filing, this should be amended to:

> "The counter is maintained by the study host server. When a participant calls
> `verify_vote_counted()`, the host backend logs the aggregate verification event
> (no wallet address or receipt ID retained in logs — aggregate count only) and
> refreshes the counter approximately every 15 minutes. The count is sourced from
> the host's log, not from on-chain data, because `verify_vote_counted()` is a
> view function that leaves no on-chain trace."

**Filing priority:** This is a pre-data clarification with no hypothesis change. It
should be incorporated before OSF filing as part of the DV3 amendment package (see
`docs/piup-study3-dv3-specification-2026-07-02.md §4`), or filed as a separate
amendment if the DV3 amendment is filed first.

---

## 4. Code fix required in VoteReceipt.tsx

The JSDoc comment at line ~262 of `packages/react/src/components/VoteReceipt.tsx`:

```
// CURRENT (incorrect):
polled from on-chain `verify_vote_counted()` call logs approximately every 15 minutes.

// CORRECT:
tracked by the host server (aggregated verification event log; no receipt IDs stored;
no on-chain trace — verify_vote_counted() is a view function). Updated approximately
every 15 minutes and passed as a prop.
```

This is a documentation-only fix. No behaviour change. Apply in the same commit as
this memo.

---

## 5. Impact on Study 3 deployment plan

Study 3 requires the following host-side infrastructure:

| Component | Requirement | Notes |
|-----------|-------------|-------|
| Host server | API endpoint `POST /api/verify` | Calls Aztec node + logs count |
| Database | Verification event log (timestamp, outcome — NO receipt_id) | Aggregate count only |
| Cache | 15-minute refresh of verification count | Served to `socialProofCount` prop |
| Privacy review | Confirm NO receipt_id stored in logs | Must be confirmed before launch |

This is lightweight infrastructure — a Vercel serverless function + Redis cache (or
even a plain KV store) is sufficient. The host backend does not need persistent
storage beyond the election window.

---

## 6. Summary of actions

| # | Action | Owner | When |
|---|--------|-------|------|
| 1 | Fix JSDoc in `VoteReceipt.tsx` (§4) | Agent | This tick (tick-4452) |
| 2 | Amend pre-reg §3.2 language (§3) | Jony | Before OSF filing |
| 3 | Implement host API endpoint (`POST /api/verify`) | Jony | Before Study 3 deployment |
| 4 | Privacy review: confirm no receipt_id in logs | Jony | Before Study 3 launch |

**Current blocker:** None for tick-4452 work (JSDoc fix). Study 3 deployment is gated
on OSF filing and IRB approval regardless, so Action 2 can be bundled with the DV3
amendment.
