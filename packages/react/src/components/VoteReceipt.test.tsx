import { render, screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { VoteReceipt } from './VoteReceipt';
import type { ExplanationVariant, ReceiptLabelVariant } from './VoteReceipt';
import type { VoteReceipt as VoteReceiptData } from '../types';

const receipt: VoteReceiptData = {
  voteId: 'vote-1',
  voteTitle: 'Should we ship?',
  receiptId:
    '0x000000000000000000000000000000000000000000000000000000000000abcd',
  txHash: '0xdeadbeef',
  timestamp: 1714238400000,
  contractAddress: '0xcontract',
};

describe('VoteReceipt copy (APV-04, APV-05, APV-06)', () => {
  it('says "Your vote was cast" - never "ballot recorded" or jargon', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(screen.getByText(/your vote was cast/i)).toBeInTheDocument();
    expect(screen.queryByText(/ballot has been recorded/i)).toBeNull();
  });

  it('labels the hex value as "vote fingerprint", not "nullifier"', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(screen.getByText(/your vote fingerprint/i)).toBeInTheDocument();
    expect(screen.queryByText(/nullifier/i)).toBeNull();
  });

  it('renders the load-bearing privacy claim verbatim', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(
      screen.getByText(
        /this fingerprint proves your ballot was counted without revealing what you voted for/i,
      ),
    ).toBeInTheDocument();
  });

  it('exposes Download receipt as the primary action', () => {
    render(<VoteReceipt receipt={receipt} />);
    const button = screen.getByRole('button', { name: /download receipt/i });
    expect(button).toHaveClass('apv-receipt__primary');
  });

  it('keeps "How to verify" collapsed by default', () => {
    render(<VoteReceipt receipt={receipt} />);
    const toggle = screen.getByRole('button', { name: /how to verify/i });
    expect(toggle).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByText(/save the receipt now/i)).toBeNull();
  });

  it('expands the verify explainer on click', async () => {
    render(<VoteReceipt receipt={receipt} />);
    const toggle = screen.getByRole('button', { name: /how to verify/i });
    await userEvent.click(toggle);
    expect(toggle).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText(/save the receipt now/i)).toBeInTheDocument();
    expect(screen.getByText(/paste your fingerprint/i)).toBeInTheDocument();
  });

  it('invokes the custom onDownload handler when provided', async () => {
    const onDownload = vi.fn();
    render(<VoteReceipt receipt={receipt} onDownload={onDownload} />);
    await userEvent.click(screen.getByRole('button', { name: /download receipt/i }));
    expect(onDownload).toHaveBeenCalledWith(receipt);
  });
});

/**
 * Study 1 label variants (APV-PIUP-01)
 * Verifies all four ReceiptLabelVariant values render the correct heading and
 * explainer noun. These correspond to the four between-subjects conditions:
 *   A: fingerprint (control / production)
 *   B: confirmation-code (eCommerce convention)
 *   C: nullifier (cryptographic term)
 *   D: receipt-id (neutral control)
 */
