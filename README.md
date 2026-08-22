# dotfiles

> "We become what we behold. We shape our tools and then our tools shape us."

---

> [!NOTE]
> Consider checking out the [current year branch](https://github.com/zazencodes/dotfiles/tree/year/2026) of this repo to see my current setup.

## Configs
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

# llm cli tool templates
# Do not run this until after you have installed llm
rm -rf ~/Library/Application\ Support/io.datasette.llm/templates # delete if exists
ln -s ~/dotfiles/llm/templates ~/Library/Application\ Support/io.datasette.llm
```

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

