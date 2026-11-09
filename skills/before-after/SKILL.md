---
name: before-after
description: Take before/after screenshots of a visual change, with the differences boxed, and nothing else. No review, rebase, or commits. Use when the user wants before and after shots while iterating on a change, or when another skill needs them.
---

# Before/after

Show what a change looks like next to how it looked before, with each
difference marked, so the user can iterate on it. This only takes pictures.
Don't review, commit, rebase, or change code, unless the user asks.

The deliverable is a folder under `/tmp/before-after/` named after the branch.
Use the same folder for each round of that change. Keep scratch files in a
separate temporary directory outside the repo, and don't report them to the
user.

Invoking this skill is permission to run the app, drive a browser, and take
screenshots.

## Sides

- **After:** the working tree as it is now, uncommitted edits included.
- **Before:** `<base>`, picked as `land`'s "Base branch" section describes
  (its other checks don't apply here), unless the user names another ref,
  such as `HEAD` to see only the uncommitted edits, or an earlier commit on
  the branch to compare against a previous round. When the
  current branch is `<base>`, the before is `HEAD`.

Run the before from a temporary worktree at that ref
(`git worktree add --detach <scratch-dir> <ref>`), and remove it once its
shots are taken. Pick ports that don't clash with an app already running.

## Steps

1. **Pick the shots:** which pages, components, or states show the change,
   and at what viewport. Use what the user named; otherwise pick the fewest
   that cover it, and say which.
2. **Take each pair** at the same viewport, size, and state, with the page
   settled: fonts loaded, animations off, and clocks or other live content
   frozen or masked. Use `browser`, `electron`, or `desktop` as fits the app.
   Save every image outside the repo, in a scratch directory.
3. **Mark the differences.** Run
   `mark-diff.sh <before.png> <after.png> <out-dir>` from this skill's
   directory, with a scratch out-dir of its own, since it writes
   `before.png` and `after.png` there and would overwrite the shots. It
   needs ImageMagick 7. It pads the pair to one canvas, boxes each changed
   region on both padded copies (numbered when there are several), writes a
   side-by-side, keeps the unmarked copies, and prints each box. It
   also copies the side-by-side into `BEFORE_AFTER_DIR`. Give each run a `SHOT_NAME` that says what the shot
   is, such as `<repo>-<branch>-<page>-<round>`. Its header lists the knobs
   for noise and for merging nearby changes.
   - When content only moved because something above it was added or
     removed, the diff boxes all of it. Then box the added or removed part
     and say what moved, instead of handing over a box around everything
     that shifted.
   - A difference nothing in the change caused, such as rendering noise,
     means retaking the pair. After two retakes, raise the noise threshold or
     mask the region, and say so.
4. **Report** the path to each new side-by-side in that change's folder, and
   what each box shows. Point out anything that looks unintended, but leave
   fixing it to the user, unless they ask.

## Next rounds

When the user asks for new shots after more edits, use the same per-change
folder and retake only the after if
the before ref still points at the same commit and the shots, viewport, and
state are unchanged. Reuse the earlier before shots (not the padded copies
`mark-diff.sh` wrote). Each new side-by-side gets its own `SHOT_NAME`, so
earlier shots from that change stay put to compare.
