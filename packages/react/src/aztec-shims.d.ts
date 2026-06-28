/**
 * Ambient module shims for @aztec/* packages.
 *
 * These packages are NOT installed in this workspace — they are only used at
 * runtime inside the demo app where the full Aztec SDK is available.
 * These shims allow `tsc --emitDeclarationOnly` and `tsup --dts` to succeed
 * without the Aztec SDK present, so the package can publish usable type
 * declarations for the UI components (VoteReceipt etc.) that don't depend on
 * Aztec at all.
 *
 * Added tick-4065: previously the DTS build was failing, leaving no
 * dist/index.d.ts, which required tsbuildinfo to be present for the demo
 * typecheck to pass.
 */

/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * Permissive shims: declare the Aztec modules as 'any'-typed namespaces.
 * Every named import from these modules resolves to `any`.
 */

// Using `export * from ...` equivalent: module augmentation that re-exports as namespace.
// The simplest form that TypeScript accepts for "any named import is fine":
declare module '@aztec/aztec.js' {
  // Explicitly declare every name used in src/aztec/* so TS is satisfied.
  export type AccountWalletWithSecretKey = any;
  export declare const AccountWalletWithSecretKey: any;
  export type PXE = any;
  export declare const PXE: any;
  export declare function createPXEClient(...args: any[]): any;
  export declare function waitForPXE(...args: any[]): any;
  export type Fr = any;
  export declare const Fr: any;
  export type AztecAddress = any;
  export declare const AztecAddress: any;
  export type Contract = any;
  export declare const Contract: any;
  export declare function computeNullifierSecretKey(...args: any[]): any;
  export declare function computeSecretHash(...args: any[]): any;
  export type TxHash = any;
  export declare const TxHash: any;
  export declare const GrumpkinScalar: any;
  export type GrumpkinScalar = any;
  // Generic fallback via namespace:
  namespace _Fallback { export const _: any; }
}

declare module '@aztec/foundation/crypto' {
  export type Fr = any;
  export declare const Fr: any;
  export declare function poseidon2Hash(...args: any[]): any;
  export declare function sha256(...args: any[]): any;
}
