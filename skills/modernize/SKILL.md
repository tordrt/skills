---
name: modernize
description: >-
  For getting old branches up to date. Use when asked to rebase an old branch
  or "modernize".
---

# Modernize

Modernize the idea, not just the branch. A clean rebase does not prove that the
branch still belongs in the product.

`main` in this skill, and `<base>` in its commands, mean the base branch:
`main`, unless the request passes `--base <branch>` or names another base. See `land` for how the base
is chosen, and pass the same base to every skill this one uses.

## Guardrails

- Fetch first, and sync `main` with its upstream the way `land` describes.
- Treat existing worktree changes as user-owned. If the branch is checked out
  in another worktree, work there only if it is clean. Otherwise ask.
- Modernizing authorizes rebasing and updating the branch. It does not
  authorize landing it, deleting it, or expanding scope.
- Never use an unqualified force push. If the branch exists on the remote,
  update it with `--force-with-lease` against the head SHA observed before the
  rebase.

## Establish the branch's intent

Record the branch, its current head SHA, and its merge base with `main`. Read
every commit message and the complete diff from the merge base, plus any notes,
issues, or plans the commits mention. State the smallest coherent goal the
branch was trying to accomplish before judging its implementation.

## Check what changed around it

Inspect commits added to `main` since the branch diverged
(`git log <merge-base>..<base>`), and their diffs. Search `main`'s history and
other branches when commit messages, code paths, or behavior suggest a
replacement or competing implementation.

Look beyond overlapping lines:

- Has the same user-facing problem already been solved?
- Did APIs, types, schemas, dependencies, or architectural boundaries change?
- Do both sides now claim ownership of the same behavior or invariant?
- Was the code being changed deleted, moved, or intentionally simplified?
- Would landing the branch restore an old behavior or create two ways to do the
  same thing?
- Is the original benefit still large enough to justify the maintenance cost?

Do not describe a branch as current merely because Git reports no conflicts.

## Choose a disposition before rebasing

Use one of these recommendations:

- **MODERNIZE**: the goal is still useful and the implementation remains the
  right shape. Rebase, resolve conflicts, test, and update the branch.
- **REWORK**: the goal is still useful, but a mechanical rebase would preserve
  the wrong implementation. Explain the smallest credible rewrite and stop
  before rebasing unless the user also asked for that rework.
- **DROP**: the branch is superseded, obsolete, directionally wrong, or no
  longer worth its cost. Cite concrete evidence and stop. Do not spend time
  rebasing an obsolete branch, and do not delete it without explicit
  permission.

Be willing to recommend `DROP`. Age alone is not evidence, and sunk effort is
not a reason to keep a branch alive.

## Rebase without losing intent

For a `MODERNIZE` disposition:

1. Record the branch head so you can compare and recover.
2. Rebase its commits onto `main`.
3. Resolve each conflict according to the branch's intent and `main`'s newer
   invariants. If a conflict reveals a product or architecture disagreement,
   stop and reconsider the disposition instead of guessing.
4. Compare the pre-rebase and post-rebase commit series with `git range-diff`
   and inspect the final diff. Confirm that no intentional behavior disappeared
   and no already-landed behavior was reintroduced.
5. Run the repository's focused checks for the touched area. Distinguish real
   failures from pre-existing or infrastructure failures.
6. If the branch exists on the remote, push with `--force-with-lease` tied to
   the previously observed remote head. If the lease fails, fetch and reassess
   rather than overwriting new work.

Do not land the branch.

## Report

Lead with `MODERNIZE`, `REWORK`, or `DROP` and the reason. Then summarize:

- meaningful changes on `main`;
- conceptual conflicts or confirmation that none were found;
- the rebase result, and the push result if performed;
- checks run and their results;
- the remaining decision or work.

Separate observed facts from judgment. Say what could not be verified instead
of manufacturing confidence.
