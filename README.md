To install:

0. Install all required software: [Heptabase map]([https://frixaco.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5?pvs=74](https://app.heptabase.com/w/5f446947094a1d734c06e5a6bbc983b79075e6a3a00ddbf433345dbc509e7ec5))
1. `cd .dotfiles/frixaco`
2. `stow --adopt --simulate --verbose --no-folding . -t $HOME` (remove `--simulate` flag to actually apply changes)

Requirements:

- See: [Heptabase map]([https://frixaco.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5?pvs=74](https://app.heptabase.com/w/5f446947094a1d734c06e5a6bbc983b79075e6a3a00ddbf433345dbc509e7ec5))

TODO:

- [ ] Fix duplicate diagnostics in Neovim
- [ ] Add video demo of my setup
- [ ] SSH keys setup (1Passwod seems to work)
- [ ] AWS credentials setup
- [ ] Easier setup between macOS, Windows, Linux

List of app, OS settings, etc.: [Heptabase map]([https://frixaco.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5?pvs=74](https://app.heptabase.com/w/5f446947094a1d734c06e5a6bbc983b79075e6a3a00ddbf433345dbc509e7ec5))

### Yabai

Updating from HEAD:

```fish
export YABAI_CERT=
yabai --stop-service
yabai --uninstall-service
brew reinstall koekeishiya/formulae/yabai
set -x YABAI_CERT yabai-cert
codesign -fs "$YABAI_CERT" (brew --prefix yabai)/bin/yabai
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
yabai --start-service
```

For installing:

```fish
codesign -fs 'yabai-cert' $(brew --prefix yabai)/bin/yabai
```
