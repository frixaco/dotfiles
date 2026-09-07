# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Sources live in [`home/`](home/), mirroring `$HOME`. [`mise.toml`](mise.toml) deploys them with mise's experimental [dotfiles](https://mise.jdx.dev/dotfiles.html) feature.

## Quick setup

```bash
curl -fsSL https://dotfiles.frixaco.com | bash
cd ~/.dotfiles
```

Requires mise 2026.8.15 or newer. Update an older installation with `mise self-update` before setup. The installer installs mise if missing, clones the repo, and runs bootstrap. Personal settings are the default; see [per-machine config](#per-machine-config) for work settings.

## Daily workflow

Run commands from `~/.dotfiles`. **`mise run sync` applies repo → machine. It does not sync both ways.**

| What you changed | Next action |
| --- | --- |
| A symlinked file, from either path | Nothing to copy. The repo source already has your edit. |
| A copied file in `home/` | `mise run sync` applies it to the live file. |
| A live copied file | `mise bootstrap dotfiles add --changed` captures changed copies into `home/`. |
| A source template in `home/` | `mise run sync` renders the live file. |

For one editing command across all modes, pass the live path:

```bash
mise bootstrap dotfiles edit --apply ~/.gitconfig
```

Mise opens the managed source in your editor and applies it after the editor exits. Use this for templates: editing the rendered live file cannot update the source template's OS/work conditions. The next apply overwrites that live edit.

For symlinks, direct editing also works. For example, editing `~/.config/nvim/init.lua` changes its repo source immediately.

### Capture edits from live copies

```bash
mise bootstrap dotfiles add --changed
git diff
git status --short
```

Capture wanted live edits before applying repo changes. Capture does not merge competing edits from both sides; review them before choosing which version to keep. It updates regular copy-mode sources only, not templates or directory copies. It does not stage or commit Git changes.

### Apply repo changes

```bash
mise bootstrap dotfiles diff             # preview repo-to-machine changes
mise run sync                           # apply files and run layout/secure hooks
mise bootstrap dotfiles status --missing # fail if any dotfile is out of sync
```

Review and commit repo changes with Git after either workflow.

## Start managing a file

Run from the repo. For an ordinary file you edit yourself:

```bash
mise bootstrap dotfiles add --mode symlink ~/.config/example.conf
```

Mise stores the file under `home/`, writes its `[dotfiles]` entry, and replaces the live file with a link. For a file an application rewrites, use `--mode copy` instead. Review and stage both `mise.toml` and the new source, then commit. Git tracking alone does not deploy files in this repo; the explicit mise entry selects them.

## Stop managing a file

To keep the live file, first replace its symlink with a regular copy of its current contents. Check the link target before removing only the link; keep its source until the live copy is verified. Copy-mode and rendered template targets are already regular files.

Then remove the target's `[dotfiles]` entry from the config that declares it. Remove the repo source only if no other mapping uses it. For example, both `~/.pi/agent/mcp.json` and `~/.omp/agent/mcp.json` use the same source. Review and commit the changes. Removing the entry alone leaves an existing link connected to the repo.

To remove the deployed file as well, preview and then unapply it **before** removing its config entry:

```bash
mise bootstrap dotfiles unapply --dry-run ~/.config/example.conf
# The next command removes the deployed file or link.
mise bootstrap dotfiles unapply ~/.config/example.conf
```

Unapply keeps the config entry and repo source. Changed copies and templates are protected from removal; preserve wanted edits before proceeding. If a directory mapping owns the file, update that mapping rather than assuming a separate file entry exists.

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

[`mise.toml`](mise.toml) owns file mappings, tasks, and hooks. `mise.local.toml` adds machine settings. Sources stay in one `home/` tree: symlinks for direct editing, copies for app-rewritten files, and [Tera templates](https://mise.jdx.dev/templates.html) for OS/work settings.

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
