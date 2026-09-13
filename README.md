# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Templates and setup snapshots live in [`home/`](home/), mirroring `$HOME`. Mise tracks ordinary live configs and saves their history locally.

## Existing installer

```bash
curl -fsSL https://dotfiles.frixaco.com | bash
cd ~/.dotfiles
```

Requires mise 2026.9.2 or newer. Update an older installation with `mise self-update` before setup. The installer installs mise if missing, clones the repo, and runs bootstrap.
This machine has migrated to local tracking. The installer does not yet restore
tracked live files on a new machine; restore them from a backup before enabling
the watcher. The `home/` snapshots retain the pre-migration ordinary configs. Personal settings are the default; see [per-machine config](#per-machine-config) for work settings.

## Daily workflow

Requires mise 2026.9.2 or newer. Ordinary configs are regular live files tracked by
`~/.config/mise/config.toml`. The `mise-history` user service saves edits locally.
No history origin is connected; nothing is uploaded automatically.

Edit live files with your usual editor. Inspect or restore saved versions with:

```bash
mise bootstrap dotfiles status
mise bootstrap dotfiles history --path ~/.config/starship.toml
mise bootstrap dotfiles rollback ~/.config/starship.toml --dry-run
mise bootstrap dotfiles rollback ~/.config/starship.toml
mise bootstrap dotfiles undo
```

Templates still live in `home/`. Edit their source files, then run from `~/.dotfiles`:

```bash
mise run sync
mise bootstrap dotfiles status --missing
```

`sync` renders templates and maintains the shared OMP/PI MCP link. It does not
copy ordinary configs or publish history. Template sources also have automatic
local history. OMP and PI use the same live `~/.pi/agent/mcp.json` file.

To track another live file:

```bash
mise bootstrap dotfiles track ~/.config/example.conf
```

Tracking declarations must be in the global mise config, not project `mise.toml`.
The repository's non-template `home/` files are setup snapshots; live edits no
longer update those snapshots. Git pull alone does not update tracked live files.
The repository copy of the global mise config is also a setup snapshot.

Check or start the background service with:

```bash
mise bootstrap services status
mise bootstrap services apply --yes
```

History is local until a separate origin is explicitly configured. Connecting an
origin can publish earlier checkpoints as well as future edits.

## Packages and tools

```bash
mise bootstrap --only packages  # install missing formulae and applications
mise run ai:sync                # install agents, link AGENTS.md + skills, verify
mise run lsp:sync                # install + verify language tools
mise bootstrap status --missing # check dotfiles, packages, and tools
mise bootstrap --dry-run        # preview a full machine setup
```

Use the full `mise bootstrap` when you also want packages, tools, and the final bootstrap task.

## Per-machine config

`mise.local.toml` is gitignored and holds machine-specific variables:

```toml
[vars]
work = true # enables the Vbrato Git identity and rbenv
```

The work identity file is a shared mapping. The `work` variable only controls
whether `~/.gitconfig` includes it. Apply profile changes with `mise run sync`.

## AI agents

A single `~/.config/AGENTS.md` is shared across the configured AI tools, and `~/.agents/skills` holds their shared skills. OMP settings, Ponytail, and MCP configuration are tracked under `~/.omp/agent`; authentication, conversations, and generated databases remain machine-local.

Run `omp` on each new machine to complete provider authentication.

## Theme

Supported terminal and TUI configs use Cyberdream dark. For Fish, run `fish_config theme save cyberdream`.

## Personal workspace

`mise run layout` creates the same workspace on Windows, macOS, and Linux:

```text
~/stuff/
├── code/
├── music/
├── 2d/
├── 3d/
└── dump/
```

Vbrato repositories live under `~/stuff/code/vbrato/`, next to the deployed
`.gitconfig-vbrato`. A full bootstrap creates the layout before dotfiles;
`mise run sync` does the same for existing machines.

## Architecture

[`mise.toml`](mise.toml) owns file mappings, tasks, and hooks. `mise.local.toml` adds machine settings. The global mise config owns live tracking and the history service. `home/` retains template sources and setup snapshots.

The `secure` hook restores `0600` on the 1Password source and rendered target because Git cannot preserve those permissions. On Windows it restricts access with `icacls`. Windows file symlinks can fall back to copies when link privileges are unavailable; automatic edit-through requires an actual link.

## Bootstrap lifecycle

`mise run sync` calls `mise bootstrap dotfiles apply --yes`: `layout` runs once before apply, and `secure` runs once afterward. Full bootstrap runs:

1. Shared Homebrew packages and macOS extras from `Brewfile.macos`.
2. `layout` to create workspace directories.
3. Dotfile apply to link, copy, or render each target.
4. `secure` to restore sensitive permissions.
5. `mise install` for configured tools.
6. `ai:sync` and `lsp:sync` to install and verify agents and language tools.

## Installer hosting

Vercel manages DNS for `dotfiles.frixaco.com`. Railway runs the redirect service from [`installer/`](installer/) and checks [`/healthz`](https://dotfiles.frixaco.com/healthz) during deployment. The root URL returns a temporary redirect to the copy of [`setup.sh`](setup.sh) on GitHub, so the short command always uses the script from the `main` branch.

Verify the public endpoint without running the installer:

```bash
curl -fsS https://dotfiles.frixaco.com/healthz
curl -fsSL https://dotfiles.frixaco.com | cmp - setup.sh
```
