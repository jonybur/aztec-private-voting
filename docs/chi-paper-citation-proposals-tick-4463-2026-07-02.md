# CHI Paper — Volkamer 2022 + Kulyk 2021 Citation Proposals (tick-4463, 2026-07-02)

**Author:** OpenClaw Agent  
**Status:** Analysis complete — Jony to confirm DOIs/page numbers and decide whether to apply edits  
**Resolves:** `retrieve-kulyk-secrecy-preserving-paper` from openJonyActions  
**Continues:** tick-4462 citation gap check  
**Word budget impact:** ~20 words if Volkamer 2022 sentence added; ~0 if Kulyk 2021 merged into existing list sentence

---

## 1. Kulyk et al. 2021 — Found and Assessed

### Citation
Kulyk, O., Ludwig, J., Volkamer, M., Koenig, R.E., and Locher, P.  
"Usable Verifiable Secrecy-Preserving E-Voting."  
*Electronic Voting: 6th International Joint Conference, E-Vote-ID 2021*, Bregenz, Austria.  
Publisher: Springer (LNCS). KIT library ID: 1000139582.  
**Jony action: confirm LNCS volume + page numbers from Springer (DOI starts 10.1007/...).**

### What the paper is about
The paper proposes using QR codes to make code voting usable. Core idea: combine Chaum's code voting with the cast-as-intended verification mechanism used in Swiss elections (personal init code, per-option return codes, confirmation code, finalization code), but replace manual code entry with QR codes. User study evaluates usability and UX of the approach.

> "In this paper we propose the usage of QR-Codes to enable usable verifiable e-voting schemes based on code voting... As our proposal performs good wrt. usability, we discuss how such usable front-ends enable more secure e-voting systems in respect to end-to-end verifiability and vote secrecy."

### Relevance to PIUP

**Verdict: LOW-MODERATE — same category as Kulyk 2015, not a PIUP competitor.**

- **Cast-as-intended verification usability:** The paper is entirely about whether voters can successfully complete the verification step. ✓ Same category as Kulyk et al. (2015), Marky et al. (2018).
- **Vote secrecy ("secrecy-preserving"):** Refers to the protocol's secrecy property (code voting hides choice from the vote server). This is a protocol-layer property, not a receipt-layer one. The "secrecy-preserving" in the title does NOT mean receipt privacy design.
- **Receipt design / privacy mental models:** Absent. The paper does not study what voters believe a receipt reveals, does not address absent-content interpretation, and does not study the post-vote artifact semantics. 

**PIUP contribution is orthogonal:** PIUP's novel contribution — what voters believe a cryptographic receipt reveals, and how protective absence framing corrects that belief — is not addressed by this paper.

### Recommended disposition
Cite in §1.2 alongside Kulyk 2015 in the verification-usability list sentence. Lower priority than Volkamer 2022 (lower venue visibility: E-Vote-ID vs. SOUPS). Only add if §1.2 references Kulyk 2015 and Jony wants a complete SECUSO citation arc showing the line from 2015 → 2021 → 2022.

**✅ Removes `retrieve-kulyk-secrecy-preserving-paper` from openJonyActions.** Paper is retrieved and assessed; verdict is safe to cite in §1.2 list without further Jony reading.

---

## 2. Draft §1.2 Edit — Volkamer 2022 (Primary Recommendation)

### Current text (line 67)
```
Prior e-voting usability work evaluates voter *verification* (ballot inclusion checking) rather than voter *comprehension* of what the inclusion proof proves or withholds. STAR-Vote (Bell et al. 2013), Helios (Adida et al. 2009), Marky et al. (2018), and Kulyk et al. (2015) measure task completion, workload, or cryptographic eligibility-hiding, not receipt representational semantics. Carback et al. (2010) evaluate whether voters *use* the Scantegrity II affordance, not whether they correctly model the privacy property. No prior work directly examines what voters *believe* a cryptographic receipt reveals about their vote choice.
```

### Option A — Insert Volkamer 2022 follow-up sentence (recommended)
Insert between the list sentence and "Carback et al. (2010)...":

