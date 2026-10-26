---
name: council
description: Trigger this if the user says 'council'.
---

# Council

Bring in three delegates to help with the user's request, usually for review
or feedback. They are Claude subagents, so their independence comes from fresh
context and different lenses, not from different providers. If the user's
instructions name council members (models or lenses), use those. Otherwise use
the strongest model available for all three, with these lenses:

- **Correctness:** bugs in the intended case, broken callers, wrong
  assumptions about surrounding code.
- **Design:** does it read like the surrounding code, is the seam in the right
  place, will it be easy to change later.
- **Scope:** does it solve the user's actual problem, and what in the diff is
  not needed for that.

`main` in this skill means the base branch: `main`, unless the request
passes `--base <branch>` or names another base. See `land` for how the base
is chosen, and pass the same base to every skill this one uses.

Start all three with the Agent tool in one message, so they run in parallel.
Wait for all three completion notices before you summarize. If one fails,
report it instead of filling in its part.

Give each delegate the request, the relevant context, and its lens. For a code
review, point them at the diff (`git diff $(git merge-base HEAD main)`, plus
untracked files) and the intent. Give them the code, not your conclusions. For
review or feedback, keep their work read-only: no edits, commits, or subagents.
Collect their responses and summarize the useful findings, disagreements, and
recommended next steps.

For a code review, ask each delegate for a score out of 10.
Count each full review pass as one round.
A fresh review after fixes starts a new round.

Report the results in your reply:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Correctness | 7/10 | 9/10 |
| Design | 8/10 | 10/10 |
| Scope | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one.
When the change lands, `land` adds a one-line summary to the commit body.

If you agree with their recommendations, make the changes and request a fresh
review after. Continue the same delegates with SendMessage so they keep their
context. Continue this process until all delegates are satisfied with the
outcome.

Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.
