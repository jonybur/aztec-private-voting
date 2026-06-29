# CHI Paper §1.1 Trio Sentence — JONY-ACTIONS Z, AA, Q
## Proposal doc · tick-4203 (2026-06-29)

**Status:** Awaiting Jony decision — 3 options below. Agent recommends Option A.  
**Resolves:** JONY-ACTION Z (Felt 2012 mechanism), JONY-ACTION AA (E&S 2013 mechanism), JONY-ACTION Q (E&S "framework" label)  
**Commit scope:** §1.1 only. Does NOT cascade to §2.1 (S), §2.2 (R), or §6.1 (P) — those have separate proposals.

---

## Current text (paper draft line 49)

> "Across usability-security research from Whitten and Tygar's foundational evaluation of PGP (1999) through Felt et al.'s work on Android permissions (2012) to Egelman and Schechter's **framework** for security warnings (2013), a **consistent finding** emerges: users interpret interface absence as system error unless the absence is explicitly marked as intentional."

---

## Why all three citations are broken here

| Citation | Indicator state | Actual failure mode | Supports "absence as error"? |
|----------|----------------|---------------------|------------------------------|
| W&T (1999) | ABSENT (no PGP encryption confirmation) | Error-attribution: users conclude the system failed | ✅ YES — precise support |
| Felt et al. (2012) | PRESENT (Android permission dialog IS shown) | Non-attention: 83% ignored the PRESENT warning | ❌ NO — mechanism mismatch |
| E&S (2013) | PRESENT (phishing warning IS shown) | Threat-model dismissal: warning dismissed as "inapplicable to me" | ❌ NO — mechanism mismatch |

**Problems:**
- **JONY-ACTION Z** (tick-4141): Felt et al. (2012) are attributed with "absence as error." They never studied absent indicators. Their failure mode is non-attention and low comprehension of PRESENT warnings (83% ignored the present Android dialog; 3% correct comprehension). This is categorically different from W&T's error-attribution mechanism.
- **JONY-ACTION AA** (tick-4142): E&S (2013) are attributed with the same "consistent finding." E&S studied users encountering the unexpected PRESENCE of a phishing warning. Their failure mode is bounded rationality / threat-model mismatch — participants made conscientious decisions to ignore warnings because "misunderstandings about the threat model led participants to believe that the warnings did not apply to them." Not absence; not error-attribution.
- **JONY-ACTION Q** (tick-4114): E&S (2013) is labelled "framework for security warnings" — WRONG. E&S (2013) is an empirical laboratory study of phishing warning compliance (Springer LNCS 7859, FC 2013). It proposes no framework.

---

## Option A — Mechanism-naming revision [RECOMMENDED]

**Resolves Z + AA + Q simultaneously. One commit. Retains all three citations.**

Replace the existing sentence with two sentences:

> "Usability-security research documents multiple failure modes when users encounter unexpected security interface states: inferring system failure from absent confirmation [Whitten and Tygar 1999], ignoring present permission warnings [Felt et al. 2012], and dismissing warnings as inapplicable [Egelman and Schechter 2013]. In the receipt context, the operative failure mode is the first."

**Precision check:**
- W&T (1999): "inferring system failure from absent confirmation" ✅ exact match — PGP absent confirmation → error-attribution (confirmed ticks 4115/4116/4140)
- Felt et al. (2012): "ignoring present permission warnings" ✅ exact match — 83% ignored present Android dialog (confirmed tick-4141, UCB/EECS-2012-26 + ACM DL)
- E&S (2013): "dismissing warnings as inapplicable" ✅ exact match — "warnings did not apply to them; acting out of bounded rationality, participants made conscientious decisions to ignore the warnings" (confirmed ticks 4113/4117/4118/4142)
- "In the receipt context, the operative failure mode is the first" ✅ correctly isolates W&T as the applicable prior work without overclaiming a "consistent finding" that does not exist

**Why recommended:**
- Keeps all three citations — no citation removal, no citation research required
- Accurately characterizes each paper — zero CHI reviewer risk for anyone who knows any of the three
- Resolves three JONY-ACTIONs with one sentence change
- "In the receipt context, the operative failure mode is the first" is a stronger argumentative move than the current sentence: it positions W&T as precise prior art while showing awareness of the broader failure-mode landscape

