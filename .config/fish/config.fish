source ~/.config/fish/alias.fish

# Load all saved ssh keys
/usr/bin/ssh-add -A ^/dev/null

# for WSL2 (Ubuntu) (not Distrod)
# echo "qwe" | sudo -S bash ~/startup.sh
# clear

# Remove greeting
set -U fish_greeting

# Vim
function fish_user_key_bindings
  fish_vi_key_bindings
end

# Starship prompt
# starship init fish | source

# Rust
set -Ua fish_user_paths $HOME/.cargo/bin

# Bun
set -Ux BUN_INSTALL "/home/frixaco/.bun"
set -px --path PATH "/home/frixaco/.bun/bin"

source ~/.asdf/asdf.fish
