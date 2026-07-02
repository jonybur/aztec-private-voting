# CHI Paper — Citation Gap Check (2026-07-02, tick-4462)

**Author:** OpenClaw Agent  
**Status:** Analysis only — Jony to review and decide which papers to add  
**Context:** CHI 2027 submission deadline September 10, 2026. Most recent HCI citation in paper: Marky et al. (2018). Search performed to identify post-2018 work that reviewers might flag as missing.

---

## Search scope

Three targeted searches for:
1. ZK voting receipt-free usability HCI/CHI 2024-2026
2. Usable private voting coercion mental model CHI/SOUPS 2023-2025
3. Marky/Kulyk/Volkamer e-voting usability comprehension 2019-2023

---

## Findings

### A — Volkamer, Kulyk, Ludwig, Fuhrberg (SOUPS 2022)
**Title:** "Increasing security without decreasing usability: a comparison of various verifiable voting systems"  
**Venue:** Eighteenth Symposium on Usable Privacy and Security (SOUPS 2022)  
**Relevance to PIUP:** MODERATE. This paper compares verifiable voting systems on usability dimensions — but "verifiable" here means *cast-as-intended* verification (did my ballot land as I marked it?), not receipt privacy design. The SECUSO group's usability work consistently focuses on the voter's ability to verify the casting step, not on the post-vote receipt artifact or privacy-mental-model accuracy.

**Distinction from PIUP:** PIUP's contribution is orthogonal. PIUP addresses the *receipt layer* — what the voter retains after their ballot is recorded, and whether that receipt correctly signals its privacy properties under adversarial conditions. Cast-as-intended verification usability (Marky 2018, Kulyk 2015, Volkamer 2022) addresses whether the voter can check that their ballot was *recorded correctly*. These are different problems: PIUP assumes recording was successful (the receipt confirms it) and focuses on what the receipt reveals about the vote choice.

**Recommendation:** Cite in §1.2 (related work paragraph on verification usability) as evidence that the SECUSO group's post-2018 work continues to focus on verification usability, not receipt privacy design. One-sentence mention. This strengthens the positioning gap claim: "While subsequent work has extended these findings to varied verifiable voting system designs (Volkamer et al., 2022), the receipt privacy-mental-model problem — the artifact voters retain *after* verification — has not been empirically addressed."

**Action required:** Jony to confirm venue/DOI (Springer chapter in SOUPS 2022 proceedings) and decide whether to add. If added: +1 reference to bibliography, ~20 words in §1.2.

---

### B — Kulyk, Henzel, Renaud, Volkamer (INTERACT 2019)
**Title:** "Comparing 'challenge-based' and 'code-based' internet voting verification implementations"  
**Venue:** INTERACT 2019, LNCS vol. 11746, pp. 519–538  
**Relevance to PIUP:** LOW-MODERATE. This paper compares two verification UX patterns (Benaloh Challenge vs. code-based). It is about cast-as-intended verification UX, not receipt privacy.

**Distinction from PIUP:** Same as A above. The verification UX problem is different from the receipt design problem.

**Recommendation:** Optional. The SOUPS 2022 paper (A) is a stronger citation because it is more recent and at a higher-relevance venue. If §1.2 already cites Marky 2018, adding both A and B creates redundancy. Choose one.

**Action required:** Only add if Jony wants a comprehensive SECUSO citation arc. Lower priority than A.

---

### C — Kulyk, Ludwig, Volkamer, Koenig, Locher — "Usable verifiable secrecy-preserving E-voting"
**Full citation:** Kulyk, O., Ludwig, J., Volkamer, M., Koenig, R.E., Locher, P. (2021). "Usable Verifiable Secrecy-Preserving E-Voting." _6th International Joint Conference on Electronic Voting (E-Vote-ID 2021)_, Bregenz, Austria. University of Tartu Press.

**Status:** ✅ ASSESSED (tick-4479) — verified via PDF abstract + snippet analysis. No Jony action required.

**Content (confirmed from PDF abstract + multiple source snippets):** Proposes using QR-codes to enable usable *code-voting* schemes (one voting code per voting option + one personal confirmation QR-code). Conducts user study evaluating usability/UX of the code-sheet-plus-QR approach for cast-as-intended verification. The "secrecy-preserving" claim refers to cryptographic secrecy at the *casting* layer: the voting device cannot learn the voter's choice because it only sees codes, not vote labels. Code sheets and the election webpage are designed following usability guidelines from the SECUSO group's prior work (Marky 2018, Kulyk 2015).