**Jony action:** Reply "Z/AA/Q: Option A" — agent will commit the two-sentence replacement to §1.1 and close Z, AA, Q.

---

## Option B — W&T solo, drop Felt and E&S from trio [minimal citation]

**Resolves Z + AA + Q. One commit. Simplest possible fix.**

Replace the existing sentence with:

> "Whitten and Tygar's foundational usability evaluation of PGP (1999) established the operative failure mode for absent-confirmation interfaces: users interpret interface absence as system error unless the absence is explicitly marked as intentional."

**Precision check:**
- W&T (1999): sole citation — ✅ direct, precise, unambiguous support
- No "consistent finding" claim — ✅ avoids the accuracy problem entirely
- "absent-confirmation interfaces" — ✅ scopes the claim correctly to W&T's domain
- Felt et al. remains at §6.1 (HTTPS lock icon paragraph, line 419 — different claim). E&S remains at §2.1/§2.2/§6.1 (separate proposals P/R/S)

**Trade-offs:**
- Loses the comparative breadth of the three-paper arc — CHI reviewers who expect an intro to survey the field may notice the shorter opener
- However, a W&T-solo opening with the addition "established the operative failure mode" is more forceful than the current hedged "consistent finding emerges"
- The subsequent §1.2 paragraph provides field context; §1.1 solo W&T is defensible

**Jony action:** Reply "Z/AA/Q: Option B" — agent will commit single-sentence W&T replacement and close Z, AA, Q.

---

## Option C — Drop Felt et al., replace E&S with verified absent-indicator citation [replacement]

**Resolves Z + Q. Partially resolves AA (replaces E&S rather than removing). Requires citation verification step.**

Replace the existing sentence with:

> "Across usability-security research, from Whitten and Tygar's foundational evaluation of PGP (1999) to [VERIFIED REPLACEMENT], a consistent finding emerges: users interpret interface absence as system error unless the absence is explicitly marked as intentional."

**Candidate replacement citations** (require verification before applying — agent has not confirmed these):
- Sunshine et al. (2009) "Crying Wolf: An Empirical Study of SSL Warning Effectiveness" (USENIX Security 2009) — potential: studied SSL warning bypass, may document absent-expected-signal → error
- Akhawe & Felt (2013) "Alice in Warningland: A Large-Scale Field Study of Browser Security Warning Effectiveness" (USENIX Security 2013) — potential: large-scale real-world study of warning response

**Status:** Candidates proposed but NOT verified as supporting "absent indicator → error-attribution" mechanism. Option C requires one additional verification tick before the commit can go in.

**Jony action:** Reply "Z/AA/Q: Option C, verify Sunshine/Akhawe-Felt first" — agent will run a citation verification tick, then draft the replacement sentence.

---

## Summary comparison

| Option | Citations retained | Resolves Z/AA/Q | Requires additional work | CHI risk |
|--------|--------------------|-----------------|--------------------------|----------|
| **A** [RECOMMENDED] | W&T + Felt + E&S | All three ✅ | None — ready to commit | Lowest — each paper accurately characterized |
| **B** | W&T only | All three ✅ | None — ready to commit | Low — W&T precise; loses comparative breadth |
| **C** | W&T + replacement(s) | Z ✅, Q ✅, AA partial | Citation verification tick needed | Medium — replacement citations unverified |

**Agent recommendation: Option A.** One commit, all three JAs closed, no citation loss, highest precision for CHI reviewers.

---

## What happens after this tick

- After Jony confirms Option A or B: agent commits §1.1 change, closes Z, AA, Q. Open JA count: 24 → 21.
- §2.1 (S), §2.2 (R), §6.1 (P) are NOT touched by this commit — each has its own batch-memo entry.
- If Option A: "In the receipt context, the operative failure mode is the first." creates a cross-reference opportunity in §1.2 (no change required — §1.2 already grounds the PIUP design response in the W&T failure mode).

---

*Written tick-4203. No code change — awaiting Jony decision. Prior analysis: tick-4141 (Z), tick-4142 (AA), tick-4114 (Q), tick-4144 (Z/AA/Q joint memo at docs/z-aa-q-resolution-memo-2026-06-28.md).*
