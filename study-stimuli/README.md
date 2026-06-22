# PIUP Study 1 — Stimuli

Static HTML mockups for **Study 1** of the PIUP user-study protocol
([`docs/piup-study-protocol-2026-06-22.md`](../docs/piup-study-protocol-2026-06-22.md)).

**Research question addressed:** RQ1 — Which label for the receipt identifier produces the most accurate comprehension of what the identifier proves and what it does not prove?

---

## Conditions

| File | Condition | Label | Rationale |
|------|-----------|-------|-----------|
| `condition-a-fingerprint.html`       | A | **vote fingerprint**  | Current production label |
| `condition-b-confirmation-code.html` | B | **confirmation code** | eCommerce convention; familiar, implies confirmed submission |
| `condition-c-nullifier.html`         | C | **nullifier**         | Cryptographically correct term; expected worst comprehension |
| `condition-d-receipt-id.html`        | D | **receipt ID**        | Neutral control; generic, no implicit claim |

Everything else is identical across conditions: layout, privacy copy, vote title, receipt value, download button, and verification instructions. Only the identifier label and the pronoun in the "How to verify" panel differ.

---

## Design choices

- **Privacy explainer copy** (held constant): _"This receipt does not contain your vote choice. It proves your ballot was counted without revealing how you voted."_ This is taken verbatim from the study protocol to ensure the comprehension questions test label comprehension specifically, not copy comprehension.
- **Receipt value** (`0x3f7a…c9e2`): same shortened hex across all conditions. Full value is realistic (`0x3f7ac1d8e29a4b56f3c07de18b2a9f40c3e5d71b84a2f96e3c50d82b1e74c9e2`).
- **Vote scenario**: _"City Council Seat 3 — 2026 Annual Election"_ — realistic but fictional.
- **Copy + Download interactions** are functional (copy-to-clipboard, simulated download confirmation) so the UI feels real without requiring a live contract.
- **Condition watermark** (`Cond. X` badge, bottom-right) is `aria-hidden` so screen readers do not announce it to participants.

---

## Deployment

Each file is self-contained: no build step, no server, no CDN. Deploy to any static host:

```bash
# Netlify drop (drag folder to netlify.com/drop)
# GitHub Pages
# Vercel CLI
npx vercel study-stimuli/ --prod

# Or serve locally for pilot testing
npx serve study-stimuli/
# → http://localhost:3000/condition-a-fingerprint.html etc.
```

Assign one URL per condition on Prolific using the **URL parameters** feature; randomise at the block level. Recommended: use unique Prolific completion codes per condition (A → `PIUP_DONE_A`, B → `PIUP_DONE_B`, …) to verify randomisation held.

---

## What to verify before pilot

- [ ] Label text matches condition assignment exactly — do **not** edit label strings
- [ ] Privacy explainer copy matches protocol Section "Stimuli" verbatim
- [ ] Mockup loads without errors in Chrome, Firefox, and Safari
- [ ] Copy button writes the full hex value to clipboard (test with DevTools)
- [ ] "How to verify" panel expands/collapses correctly and uses condition-specific pronoun
- [ ] Condition watermark invisible in participant screenshots (small, bottom-right)

---

## Relation to production code

The same parameterisation is available in the React component via the `labelVariant` prop on `<VoteReceipt>`. See [`packages/react/src/components/VoteReceipt.tsx`](../packages/react/src/components/VoteReceipt.tsx):

```tsx
// Condition A (default / production)
<VoteReceipt receipt={r} />

// Study conditions
<VoteReceipt receipt={r} labelVariant="confirmation-code" />
<VoteReceipt receipt={r} labelVariant="nullifier" />
<VoteReceipt receipt={r} labelVariant="receipt-id" />
```

The HTML stimuli here are the canonical study artefacts. The React prop is provided for integration testing and future in-app A/B experiments.
