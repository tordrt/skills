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
| `ready` | `/ready` | Reviews the current branch with `/code-review` at a depth matched to its risk (up to 3 rounds), fixes what the branch got wrong, rebases and tidies, and captures before/after proof with `before-after`. Stops there, so you verify and land it yourself. |
| `before-after` | `/before-after` | Just the screenshots: shoots the working tree next to `main` (or a ref you name, like `HEAD`), with the differences boxed, and numbered when there are several (needs ImageMagick 7). No review or commits, so you can iterate before running `ready`. |
| `land` | "land it" | Syncs `main`, rebases the branch, tidies its history, rechecks, and fast-forwards `main`. In Komla, it then trashes the workspace when nothing is left to do. |
| `browser` | (automatic) | Lets agents drive a headless browser live with `playwright-cli`, or script it with Playwright, for screenshots and clicking through a flow. |
| `desktop` | (automatic) | Lets agents run GUI apps on a virtual desktop you watch in Komla, with `komla desktop run`. |
| `electron` | (automatic) | Lets agents run an Electron app under `xvfb-run`, or on a desktop you watch, to test it, screenshot it, or drive it live. |
| `modernize` | "modernize" | Rebases an old branch and decides if it should still exist. |

Every skill targets the repo's default branch (`main` or `master`). To use
another base branch, pass `--base <branch>` (for example
`/land --base release`), or just say "land onto `dev`". The skills pass it on
to each other.

Some skills call others. Install the ones they need too:

- `implement` uses `ready`.
- `ready` uses `land` and `before-after`, plus your agent's built-in code and
  security review (`/code-review` and `/security-review` in Claude Code).
- `before-after` uses `land` (for picking the base) and whichever of `browser`,
  `electron`, or `desktop` fits the app.
- `desktop` uses `browser`, and `electron` uses `browser` and `desktop`.
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
- For `browser`: Playwright and `@playwright/cli` installed globally, with
  their browsers (`npm i -g playwright @playwright/cli && npx playwright install --with-deps chromium && playwright-cli install-browser chrome-for-testing`).
- For `desktop`: Komla (formerly Baton), with `tigervnc-standalone-server`,
  `novnc` and `websockify` on the machine.
- For `electron`: `xvfb` on Linux machines without a display.

## Make them yours

Put personal settings, like not pushing when landing, in your `CLAUDE.md`, so
you can update the skills without losing them.

## License

[MIT](LICENSE), from upstream.
