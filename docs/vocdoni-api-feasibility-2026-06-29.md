# Vocdoni API Feasibility Check: Study 3 Platform Partnership Option

**Date:** 2026-06-29  
**Tick:** 4245  
**Status:** Feasibility assessment — pre-decision  
**Author:** @jonybur  
**Connects to:** `piup-study3-power-analysis-2026-06-29.md` (Option C), `piup-study3-social-verification-2026-06-29.md`

---

## 1. Purpose

Study 3 as designed (concurrent with Study 2, n ≈ 40/condition) is underpowered for OR = 2.0 at any realistic verification baseline. The power analysis (tick-4244) identified three paths to an adequately powered replication. Option C — platform partnership — proposes running Study 3 on an existing deployed ZK/verifiable voting platform with a larger organic voter pool, without building the voter pool from scratch.

This document assesses Vocdoni (`app.vocdoni.io`) as a candidate for that platform partnership, focusing on:

1. Whether Vocdoni's API provides a publicly readable verification event log (equivalent to `verify_vote_counted()` in the PIUP Aztec design)
2. Whether the platform has sufficient voter scale for a powered Study 3 (n = 80–280/condition)
3. Whether a research partnership is technically and organisationally feasible

---

## 2. API capability assessment

### 2.1 Access model

All read operations on the Vocdoni API (`https://api.vocdoni.io/v2/`) are **publicly accessible without authentication**. This was confirmed by live API calls:

```bash
# Live as of 2026-06-29
curl -s "https://api.vocdoni.io/v2/chain/info"
# Returns: chainId, electionCount, voteCount, height etc.

curl -s "https://api.vocdoni.io/v2/elections?limit=1&status=RESULTS"
# Returns election list with voteCount per election
```

### 2.2 Available endpoints relevant to Study 3

| Endpoint | Returns | Relevant to Study 3? |
|---|---|---|
| `GET /elections/{id}/votes/count` | Integer vote count | Yes — total votes cast |
| `GET /votes?electionId={id}` | List of voteIDs + voterIDs | Partial — all cast votes |
| `GET /votes/verify/{electionId}/{voteId}` | 200 or 404 | Per-voter only |
| `GET /chain/info` | Global stats incl. total voteCount | Context only |

### 2.3 The verification event log — critical gap

**Finding: Vocdoni does NOT have a verification event log.**

The PIUP Study 3 social proof counter requires: *"X voters have already verified their vote in this election."* For this counter to exist, each voter's act of verification must be a **logged, countable event** — separate from, and subsequent to, casting a vote.

In the PIUP Aztec design, `verify_vote_counted()` is a ZK contract call that:
1. Verifies the voter's private receipt against the on-chain tally commitment
2. Emits a logged event on the Aztec contract
3. Makes the log count publicly readable (social proof counter)

In Vocdoni, the `/votes/verify/{electionId}/{voteId}` endpoint:
1. Accepts a nullifier (voteID)
2. Calls `VoteExists()` on the internal state
3. Returns HTTP 200 (found) or 404 (not found)
4. **Does not log the verification call** — it is a stateless read, not a transaction

From the source (vocdoni-node `api/vote.go`):
```go
func (a *API) verifyVoteHandler(...) error {
    if ok, err := a.vocapp.State.VoteExists(electionID, voteID, true); !ok || err != nil {
        return ErrVoteNotFound
    }
    return ctx.Send(nil, apirest.HTTPstatusOK)
}
```

There is no counter increment, no event emission, no database write. The `// TODO: use the indexer to verify that a vote exists?` comment in the source confirms this is a minimal implementation.

**Consequence:** The social proof counter for Study 3 (`X voters have already verified`) cannot be built using Vocdoni's current API. The vote count (`/elections/{id}/votes/count`) is available, but that measures *votes cast*, not *acts of verification* — a different construct.

### 2.4 What IS available from Vocdoni

| What | How | Study 3 usefulness |
|---|---|---|
| Total vote count (public) | `/elections/{id}/votes/count` | Proxy for participation, not verification |
| All voter nullifiers (public) | `/votes?electionId={id}` | Could support custom verification flow |
| Per-voter verification | `/votes/verify/{id}/{nullifier}` | Individual only; not logged |
| Election metadata | `/elections/{id}` | voteMode.anonymous, census.maxCensusSize |

---

## 3. Platform scale assessment

### 3.1 Observed stats (2026-06-29)

| Metric | Value |
|---|---|
| Total elections (all-time, since April 2024) | 2,525 |
| Total votes (all-time) | 134,308 |
| Organisations | 254 |
| Average votes per election | ≈ 53 |
| Largest election sampled | 30 votes |
| Chain launched | 2024-04-24 |

The platform is active and growing. However, at an average of ~53 votes/election, most elections are small. The Study 3 requirement is n = 80–280/condition (160–560 total). Finding single elections with 160–560 participants would require partnering with one of Vocdoni's larger organisational users.

### 3.2 Census size vs. actual voters

Vocdoni uses a census-based model: eligible voters are defined pre-election via `maxCensusSize`. The actual vote count is typically a fraction of the census (turnout varies). A census size of 1,000–2,000 would be needed to target n = 160/election at realistic turnout rates.

