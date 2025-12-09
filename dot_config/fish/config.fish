set -g fish_greeting

set -gx EDITOR nvim

# for Lazygit config to work
set -gx XDG_CONFIG_HOME "$HOME/.config"

alias l="eza --color=always --icons --all --long --time modified --sort modified --no-permissions --octal-permissions --git --smart-group --git-repos"
alias v="nvim"
alias en="cd ~/.config/nvim && nvim"
alias sf="source ~/.config/fish/config.fish"
alias c="clear"
alias ef="nvim ~/.config/fish/config.fish"
alias amp="bunx @sourcegraph/amp --ide"
alias opencode="bunx opencode-ai"
alias codex="bunx @openai/codex"
alias claude="bunx @anthropic-ai/claude-code"

function g
  set -l original_dir (pwd)

  lazygit $argv

  cd $original_dir
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

if test -f ~/.config/fish/env.fish 
  source ~/.config/fish/env.fish
end

zoxide init fish | source
starship init fish | source
fzf --fish | source
