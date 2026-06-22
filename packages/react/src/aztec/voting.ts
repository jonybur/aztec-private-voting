import type { AccountWalletWithSecretKey } from '@aztec/aztec.js';

import type { VoteConfig } from '../types';

interface ContractMethod {
  send: () => { wait: () => Promise<{ txHash: { toString: () => string } }> };
  simulate: () => Promise<unknown>;
}

export interface VotingContract {
  methods: {
    cast_vote: (
      choice: number,
      eligibilityProof: bigint,
      receiptId: bigint,
    ) => ContractMethod;
    finalize_vote: () => ContractMethod;
    verify_vote_counted: (receiptId: bigint) => ContractMethod;
    get_vote_count: () => ContractMethod;
    get_final_tally: (optionIndex: number) => ContractMethod;
    is_finalized: () => ContractMethod;
  };
}

/**
 * M2 contract interface — adds cast_vote_babylon_v2.
 *
 * cast_vote_babylon_v2 takes:
 *   vote_choice    : u8          — 0-based option index
 *   balance        : u64         — holder balance in ubbn
 *   merkle_path    : [[u8;32];20] — sibling hashes leaf-to-root
 *   merkle_indices : [bool;20]   — direction bits
 *   pubkey_x       : [u8;32]     — secp256k1 public key x-coordinate
 *   pubkey_y       : [u8;32]     — secp256k1 public key y-coordinate
 *   sig            : [u8;64]     — ECDSA r||s (EIP-191, low-S normalised)
 *   receipt_id     : Field       — client-generated unique ballot ID
 *
 * See contracts/src/main.nr §cast_vote_babylon_v2 and
 * docs/m2-secp256k1-ownership-proof-design.md for the full circuit spec.
 */
export interface VotingContractV2 extends VotingContract {
  methods: VotingContract['methods'] & {
    cast_vote_babylon_v2: (
      choice: number,
      balance: bigint,
      merkle_path: number[][],
      merkle_indices: boolean[],
      pubkey_x: number[],
      pubkey_y: number[],
      sig: number[],
      receiptId: bigint,
    ) => ContractMethod;
  };
}

export async function loadVotingContract(
  wallet: AccountWalletWithSecretKey,
  contractAddress: string,
): Promise<VotingContract> {
  const { Contract: AztecContract, AztecAddress: AztecAddressCtor } = await import(
    '@aztec/aztec.js'
  );
  const { PrivateVotingContractArtifact } = await import('./artifact');
  const contract = await AztecContract.at(
    AztecAddressCtor.fromString(contractAddress),
    PrivateVotingContractArtifact,
    wallet,
  );
  return contract as unknown as VotingContract;
}

/**
 * Load the PrivateVoting contract with the M2 (cast_vote_babylon_v2) interface.
 *
 * Uses the same artifact as loadVotingContract — the compiled JSON includes all
 * entrypoints. The V2 interface is cast on top to expose cast_vote_babylon_v2.
 */
export async function loadVotingContractV2(
  wallet: AccountWalletWithSecretKey,
  contractAddress: string,
): Promise<VotingContractV2> {
  const contract = await loadVotingContract(wallet, contractAddress);
  return contract as unknown as VotingContractV2;
}

export function eligibilityModeToCode(mode: VoteConfig['eligibilityMode']): number {
  switch (mode) {
    case 'open':
      return 0;
    case 'token':
      return 1;
    case 'allowlist':
      return 2;
    case 'babylon-v2':
      // babylon-v2 deploys with TOKEN mode (1) in the circuit; the M2 Merkle root
      // is encoded in the token_address slot. Voters use cast_vote_babylon_v2().
      return 1;
  }
}
