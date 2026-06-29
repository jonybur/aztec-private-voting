# JONY-ACTION JJ — Cover Letter ¶2 "Coercion Resistance" Overclaim

**Generated:** tick-4201 (2026-06-29)  
**File:** `docs/gt-hci-cover-letter-draft-2026-06-29.md`  
**Severity:** HIGH — factual overclaim directly contradicting §3.3 L2 and §6.5 L2 commitments  
**CHI risk:** N/A (cover letter, not paper) but **Annie Antón risk: HIGH** — recipient is a formal privacy specification researcher who will notice a claim the paper explicitly disclaims  
**Blocking:** Yes — DO NOT send cover letter or cold-contact email to Antón until ¶2 is corrected

---

## The Error

**Cover letter ¶2 (current):**
> "The cryptographic machinery was, in a meaningful sense, solved: zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **coercion resistance** simultaneously."

**Research statement ¶1 (correct):**
> "The cryptographic machinery was, in a meaningful sense, solved: zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **double-vote prevention** simultaneously."

---

## Why This Is Wrong

The CHI paper (§3.3 L2, §6.5, design notes §2.1 named limitation) explicitly states:

> *"Receipt-freeness is partial. The contract does not implement a re-encryption mix. The commitment not to use the term 'coercion-resistant' in user-facing copy until this is resolved is maintained in the receipt component."*

The system achieves three ZK-guaranteed properties:
1. **Ballot privacy** — vote choice is in private state, not observable by anyone without the private key
2. **Individual verifiability** — the receipt identifier (`receipt_id`) enables post-vote verification via the public `receipts` mapping
3. **Double-vote prevention** — `SingleUseClaim` nullifier derived from the voter's Aztec spending keys prevents re-use

**Coercion resistance is NOT achieved** because:
- Full coercion resistance requires that a voter be unable to prove to a third party how they voted, even voluntarily (Juels et al. 2005)
- The Aztec Private Voting contract does not implement a re-encryption mix
- A voter who shares their `receipt_id` (fingerprint) with a coercer provides a handle that, combined with `record_vote` calldata (which includes both `receipt_id` and `vote_choice`), allows reconstruction of vote choice — i.e., voluntarily producible coercion evidence exists
- This is explicitly documented as L2 in §3.3 and §6.5 (JONY-ACTION HH proposal, tick-4198)

---

## Why This Matters for Annie Antón

Annie Antón's research programme is specifically about specifying and verifying that software behaviour is **correct and complete** against privacy requirements. A cover letter that overclaims privacy properties — claiming "coercion resistance" for a system that explicitly does not achieve it — is precisely the kind of error she would catch. Sending a cover letter with this claim to Antón does the opposite of establishing credibility; it signals that the applicant confuses formal privacy properties with implementation capabilities.

The research statement correctly says "double-vote prevention" — the cover letter's ¶2 appears to have been drafted independently (or earlier) and was not synced against the paper's final §3.3 L2 commitment.

---

## Cross-check: What the Paper Commits To

| Claim | Paper says | Cover letter ¶2 says | Match? |
|-------|-----------|---------------------|--------|
| Ballot privacy | ✅ ZK private state | "ballot privacy" | ✅ |
| Individual verifiability | ✅ receipt_id + verify endpoint | (implicit) | ✅ |
| Double-vote prevention | ✅ SingleUseClaim nullifier | ❌ "coercion resistance" | ❌ |
| Coercion resistance | ❌ EXPLICITLY NOT CLAIMED (§3.3 L2, §6.5, VoteReceipt.tsx) | "coercion resistance" | ❌ WRONG |

---

## Proposed Correction

**Option (a) [RECOMMENDED — match research statement exactly]:**

Replace cover letter ¶2:
> "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **coercion resistance** simultaneously."

With:
> "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and **double-vote prevention** simultaneously."

This matches the research statement ¶1 exactly and is factually correct.

**Option (b) [slightly more informative]:**

> "zero-knowledge proofs can guarantee ballot privacy, individual verifiability, and double-vote prevention simultaneously — but they cannot, alone, guarantee that a voter cannot voluntarily prove how they voted."

This is accurate and could strengthen the argument for why the UX/HCI work is necessary, but it adds wordiness to a tight cover letter paragraph.

**Option (c) [preserve structure but fix claim]:**

Replace the three-property list with a brief accurate description:
> "zero-knowledge proofs handle the cryptographic half: ballot secrecy and individual verifiability without a central authority."

Shorter, accurate, and sidesteps the enumeration that led to the overclaim.

**RECOMMENDATION: Option (a).** Exact match to research statement. No new prose needed.

---

## Also: Cold-contact email template contains the same error

The cold-contact email template (under "Notes for Jony" → "Cold-contact email template") says in ¶1:
> "The cryptographic privacy properties are formally specified and implemented..."

This is fine, but ¶2 of the email body must also be checked before sending. The email body ¶1 in the template does not explicitly claim "coercion resistance" — but if ¶2 of the letter body is copied into the email, the error propagates.

**Action:** After applying option (a) to the main letter ¶2, do a search for "coercion resistance" in the cover letter file and confirm it does not appear in any paragraph (including the cold-contact email template).

---

## Jony's Decision

Reply **"JJ: option (a)"** — agent applies the fix to `docs/gt-hci-cover-letter-draft-2026-06-29.md` ¶2 and does a full search for other "coercion resistance" occurrences in the cover letter file.

**Do not send cover letter or cold-contact email to Antón before applying option (a).**

---

_Generated tick-4201. 0 BUGS in paper. 1 ERROR in cover letter. JONY-ACTION JJ opened._
