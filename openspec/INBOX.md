# Inbox

Notes from execution agents — items that can't be fixed under the standing
rules. Planning sessions clear these.

---

## 2026-06-10 11:25 UTC — openclaw / execution agent

### ✅ 1. babylon.tsx UI copy still uses L0/L2 language - RESOLVED by planning session 2026-06-11

`demo/pages/babylon.tsx` contains strings that overstate L1 privacy. Hard rule
3 says "never reword privacy or security claims" — flagging instead of
rewriting.

Specific lines (commit 4d04707):

- L154 button: "Connect Keplr / Leap wallet" — wording is fine.
- L165–166: "A ZK proof of your BABY balance is generated locally in your
  browser. Your address never leaves your device." — true at L1 modulo the
  fingerprint caveat below; arguably fine, but worth a pass.
- L226 (receipt step): "Vote cast privately" / "This fingerprint proves your
  vote was counted **without revealing your choice**." — at L1 the per-ballot
  choice IS public (anonymous plaintext); a voter who shares their fingerprint
  reveals their choice. The ROADMAP itself flags this. The string is L2
  language.
- L251 (bottom blurb): "Your address and choice are unknown to all observers.
  Only the aggregate tally will be revealed." — same problem. "Only the
  aggregate tally will be revealed" is explicitly an L2 claim; CLAUDE.md
  Frozen decisions ban it until M2 ships.

Also: the page sub-header (L122): "Prove your BABY holdings with a ZK proof.
Vote privately. No bridging." — "Vote privately" is acceptable for L1
(anonymous), but a planning-session pass should confirm the wording.

I have not edited any of these. Planning session to decide replacement copy
that matches the L1 ladder rung.

### 2. (OPEN - awaiting Jony) Babylon demo deployment — does the contract redeploy in M1 count as a "deploy"?

ROADMAP M1 task 1: "Re-deploy PrivateVoting (with cast_vote_babylon) to Aztec
testnet; update deployments/alpha-testnet.json."

Standing rule 2: "Never deploy or publish anything without an explicit
instruction from Jony in the current session."

These are in tension. My read: a testnet contract redeploy is part of M1, so
it's "already on the roadmap" and inside execution-agent scope — but it's
also irreversibly publishing a contract address to a public network and burns
testnet fees. Asking for explicit go-ahead before running
`scripts/deploy-testnet.ts` against the testnet.

Funding state of the deployer wallet, current toolchain version on disk
(/root/.aztec has v4.1.3, v4.2.0, v4.3.0-nightly.20260515; CLAUDE.md pins
v5.0.0-nightly.20260525 — not installed), and the
`AZTEC_PXE_URL`/`DEPLOYER_SECRET_KEY`/`DEPLOYER_SIGNING_KEY` secrets all
need a planning-session decision before the deploy is feasible from this
machine.

### ✅ 3. demo/lib/aztec.ts wallet adapter direction - APPROVED by planning session 2026-06-11: raw window.keplr/window.leap is the right call, keep it

M1 task: "Keplr/Leap wallet connection (currently stubbed)." Implementing
this requires picking an adapter (`@keplr-wallet/cosmos`,
`@cosmos-kit/react`, raw `window.keplr`). The choice affects bundle size and
the babylon demo's UI surface. Defaulting to raw `window.keplr` + a
`window.leap` fallback for minimum surface — flag here if planning wants a
different direction.


---

## 2026-06-11 - planning session resolution notes

- Item 1: all four flagged strings rewritten to L1 language in babylon.tsx,
  including one more the flag missed: "your address never leaves your device"
  became false once /api/eligibility was added (the connected address is sent
  to the demo server). Copy now says so.
- Item 2: stays open for Jony. Note for the deploy plan: the openclaw server
  lacks the pinned toolchain (max v4.3.0-nightly); the planning machine has
  v5.0.0-nightly.20260525 installed and the contract compiles there, so the
  redeploy will likely run from the planning side once Jony provides go-ahead
  and deployer secrets.
