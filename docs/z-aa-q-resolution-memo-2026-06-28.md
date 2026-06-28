# Z/AA/Q Resolution Memo — §1.1 trio sentence revision (tick-4144, 2026-06-28)

## Summary

**JONY-ACTION Z option (a2) resolves three open JONY-ACTIONs simultaneously: Z, AA, and Q.**

One sentence change in §1.1 fixes all three. No other changes required to resolve the §1.1 trio issues.

---

## The three open JONY-ACTIONs at §1.1

### JONY-ACTION Q (tick-4114)
- **Issue:** E&S (2013) is labelled "framework for security warnings" in the §1.1 trio sentence.
- **Verdict:** INACCURATE. E&S (2013) is an empirical laboratory study of phishing warning compliance (FC 2013, LNCS 7859 pp. 52–59: "We performed a laboratory study to investigate how the choice of background color in the warning and the text describing the recommended course of action impact a user's decision to comply with the warning."). It proposes no framework.

### JONY-ACTION Z (tick-4141)
- **Issue:** The §1.1 "consistent finding" sentence attributes the absence-as-error mechanism to Felt et al. (2012).
- **Verdict:** PRECISION ERROR. Felt et al. (2012) studied Android permission warnings — indicators that ARE PRESENT during app installation. Their failure mode is non-attention (83% of users ignored PRESENT warnings) and low comprehension (3% correct comprehension), not absence-as-error inference. The claimed "consistent finding" is false for Felt et al. (2012).

### JONY-ACTION AA (tick-4142)
- **Issue:** The same "consistent finding" sentence attributes the absence-as-error mechanism to E&S (2013).
- **Verdict:** PRECISION ERROR. E&S (2013) studied users encountering the unexpected PRESENCE of a browser phishing warning. Their failure mode is bounded rationality / threat-model mismatch: participants "made conscientious decisions to ignore the warnings" because "misunderstandings about the threat model led participants to believe that the warnings did not apply to them." This is categorically different from absent-content → error-attribution.

**§1.1 trio precision table (established ticks 4140–4142):**

| Citation | Indicator state | Actual failure mode | Supports "absence as error"? |
|----------|----------------|---------------------|------------------------------|
| W&T (1999) | ABSENT (no PGP encryption confirmation) | Error-attribution: users concluded the system failed | ✅ YES |
| Felt et al. (2012) | PRESENT (Android permission dialog shown) | Non-attention: 83% ignored the present warning | ❌ NO |
| E&S (2013) | PRESENT (phishing warning shown) | Threat-model dismissal: warning dismissed as inapplicable | ❌ NO |

Only W&T (1999) directly supports the "absence as error" claim. Both supporting citations are broken.

---

## The current §1.1 sentence (with accumulated notes)

> "Across usability-security research from Whitten and Tygar's foundational evaluation of PGP (1999) through Felt et al.'s work on Android permissions (2012) to Egelman and Schechter's **framework** for security warnings (2013), a **consistent finding** emerges: users interpret interface absence as system error unless the absence is explicitly marked as intentional."

Problems:
1. "framework" for E&S → wrong (Q)
2. "consistent finding" with Felt et al. → wrong mechanism (Z)
3. "consistent finding" with E&S → wrong mechanism (AA)

---

## Z option (a2) — the single fix that resolves all three

**Proposed replacement sentence:**

> "Usability-security research documents multiple failure modes when users encounter unexpected security interface states: inferring system failure from absent confirmation [Whitten and Tygar 1999], ignoring present permission warnings [Felt et al. 2012], and dismissing warnings as inapplicable [Egelman and Schechter 2013]. In the receipt context, the operative failure mode is the first."

**Why this resolves all three:**

| Action | Problem in original | Resolution in revised sentence |
|--------|--------------------|---------------------------------|
| Q | E&S labelled "framework" | Revised sentence names E&S by authors + year only; "framework" label disappears entirely |
| Z | Felt et al. (2012) attributed "absence as error" | Revised sentence names Felt et al.'s actual mechanism: "ignoring present permission warnings" |
| AA | E&S (2013) attributed "absence as error" | Revised sentence names E&S's actual mechanism: "dismissing warnings as inapplicable" |

**Precision checks on the revised sentence:**

- W&T (1999): "inferring system failure from absent confirmation" → ✅ exact match to PGP absent-confirmation → error-attribution finding (confirmed ticks 4115, 4116, 4140)
- Felt et al. (2012): "ignoring present permission warnings" → ✅ exact match: 83% of participants ignored the present Android permission dialog (confirmed tick 4141, UCB/EECS-2012-26 + ACM DL)
- E&S (2013): "dismissing warnings as inapplicable" → ✅ exact match to E&S's "misunderstandings about the threat model led participants to believe that the warnings did not apply to them" (confirmed ticks 4113, 4117, 4118, 4119, 4142)
- "In the receipt context, the operative failure mode is the first" → ✅ correctly isolates W&T as the applicable prior work; does not overstate the scope of the Felt et al. or E&S findings

---

## What Z option (a2) does NOT resolve

The E&S precision issue extends beyond §1.1. These sites still require separate fixes, even after applying Z(a2) to §1.1:

| JONY-ACTION | Site | Issue | Status |
|-------------|------|-------|--------|
| P (tick-4113) | §6.1 | E&S cited for "error-attribution" mechanism (W&T's mechanism, not E&S's) | Open — separate §6.1 edit required |
| R (tick-4118) | §2.2 Alt3 | E&S co-cited for "absent-content interpretation → failure" (E&S studied present-content) | Open — separate §2.2 edit required |
| S (tick-4119) | §2.1 | E&S co-cited for "absent confirmation content: error, incomplete transaction, untrustworthy system" (E&S mechanism doesn't match any of the three) | Open — separate §2.1 edit required |

Applying Z(a2) to §1.1 is **scoped to §1.1 only** and does not cascade to fix P/R/S. Each of those sites still requires the individual edit recommended in their respective JONY-ACTION notes.

---

## Recommendation to Jony

**Confirm option Z(a2) for the §1.1 trio sentence.** This is the lowest-risk path:

1. Single sentence swap — no multi-site cascade, no citation removals
2. Retains all three citations (W&T, Felt et al., E&S) — no loss of coverage or depth
3. Accurately characterizes each paper's actual contribution — no mechanism mismatch for a CHI reviewer who knows any of the three papers
4. "In the receipt context, the operative failure mode is the first" — cleanly connects the trio to the paper's central problem without overclaiming a "consistent finding" that does not exist

**After confirming Z(a2):** JONY-ACTIONs Z, AA, and Q are resolved with one commit to §1.1. Open count drops from 17 to 14.

**Still open and requiring separate Jony decisions:** I, G, A, B, C, O, P, R, S, T, U, W, X, Y + Kulyk/Nissen citation (VON-530).

---

*Memo written tick-4144. No code change needed — this is a recommendation memo. Paper edit goes in on Jony's confirm.*
