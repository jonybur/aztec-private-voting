# Proposal: Testnet Deploy

## Why
A live contract address makes the grant application credible. Currently Umbra compiles
and has full test coverage but has never been deployed to a public network.

## What
Deploy PrivateVoting contract to Aztec testnet (alpha-testnet).
Record address in deployments/alpha-testnet.json.
Update GRANT.md and README with live address.

## Status
- L1 fee juice bridged: 2026-05-15, tx 0xaf16f6f860ab9032c0c180db20e03d2b0925736a9ca4395b025c846d513000c3
- Waiting for L2 inclusion (can take 15-30 min on testnet)
- Once fee juice arrives: run aztec-wallet deploy

## Success criteria
- Contract deployed, address in deployments/alpha-testnet.json
- GRANT.md updated with live address
- README deployment table updated
