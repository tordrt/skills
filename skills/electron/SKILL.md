---
name: electron
description: Run an Electron app headless to drive it, test it, or screenshot it, on a machine without a display. Use for e2e tests, screenshots, or checking UI of an Electron app under development.
---

# Electron

Electron needs a display. On a machine without one, wrap the command in
`xvfb-run -a`, for example `xvfb-run -a npm run test:e2e`.

- Use the project's own e2e and screenshot scripts and docs first (look for
  an `e2e/` folder or `AGENTS.md`). Many need a fresh build.
- Drive it live or with a script, whichever suits the job (see `browser`). To
  drive it live, start the app in the background with
  `--remote-debugging-port=<a free port>` passed to Electron itself, then
  `playwright-cli -s=<name> attach --cdp=http://127.0.0.1:<port>`. Run
  `-s=<name> detach` and stop the app when done. A script can use Playwright's
  `_electron.launch()`, with `executablePath` set to the project's Electron
  binary (`node -p "require('electron')"` in the project).
- Run it headless unless the user asks to watch. Then start it with
  `komla desktop run` (or `baton desktop run`) instead of `xvfb-run` (see
  `desktop`) and attach the same way.
