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
export PATH=~/bin:$PATH
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH" # Add homebrew java to path

# Load credentials
source $HOME/.secrets.sh

# Neovim
alias v=nvim
alias vim=nvim
export VISUAL=nvim
# export EDITOR="$VISUAL"

# Zoxide
# eval "$(zoxide init --cmd=cd zsh)"

# Tmux
alias t=tmux

# Python
# Note: use symlinks, e.g.
# >>> ln -vs /opt/homebrew/bin/python3.9 ~/bin/python
# >>> ln -vs /opt/homebrew/bin/pip3.9 ~/bin/pip
alias python3.12=/opt/homebrew/bin/python3.12
alias pip3.12=/opt/homebrew/bin/pip3.12
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
alias oo='cd $HOME/library/Mobile\ Documents/iCloud~md~obsidian/Documents/ZazenCodes'
alias or='vim $HOME/library/Mobile\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/inbox/*.md'
alias ou='cd $HOME/notion-obsidian-sync-zazencodes && node batchUpload.js --lastmod-days-window 5'
alias oo2='cd $HOME/pro/ZazenCodes'
alias or2='vim $HOME/pro/ZazenCodes/inbox/*.md'
alias ou2='cd $HOME/pro/notion-obsidian-sync-zazencodes && node batchUpload.js --lastmod-days-window 5'

# Path shortcuts
alias nvc='cd $HOME/.config/nvim && vim'
alias zc='cd $HOME/pro/zazencodes-season-2/src'

# App aliases
alias cat='bat -pp'
alias vue='$HOME/.yarn/bin/vue'
alias httpx='$HOME/go/bin/httpx'
alias sqlj='java -jar /Applications/SQLWorkbenchJ.app/Contents/Java/sqlworkbench.jar </dev/null &>/dev/null &'

# App shortcuts
alias lg=lazygit
alias leet="nvim leetcode.nvim"

# Dir list, nav
alias pwdy="echo $(pwd) | pbcopy"
alias cl="clear"
alias z="cd"
alias lr="ls -lrt"
# alias zr="cd $(ls -td -- $(pwd)/*/ | head -n 1)"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Colors
alias ls="ls -G"


# Zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Only use p10k (terminal runs much faster than with full oh-my-zsh setup)
# I just put it in the ~/.oh-my-zsh folder for legacy reasons
# Install: git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# This file (below) is generated when running p10k config for the first time
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Disabled oh-my-zsh
# plugins=(git colored-man-pages colorize python macos zsh-syntax-highlighting)
# export ZSH="$HOME/.oh-my-zsh"
# source $ZSH/oh-my-zsh.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alex/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alex/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/completion.zsh.inc'; fi

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Legacy - disable in the future
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/alex/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/alex/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/alex/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/alex/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# pipx
export PATH="$PATH:/Users/alex/.local/bin"

# AI
alias llm_deepseek="llm -m deepseek-r1:8b "
alias llm_cat_dir="find . -maxdepth 1 -type f | xargs -I {} sh -c 'echo \"\n=== {} ===\n\"; cat {}'"
