---
name: land
description: Rebase the current branch onto main, tidy its history, and fast-forward main to it. Use when the user asks to land, ship, or fast-forward main.
---

# Land

There are no pull requests. Work happens on a branch, gets rebased onto
`main`, gets reviewed, and lands when `main` fast-forwards to it. Commits land
exactly as they are on the branch, so the branch's history is what `main`
keeps.

Never create a merge commit, never rewrite `main`, and never force-push `main`.

## 1. Check the branch

Run `git status`. If uncommitted changes belong to this work, commit them. If
it is unclear whether they do, ask. If `HEAD` is `main`, there is nothing to
land.

Run `git worktree list` and note whether `main` is checked out in a non-bare
worktree. Step 6 depends on it.

## 2. Sync main

If `main` tracks a remote, run `git fetch origin`. If `origin/main` is ahead of
`main`, fast-forward `main` first:

- `main` not checked out in a non-bare worktree: `git fetch origin main:main`.
- `main` checked out at `<path>`: `git -C <path> merge --ff-only origin/main`,
  only if that worktree is clean. If it is dirty, ask.

If `main` and `origin/main` have diverged, stop and ask. Never pick a side.

## 3. Rebase

Record the branch head, then run `git rebase main`. Resolve each conflict by
the branch's intent and `main`'s newer invariants. If a conflict reveals a
product or architecture disagreement, stop and ask instead of guessing.

After the rebase, compare with `git range-diff <old-base>..<old-head> main..HEAD`.
Confirm that no intended behavior disappeared and nothing already on `main` was
reintroduced.

## 4. Tidy history

Make the commits what `main` should keep: one commit per coherent change, each
one building and passing checks on its own when practical.

Fold review fixes into the commit they fix. Make them with
`git commit --fixup=<sha>`, then run
`GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash main`. Do not squash
unrelated changes together. Do not reorder commits in a way that changes what
each commit means.

### Commit messages

Follow the repository's conventions. Look at `git log` on `main` for examples.
Prefer a concise, human-readable subject that explains why the change matters:

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

If `review-loop` or `council` reviewed the change, add one line to the body of
the commit it covers, for example
`Reviewed with council: 2 rounds (9/10, 9/10, 10/10).` Keep the co-author
trailer your harness adds. Do not add a second attribution.

Check every message for secrets and private details.

## 5. Recheck

A rebase can break code without a conflict. Run the repo's checks on the final
`HEAD`: look at what CI runs (`.github/workflows`, `package.json` scripts,
`Makefile`) and run the same commands locally. If commits that landed on `main`
since the old base touch this branch's files, prove the affected behavior again.

If the branch also exists on the remote, update it with
`git push --force-with-lease=<branch>:<old-remote-head>`. Never use a plain
`--force`.

## 6. Fast-forward main

Do this only when the user asked to land, or under `full-send`. Otherwise stop
here and report that the branch is ready.

First confirm `git merge-base --is-ancestor main HEAD` succeeds. Then:

- `main` not checked out in a non-bare worktree: `git fetch . HEAD:main`.
- `main` checked out at `<path>`: `git -C <path> merge --ff-only <branch>`,
  only if that worktree is clean. If it is dirty, ask.

Both refuse anything that is not a fast-forward. If one refuses, `main` moved:
go back to step 2. Never use `git branch -f`, `git update-ref`, or
`git reset` on `main`.

## 7. Push

Push `main` only when the user asked to push, the request was `full-send`, or
the user's instructions say landing includes pushing. Use a plain
`git push origin main`. If the push is rejected, `origin/main` moved: go back to
step 2.

If the repo runs CI on `main`, watch the run for the pushed commit with
`gh run watch`. If it fails, report it. Fix forward on a new branch. Never
revert or rewrite `main` without asking.

## 8. Report

Report the new `main` SHA, the commits that landed
(`git log --oneline <old-main>..main`), the checks you ran and their results,
and whether `main` was pushed.

Do not delete the branch or its worktree. The user cleans those up.
