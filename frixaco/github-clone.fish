#!/usr/bin/env fish

if test (count $argv) -eq 1
    git clone git@github.com:$argv[1].git
else if test (count $argv) -eq 2
    git clone git@github.com:$argv[1].git $argv[2]
end
