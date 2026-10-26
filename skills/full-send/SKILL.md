---
name: full-send
description: Trigger this if the user says 'full send'.
---

# Full Send

If the user triggered this, it's because they are not watching this thread, and
they want you to complete the work end-to-end autonomously. Your updates and
your final message go unread until long after you stop. You own the work from
its current state until it lands on `main`.

If the user did not explicitly request "full send" in some clear way, do not
assume full autonomy. If they did, everything below applies.

`main` in this skill, and `<base>` in its commands, mean the base branch:
`main`, unless the request passes `--base <branch>` or names another base. See `land` for how the base
is chosen, and pass the same base to every skill this one uses.

The user grants you permission to:

- Rewrite this task's branch: rebase it, fold in fixups, and update its remote
  copy with `--force-with-lease`, if it has one.
- Fast-forward `main` to the branch once the land gate passes, and push `main`
  (fast-forward only, never forced).
- Use the test methods that Proof needs, without asking first.

## Testing permission

A "full send" request is the permission. If a project file or other
instruction says to ask before a test method, or to leave testing to the
user, this request replaces that rule for this task.

That includes ask-first rules for computer use, browser automation,
simulators and devices, running the app or a dev server, screenshots, and
visual checks. Use the method that gives direct proof. List it in the
report.

Rules about how to test still apply. Follow rules that name the correct
command, fixture, or check. This permission only removes the ask-first or
leave-it-to-the-user step. If a preferred method cannot prove the change,
use a gated method under this permission.

It covers only the tests needed for this task. It does not add permission
for the steps under "Asking the user", such as production changes or data
deletion. It also does not bypass a harness or system approval prompt if
one appears.

## Steps

1. **Finish the change.** Complete the goal from the user's request with the
   smallest change that works. Fix the case that happened, not every case
   that could. Commit as you go.
2. **Prove it.** Get proof for every change you made. See "Proof".
3. **Get feedback.** Use the `review-loop` skill to verify changes. Get proof
   for each fix it leads to.
4. **Land it** with the `land` skill: sync `main`, rebase, tidy history, and
   recheck on the rebased head.
5. **Push and fast-forward `main`** when the land gate passes.
6. **Report** in your final message: the commits that landed, the new `main`
   SHA, whether `main` was pushed and CI on it passed, your proof, and each
   decision you made for the user.

Stay active from step 1 to step 6. If you end your turn while a reviewer or a
check is still running, the work stops, because nobody will prompt you again.
Background subagents and commands notify you when they finish, so wait for that
notice instead of ending the turn.

## Proof

Proof is evidence you observed yourself in this session: command output, a
reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, then watch the same
  reproduction pass.
- Run the checks that the repo's CI runs (typecheck, lint, tests).
- Add one focused test that fails without the fix, when the behavior has none
  and the repo has a test setup.
- For UI and runtime behavior, run the app and look at the change. Green mocked
  tests do not prove that the user experience works.

When you cannot find a way to prove a change, you do not have full confidence.
Ask the user.

## Land gate

Full confidence means all of these are true on the final `HEAD`:

- Your proof covers every change in the diff against `main`.
- `review-loop` agreed on the current behavior diff, and each finding is fixed
  or declined with a written reason.
- The branch is rebased on the latest `main`: after a fetch,
  `git merge-base --is-ancestor <base> HEAD` succeeds, and so does
  `git merge-base --is-ancestor <upstream> HEAD` if the base has an upstream
  (see `land`).
- The repo's checks pass on the rebased head, not just before the rebase.
- The working tree is clean, review fixes are folded in, and every commit
  message follows `land`.

Never use a merge commit, rewrite `main`, or force-push `main`.

## Asking the user

A question in a normal message goes unseen, and the thread looks done. To ask
the user something, use `AskUserQuestion` so the thread shows that it is
waiting. Put all the context in the question: the branch, what blocks you, and
the options with your recommendation first.

Ask only when you cannot continue alone:

- You cannot prove the change.
- The land gate cannot pass, and you cannot fix that yourself.
- The next step is outside the grant above: deleting data, touching production,
  changing things outside the repo, deleting a branch or worktree, or
  rewriting any other branch.
- `main` and its upstream have diverged.
- The goal is ambiguous in a way that changes the result.
- Work already on `main` makes this change obsolete.

Decide everything else yourself with sensible defaults, and list those decisions
in the report.

If the tool returns no answer, take the safe path: leave `main` where it is,
and start your final message with the question.
