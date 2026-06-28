/**
 * study2-host/src/App.jsx
 *
 * Prototype host for PIUP Study 2 — 2×2×2 between-subjects design.
 * Deploy to Vercel as a standalone app (e.g. https://aztec-study2.vercel.app).
 * Designed to be embedded as an <iframe> inside a Qualtrics Stimulus block.
 *
 * URL param:
 *   ?condition=<code>   e.g. ?condition=L1E1I1
 *
 * Condition codes (8 cells):
 *   L1 = labelVariant "fingerprint"        | L2 = labelVariant "confirmation-code"
 *   E1 = explanationVariant "explained"    | E2 = explanationVariant "unexplained"
 *   I1 = Intervention: none (control)      | I2 = Intervention: calibration block
 *
 * postMessage protocol (sent to window.parent):
 *   { type: 'piup-ready' }                              — component mounted
 *   { type: 'piup-download-click', clicked: true }      — Download button clicked
 *   { type: 'piup-verify-expanded', expanded: boolean } — "How to verify" toggled
 *
 * See: docs/qualtrics-setup-guide-study2-2026-06-28.md §A
 */

import { useEffect, useMemo } from 'react';
import { VoteReceipt } from '@aztec-private-voting/react';
import '@aztec-private-voting/react/styles.css';

// ---------------------------------------------------------------------------
// Synthetic placeholder receipt — realistic shape, nonsense values.
// Replace with a real receipt fetched from the Aztec node if needed;
// for the study the exact values do not matter (participants evaluate
// the UI, not the blockchain data).
// ---------------------------------------------------------------------------
const PLACEHOLDER_RECEIPT = {
  voteId: 'piup-study2-demo-0001',
  voteTitle: 'City Council Motion: Extend Park Hours',
  receiptId:
    '0x3a4f7b2c8e1d6a9f5c2b0e7d4a8f3c6b1e9d2a5f8c3b7e0d4a9f2c5b8e1d3a6f',
  txHash:
    '0x7e2a5b8c3d6f1e4a9b2c5e8d3a6f1b4e7c0d3a6b9c2e5d8a1f4b7c0e3d6a9f2b5',
  timestamp: Math.floor(Date.now() / 1000) - 300, // 5 minutes ago
  contractAddress: '0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b',
};

// ---------------------------------------------------------------------------
// Parse condition from URL
// ---------------------------------------------------------------------------
function parseCondition(raw) {
  const code = (raw || '').toUpperCase();
  return {
    raw: code,
    labelVariant: code.startsWith('L1') ? 'fingerprint' : 'confirmation-code',
    explanationVariant: code.includes('E1') ? 'explained' : 'unexplained',
    interventionGroup: code.includes('I2') ? 'calibration' : 'control',
  };
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
export default function App() {
  const params = useMemo(
    () => new URLSearchParams(window.location.search),
    []
  );
  const condition = useMemo(
    () => parseCondition(params.get('condition')),
    [params]
  );

  // Signal to Qualtrics that the prototype has rendered successfully.
  // Must fire quickly — Qualtrics waits up to 8 seconds before showing
  // the static fallback screenshot (§9.3.1 of design note).
  useEffect(() => {
    window.parent?.postMessage({ type: 'piup-ready' }, '*');
  }, []);

  // ── postMessage callbacks ──────────────────────────────────────────────
  function handleDownloadClick() {
    window.parent?.postMessage({ type: 'piup-download-click', clicked: true }, '*');
  }

  function handleVerifyExpanded(expanded) {
    window.parent?.postMessage({ type: 'piup-verify-expanded', expanded }, '*');
  }

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'flex-start',
        padding: '24px 16px',
        minHeight: '100%',
      }}
    >
      <VoteReceipt
        receipt={PLACEHOLDER_RECEIPT}
        labelVariant={condition.labelVariant}
        explanationVariant={condition.explanationVariant}
        studyMode={true}
        onDownloadClick={handleDownloadClick}
        onVerifyExpanded={handleVerifyExpanded}
      />
    </div>
  );
}
