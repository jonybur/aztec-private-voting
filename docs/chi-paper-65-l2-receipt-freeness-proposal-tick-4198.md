# §6.5 L2 Receipt-Freeness Paragraph — Proposal (tick-4198)

**Status:** PROPOSAL — awaiting Jony review (JONY-ACTION HH)  
**CHI risk:** MODERATE (flagged tick-4194 item 12)  
**Action required:** Jony approves → apply to paper draft; Jony rejects → close HH  

---

## Background

§3.3 documents two design limitations:
- **L1 privacy gap** — `vote_choice` and `receipt_id` are plaintext in `record_vote` calldata; an observer can build a `receipt_id → vote_choice` map.
- **L2 receipt-freeness is partial** — The contract does not implement a re-encryption mix. The term "coercion-resistant" is withheld from user-facing copy in `VoteReceipt.tsx` until this is resolved.

§6.5 currently has a **Protocol-layer exposure** entry that covers L1 in depth.  
§6.5 has **no entry for L2**. A CHI reviewer familiar with the e-voting receipt-freeness  
literature (Juels et al. 2005; Carback et al. 2010) may look for L2 disclosure in §6.5  
and not find it. Flagged tick-4194 as CHI risk MODERATE.

---

## Proposed insertion

**Location:** After the "Protocol-layer exposure" paragraph, before "Study 1 ecological validity."

**Text to insert:**

---

**Partial receipt-freeness.** Receipt-freeness requires that a voter be unable to prove to a third party how they voted, even voluntarily (Juels et al. 2005). The current Aztec Private Voting instantiation does not achieve full receipt-freeness: a voter who shares their fingerprint identifier with a coercer provides a direct handle for that coercer to reconstruct the voter's choice from the on-chain `record_vote` calldata (§3.3, L1 privacy gap), because the `receipt_id → vote_choice` map is publicly constructible from calldata alone. Full receipt-freeness requires a protocol mechanism that severs the link between a voter's identifier and their recorded choice — such as a re-encryption mix — which the contract does not implement (§3.3, L2). PIUP addresses the coercion surface at the receipt-content layer (Invariant 3: the receipt withholds the vote choice) and at the UX layer (protective framing explicitly names the absent content), but these do not prevent a voter from voluntarily producing verifiable coercion evidence by sharing their fingerprint. The term "coercion-resistant" is withheld from user-facing copy in `VoteReceipt.tsx` until a re-encryption mix is implemented, consistent with the §3.3 L2 commitment. This limitation does not affect Study 1 or Study 2: the comprehension endpoints test absent-content inference — whether participants correctly understand what the receipt shows and withholds — rather than receipt-freeness or threat-model comprehension; no question asks whether a voter can construct coercion evidence using their identifier. [Added tick-4198 — JONY-ACTION HH: §3.3 documents two design limitations (L1 privacy gap + L2 partial receipt-freeness); §6.5 had Protocol-layer exposure (L1) but no L2 entry. CHI risk MODERATE (flagged tick-4194). Paragraph added here. See bibliography note below.]

---

## Bibliography entry required (not yet in paper)

If Jony approves this paragraph, add the following entry to the References section  
(alphabetical order: after "Jakobsson" / before "Kulyk"):

```
- Juels, A., Catalano, D., and Jakobsson, M. (2005). "Coercion-resistant electronic
  elections." In _Proceedings of the 4th ACM Workshop on Privacy in the Electronic
  Society (WPES '05)_, pp. 61-70. ACM. DOI: 10.1145/1102199.1102213.
  [DBLP: conf/wpes/JuelsCJ05; pages + DOI confirmed tick-4212.]
```

### Verification status
- Authors: Ari Juels, Dario Catalano, Markus Jakobsson — **CONFIRMED** (DBLP tick-4198)
- Title: "Coercion-resistant electronic elections." — **CONFIRMED** (DBLP tick-4198)
- Venue: WPES 2005 (4th ACM Workshop on Privacy in the Electronic Society) — **CONFIRMED** (DBLP tick-4198)
- Pages: pp. 61-70 — **CONFIRMED** (DBLP conf/wpes/JuelsCJ05 + Semantic Scholar DOI:10.1145/1102199.1102213, tick-4212)
- DOI: 10.1145/1102199.1102213 — **CONFIRMED** (tick-4212)

---

## Cross-reference consistency check

If this paragraph is applied, no other §6.5 edits are needed. Cross-check:

| Reference in proposed text | Cross-reference target | Status |
|---|---|---|
| `§3.3, L1 privacy gap` | §3.3 L1 heading: "L1 privacy gap." | ✅ MATCH |
| `§3.3, L2` | §3.3 L2: "Receipt-freeness is partial." | ✅ MATCH |
| `Invariant 3` | §2.1 Invariant 3 (Minimal receipt content) | ✅ MATCH |
| `VoteReceipt.tsx` | §3.4 component name | ✅ MATCH |
| `Juels et al. 2005` | New bibliography entry (see above) | ⚠️ REQUIRES NEW BIB ENTRY |
| Study 1 + Study 2 scope | No comprehension questions test receipt-freeness — confirmed (§4.4, §5.4) | ✅ CLEAN |

---

## Jony's options

**(a) Apply** — Insert the text above after "Protocol-layer exposure" in §6.5, add the Juels et al. (2005) bibliography entry (pp. 61-70 + DOI now fully verified tick-4212), and close JONY-ACTION HH.

**(b) Apply without Juels citation** — Insert the paragraph without the (Juels et al. 2005) citation, keep the definition prose but remove the reference. Lower bibliography burden; slightly weaker for a CHI reviewer.

**(c) Reject** — §6.5 L2 omission is acceptable; keep §3.3's terse L2 note as the only disclosure. Close JONY-ACTION HH as rejected.

---

*Proposal written tick-4198. Pages + DOI verified tick-4212. No commit to paper draft made. Awaiting Jony decision.*
