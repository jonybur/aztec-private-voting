import { useEffect, useState } from 'react';

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

/**
 * Controls the protective-framing explanation shown on the receipt.
 * Used in Study 2 of the PIUP user study (Factor E: Explanation × Label).
 *
 * - 'explained'   (E1) Full absent-choice explanation: "This is intentional.
 *                 Keeping your vote private means your receipt can be shared,
 *                 checked, or subpoenaed without revealing how you voted."
 *                 (design note §6.1).
 * - 'unexplained' (E2) Minimal statement only: "Your vote choice is not shown
 *                 on this receipt." — no design-intent signal.
 * - undefined     Production framing (current default; used in Study 1).
 */
export type ExplanationVariant = 'explained' | 'unexplained';

const LABEL_COPY: Record<ReceiptLabelVariant, { heading: string; noun: string }> = {
  'fingerprint':       { heading: 'Your vote fingerprint',  noun: 'fingerprint'       },
  'confirmation-code': { heading: 'Your confirmation code', noun: 'confirmation code'  },
  'nullifier':         { heading: 'Your nullifier',         noun: 'nullifier'         },
  'receipt-id':        { heading: 'Your receipt ID',        noun: 'receipt ID'        },
};

/**
 * Formats milliseconds remaining into a human-readable countdown string.
 * Used by TemporalDisclosure (Option D, Invariant 2 enforcement).
 *
 * Examples:
 *   5d 3h 12m  — days-dominant
 *   3h 12m     — hours-dominant
 *   12m 48s    — minutes-dominant
 *   48s        — seconds only (final minute)
 */
function formatTimeRemaining(ms: number): string {
  const totalSeconds = Math.max(0, Math.floor(ms / 1000));
  const days = Math.floor(totalSeconds / 86400);
  const hours = Math.floor((totalSeconds % 86400) / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (days > 0) return `${days}d ${hours}h ${minutes}m`;
  if (hours > 0) return `${hours}h ${minutes}m`;
  if (minutes > 0) return `${minutes}m ${seconds}s`;
  return `${seconds}s`;
}

/**
 * Option D: temporal disclosure countdown (Invariant 2).
 *
 * Shows a live countdown until the vote closes, then a "sharing is now safe"
 * message. Renders nothing when `voteCloseTimestamp` is undefined.
 *
 * The countdown provides a concrete temporal anchor — users can truthfully
 * say "sharing is not safe yet" and point to the UI — without a technical
 * lock (which would require enforcing the timestamp server-side). This is
 * the minimum viable implementation of social-deniability for vote-buyer
 * pressure scenarios (see spike: Option D rationale).
 *
 * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option D
 */
function TemporalDisclosure({
  voteCloseTimestamp,
  identifierNoun,
}: {
  voteCloseTimestamp: number | undefined;
  identifierNoun: string;
}): JSX.Element | null {
  const [remaining, setRemaining] = useState<number>(() =>
    voteCloseTimestamp != null ? voteCloseTimestamp - Date.now() : 0,
  );

  useEffect(() => {
    if (voteCloseTimestamp == null) return;
    const tick = (): void => setRemaining(voteCloseTimestamp - Date.now());
    tick();
    const id = window.setInterval(tick, 1000);
    return () => window.clearInterval(id);
  }, [voteCloseTimestamp]);

  if (voteCloseTimestamp == null) return null;

  if (remaining <= 0) {
    return (
      <p
        className="apv-receipt__temporal apv-receipt__temporal--safe"
        role="status"
        aria-live="polite"
      >
        Vote is closed — sharing your {identifierNoun} is now safe.
      </p>
    );
  }

  return (
    <p
      className="apv-receipt__temporal apv-receipt__temporal--pending"
      role="status"
      aria-live="off"
    >
      Sharing is safe in {formatTimeRemaining(remaining)} — after the vote closes.
    </p>
  );
}

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
  /**
   * Controls the protective-framing explanation copy (Study 2 Factor E).
   *
   * - 'explained'   (E1) Full explanation including design-intent rationale.
   * - 'unexplained' (E2) Minimal statement: no design-intent signal.
   * - undefined     Production framing (default; used in Study 1).
   */
  explanationVariant?: ExplanationVariant;
  /**
   * Unix-millisecond timestamp when the vote closes.
   * When provided, renders an Option D temporal disclosure countdown
   * (Invariant 2 enforcement) between the explainer paragraph and the
   * action buttons.
   *
   * - Pre-close: "Sharing is safe in Xd Yh Zm — after the vote closes."
   * - Post-close: "Vote is closed — sharing your [noun] is now safe."
   *
   * No technical lock is applied; the countdown is a copy-level salience
   * aid. Add Option B (UI lock) separately when the adversarial model warrants.
   *
   * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option D
   */
  voteCloseTimestamp?: number;
  /**
   * When true, the component operates in study-data-collection mode:
   *   - The Download button fires `onDownloadClick(true)` instead of
   *     triggering an actual file download. No file is written to disk.
   *   - The "How to verify" toggle fires `onVerifyExpanded(expanded)` on
   *     every state change so the host can log behavioural engagement.
   *   - `onDownload` is NOT called in study mode.
   * Defaults to false (production behaviour).
   */
  studyMode?: boolean;
  /**
   * Fires when the participant clicks Download in study mode.
   * Receives `true` on every click (one-shot behavioural signal).
   * Not called in production mode.
   */
  onDownloadClick?: (clicked: true) => void;
  /**
   * Fires whenever the verification section is expanded or collapsed
   * in study mode. Receives the new `expanded` state.
   * Not called in production mode.
   */
  onVerifyExpanded?: (expanded: boolean) => void;
}

