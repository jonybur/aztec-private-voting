import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { VoteReceipt } from './VoteReceipt';
import type { ReceiptLabelVariant } from './VoteReceipt';
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
        /this fingerprint proves your vote was counted without revealing how you voted/i,
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
    expect(screen.getByText(/your vote fingerprint/i)).toBeInTheDocument();
    expect(
      screen.getByText(
        /this fingerprint proves your vote was counted without revealing how you voted/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy fingerprint/i })).toBeInTheDocument();
  });

  it('condition A (explicit): labelVariant="fingerprint" renders fingerprint copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="fingerprint" />);
    expect(screen.getByText(/your vote fingerprint/i)).toBeInTheDocument();
    expect(screen.queryByText(/your confirmation code/i)).toBeNull();
    expect(screen.queryByText(/your nullifier/i)).toBeNull();
    expect(screen.queryByText(/your receipt id/i)).toBeNull();
  });

  it('condition B: labelVariant="confirmation-code" renders confirmation code copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="confirmation-code" />);
    expect(screen.getByText(/your confirmation code/i)).toBeInTheDocument();
    expect(
      screen.getByText(
        /this confirmation code proves your vote was counted without revealing how you voted/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy confirmation code/i })).toBeInTheDocument();
    // Ensure fingerprint copy does not bleed through
    expect(screen.queryByText(/your vote fingerprint/i)).toBeNull();
  });

  it('condition C: labelVariant="nullifier" renders nullifier copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="nullifier" />);
    expect(screen.getByText(/your nullifier/i)).toBeInTheDocument();
    expect(
      screen.getByText(
        /this nullifier proves your vote was counted without revealing how you voted/i,
      ),
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy nullifier/i })).toBeInTheDocument();
  });

  it('condition D: labelVariant="receipt-id" renders receipt ID copy', () => {
    render(<VoteReceipt receipt={receipt} labelVariant="receipt-id" />);
    expect(screen.getByText(/your receipt id/i)).toBeInTheDocument();
    expect(
      screen.getByText(
        /this receipt id proves your vote was counted without revealing how you voted/i,
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
      expect(screen.getByText(headings[i])).toBeInTheDocument();
      // Other three headings must not appear
      headings.forEach((h, j) => {
        if (j !== i) expect(screen.queryByText(h)).toBeNull();
      });
      unmount();
    });
  });
});
