{%- if os() == "macos" -%}
fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
{%- elif os() == "linux" -%}
/home/linuxbrew/.linuxbrew/bin/brew shellenv | source
{%- endif %}
fish_add_path -g ~/.local/bin ~/.bun/bin ~/.opencode/bin
{%- if os() == "macos" %}
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
fish_add_path -g "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator" /Applications/Obsidian.app/Contents/MacOS
{%- elif os() == "linux" %}
fish_add_path -g /usr/local/bin/obsidian
{%- endif %}

# After every fish_add_path: those reorder PATH and would bury mise's tools.
# Full activation at the prompt, shims for scripts and editors.
if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

set -g fish_greeting

set -gx EDITOR nvim

{%- if os() == "macos" %}
set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"
{%- endif %}

# for Lazygit config to work
set -gx XDG_CONFIG_HOME "$HOME/.config"

alias l="eza --color=always --icons --all --long --time modified --sort modified --no-permissions --octal-permissions --git --smart-group --git-repos"
alias v="nvim"
alias en="cd ~/.config/nvim && nvim"
alias sf="source ~/.config/fish/config.fish"
alias c="clear"
alias ef="nvim ~/.dotfiles/home/.config/fish/config.fish"
alias oc="opencode"
alias se="source .venv/bin/activate.fish"
alias cx="codex --yolo"
alias cl="claude --permission-mode bypassPermissions"

function upall --description 'Update mise, packages, tools, agents, and dotfiles'
    mise -C ~/.dotfiles run up
end

function ccd
    cd ~/.dotfiles
end

{%- if os() == "linux" %}
{% if env.WSL_DISTRO_NAME is defined %}
function copy-to-desktop --description 'Copy file(s) to WSL Desktop (/mnt/c/Users/frixa/Desktop)'
    if test (count $argv) -eq 0
        echo "Usage: copy-to-desktop <file1> [file2 ...]"
        return 1
    end
    
    set target_dir "/mnt/c/Users/frixa/Desktop"
    
    if not test -d $target_dir
        echo "Error: Desktop directory not found: $target_dir"
        return 1
    end
    
    for file in $argv
        if test -e $file
            cp $file $target_dir
            echo "Copied: $file -> $target_dir/"
        else
            echo "Error: File not found: $file"
        end
    end
end
{% endif %}
{%- endif %}

function envsource
    if not test -f $argv[1]
        echo "Error: File $argv[1] not found"
        return 1
    end

    while read -l line
        # Skip comments and empty lines
        if string match -qv '#*' $line; and string length -q (string trim $line)
            set -l item (string split -m 1 '=' $line)
            if test (count $item) -eq 2
                set -gx $item[1] (string trim -c '"\'' $item[2])
            end
        end
    end < $argv[1]
end

function g
  set -l original_dir (pwd)

  lazygit $argv

  cd $original_dir
end

function j
  set -l original_dir (pwd)

  jjui $argv

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

if status is-interactive
    command -q zoxide; and zoxide init fish | source
    command -q starship; and starship init fish | source
    command -q fzf; and fzf --fish | source
end
{% if vars.work and os() == "macos" -%}
rbenv init - fish | source
{%- endif -%}

{%- if os() == "macos" %}
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
{%- endif %}
