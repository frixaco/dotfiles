switch (uname)
  case Darwin
    /opt/homebrew/bin/brew shellenv | source
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting

if set -q SSH_CONNECTION
    set -gx EDITOR vim
else
    set -gx EDITOR nvim
end

switch (uname)
  case Darwin
    set -gx ANDROID_HOME ~/Library/Android/sdk
    set -gx NDK_HOME ~/Library/Android/sdk/ndk/25.2.9519653
    set -gx JAVA_HOME /Applications/Android\ Studio.app/Contents/jbr/Contents/Home
  case Linux
    set -gx ANDROID_HOME ~/Android/sdk
    fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
end

set -gx XDG_CONFIG_HOME ~/.config
set -gx GPG_TTY (tty)

set -gx BUN_INSTALL ~/.bun
set -gx DENO_INSTALL $HOME/.deno

fish_add_path /opt/homebrew/opt/grep/libexec/gnubin 
fish_add_path $HOME/.orbstack/bin $HOME/stuff/flutter/bin $DENO_INSTALL/bin $BUN_INSTALL/bin ~/.amplify/bin ~/.local/bin $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools $EMSDK/upstream/bin ~/.cargo/bin

alias l="eza --color=always --icons --all --long --time modified --sort modified --no-permissions --octal-permissions --git --smart-group"
alias v="nvim"
alias en="cd ~/.config/nvim && nvim"
alias y="yazi"
alias sf="source ~/.config/fish/config.fish"
alias c="clear"
alias ef="nvim ~/.config/fish/config.fish"

# Switched to uv, will keep for now
# function mpy
#   echo -e "[tools]\npython = { version=\"3.12\", virtualenv=\".venv\" }" > .mise.toml
# end

function g
  set -gx LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir

  # sudo lazygit $argv
  # with sudo lazygit i keep getting confirmation prompts
  lazygit $argv

  if test -f $LAZYGIT_NEW_DIR_FILE
    cd (cat $LAZYGIT_NEW_DIR_FILE)
    or exit
    rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
  end
end

if test -f ~/.config/fish/env.fish 
  source ~/.config/fish/env.fish
end

starship init fish | source

fzf --fish | source
set -gx FZF_DEFAULT_COMMAND 'fd --follow --hidden --no-ignore --exclude .aws-sam --exclude Library --exclude .cache --exclude .gradle --exclude .vscode/extensions --exclude .git/ --exclude .pyenv --exclude .venv --exclude .npm --exclude .yarn --exclude node_modules --exclude .next/ --exclude .open-next/'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

zoxide init fish | source
# jumper shell fish | source
~/.local/bin/mise activate fish | source

switch (uname)
  case Darwin
    # pnpm
    set -gx PNPM_HOME "/Users/frixaco/Library/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
      set -gx PATH "$PNPM_HOME" $PATH
    end
    # pnpm end
  case Linux
    # pnpm
    set -gx PNPM_HOME "/home/frixaco/.local/share/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
      set -gx PATH "$PNPM_HOME" $PATH
    end
    # pnpm end
end
