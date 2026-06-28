#!/usr/bin/env node
/**
 * generate-fallback-screenshots.js
 *
 * Generates the 4 static fallback screenshots for the PIUP Study 2
 * Qualtrics Stimulus block (§9.3 of design note).
 *
 * Requires Playwright with a Chromium browser. Install in this package:
 *   npm install --save-dev playwright
 *   npx playwright install chromium
 *
 * Usage:
 *   node scripts/generate-fallback-screenshots.js [baseUrl]
 *
 *   baseUrl  Base URL of the running study2-host dev or prod server.
 *            Defaults to http://localhost:5174 (Vite dev server).
 *            Pass the deployed Vercel URL after production deploy:
 *              node scripts/generate-fallback-screenshots.js https://aztec-study2.vercel.app
 *
 * Output:
 *   public/static/fallback-L1E1.png  — fingerprint + explained
 *   public/static/fallback-L1E2.png  — fingerprint + unexplained
 *   public/static/fallback-L2E1.png  — confirmation-code + explained
 *   public/static/fallback-L2E2.png  — confirmation-code + unexplained
 *
 * These 4 files are served by Vercel at:
 *   https://aztec-study2.vercel.app/static/fallback-<LxEx>.png
 * which matches the Qualtrics Stimulus block fallback image src.
 *
 * After running this script, redeploy to Vercel:
 *   npm run build && npx vercel --prod
 *
 * Viewport: 1024×768 (canonical; matches study protocol §A.2 screenshot spec).
 * Wait: script waits for the `piup-ready` postMessage from the component,
 * with a 10-second timeout to catch rendering failures early.
 *
 * See: docs/qualtrics-setup-guide-study2-2026-06-28.md §A + public/static/README.md
 */

'use strict';

const path = require('path');
const fs   = require('fs');

// ── Configuration ────────────────────────────────────────────────────────────

const BASE_URL = process.argv[2] || 'http://localhost:5174';

// The 4 L×E cells (I-factor is handled entirely in Qualtrics; only 4 distinct
// prototype variants exist — one per L×E combination).
const CONDITIONS = [
  { code: 'L1E1I1', filename: 'fallback-L1E1.png', desc: 'fingerprint + explained'        },
  { code: 'L1E2I1', filename: 'fallback-L1E2.png', desc: 'fingerprint + unexplained'      },
  { code: 'L2E1I1', filename: 'fallback-L2E1.png', desc: 'confirmation-code + explained'  },
  { code: 'L2E2I1', filename: 'fallback-L2E2.png', desc: 'confirmation-code + unexplained'},
];

// Viewport: 1024×768 (canonical study spec). The VoteReceipt renders at max
// 640px wide centered in the viewport, so 1024px gives appropriate padding.
const VIEWPORT = { width: 1024, height: 768 };

// How long to wait for piup-ready (ms). 10s allows for cold Vercel starts.
const READY_TIMEOUT_MS = 10_000;

// Output directory (relative to this script's location → packages/study2-host/)
const OUT_DIR = path.resolve(__dirname, '..', 'public', 'static');

// ── Main ─────────────────────────────────────────────────────────────────────

async function run() {
  let playwright;
  try {
    playwright = require('playwright');
  } catch (e) {
    console.error('\n❌  Playwright not found. Install it first:\n');
    console.error('   npm install --save-dev playwright');
    console.error('   npx playwright install chromium\n');
    process.exit(1);
  }

  fs.mkdirSync(OUT_DIR, { recursive: true });

  console.log(`\n📸  generate-fallback-screenshots.js`);
  console.log(`    Base URL:  ${BASE_URL}`);
  console.log(`    Viewport:  ${VIEWPORT.width}×${VIEWPORT.height}`);
  console.log(`    Output:    ${OUT_DIR}\n`);

  const browser = await playwright.chromium.launch({ headless: true });
  const results  = [];

  for (const cond of CONDITIONS) {
    const url    = `${BASE_URL}/?condition=${cond.code}`;
    const outPath = path.join(OUT_DIR, cond.filename);

    process.stdout.write(`  [${cond.code}] ${cond.desc} … `);

    try {
      const context = await browser.newContext({ viewport: VIEWPORT });
      const page    = await context.newPage();

      // Listen for the piup-ready postMessage from the prototype.
      // Playwright captures messages via page.evaluate + window.addEventListener.
      const readyPromise = page.evaluate((timeoutMs) => {
        return new Promise((resolve, reject) => {
          const t = setTimeout(() => reject(new Error('piup-ready timeout')), timeoutMs);
          window.addEventListener('message', function handler(evt) {
            if (evt.data && evt.data.type === 'piup-ready') {
              clearTimeout(t);
              window.removeEventListener('message', handler);
              resolve(true);
            }
          });
        });
      }, READY_TIMEOUT_MS).catch(() => null);

      // Navigate to the condition URL.
      await page.goto(url, { waitUntil: 'domcontentloaded' });

      // Since study2-host is NOT embedded in an iframe here (we're opening it
      // directly), piup-ready fires via window.parent?.postMessage(…, '*').
      // window.parent === window when there's no iframe, so the message IS
      // dispatched to window itself. However, page.evaluate runs in the page
      // context, so the listener above fires correctly.
      //
      // Fallback: also wait for the VoteReceipt container element to appear,
      // ensuring the React tree has hydrated even if postMessage timing varies.
      const readyOrElement = await Promise.race([
        readyPromise,
        page.waitForSelector('[data-testid="vote-receipt"], .vote-receipt, #root > div', {
          timeout: READY_TIMEOUT_MS,
        }).catch(() => null),
        new Promise(resolve => setTimeout(resolve, READY_TIMEOUT_MS, 'timeout')),
      ]);

      if (readyOrElement === 'timeout') {
        console.log('⚠️  timeout (screenshot taken anyway)');
      } else {
        // Extra 200ms for CSS transitions / icon loading.
        await page.waitForTimeout(200);
        console.log('✅');
      }

      await page.screenshot({ path: outPath, fullPage: false });
      await context.close();

      results.push({ code: cond.code, file: outPath, ok: true });
    } catch (err) {
      console.log(`❌  ${err.message}`);
      results.push({ code: cond.code, file: outPath, ok: false, err: err.message });
    }
  }

  await browser.close();

  // ── Summary ──────────────────────────────────────────────────────────────
  console.log('\n── Summary ─────────────────────────────────────────────────────────\n');
  const passed = results.filter(r => r.ok).length;
  for (const r of results) {
    const icon = r.ok ? '✅' : '❌';
    console.log(`  ${icon}  ${r.code} → ${path.relative(process.cwd(), r.file)}`);
    if (!r.ok) console.log(`       Error: ${r.err}`);
  }
  console.log(`\n  ${passed} / ${results.length} screenshots generated.`);

  if (passed === results.length) {
    console.log('\n  ✅  All done. Next steps:');
    console.log('       npm run build');
    console.log('       npx vercel --prod\n');
  } else {
    console.log('\n  ⚠️  Some screenshots failed. Check the errors above.');
    console.log('     If the dev server is not running, start it first:');
    console.log('       npm run dev  (from repo root with --workspace=packages/study2-host)\n');
    process.exit(1);
  }
}

run().catch(err => {
  console.error('\n❌  Unexpected error:', err.message);
  process.exit(1);
});
