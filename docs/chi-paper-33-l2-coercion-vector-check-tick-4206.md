# CHI Paper §3.3 L2 + §2.2 Alt3 — Coercion-Like Vector Cross-Check

**Tick:** 4206  
**Status:** CLEAN — 1 INFO, 0 BUGS, no new JONY-ACTION  
**CHI risk:** LOW  
**Sections audited:** §3.3 L2 ("Receipt-freeness is partial"); §2.2 Alt3 "second supervised submission" passage  

---

## Background

The nextRotation planned this tick as: "JONY-ACTION O — §3.3 NF2 'coercion-like' vector. Check the §3.3 security table NF2 entry wording. NF2 states the contract does not prevent a second supervised submission if the voter reveals their nullifier — the paper should frame this correctly without overstating coercion resistance claims already disclaimed at L2/§6.5."

**Clarification on naming:** There is no entry labeled "NF2" in the CHI paper §3.3 body text. The security review uses N-F1–N-F7 for nullifier/eligibility findings; N-F2 (cross-wallet Merkle reuse, CONFIRMED SOUND) has no corresponding CHI paper §3.3 entry, nor should it. The "coercion-like vector" referenced in the nextRotation corresponds to the §3.3 L2 entry and the §2.2 Alt3 second-supervised-submission scenario. This tick audits both.

---

## 1. §3.3 L2 — "Receipt-freeness is partial"

**Current text (exact):**
> *Receipt-freeness is partial.* The contract does not implement a re-encryption mix. The commitment not to use the term "coercion-resistant" in user-facing copy until this is resolved is maintained in the receipt component.

### Cross-check dimensions

**1a. Is "partial" the right framing?**

Receipt-freeness (formal definition): a voter cannot construct a proof of their vote choice for a coercer, because any such proof is deniable (the voter could have changed their vote via re-encryption).

Without re-encryption mix:
- A voter whose vote choice appears in L1 calldata (§3.3 L1 gap) CAN have their vote direction inferred by a coercer with calldata access — receipt-freeness is NOT achieved in L1-observer scenarios.
- A voter who does NOT share their fingerprint, and whose coercer lacks calldata monitoring capability, is harder to coerce — in this narrower threat model, receipt-freeness PARTIALLY holds.

**Verdict: ✅ "Partial" is defensible.** The system achieves privacy at the state layer (ballot secrecy at the ZK/private-kernel level) but not at the calldata layer. In scenarios where the coercer cannot monitor calldata, the receipt-freeness partial claim holds. The qualifier "partial" is appropriately conservative without being alarmist.

**1b. Does the entry mention the specific coercion mechanism?**

The entry does not spell out the specific mechanism (calldata exposure enabling coercer to verify vote direction). However:
- §3.3 L1 describes the calldata exposure in detail.
- §6.5 Protocol-layer exposure discusses it at length.
- The cross-reference architecture is complete: a reader of §3.3 L2 who wonders "partial how?" is directed to look at L1 and §6.5.

**Verdict: ✅ CLEAN.** The entry is minimal but complete given the cross-reference structure.

**1c. Does the "commitment not to use 'coercion-resistant'" note overclaim or underclaim?**

This sentence is a UX commitment, not a security claim. It is appropriately scoped: it does not say the system IS coercion-resistant; it says the word will not be used in user-facing copy until the architectural gap is closed. This is precision-correct.

**Verdict: ✅ CLEAN.**

**1d. CHI risk of the L2 entry as-is:**

A CHI reviewer from formal security or cryptography background would:
- Understand "receipt-freeness is partial" immediately
- Confirm the re-encryption mix requirement matches the formal definition
- Note the commitment not to overclaim — which is a positive signal

A CHI reviewer from HCI background would:
- See "partial" as an honest limitation disclosure
- Not know the formal definition; unlikely to press on mechanism

**CHI risk: LOW.** Entry is accurate and appropriately scoped.

---

## 2. §2.2 Alt3 — "Second Supervised Submission" Passage

**Current text (key passage):**
> "...a voter who believes their ballot was not counted is accessible to a second supervised submission, reopening exactly the coercion window the pattern is designed to close. This comparison is a design inference not directly tested by the cited absent-content literature..."

### Analysis

