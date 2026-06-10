/**
 * Aztec v4 wallet bootstrap for the demo.
 * All Aztec imports are dynamic to avoid type conflicts at build time.
 */

const SECRET_KEY_STORAGE = 'apv-demo-secret-v4';

function getOrCreateSecretKey(): string {
  if (typeof window === 'undefined') throw new Error('Browser only');
  const existing = window.localStorage.getItem(SECRET_KEY_STORAGE);
  if (existing) return existing;
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  const hex = '0x' + Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
  window.localStorage.setItem(SECRET_KEY_STORAGE, hex);
  return hex;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function createDemoWallet(nodeUrl: string): Promise<any> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { EmbeddedWallet } = await import('@aztec/wallets/embedded' as any);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { Fr } = await import('@aztec/aztec.js/fields' as any);

  const secretKey = Fr.fromHexString(getOrCreateSecretKey());
  const embeddedWallet = await EmbeddedWallet.create(nodeUrl, { ephemeral: true });
  const accountManager = await embeddedWallet.createSchnorrAccount(secretKey, Fr.ZERO);
  const address = accountManager.address;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return new Proxy(embeddedWallet, {
    get(target: any, prop: string) {
      if (prop === 'getAddress') return () => address;
      const val = target[prop];
      return typeof val === 'function' ? val.bind(target) : val;
    },
  });
}
