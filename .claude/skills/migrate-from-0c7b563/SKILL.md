---
name: migrate-from-0c7b563
description: Temporary. Bring a macOS, Linux, or Windows machine whose ~/.dotfiles is at 0c7b563 up to date with the next two commits (28e3838 "major cleanup", 123bda0 "simplify setup"), then remove everything those commits made obsolete. Delete this skill once every machine is migrated.
disable-model-invocation: true
---

# Migrate a machine from 0c7b563

The repo already holds the finished setup; it was applied and cleaned up on the main Mac. Apply it here
and remove what it replaced. Don't redesign anything. Work from `~/.dotfiles`, use `pwsh` on Windows, and
report progress briefly between steps.

## What changed

**28e3838 (major cleanup)**
- Deleted every Cyberdream theme (bat, btop, delta, fish, ghostty, jjui, kitty, opencode, yazi) and the
  theme settings that used them. nvim keeps its Cyberdream colorscheme on purpose.
- Deleted the AeroSpace config and the `migrate-agents` skill. Stopped shipping repo snapshots of
  `btop.conf`, OpenCode `cli.json`, OMP `config.yml`, and PI `settings.json`.

**123bda0 (simplify setup)**
- CLI tools (bat, fd, ripgrep, fzf, jq, lazygit, starship, zoxide, yazi, gh, delta, difftastic, jj,
  jjui, dua, hyperfine, tree-sitter, railway, hunk), all language servers and formatters, and
  agent-browser are now mise `[tools]` in `home/.config/mise/config.toml`. The `lsp:*` tasks are gone,
  along with the Bun, `go install`, and `uv tool` installs behind them.
- eza, tokei, and resvg: `brew:` on macOS/Linux and `scoop:` on Windows (`mise.toml`).
- macOS packages: mise installs formulae and casks itself. `Brewfile.macos`, the Homebrew installer
  hook, and the `modem-dev` tap are gone. AeroSpace has been removed entirely.
- Dotfiles: `[dotfile_groups.home]` replaces the `"~"` symlink-each entry; `mise run sync` prunes
  files whose sources were deleted. Merge entries own only the repo's keys in `~/.claude.json`
  (chrome-devtools MCP), `~/.config/amp/settings.json`, and `~/.codex/config.toml` (so `ai:link` is
  gone). App-written settings use `track-local`.
- Shells: `fish/conf.d/00-mise.fish` is merged into `config.fish`; fish uses `fish_add_path -g`.
  `upall` calls `mise run up`, which keeps going after failures.
- Windows: `$PROFILE.CurrentUserAllHosts` dot-sources the repo's `profile.ps1` directly. 1Password's
  `agent.toml` moved to `~/AppData/Local/1Password/config/ssh/`. `.zshrc` is no longer deployed.

## Rules

- Ask once before each deletion step, showing exactly what will go. The user approved all of these on
  the main Mac, so a single yes per step is enough.
- Never delete anything you didn't confirm belongs to the old setup. Packages the user installed for
  other reasons stay, so ask when unsure.
- Don't commit or push. At the end, list any scratch files you created and delete them.

## 1. Preflight

1. `git -C ~/.dotfiles status --short` must be empty, and `git rev-parse HEAD` must be `0c7b563…`
   (or `28e3838…`). If the tree is dirty, stop and ask.
2. `git pull --ff-only`, then confirm `git log --oneline -3` includes `123bda0`.
3. Update mise to 2026.10.7 or newer (`mise.toml` sets `min_version`):
   - Windows: `scoop update; scoop update mise`.
   - Otherwise: `mise self-update --yes`.
4. Run `mise trust` in `~/.dotfiles`.
5. Take an inventory, to compare before and after:
   - `mise --version`, `mise ls`.
   - macOS/Linux: `brew list --formula`, `brew list --cask`, `brew tap`.
   - Windows: `scoop list`.
   - `bun pm ls -g`, `uv tool list`, and the contents of `$(go env GOPATH)/bin` and `$(mise where go)/bin`.
   - `ls -la ~/.local/bin`.
6. Ask the user to quit running agent sessions other than this one; the installers replace their binaries.

## 2. Apply the new config

1. `mise run sync`, then `mise run sync` again. The first run can remove `~/.pi/agent/mcp.json` while
   migrating the old symlink-each state; the second run restores it. Both runs must end with
   `status --missing` passing.
2. `mise bootstrap --force-dotfiles --yes` (long timeout). This installs the new `[tools]` and packages,
   then runs the bootstrap task (`layout`, `ai:install`, `ai:doctor`).
   - On Windows, Scoop must be on PATH for the `scoop:` entries.
   - The first PI install may wait for one keypress when a terminal is attached.
   - If an installer fails on a transient network error (the Codex one once failed with a TLS
     handshake), rerun `mise run ai:install`.
