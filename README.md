# My dotfiles, managed by [`mise`](https://mise.jdx.dev)

Configs and templates live in [`home/`](home/), mirroring `$HOME`. mise links them into place, renders templates, merges repo-owned keys into app-written settings, and keeps local history of those settings.

## New machine

```bash
curl -fsSL https://dotfiles.frixaco.com | bash
```

Installs mise if missing (2026.10.7 or newer; run `mise self-update` on an older install), clones this repo to `~/.dotfiles`, and runs `mise bootstrap`: packages, dotfiles, tools, then the `bootstrap` task (workspace layout and AI agents). Run `omp` once afterwards to authenticate.

Windows has no installer script: install mise with Scoop, clone to `~/.dotfiles`, then `mise trust` and `mise bootstrap --force-dotfiles --yes` from inside it.

## Daily use

| Command                 | Does                                                                         |
| ----------------------- | ---------------------------------------------------------------------------- |
| `upall` (`mise run up`) | Sync dotfiles, then update mise, packages, `[tools]`, and AI agents; keeps going after a failed step and lists failures at the end |
| `mise run sync`         | Apply dotfiles, remove ones deleted from `home/`, start the history watcher |
| `mise up`               | Update `[tools]` only                                                        |
| `mise bootstrap status` | Check packages, dotfiles, and tools                                          |

Run `mise` commands for this repo from `~/.dotfiles` (or with `mise -C ~/.dotfiles`).

Edit sources in `home/`, then `mise run sync`. On macOS most files are symlinks, so edits through `~` land in the repo too. Windows copies every file (except directory links), so always edit the repo source there. Use `ef` to edit your shell config's source.

The 1Password CLI (`op`) is the `1password` tool in `[tools]`, so `upall` updates it everywhere; the Homebrew `1password-cli` cask isn't used.

eza, tokei, and resvg have no upstream macOS binaries, so they are `brew:` packages on macOS and `scoop:` packages on Windows, both in `mise.toml`.

Homebrew is optional now: mise installs the `brew:` and `brew-cask:` packages in `mise.toml` itself. `upall` doesn't run `brew upgrade`, so anything you installed by hand with brew needs its own `brew upgrade`.

## Layout

- [`mise.toml`](mise.toml): macOS packages, the `home` dotfile group (everything in `home/` deploys automatically), templates, shared agent files, merge edits, and tasks.
- [`home/.config/mise/config.toml`](home/.config/mise/config.toml): the global config, linked into place. It holds `[tools]` (runtimes, CLI tools, language servers, the same on macOS and Windows), AI agent tasks, history tracking, and the watcher service.
- `mise.local.toml` (gitignored): per-machine variables, e.g. `[vars] work = true` for the Vbrato Git identity and rbenv.

### What deploys how

- **Everything in `home/`**: linked file by file (copied on Windows). Deleting a file from `home/` removes its link on the next `sync`.
- **Templates**: `.zshrc` (Unix only), `.gitconfig`, fish `config.fish`, Ghostty config, `.gitconfig-vbrato`, and 1Password's `agent.toml` (mode 0600; on Windows it goes under `AppData/Local/1Password`).
- **Shared agent files**: one `AGENTS.md` is linked to Claude, Codex, OpenCode, Amp, PI, and OMP. PI and OMP share `.pi/agent/mcp.json`.
- **Merge edits**: Claude Code, Amp, and Codex rewrite `~/.claude.json`, `~/.config/amp/settings.json`, and `~/.codex/config.toml`. mise owns only the keys in the repo copies (the Chrome DevTools MCP server, plus Amp's remote threads) and leaves the rest to the app.
- **Not deployed**: `home/.claude/settings.json` is a reference snapshot; the live file belongs to Claude Code and is only tracked.
- **Local history**: the global config tracks the app-written settings with `track-local`, so the watcher saves every edit on this machine and never shares it. Inspect with `mise dot --local history` and restore with `mise dot rollback <path>`.

### Windows notes

- The PowerShell profile sets `XDG_CONFIG_HOME`, `YAZI_CONFIG_HOME`, and `LG_CONFIG_FILE`, so nvim, yazi, and lazygit read `~/.config` like on macOS. Apps started outside PowerShell don't see these variables.
- `upall` runs `scoop update` and `scoop update --all` (which updates mise) before `mise run up`, because Scoop can't update mise while a mise task is running.
- The post-dotfiles hook makes `$PROFILE.CurrentUserAllHosts` dot-source `~/.dotfiles/home/.config/powershell/profile.ps1` directly, so profile edits need no sync. `sf` reloads environment variables only; open a new session to pick up changed functions and aliases. Machine-specific settings go in the untracked `~/.config/powershell/env.ps1`.
- OpenCode V2 has no Windows standalone installer, so it's installed as the `@opencode/cli` Bun package there.

## AI agents

`mise run ai:install` installs or updates Claude Code, Codex, OpenCode V2, PI, OMP, Amp, and the T3 Code CLI (`t3`) with their standalone installers; `mise run ai:doctor` checks they're on `PATH`. The T3 Code desktop app is the `t3-code` cask in `mise.toml`, macOS only; Linux and Windows get the CLI only. The browser MCP for every agent points at Helium's debugging endpoint, `http://127.0.0.1:9222`: start Helium with `--remote-debugging-port=9222`.

Amp model and effort pins are account settings: set them in [Settings → Mode Dial → Tune Modes](https://ampcode.com/docs/the-dial#tune-the-modes).

## Misc

- Workspace: `mise run layout` creates `~/stuff/{code,music,2d,3d,dump}`. Vbrato repos live in `~/stuff/code/vbrato/`.
- On other Macs, import [Vorssaint Settings.plist](<Vorssaint Settings.plist>) in Vorssaint under Settings → Advanced → Import settings.

## Installer hosting

Vercel manages DNS for `dotfiles.frixaco.com`. Railway runs the redirect service in [`installer/`](installer/), health-checked at [`/healthz`](https://dotfiles.frixaco.com/healthz). The root URL redirects to [`setup.sh`](setup.sh) on `main`.

```bash
curl -fsS https://dotfiles.frixaco.com/healthz
curl -fsSL https://dotfiles.frixaco.com | cmp - setup.sh
```
