---
name: cmux
description: "Control and troubleshoot cmux windows, workspaces, panes, surfaces, browser panels, settings, shortcuts, custom commands, and workspace-safe automation. Use for cmux topology/routing, current workspace operations, browser automation in cmux, cmux.json edits, diagnostics, or customization."
---

# cmux

Use this skill for end-user cmux automation and configuration.

## Core Concepts

- Window: top-level macOS cmux window.
- Workspace: tab-like group within a window.
- Pane: split container in a workspace.
- Surface: a tab within a pane (terminal or browser panel).

## Pick The Mode

- Topology/routing: windows, workspaces, panes, surfaces, moves, reorder, focus, and flash.
- Current workspace automation: read `references/workspace/commands.md` before changing pane focus or user-visible layout.
- Browser automation: read the relevant files under `references/browser/` and use templates in `templates/browser/`.
- Settings or shortcuts: use `scripts/cmux-settings` when possible; read `references/settings/all-keys.md` and `references/settings/shortcut-actions.md` before editing `~/.config/cmux/cmux.json`.
- Customization: read `references/customization/examples.md` for actions, custom commands, sidebar, Dock controls, Command Palette entries, plus-button behavior, browser routing, and terminal preferences.
- Diagnostics: run `scripts/cmux-diagnostics` for health reports around hooks, notifications, session restore, socket access, browser automation, and settings.

## Fast Start

```bash
cmux identify --json
cmux list-windows
cmux list-workspaces
cmux list-panes
cmux list-pane-surfaces --pane pane:1
cmux new-workspace
cmux new-split right --panel pane:1
cmux move-surface --surface surface:7 --pane pane:2 --focus true
cmux split-off --surface surface:7 right
cmux reorder-surface --surface surface:7 --before surface:3
cmux trigger-flash --surface surface:7
```

For settings changes:

```bash
scripts/cmux-settings get .
scripts/cmux-settings set path.to.key value
cmux reload-config
```

## Handle Model

- Default output uses short refs: `window:N`, `workspace:N`, `pane:N`, `surface:N`.
- UUIDs are still accepted as inputs.
- Request UUID output only when needed: `--id-format uuids|both`.

## Core References

- `references/handles-and-identify.md`
- `references/windows-workspaces.md`
- `references/panes-surfaces.md`
- `references/trigger-flash-and-health.md`

## Rules

- Avoid disruptive focus/layout changes unless the user explicitly asks.
- Back up `cmux.json` before editing it directly.
- Prefer cmux helper scripts over ad hoc JSON edits when available.
