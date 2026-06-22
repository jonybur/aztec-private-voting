import { useCallback, useState } from 'react';

import { useAztecClient } from '../aztec/context';
import { translateVoteError } from '../aztec/errors';
import { fingerprintFromReceiptId, generateReceiptId } from '../aztec/receipt-id';
import { loadVotingContractV2 } from '../aztec/voting';
import type { M2SigningOutput } from './useM2Signing';
import type { VoteConfig, VoteReceipt } from '../types';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Merkle eligibility inputs for cast_vote_babylon_v2.
 * These come from the snapshot API (/api/eligibility?address=...) and match
 * the M2 merkle tree built with synthetic-snapshot.ts --version 2.
 */
export interface BabylonV2EligibilityInputs {
  /** Holder balance in ubbn at snapshot block. */
  balance: bigint;
  /** Sibling hashes from leaf to root. Length must equal tree depth (20). */
  merkle_path: number[][];
  /** Direction bits, same length as merkle_path. */
  merkle_indices: boolean[];
}

export interface CastVoteBabylonV2Input {
  /** Vote option index (0-based). */
  choice: number;
  /** Merkle membership and balance witnesses. */
  eligibility: BabylonV2EligibilityInputs;
  /**
   * Ownership proof from useM2Signing (EIP-191 mode).
   * Provides pubkey_x, pubkey_y, sig_r, sig_s.
   * sig_r and sig_s are combined into sig[64] = r||s for the circuit.
   */
  m2Signing: M2SigningOutput;
}

export type VoteBabylonV2Status = 'idle' | 'submitting' | 'cast' | 'error';

export interface UseVoteBabylonV2Result {
  castVote: (input: CastVoteBabylonV2Input) => Promise<VoteReceipt | null>;
  status: VoteBabylonV2Status;
  error: string | null;
  receipt: VoteReceipt | null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hook
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Cast a private ballot using the M2 in-circuit secp256k1 ownership proof.
 *
 * This is the Babylon-v2 voting path. It calls `cast_vote_babylon_v2` on the
 * deployed PrivateVoting contract, which verifies:
 *   1. An EIP-191 secp256k1 signature proving key ownership.
 *   2. Merkle membership in the SHA-256d snapshot tree (version 2).
 *
 * Caller flow:
 *   1. useM2Signing.sign({ mode: 'eip191', titleHash, merkleRootField }) → M2SigningOutput
 *   2. Fetch Merkle path from /api/eligibility?address=<evmAddress>
 *   3. useVoteBabylonV2(config).castVote({ choice, eligibility, m2Signing })
 *
 * Gate cost estimate: ~100k (secp256k1 ECDSA) + ~5k (keccak256 EIP-191) + Merkle.
 * Proof time: 2–4s on M2 hardware; 8–15s on budget laptop; acceptable for governance.
 *
 * IMPORTANT: The contract must have been deployed with eligibilityMode='babylon-v2'
 * (which maps to circuit mode TOKEN=1 with the M2 Merkle root in token_address).
 * See scripts/deploy-testnet.ts and scripts/deploy.config.json.
 */
export function useVoteBabylonV2(config: VoteConfig): UseVoteBabylonV2Result {
  const client = useAztecClient();
  const [status, setStatus] = useState<VoteBabylonV2Status>('idle');
  const [error, setError] = useState<string | null>(null);
  const [receipt, setReceipt] = useState<VoteReceipt | null>(null);

  const castVote = useCallback(
    async (input: CastVoteBabylonV2Input): Promise<VoteReceipt | null> => {
      setStatus('submitting');
      setError(null);

      try {
        const contract = await loadVotingContractV2(client.wallet, config.contractAddress);

        const receiptId = await generateReceiptId();

        // Combine sig_r (32 bytes) + sig_s (32 bytes) → sig[64] as the circuit expects.
        const sig: number[] = [...input.m2Signing.sig_r, ...input.m2Signing.sig_s];
        if (sig.length !== 64) {
          throw new Error(
            `sig must be 64 bytes (r||s); got ${sig.length}. Check M2SigningOutput.`,
          );
        }

        // Validate merkle path depth (circuit requires exactly 20 levels).
        if (input.eligibility.merkle_path.length !== 20) {
          throw new Error(
            `merkle_path must have exactly 20 levels; got ${input.eligibility.merkle_path.length}`,
          );
        }
        if (input.eligibility.merkle_indices.length !== 20) {
          throw new Error(
            `merkle_indices must have exactly 20 entries; got ${input.eligibility.merkle_indices.length}`,
          );
        }

        const tx = await contract.methods
          .cast_vote_babylon_v2(
            input.choice,
            input.eligibility.balance,
            input.eligibility.merkle_path,
            input.eligibility.merkle_indices,
            input.m2Signing.pubkey_x,
            input.m2Signing.pubkey_y,
            sig,
            receiptId,
          )
          .send()
          .wait();

        const next: VoteReceipt = {
          voteId: config.voteId,
          voteTitle: config.title,
          receiptId: fingerprintFromReceiptId(receiptId),
          txHash: tx.txHash.toString(),
          timestamp: Date.now(),
          contractAddress: config.contractAddress,
        };

        setReceipt(next);
        setStatus('cast');
        return next;
      } catch (err) {
        const raw = err instanceof Error ? err.message : 'Babylon V2 vote submission failed';
        setError(translateVoteError(raw));
        setStatus('error');
        return null;
      }
    },
    [client, config],
  );

  return { castVote, status, error, receipt };
}
