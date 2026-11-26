---
name: browser
description: Drive a headless browser with Playwright to see or use a web page or local app, or the user's own signed-in Chrome through browse when a site needs their logins or blocks bots. Use for screenshots, before/after proof, clicking through a flow, checking what a page renders or logs, or browsing a site such as Reddit for the user.
---

# Browser

Playwright, `playwright-cli` and headless Chromium are installed globally on
this machine.

- **Drive it live:** `playwright-cli -s=<name> open --browser=chromium <url>`,
  then `snapshot`, `click <ref>`, `type`, `screenshot` and so on, each acting on
  the same open page (`playwright-cli --help`). Pass a unique `-s=<name>` on
  every command, since the default session is shared with other agents, and
  `close` it when done. `open` needs `--browser=chromium`. Output goes to
  `.playwright-cli/` in the folder it starts from, so start it outside the
  repo. It refuses `file:` URLs, so serve pages over HTTP.
- **Script it:** a short CommonJS script that does `require('playwright')`,
  run with `NODE_PATH="$(npm root -g)" node script.cjs`.

Live suits exploring an unfamiliar UI. A script is often simpler for a known
flow, and you can rerun it, such as on the old and new code for before/after.

Read screenshots yourself to check them, then show them to the user. Keep
scripts and captures outside the repo.

## The user's own browser

Headless Playwright is the default. Use the user's real Chrome instead, through
the browse MCP tools (`mcp__browse__*`), only when a site needs their sign-ins
or turns headless browsers away, such as reading Reddit or a logged-in
dashboard for them. Never use it for local apps or before/after shots.

- It acts as the user, with their accounts. Reading and looking around are
  fine; ask before anything that posts, sends, buys, deletes or changes a
  setting.
- Call `status` first. If no browser is connected, follow its `nextStep`. On a
  machine without a display, the user's Chrome runs on a virtual desktop: if
  it isn't running, start it there with the `desktop` skill and its usual
  profile, so their sign-ins carry over.
- Hand sign-ins, 2FA, captchas and payments to the user with `handoff`, and
  tell them where to find the tab.
- Close the tabs you opened when done.
