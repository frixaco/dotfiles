# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Deployment uses mise's experimental [`[dotfiles]`](https://mise.jdx.dev/dotfiles.html) feature. The real files live under [`home/`](home/) mirroring `$HOME`; [`mise.toml`](mise.toml) maps each into place.

## Fresh machine

```bash
curl -fsSL https://dotfiles.frixaco.com | bash
```

This installs mise, clones the repository to `~/.dotfiles`, and runs the full bootstrap. Personal configuration is the default; work machines can add a [per-machine config](#per-machine-config) afterward.

## Everyday commands

Run from `~/.dotfiles`:

```bash
mise run sync                    # apply dotfiles and secure sensitive files
mise bootstrap status --missing # check packages, dotfiles, and tools
mise bootstrap --only packages  # install missing formulae and applications
mise bootstrap --dry-run        # preview a full bootstrap
mise dotfiles add ~/.config/foo # capture a live file into home/
```

## Architecture

```text
                                  FRESH MACHINE
                                        │
                                        ▼
                    ╭────────────────────────────────╮
                    │ dotfiles.frixaco.com           │
                    │                                │
                    │ Railway redirects to the       │
                    │ setup.sh file on GitHub        │
                    ╰───────────────┬────────────────╯
                                    │
                                    ▼
                    ╭────────────────────────────────╮
                    │ setup.sh                       │
                    │                                │
                    │ 1. Install mise                │
                    │ 2. Clone into ~/.dotfiles      │
                    │ 3. Trust mise.toml             │
                    │ 4. Run mise bootstrap          │
                    ╰───────────────┬────────────────╯
                                    │
                                    ▼
╭──────────────────────────────────────────────────────────────────────────────╮
│                         ~/.dotfiles repository                               │
│                                                                              │
│  ╭──────────────────╮       ╭─────────────────────────────────────────────╮  │
│  │ mise.toml        │       │ mise.local.toml — gitignored                │  │
│  │                  │◀──────│                                             │  │
│  │ Shared mappings  │ merge │ [vars]                                      │  │
│  │ Tasks and hooks  │       │ work = true                                 │  │
│  │ work = false     │       │                                             │  │
│  ╰────────┬─────────╯       │ Work-only dotfile mappings                  │  │
│           │                 ╰─────────────────────────────────────────────╯  │
│           │                                                                  │
│           ▼                                                                  │
│  ╭────────────────────────────────────────────────────────────────────────╮  │
│  │ home/ — source tree mirrors $HOME                                      │  │
│  │                                                                        │  │
│  │  .zshrc                          template                              │  │
│  │  .gitconfig                      template                              │  │
│  │  .config/fish/config.fish        template                              │  │
│  │  .config/ghostty/config          template                              │  │
│  │  .config/1Password/...           template + chmod 0600                 │  │
│  │                                                                        │  │
│  │  .config/nvim/                  symlinked directory                    │  │
│  │  .agents/skills/                symlinked directory                    │  │
│  │  .config/aerospace/...          symlinked file                         │  │
│  │  .config/kitty/...              symlinked files                        │  │
│  │                                                                        │  │
│  │  .config/mise/config.toml       copied file                            │  │
│  │  .config/amp/settings.json      copied file                            │  │
│  │  .factory/settings.json         copied file + chmod 0600               │  │
│  │                                                                        │  │
│  │  Documents/vbrato/                                                     │  │
│  │    .gitconfig-vbrato            work-only template                     │  │
│  ╰────────────────────────────────────────────────────────────────────────╯  │
╰─────────────────────────────────────┬────────────────────────────────────────╯
                                      │
                              mise dotfiles apply
                                      │
                  ╭───────────────────┼───────────────────╮
                  │                   │                   │
                  ▼                   ▼                   ▼
       ╭──────────────────╮ ╭──────────────────╮ ╭──────────────────────╮
       │ TEMPLATE         │ │ COPY             │ │ SYMLINK              │
       │                  │ │                  │ │                      │
       │ Render Tera      │ │ Independent      │ │ Live points directly │
       │ expressions      │ │ writable file    │ │ into repository      │
       │                  │ │                  │ │                      │
       │ os()             │ │ Used when tools  │ │ Editing either side  │
       │ vars.work        │ │ rewrite configs  │ │ edits repo source    │
       │ env.*            │ │                  │ │                      │
       ╰────────┬─────────╯ ╰────────┬─────────╯ ╰──────────┬───────────╯
                │                    │                      │
                ╰────────────────────┼──────────────────────╯
                                     ▼
                         ╭────────────────────────╮
                         │       Live $HOME       │
                         │                        │
                         │ ~/.zshrc               │
                         │ ~/.gitconfig           │
                         │ ~/.config/*            │
                         │ ~/.agents/skills       │
                         │ ~/.factory/*           │
                         │ ~/Documents/vbrato/*   │
                         ╰────────────┬───────────╯
                                      │
                                      ▼
                         ╭────────────────────────╮
                         │ mise run secure        │
                         │                        │
                         │ chmod 0600:            │
                         │ • 1Password agent      │
                         │ • Factory settings     │
                         ╰────────────────────────╯
```

## Bootstrap lifecycle

```text
╭────────────────────╮
│ mise bootstrap     │
╰─────────┬──────────╯
          │
          ▼
╭──────────────────────────────────────╮
│ Bootstrap packages                   │
│                                      │
│ Apply [bootstrap.packages]           │
│                                      │
│ Install shared Homebrew formulae     │
│ Install macOS extras from            │
│ Brewfile.macos                       │
╰─────────┬────────────────────────────╯
          │
          ▼
╭──────────────────────────────────────╮
│ Apply [dotfiles]                     │
│                                      │
│ • Render templates                   │
│ • Copy writable configs              │
│ • Create symlinks                    │
╰─────────┬────────────────────────────╯
          │
          ▼
╭──────────────────────────────────────╮
│ post-dotfiles hook                   │
│                                      │
│ mise run secure                      │
╰─────────┬────────────────────────────╯
          │
          ▼
╭──────────────────────────────────────╮
│ Install tools from [tools]           │
│                                      │
│ mise install                         │
╰─────────┬────────────────────────────╯
          │
          ▼
╭──────────────────────────────────────╮
│ Bootstrap task                       │
│                                      │
│ mise run ai:sync                     │
│   • Install/update agents            │
│   • Link AGENTS.md and skills        │
│   • Verify binaries                  │
│                                      │
│ mise run lsp:sync                    │
│   • Install/update language tools    │
│   • Verify binaries                  │
╰──────────────────────────────────────╯
```

## Daily workflow

```text
                         ╭──────────────────────╮
                         │ ~/.dotfiles/home/*   │
                         │ Source of truth      │
                         ╰──────────┬───────────╯
                                    │
                         mise run sync
                    apply dotfiles + secure files
                                    │
                                    ▼
                         ╭──────────────────────╮
                         │ Live files in $HOME  │
                         ╰──────────┬───────────╯
                                    │
                mise dotfiles add ~/.config/example
                                    │
                                    ▼
                         ╭──────────────────────╮
                         │ Capture live file    │
                         │ back into home/      │
                         ╰──────────────────────╯
```

## Installer hosting

Vercel manages DNS for `dotfiles.frixaco.com`. Railway runs the redirect service from [`installer/`](installer/) and checks [`/healthz`](https://dotfiles.frixaco.com/healthz) during deployment. The root URL returns a temporary redirect to the copy of [`setup.sh`](setup.sh) on GitHub, so the short command always uses the script from the `main` branch.

Verify the public endpoint without running the installer:

```bash
curl -fsS https://dotfiles.frixaco.com/healthz
curl -fsSL https://dotfiles.frixaco.com | cmp - setup.sh
```

## Deployment modes

Configured in [`mise.toml`](mise.toml):

- `template` — OS/work-specific files, rendered with [Tera](https://mise.jdx.dev/templates.html) (`os()`, `vars.work`, `env`).
- `copy` — real files a tool rewrites in place, or sensitive files (git can't preserve `0600`, so `mise run secure` restores it).
- `symlink` — everything else; edits flow straight back into the repo.

## Per-machine config

`mise.local.toml` is gitignored and holds machine-specific variables and dotfiles:

```toml
[vars]
work = true                                    # enables vbrato git identity + rbenv

[dotfiles]
# work machines: vbrato git identity
"~/Documents/vbrato/.gitconfig-vbrato" = { mode = "template" }
```

Apply profile changes with `mise run sync`.

## AI agents

A single `~/.config/AGENTS.md` is shared across the configured AI tools, and `~/.agents/skills` holds their shared skills:

```bash
mise run ai:sync    # install agents, link AGENTS.md + skills, verify
mise run lsp:sync   # install + verify LSP/formatter stack
```

## Theme

Supported terminal and TUI configs use Cyberdream dark. For Fish, run `fish_config theme save cyberdream`.
