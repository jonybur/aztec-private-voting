import { useCallback, useState } from 'react';

import { useAztecClient } from '../aztec/context';
import { translateVoteError } from '../aztec/errors';
import { fingerprintFromReceiptId, generateReceiptId } from '../aztec/receipt-id';
import { loadVotingContract } from '../aztec/voting';
import type { EligibilityProof, VoteConfig, VoteReceipt } from '../types';

export type VoteStatus = 'idle' | 'submitting' | 'cast' | 'error';

export interface CastVoteInput {
  choice: number;
  eligibilityProof: EligibilityProof;
}

export interface UseVoteResult {
  castVote: (input: CastVoteInput) => Promise<VoteReceipt | null>;
  status: VoteStatus;
  error: string | null;
  receipt: VoteReceipt | null;
}

export function useVote(config: VoteConfig): UseVoteResult {
  const client = useAztecClient();
  const [status, setStatus] = useState<VoteStatus>('idle');
  const [error, setError] = useState<string | null>(null);
  const [receipt, setReceipt] = useState<VoteReceipt | null>(null);

  const castVote = useCallback(
    async (input: CastVoteInput): Promise<VoteReceipt | null> => {
      setStatus('submitting');
      setError(null);
      try {
        const contract = await loadVotingContract(client.wallet, config.contractAddress);

        const receiptId = await generateReceiptId();

        const eligibilityField = BigInt(input.eligibilityProof.proof);

        const tx = await contract.methods
          .cast_vote(input.choice, eligibilityField, receiptId)
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
        const raw = err instanceof Error ? err.message : 'Vote submission failed';
        setError(translateVoteError(raw));
        setStatus('error');
        return null;
      }
    },
    [client, config],
  );

  return { castVote, status, error, receipt };
}
