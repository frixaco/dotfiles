get_node_info() {
    local node_version
    node_version=$(node -v)
    if [ -f package.json ]; then
        echo " \ue718 $node_version" | sed 's/v//'
    fi
}

get_go_info() {
    local go_version
    go_version=$(go version)
    if [ -f go.mod ]; then
        echo " \ue724 $go_version" | sed 's/v//'
    fi
}

get_rust_info() {
    local rust_version
    rust_version=$(rustc --version)
    if [ -f Cargo.toml ]; then
        echo " \ue7a8 $rust_version" | sed 's/v//'
    fi
}

get_python_info() {
    local python_version
    python_version=$(python3 -V | sed 's/Python //')
    local py_file_count=$(fd -d 1 -e .py | wc -l | sed 's/ //g')

    if [ $py_file_count -gt 0 ]; then
        echo " \ue73c $python_version" | sed 's/v//'
    fi
}

get_git_info() {
    # if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ -d .git ]] || [[ -f .git ]] then
      local staged_files=$(git diff --cached --name-only | wc -l | sed 's/ //g')
      local unstaged_untracked_files=$(git status --porcelain --untracked-files=all | wc -l | sed 's/ //g')
      # local commits_not_pushed=$(git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline | wc -l | sed 's/ //g')
      # local commits_need_pull=$(git log HEAD..origin/$(git rev-parse --abbrev-ref HEAD) --oneline | wc -l | sed 's/ //g')
      local branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

      # echo " \ue702 ($branch_name) +$staged_files *$unstaged_untracked_files \u2193$commits_not_pushed \u2191$commits_need_pull"
      echo " \ue702 ($branch_name) +$staged_files *$unstaged_untracked_files"
    fi
}

setopt prompt_subst
precmd() {
    local info="%F{#F9E2AF}$(get_node_info)%f%F{#89B4FA}$(get_python_info)%f%F{#74C7EC}$(get_go_info)%f%F{#F38BA8}$(get_rust_info)%f%F{#A6E3A1}$(get_git_info)%f";
    PROMPT="%F{#F5C2E7}%B(%n)%b%f%f %F{#BAC2DE}%1~%f$info %F{#CBA6F7}●%f "
}

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# HOMEBREW completions
if  [[ "$OSTYPE" == "darwin"* ]]; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

my_configs=(
    "$HOME/.asdf/asdf.sh"
)

for f in $my_configs; do
    . $f
done

# append completions to fpath
fpath=(${ASDF_DIR}/completions ~/.zsh/completion $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

. ~/.asdf/plugins/java/set-java-home.zsh

export ANDROID_HOME=$HOME/Library/Android/sdk

NEW_PATH="$PATH"
ADDITIONAL_PATHS=(
    $HOME/.local/bin
    $HOME/go/bin
    $HOME/.pyenv/shims
    $ANDROID_HOME/emulator
    $ANDROID_HOME/platform-tools
    $EMSDK/upstream/bin
    $HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin
)
for path in "${ADDITIONAL_PATHS[@]}"; do
    if [[ -d $path && ! $NEW_PATH =~ (^|:)$path(:|$) ]]; then
        NEW_PATH="$NEW_PATH:$path"
    fi
done
export PATH="$NEW_PATH"

export XDG_CONFIG_HOME="$HOME/.config"

export GPG_TTY=$(tty)

# export FZF_DEFAULT_COMMAND='fd --follow --hidden --no-ignore --exclude .git --exclude node_modules --exclude Library --exclude .cache --exclude .gradle --exclude .vscode\/extensions'
export FZF_DEFAULT_COMMAND='fd -L -H -I -E .aws-sam -E Library -E .cache -E .gradle -E .vscode\/extensions -E .git -E .pyenv -E .venv -E venv -E .npm -E .yarn -E node_modules -E .next -E .open-next -d 5'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

alias z=zoxide
alias x=xplr
alias sz="source ~/.zshrc"
alias ez="nvim ~/.zshrc"
alias ls='eza'
alias v='nvim'

eval "$(zoxide init zsh)"

# bun completions
[ -s "/Users/frixaco/.bun/_bun" ] && source "/Users/frixaco/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
