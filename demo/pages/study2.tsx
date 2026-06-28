/**
 * PIUP Study 2 — Prototype Host Page
 *
 * Serves as the iframe target embedded in the Qualtrics Stimulus block.
 * Reads ?condition=L1E1I1 (or any 8-cell code) from the URL and renders
 * VoteReceipt in studyMode with the appropriate label and explanation props.
 *
 * Design note: aztec-private-voting/docs/piup-study2-design-note-2026-06-22.md
 * Qualtrics guide: aztec-private-voting/docs/qualtrics-setup-guide-study2-2026-06-28.md §A
 *
 * postMessage protocol (§A.2 of Qualtrics guide):
 *   { type: 'piup-ready' }                         — fired after mount
 *   { type: 'piup-download-click', clicked: true } — download button clicked
 *   { type: 'piup-verify-expanded', expanded: bool } — verify section toggled
 *
 * Factor I (I1 / I2 calibration intervention) is handled entirely in Qualtrics.
 * This page does NOT vary by I level.
 *
 * URL param schema:
 *   ?condition=L1E1I1  → fingerprint / explained
 *   ?condition=L1E1I2  → fingerprint / explained
 *   ?condition=L1E2I1  → fingerprint / unexplained
 *   ?condition=L1E2I2  → fingerprint / unexplained
 *   ?condition=L2E1I1  → confirmation-code / explained
 *   ?condition=L2E1I2  → confirmation-code / explained
 *   ?condition=L2E2I1  → confirmation-code / unexplained
 *   ?condition=L2E2I2  → confirmation-code / unexplained
 */

import { useEffect, useCallback } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import { VoteReceipt } from '@aztec-private-voting/react';
import type {
  VoteReceiptData,
  VoteReceiptProps,
  ReceiptLabelVariant,
  ExplanationVariant,
} from '@aztec-private-voting/react';

// ─── Condition decoder ───────────────────────────────────────────────────────

type ConditionFactors = {
  labelVariant: ReceiptLabelVariant;
  explanationVariant: ExplanationVariant;
};

/**
 * Decodes a condition code like "L1E1I1" into VoteReceipt props.
 *
 * L1 → labelVariant = 'fingerprint'       ("vote fingerprint")
 * L2 → labelVariant = 'confirmation-code' ("confirmation code")
 * E1 → explanationVariant = 'explained'
 * E2 → explanationVariant = 'unexplained'
 * I  → not used here; handled by Qualtrics Calibration block
 */
function decodeCondition(raw: string | string[] | undefined): ConditionFactors {
  const code = (Array.isArray(raw) ? raw[0] : raw ?? 'L1E1I1').toUpperCase();

  const labelVariant: ReceiptLabelVariant = code.startsWith('L2')
    ? 'confirmation-code'
    : 'fingerprint';

  const explanationVariant: ExplanationVariant = code.includes('E2')
    ? 'unexplained'
    : 'explained';

  return { labelVariant, explanationVariant };
}

// ─── Study receipt fixture ───────────────────────────────────────────────────
// Fixed values so the display is stable across all participants.
// These are illustrative — no real blockchain data is used.

const STUDY_RECEIPT: VoteReceiptData = {
  voteId: 'piup-study-2026-s2',
  voteTitle: 'DAO Governance Vote #12',
  receiptId:
    '0xa3f7c8e2d4b1f098a3f7c8e2d4b1f098a3f7c8e2d4b1f098a3f7c8e2d4b1f098',
  txHash:
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
  timestamp: 1751068800000, // 2025-06-28 (fixed; display must be consistent across sessions)
  contractAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
};

// ─── Study2HostInner (client-only) ────────────────────────────────────────────

interface Study2HostProps {
  labelVariant: ReceiptLabelVariant;
  explanationVariant: ExplanationVariant;
}

function Study2HostInner({
  labelVariant,
  explanationVariant,
}: Study2HostProps): JSX.Element {
  // Signal render-ready to Qualtrics parent.
  // Qualtrics listens for this within 8 seconds to cancel the browser-fallback timeout.
  useEffect(() => {
    window.parent?.postMessage({ type: 'piup-ready' }, '*');
  }, []);

  // Fires when participant clicks the Download button in study mode.
  const handleDownloadClick = useCallback<
    NonNullable<VoteReceiptProps['onDownloadClick']>
  >(() => {
    window.parent?.postMessage({ type: 'piup-download-click', clicked: true }, '*');
  }, []);

  // Fires whenever the "How to verify" section is expanded or collapsed.
  const handleVerifyExpanded = useCallback<
    NonNullable<VoteReceiptProps['onVerifyExpanded']>
  >((expanded: boolean) => {
    window.parent?.postMessage({ type: 'piup-verify-expanded', expanded }, '*');
  }, []);

  return (
    <div className="study2-host__container">
      <VoteReceipt
        receipt={STUDY_RECEIPT}
        labelVariant={labelVariant}
        explanationVariant={explanationVariant}
        studyMode={true}
        onDownloadClick={handleDownloadClick}
        onVerifyExpanded={handleVerifyExpanded}
      />
    </div>
  );
}

// ─── Page (Next.js) ───────────────────────────────────────────────────────────

export default function Study2Page(): JSX.Element {
  const { query, isReady } = useRouter();
  const { labelVariant, explanationVariant } = decodeCondition(
    isReady ? query.condition : undefined,
  );

  return (
    <>
      <Head>
        {/* Minimal head — this page is an iframe target, not a standalone page */}
        <title>PIUP Study 2</title>
        <meta name="robots" content="noindex, nofollow" />
        {/* Allow framing from Qualtrics (overrides X-Frame-Options if set globally) */}
        <meta httpEquiv="X-Frame-Options" content="ALLOWALL" />
      </Head>

      <style>{`
        html, body { margin: 0; padding: 0; background: #fff; }
        .study2-host__container {
          padding: 16px;
          max-width: 640px;
          margin: 0 auto;
        }
      `}</style>

      {isReady && (
        <Study2HostInner
          labelVariant={labelVariant}
          explanationVariant={explanationVariant}
        />
      )}
    </>
  );
}
