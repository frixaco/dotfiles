#!/usr/bin/env bash
# Bootstrap a machine from these dotfiles using mise.
#   curl -fsSL https://raw.githubusercontent.com/frixaco/dotfiles/main/setup.sh | bash
set -euo pipefail

REPO="${DOTFILES_DIR:-$HOME/.dotfiles}"

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ ! -d "$REPO/.git" ]; then
  git clone https://github.com/frixaco/dotfiles.git "$REPO"
fi
cd "$REPO"

mise trust
mise bootstrap --yes
