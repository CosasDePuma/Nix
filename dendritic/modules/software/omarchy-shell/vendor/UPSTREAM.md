Vendored from https://github.com/basecamp/omarchy at commit
`43bfe9b9d82ba650b5b80eef79e94776790801c9` (2026-08-23).

Contains:
- `shell/` — the Quickshell/QML status bar and desktop shell app, unmodified.
- `config/omarchy/shell.json` — upstream's bundled default bar layout, used
  as a fallback if the user's own `~/.config/omarchy/shell.json` fails to
  parse.
- `default/omarchy/omarchy-menu.jsonc` — the default menu tree the menu
  plugin loads from `$OMARCHY_PATH/default/omarchy/`; without it the menu
  opens empty.
- `default/omarchy/launcher.hides` — app ids hidden from the apps provider.

Not vendored: `bin/omarchy-*` helper scripts. The bar renders read-only
status (clock, workspaces, tray, audio/network/bluetooth/battery state via
Quickshell's own services) without them; widgets whose *actions* shell out
to a missing `omarchy-*` script (e.g. switching audio output, toggling
bluetooth power) will not work until those scripts are ported. The menu
rows that invoke them (capture, reminders, emoji insert...) open but their
actions fail until `omarchy-cli` lands.
