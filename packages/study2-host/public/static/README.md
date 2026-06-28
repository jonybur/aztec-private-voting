# static/

Place the 4 static fallback screenshots here before study launch.

These are used by the Qualtrics Stimulus block when the participant's browser
cannot render the interactive VoteReceipt prototype (§9.3 of design note;
§8 of qualtrics-setup-guide-study2-2026-06-28.md).

## Required files

| Filename            | Condition | Description                              |
|---------------------|-----------|------------------------------------------|
| fallback-L1E1.png   | L1E1      | Fingerprint label + explained framing    |
| fallback-L1E2.png   | L1E2      | Fingerprint label + unexplained framing  |
| fallback-L2E1.png   | L2E1      | Confirmation code + explained framing    |
| fallback-L2E2.png   | L2E2      | Confirmation code + unexplained framing  |

## How to generate

1. Deploy the study2-host to Vercel.
2. Open each condition URL in a browser:
   - `https://aztec-study2.vercel.app/?condition=L1E1I1`
   - `https://aztec-study2.vercel.app/?condition=L1E2I1`
   - `https://aztec-study2.vercel.app/?condition=L2E1I1`
   - `https://aztec-study2.vercel.app/?condition=L2E2I1`
3. Screenshot the VoteReceipt at the canonical viewport width (1024px × 768px).
4. Save as `fallback-L1E1.png` etc. in this directory.
5. Redeploy (`npx vercel --prod`).

The I-factor (I1/I2) does not affect the receipt appearance, so one screenshot
per L×E cell is sufficient.