**Relevance to PIUP:** LOW — NOT a competitor. Despite the title's "secrecy-preserving" wording, the paper operates in cast-as-intended verification UX space, not receipt design or receipt privacy mental models. Specifically:
- "Secrecy-preserving" in Kulyk 2021 = the voting *device* cannot observe the vote choice (protocol-layer property enforced by code sheets)
- "Privacy" in PIUP = the *receipt* (post-vote artifact) does not reveal the vote choice to a coercer (receipt design property and user mental model)
- Kulyk 2021's user study DV: task completion and user experience of the code-sheet process
- PIUP's user study DV: accuracy of voter belief about what the receipt reveals

These are orthogonal contributions. The existing Marky 2018 citation in §1.2 already credits the SECUSO group's CHI-published usability work in this tradition. Adding Kulyk 2021 would add a third SECUSO citation (after Kulyk 2015 and Marky 2018) with no unique positioning value for PIUP.

**Recommendation:** No action. Not a prior work competitor. Not required for §1.2 completeness (already covered by Marky 2018). No defensive revision to §6.5 needed.

**Action required:** None — Jony does not need to read this paper before CHI submission.

---

### D — E-Vote-ID 2024/2025 proceedings papers (Springer, E-Vote-ID)
**Papers found:**
- "Direct and Transparent Voter Verification with Everlasting Receipt-Freeness" (Springer E-Vote-ID proceedings, 2024)
- "Expanding the Toolbox: Coercion and Vote-Selling at Vote-Casting Revisited" (Springer E-Vote-ID)
- "ZK-SNARKs for Ballot Validity: A Feasibility Study" (Springer 2024)

**Relevance to PIUP:** LOW. These are all cryptographic/protocol papers on receipt-freeness and coercion resistance. They address formal security properties (Juels-Catalano-Jakobsson coercion resistance), not HCI/usability of receipt design. The PIUP paper already cites Juels et al. 2005 for the protocol-level coercion resistance definition and explicitly positions PIUP as a *UX-layer* contribution, not a cryptographic one.

**Recommendation:** No action needed. These papers are in a different discipline (cryptography/security engineering) and the PIUP paper correctly positions itself relative to this body of work in §6.5.

---

### E — Votegral at SOSP 2025 
**Title:** "Prototype e-voting system can solve coercion problem" (reported at SOSP 2025)  
**Relevance to PIUP:** LOW. Systems paper on fake credentials mechanism for coercion resistance. Not HCI.

**Recommendation:** No action needed.

---

## Summary verdict

| Paper | Add to CHI paper? | Priority |
|---|---|---|
| A: Volkamer et al. SOUPS 2022 | ✅ Yes — one sentence in §1.2 | Medium |
| B: Kulyk et al. INTERACT 2019 | Optional — only if §1.2 needs breadth | Low |
| C: Kulyk et al. E-Vote-ID 2021 | ✅ No action — NOT a competitor (QR-code code-voting UX, not receipt privacy mental models). Assessed tick-4479. | CLOSED |
| D: E-Vote-ID 2024/2025 cryptography papers | No action | — |
| E: Votegral SOSP 2025 | No action | — |

---

## Key finding: no direct HCI competitor identified

**The most important result of this search:** No CHI, SOUPS, or INTERACT paper from 2019-2026 directly addresses receipt design for privacy-preserving voting systems from an HCI/mental-model perspective. The SECUSO group (the closest research community) continues to focus on cast-as-intended verification usability, not post-vote receipt privacy artifact design. This confirms that PIUP's core contribution — the empirical study of receipt label effects and protective framing on privacy mental models — occupies an unaddressed gap in the literature.

**For the paper:** The positioning in §1 ("nobody has shipped a polished, DAO-usable product" and "the HCI/receipt-design gap nobody else is pursuing") is supported. No defensive revision needed; only the optional addition of Volkamer et al. 2022 to acknowledge the SECUSO group's more recent work.

---

## Draft citation text (for §1.2, if Jony approves addition of Paper A)

> "While subsequent work has extended usability evaluation to varied verifiable voting system designs (Volkamer et al., 2022), this line of research focuses on cast-as-intended verification — whether voters can confirm their ballot was recorded correctly. The artifact voters receive *after* verification — the receipt, its labels, and whether its privacy properties are correctly understood — has not been empirically addressed."

**Bibliography entry to add:**
> Volkamer, M., Kulyk, O., Ludwig, J., and Fuhrberg, N. (2022). "Increasing security without decreasing usability: a comparison of various verifiable voting systems." _Eighteenth Symposium on Usable Privacy and Security (SOUPS 2022)_, pp. [pp]. USENIX Association. [Jony to verify pp. and DOI]

---

_Created: 2026-07-02 (tick-4462). Updated: 2026-07-02 (tick-4479) — Kulyk et al. 2021 (Paper C) assessed and closed. No competitor. Full citation and content verdict added.

Remaining open action: Jony to (1) confirm addition of Volkamer et al. 2022 to §1.2 (optional, ~20 words + 1 reference)._