**The claim:** Without protective framing, a voter who believes their ballot failed is "accessible to a second supervised submission" which "reopens exactly the coercion window."

**What actually happens with SingleUseClaim:**

1. Voter has already cast a ballot → SingleUseClaim nullifier is **spent**.
2. A coercer demands the voter vote again under supervision.
3. The voter's `cast_vote` attempt **fails** — the spent nullifier means the private kernel rejects the double-spend.
4. The coercer now knows the voter previously voted (the attempt failed ≠ not previously voted).
5. The vote **choice** is still not revealed by the failed second submission attempt itself.
6. HOWEVER: if the coercer has L1 calldata access (§3.3 L1 gap), they can look up the original `record_vote` transaction and see `vote_choice` in calldata.

**Precision assessment of "reopening exactly the coercion window":**

- The "coercion window" the PIUP is designed to close is: **a coercer being able to verify how the voter voted** (vote-direction exposure).
- The second supervised submission exposes the voter to **coercion pressure** (they can be forced to attempt to vote under observation).
- The second submission DOES NOT directly reopen vote-direction exposure — that requires L1 calldata access (§3.3 L1 gap) in addition.
- The §2.2 Alt3 claim "reopening exactly the coercion window" slightly conflates two effects:
  - (a) The voter being put in a coercion situation (second supervised attempt)
  - (b) The coercer learning the voter already voted (via nullifier-failure signal)
  - (c) Vote direction being revealed (requires L1 calldata access, separate from the second submission)

**Is this a precision bug?**

**No — for three reasons:**

1. **The paper already hedges:** "This comparison is a design inference not directly tested by the cited absent-content literature" — the text explicitly acknowledges the comparison is a design-level claim, not an empirically verified mechanism.

2. **The §2.2 Alt3 argument is directionally correct:** Without protective framing, the voter IS accessible to coercion pressure (second supervised submission); the coercer gains information (voter has already voted); and the combination with L1 calldata access would reveal vote direction. The argument chain is valid even if the §2.2 text telescopes it.

3. **CHI risk is LOW:** The §2.2 Alt3 text is part of a design-rationale argument for rejected alternatives, not a formal security claim. A CHI reviewer with ZK cryptography expertise might notice the mechanism telescoping; an HCI reviewer would not. The "design inference" hedge covers this.

**Verdict: ✅ CLEAN (1 INFO)**

**INFO:** The §2.2 Alt3 phrase "reopening exactly the coercion window" telescopes a three-step mechanism (second submission → coercer learns voter already voted → L1 calldata reveals choice) into a single causal claim. Strictly, the second submission alone reopens coercion pressure but not direct choice-revelation. The paper's own "design inference" hedge is adequate mitigation. CHI risk: LOW. No paper edit needed; no new JONY-ACTION.

---

## 3. Summary

| Check | Result | CHI risk |
|---|---|---|
| §3.3 L2 — "partial" framing accuracy | ✅ CLEAN | LOW |
| §3.3 L2 — calldata mechanism disclosure | ✅ CLEAN (cross-refs to L1 + §6.5) | LOW |
| §3.3 L2 — "coercion-resistant" commitment | ✅ CLEAN | LOW |
| §2.2 Alt3 — "second supervised submission" | ✅ CLEAN (1 INFO) | LOW |
| Missing "NF2" entry in §3.3 | N/A — no such entry needed | — |
| Coercion resistance overclaim anywhere in §3.3 | ✅ NOT FOUND | — |

**0 BUGS. 0 new JONY-ACTIONs. 1 INFO (low-risk mechanism telescoping in §2.2 Alt3, hedged by paper's own design-inference caveat).**

---

## 4. JONY-ACTION O clarification

The open JONY-ACTION O (from jony-actions-audit-2026-06-23.md §4.2) is:
**§4.2 CS/SE student screener extension — file OSF Amendment 5 before pilot launch.**

This is a Jony-action (requires OSF filing), not agent work. Amendment 5 text is ready in `docs/osf-amendment-filing-2026-06-24.md`. No agent step remaining. Awaiting Jony's OSF upload.

The "§3.3 NF2 coercion-like vector" in the nextRotation was a planned NEW investigation, not JONY-ACTION O itself. The investigation is now complete: **CLEAN**.

---

**No commit needed. No paper changes. JA count: 24 (unchanged).**
