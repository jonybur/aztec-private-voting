import { useState } from 'react';

import { shortenHex, formatTimestamp } from '../format';
import { downloadReceipt } from '../receipt';
import type { VoteReceipt as VoteReceiptData } from '../types';

/**
 * Controls which label is shown for the receipt identifier.
 * Used in Study 1 of the PIUP user study (RQ1: label comprehension).
 *
 * - 'fingerprint'       Current implementation — "vote fingerprint"
 * - 'confirmation-code' eCommerce convention — "confirmation code"
 * - 'nullifier'         Cryptographic term — "nullifier"
 * - 'receipt-id'        Neutral control — "receipt ID"
 */
export type ReceiptLabelVariant = 'fingerprint' | 'confirmation-code' | 'nullifier' | 'receipt-id';

const LABEL_COPY: Record<ReceiptLabelVariant, { heading: string; noun: string }> = {
  'fingerprint':       { heading: 'Your vote fingerprint',  noun: 'fingerprint'       },
  'confirmation-code': { heading: 'Your confirmation code', noun: 'confirmation code'  },
  'nullifier':         { heading: 'Your nullifier',         noun: 'nullifier'         },
  'receipt-id':        { heading: 'Your receipt ID',        noun: 'receipt ID'        },
};

export interface VoteReceiptProps {
  receipt: VoteReceiptData;
  onDownload?: (receipt: VoteReceiptData) => void;
  onVerify?: (receipt: VoteReceiptData) => void;
  verifierUrl?: string;
  /**
   * Which label variant to display for the receipt identifier.
   * Defaults to 'fingerprint' (production behaviour).
   * Set a different variant when rendering Study 1 stimuli.
   */
  labelVariant?: ReceiptLabelVariant;
}

export function VoteReceipt({
  receipt,
  onDownload,
  onVerify,
  verifierUrl,
}: VoteReceiptProps): JSX.Element {
  const [showHowToVerify, setShowHowToVerify] = useState(false);
  const [copied, setCopied] = useState(false);

  const { heading: identifierHeading, noun: identifierNoun } =
    LABEL_COPY[labelVariant ?? 'fingerprint'];

  const handleCopy = async (): Promise<void> => {
    await navigator.clipboard.writeText(receipt.receiptId);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1500);
  };

  const handleDownload = (): void => {
    if (onDownload) {
      onDownload(receipt);
      return;
    }
    downloadReceipt(receipt);
  };

  const handleVerify = (): void => {
    if (onVerify) {
      onVerify(receipt);
      return;
    }
    if (verifierUrl) {
      window.open(verifierUrl, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <div className="apv-receipt" role="region" aria-label="Vote receipt">
      <div className="apv-receipt__header">
        <span className="apv-receipt__check" aria-hidden="true">
          ✓
        </span>
        <h2 className="apv-receipt__title">Your vote was cast</h2>
      </div>

      <dl className="apv-receipt__meta">
        <div>
          <dt>Vote</dt>
          <dd>{receipt.voteTitle}</dd>
        </div>
        <div>
          <dt>Time</dt>
          <dd>{formatTimestamp(receipt.timestamp)}</dd>
        </div>
      </dl>

      <div className="apv-receipt__fingerprint">
        <label htmlFor="apv-fingerprint">{identifierHeading}</label>
        <div className="apv-receipt__fingerprint-row">
          <code id="apv-fingerprint" className="apv-receipt__fingerprint-value">
            {shortenHex(receipt.receiptId, 6, 4)}
          </code>
          <button
            type="button"
            className="apv-receipt__copy"
            onClick={handleCopy}
            aria-label="Copy vote fingerprint"
          >
            {copied ? 'Copied' : 'Copy'}
          </button>
        </div>
      </div>

      <p className="apv-receipt__explainer">
        This {identifierNoun} proves your vote was counted without revealing how
        you voted. Save it to verify after the vote closes, and keep it private
        — treat it like a ballot stub, not something to share.
      </p>

      <div className="apv-receipt__actions">
        <button type="button" className="apv-receipt__primary" onClick={handleDownload}>
          Download receipt
        </button>
        <button
          type="button"
          className="apv-receipt__secondary"
          onClick={() => setShowHowToVerify((v) => !v)}
          aria-expanded={showHowToVerify}
        >
          {showHowToVerify ? 'Hide' : 'How to verify'}
        </button>
      </div>

      {showHowToVerify ? (
        <div className="apv-receipt__how-to" role="note">
          <p>
            After the vote closes, you can check that your fingerprint appears
            in the set of counted votes. This proves your vote was included
            without revealing your choice.
          </p>
          <ol>
            <li>Save the receipt now (it&apos;s only stored on your device).</li>
            <li>When the vote closes, open the verifier.</li>
            <li>Paste your fingerprint. The verifier will tell you whether it was counted.</li>
          </ol>
          {verifierUrl ? (
            <button type="button" className="apv-receipt__link" onClick={handleVerify}>
              Open verifier
            </button>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
