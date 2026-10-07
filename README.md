# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Repo-owned configs and templates live in [`home/`](home/), mirroring `$HOME`. Mise links those configs, renders templates, and saves app-written settings in local history.

## Existing installer

```bash
curl -fsSL https://dotfiles.frixaco.com | bash
cd ~/.dotfiles
```

Requires mise 2026.9.2 or newer. Update an older installation with `mise self-update` before setup. The installer installs mise if missing, clones the repo, and runs bootstrap.
Personal settings are the default; see [per-machine config](#per-machine-config) for work settings. App-written settings are machine-local: configure them in the app or restore a backup on a new machine. Their `home/` snapshots are references and are not deployed.

## Daily workflow

Edit repo-owned configs and template sources in `home/`. After editing or pulling repository updates, run from `~/.dotfiles`:

```bash
mise run sync
```

`sync` applies native file links and templates, restores sensitive permissions, ensures the history service is running, and fails if deployment is incomplete. It repairs missing links, overwrites conflicting files at managed targets, and includes new repo-owned files automatically. OMP and PI share the repo-owned MCP config, and all five agents share `AGENTS.md`.

The linked global mise config keeps tool declarations and tasks current too. Updating installed tools is separate: use `ai:sync` or `lsp:sync` below. Sync cannot fix configuration keys changed by a future app release; those source changes still need review.

Edit app-written settings through the app or their live file. The global mise config tracks Amp settings, btop settings, OpenCode TUI settings, OMP settings, Codex settings, and PI settings. Sync preserves those files and never deploys their repository snapshots. Git handles repo-owned configs; the `mise-history` user service handles these local settings.

Inspect or restore app settings with:

```bash
mise bootstrap dotfiles history --path ~/.pi/agent/settings.json
mise bootstrap dotfiles rollback ~/.pi/agent/settings.json --dry-run
mise bootstrap dotfiles rollback ~/.pi/agent/settings.json
mise bootstrap dotfiles undo
```

To track another live file:

```bash
mise bootstrap dotfiles track ~/.config/example.conf
```

Tracking declarations must be in the global mise config, not project `mise.toml`. Edit its linked source at `home/.config/mise/config.toml`. If a new app-written snapshot is added under `home/`, also exclude it from the root `symlink-each` mapping before running sync.

Check or start the background service with:

```bash
mise bootstrap services status
mise bootstrap services apply --yes
```

No history origin is connected; nothing is uploaded automatically. Connecting an origin can publish earlier checkpoints as well as future edits.

## Packages and tools

```bash
mise bootstrap --only packages  # install missing formulae and applications
mise run ai:sync                # install agents, configure browser MCP, verify
mise run lsp:sync                # install + verify language tools
mise bootstrap status --missing # check dotfiles, packages, and tools
mise bootstrap --dry-run        # preview a full machine setup
```

Use `mise bootstrap --force-dotfiles --yes` when you also want packages, tools, and the final bootstrap task. The installer uses these flags to replace conflicting files at managed targets.

On other Macs, import [Vorssaint Settings.plist](<Vorssaint Settings.plist>) in Vorssaint under Settings → Advanced → Import settings.

## Per-machine config

`mise.local.toml` is gitignored and holds machine-specific variables:

```toml
[vars]
work = true # enables the Vbrato Git identity and rbenv
```

The work identity file is a shared mapping. The `work` variable only controls
whether `~/.gitconfig` includes it. Apply profile changes with `mise run sync`.

## AI agents

A single `~/.config/AGENTS.md` is shared across the configured AI tools. This setup does not install or share skills or workflows.

Model and reasoning preferences live in each agent's settings; OMP has separate model roles. App-written agent settings have local mise history. OpenCode's main config is repo-owned; its TUI settings are local. Authentication, conversations, and generated databases remain machine-local.

`ai:link` configures Codex’s Chrome DevTools MCP connection to the same browser endpoint used by PI, OMP, Amp, and OpenCode: `http://127.0.0.1:9222`. Start Helium with `--remote-debugging-port=9222` using the existing signed-in profile. Restart the Codex session after changing its MCP configuration. The connection requires Helium to be running; setup does not restart the browser.

Amp model and effort pins are account settings, not local dotfiles. In [Settings → Mode Dial → Tune Modes](https://ampcode.com/docs/the-dial#tune-the-modes), select Astra with medium reasoning for Main Agent, Oracle, and Subagents in each mode, then save. These pins still need to be applied through a signed-in Amp session.

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

[`mise.toml`](mise.toml) owns file mappings, tasks, and hooks. Its native `symlink-each` mapping links individual repo-owned files without replacing their parent directories or unrelated files. Neovim's Lua files use the same per-file links; templates and app-written snapshots are excluded. `mise.local.toml` adds machine settings. The linked global mise config owns tools, agent/LSP tasks, local tracking, and the history service.

The `secure` hook restores `0600` on the 1Password source and rendered target because Git cannot preserve those permissions. On Windows it restricts access with `icacls`. Windows file symlinks can fall back to copies when link privileges are unavailable; automatic edit-through requires an actual link.

## Bootstrap lifecycle

`mise run sync` force-applies dotfiles, overwriting conflicting files at managed targets, applies services, then checks dotfile status. `layout` runs once before dotfile apply, and `secure` runs once afterward. Full bootstrap runs:

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
