To setup the dotfiles, I used this blog: https://www.atlassian.com/git/tutorials/dotfiles

## How to view via lazygit?

```bash
lazygit -g $HOME/.cfg/ -w $HOME
```

## What asdf plugins are needed?

### Node.js

```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs 16.16.0
```

### Golang

```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install golang 1.18.3
```

### Ruby

```bash
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.1.2
```

### How to install Nerd Fonts? (JetBrainsMono Nerd Font)

```bash
git clone https://github.com/ronniedroid/getnf.git
cd getnf
./getnf
```
