if test (uname) = "Darwin"
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
else if test (uname) = "Linux"
    fish_add_path /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
end

if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end