describe('VoteReceipt labelVariant — Study 1 conditions (APV-PIUP-01)', () => {
  it('condition A (default): renders "vote fingerprint" heading and noun', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(screen.getByText(/your vote fingerprint/i, { selector: 'label' })).toBeInTheDocument();
    expect(
      screen.getByText(
        /this fingerprint proves your ballot was counted without revealing what you voted for/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy fingerprint/i })).toBeInTheDocument();
  });

  it('condition A (explicit): labelVariant="fingerprint" renders fingerprint copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="fingerprint" />);
    expect(screen.getByText(/your vote fingerprint/i, { selector: 'label' })).toBeInTheDocument();
    expect(screen.queryByText(/your confirmation code/i, { selector: 'label' })).toBeNull();
    expect(screen.queryByText(/your nullifier/i, { selector: 'label' })).toBeNull();
    expect(screen.queryByText(/your receipt id/i, { selector: 'label' })).toBeNull();
  });

  it('condition B: labelVariant="confirmation-code" renders confirmation code copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="confirmation-code" />);
    expect(screen.getByText(/your confirmation code/i, { selector: 'label' })).toBeInTheDocument();
    expect(
      screen.getByText(
        /this confirmation code proves your ballot was counted without revealing what you voted for/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy confirmation code/i })).toBeInTheDocument();
    // Ensure fingerprint copy does not bleed through
    expect(screen.queryByText(/your vote fingerprint/i, { selector: 'label' })).toBeNull();
  });

  it('condition C: labelVariant="nullifier" renders nullifier copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="nullifier" />);
    expect(screen.getByText(/your nullifier/i, { selector: 'label' })).toBeInTheDocument();
    expect(
      screen.getByText(
        /this nullifier proves your ballot was counted without revealing what you voted for/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy nullifier/i })).toBeInTheDocument();
  });

  it('condition D: labelVariant="receipt-id" renders receipt ID copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="receipt-id" />);
    expect(screen.getByText(/your receipt id/i, { selector: 'label' })).toBeInTheDocument();
    expect(
      screen.getByText(
        /this receipt id proves your ballot was counted without revealing what you voted for/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy receipt id/i })).toBeInTheDocument();
  });

  it('each variant produces a distinct heading (no cross-contamination)', () => {
    const variants: ReceiptLabelVariant[] = [
      'fingerprint',
      'confirmation-code',
      'nullifier',
      'receipt-id',
    ];
    const headings = [
      /your vote fingerprint/i,
      /your confirmation code/i,
      /your nullifier/i,
      /your receipt id/i,
    ];
    variants.forEach((variant, i) => {
      const { unmount } = render(<VoteReceipt receipt={receipt} labelVariant={variant} />);
      expect(screen.getByText(headings[i]!)).toBeInTheDocument();
      // Other three headings must not appear
      headings.forEach((h, j) => {
        if (j !== i) expect(screen.queryByText(h!)).toBeNull();
      });
      unmount();
    });
  });
});

/**
 * Study 2 explanation variants (APV-PIUP-02, Factor E)
 * Verifies E1 ('explained') and E2 ('unexplained') render the correct
 * protective-framing copy and that production framing (undefined) is unchanged.
 *
 *   E1: Full absent-choice explanation + design-intent rationale.
 *   E2: Minimal statement only — no design-intent signal.
 *   undefined: Current production framing (Study 1 default).
 */
describe('VoteReceipt explanationVariant — Study 2 Factor E (APV-PIUP-02)', () => {
  it('undefined (default): renders production framing with "This is intentional"', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(
      screen.getByText(/this fingerprint proves your ballot was counted without revealing/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/save it to verify after the vote closes/i)).toBeInTheDocument();
    // Must NOT include Study 2 E1-specific rationale
    expect(screen.queryByText(/subpoenaed without revealing how you voted/i)).toBeNull();
  });

  it('E1 (explained): renders full absent-choice explanation with design-intent rationale', () => {
    render(<VoteReceipt receipt={receipt} explanationVariant="explained" />);
    // E1 key signal: "This is intentional."
    expect(screen.getByText(/this is intentional/i)).toBeInTheDocument();
    // E1 key detail: privacy-as-subpoena-resistance rationale
    expect(
      screen.getByText(/subpoenaed without revealing how you voted/i),
    ).toBeInTheDocument();
    // E1 closing claim: "is the only thing you need"
    expect(
      screen.getByText(/is the only thing you need/i),
    ).toBeInTheDocument();
    // Must NOT include production framing ("Save it to verify after the vote closes")
    expect(screen.queryByText(/save it to verify after the vote closes/i)).toBeNull();
  });

  it('E2 (unexplained): renders minimal statement only — no design-intent signal', () => {
    render(<VoteReceipt receipt={receipt} explanationVariant="unexplained" />);
    // E2 content: minimal statement
    expect(
      screen.getByText(/your vote is private and verifiable/i),
    ).toBeInTheDocument();
    // Must NOT include "This is intentional"
    expect(screen.queryByText(/this is intentional/i)).toBeNull();
    // Must NOT include subpoena rationale
    expect(screen.queryByText(/subpoenaed without revealing how you voted/i)).toBeNull();
    // Must NOT include production "save it to verify" copy
    expect(screen.queryByText(/save it to verify after the vote closes/i)).toBeNull();
  });

  it('E1 + confirmation-code: label noun appears in explanation', () => {
    render(
      <VoteReceipt
        receipt={receipt}
        labelVariant="confirmation-code"
        explanationVariant="explained"
      />,
    );
    // Heading label — use selector to avoid matching the explanation paragraph
    expect(screen.getByText(/your confirmation code/i, { selector: 'label' })).toBeInTheDocument();
    // E1 explanation must embed "confirmation code" noun — unique phrase in the E1 paragraph
    expect(
      screen.getByText(/confirmation code is the only thing you need/i),
    ).toBeInTheDocument();
  });

  it('all three explanation variants produce distinct copy (no cross-contamination)', () => {
    const cases: Array<{ variant: ExplanationVariant | undefined; marker: RegExp; absent: RegExp[] }> = [
      {
        variant: undefined,
        marker: /save it to verify after the vote closes/i,
        absent: [/subpoenaed without revealing how you voted/i],
      },
      {
        variant: 'explained',
        marker: /subpoenaed without revealing how you voted/i,
        absent: [/save it to verify after the vote closes/i],
      },
      {
        variant: 'unexplained',
        // E2 has only the minimal statement; use a phrase not in the others
        marker: /your vote is private and verifiable/i,
        absent: [
          /subpoenaed without revealing how you voted/i,
          /save it to verify after the vote closes/i,
        ],
      },
    ];
    cases.forEach(({ variant, marker, absent }) => {
      const { unmount } = render(
        <VoteReceipt receipt={receipt} {...(variant !== undefined ? { explanationVariant: variant } : {})} />,
      );
      expect(screen.getByText(marker)).toBeInTheDocument();
      absent.forEach((pattern) => {
        expect(screen.queryByText(pattern)).toBeNull();
      });
      unmount();
    });
  });
});

