# CHI Paper §3.3 — N-F4 Resolved Finding Proposal

**Tick:** 4199  
**Status:** JONY-REVIEW — ready to apply (no new JONY-ACTION opened)  
**CHI risk if omitted:** LOW-MODERATE  
**Proposed change:** Add N-F4 as a fourth resolved finding in §3.3  

---

## Background

Flagged as INFO item 11 at tick-4193. The `main.nr` constructor contains a guard
explicitly labelled `// Security hardening (N-F4)` (lines 75–83):

```nr
// Security hardening (N-F4): in TOKEN mode a zero min_token_balance would
// admit every address in the snapshot (balance >= 0 is always true).
// Enforce a positive threshold at deploy time so the deployer cannot
// accidentally create an open vote while intending token gating.
if config.eligibility_mode == ELIGIBILITY_MODE_TOKEN {
    assert(
        config.min_token_balance > 0,
        "token mode: min_token_balance must be > 0",
    );
}
```

The paper's §3.3 resolved findings list currently reads:

> Three findings were resolved before the study - one HIGH severity and two LOW:
> F1-RESIDUAL ... F2 ... F3 ...

N-F4 is **absent from the paper** despite being explicitly named in code.  
A CHI reviewer browsing the annotated source will see `(N-F4)` with no §3.3 counterpart.

---

## Code verification (tick-4199)

- **File:** `contracts/src/main.nr`, lines 75–83  
- **Guard:** conditional on `ELIGIBILITY_MODE_TOKEN`; fires only when deployer sets `eligibility_mode = TOKEN`  
- **Failure mode if guard absent:** `min_token_balance = 0` → `token_balance >= 0` is vacuously true for every address in the snapshot → token gate admits everyone → gated vote behaves as open vote  
- **Severity:** INFORMATIONAL (deployment-configuration error class, not a protocol invariant; only triggered by a misconfigured VoteConfig at deploy time)  
- **Open/Allowlist modes:** unaffected (`min_token_balance` is unused in those modes)  

---

## Proposed text additions

### 1. Update preamble sentence (line ~195)

**Current:**
> Three findings were resolved before the study - one HIGH severity and two LOW:

**Proposed:**
> Four findings were resolved before the study - one HIGH severity, two LOW, and one INFORMATIONAL:

### 2. Add N-F4 bullet after F3 (after line ~201)

Insert immediately after the F3 paragraph:

---

*N-F4 (INFORMATIONAL — TOKEN mode minimum balance guard).* In TOKEN eligibility mode, a deployer could configure `min_token_balance = 0`, causing the balance check (`token_balance >= min_token_balance`) to be vacuously satisfied for every address in the eligibility snapshot regardless of actual holdings — admitting all snapshot addresses rather than only those meeting the intended threshold. This is a deployment-configuration error class rather than a protocol-level invariant violation: a correctly configured deployment is unaffected. Resolved by adding a conditional guard in the constructor: for `ELIGIBILITY_MODE_TOKEN` deployments, `assert(config.min_token_balance > 0)` enforces a positive threshold at deploy time. OPEN and ALLOWLIST mode deployments are unaffected; `min_token_balance` is unused in those modes. [Added tick-4199.]

---

## Insertion point

After F3 paragraph (approximately line 202 in the current draft), before:
> Two design limitations are documented and not resolved at the prototype stage:

---

## Jony's options

**(a) Apply [RECOMMENDED]** — insert preamble update + N-F4 bullet. Closes the code/paper gap. No new citation needed.

**(b) Reject** — §3.3 N-F4 omission acceptable; code comment stands without paper counterpart. Accept CHI risk LOW-MODERATE.

**(c) Rename in code** — Remove `(N-F4)` label from code comment to eliminate the cross-reference expectation. Trivial code commit; no paper change needed. Less transparent.

---

## Notes

- No new JONY-ACTION opened (22 already open: I, G, A, B, C, O, P, Q, R, S, T, U, W, Y, Z, AA, BB, DD, EE, FF, GG, HH). If Jony confirms option (a), no JONY-ACTION to close — direct apply.  
- No commit this tick — proposal only.  
- CHI risk LOW-MODERATE: the word `(N-F4)` in code is a documentation annotation, not a theorem. A reviewer may or may not check constructor code. Risk is real but not critical-path.
