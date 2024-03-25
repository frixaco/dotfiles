#!/usr/bin/env fish

set -L location "Where do you want to store the project? (default=same as project name): "
set -L default_location (string split "/" $argv[1])[-1]

read -P $location -l project_path
if test -z "$project_path"
  set project_path $default_location
end
echo $project_path

mkdir $project_path
cd $project_path

echo "Cloning bare repository to .bare ..."
git clone --bare git@github.com:$argv[1].git .bare

echo "Setting .git file contents ..."
echo "gitdir: ./.bare" > .git

echo "Adjusting origin fetch locations ..."
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

echo "Checking out main branch ..."
git worktree add main main

echo "cd to main ..."
cd main
