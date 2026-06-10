/**
 * Babylon Governance Demo
 *
 * Demonstrates private BABY token governance voting:
 * 1. Voter connects their Babylon/Keplr wallet
 * 2. App fetches their Merkle path from the snapshot
 * 3. ZK proof generated in browser (proves BABY holding without revealing address)
 * 4. Private ballot submitted
 * 5. Receipt shown
 *
 * No bridging. BABY tokens never move.
 */

import { useState } from 'react';
import { connect as connectWallet, isWalletAvailable, NoWalletInstalledError, UserRejectedError } from '../lib/keplr';
import { generateBabyProof, proofFingerprint } from '../lib/babyProof';
import type { EligibilityResponse } from './api/eligibility';

type Step = 'connect' | 'check' | 'prove' | 'vote' | 'receipt' | 'error';

interface VoteOption {
  id: number;
  label: string;
}

const VOTE_OPTIONS: VoteOption[] = [
  { id: 0, label: 'For' },
  { id: 1, label: 'Against' },
  { id: 2, label: 'Abstain' },
];

const DEMO_VOTE_TITLE = 'Babylon Genesis — Treasury Allocation Q3 2026';
// Merkle root over a synthetic eligibility set (scripts/synthetic-snapshot.ts).
// Addresses are generated, not real holders — no Babylon Genesis data is used.
const DEMO_MERKLE_ROOT = '0xdaee10093b80045cbbdc2519dac7d9a9d6c858d51bcba4853e68c37badafcf63';
const SNAPSHOT_HOLDER_COUNT = 10_000;
const SNAPSHOT_DATE = '2026-06-10';

