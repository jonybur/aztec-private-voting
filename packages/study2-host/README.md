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
- [ ] monorepo `npm install` verified
- [ ] Vite build passes
- [ ] Deployed to Vercel
- [ ] Fallback screenshots generated
