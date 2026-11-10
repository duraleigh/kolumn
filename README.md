# Kolumn

A board app for small teams: cards on boards, To-do / Later / Done, and self-tidying of stale
cards. It works offline and syncs when back online. Android first, built with Flutter; Windows,
Mac and iPhone come later from the same code.

Inspired by the behavior of 37signals' Fizzy. Written from scratch, with no Fizzy code.

## Layout

- `mockups/` — Phase 1 sample screens, as Design canvas source files (`project/*.dc.html`). Light
  theme (ConvoMail style) and dark theme, at phone, small-phone, large-phone and tablet sizes.
  `Main.dc.html` is the interactive prototype; every other screen reuses it with different
  settings.
- `app/` — the Flutter app (from Phase 2).
- `server/` — the sync server (from Phase 3).

## Rules for this repo

This repository is public. Never commit keys, passwords, signing files or `.env` files.
