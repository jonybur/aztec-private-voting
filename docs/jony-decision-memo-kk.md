# JONY-ACTION KK — H2.3 Power Disclosure Missing from §5.2

**Generated:** tick-4236 (2026-06-29)  
**Severity:** LOW — body-text disclosure gap only; no protocol or analysis impact  
**Type:** BATCH YES — no real choice; fix is a single missing sentence  
**Script:** `scripts/apply-kk.py`

---

## The Gap

§5.2 Power paragraph (line 355) states:

> "For the primary H2.1 endpoint (Q-AC accuracy, E main effect: 50% in E2 → 70% in E1, one-tailed, α = 0.05), n = 30 per cell provides approximately **84%** power (OR ≈ 2.3; design note §10.1). N = 240 also provides approximately **80%** power for the H2.2 interaction endpoint (f ≈ 0.22; design note §10.2) and adequate headroom for a 20-25% Prolific exclusion rate without falling below 80% power for H2.1. The final power analysis will be revised using Study 1 pilot data before Study 2 pre-registration (§5.6)."

**H2.3 is entirely absent.** The three power estimates given are H2.1 (84%), H2.2 (80%), and H2.4 (implicitly covered by N=240). H2.3 — the calibration residual TOST in L2 only — is the **only underpowered endpoint** and is never mentioned in the paper body.

The tick-4130 note (in §5.5, inside a Note block) says:

> "H2.3 is the only underpowered endpoint. Design note §10.3 reports power ≈ 0.72 for d = 0.50 (α = 0.05, one-tailed; L2 n = 60). This is acknowledged as a limitation of the conditional secondary test; if underpowered, a calibration-focused Study 2b (N = 80 in L2 only) is planned."

But "acknowledged in a Note block" ≠ disclosed in the paper body. After note-stripping for CHI submission, this limitation is invisible.

---

## Why This Matters

A CHI reviewer auditing the Study 2 power analysis will find:
- H2.1: ✅ 84% power stated in §5.2
- H2.2: ✅ 80% power stated in §5.2
- H2.3: ❌ power not stated anywhere in the paper body
- H2.4: ✅ covered implicitly by N=240 framing

H2.3 is the only conditionally elevated endpoint (flagged as "key reporting focus" in the H4-supported scenario per design note §9.1). A CHI reviewer who follows the paper's contingency logic will ask: what is H2.3's power? Not finding it raises a red flag.

Also, §6.5 Statistical Power only covers Study 1's McNemar correction. There is no §6.5 paragraph disclosing Study 2 power limitations. The H2.3 gap exists in both §5.2 and §6.5.

---

## Fix (no real choice required)

**Add one sentence to §5.2 Power**, after the H2.2 sentence and before the "will be revised" sentence:

> **H2.3 (calibration residual TOST; M4 in L2 conditions only; n = 60 pooled across I levels) provides approximately 72% power for d = 0.50 (α = 0.05, one-tailed; design note §10.3) — below the 80% threshold, consistent with H2.3's status as a conditional secondary test dependent on H4 support; a calibration-focused Study 2b (L2 only, N = 80) is pre-planned if H2.3 is inconclusive.**

This is a disclosure-only fix. No protocol, analysis, or methodological change.

**Apply phrase:** `"KK: apply"`

---

## Why Batch YES (no real choice)

- Single missing sentence with no trade-off
- Content is already confirmed in design note §10.3 and tick-4130 note
- CHI risk is clear and fix is unambiguous
- No OSF amendment required (design note §10.3 already documents this; paper is just catching up)

---

## Sequence

KK does not depend on any other open JA. Can be applied in any order.

**Total open JAs after KK applied: 24 → 25 (adds KK) → 24 (clears KK immediately as batch yes).**

---

*Commit: pending apply-kk.py*