```
Prior e-voting usability work evaluates voter *verification* (ballot inclusion checking) rather than voter *comprehension* of what the inclusion proof proves or withholds. STAR-Vote (Bell et al. 2013), Helios (Adida et al. 2009), Marky et al. (2018), and Kulyk et al. (2015) measure task completion, workload, or cryptographic eligibility-hiding, not receipt representational semantics. While subsequent work has extended these findings to varied verifiable voting system designs (Volkamer et al., 2022), the receipt privacy-mental-model problem — the artifact voters retain *after* verification — has not been empirically addressed. Carback et al. (2010) evaluate whether voters *use* the Scantegrity II affordance, not whether they correctly model the privacy property. No prior work directly examines what voters *believe* a cryptographic receipt reveals about their vote choice.
```

**Word delta:** +22 words (~1.8% of §1.2 budget).  
**Effect:** Establishes explicitly that PIUP's gap claim survives post-2018 work. Blocks a CHI reviewer objection that the literature review is outdated.

### Option B — Add Kulyk 2021 to the list sentence (lower priority)
Replace "and Kulyk et al. (2015) measure" with "Kulyk et al. (2015), and Kulyk et al. (2021) measure":

```
STAR-Vote (Bell et al. 2013), Helios (Adida et al. 2009), Marky et al. (2018), Kulyk et al. (2015), and Kulyk et al. (2021) measure task completion, workload, or cryptographic eligibility-hiding, not receipt representational semantics.
```

**Word delta:** +5 words. Only useful if Jony wants a complete SECUSO citation arc. Two "Kulyk et al." citations in one sentence is awkward; consider "Kulyk et al. (2015, 2021)" instead.

### Recommendation
**Apply Option A only.** Add the Volkamer 2022 sentence. Skip Option B unless the SECUSO arc is important to reviewers. If adding both, combine as:

```
STAR-Vote (Bell et al. 2013), Helios (Adida et al. 2009), Marky et al. (2018), Kulyk et al. (2015, 2021) measure task completion, workload, or cryptographic eligibility-hiding, not receipt representational semantics. While this verification-usability work has continued to expand (Volkamer et al., 2022), the receipt privacy-mental-model problem — the artifact voters retain *after* verification — has not been empirically addressed.
```

---

## 3. Bibliography Entries (pending Jony DOI verification)

### Volkamer et al. 2022 (SOUPS)
```
- Volkamer, M., Kulyk, O., Ludwig, J., and Fuhrberg, N. (2022). "Increasing Security without Decreasing Usability: A Comparison of Various Verifiable Voting Systems." _Eighteenth Symposium on Usable Privacy and Security (SOUPS 2022)_. USENIX Association. [Jony: verify DOI and page numbers from USENIX proceedings]
```

### Kulyk et al. 2021 (E-Vote-ID) — only if Option B or combined edit applied
```
- Kulyk, O., Ludwig, J., Volkamer, M., Koenig, R.E., and Locher, P. (2021). "Usable Verifiable Secrecy-Preserving E-Voting." _Electronic Voting: 6th International Joint Conference, E-Vote-ID 2021_, LNCS vol. [TBD], pp. [TBD]. Springer. DOI: 10.1007/[TBD]. KIT ID: 1000139582.
```

---

## 4. Jony Actions from this tick

| Action | Status | Detail |
|---|---|---|
| retrieve-kulyk-secrecy-preserving-paper | **✅ RESOLVED** | Paper found, assessed LOW-MODERATE, safe to add to §1.2 list if desired |
| Add Volkamer 2022 to §1.2 | **⏳ JONY DECISION** | Confirm venue/DOI; apply Option A text above |
| Verify Volkamer 2022 DOI + page numbers | **⏳ JONY** | Check USENIX SOUPS 2022 proceedings |
| Verify Kulyk 2021 LNCS volume + DOI | **⏳ JONY (if adding)** | Check Springer E-Vote-ID 2021 proceedings |

---

## 5. Word count projection

If Option A applied:
- §1.2 before: ~[current count] words
- §1.2 after: +22 words
- Total paper: approaches ceiling more; currently ~11,823 words (tick-4418 baseline); still under 12,000 cap by ~177 words before trim
- No trim required at this addition size
