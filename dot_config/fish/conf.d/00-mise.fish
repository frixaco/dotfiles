fish_add_path /opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/mise/bin

if test -x /opt/homebrew/opt/mise/bin/mise
    /opt/homebrew/opt/mise/bin/mise activate fish | source
else if test -x /opt/homebrew/bin/mise
    /opt/homebrew/bin/mise activate fish | source
end
