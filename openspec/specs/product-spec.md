# Umbra — Product Specification

## What it is
Private ballot infrastructure for DAOs. Members vote privately on-chain using
Aztec's zero-knowledge proofs. Only the final tally is revealed. No one can
see how any individual voted.

## The research contribution
The receipt UX — designing for "trust without transparency."

Current problem: after voting privately, voters have no way to verify their vote
was counted without revealing how they voted. Every existing system either:
- Reveals the vote (breaks privacy)
- Provides a hex nullifier (incomprehensible to non-technical users)

Umbra's approach: a "vote fingerprint" — a human-readable representation of the
cryptographic nullifier. Inspired by PGP fingerprints. Grounded in HCI research
(Benaloh/Tuinstra receipt-freeness 1994, Helios usability 2008, Amershi CHI 2019).

## Technical stack
- Smart contract: Aztec Noir (v4.3.0-nightly.20260429)
- Frontend: React component library (4 components)
- Demo: Next.js app
- Tests: Vitest unit + Nargo contract tests + Playwright e2e

## Target users
- DAO operators (facilitators) — deploy and manage votes
- DAO members (voters) — cast private votes and verify they were counted

## Competitive landscape
- MACI (Ethereum Foundation): strongest cryptography, no product layer, too complex
- Shutter Network: 881 DAOs, simple UX, but not truly receipt-free
- Aztec/NounsDAO experiment: proof of concept, not production

The gap: polished, DAO-usable private voting with a receipt UX that non-technical
voters can actually trust.
