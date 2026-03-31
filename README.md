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

- AI agents:
  ```
  amp, opencode, claude - bash script install
  bun i -g @openai/codex @mariozechner/pi-coding-agent
  ```

**AGENTS.md Symlinks**

All AI agent tools share a single `~/.config/AGENTS.md` via symlinks:

```bash
mkdir -p \
  ~/.claude \
  ~/.config/opencode \
  ~/.pi/agent \
  ~/.config/amp \
  ~/.factory \
  ~/.codex && \
ln -sfn ~/.config/AGENTS.md ~/.claude/CLAUDE.md && \
ln -sfn ~/.config/AGENTS.md ~/.config/opencode/AGENTS.md && \
ln -sfn ~/.config/AGENTS.md ~/.pi/agent/AGENTS.md && \
ln -sfn ~/.config/AGENTS.md ~/.config/amp/AGENTS.md && \
ln -sfn ~/.config/AGENTS.md ~/.factory/AGENTS.md && \
ln -sfn ~/.config/AGENTS.md ~/.codex/AGENTS.md
```

Skills live in `~/.agents/skills/` (Amp, Codex, OpenCode, Pi). F*ck Claude Code for using `~/.claude/skills`:

```bash
rm -rf ~/.claude/skills
ln -s ~/.agents/skills ~/.claude/skills

rm -rf ~/.factory/skills
ln -s ~/.agents/skills ~/.factory/skills
```

**Theme**

- Run `theme-light` or `theme-dark` after OS theme change

