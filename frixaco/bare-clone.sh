#!/bin/bash

echo "Cloning bare repository to .bare ..."
git clone --bare git@github.com:$1.git .bare

echo "Adjusting origin fetch locations ..."
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

echo "Setting .git file contents ..."
echo "gitdir: ./.bare" > .git

msg "Checking out main branch ..."
git worktree add main main
