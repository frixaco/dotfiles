# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Deployment uses mise's experimental [`[dotfiles]`](https://mise.jdx.dev/dotfiles.html) feature. The real files live under [`home/`](home/) mirroring `$HOME`; [`mise.toml`](mise.toml) maps each into place.

## Architecture

```text
                                  FRESH MACHINE
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
│ pre-packages hook                    │
│                                      │
│ macOS ──▶ Brewfile.macos             │
│ Linux ──▶ Brewfile.linux             │
│                                      │
│ Install Homebrew if missing          │
│ Run brew bundle                      │
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

## Fresh machine

```
curl -fsSL https://raw.githubusercontent.com/frixaco/dotfiles/main/setup.sh | bash
```

This installs mise, clones the repo to `~/.dotfiles`, trusts it, then runs `mise bootstrap`. Bootstrap installs Homebrew and the platform's [`Brewfile.macos`](Brewfile.macos) or [`Brewfile.linux`](Brewfile.linux) packages, applies dotfiles, fixes sensitive-file permissions, and installs tools + AI agents.

Non-work is the default machine profile. On a work machine, create the [per-machine config](#per-machine-config) after bootstrap, then run `mise run sync` to re-render the work-specific files.

## Daily use

Run from `~/.dotfiles`:

```
mise dotfiles status          # what's applied / missing / drifted
mise dotfiles apply           # deploy (add --force to replace conflicts)
mise run secure               # chmod 0600 on sensitive files
mise run sync                 # apply + secure in one step
mise run brew:sync            # install/update Brewfile packages
mise dotfiles add ~/.config/foo   # capture a live file back into home/
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

```
mise run ai:sync    # install agents, link AGENTS.md + skills, verify
mise run lsp:sync   # install + verify LSP/formatter stack
```

## Theme

Supported terminal and TUI configs use Cyberdream dark. For Fish, run `fish_config theme save cyberdream`.
