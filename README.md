Initially, inspired by https://www.atlassian.com/git/tutorials/dotfiles.

## I'm using:

- Tmux
- Neovim (built from source)
- i3
- asdf (for node.js, golang, ruby, java)
- Fish shell
- Kitty terminal (MacOS/Linux), Windows Terminal (WSL2)
- getnf (to install Nerf Fonts: JetBrainsMono Nerf Font, MesloLGS NF, FiraCode Nerd Font)

## Setup FISH shell

Install prompt manager using Fisher plugin manager: https://github.com/IlanCosman/tide

## WSL2

[Distrod](https://github.com/nullpo-head/wsl-distrod) - to install Arch Linux

**Note**: If start on Windows startup command isn't working, run it `wsl -d Distrod`

## What asdf plugins are needed?

### Node.js

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs 16.16.0
```

### Golang

```bash
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
asdf install golang 1.18.3
```

### Ruby

```bash
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.1.2
```

## How to install Nerd Fonts? (JetBrainsMono Nerd Font)

```bash
git clone https://github.com/ronniedroid/getnf.git
cd getnf
./getnf
```
