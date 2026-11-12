# dotfiles

> "We become what we behold. We shape our tools and then our tools shape us."

---

> [!NOTE]
> Consider checking out the [current year branch](https://github.com/zazencodes/dotfiles/tree/year/2026) of this repo to see my current setup.

## Configs

Hotkeys are documented in [docs/hammerspoon.md](docs/hammerspoon.md) and [docs/aerospace.md](docs/aerospace.md).

```bash
git clone https://github.com/agalea91/dotfiles.git ~/dotfiles
# ln -s ~/dotfiles/alacritty ~/.config/alacritty
ln -s ~/dotfiles/ghostty ~/.config/ghostty
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.aerospace.toml ~/.aerospace.toml
mkdir ~/.hammerspoon
ln -s ~/dotfiles/hammerspoon/init.lua ~/.hammerspoon/init.lua
mkdir -p ~/.secrets
ln -s ~/dotfiles/secrets/README.md ~/.secrets/README.md

# private aliases (gitignored, machine-local; copy over by hand if wanted)
touch ~/dotfiles/.zshrc.private

# llm cli tool templates
# Do not run this until after you have installed llm
rm -rf ~/Library/Application\ Support/io.datasette.llm/templates # delete if exists
ln -s ~/dotfiles/llm/templates ~/Library/Application\ Support/io.datasette.llm
```

## Private zsh aliases (`.zshrc.private`)

This repo is public, so aliases that name clients or private projects live in `~/dotfiles/.zshrc.private` instead of `.zshrc`.

- `.zshrc` sources it near the Obsidian aliases: `[[ -f $HOME/dotfiles/.zshrc.private ]] && source $HOME/dotfiles/.zshrc.private`.
- It's listed in `.gitignore`, so git never commits or pushes it.
- It exists only on this Mac. A fresh clone won't have it; copy it across by hand if you want the same aliases on another machine.
- To add one, append a line such as `alias o-example='cd "$HOME/path/to/dir"'`, then run `source ~/.zshrc`.

## `/bin`

Bash scripts which are intended to be symlinked with `~/bin`

These symlinks should be created one time, by running the following:

```bash
mkdir -p ~/bin
./symlink_dotfiles.sh bin

# Runs symlink command for each file in ~/dotfiles/bin
# But ignores files that are already symlinked
# e.g.
# ln -s ~/dotfiles/bin/on ~/bin/on
```

## `/opt`

Libraries which are intended to be symlinked with `~/opt`

```bash
mkdir -p ~/opt
./symlink_dotfiles.sh opt