/**
 * Study 2 study mode — behavioral logging (APV-PIUP-03)
 * Verifies that studyMode=true:
 *   - Fires onDownloadClick(true) instead of triggering a real download.
 *   - Does NOT call onDownload.
 *   - Fires onVerifyExpanded(true/false) on verification section toggle.
 *   - Does NOT actually write a file (onDownloadClick fires, file absent).
 */
describe('VoteReceipt studyMode — Study 2 behavioral logging (APV-PIUP-03)', () => {
  it('studyMode=true: fires onDownloadClick(true) on Download click', async () => {
    const onDownloadClick = vi.fn();
    render(
      <VoteReceipt receipt={receipt} studyMode onDownloadClick={onDownloadClick} />,
    );
    await userEvent.click(screen.getByRole('button', { name: /download receipt/i }));
    expect(onDownloadClick).toHaveBeenCalledOnce();
    expect(onDownloadClick).toHaveBeenCalledWith(true);
  });

  it('studyMode=true: does NOT call onDownload', async () => {
    const onDownload = vi.fn();
    const onDownloadClick = vi.fn();
    render(
      <VoteReceipt
        receipt={receipt}
        studyMode
        onDownload={onDownload}
        onDownloadClick={onDownloadClick}
      />,
    );
    await userEvent.click(screen.getByRole('button', { name: /download receipt/i }));
    expect(onDownload).not.toHaveBeenCalled();
    expect(onDownloadClick).toHaveBeenCalledWith(true);
  });

  it('studyMode=true: fires onVerifyExpanded(true) on expand', async () => {
    const onVerifyExpanded = vi.fn();
    render(
      <VoteReceipt receipt={receipt} studyMode onVerifyExpanded={onVerifyExpanded} />,
    );
    await userEvent.click(screen.getByRole('button', { name: /how to verify/i }));
    expect(onVerifyExpanded).toHaveBeenCalledOnce();
    expect(onVerifyExpanded).toHaveBeenCalledWith(true);
  });

  it('studyMode=true: fires onVerifyExpanded(false) on collapse', async () => {
    const onVerifyExpanded = vi.fn();
    render(
      <VoteReceipt receipt={receipt} studyMode onVerifyExpanded={onVerifyExpanded} />,
    );
    const toggle = screen.getByRole('button', { name: /how to verify/i });
    await userEvent.click(toggle);   // expand → true
    await userEvent.click(toggle);   // collapse → false
    expect(onVerifyExpanded).toHaveBeenCalledTimes(2);
    expect(onVerifyExpanded).toHaveBeenNthCalledWith(1, true);
    expect(onVerifyExpanded).toHaveBeenNthCalledWith(2, false);
  });

  it('studyMode=false (default): onDownload is called normally', async () => {
    const onDownload = vi.fn();
    const onDownloadClick = vi.fn();
    render(
      <VoteReceipt
        receipt={receipt}
        onDownload={onDownload}
        onDownloadClick={onDownloadClick}
      />,
    );
    await userEvent.click(screen.getByRole('button', { name: /download receipt/i }));
    expect(onDownload).toHaveBeenCalledWith(receipt);
    expect(onDownloadClick).not.toHaveBeenCalled();
  });

  it('studyMode=false (default): onVerifyExpanded is NOT called on toggle', async () => {
    const onVerifyExpanded = vi.fn();
    render(
      <VoteReceipt receipt={receipt} onVerifyExpanded={onVerifyExpanded} />,
    );
    await userEvent.click(screen.getByRole('button', { name: /how to verify/i }));
    expect(onVerifyExpanded).not.toHaveBeenCalled();
  });

  it('studyMode=true + E2 + confirmation-code: full Study 2 condition wires up', async () => {

    const onDownloadClick = vi.fn();
    const onVerifyExpanded = vi.fn();
    render(
      <VoteReceipt
        receipt={receipt}
        labelVariant="confirmation-code"
        explanationVariant="unexplained"
        studyMode
        onDownloadClick={onDownloadClick}
        onVerifyExpanded={onVerifyExpanded}
      />,
    );
    // E2 minimal framing present
    expect(
      screen.getByText(/your vote is private and verifiable/i),
    ).toBeInTheDocument();
    // Confirmation code heading
    expect(screen.getByText(/your confirmation code/i)).toBeInTheDocument();
    // Download click is captured
    await userEvent.click(screen.getByRole('button', { name: /download receipt/i }));
    expect(onDownloadClick).toHaveBeenCalledWith(true);
    // Verify expansion is logged
    await userEvent.click(screen.getByRole('button', { name: /how to verify/i }));
    expect(onVerifyExpanded).toHaveBeenCalledWith(true);
  });
});

