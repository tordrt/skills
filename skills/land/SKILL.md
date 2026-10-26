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

The base must already exist locally, and it must not be the current branch. If
either fails, stop and ask. `origin/<base>` below means the base's upstream; if
the base tracks no remote, skip everything that mentions it.

Other skills (`full-send`, `full-stop`, `review-loop`, `council`, `modernize`)
take the same flag and pass it on to this one.

## 1. Check the branch

Run `git status`. If uncommitted changes belong to this work, commit them. If
it is unclear whether they do, ask. If `HEAD` is `<base>`, there is nothing to
land.

Run `git worktree list` and note whether `<base>` is checked out in a non-bare
worktree. Step 6 depends on it.

## 2. Sync the base

If `<base>` tracks a remote, run `git fetch origin`. If `origin/<base>` is
ahead of `<base>`, fast-forward `<base>` first:

- `<base>` not checked out in a non-bare worktree:
  `git fetch origin <base>:<base>`.
- `<base>` checked out at `<path>`:
  `git -C <path> merge --ff-only origin/<base>`, only if that worktree is
  clean. If it is dirty, ask.

If `<base>` and `origin/<base>` have diverged, stop and ask. Never pick a side.

## 3. Rebase

Record the branch head and its merge base with `<base>`, then run
`git rebase <base>`. Resolve each conflict by the branch's intent and the
base's newer invariants. If a conflict reveals a product or architecture
disagreement, stop and ask instead of guessing.

After the rebase, compare with
`git range-diff <old-merge-base>..<old-head> <base>..HEAD`. Confirm that no
intended behavior disappeared and nothing already on `<base>` was
reintroduced.

## 4. Tidy history

Make the commits what `<base>` should keep: one commit per coherent change,
each one building and passing checks on its own when practical.

Fold review fixes into the commit they fix. Make them with
`git commit --fixup=<sha>`, then run
`GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`. Do not squash
unrelated changes together. Do not reorder commits in a way that changes what
each commit means.

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

If `review-loop` or `council` reviewed the change, add one line to the body of
the commit it covers, for example
`Reviewed with council: 2 rounds (9/10, 9/10, 10/10).` Keep the co-author
trailer your harness adds. Do not add a second attribution.

Check every message for secrets and private details.

## 5. Recheck

A rebase can break code without a conflict. Run the repo's checks on the final
`HEAD`: look at what CI runs (`.github/workflows`, `package.json` scripts,
`Makefile`) and run the same commands locally. If commits that landed on
`<base>` since the old merge base touch this branch's files, prove the
affected behavior again.

If the branch also exists on the remote, update it with
`git push --force-with-lease=<branch>:<old-remote-head>`. Never use a plain
`--force`.

## 6. Fast-forward the base

Do this only when the user asked to land, or under `full-send`. Otherwise stop
here and report that the branch is ready.

First confirm `git merge-base --is-ancestor <base> HEAD` succeeds. Then:

- `<base>` not checked out in a non-bare worktree: `git fetch . HEAD:<base>`.
- `<base>` checked out at `<path>`: `git -C <path> merge --ff-only <branch>`,
  only if that worktree is clean. If it is dirty, ask.

Both refuse anything that is not a fast-forward. If one refuses, `<base>`
moved: go back to step 2. Never use `git branch -f`, `git update-ref`, or
`git reset` on `<base>`.

## 7. Push

Push `<base>` only when the user asked to push, the request was `full-send`,
or the user's instructions say landing includes pushing. Use a plain
`git push origin <base>`. If the push is rejected, `origin/<base>` moved: go
back to step 2.

If the repo runs CI on `<base>`, watch the run for the pushed commit with
`gh run watch`. If it fails, report it. Fix forward on a new branch. Never
revert or rewrite `<base>` without asking.

## 8. Report

Report the base branch, its new SHA, the commits that landed
(`git log --oneline <old-base-sha>..<base>`), the checks you ran and their
results, and whether `<base>` was pushed.

Do not delete the branch or its worktree. The user cleans those up.
