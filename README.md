# skills

Testing out a fork of [t3dotgg/tstack](https://github.com/t3dotgg/tstack),
adapted to how I work:

- **No pull requests.** Work happens on a branch, gets rebased onto `main` and
  reviewed locally, and lands when `main` fast-forwards to it.
- **One agent: Claude Code.** Reviews that used other providers' models now use
  Claude Code's `/code-review`. Codex and T3 Code specifics are gone.

## Skills

| Skill | Say | What it does |
|---|---|---|
| `implement` | `/implement <what to build>` | Builds what you describe, then runs `ready` on it. |
| `ready` | `/ready` | Reviews the current branch with `/code-review` (up to 3 rounds), fixes what should be fixed, rebases and tidies, and captures before/after proof. Stops there, so you verify and land it yourself. |
| `land` | "land it" | Syncs `main`, rebases the branch, tidies its history, rechecks, and fast-forwards `main`. |
| `modernize` | "modernize" | Rebases an old branch and decides if it should still exist. |

Every skill targets `main` by default. To use another base branch, pass
`--base <branch>` (for example `/land --base release`), or just say "land onto
`dev`". The skills pass it on to each other. To change the default for one
repo, set it in that repo's `CLAUDE.md`.

Some skills call others. Install the ones they need too:

- `implement` uses `ready`.
- `ready` uses `land`, plus your agent's built-in code review
  (`/code-review` in Claude Code).
- `modernize` refers to `land`.

## Changes from upstream

Forked from tstack at
[`7de017b`](https://github.com/t3dotgg/tstack/commit/7de017b). To see what
changed since, compare upstream's `7de017b..main`.

| Upstream | Here |
|---|---|
| `full-send`, `full-stop` | Dropped. `implement` does the same work, and stops before fast-forwarding `main`. |
| `sol-loop` | Dropped. `ready` reviews with `/code-review` instead. |
| `council` | Dropped. |
| `file-pr` | Folded into `land` as commit message rules, since commits land as they are. |
| `babysit-pr` | Its rebase and merge rules are in `land`. PR, CI, and review bot watching is dropped, along with `pr-wait`. |
| `modernize` | Kept, for branches instead of PRs. `CLOSE` is now `DROP`. |
| `takeover`, `leaving-pr-comments` | Dropped. |
| `agents/openai.yaml` | Dropped (Codex only). |

## Install

```bash
git clone https://github.com/tordrt/skills
mkdir -p ~/.claude/skills
cp -R skills/skills/* ~/.claude/skills/
```

Copying only adds skills. If you installed an older version, delete the ones
this repo dropped, such as `~/.claude/skills/review-loop`.

## Requirements

- `git`. `land` handles a `main` that is checked out in another worktree, and
  bare-repo worktree setups.
- Optional: an authenticated [GitHub CLI](https://cli.github.com) (`gh`), so
  `land` can watch CI on `main` after a push.

## Make them yours

Put personal settings, like whether landing should push `main`, in your
`CLAUDE.md`, so you can update the skills without losing them.

## License

[MIT](LICENSE), from upstream.
