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

/**
 * Controls the temporal download-lock behaviour (Option B, Invariant 2).
 *
 * - 'lock'    (Option B) Download and copy are disabled until the vote closes.
 *             A padlock icon is shown; button reads "Locked until vote closes".
 *             Used to generate Study 4 stimuli (UI-lock × coercion-pressure).
 * - 'count'   (Option D) Countdown is shown but no technical barrier is applied.
 *             Default when `voteCloseTimestamp` is set.
 * - undefined No temporal enforcement (production default; no `voteCloseTimestamp`).
 *
 * Ref: docs/piup-study4-temporal-coercion-vignette-2026-07-01.md §3.1
 * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option B
 */
export type TemporalLockVariant = 'lock' | 'count';

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
 * Shared countdown state hook — used by TemporalDisclosure and the
 * Option B lock to keep both in sync from a single interval.
 */
function useTimeRemaining(voteCloseTimestamp: number | undefined): number {
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

  return remaining;
}

/**
 * Pre-registered social proof counter floor (Study 3, OSF pre-reg §3.2).
 * Counter activates only when verifiedCount >= floor to avoid negative
 * social proof at low counts (Cialdini, 1984). Do NOT change without
 * filing an OSF amendment before data collection begins.
 */
const SOCIAL_PROOF_FLOOR = 5;

/**
 * Study 3: Social proof verification counter banner.
 *
 * Treatment condition receipt displays a count of voters who have already
 * verified their receipt. The counter activates only when count >= floor
 * (pre-registered at 5 per OSF §3.2) to avoid negative social proof at
 * low verification counts ("0 voters have verified" demotivates).
 *
 * When count >= floor:
 *   "N voters have already verified their vote in this election.
 *    Verification is open until [date]."
 * When count < floor:
 *   "Verification is open until [date]." (no count displayed)
 *
 * Renders nothing when `socialProofCount` is undefined (control condition).
 *
 * Ref: docs/piup-study3-social-verification-2026-06-29.md §3 (floor §M1)
 * Ref: docs/piup-study3-osf-prereg-2026-07-01.md §3.2
 */
