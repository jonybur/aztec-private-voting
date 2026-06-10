/**
 * Babylon Genesis wallet connector — Keplr (with Leap fallback).
 *
 * Uses the raw browser injection (`window.keplr` / `window.leap`) to keep
 * bundle size minimal. The chain config below targets Babylon Genesis
 * mainnet (chain id `bbn-1`).
 *
 * `connect()` triggers the wallet popup. `disconnect()` clears local state.
 * `getAddress()` returns the bbn1 bech32 address.
 *
 * No funds are touched here. The demo only reads the address to look up its
 * Merkle path against the synthetic eligibility set.
 */

const BABYLON_CHAIN_ID = 'bbn-1';

interface CosmosKey {
  bech32Address: string;
  pubKey: Uint8Array;
}

interface CosmosWallet {
  enable: (chainId: string) => Promise<void>;
  getKey: (chainId: string) => Promise<CosmosKey>;
}

interface InjectedWindow {
  keplr?: CosmosWallet;
  leap?: CosmosWallet;
}

export type WalletKind = 'keplr' | 'leap';

export interface ConnectedWallet {
  kind: WalletKind;
  address: string;
}

function getInjected(): InjectedWindow {
  if (typeof window === 'undefined') return {};
  return window as unknown as InjectedWindow;
}

export function isWalletAvailable(): { keplr: boolean; leap: boolean } {
  const w = getInjected();
  return { keplr: !!w.keplr, leap: !!w.leap };
}

export class NoWalletInstalledError extends Error {
  constructor() {
    super('No Keplr or Leap wallet detected. Install Keplr (keplr.app) or Leap (leapwallet.io) to continue.');
    this.name = 'NoWalletInstalledError';
  }
}

export class UserRejectedError extends Error {
  constructor(message = 'Wallet connection was rejected') {
    super(message);
    this.name = 'UserRejectedError';
  }
}

/**
 * Prompt the user to connect their Babylon wallet. Tries Keplr first, then
 * falls back to Leap. Returns the bech32 address.
 */
export async function connect(): Promise<ConnectedWallet> {
  const w = getInjected();
  const choices: Array<[WalletKind, CosmosWallet | undefined]> = [
    ['keplr', w.keplr],
    ['leap', w.leap],
  ];

  const [kind, wallet] = choices.find(([, c]) => !!c) ?? [];
  if (!wallet || !kind) throw new NoWalletInstalledError();

  try {
    await wallet.enable(BABYLON_CHAIN_ID);
  } catch (err) {
    // Both Keplr and Leap throw a generic Error on user reject; surface as such.
    throw new UserRejectedError(err instanceof Error ? err.message : undefined);
  }

  const key = await wallet.getKey(BABYLON_CHAIN_ID);
  if (!key?.bech32Address?.startsWith('bbn1')) {
    throw new Error('Wallet did not return a Babylon (bbn1) address');
  }

  return { kind, address: key.bech32Address };
}

/**
 * Build a "click to install" URL for the missing wallet so the UI can show
 * an install affordance.
 */
export const WALLET_INSTALL_URLS = {
  keplr: 'https://www.keplr.app/get',
  leap: 'https://www.leapwallet.io/cosmos',
} as const;
