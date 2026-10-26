# skills

Testing out a a fork of [t3dotgg/tstack](https://github.com/t3dotgg/tstack),
adapted to how I work:

- **No pull requests.** Work happens on a branch, gets rebased onto `main` and
  reviewed locally, and lands when `main` fast-forwards to it.
- **One agent: Claude Code.** Reviews that used other providers' models now use
  fresh Claude subagents. Codex and T3 Code specifics are gone.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `full-send` | "full send" | Takes a change to landed on `main` with nobody watching: proves it, reviews it, rebases it, fast-forwards `main`, pushes it. |
| `full-stop` | "full stop" | Same as `full-send`, but stops when the branch is ready for you to fast-forward `main`. |
| `review-loop` | "review loop" | Reviews a change with a fresh Claude subagent in a loop until both agents agree. |
| `council` | "council" | Gets review from three Claude subagents with different lenses, and loops until they agree. |
| `land` | "land it" | Syncs `main`, rebases the branch, tidies its history, rechecks, and fast-forwards `main`. |
| `modernize` | "modernize" | Rebases an old branch and decides if it should still exist. |

Some skills call others. Install the ones they need too:

- `full-send` uses `review-loop` and `land`.
- `full-stop` uses `full-send` and `land`.
- `review-loop`, `council`, and `modernize` refer to `land`.

## Changes from upstream

Forked from tstack at
[`7de017b`](https://github.com/t3dotgg/tstack/commit/7de017b). To see what
changed since, compare upstream's `7de017b..main`.

| Upstream | Here |
|---|---|
| `full-send`, `full-stop` | Kept. The merge gate is now a land gate, and merging is a fast-forward of `main`. |
| `sol-loop` | Now `review-loop`: the same loop, with a Claude subagent instead of GPT Sol. |
| `council` | Kept. Three Claude subagents with different lenses instead of three providers. Scores go in the reply and the commit body, not a PR description. |
| `file-pr` | Folded into `land` as commit message rules, since commits land as they are. |
| `babysit-pr` | Its rebase and merge rules are in `land`. PR, CI, and review bot watching is dropped, along with `pr-wait`. |
| `modernize` | Kept, for branches instead of PRs. `CLOSE` is now `DROP`. |
| `takeover`, `leaving-pr-comments` | Dropped. |
| `agents/openai.yaml` | Dropped (Codex only). |

## Install

```bash
git clone https://github.com/tordrt/skills
cp -R skills/skills/* ~/.claude/skills/
```

## Requirements

- `git`. `land` handles a `main` that is checked out in another worktree, and
  bare-repo worktree setups.
- Optional: an authenticated [GitHub CLI](https://cli.github.com) (`gh`), so
  `land` can watch CI on `main` after a push.

## Make them yours

Put personal settings, like which models or lenses sit on the council, or
whether landing should push `main`, in your `CLAUDE.md`, so you can update the
skills without losing them.

## License

[MIT](LICENSE), from upstream.
