# study2-host

**PIUP Study 2 — VoteReceipt Prototype Host**

Minimal Vite/React app that serves the `VoteReceipt` component in `studyMode`
for embedding inside a Qualtrics Stimulus block (via `<iframe>`).

See: `docs/qualtrics-setup-guide-study2-2026-06-28.md §A` for full setup
instructions.

---

## URL parameter

```
?condition=<code>
```

| Code | L factor | E factor | I factor |
|------|----------|----------|----------|
| L1E1I1 | fingerprint | explained | control |
| L1E1I2 | fingerprint | explained | calibration |
| L1E2I1 | fingerprint | unexplained | control |
| L1E2I2 | fingerprint | unexplained | calibration |
| L2E1I1 | confirmation-code | explained | control |
| L2E1I2 | confirmation-code | explained | calibration |
| L2E2I1 | confirmation-code | unexplained | control |
| L2E2I2 | confirmation-code | unexplained | calibration |

---

## postMessage protocol

The host sends the following events to `window.parent` (Qualtrics):

| Event | Payload |
|-------|---------|
| Component rendered | `{ type: 'piup-ready' }` |
| Download button clicked | `{ type: 'piup-download-click', clicked: true }` |
| "How to verify" toggled | `{ type: 'piup-verify-expanded', expanded: boolean }` |

---

## Dev

```bash
# From repo root (workspace protocol requires monorepo context)
npm install
npm run dev --workspace=packages/study2-host
```

Or from this directory (after installing monorepo deps):

```bash
npm run dev     # http://localhost:5174/?condition=L1E1I1
npm run build   # outputs to dist/
```

---

## Deploy

```bash
npm run build
npx vercel --prod
```

Expected URL: `https://aztec-study2.vercel.app`

After deploying:
1. Test all 8 condition URLs manually.
2. Confirm `piup-ready` fires on load (DevTools → Console).
3. Generate 4 fallback screenshots → `public/static/` (see `public/static/README.md`).
4. Redeploy with screenshots included.

---

## Status

- [x] Scaffold created (tick-4066)
- [x] monorepo `npm install` verified (tick-4067: changed `workspace:*` → `*` in package.json)
- [x] Vite build passes (tick-4067: 148 KB bundle, 906ms — added `@aztec/*` rollupOptions external)
- [ ] Deployed to Vercel
- [ ] Fallback screenshots generated

### Build notes (tick-4067)

**`workspace:*` → `*`**: npm does not support pnpm's `workspace:*` protocol. Changed to `"*"` (as `demo/` does) so `npm install` resolves `@aztec-private-voting/react` via the monorepo workspace symlink.

**`@aztec/*` external**: The pre-built `react` dist contains dynamic `import("@aztec/aztec.js")` calls in hooks/context code. Rollup tries to resolve these statically and fails (non-standard exports field). Since `study2-host` only uses `VoteReceipt` (zero aztec runtime deps), all `@aztec/*`, `@noir-lang/*`, and `@noble/*` packages are marked external in `vite.config.js`. The two crypto warnings on `secp256k1-47LVE5GU.mjs` are benign — that module is dead code at runtime.