3. `mise ls --missing` must print nothing.

## 3. Remove superseded installs

Wait until step 2 has installed the mise copies, and check that nothing else depends on an item before
removing it.

**Homebrew** (macOS/Linux, only if `brew` exists):
- For each formula below, run `brew uses --installed --recursive <f>`. Only `jjui` should depend on `jj`.
- Uninstall: `bat difftastic dua-cli fd fzf gh git-delta hyperfine jjui jj jq lazygit ripgrep starship
  tree-sitter-cli yazi zoxide railway modem-dev/tap/hunk`. Skip any that aren't installed.
- Run `brew untap modem-dev/tap`.
- Keep eza, tokei, resvg, and the Brewfile casks; mise treats casks Homebrew installed as installed.
- Without `brew` on Linux, mise installed these formulae itself. Run
  `mise bootstrap packages prune --manager brew --dry-run`, show the list, and prune only after the
  user confirms it holds nothing else.

**AeroSpace** (macOS):
- `brew uninstall --cask --zap aerospace`, then `brew untap nikitabobko/tap`.
- Delete `~/Library/Preferences/bobko.aerospace.plist`, and remove AeroSpace from Login Items if it's
  there.

**Bun globals**: remove these if present:
- language servers and formatters: `@astrojs/language-server`, `@johnnymorganz/stylua-bin`,
  `@olrtg/emmet-language-server`, `@tailwindcss/language-server`, `@taplo/cli`,
  `@typescript/native-preview`, `eslint`, `graphql-language-service-cli`, `oxfmt`, `oxlint`,
  `prettier`, `shellcheck`, `svelte-language-server`, `typescript-language-server`,
  `vscode-langservers-extracted`;
- agent-browser, and the stray placeholder packages `clangd` and `shfmt`;
- leftover agent packages: `@openai/codex`, `@earendil-works/pi-coding-agent`,
  `@oh-my-pi/pi-coding-agent`, `opencode-ai`, `@opencode-ai/cli`.
- **Windows:** keep `@opencode/cli`, which is OpenCode V2 there.
- Keep anything else, such as `@frixaco/xport`.
- `bun remove -g` leaves orphaned modules behind. If `ls ~/.bun/install/global/node_modules` still lists
  far more than the kept packages, rebuild the folder:
  1. Move `node_modules` aside.
  2. Rewrite `package.json` with only the kept packages, and drop the stale `trustedDependencies`.
  3. `bun install` (add `--trust` for `@opencode/cli` on Windows).
  4. Check that each kept command runs, then delete the old folder.
- Delete launchers in `~/.bun/bin` for removed packages.

**uv / Go**:
- `uv tool uninstall ruff ty clang-format`.
- Delete `gopls`, `goimports`, and `shfmt` (`.exe` on Windows) from `$(mise where go)/bin` and
  `$(go env GOPATH)/bin`. mise now provides them under its `go-…` and `shfmt` installs.

**Scoop** (Windows): show `scoop list` entries that duplicate mise `[tools]`, such as bat, fd, ripgrep,
fzf, jq, lazygit, starship, zoxide, yazi, gh, delta, difftastic, jj, jjui, dua, hyperfine, tree-sitter,
shellcheck, shfmt, taplo, and stylua. Uninstall the ones the user confirms. Keep `mise`, eza, tokei, and
resvg.

**Then check** in a new shell that each tool resolves from mise:
- fish: `type -p bat rg lazygit starship gopls tsgo`.
- Windows: `Get-Command bat,rg,lazygit,starship,gopls,tsgo | Format-Table Name,Source`.
- eza, tokei, and resvg should come from brew or Scoop.

## 4. Leftover files from the old layout

- **Dangling symlinks into the repo** (macOS/Linux): run
  `find ~ -maxdepth 6 -type l -lname '*dotfiles*' ! -exec test -e {} \; -print` (skip `~/Library`) and
  delete what it finds. On Windows, `sync --prune` removes copies mise wrote; delete any remaining copy
  under `~/.config` whose source no longer exists in `home/`.
- **Agent launchers** in `~/.local/bin`: delete dangling links, and OMP's `omp.*.bak` and `omp.lock`
  when OMP isn't running. If PI's installer put a second `pi` launcher in `/opt/homebrew/bin` that
  points at the same `~/.pi/agent/bin/pi`, delete that one.
- **fish**: `set -Ue fish_user_paths`. The old config added paths there permanently; the new one sets
  them per session. Afterwards `fish -c 'echo $PATH'` should start with the mise paths, then
  `~/.local/bin`.
