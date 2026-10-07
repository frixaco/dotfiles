---
name: migrate-agents
description: Temporary. Move this machine's AI agents (Claude Code, Codex, PI, OMP, OpenCode) from Bun/npm packages to standalone installs and migrate OpenCode V1 to V2, using the ai:* mise tasks in ~/.dotfiles. Works on macOS, Linux, and Windows. Delete this skill once every machine is migrated.
disable-model-invocation: true
---

# Migrate AI agents to standalone installs

Bring this machine in line with the setup already applied on the main Mac. The repo already has the
finished work. Do not redesign it; apply it and clean up.

- `home/.config/mise/config.toml`: `ai:install` (macOS/Linux) and the hidden `ai:install:windows`
  install missing agents and upgrade installed ones. `ai:doctor` checks `amp claude opencode codex pi omp`.
- `home/.config/opencode/opencode.json` is in the native OpenCode V2 format.
- `~/.config/opencode/cli.json` replaces V1's `tui.json` and is tracked by mise history.

Target state:

| Agent | macOS / Linux | Windows | Upgrade |
|---|---|---|---|
| Claude Code | `~/.local/bin/claude` | `~\.local\bin\claude.exe` | `claude update` (also self-updates) |
| Codex | `~/.local/bin/codex` | `%LOCALAPPDATA%\Programs\OpenAI\Codex\bin` | rerun installer |
| PI | `~/.local/bin/pi` -> `~/.pi/agent/bin/pi` | `~\.pi\agent\bin\pi.cmd` | `pi update --all` |
| OMP | `~/.local/bin/omp` (prebuilt binary) | `%LOCALAPPDATA%\omp\omp.exe` | `omp update` |
| OpenCode V2 | `~/.opencode/bin/opencode` (+ `opencode2` shim) | Bun `@opencode/cli` in `~\.bun\bin` | `opencode upgrade` / rerun `bun install -g --trust @opencode/cli@latest` |
| Amp | unchanged | unchanged | `amp update` |

Only `agent-browser` (and the LSP tools) stay global Bun packages.

## Steps

Work from `~/.dotfiles`. Report progress briefly between steps. On Windows, run commands in `pwsh`.

### 1. Preflight

1. Run `git pull --ff-only` and confirm that `home/.config/mise/config.toml` contains `ai:install:windows` and
   `omp.sh/install`. If it does not, stop: the machine does not have the migration commits yet.
2. Run `mise --version`. The version must be 2026.9.2 or newer; otherwise ask before running `mise self-update`.
3. Take an inventory, so you can show the user a before/after comparison:
   - macOS/Linux: `which -a claude codex pi omp opencode; for b in claude codex pi omp opencode; do $b --version; done`
   - Windows: `Get-Command -All claude,codex,pi,omp,opencode | Format-Table Name,Source`
   - Also list package-managed copies: `ls ~/.bun/install/global/node_modules/{@openai,@earendil-works,@oh-my-pi,opencode-ai}`
     and `mise exec -- npm ls -g --depth=0` (look for `@openai/codex`, `@anthropic-ai/claude-code`,
     `@earendil-works/pi-coding-agent`, `@oh-my-pi/pi-coding-agent`, `opencode-ai`).
4. Ask the user to quit running sessions of these agents, because the installers replace their binaries.
   Leave Claude Code running; the update only takes effect on the next start.

### 2. Apply dotfiles, then install

1. Run `mise run sync`. This links the V2 `opencode.json` and declares `cli.json` tracking.
2. Run `mise run ai:sync` with a long timeout. It removes the old Bun packages, installs or upgrades each
   agent, configures the Codex MCP, and runs `ai:doctor`.
   - The first PI install shows a menu and waits for one keypress (Enter) when a terminal is attached.
     If you have no TTY, it continues on its own.
   - The OpenCode V2 installer replaces V1 in `~/.opencode/bin` (on macOS/Linux).
3. If npm (not Bun) holds any of the packages from step 1, remove them with
   `mise exec -- npm uninstall -g <pkg>`. `ai:install` only removes Bun copies.
4. The installers may append PATH lines to shell profiles. Run `mise run sync` again so the templated
   `~/.zshrc` and fish config are re-rendered. Check `~/.zprofile`, `~/.bash_profile`, `~/.bashrc`,
   and `~/.profile` for new `codex`, `opencode`, or `pi` lines; they are usually redundant, since
   `~/.local/bin` and `~/.opencode/bin` are already on PATH. Mention any you find, but don't delete them
   without asking.

### 3. Migrate OpenCode V1 to V2

Reference: https://opencode.ai/v2/docs/migrate-v1/

1. Run `opencode --version`. It must print `v2.x`.
2. Run `opencode debug config` from a neutral directory. The output should show the repo `opencode.json`
   parsed, with `mcp.servers.chrome-devtools` and `providers.openai.models.gpt-6-astra.settings`,
   and no warnings.
3. Create `cli.json` by starting the TUI once, so V2 migrates `tui.json` and its persisted preferences
   itself. Do not hand-write the file. Either ask the user to run `opencode` and quit, or, on
   macOS/Linux without a TTY, run it in a pseudo-terminal for about 8 seconds:
   `script -q /dev/null opencode >/dev/null 2>&1 & sleep 8; pkill -f 'opencode$'`.
   Expected result: `~/.config/opencode/cli.json` containing
   `{"$schema": "https://opencode.ai/v2/cli.json", "theme": {"name": "cyberdream"}}`.
   If `tui.json` was missing, write exactly that.
4. The V1-format cyberdream theme in `~/.config/opencode/themes/` works in V2 as is; don't convert it.
5. V2 starts a background service (`opencode serve --service`). This is expected.

### 4. Clean up (ask once, then delete)

Show the user this list and get a yes before deleting. On the main Mac, the user approved all of it.

- In `~/.config/opencode/` (on Windows, `$HOME\.config\opencode\`): `tui.json`, `package.json`,
  `package-lock.json`, `bun.lock`, `node_modules/`, `.gitignore`, and `tool/` (the V1 custom
  `kitty_capture.ts` tool, which V2 cannot run). Keep `AGENTS.md`, `opencode.json`, `cli.json`,
  `service.json`, and `themes/`.
- Windows only: a leftover V1 `opencode.exe` in `~\.opencode\bin` or from scoop/choco/winget. Check
  that `Get-Command opencode` resolves to `~\.bun\bin` first.
- Any scratch files or backups you created during this run.

### 5. Verify and report

1. Run `mise run ai:doctor`. It must list all six agents at the target paths above.
2. Run `mise run ai:install` a second time. Every agent should report that it is already up to date
   (Codex reinstalls the same version). This confirms that the upgrade path works.
3. Run `mise bootstrap dotfiles status --missing`; nothing should be missing.
4. Tell the user the before/after versions and paths, anything left unresolved (such as profile lines
   or failed steps, with their output), and that nothing was committed.

Once every machine has been migrated, the user can delete `.claude/skills/migrate-agents/`.
