# Decision Memo: JONY-ACTION U
_tick-4235 | 2026-06-29 | pre-registration-critical choice_

This is the only remaining **real choice** from the cheatsheet after the EE/FF/GG memo (tick-4234).
Apply script passes all 5 dry-run checks. Recommendation is strong.

---

## U — E2 copy: "Your vote is private and verifiable" vs. "Your vote choice is not shown"

### The conflict (what diverged)

The paper §5.3 and design note §6.1 both specify that the E2 (no-explanation) condition
retains a **generic privacy note** with no absent-choice signal:

> *"Your vote is private and verifiable."*

But `VoteReceipt.tsx` (`explanationVariant='unexplained'`) currently renders:

> *"Your vote choice is not shown on this receipt."*

This is an **absent-choice statement** — it directly tells the participant that their vote
choice is not shown. `VoteReceipt.test.tsx` APV-PIUP-02 asserts this text, confirming the
implementation diverges from both the paper and the design note.

### Why this matters methodologically

The whole point of the E factor is to test whether an **explanation** (E1) improves
absent-choice inference vs. **no absent-choice cue** (E2).

If E2 says "Your vote choice is not shown on this receipt," participants can answer Q-AC
("Is your vote choice shown?") correctly by **verbatim reading alone** — without any inference.
That collapses the E main effect:

| What E2 shows | What E contrast measures |
|---|---|
| "Your vote is private and verifiable." ✅ | Explanation vs. no absent-choice cue (full contrast) |
| "Your vote choice is not shown on this receipt." ❌ | Explanation vs. absent-choice acknowledgment (weakened contrast) |

In the second case, H2.1 is harder to interpret: does E1 advantage over E2 reflect the
*explanation*, or just the *rationale* vs. *bare statement*? A CHI reviewer who spots this
would rightly ask whether the E manipulation was clean.

**Option (a) [RECOMMENDED — spec-faithful]:**  
Fix `VoteReceipt.tsx` E2 to render `"Your vote is private and verifiable."` — no absent-choice
signal, matching paper + design note. Update `VoteReceipt.test.tsx` APV-PIUP-02 assertions
(3 occurrences). Also syncs design note §6.1 line 159: `"Your ballot was counted"` →
`"Your vote was cast"` (a minor status-line text that was corrected in the paper at tick-4037
but never synced to the design note).

**Option (b) [implementation-as-spec]:**  
Update paper §5.3 + design note §6.1 to match the current implementation: E2 shows
`"Your vote choice is not shown on this receipt."` Requires rewriting the E factor
description, H2.1 rationale (to reflect the weakened contrast), and study2-host
screenshot validation. No code changes needed.

---

## Recommendation: (a) — fix the code to match the spec

**Why option (a) is clearly better:**

1. **Research validity.** Option (a) gives you a clean E contrast. Option (b) weakens H2.1
   and requires you to disclose the weakened manipulation to reviewers. CHI reviewers who
   know the priming literature will notice immediately that "Your vote choice is not shown
   on this receipt" is a partial answer to Q-AC.

2. **Pre-registration alignment.** The instrument §11 and design note §6.1 already specify
   the generic privacy note. Option (a) makes the code conform to what was documented.
   Option (b) moves the pre-specified design post-hoc to match a coding error.

3. **Low cost.** The code change is one line in `VoteReceipt.tsx` and three test assertion
   updates. The apply script does all of it automatically and passes 5/5 checks.

4. **No OSF amendment.** Both options leave the pre-specified E factor description intact
   conceptually — option (a) just makes the implementation match. No registration change needed.

**The only reason to choose (b)** would be if Study 2 stimuli have already been finalised,
screenshots taken, and Prolific participants already seen the "not shown" phrasing. But §5.6
states Study 2 is at design-note stage and requires Study 1 pilot data before finalisation —
so the code hasn't been used in production yet. Fix it now.

---

## Secondary sync item (applies regardless of option chosen)

Design note §6.1 line 159 still reads `"Your ballot was counted"` for the status line.
This was corrected in the paper at tick-4037 to match the actual VoteReceipt.tsx text
(`"Your vote was cast"`), but the design note was never synced.

`apply-u.py --apply` fixes this as part of the option (a) changes. If you choose option (b),
you'd need to fix this manually in the design note.

---

## How to apply

```bash
cd aztec-private-voting

# Confirm 5/5 checks still pass:
python3 scripts/apply-u.py

# Apply option (a):
python3 scripts/apply-u.py --apply

# Verify tests still pass:
npm test --prefix packages/react/

# Commit:
git add packages/react/src/components/VoteReceipt.tsx \
        packages/react/src/components/VoteReceipt.test.tsx \
        docs/piup-study2-design-note-2026-06-22.md \
        drafts/piup-chi-paper-draft-2026-06-22.md
git commit -m 'fix E2 copy: VoteReceipt.tsx + tests + design note §6.1 — JONY-ACTION U option (a) applied'
```

---

## Status after U

| What | Before | After (a) | After (b) |
|---|---|---|---|
| `VoteReceipt.tsx` E2 text | "Your vote choice is not shown…" | "Your vote is private and verifiable." | no change |
| `VoteReceipt.test.tsx` APV-PIUP-02 | 3× "not shown" assertion | 3× "private and verifiable" | no change |
| Design note §6.1 E2 text | already "Your vote is private and verifiable." | confirmed ✅ | updated to match impl |
| Design note §6.1 status line | "Your ballot was counted" | "Your vote was cast" | "Your vote was cast" |
| Paper §5.3 | JONY-ACTION U note removed, option (a) marker added | ✅ | different text added |
| Open JAs | 24 | 23 (U closed) | 23 (U closed) |

**After option (a): U is the last real-choice JA. The remaining 23 JAs are all batch-approvable
or have clear recommendations (or are OSF upload dependencies).**

_See: docs/jony-approval-cheatsheet-2026-06-29.md for full batch-approval path._
