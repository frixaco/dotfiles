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

set -gx FZF_DEFAULT_COMMAND 'fd -L -H -I -E .aws-sam -E Library -E .cache -E .gradle -E .vscode/extensions -E .git -E .pyenv -E .venv -E venv -E .npm -E .yarn -E node_modules -E .next -E .open-next -d 5'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

set -gx BUN_INSTALL ~/.bun

fish_add_path $BUN_INSTALL/bin ~/.amplify/bin ~/.local/bin $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools $EMSDK/upstream/bin ~/.cargo/bin

alias ls="eza"
alias z="zoxide"
alias v="nvim"
alias en="cd ~/.config/nvim && nvim"
alias y="yazi"
alias sf="source ~/.config/fish/config.fish"
alias c="clear"
alias ef="nvim ~/.config/fish/config.fish"

function lg
  set -gx LAZYGIT_NEW_DIR_FILE ~/.lazygit/newdir

  lazygit $argv

  if test -f $LAZYGIT_NEW_DIR_FILE
    cd (cat $LAZYGIT_NEW_DIR_FILE)
    or exit
    rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
  end
end

starship init fish | source
zoxide init fish | source
~/.local/bin/mise activate fish | source
