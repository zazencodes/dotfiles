# dotfiles

> “We become what we behold. We shape our tools and then our tools shape us”.

## Configs
```bash
git clone https://github.com/agalea91/dotfiles.git ~/dotfiles
ln -s ~/dotfiles/alacritty ~/.config/alacritty
ln -s ~/dotfiles/llm/templates ~/Library/Application\ Support/io.datasette.llm/templates
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
```

## Scripts
```bash
./symlink_dotfiles.sh

# Runs symlink command for each file in ~/dotfiles/bin
# But ignores files that are already symlinked
# e.g.
# ln -s ~/dotfiles/bin/on ~/bin/on
```


