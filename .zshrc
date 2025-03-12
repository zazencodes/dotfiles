if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Shell config
export LANG=en_US.UTF-8

# Alacritty config
# https://chatgpt.com/c/a7b8eecc-e9d4-490d-9379-583c954945e3
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Extend PATH
export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
# export PATH="/opt/homebrew/opt/openjdk/bin:$PATH" # Add homebrew java to path
# export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# Load credentials
source $HOME/.secrets.sh

# Neovim
alias v=nvim
alias vim=nvim
export VISUAL=nvim
export EDITOR="$VISUAL"

# fzf (Overrides and ctrl+r ctrl+t [cd with fuzzy search])
# Need to install fd for commands below to work
source <(fzf --zsh)
export FZF_CTRL_R_OPTS="--height=1 --reverse --no-scrollbar"
export FZF_CTRL_T_OPTS="--height 40% --no-scrollbar"
export FZF_CTRL_T_COMMAND='fd --hidden --follow --exclude .git'

# cd widget using fd, ignore git and sort folders by depth (will fail for really large dirs, e.g. ~/)
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git . | awk -F'/' '{print NF-1, \$0}' | sort -n | cut -d' ' -f2-"
# Use cd widget with Ctrl+O (default is Alt+C)
bindkey '^G' fzf-cd-widget

# **<tab> using fd, ignore git and sort folders by depth (will fail for really large dirs, e.g. ~/)
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1" | awk -F'/' '{print NF-1, $0}' | sort -n | cut -d' ' -f2-
}


# eza
export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:oc=0:xa=0:uu=0:uR=0:un=0:gu=0:gR=0:gn=0:lc=0:lm=0:sn=0:nb=0:nk=0:nm=0:ng=0:nt=0"
alias ls="eza --long --icons=always"
alias lr="eza --long --icons=always --sort=newest --reverse"
alias lt="eza --long --icons=always -T"
alias lt2="eza --long --icons=always -T -L=2"
alias lt3="eza --long --icons=always -T -L=3"

# Tmux
alias t=tmux

# Python
# Use symlinks instead of aliases, for proper virtual env activation support
# >>> ln -vs /opt/homebrew/bin/python3.12 ~/bin/python
# >>> ln -vs /opt/homebrew/bin/pip3.12 ~/bin/pip
# alias python3.12=/opt/homebrew/bin/python3.12
# alias pip3.12=/opt/homebrew/bin/pip3.12
# alias python=/opt/homebrew/bin/python3.12
# alias pip=/opt/homebrew/bin/pip3.12
alias python3=/opt/homebrew/bin/python3.12
alias pip3=/opt/homebrew/bin/pip3.12
alias pyv=$HOME/virtualenvs/adhoc/bin/python
alias piv=$HOME/virtualenvs/adhoc/bin/pip
alias jn='$HOME/virtualenvs/adhoc/bin/jupyter notebook'
alias jc='$HOME/virtualenvs/adhoc/bin/jupyter console'
export JUPYTER_NOTEBOOK_STYLE='from IPython.display import HTML;HTML("<style>div.text_cell_render{font-size:130%;padding-top:50px;padding-bottom:50px}</style>")'

# Git
alias gits='git status'
alias gita='git add -u'
gitm() { git commit -m "$1" }
alias gitp='git push'
alias gitu='git commit -m "Update $(date +%F)"'
alias gitq='git add -u && git commit -m "Update $(date +%F)" && git push'
alias gitc='aicommits' # requires aicommits installed (https://github.com/Nutlope/aicommits)

# Plain text
export EDITOR='mate -w'
nn() { touch ~/Downloads/$1 && mate $1 }

# Obsidian
alias oo='cd $HOME/obsidian/ZazenCodes'
alias or='vim $HOME/obsidian/ZazenCodes/inbox/*.md'
alias ou='cd $HOME/pro/notion-obsidian-sync-zazencodes && node batchUpload.js --lastmod-days-window 5'

# Path shortcuts
alias nvc='cd $HOME/.config/nvim && vim'
alias zc='cd $HOME/pro/zazencodes-season-2/src'

# App aliases
alias cat='bat -pp'
# alias vue='$HOME/.yarn/bin/vue'
# alias httpx='$HOME/go/bin/httpx'
# alias sqlj='java -jar /Applications/SQLWorkbenchJ.app/Contents/Java/sqlworkbench.jar </dev/null &>/dev/null &'

# App shortcuts
alias lg=lazygit
# alias leet="nvim leetcode.nvim"

# Dir list, nav
alias pwdy="echo $(pwd) | pbcopy"
alias cl="clear"
alias z="cd"
# alias lr="ls -lrt"
# alias zr="cd $(ls -td -- $(pwd)/*/ | head -n 1)"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Colors
# alias ls="ls -G"

# Zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Only use p10k (terminal runs much faster than with full oh-my-zsh setup)
# I just put it in the ~/.oh-my-zsh folder for legacy reasons
# Install: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# Installed with brew
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# This file (below) is generated when running p10k config for the first time
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# AI
alias llm_deepseek="llm -m deepseek-r1:8b "
alias llm_cat_dir="find . -maxdepth 1 -type f | xargs -I {} sh -c 'echo \"\n=== {} ===\n\"; cat {}'"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alex/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alex/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/completion.zsh.inc'; fi

