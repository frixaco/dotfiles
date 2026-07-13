### my dotfiles, managed by [`mise`](https://mise.jdx.dev)

Deployment uses mise's experimental [`[dotfiles]`](https://mise.jdx.dev/dotfiles.html) feature. The real files live under [`home/`](home/) mirroring `$HOME`; [`mise.toml`](mise.toml) maps each into place.

**Fresh machine**

```
curl -fsSL https://raw.githubusercontent.com/frixaco/dotfiles/main/setup.sh | bash
```

This installs mise, clones the repo to `~/.dotfiles`, trusts it, then runs `mise bootstrap`. Bootstrap installs Homebrew and the platform's [`Brewfile.macos`](Brewfile.macos) or [`Brewfile.linux`](Brewfile.linux) packages, applies dotfiles, fixes sensitive-file permissions, and installs tools + AI agents.

**Daily use** (run from `~/.dotfiles`)

```
mise dotfiles status          # what's applied / missing / drifted
mise dotfiles apply           # deploy (add --force to replace conflicts)
mise run secure               # chmod 0600 on sensitive files
mise run sync                 # apply + secure in one step
mise run brew:sync            # install/update Brewfile packages
mise dotfiles add ~/.config/foo   # capture a live file back into home/
```

**Deployment modes** (`mise.toml`)

- `template` — OS/work-specific files, rendered with [Tera](https://mise.jdx.dev/templates.html) (`os()`, `vars.work`, `env`).
- `copy` — real files a tool rewrites in place, or sensitive files (git can't preserve `0600`, so `mise run secure` restores it).
- `symlink` — everything else; edits flow straight back into the repo.

**Per-machine config** — `mise.local.toml` (gitignored) holds machine-specific vars and dotfiles:

```toml
[vars]
work = true                                    # enables vbrato git identity + rbenv

[dotfiles]
# work machines: vbrato git identity
"~/Documents/vbrato/.gitconfig-vbrato" = { mode = "template" }
```

**AI agents** — a single `~/.config/AGENTS.md` is shared to every tool and `~/.agents/skills` holds all skills:

```
mise run ai:sync    # install agents, link AGENTS.md + skills, verify
mise run lsp:sync   # install + verify LSP/formatter stack
```

**Theme** — Cyberdream dark everywhere. For fish: `fish_config theme save cyberdream`.
