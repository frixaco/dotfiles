#!/usr/bin/env bash
# Bootstrap a machine from these dotfiles using mise.
#   curl -fsSL https://dotfiles.frixaco.com | bash
set -euo pipefail

# Wrapped in a function so `curl | bash` reads the whole script before running it.
main() {
  local repo="$HOME/.dotfiles" status=0

  if ! command -v mise &>/dev/null; then
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  if [ -d "$repo/.git" ]; then
    # Reuse any existing checkout, whatever its origin (HTTPS or SSH).
    mise trust "$repo"
    mise -C "$repo" bootstrap --force-dotfiles --yes || status=$?
  else
    # Clones the repo (offering to install Git if missing) and applies everything.
    mise bootstrap --from https://github.com/frixaco/dotfiles.git --from-dir "$repo" \
      --force-dotfiles --yes || status=$?
    # Trust the checkout even if bootstrap failed, so `mise run sync` can finish the job.
    if [ -d "$repo/.git" ]; then mise trust "$repo"; fi
  fi

  return "$status"
}

main "$@"
