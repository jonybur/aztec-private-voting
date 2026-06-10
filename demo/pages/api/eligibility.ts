/**
 * GET /api/eligibility?address=bbn1...
 *
 * Returns the Merkle path for a synthetic holder. The eligibility set is the
 * synthetic snapshot (scripts/synthetic-snapshot.ts) — no real Babylon Genesis
 * holders are used. The path is computed at snapshot build time and looked up
 * here server-side so we don't ship a 15 MB JSON to the browser.
 *
 * 404 if the address is not in the synthetic set.
 */

import type { NextApiRequest, NextApiResponse } from 'next';
import fs from 'node:fs';
import path from 'node:path';

interface Holder {
  address: string;
  balance: string;
  leaf: string;
  path: string[];
  indices: boolean[];
}

interface Snapshot {
  root: string;
  rootAsField: string;
  minBalance: string;
  treeDepth: number;
  treeSize: number;
  timestamp: string;
  holders: Holder[];
}

let cache: { byAddress: Map<string, Holder>; meta: Omit<Snapshot, 'holders'> } | null = null;

function loadSnapshot() {
  if (cache) return cache;
  // snapshot/ sits at the repo root, one level above demo/
  const repoRoot = path.resolve(process.cwd(), '..');
  const candidates = [
    path.join(repoRoot, 'snapshot', 'synthetic-holders.json'),
    // when next dev is launched from demo/ during tests, cwd may already be demo/
    path.join(process.cwd(), '..', 'snapshot', 'synthetic-holders.json'),
  ];
  let raw: string | null = null;
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      raw = fs.readFileSync(p, 'utf8');
      break;
    }
  }
  if (!raw) throw new Error('synthetic-holders.json missing. Run `npx tsx scripts/synthetic-snapshot.ts`.');
  const snap: Snapshot = JSON.parse(raw);
  const byAddress = new Map<string, Holder>();
  for (const h of snap.holders) byAddress.set(h.address, h);
  const { holders: _, ...meta } = snap;
  cache = { byAddress, meta };
  return cache;
}

export interface EligibilityResponse {
  address: string;
  balance: string;
  leaf: string;
  path: string[];
  indices: boolean[];
  root: string;
  rootAsField: string;
  minBalance: string;
  treeDepth: number;
}

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const address = String(req.query.address ?? '').trim();
  if (!address) return res.status(400).json({ error: 'address query param required' });
  if (!/^bbn1[a-z0-9]{38,}$/.test(address)) {
    return res.status(400).json({ error: 'address is not a bbn1 cosmos address' });
  }

  let snap: ReturnType<typeof loadSnapshot>;
  try {
    snap = loadSnapshot();
  } catch (err) {
    return res.status(503).json({
      error: 'eligibility snapshot unavailable',
      detail: err instanceof Error ? err.message : String(err),
    });
  }

  const holder = snap.byAddress.get(address);
  if (!holder) {
    return res.status(404).json({
      error: 'address not in synthetic eligibility set',
      sampleEligibleAddress: snap.byAddress.keys().next().value,
    });
  }

  const body: EligibilityResponse = {
    address: holder.address,
    balance: holder.balance,
    leaf: holder.leaf,
    path: holder.path,
    indices: holder.indices,
    root: snap.meta.root,
    rootAsField: snap.meta.rootAsField,
    minBalance: snap.meta.minBalance,
    treeDepth: snap.meta.treeDepth,
  };
  return res.status(200).json(body);
}
