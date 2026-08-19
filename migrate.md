# Migrate an old machine to `~/stuff`

Move existing data **before** you run `mise run sync`. The sync task creates destination directories, but it does not migrate existing files.

First, commit and push the dotfiles changes from the updated machine. Then use the applicable case below.

## If the old root is `~/projects`

Close editors, audio tools, Blender, and terminals that use the old path. Then run:

```bash
cd ~/.dotfiles
git pull

test -d "$HOME/projects"
test ! -e "$HOME/stuff"

mv "$HOME/projects" "$HOME/stuff"
mv "$HOME/stuff/downloads" "$HOME/stuff/dump"
```

These are same-filesystem directory renames. They do not copy or delete the files.

## If Vbrato is under `~/Documents`

Do not rename the complete `Documents` folder. Move only your managed folders:

```bash
cd ~/.dotfiles
git pull

test -d "$HOME/Documents/vbrato"
test ! -e "$HOME/stuff"

mkdir -p "$HOME/stuff/code"
mv "$HOME/Documents/vbrato" "$HOME/stuff/code/vbrato"
```

Move other old categories only when they exist and the destination does not:

```bash
test ! -e "$HOME/stuff/music" && \
  mv "$HOME/Documents/music" "$HOME/stuff/music"

test ! -e "$HOME/stuff/2d" && \
  mv "$HOME/Documents/2d" "$HOME/stuff/2d"

test ! -e "$HOME/stuff/3d" && \
  mv "$HOME/Documents/3d" "$HOME/stuff/3d"
```

Do not move the OS `~/Downloads` directory unless you intentionally want all of it in `~/stuff/dump`.

## Update the local mise override

Change `~/.dotfiles/mise.local.toml` to contain only:

```toml
[vars]
work = true
```

Remove its old `[dotfiles]` section.

## Apply and verify

```bash
cd ~/.dotfiles
mise run sync

test -d "$HOME/stuff/code"
test -d "$HOME/stuff/2d/refs"
test -d "$HOME/stuff/3d/refs"
test -d "$HOME/stuff/dump"
```

For a Vbrato repository:

```bash
git -C "$HOME/stuff/code/vbrato/REPOSITORY" config user.email
```

Expected:

```text
rashurmatov@vbrato.io
```

For a personal repository outside `~/stuff/code/vbrato/`, the expected email is:

```text
rustam21ashurmatov@gmail.com
```

Stop if `~/stuff` already exists. Do not merge two populated directory trees with `mv`; inspect collisions first.
