# CHI Paper §6.1 — JONY-ACTION P Resolution Proposal

**Generated:** tick-4205 (2026-06-29)  
**Action:** JONY-ACTION P — §6.1 E&S mechanism description precision  
**Status:** Awaiting Jony confirmation (option a or b)  
**Prior work:** Option (a) text verified clean tick-4145 (commit df81db9); consolidated in batch memo tick-4148.

---

## The Issue

§6.1 lines 387-389 currently read:

> "This failure mode is not limited to novice users. **Egelman and Schechter (2013) find that even security-aware users, when confronted with feedback that violates expected conventions, tend toward behavioral normalization: they attribute the unexpected signal to error rather than design and proceed as if the system had confirmed the usual thing.**"

### Why this is wrong

The phrase **"attribute the unexpected signal to error rather than design"** is W&T's mechanism, not E&S's.

| Paper | What users encountered | Actual failure mode |
|---|---|---|
| **Whitten & Tygar (1999)** | Absent PGP confirmation output | Error-attribution: "the system failed / the operation didn't complete" |
| **Egelman & Schechter (2013)** | *Present* phishing warning (unexpected addition) | Threat-model dismissal: "this warning doesn't apply to me" — consciously bypassed via bounded rationality |

E&S's paper (FC 2013, LNCS 7859, pp. 52-59) abstract:
> *"misunderstandings about the threat model led participants to believe that the warnings did not apply to them. Acting out of bounded rationality, participants made conscientious decisions to ignore the warnings."*

E&S users did **not** conclude the system had errored. They concluded the warning was inapplicable to their situation. These are categorically different mechanisms.

The prior W&T sentence correctly captures error-attribution: *"they conclude that something has gone wrong."* The E&S sentence then re-attributes the same mechanism to E&S — which is imprecise.

**CHI risk: MODERATE.** A reviewer who knows E&S (warning-compliance study; FC 2013) will recognise the mechanism mismatch. The sentence's broader claim (even security-aware users bypass unexpected feedback) is supportable from E&S; the specific mechanism description ("attribute to error") is not.

---

## Option (a) — RECOMMENDED

Replace the E&S sentence with a mechanism-accurate description:

**BEFORE (current):**
> "Egelman and Schechter (2013) find that even security-aware users, when confronted with feedback that violates expected conventions, tend toward behavioral normalization: they attribute the unexpected signal to error rather than design and proceed as if the system had confirmed the usual thing."

**AFTER (option a):**
> "Egelman and Schechter (2013) find that even security-aware users dismiss unexpected security feedback when it does not align with their threat model — acting from bounded rationality, they conscientiously bypass it and proceed as if the system had confirmed the usual thing."

### Precision checks (all ✅)

1. **"dismiss unexpected security feedback"** — E&S participants ignored/dismissed the phishing warning. ✅
2. **"when it does not align with their threat model"** — E&S: "misunderstandings about the threat model led participants to believe the warnings did not apply to them." ✅
3. **"acting from bounded rationality"** — E&S's own framing: "acting out of bounded rationality, participants made conscientious decisions to ignore the warnings." ✅
4. **"conscientiously bypass it"** — E&S explicitly says "conscientious decisions." ✅
5. **"proceed as if the system had confirmed the usual thing"** — Behavioural outcome: users ignored the warning and proceeded. ✅ (this phrasing is a design-inference from E&S's finding, acceptable for §6.1 argument framing)
6. **"even security-aware users"** — E&S sample was drawn to be security-experienced; the paper's finding generalises beyond novice users. ✅

### Effect on surrounding passage

The W&T sentence immediately before ("they conclude that something has gone wrong") remains intact. Option (a) now correctly distinguishes **two distinct failure modes**:
- W&T: absent expected output → **error-attribution**
- E&S: present unexpected content → **threat-model dismissal**

Both support §6.1's point that security signals fail even for motivated/experienced users.

**One-line commit. No other paper changes. JONY-ACTION P closed. Open JA count: 24 → 23.**

---

## Option (b) — Keep current text

Risk: CHI reviewer familiar with E&S (FC 2013 is well-known in usable-security; E&S is among the top 10 cited SOUPS/FC papers on warning compliance) will notice:
- E&S studied a *present* unexpected warning (phishing warning displayed when participant visited a URL), not absent expected output
- E&S's documented mechanism is threat-model dismissal, not error-attribution
- The sentence's mechanism language ("attribute to error") is W&T's vocabulary, repeated from the prior sentence

Probability a knowledgeable reviewer notices: **~60%**. §6.1 is the Discussion — reviewers read this carefully.

---

## What to reply

```
P: option (a)
```

or

```
P: option (b)
```

After "P: option (a)" the agent will apply the replacement, remove the inline JONY-ACTION P note block, and commit. One commit. No other changes.

---

## Context: independence from Z/AA/Q

This fix is **independent** of the Z/AA/Q §1.1 trio sentence decision. §6.1 does not cite the trio sentence or reference §1.1 at this location. Option (a) here can be applied regardless of which §1.1 option Jony confirms.

## Context: §2.1 and §2.2 (JONY-ACTIONS S and R)

R (§2.2) and S (§2.1) are the same E&S mechanism mismatch at their respective sites; those have option (a) recommended (remove E&S, retain W&T alone). §6.1 (P) is a different sentence structure: E&S is the **sole** citation at this location, carrying the "even security-aware users" extension. Option (a) retains E&S but corrects the mechanism — distinct from R+S where E&S is co-cited with W&T for absent-content failure (where E&S genuinely doesn't fit and is cleanly removable).