function SocialProofBanner({
  count,
  floor,
  voteCloseTimestamp,
}: {
  count: number;
  floor: number;
  voteCloseTimestamp: number | undefined;
}): JSX.Element {
  const closingText =
    voteCloseTimestamp != null
      ? `Verification is open until ${new Date(voteCloseTimestamp).toLocaleDateString(undefined, { month: 'long', day: 'numeric' })}.`
      : 'Verification is open.';

  return (
    <p
      className="apv-receipt__social-proof"
      role="status"
      aria-live="polite"
      data-testid="social-proof-banner"
    >
      {count >= floor ? (
        <>
          <span className="apv-receipt__social-proof-count">
            {count} {count === 1 ? 'voter has' : 'voters have'} already verified their vote in
            this election.
          </span>{' '}
          {closingText}
        </>
      ) : (
        closingText
      )}
    </p>
  );
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
  remaining,
}: {
  voteCloseTimestamp: number | undefined;
  identifierNoun: string;
  remaining: number;
}): JSX.Element | null {
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
   * When provided, renders a temporal disclosure countdown (Invariant 2).
   *
   * Behaviour depends on `temporalLock`:
   *
   * - `temporalLock` undefined or 'count' (Option D): countdown shown;
   *   no technical barrier applied. Pre-close copy: "Sharing is safe in
   *   Xd Yh Zm — after the vote closes." Post-close: "Vote is closed —
   *   sharing your [noun] is now safe."
   *
   * - `temporalLock='lock'` (Option B): countdown shown AND download/copy
   *   buttons are disabled until the vote closes. Post-close: buttons
   *   re-enable normally.
   *
   * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option D §Option B
   */
  voteCloseTimestamp?: number;
  /**
   * Controls whether a technical download/copy barrier is enforced
   * (Option B) or only a salient countdown is shown (Option D, default).
   *
   * - 'lock'  (Option B) Download button is disabled with a padlock icon
   *           until `voteCloseTimestamp` is reached. Generates the
   *           structural-excuse condition in Study 4.
   * - 'count' (Option D, default) Countdown shown; no technical barrier.
   *
   * Has no effect when `voteCloseTimestamp` is undefined.
   *
   * Ref: docs/piup-study4-temporal-coercion-vignette-2026-07-01.md §3.1
   */
  temporalLock?: TemporalLockVariant;
  /**
   * Study 3 social proof counter — number of voters who have already
   * verified their receipt in this election. Provided by the host server
   * (application-layer log; NOT on-chain — verify_vote_counted() is a view
   * function that leaves no on-chain trace). The host backend logs aggregate
   * verification events (no receipt_id stored), caches the count, and
   * refreshes approximately every 15 minutes.
   *
   * When set, renders the SocialProofBanner (treatment condition).
   * When undefined (default), no social proof banner is shown (control).
   *
   * The count is only displayed when `socialProofCount >= socialProofFloor`
   * (default 5) to avoid negative social proof at low counts.
   *
   * Architecture: docs/study3-verification-counter-architecture-2026-07-02.md
   * Ref: docs/piup-study3-social-verification-2026-06-29.md §3
   * Ref: docs/piup-study3-osf-prereg-2026-07-01.md §3.2
   */
  socialProofCount?: number;
  /**
   * Pre-registered floor for the social proof counter (Study 3 OSF §3.2).
   * The count text is shown only when `socialProofCount >= socialProofFloor`.
   * Below the floor the banner shows "Verification is open [until date]."
   * with no count, avoiding negative social proof from low numbers.
   *
   * Defaults to 5 (pre-registered). Do NOT change after OSF filing without
   * a new amendment.
   */
  socialProofFloor?: number;
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
  temporalLock,
  socialProofCount,
  socialProofFloor = SOCIAL_PROOF_FLOOR,
  studyMode = false,
  onDownloadClick,
  onVerifyExpanded,
}: VoteReceiptProps): JSX.Element {
  const [showHowToVerify, setShowHowToVerify] = useState(false);
  const [copied, setCopied] = useState(false);

  const { heading: identifierHeading, noun: identifierNoun } = LABEL_COPY[labelVariant];

  // Shared countdown for both TemporalDisclosure and Option B lock.
  const remaining = useTimeRemaining(voteCloseTimestamp);
  const isLocked = temporalLock === 'lock' && voteCloseTimestamp != null && remaining > 0;

  const handleCopy = async (): Promise<void> => {
    // Copy is blocked in Option B lock mode (pre-close).
    if (isLocked) return;
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
            className={`apv-receipt__copy${isLocked ? ' apv-receipt__copy--locked' : ''}`}
            onClick={handleCopy}
            disabled={isLocked}
            aria-label={isLocked ? `${identifierNoun} locked until vote closes` : `Copy ${identifierNoun}`}
            aria-disabled={isLocked}
          >
            {isLocked ? '🔒' : copied ? 'Copied' : 'Copy'}
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
        remaining={remaining}
      />

      {socialProofCount != null ? (
        <SocialProofBanner
          count={socialProofCount}
          floor={socialProofFloor}
          voteCloseTimestamp={voteCloseTimestamp}
        />
      ) : null}

      <div className="apv-receipt__actions">
        {isLocked ? (
          // Option B: UI-lock — download disabled with padlock until vote closes.
          // Generates the structural-excuse stimulus for Study 4 (UI-lock condition).
          // Copy handler is also guarded above; this button is the primary
          // download entry point.
          <button
            type="button"
            className="apv-receipt__primary apv-receipt__primary--locked"
            disabled
            aria-label="Download locked until vote closes"
            aria-disabled="true"
          >
            <span className="apv-receipt__lock-icon" aria-hidden="true">🔒</span>
            {' '}Locked until vote closes in {formatTimeRemaining(remaining)}
          </button>
        ) : (
          <button type="button" className="apv-receipt__primary" onClick={handleDownload}>
            Download receipt
          </button>
        )}
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
