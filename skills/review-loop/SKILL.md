---
name: review-loop
description: Use when the user says "review loop".
---

# review-loop

This is a workflow for making your code changes more correct before landing
them on `main`. tl;dr - have a fresh Claude subagent review your branch in a
loop until you both agree.

The reviewer has none of your context. That is the point: it reads the code,
not your reasoning. Brief it with the code and the intent, never with your
conclusions.

`main` in this skill, and `<base>` in its commands, mean the base branch:
`main`, unless the request passes `--base <branch>` or names another base. See `land` for how the base
is chosen, and pass the same base to every skill this one uses.

Make the most minimal possible changes to appease the reviewer. Be careful of
scope creep and don't be scared to push back.

## Budget

- Default: 3 rounds total. Round 1 is full. Later rounds check only
  changed code and open findings.
- Extend to 5 only for security, permissions, auth, data loss, or
  state/concurrency, while a blocker or should stays open with evidence. Or when
  the user asks.
- Stop early if a round returns only nits. Declined nits and comment,
  doc, or format-only fixes need no new round.
- One reviewer only. The reviewer must not start subagents.
- Keep a ledger: id, severity, outcome. Never guess it.

## 1. Scope

Run `git status --short`. Do not stash, discard, or include unrelated
changes. Limit review to the change paths if they separate cleanly.
Otherwise stop and ask.

The diff base is `git merge-base HEAD <base>`.

The change is base to working tree in those paths, with untracked files.
Use one diff command all rounds. State intent and out-of-scope in 1-2
sentences. Run covering checks. Do not send code this change breaks. Note
missing or pre-failing checks in the brief.

## 2. Start the reviewer

Start one subagent with the Agent tool. Use the strongest model available,
unless the user named one. Save its name so you can continue it later.

Do not edit scoped files while review runs. Wait for its completion notice. Do
not poll, and do not start a second reviewer. A timeout, an error, or no reply
is not approval. On failure, stop it, then restart with the ledger.

Round 1 brief:

```
Review only. Do not edit, commit, push, or start subagents.
Repo: <abs path> Base: <sha> Intent: <intent> Out of scope: <scope> Checks: <results>
See: git diff <base> [-- <paths>]; git status --short (read untracked).
Read surrounding code. Find bugs, broken callers, mismatch with intent.
Skip style unless it hides a bug. Hold to the smallest change. Flag code,
tests, or guards the intent does not need. Other paths, rare cases, small
perf, extra compat: nits.
blocker = intended case wrong. should = real bug callers will hit, in intent. nit = rest.
Reply:
VERDICT: APPROVE or CHANGES
S1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion> (stable ids)
```

## 3. Answer findings

Check each finding and severity yourself. Another path, rare case, or
small cost is a nit, whatever label it came with.

- Agree: smallest fix. Prefer delete or narrow over new lock, cache,
  helper, or option. Fix the case that happened. Add one focused test
  that fails without the fix, if intent needs it.
- Disagree: say why, with evidence (file:line, test, output).
- Out of scope or nit: decline in one line. List as follow-up.

If the change is already committed, commit each fix with
`git commit --fixup=<sha>` against the commit it fixes, so `land` can fold it
in. Update the ledger. Re-run checks and
`git diff --shortstat <base>`. If review grew the diff, cut first. Do not agree
just to end the loop.

## 4. Next round

Start one only if budget remains and a blocker or should is open, behavior code
changed, or approval does not cover the current behavior diff. Continue the
same reviewer with SendMessage. If it is gone, start a fresh one with the round
1 brief. Send the ledger (`fixed:` / `disagree:` / `declined:` + evidence), the
same base diff, and the change since last round. Tell the reviewer: open ids
and changed code only. Mark each old id `resolved` or `still open: <reason>`.

## 5. Stop

Agreed: APPROVE on the current behavior diff, no blocker or should open,
no concern of your own. Stuck: an item stays disputed after two replies,
or budget ends. Show both sides in 2-3 lines each. The user decides.
Budget end is not approval.

Do not land during the loop. Land after agreement only if the user asked to
land or ship, using the `land` skill.

Report: rounds, model, what the reviewer changed, diff size before/after, fixed
and declined findings with reasons, landed or not.