- **Windows only**:
  - `~/.config/powershell/profile.ps1` was a `copy` entry, which prune doesn't own. Delete it once
    `$PROFILE.CurrentUserAllHosts` contains the line that dot-sources
    `$HOME\.dotfiles\home\.config\powershell\profile.ps1`.
  - Delete `~/.zshrc`; it's no longer deployed on Windows.
  - Delete the old rendered `~/.config/1Password/ssh/agent.toml` once
    `~/AppData/Local/1Password/config/ssh/agent.toml` exists with the same content. Ask the user to
    confirm the 1Password SSH agent still sees the key, using "Configure for SSH Agent" in 1Password,
    because this path and its permissions are unverified on Windows.
- **chezmoi**: if it's installed or `~/.config/chezmoi` exists (its only setting was `work`, now
  `[vars] work` in `mise.local.toml`), offer to uninstall it and delete that folder. Also delete
  `~/.config/mise/miserc.toml` if its only content is an ignore rule for `~/.local/share/chezmoi`.

## 5. Theme cleanup (from 28e3838)

The user's rule: delete theme files, and delete configs that aren't in this repo when they exist only to
select the removed theme. In configs that are in the repo, or that hold other real settings, remove just
the theme entry. Leave nvim's Cyberdream alone.

1. Find leftovers:
   - macOS/Linux:
     `find ~/.config ~/.local/bin ~/.local/state -maxdepth 4 -iname '*cyberdream*' -not -path '*/nvim/*'`
     and `grep -rIl -i cyberdream ~/.config | grep -v nvim`.
   - Windows: also search `$env:APPDATA` and `$env:LOCALAPPDATA` (bat, yazi, lazygit, Zed, and others
     keep config there).
2. What the main Mac had, and what was done:

   | Leftover | Action |
   |---|---|
   | `cyberdream*` theme files in `opencode/themes`, `ghostty/themes`, `delta/themes`, `zed/themes`, `superfile/theme`, `jjui/themes`, `btop/themes`, `bat/themes`, `yazi/flavors` | Delete, then `rmdir` folders left empty |
   | `~/.config/kitty/{light,dark,no-preference}-theme.auto.conf` (these override `kitty.conf`) | Delete |
   | `~/.local/bin/theme-mode`, `~/.local/state/theme-mode`, `~/.config/lazygit/{dark,light}.yml` | Delete |
   | `~/.config/btop/btop.conf` and `~/.config/opencode/cli.json` (no longer in the repo; both select Cyberdream) | Delete; btop and OpenCode recreate defaults, and mise local history keeps the old versions. Remove `~/.config/btop` if empty |
   | Zed `settings.json` `"theme": {...}` block, superfile `config.toml` `theme = 'cyberdream'` line | Remove only that entry |
   | fish universal `BAT_THEME`, `theme_mode`, and Cyberdream colors | `set -Ue BAT_THEME; set -Ue theme_mode`, then save Catppuccin Mocha (below) |

3. Save the fish theme. fish 4.9 refuses to save without a terminal (`$fish_terminal_color_theme not yet
   initialized`), so run it in a pseudo-terminal:
   `script -q /dev/null fish -i -c 'yes | fish_config theme save catppuccin-mocha'`.
   The error can still print; check that `~/.config/fish/fish_variables` has
   `fish_color_normal:cdd6f4` and `fish_color_command:89b4fa`, and no `cyberdream`.
   Skip this if fish isn't installed (for example on Windows). Over ssh the save still fails, because
   no terminal answers fish's color query. There, `set -Ue` the old `fish_color_*` and
   `fish_pager_color_*` variables and copy the `SETUVAR fish_color_*` and `fish_pager_color_*` lines
   from a migrated machine's `fish_variables` (same fish version). Pass `</dev/null` to `script` in
   heredocs, because it reads the rest of stdin.
4. Run the searches from 1 again; only nvim (`init.lua`, `nvim-pack-lock.json`, undo history) may
   still mention Cyberdream.

## 6. Verify and report

1. `mise bootstrap --dry-run` lists nothing to install or change, and `mise bootstrap status --missing`
   exits 0.
2. `mise run ai:doctor` finds all six agents.
3. `claude mcp list` shows `chrome-devtools` (it connects only while Helium runs with
   `--remote-debugging-port=9222`).
4. Open a new shell and run `upall` once. It must finish, listing any failed steps at the end.
5. Report the before/after inventory, everything deleted, anything skipped or still open with its
   output, and that nothing was committed. Once every machine is migrated, the user deletes
   `.claude/skills/migrate-from-0c7b563/`.
