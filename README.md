### my dotfiles managed by `chezmoi`

**NOTES**

- `chezmoi init git@github.com:frixaco/dotfiles.git --apply` - `--apply` immediately sets up all the files

- `chezmoi` docs: https://www.chezmoi.io/user-guide/daily-operations/

- `~/.config/chezmoi/chezmoi.toml`:

  ```
  [data]
  work = true/false
  ```

- `fish_config theme save cyberdream`

**AGENTS.md Symlinks**

All AI agent tools share a single `~/.config/AGENTS.md` via symlinks:

| Tool        | Symlink Path                   |
| ----------- | ------------------------------ |
| claude code | `~/.claude/CLAUDE.md`          |
| opencode    | `~/.config/opencode/AGENTS.md` |
| pi          | `~/.pi/agent/AGENTS.md`        |
| ampcode     | `~/.config/amp/AGENTS.md`      |
| droid       | `~/.factory/AGENTS.md`         |
| codex       | `~/.codex/AGENTS.md`           |

```bash
mkdir -p ~/.claude ~/.config/opencode ~/.pi/agent ~/.config/amp ~/.factory ~/.codex && \
ln -sf ~/.config/AGENTS.md ~/.claude/CLAUDE.md && \
ln -sf ~/.config/AGENTS.md ~/.config/opencode/AGENTS.md && \
ln -sf ~/.config/AGENTS.md ~/.pi/agent/AGENTS.md && \
ln -sf ~/.config/AGENTS.md ~/.config/amp/AGENTS.md && \
ln -sf ~/.config/AGENTS.md ~/.factory/AGENTS.md && \
ln -sf ~/.config/AGENTS.md ~/.codex/AGENTS.md
```
