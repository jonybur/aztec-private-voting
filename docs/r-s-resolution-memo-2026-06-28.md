# JONY-ACTIONS R and S — Combined Resolution Memo
_Generated tick-4146. Both actions are resolved by one decision: remove E&S (2013) from the two absent-content co-citations (§2.2 and §2.1). Two edits, one confirmation needed._

---

## Background: the shared underlying finding

E&S (2013) = Egelman & Schechter, "The Importance of Being Earnest [In Security Warnings]," FC 2013, LNCS 7859.

**E&S actual finding (confirmed from Springer abstract, ticks 4113/4117/4118/4119):**
> "Misunderstandings about the threat model led participants to believe that the warnings did not apply to them. Acting out of bounded rationality, participants made conscientious decisions to ignore the warnings."

E&S studied users encountering the **unexpected PRESENCE** of a phishing warning in their browser. The failure mode is **threat-model dismissal**: users saw a warning, decided it didn't apply to them, and bypassed it consciously.

This is categorically different from **absent-content → error inference** (W&T 1999). W&T users faced the *absence* of expected PGP output and concluded the system had failed. E&S users faced the *presence* of unexpected browser copy and concluded it was inapplicable.

---

## JONY-ACTION R — §2.2 line 146

**Current text (bold = the broken part):**
> Prior work on absent-content interpretation **[Egelman and Schechter 2013; Whitten and Tygar 1999] consistently finds** that users interpret absent expected content as failure unless absence is explicitly marked as intentional.

**Problem:**
- E&S studied PRESENT-warning dismissal, not absent-content inference.
- "Consistently finds" implies both papers document the same absent-content pattern — they do not.
- W&T (1999) ✅ directly supports this claim (PGP users → absent encryption confirmation → concluded system failed).
- E&S (2013) ❌ does not support this claim (phishing warning was present; users dismissed it as inapplicable).

**Option (a) [RECOMMENDED] — Apply:**
> Prior work on absent-content interpretation [Whitten and Tygar 1999] finds that users interpret absent expected content as failure unless absence is explicitly marked as intentional.

Two changes: (1) remove `Egelman and Schechter 2013; `, (2) remove `consistently` (single-paper citation does not need "consistently").

---

## JONY-ACTION S — §2.1 line 134

**Current text (bold = the broken part):**
> Without this component, users apply the default interpretation for absent confirmation content: error, incomplete transaction, or untrustworthy system **[Egelman and Schechter 2013; Whitten and Tygar 1999]**.

**Problem:**
- E&S users did **not** interpret anything as "error, incomplete transaction, or untrustworthy system."
- They concluded the phishing warning "did not apply to them" — a very different response.
- W&T (1999) ✅ directly supports all three interpretations (PGP users → concluded operation failed / system error).
- E&S (2013) ❌ does not — their users made a threat-model judgment, not a system-failure inference.

**Option (a) [RECOMMENDED] — Apply:**
> Without this component, users apply the default interpretation for absent confirmation content: error, incomplete transaction, or untrustworthy system [Whitten and Tygar 1999].

One change: remove `Egelman and Schechter 2013; ` from the citation bracket.

---

## Symmetry table

| Site | Current citation | What E&S actually found | Fit? | Recommended fix |
|------|-----------------|------------------------|------|----------------|
| §2.2 line 146 | E&S + W&T co-cite for "absent-content → failure" | PRESENT warning → threat-model dismissal | ❌ JONY-ACTION R | Remove E&S; retain W&T |
| §2.1 line 134 | E&S + W&T co-cite for "error / incomplete / untrustworthy" | PRESENT warning → threat-model dismissal | ❌ JONY-ACTION S | Remove E&S; retain W&T |

Identical underlying diagnosis. Identical fix direction. One confirmation resolves both.

---

## Interaction with other open JONY-ACTIONs

| Action | Site | E&S role | Interaction with R/S(a)? |
|--------|------|---------|--------------------------|
| Z/AA/Q | §1.1 | Historical trio citation | **None** — Z option (a2) keeps E&S with corrected mechanism description ("dismissing warnings as inapplicable"); R/S(a) remove E&S only from the §2.x absent-content co-citations. Compatible. |
| P | §6.1 | Solo: "error attribution" | **None** — P option (a) corrects E&S §6.1 mechanism to "threat-model dismissal"; R/S(a) touch §2.x only. Compatible. |
| §2.1 solo (tick-4117) | Status line sentence | "pattern-match from prior experience" | **None** — that solo use was assessed BORDERLINE ACCEPTABLE (tick-4117, no JONY-ACTION); R/S(a) affect the co-citation on the *next* sentence only. Compatible. |

**After R(a) + S(a):**
- E&S citation count: was 5 sites, becomes 3 (§1.1 trio + §2.1 status line solo + §6.1 solo).
- All three remaining uses have Jony-action notes (Z/AA/Q for §1.1; P for §6.1; borderline-acceptable note for §2.1 solo).
- No stranded bibliography entry — E&S remains cited at 3 sites.

---

## Scope

R(a) and S(a) affect §2.1 line 134 and §2.2 line 146 only.

They do **not** cascade to:
- §1.1 (handled by Z/AA/Q)
- §6.1 (handled by P)
- §2.1 status-line E&S solo use (separately assessed BORDERLINE ACCEPTABLE, tick-4117)

---

## Recommended decision for Jony

> **"Confirm option (a) for both R and S: remove E&S (2013) from the two absent-content co-citations at §2.1 line 134 and §2.2 line 146. Retain W&T alone at both sites."**

This is a low-risk, high-precision correction. W&T (1999) is the right citation for both absent-content claims. E&S is well-placed elsewhere (§1.1, §2.1 status line, §6.1) for its actual findings once P and Z/AA/Q are also confirmed.

_Open Jony-actions after R(a)+S(a) confirmed: 15 (I, G, A, B, C, O, P, Q, T, U, W, X, Y, Z, AA)._
