// The receipt id is a client-generated random field element. It is recorded
// by the contract and backs the verify_vote_counted receipt check. It must
// never be derived from the wallet: double voting is prevented by the
// contract's private single-use claim, not by this value.
//
// Privacy note (L1): the receipt id appears in the same public transaction as
// the vote choice, so the voter must treat it as private - sharing it reveals
// the choice. See docs/receipt.md and openspec/ROADMAP.md (M2).
export async function generateReceiptId(): Promise<bigint> {
  const { Fr } = await import('@aztec/aztec.js');
  return Fr.random().toBigInt();
}

export function fingerprintFromReceiptId(receiptId: bigint): string {
  return `0x${receiptId.toString(16).padStart(64, '0')}`;
}
