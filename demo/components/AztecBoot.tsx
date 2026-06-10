import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import {
  AztecProvider,
  useBrowserAztecClient,
  setPrivateVotingArtifact,
} from '@aztec-private-voting/react';
import type { ContractArtifact } from '@aztec/aztec.js/abi';

import { createDemoWallet } from '../lib/aztec';

interface AztecBootProps {
  children: ReactNode;
}

export function AztecBoot({ children }: AztecBootProps): JSX.Element {
  const [artifactReady, setArtifactReady] = useState(false);
  const [artifactError, setArtifactError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const load = async (): Promise<void> => {
      try {
        const res = await fetch('/private_voting-PrivateVoting.json');
        if (!res.ok) throw new Error(`Failed to fetch artifact: ${res.status}`);
        const raw = await res.json();
        const { loadContractArtifact } = await import('@aztec/aztec.js/abi');
        const artifact = loadContractArtifact(raw);
        setPrivateVotingArtifact(artifact);
        if (!cancelled) setArtifactReady(true);
      } catch (err) {
        if (!cancelled) {
          setArtifactError(
            err instanceof Error
              ? err.message
              : 'Could not load contract artifact.',
          );
        }
      }
    };
    void load();
    return () => { cancelled = true; };
  }, []);

  const nodeUrl = process.env.NEXT_PUBLIC_AZTEC_NODE_URL;
  if (!nodeUrl) {
    return (
      <div className="boot-error">
        Missing NEXT_PUBLIC_AZTEC_NODE_URL - copy .env.example to .env.local.
      </div>
    );
  }

  if (artifactError) {
    return <div className="boot-error">{artifactError}</div>;
  }

  if (!artifactReady) {
    return <div className="boot-loading">Loading contract artifact...</div>;
  }

  return <ConnectedProvider nodeUrl={nodeUrl}>{children}</ConnectedProvider>;
}

function ConnectedProvider({
  nodeUrl,
  children,
}: {
  nodeUrl: string;
  children: ReactNode;
}): JSX.Element {
  const state = useBrowserAztecClient({ nodeUrl, createWallet: createDemoWallet });
  return (
    <AztecProvider client={state.client} loading={state.loading} error={state.error}>
      {state.loading ? (
        <div className="boot-loading">Connecting to Aztec...</div>
      ) : state.error ? (
        <div className="boot-error">Aztec connection failed: {state.error}</div>
      ) : (
        children
      )}
    </AztecProvider>
  );
}