No sampled election showed a `maxCensusSize` consistent with that requirement in the current dataset. However, the dataset only covers elections returned in recent API pages — Vocdoni's larger community elections (e.g., Spanish cooperatives, crypto DAOs) may have substantially larger censuses. This requires direct contact with the Vocdoni team to verify.

### 3.3 Anonymous voting mode

Vocdoni supports both anonymous and non-anonymous elections (`voteMode.anonymous`). For Study 3:
- **Non-anonymous elections**: voterID (Ethereum address) is public — voter identity is weakly linkable. This creates privacy concerns for IRB and reduces ecological validity as a comparison to PIUP's ZK receipt design.
- **Anonymous elections**: ZK-based, no voterID disclosed — closer to PIUP design. Less information available publicly, consistent with the privacy properties being studied.

All sampled elections in the live API had `anonymous: false`. Anonymous Vocdoni elections do exist (they are built into the protocol) but are less common. A research partnership should target anonymous elections to match Study 3's ecological validity requirements.

---

## 4. Feasibility verdict

### 4.1 Native API (current, no partnership)

❌ **Not feasible** as a platform for Study 3 without code changes.
- No verification event log
- Cannot build the social proof counter
- Small election sizes

### 4.2 With platform partnership (medium effort)

🟡 **Potentially feasible** with Vocdoni team cooperation, but non-trivial.

Required from Vocdoni:
1. **Implement a verification counter endpoint** — a write endpoint (authenticated, voter-authenticated) that logs when a voter actively verifies. Analogous to `verify_vote_counted()`. This would require Vocdoni to add a small new feature to their node.
2. **Access to large anonymous elections** — partner with a Vocdoni organisation running elections with n > 300 eligible voters.
3. **IRB data-sharing agreement** — Vocdoni's voter data is semi-public; a formal agreement would be needed.

**Development effort estimate:** Adding a verification counter to vocdoni-node is 1–3 days of engineering work (small Go change, new state bucket, new endpoint). Vocdoni is open-source (Apache-2.0); the change could be submitted as a PR with research context.

### 4.3 Alternative: custom verification service (low partnership dependency)

Instead of modifying vocdoni-node, a lightweight external verification counter could be built:
- Voter clicks "verify my vote" in the study app → app submits a signed message to a study server
- Study server verifies the signature (confirming voter identity without exposing identity)
- Counter increments
- Counter is displayed as social proof

This decouples from Vocdoni's internal code but requires study-specific infrastructure. It is equivalent to PIUP's Aztec approach in effect, but hosted externally rather than on-chain. Trade-off: less ecological validity (trust in a central counter vs. ZK proof), but faster to implement.

---

## 5. Recommended next steps

### 5.1 Immediate (actionable without Jony)
- None — the feasibility check is complete. This document is the output.

### 5.2 For Jony (decision required)

**Action V1:** Decide on Study 3 powered replication path  
The Vocdoni native API is not directly usable. Three paths remain:

| Path | Effort | Timeline | Dependency |
|---|---|---|---|
| A — Pilot/feasibility at n=40/cond | Low | Q3 2026 | None (already decided) |
| B — Sequential elections over 12-18 months | Medium | 2027 | Study 2 completion |
| C1 — Vocdoni partnership + verification counter PR | High | Q1-Q2 2027 | Vocdoni team buy-in |
| C2 — Custom counter service on any platform | Medium | Q3-Q4 2026 | Dev time |

Recommended: keep A (pilot) as immediate path; hold C2 as the powered replication strategy for the registered report, pending Jony's decision on whether the infrastructure investment is worthwhile.

**If pursuing C1 (Vocdoni partnership):** Contact point is info@vocdoni.io or the Vocdoni Slack community. The pitch: academic research partnership, implement a small verification-counter feature (PR offered), in exchange for access to larger anonymous election census data for IRB-approved study. The feature benefits the broader platform (vote auditability UX).

---

## 6. Technical appendix

### 6.1 Vocdoni API endpoints tested

```bash
# All endpoints are unauthenticated GET
GET https://api.vocdoni.io/v2/chain/info
GET https://api.vocdoni.io/v2/elections?limit=N&status=RESULTS
GET https://api.vocdoni.io/v2/elections/{electionId}
GET https://api.vocdoni.io/v2/elections/{electionId}/votes/count
GET https://api.vocdoni.io/v2/votes?electionId={id}&limit=N
GET https://api.vocdoni.io/v2/votes/verify/{electionId}/{voteId}
GET https://api.vocdoni.io/v2/accounts?limit=N
```

### 6.2 Live API stats snapshot (2026-06-29)

```json
{
  "chainId": "vocdoni/LTS/1.2",
  "electionCount": 2525,
  "organizationCount": 254,
  "height": 7871397,
  "transactionCount": 155124,
  "voteCount": 134308,
  "genesisTime": "2024-04-24T09:00:00Z",
  "blockTime": [10230, 10292, 10302, 10383, 10397]
}
```

### 6.3 Source reference

Source: [vocdoni/vocdoni-node, `api/vote.go`](https://github.com/vocdoni/vocdoni-node/blob/main/api/vote.go)  
License: Apache-2.0  
The `verifyVoteHandler` is a stateless existence check with no event logging.

---

*Generated tick-4245 as Vocdoni API feasibility check for Study 3 option C platform partnership.*
