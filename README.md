To install:

0. Install all required software: https://few-torta-1c7.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5
1. `cd frixaco`
2. `stow --adopt --simulate --verbose --no-folding . -t $HOME` (remove `--simulate` flag to actually apply changes)

Requirements:

- See: https://few-torta-1c7.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5

TODO:

- [ ] SSH keys setup (1Passwod seems to work)
- [ ] AWS credentials setup
- [ ] Yabai auto-updater

List of app, OS settings, etc.: https://few-torta-1c7.notion.site/System-Setup-1395a0964d914e6e92442fafbf6334a5?pvs=4

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
