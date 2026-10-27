---
name: implement
description: Build what you described, review it with /code-review, prove it works (before/after screenshots for visual changes), rebase on main, then wait for your go-ahead to fast-forward.
disable-model-invocation: true
---

# Implement

The user described a feature or a problem alongside this skill. Take it from
that description to a branch that is reviewed, proven, and ready to
fast-forward `main`, then let the user decide.

`main` in this skill means the base branch: `main`, unless the request passes
`--base <branch>` or names another base. See `land`, and pass the same base to
every skill this one uses.

Invoking this skill is permission to run the app, drive a browser, and take
screenshots or recordings for proof.

## Steps

1. **Capture the before.** For a visual change, capture the current state of
   what it touches. For a bug, reproduce it.
2. **Implement** the request on a task branch. Ask only if it is ambiguous in a
   way that changes the result.
3. **Review** the branch's diff against `main` with the built-in `code-review`
   skill. Fix the findings that are real and should be fixed before this
   ships. Note the rest, and why.
4. **Prove it.** Run the tests, typecheck, lint, and build. For a visual change,
   capture the after, paired with the before. Otherwise, verify that it works.
5. **Rebase and tidy** with `land`, through its recheck step. Squash commits
   that belong together, so `main` keeps a clean history. It is ready only
   when the tests pass on the rebased head. If the rebase changed code, prove
   it again.
6. **Hand off.** Show what you built, the review outcome, and the proof. Ask
   with `AskUserQuestion` whether to fast-forward `main`, and wait. Move `main`
   only on a yes, using `land`. If `main` moved in the meantime, rebase, prove
   it again, and ask again.
