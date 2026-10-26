---
name: full-stop
description: Trigger this if the user says 'full stop'.
---

# Full Stop

Do the same work as `full-send`, but stop with the branch ready for the user to
fast-forward `main`. Never move `main`.

Read [full-send](../full-send/SKILL.md) and follow its workflow, proof rules,
and review steps. An explicit "full stop" request authorizes that work without
a separate "full send" request. That includes full-send's testing permission.
A "full stop" request is the permission for the test methods Proof needs, even
when a project file says to ask first, for example before computer use. Use
those methods directly. Its permission to fast-forward and push `main` does not
apply. The overrides below take precedence.

## Never move main

You may commit, rebase, fold in fixups, fix conflicts, and use
`--force-with-lease` on this task's branch. You may fast-forward local `main`
to `origin/main` while syncing, as `land` describes, because that only catches
`main` up. Never fast-forward `main` to the branch, push `main`, or delegate
those actions.

## Stop at the gate

Follow `land` through its recheck step, then stop. Use full-send's land gate as
the readiness check. Replace its fast-forward and final report steps with a
handoff. Proof and review must cover the final diff; recheck behavior changes
and meaningful conflict fixes before handoff.

Right before the handoff, run `git fetch` if `main` tracks a remote, and confirm
the branch still sits on the latest `main`.

- **Ready to land:** the land gate passes. Leave `main` where it is.
- **Blocked:** explain what prevents readiness, what you tried, and what is
  needed. Follow full-send's rules for asking the user.

Report the branch, final head, verdict, proof, reviewer outcome, and remaining
risks. Give the user the exact fast-forward command from `land` step 6 for this
checkout, or say they can ask you to land it.
