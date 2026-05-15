# Testnet Deploy — Tasks

- [x] Contract compiles (nargo build in contracts/)
- [x] bridge-and-deploy.sh written
- [x] Fee juice bridged to L2 (L1 tx 0xaf16f6f...)
- [ ] Verify fee juice arrived on L2:
      aztec-wallet get-fee-juice-balance 0x065824b54ec4c5a14de7c38e7e47aa05da6604809bb4959664e737b3e42fe238 --node-url https://rpc.testnet.aztec-labs.com
- [ ] Deploy contract:
      export PATH="$HOME/.aztec/versions/4.3.0-nightly.20260430/bin:$PATH"
      export AZTEC_NODE_URL=https://rpc.testnet.aztec-labs.com
      aztec-wallet deploy contracts/target/private_voting-PrivateVoting.json --from accounts:deployer
- [ ] Save address to deployments/alpha-testnet.json
- [ ] Update GRANT.md with live contract address
- [ ] Update README deployment table