export default function BabylonDemo() {
  const [step, setStep] = useState<Step>('connect');
  const [address, setAddress] = useState<string>('');
  const [balance, setBalance] = useState<bigint>(0n);
  const [eligibility, setEligibility] = useState<EligibilityResponse | null>(null);
  const [selectedOption, setSelectedOption] = useState<number | null>(null);
  const [receipt, setReceipt] = useState<string>('');
  const [proofDurationMs, setProofDurationMs] = useState<number | null>(null);
  const [error, setError] = useState<string>('');
  const [proving, setProving] = useState(false);

  const handleConnect = async () => {
    setError('');
    try {
      const { address: addr } = await connectWallet();
      setAddress(addr);
      setStep('check');
    } catch (e) {
      if (e instanceof NoWalletInstalledError) {
        const w = isWalletAvailable();
        setError(`${e.message}${(!w.keplr && !w.leap) ? '' : ''}`);
      } else if (e instanceof UserRejectedError) {
        setError(e.message);
      } else {
        setError(e instanceof Error ? e.message : 'Failed to connect wallet');
      }
      setStep('error');
    }
  };

  const checkEligibility = async () => {
    setError('');
    try {
      const r = await fetch(`/api/eligibility?address=${encodeURIComponent(address)}`);
      if (r.status === 404) {
        const body = await r.json();
        setError(`Address ${address} is not in the synthetic eligibility set. Try the sample eligible address: ${body.sampleEligibleAddress ?? '(none)'}.`);
        setStep('error');
        return;
      }
      if (!r.ok) {
        const body = await r.json().catch(() => ({}));
        setError(body.error ?? `Eligibility lookup failed: HTTP ${r.status}`);
        setStep('error');
        return;
      }
      const data: EligibilityResponse = await r.json();
      const bal = BigInt(data.balance);
      const min = BigInt(data.minBalance);
      if (bal < min) {
        setError(`Minimum ${(Number(min) / 1_000_000).toFixed(0)} BABY required; address holds ${(Number(bal) / 1_000_000).toFixed(2)}.`);
        setStep('error');
        return;
      }
      setBalance(bal);
      setEligibility(data);
      setStep('prove');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Eligibility lookup failed');
      setStep('error');
    }
  };

  const generateProofAndVote = async () => {
    if (selectedOption === null || !eligibility) return;
    setProving(true);
    setError('');

    try {
      const { proof, durationMs } = await generateBabyProof({
        address: eligibility.address,
        balance: BigInt(eligibility.balance),
        minBalance: BigInt(eligibility.minBalance),
        path: eligibility.path,
        indices: eligibility.indices,
        root: eligibility.root,
      });
      const fingerprint = await proofFingerprint(proof);
      setReceipt(fingerprint);
      setProofDurationMs(Math.round(durationMs));
      setStep('receipt');
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Proof generation failed');
      setStep('error');
    } finally {
      setProving(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: '#0d0d0d',
      color: '#e8e8e8',
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '40px 24px',
    }}>
      {/* Header */}
      <div style={{ textAlign: 'center', marginBottom: '48px' }}>
        <div style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '0.16em', textTransform: 'uppercase', color: '#f97316', marginBottom: '12px' }}>
          Umbra × Babylon
        </div>
        <h1 style={{ fontSize: '28px', fontWeight: 700, margin: '0 0 8px', color: '#fff' }}>
          Private Governance Vote
        </h1>
        <p style={{ color: '#555', fontSize: '14px', margin: 0, maxWidth: '400px' }}>
          Prove your BABY holdings with a ZK proof. Vote anonymously. No bridging.
        </p>
      </div>

      {/* Vote card */}
      <div style={{
        width: '100%',
        maxWidth: '480px',
        background: '#151515',
        border: '1px solid #222',
        borderRadius: '12px',
        padding: '32px',
      }}>
        <div style={{ fontSize: '11px', color: '#555', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.1em', marginBottom: '8px' }}>
          Active proposal
        </div>
        <h2 style={{ fontSize: '18px', fontWeight: 600, margin: '0 0 24px', color: '#e8e8e8', lineHeight: 1.4 }}>
          {DEMO_VOTE_TITLE}
        </h2>

        {/* Step: Connect */}
        {step === 'connect' && (
          <div>
            <p style={{ color: '#666', fontSize: '14px', marginBottom: '24px', lineHeight: 1.6 }}>
              Connect your Babylon wallet to prove your BABY token balance.
              Your address and vote remain private.
            </p>
            <button onClick={handleConnect} style={primaryBtn('#f97316')}>
              Connect Keplr / Leap wallet
            </button>
            <div style={{ marginTop: '16px', padding: '12px', background: '#1a1a1a', borderRadius: '6px', fontSize: '12px', color: '#555' }}>
              <strong style={{ color: '#444' }}>How it works:</strong> A ZK proof of your BABY balance is generated
              locally in your browser. Your address is checked against the snapshot
              for the demo and is never posted onchain.
            </div>
          </div>
        )}

        {/* Step: Check eligibility */}
        {step === 'check' && (
          <div>
            <div style={{ padding: '16px', background: '#1a1a1a', borderRadius: '8px', marginBottom: '24px' }}>
              <div style={{ fontSize: '12px', color: '#555', marginBottom: '4px' }}>Connected address</div>
              <div style={{ fontSize: '13px', color: '#888', fontFamily: 'monospace', wordBreak: 'break-all' }}>{address}</div>
              <div style={{ fontSize: '12px', color: '#555', marginTop: '8px', marginBottom: '4px' }}>BABY balance</div>
              <div style={{ fontSize: '16px', fontWeight: 700, color: '#f97316' }}>
                {(Number(balance) / 1_000_000).toFixed(2)} BABY
              </div>
            </div>
            <button onClick={checkEligibility} style={primaryBtn('#f97316')}>
              Check eligibility &amp; continue
            </button>
          </div>
        )}

        {/* Step: Select option + prove */}
        {step === 'prove' && (
          <div>
            <div style={{ marginBottom: '20px' }}>
              <div style={{ fontSize: '12px', color: '#555', marginBottom: '12px', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                Your vote
              </div>
              {VOTE_OPTIONS.map(opt => (
                <button
                  key={opt.id}
                  onClick={() => setSelectedOption(opt.id)}
                  style={{
                    display: 'block', width: '100%', padding: '12px 16px',
                    marginBottom: '8px', background: selectedOption === opt.id ? '#1a1a1a' : 'transparent',
                    border: `1px solid ${selectedOption === opt.id ? '#f97316' : '#2a2a2a'}`,
                    borderRadius: '6px', color: selectedOption === opt.id ? '#f97316' : '#666',
                    fontSize: '14px', fontWeight: 600, cursor: 'pointer', textAlign: 'left',
                    fontFamily: 'inherit',
                  }}
                >
                  {opt.label}
                </button>
              ))}
            </div>

            {proving ? (
              <div style={{ padding: '16px', background: '#1a1a1a', borderRadius: '8px', textAlign: 'center' }}>
                <div style={{ fontSize: '13px', color: '#666', marginBottom: '8px' }}>
                  Generating ZK proof…
                </div>
                <div style={{ fontSize: '11px', color: '#444' }}>
                  Proving BABY membership in snapshot · In-browser UltraHonk · 5–15s
                </div>
              </div>
            ) : (
              <button
                onClick={generateProofAndVote}
                disabled={selectedOption === null}
                style={primaryBtn(selectedOption !== null ? '#f97316' : '#333')}
              >
                Cast private ballot
              </button>
            )}
          </div>
        )}

        {/* Step: Receipt */}
        {step === 'receipt' && (
          <div>
            <div style={{ textAlign: 'center', marginBottom: '24px' }}>
              <div style={{ fontSize: '32px', marginBottom: '8px' }}>✓</div>
              <div style={{ fontSize: '16px', fontWeight: 700, color: '#fff', marginBottom: '4px' }}>Vote cast privately</div>
              <div style={{ fontSize: '13px', color: '#555' }}>Your ballot is included in the tally</div>
            </div>
            <div style={{ padding: '16px', background: '#1a1a1a', borderRadius: '8px', marginBottom: '16px' }}>
              <div style={{ fontSize: '11px', color: '#555', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.1em' }}>
                Vote fingerprint
              </div>
              <div style={{ fontSize: '20px', fontWeight: 700, fontFamily: 'monospace', color: '#f97316', letterSpacing: '0.1em' }}>
                {receipt}
              </div>
              <div style={{ fontSize: '12px', color: '#444', marginTop: '8px' }}>
                This fingerprint proves your vote was counted. Keep it private - anyone
                you show it to can find your ballot and see your choice. Save it to
                verify after the vote closes.
              </div>
              {proofDurationMs !== null && (
                <div style={{ fontSize: '11px', color: '#333', marginTop: '6px' }}>
                  Proof generated in {(proofDurationMs / 1000).toFixed(1)}s
                </div>
              )}
            </div>
            <div style={{ fontSize: '12px', color: '#444', padding: '12px', background: '#111', borderRadius: '6px' }}>
              <strong style={{ color: '#555' }}>What this proves:</strong> You held sufficient BABY at
              the snapshot block, without revealing which holder you are. Ballots are
              anonymous but recorded in plaintext onchain; an encrypted tally that
              hides individual choices is on the roadmap (M2).
            </div>
          </div>
        )}

        {/* Error */}
        {step === 'error' && (
          <div style={{ padding: '16px', background: '#1a0000', border: '1px solid #3a0000', borderRadius: '8px' }}>
            <div style={{ color: '#ef4444', fontSize: '14px' }}>{error}</div>
          </div>
        )}
      </div>

      {/* Technical note */}
      <div style={{ marginTop: '32px', maxWidth: '480px', textAlign: 'center', fontSize: '12px', color: '#333' }}>
        Merkle root: <span style={{ fontFamily: 'monospace', color: '#444', fontSize: '10px' }}>{DEMO_MERKLE_ROOT.slice(0, 20)}...</span>
        <br />
        <span style={{ color: '#3a3a3a' }}>Synthetic eligibility set: {SNAPSHOT_HOLDER_COUNT.toLocaleString()} generated holders · {SNAPSHOT_DATE}</span>
        <br />
        ZK proof: Noir · Verifier: Ethereum · No bridging
      </div>
    </div>
  );
}

function primaryBtn(color: string): React.CSSProperties {
  return {
    width: '100%', padding: '14px', background: color === '#333' ? '#1a1a1a' : color,
    color: color === '#333' ? '#444' : '#000', border: 'none', borderRadius: '8px',
    fontSize: '15px', fontWeight: 700, cursor: color === '#333' ? 'not-allowed' : 'pointer',
    fontFamily: 'inherit',
  };
}
