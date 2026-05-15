# Umbra — Roadmap

## Now (blocked on Jony)
| Feature | Folder | Status | Blocker |
|---------|--------|--------|---------|
| Testnet deploy | changes/testnet-deploy | in_progress | Fee juice on L2 arriving (L1 tx landed 2026-05-15) |
| Grant application — Wave 3 | changes/grant-submission | ready | Deploy address needed |

## Next (after deploy)
| Feature | Folder | Status |
|---------|--------|--------|
| Grant submission to Aztec | changes/grant-submission | ready to send |
| Receipt UX — human-readable fingerprint | changes/receipt-ux | designed, not built |
| Demo video for grant | changes/grant-demo | todo |

## Done
| Feature | Date |
|---------|------|
| Noir contract (main.nr, eligibility.nr) | 2026-04-30 |
| Voter flow (APV-01–11) | 2026-04-30 |
| Facilitator flow (APV-12–18) | 2026-04-30 |
| Test suite (37 unit + contract + e2e) | 2026-04-30 |
| v4.3 nightly port | 2026-05-03 |
| GRANT.md written | 2026-05-04 |
| bridge-and-deploy.sh | 2026-05-04 |

## Key context
- Aztec Wave 3 grant: $25K target, deadline TBC
- Contract compiles cleanly on nargo v4.3.0-nightly.20260429
- Fee juice bridged to L2 on 2026-05-15, awaiting L2 inclusion
- L1 tx: 0xaf16f6f860ab9032c0c180db20e03d2b0925736a9ca4395b025c846d513000c3
