/**
 * Stub module for @aztec/aztec.js in vitest.
 *
 * The installed @aztec/aztec.js package has no root "." export (only
 * sub-path exports like ./abi, ./account, etc.), so vite fails to resolve
 * any dynamic `import('@aztec/aztec.js')` during module-graph scanning —
 * even when those imports are never actually executed in the test.
 *
 * This stub is aliased to @aztec/aztec.js via vitest.config.ts so the
 * resolver has something to land on. All exports are lightweight stubs;
 * tests that exercise real Aztec SDK calls should use vi.mock to override
 * specific functions.
 *
 * Added tick-4255: fixes receipt-id.test.ts and PrivateBallot.test.tsx
 * failing with "Missing '.' specifier in '@aztec/aztec.js' package".
 */

/* eslint-disable @typescript-eslint/no-explicit-any */

export const Fr = {
  random: () => ({ toBigInt: () => BigInt(Math.floor(Math.random() * 1e15)) }),
  fromString: (s: string) => ({ toBigInt: () => BigInt(s) }),
  fromBuffer: (_b: any) => ({ toBigInt: () => 0n }),
  ZERO: { toBigInt: () => 0n },
};

export const AztecAddress = {
  fromString: (s: string) => s,
  ZERO: '0x0000000000000000000000000000000000000000000000000000000000000000',
};

export const Contract = {
  at: async (_address: any, _artifact: any, _wallet: any) => ({}),
};

export const GrumpkinScalar = {
  random: () => ({ toString: () => '0x0' }),
};

export const TxHash = {
  fromString: (s: string) => s,
};

export function createPXEClient(_url: string): any {
  return {};
}

export async function waitForPXE(_pxe: any): Promise<void> {
  return;
}

export function computeNullifierSecretKey(_key: any): any {
  return {};
}

export function computeSecretHash(_key: any): any {
  return {};
}

export type AccountWalletWithSecretKey = any;
export type PXE = any;