/**
 * Returns the protective-framing explainer paragraph based on the
 * explanation variant and identifier noun.
 *
 * E1 ('explained'): Full absent-choice explanation (design note §6.1).
 * E2 ('unexplained'): Minimal factual statement — no design-intent signal.
 * undefined (production / Study 1): Current production framing.
 */
function ExplainerParagraph({
  explanationVariant,
  identifierNoun,
}: {
  explanationVariant: ExplanationVariant | undefined;
  identifierNoun: string;
}): JSX.Element {
  if (explanationVariant === 'explained') {
    // E1: Full explanation including design-intent rationale (design note §6.1).
    // "Your vote choice is not shown on this receipt. This is intentional.
    //  Keeping your vote private means your receipt can be shared, checked,
    //  or subpoenaed without revealing how you voted. Your [noun] is the
    //  only thing you need — matching it later proves your ballot was
    //  counted, nothing more."
    return (
      <p className="apv-receipt__explainer apv-receipt__explainer--explained">
        Your vote choice is not shown on this receipt. This is intentional.
        Keeping your vote private means your receipt can be shared, checked,
        or subpoenaed without revealing how you voted. Your {identifierNoun} is
        the only thing you need — matching it later proves your ballot was
        counted, nothing more.
      </p>
    );
  }

  if (explanationVariant === 'unexplained') {
    // E2: Minimal statement. No "This is intentional" signal, no rationale.
    // Tests whether the label alone (without explanation) supports
    // correct absent-choice inference.
    return (
      <p className="apv-receipt__explainer apv-receipt__explainer--unexplained">
        Your vote is private and verifiable.
      </p>
    );
  }

  // Production / Study 1 framing (current default).
  return (
    <p className="apv-receipt__explainer">
      Your vote choice is not shown on this receipt. This is intentional —
      this {identifierNoun} proves your ballot was counted without revealing
      what you voted for. Save it to verify after the vote closes, and keep
      it private until then.
    </p>
  );
}

export function VoteReceipt({
  receipt,
  onDownload,
  onVerify,
  verifierUrl,
  labelVariant = 'fingerprint',
  explanationVariant,
  voteCloseTimestamp,
  studyMode = false,
  onDownloadClick,
  onVerifyExpanded,
}: VoteReceiptProps): JSX.Element {
  const [showHowToVerify, setShowHowToVerify] = useState(false);
  const [copied, setCopied] = useState(false);

  const { heading: identifierHeading, noun: identifierNoun } = LABEL_COPY[labelVariant];

  const handleCopy = async (): Promise<void> => {
    await navigator.clipboard.writeText(receipt.receiptId);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1500);
  };

  const handleDownload = (): void => {
    if (studyMode) {
      // Study mode: log the click but do NOT write any file to disk.
      // `onDownload` is intentionally bypassed so the host study harness
      // captures the behavioural signal via `onDownloadClick`.
      onDownloadClick?.(true);
      return;
    }
    if (onDownload) {
      onDownload(receipt);
      return;
    }
    downloadReceipt(receipt);
  };

  const handleVerifyToggle = (): void => {
    const next = !showHowToVerify;
    setShowHowToVerify(next);
    if (studyMode) {
      // Study mode: fire expansion log on every toggle.
      onVerifyExpanded?.(next);
    }
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
            aria-label={`Copy ${identifierNoun}`}
          >
            {copied ? 'Copied' : 'Copy'}
          </button>
        </div>
      </div>

      <ExplainerParagraph
        explanationVariant={explanationVariant}
        identifierNoun={identifierNoun}
      />

      <TemporalDisclosure
        voteCloseTimestamp={voteCloseTimestamp}
        identifierNoun={identifierNoun}
      />

      <div className="apv-receipt__actions">
        <button type="button" className="apv-receipt__primary" onClick={handleDownload}>
          Download receipt
        </button>
        <button
          type="button"
          className="apv-receipt__secondary"
          onClick={handleVerifyToggle}
          aria-expanded={showHowToVerify}
        >
          {showHowToVerify ? 'Hide' : 'How to verify'}
        </button>
      </div>

      {showHowToVerify ? (
        <div className="apv-receipt__how-to" role="note">
          <p>
            After the vote closes, you can check that your {identifierNoun} appears
            in the set of counted votes. This proves your vote was included
            without revealing your choice.
          </p>
          <ol>
            <li>Save the receipt now (it&apos;s only stored on your device).</li>
            <li>When the vote closes, open the verifier.</li>
            <li>Paste your {identifierNoun}. The verifier will tell you whether it was counted.</li>
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
