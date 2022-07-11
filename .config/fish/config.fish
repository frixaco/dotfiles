alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

function fish_greeting
	echo "Always read errors."
end

source /opt/asdf-vm/asdf.fish

set -gx EDITOR nvim

starship init fish | source
