---
name: browser
description: Drive a headless browser with Playwright to see or use a web page or local app. Use for screenshots, before/after proof, clicking through a flow, or checking what a page renders or logs.
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