/**
 * Option D: temporal disclosure countdown (APV-PIUP-04)
 *
 * Verifies the TemporalDisclosure component renders correctly for three states:
 *   1. No timestamp provided — nothing rendered.
 *   2. Timestamp in the future — countdown shown.
 *   3. Timestamp in the past — "sharing is now safe" shown.
 *
 * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option D
 */
describe('VoteReceipt temporal disclosure — Option D countdown (APV-PIUP-04)', () => {
  const NOW = 1_751_300_000_000; // fixed reference epoch (ms)

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('renders nothing when voteCloseTimestamp is not provided', () => {
    render(<VoteReceipt receipt={receipt} />);
    expect(screen.queryByRole('status')).toBeNull();
    expect(screen.queryByText(/sharing is safe in/i)).toBeNull();
    expect(screen.queryByText(/vote is closed/i)).toBeNull();
  });

  it('shows countdown when voteCloseTimestamp is in the future', () => {
    const future = NOW + 5 * 86400_000 + 3 * 3600_000 + 12 * 60_000; // 5d 3h 12m
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    // Countdown message present
    expect(screen.getByRole('status')).toBeInTheDocument();
    expect(screen.getByText(/sharing is safe in/i)).toBeInTheDocument();
    // Days-dominant format
    expect(screen.getByText(/5d 3h 12m/i)).toBeInTheDocument();
    // "sharing is now safe" must NOT appear
    expect(screen.queryByText(/vote is closed/i)).toBeNull();
  });

  it('shows hours+minutes format when < 1 day remains', () => {
    const future = NOW + 3 * 3600_000 + 12 * 60_000; // 3h 12m
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    expect(screen.getByText(/3h 12m/i)).toBeInTheDocument();
    expect(screen.queryByText(/\dd/)).toBeNull(); // no days part
  });

  it('shows minutes+seconds format when < 1 hour remains', () => {
    const future = NOW + 12 * 60_000 + 48_000; // 12m 48s
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    expect(screen.getByText(/12m 48s/i)).toBeInTheDocument();
  });

  it('shows "vote is closed" when voteCloseTimestamp is in the past', () => {
    const past = NOW - 60_000; // 1 minute ago
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={past} />);
    expect(screen.getByRole('status')).toBeInTheDocument();
    expect(screen.getByText(/vote is closed/i)).toBeInTheDocument();
    expect(screen.getByText(/sharing your fingerprint is now safe/i)).toBeInTheDocument();
    // Countdown must NOT appear
    expect(screen.queryByText(/sharing is safe in/i)).toBeNull();
  });

  it('uses the correct identifier noun in the post-close message', () => {
    const past = NOW - 1_000;
    render(
      <VoteReceipt receipt={receipt} labelVariant="confirmation-code" voteCloseTimestamp={past} />,
    );
    expect(screen.getByText(/sharing your confirmation code is now safe/i)).toBeInTheDocument();
  });

  it('transitions from countdown to post-close when timer expires', () => {
    const future = NOW + 5_000; // 5 seconds from now
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    // Before expiry: countdown visible
    expect(screen.getByText(/sharing is safe in/i)).toBeInTheDocument();
    expect(screen.queryByText(/vote is closed/i)).toBeNull();
    // Advance past close time
    act(() => { vi.advanceTimersByTime(6_000); });
    expect(screen.queryByText(/sharing is safe in/i)).toBeNull();
    expect(screen.getByText(/vote is closed/i)).toBeInTheDocument();
  });

  it('updates the countdown display on each tick', () => {
    const future = NOW + 2 * 60_000 + 30_000; // 2m 30s
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    expect(screen.getByText(/2m 30s/i)).toBeInTheDocument();
    // Advance 1 second
    act(() => { vi.advanceTimersByTime(1_000); });
    expect(screen.getByText(/2m 29s/i)).toBeInTheDocument();
  });

  it('does not render temporal disclosure in study mode (no timestamp)', () => {
    render(<VoteReceipt receipt={receipt} studyMode onDownloadClick={vi.fn()} />);
    expect(screen.queryByRole('status')).toBeNull();
  });
});

