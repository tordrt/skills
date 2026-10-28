---
name: implement
description: Build what you described, then run ready on it, so it comes back reviewed, rebased, and proven for you to verify and land.
disable-model-invocation: true
---

# Implement

The user described a feature or a problem alongside this skill. Build it on a
task branch, then hand the branch to `ready`.

Pass any base branch the request names (`--base <branch>`) on to `ready`.

Invoking this skill is permission to run the app, drive a browser, and take
screenshots or recordings for proof.

## Steps

1. **Understand it.** For a bug, reproduce it first.
2. **Implement** the request on a task branch, and commit it. Ask only if it is
   ambiguous in a way that changes the result.
3. **Run `ready`** on the branch. Its hand-off is this skill's hand-off. The
   user verifies the branch and lands it.
