---
name: land
description: Rebase the current branch onto main (or another base branch), tidy its history, and fast-forward the base to it. Use when the user asks to land, ship, or fast-forward main.
---

# Land

There are no pull requests. Work happens on a branch, gets rebased onto a base
branch, gets reviewed, and lands when the base fast-forwards to it. Commits
land exactly as they are on the branch, so the branch's history is what the
base keeps.

Never create a merge commit, never rewrite `<base>`, and never force-push
`<base>`.

## Base branch

`<base>` below is `main` unless one of these names another branch, first match
wins:

1. `--base <branch>` in the request or skill arguments, or plain words like
   "land onto `<branch>`" or "rebase on `<branch>`".
2. A default base the user's instructions set for this repo.

The base must already exist locally. If it does not, stop and ask.

`<upstream>` below is the base's upstream, from
`git rev-parse --abbrev-ref <base>@{upstream}` (for example `origin/main`).
`<remote>` and `<remote-base>` are its two parts. If the base has no upstream,
skip everything that mentions them.

Other skills (`implement`, `review-loop`, `modernize`) take the same flag and
pass it on to this one.

## 1. Check the branch

Run `git status`. If uncommitted changes belong to this work, commit them. If
it is unclear whether they do, ask. If `HEAD` is `<base>`, stop: there is
nothing to land.

Record the branch head. If the branch has an upstream of its own, record
`git rev-parse @{upstream}` now, before any fetch. That SHA is the lease for
step 5.

Run `git worktree list` and note whether `<base>` is checked out in a non-bare
worktree. Steps 2 and 7 depend on it.

## 2. Sync the base

Run `git fetch <remote>`. If `<upstream>` is ahead of `<base>`, fast-forward
`<base>` first:

- `<base>` not checked out in a non-bare worktree:
  `git fetch <remote> <remote-base>:<base>`.
- `<base>` checked out at `<path>`:
  `git -C <path> merge --ff-only <upstream>`, only if that worktree is clean.
  If it is dirty, ask.

If `<base>` and `<upstream>` have diverged, stop and ask. Never pick a side.

## 3. Rebase

Record the branch's merge base with `<base>`, then run `git rebase <base>`.
Resolve each conflict by the branch's intent and the base's newer invariants.
If a conflict reveals a product or architecture disagreement, stop and ask
instead of guessing.

After the rebase, compare with
`git range-diff <old-merge-base>..<old-head> <base>..HEAD`. Confirm that no
intended behavior disappeared and nothing already on `<base>` was
reintroduced.

## 4. Tidy history

Make the commits what `<base>` should keep: one commit per coherent change,
each one building and passing checks on its own when practical.

Fold review fixes into the commit they fix. Make them with
`git commit --fixup=<sha>`, then run `git rebase --autosquash <base>`. On git
older than 2.44, use `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`
instead. Do not squash unrelated changes together. Do not reorder commits in a
way that changes what each commit means.

### Commit messages

Follow the repository's conventions. Look at `git log` on `<base>` for
examples. Prefer a concise, human-readable subject that explains why the
change matters:

BAD

> ❌ perf(server): negotiate permessage-deflate on the websocket

GOOD

> ✅ perf(server): cut websocket frame size by 70%+ with gzipping

Open the body with the problem, based on the user's original prompt, then
briefly explain the solution. Do not lead with an inventory of changes:

BAD

> ❌ Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD

> ✅ My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

If `review-loop` reviewed the change, add one line to the body of the commit it
covers, for example `Reviewed with review-loop: 2 rounds.` Keep the co-author
trailer your harness adds. Do not add a second attribution.

Check every message for secrets and private details.

## 5. Recheck

A rebase can break code without a conflict. Run the repo's checks on the final
`HEAD`: look at what CI runs (`.github/workflows`, `package.json` scripts,
`Makefile`) and run the same commands locally. If commits that landed on
`<base>` since the old merge base touch this branch's files, prove the
affected behavior again.

If the branch has an upstream of its own, update it with
`git push --force-with-lease=<remote-branch>:<sha-from-step-1> <remote> HEAD:<remote-branch>`.
Never use a plain `--force`. If the lease fails, someone else pushed to the
branch: fetch and reassess rather than overwriting their work.

## 6. Push

Do steps 6 and 7 only when the user asked to land.
Otherwise stop here and report that the branch is ready.

Push before you move the local base, so a rejected push leaves nothing to undo.
Push only when the user asked to push, or the user's instructions say landing
includes pushing. Otherwise skip to step 7.

First confirm `git merge-base --is-ancestor <upstream> HEAD` succeeds. Then
run a plain `git push <remote> HEAD:<remote-base>`. The remote accepts only a
fast-forward. If it rejects the push, `<upstream>` moved: go back to step 2.

## 7. Fast-forward the base

Confirm `git merge-base --is-ancestor <base> HEAD` succeeds. Then:

- `<base>` not checked out in a non-bare worktree: `git fetch . HEAD:<base>`.
- `<base>` checked out at `<path>`: `git -C <path> merge --ff-only <branch>`,
  only if that worktree is clean. If it is dirty, ask.

Both refuse anything that is not a fast-forward. If one refuses before a push,
`<base>` moved: go back to step 2. If one refuses after a push, stop and ask.
Never use `git branch -f`, `git update-ref`, or `git reset` on `<base>`.

If you pushed and the repo runs CI on `<base>`, watch the run for the pushed
commit with `gh run watch`. If it fails, report it. Fix forward on a new
branch. Never revert or rewrite `<base>` without asking.

## 8. Report

Report the base branch, its new SHA, the commits that landed
(`git log --oneline <old-base-sha>..<base>`), the checks you ran and their
results, and whether `<base>` was pushed.

Do not delete the branch or its worktree. The user cleans those up.
