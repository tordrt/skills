---
name: ready
description: Get the current branch ready to land, without landing it. Reviews with /code-review at a depth matched to the change's risk, fixes what the branch got wrong, rebases and tidies, and captures before/after proof. Use when the user asks to get a branch ready, or when another skill hands off to it.
---

# Ready

Take the current branch to reviewed, rebased, tidy, and proven, then hand it
to the user, who verifies and lands it. Only the user moves `<base>` to the
branch.

`<base>` is chosen as `land` describes. Pass it on to `land`.

Invoking this skill is permission to run the app, drive a browser, and take
screenshots for proof.

## Steps

1. **Scope.** Work on a task branch, with this work committed. Review
   everything since the merge base with `<base>`.
2. **Pick the depth**, unless the user named one. Always name the level,
   because `/code-review` with no level reuses the last one typed.
   - `low`: only prose that nothing runs or follows as instructions, such as
     docs, copy, or comments.
   - `high`, plus one `/security-review`: anything that touches a trust
     boundary, such as auth, secrets, or a network or IPC surface.
   - `medium`: everything else.

   A repo's `REVIEW.md` may say which paths get which level.
3. **Review** with `/code-review <level> <target>`. Sort each finding, from
   either review, into one of:
   - **Fix:** this branch caused it, and it should be fixed before this
     ships. Commit as `--fixup`.
   - **Pre-existing:** the same behavior is on `<base>`. Report it; don't fix
     it here.
   - **Decline:** say why in one line.

   Review again only if a fix changed a design or code beyond the flagged
   lines, at most 3 rounds in total. Skip findings you already declined.
4. **Rebase and tidy** with `land`, through its recheck step. Note the review
   in the body of the commit it covers, such as
   `Reviewed with /code-review (medium): 2 rounds.`
5. **Prove it** on the final head: before/after screenshots for visual changes
   (run `<base>` from a temporary worktree for the before, and remove it
   after), the bug reproduced and then fixed, or otherwise a run showing it
   works. If the proof fails, fix it and repeat from step 4.
6. **Hand off.** Report the branch and its commits, the review level and
   rounds, what review fixed, what was pre-existing and what you declined, the
   checks, paths to the screenshots, and how the user can run it. Say
   "land it" fast-forwards `<base>` when the user is happy.
