---
name: desktop
description: Run a GUI app on a virtual desktop the user can watch, with `komla desktop run`. Use to show the user a desktop or Electron app, or anything else that needs a display.
---

# Desktop

On a machine without a display, `komla desktop run -- <command> [args]` runs a
GUI app on a virtual desktop of its own, which opens in Komla's browser preview
for the user (`--app` opens their VNC app instead). It blocks until the app
exits, and the desktop stops with it, so run it in the background. Where `komla`
is not on PATH yet, the CLI is still called `baton`.

- `komla desktop status` lists running desktops, with each one's browser view
  URL and the `DISPLAY` and `XAUTHORITY` for starting more apps on it.
- To see it yourself, screenshot its browser view URL with Playwright (see
  `browser`) once it has connected. In the URL, change `resize=remote` to
  `resize=scale` and add `view_only=1`, so you neither resize nor control the
  user's desktop.
- `komla desktop stop :<n>` stops a desktop you started. Without a number it
  stops every desktop, including the user's.
