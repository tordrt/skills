---
name: ready
description: Get the current branch ready to land, without landing it. Reviews with /code-review for up to 3 rounds, fixes what should be fixed, rebases and tidies, and captures before/after proof. Use when the user asks to get a branch ready, or when another skill hands off to it.
---

# Ready

Take the current branch to reviewed, rebased, tidy, and proven, then hand it
to the user, who verifies and lands it. Only the user moves `<base>` to the
branch.

`<base>` is `main` unless the request names another (`--base <branch>`). Pass
it on to `land`.

Invoking this skill is permission to run the app, drive a browser, and take
screenshots for proof.

## Steps

1. **Scope.** Work on a task branch, with this work committed. Review
   everything since the merge base with `<base>`.
2. **Review** with `/code-review`, passing that target explicitly. Fix what
   should be fixed before this ships, as `--fixup` commits, and note what you
   declined and why. Run another round only if the fixes changed behavior, up
   to 3 rounds, each covering just the new fixups and open findings.
3. **Rebase and tidy** with `land`, through its recheck step. Note
   `Reviewed with /code-review: <n> rounds.` in the commit body while tidying.
4. **Prove it** on the final head: before/after screenshots for visual changes
   (run `<base>` from a temporary worktree for the before), the bug reproduced
   and then fixed, or otherwise a run showing it works. If the proof fails,
   fix it and repeat from step 3.
5. **Hand off.** Report the branch and its commits, what review fixed and
   declined, the checks, paths to the screenshots, and how the user can run it.
   Say "land it" fast-forwards `<base>` when the user is happy.
