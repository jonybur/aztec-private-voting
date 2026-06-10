# Umbra — Strategy Note (June 2026)

## Pivot: from ZK protocol to managed service layer

The PSE/Shutter *State of Private Voting 2026* report (co-authored by Privacy Stewards
of Ethereum and Shutter Network, January 2026) evaluated 12 private voting protocols
against 26 properties. Key finding: **the cryptographic problems are largely solved.
The unsolved problems are product and distribution.**

Specifically, the report identifies as future work:
- "Better developer experience — plug-and-play modules for DAO tooling" (Point 4)
- "Demand generation — DAOs are not yet asking for privacy" (Point 6)

Umbra's pivot responds directly to these findings.

## What Umbra is now

**A managed service and UX layer** that makes private DAO governance votes
accessible to facilitators with no cryptographic background.

Protocol-agnostic: the cryptographic backend can be MACI V3, Shutter Permanent
Shielded Voting, DAVINCI (Vocdoni), or Aztec, depending on the DAO's requirements.
Umbra provides:

1. **The facilitator flow** — six-step vote configuration, no ZK knowledge required
2. **The voter flow** — browser-side proof generation, plain-language eligibility check
3. **The receipt** — a vote fingerprint that communicates proof-of-inclusion in plain
   language; receipt-free by design (proves the vote was counted, never the choice).
   Coercion resistance is explicitly out of scope — key sale and forced abstention
   are unaddressable with token-based pseudonymous eligibility (MACI positioning)
4. **Operations** — Umbra runs the vote as a managed service; DAOs don't operate
   cryptographic infrastructure

## What Umbra is not

Not a new cryptographic protocol. The PSE report lists Aragon/Aztec as a
low-maturity research prototype; building a better ZK voting contract is not the
gap. The gap is the product layer that makes existing protocols usable.

## The Aztec technical work

The Noir contracts and React components built for the Aztec implementation remain
the canonical implementation and the basis for the Aztec Wave 3 grant application.
Aztec is one of the supported backends; it is not the only one.

The receipt design — documented in docs/receipt-design.md — is the research
contribution that is protocol-independent and the actual differentiator.

## Competitive position

From the PSE report:
- MACI V3: strongest coercion resistance, but a library — no product, no UX
- Shutter: 850+ DAOs in production, but threshold encryption (no ZK), votes revealed post-close
- DAVINCI: strongest overall protocol, approaching mainnet, no facilitator tooling
- Enclave: strong cryptography, no facilitator UX
- Aragon/Aztec: research prototype (same category as pre-pivot Umbra)

Caveat (verified against the report and project sites, June 2026): Snapshot+Shutter
is already a toggle-managed service (temporary privacy — votes revealed post-close),
Vocdoni operates a voting SaaS (app.vocdoni.io, aimed at off-chain organisations),
and Privote offers hosted MACI. The defensible gap is narrower: a managed service
for permanent-anonymity onchain DAO governance with facilitator and receipt UX.
That is the gap Umbra now addresses.

## First customer target

Mid-size DAO ($10M–$500M treasury) with a contested governance vote — delegate
elections, treasury allocations, contributor compensation. These are the votes where
public ballots cause social damage. Initial delivery: concierge service, Umbra
configures and operates the vote, DAO gets the result with a verification artifact.