/**
 * Option B: UI-lock — download/copy disabled until vote closes (APV-PIUP-05)
 *
 * Verifies that `temporalLock='lock'` + `voteCloseTimestamp` produces a
 * technical barrier (disabled buttons, padlock icon, correct aria attributes)
 * before the vote closes, and that both buttons re-enable once the close
 * timestamp is reached.
 *
 * This generates the "structural-excuse" stimulus condition for Study 4
 * (UI-lock × coercion-pressure factorial vignette).
 *
 * Ref: docs/piup-temporal-disclosure-ux-spike-2026-07-01.md §Option B
 * Ref: docs/piup-study4-temporal-coercion-vignette-2026-07-01.md §3.1
 */
describe('VoteReceipt UI-lock — Option B pre-close enforcement (APV-PIUP-05)', () => {
  const NOW = 1_751_300_000_000; // fixed reference epoch (ms)

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('disables download button before vote close when temporalLock=lock', () => {
    const future = NOW + 5 * 86400_000; // 5 days from now
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    // The locked button renders with class apv-receipt__primary--locked
    const downloadBtn = screen.getByRole('button', { name: /download locked until vote closes/i });
    expect(downloadBtn).toBeDisabled();
    expect(downloadBtn).toHaveAttribute('aria-disabled', 'true');
    expect(downloadBtn).toHaveClass('apv-receipt__primary--locked');
    // Standard "Download receipt" button must NOT appear
    expect(screen.queryByRole('button', { name: /^download receipt$/i })).toBeNull();
  });

  it('shows padlock icon and countdown on the locked download button', () => {
    const future = NOW + 5 * 86400_000 + 3 * 3600_000 + 12 * 60_000; // 5d 3h 12m
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    const downloadBtn = screen.getByRole('button', { name: /download locked until vote closes/i });
    // Button text contains the countdown (5d 3h 12m)
    expect(downloadBtn.textContent).toMatch(/5d 3h 12m/i);
    // Padlock emoji present in button
    expect(downloadBtn.textContent).toContain('🔒');
  });

  it('disables copy button before vote close when temporalLock=lock', () => {
    const future = NOW + 5 * 86400_000;
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    const copyBtn = screen.getByRole('button', { name: /fingerprint locked until vote closes/i });
    expect(copyBtn).toBeDisabled();
    expect(copyBtn).toHaveAttribute('aria-disabled', 'true');
    // Padlock emoji visible on the copy button
    expect(copyBtn.textContent).toContain('🔒');
  });

  it('still renders the Option D countdown when temporalLock=lock', () => {
    // Option B = UI-lock + countdown; TemporalDisclosure should still appear.
    // Note: /5d 3h 12m/ appears in both the status element and the locked button
    // text — scope assertion to role='status' to avoid multiple-element error.
    const future = NOW + 5 * 86400_000 + 3 * 3600_000 + 12 * 60_000; // 5d 3h 12m
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    expect(screen.getByRole('status')).toBeInTheDocument();
    expect(screen.getByText(/sharing is safe in/i)).toBeInTheDocument();
    // Countdown value appears in the status element (TemporalDisclosure)
    expect(screen.getByRole('status')).toHaveTextContent(/5d 3h 12m/);
  });

  it('re-enables download button once the vote closes', () => {
    const future = NOW + 3_000; // 3 seconds from now
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    // Pre-close: locked
    expect(screen.getByRole('button', { name: /download locked until vote closes/i })).toBeDisabled();
    // Advance past close time
    act(() => { vi.advanceTimersByTime(4_000); });
    // Post-close: normal download button appears
    const downloadBtn = screen.getByRole('button', { name: /download receipt/i });
    expect(downloadBtn).not.toBeDisabled();
    expect(downloadBtn).toHaveClass('apv-receipt__primary');
    expect(downloadBtn).not.toHaveClass('apv-receipt__primary--locked');
  });

  it('re-enables copy button once the vote closes', () => {
    const future = NOW + 3_000;
    render(<VoteReceipt receipt={receipt} temporalLock="lock" voteCloseTimestamp={future} />);
    // Pre-close: copy locked
    expect(screen.getByRole('button', { name: /fingerprint locked until vote closes/i })).toBeDisabled();
    act(() => { vi.advanceTimersByTime(4_000); });
    // Post-close: copy button enabled with normal aria-label
    const copyBtn = screen.getByRole('button', { name: /copy fingerprint/i });
    expect(copyBtn).not.toBeDisabled();
  });

  it('Option D (temporalLock=count) keeps download enabled before vote close', () => {
    const future = NOW + 5 * 86400_000;
    render(<VoteReceipt receipt={receipt} temporalLock="count" voteCloseTimestamp={future} />);
    // Countdown shown (Option D)
    expect(screen.getByText(/sharing is safe in/i)).toBeInTheDocument();
    // Download button is NOT locked — normal "Download receipt" button present and enabled
    const downloadBtn = screen.getByRole('button', { name: /download receipt/i });
    expect(downloadBtn).not.toBeDisabled();
    expect(downloadBtn).not.toHaveClass('apv-receipt__primary--locked');
    // No padlock-locked button present
    expect(screen.queryByRole('button', { name: /download locked until vote closes/i })).toBeNull();
  });

  it('no temporalLock keeps download enabled before vote close', () => {
    const future = NOW + 5 * 86400_000;
    render(<VoteReceipt receipt={receipt} voteCloseTimestamp={future} />);
    // Countdown shown (default Option D behaviour when timestamp provided)
    expect(screen.getByText(/sharing is safe in/i)).toBeInTheDocument();
    // Download not locked
    const downloadBtn = screen.getByRole('button', { name: /download receipt/i });
    expect(downloadBtn).not.toBeDisabled();
    expect(screen.queryByRole('button', { name: /download locked until vote closes/i })).toBeNull();
  });

  it('temporalLock=lock has no effect when voteCloseTimestamp is not provided', () => {
    // Without a timestamp, isLocked is always false
    render(<VoteReceipt receipt={receipt} temporalLock="lock" />);
    // Normal download button present
    expect(screen.getByRole('button', { name: /download receipt/i })).not.toBeDisabled();
    // No locked download button
    expect(screen.queryByRole('button', { name: /download locked until vote closes/i })).toBeNull();
    // Copy button present in normal state
    expect(screen.getByRole('button', { name: /copy fingerprint/i })).not.toBeDisabled();
    // No temporal disclosure rendered
    expect(screen.queryByRole('status')).toBeNull();
  });

  it('uses the correct identifier noun in locked copy button label', () => {
    const future = NOW + 5 * 86400_000;
    render(
      <VoteReceipt
        receipt={receipt}
        temporalLock="lock"
        voteCloseTimestamp={future}
        labelVariant="confirmation-code"
      />,
    );
    expect(
      screen.getByRole('button', { name: /confirmation code locked until vote closes/i }),
    ).toBeDisabled();
  });
});
