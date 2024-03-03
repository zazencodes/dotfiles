if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Shell config
export LANG=en_US.UTF-8

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

# Enable zoxide
eval "$(zoxide init zsh)"

# Alias to brew's python
# Note: use symlinks, e.g.
# >>> ln -vs /opt/homebrew/bin/python3.9 ~/bin/python
# >>> ln -vs /opt/homebrew/bin/pip3.9 ~/bin/pip
alias python3.12=/opt/homebrew/bin/python3.12
alias pip3.12=/opt/homebrew/bin/pip3.12

# Git
alias gits='git status'
alias gita='git add -u'
gitm() { git commit -m "$1" }
alias gitp='git push'
alias gitq='git add -u && git commit -m "Update" && git push'
alias gitc='aicommits' # requires aicommits installed (https://github.com/Nutlope/aicommits)

# Jupyter
alias jn='jupyter notebook --no-browser'
alias jc='jupyter console'
export JUPYTER_NOTEBOOK_STYLE='from IPython.display import HTML;HTML("<style>div.text_cell_render{font-size:130%;padding-top:50px;padding-bottom:50px}</style>")'
alias jl='jupyter lab --core-mode' # Fix for M1 mac

# Plain text
export EDITOR='mate -w'
nn() { touch ~/Downloads/$1 && mate $1 }

# Obsidian
alias oo='cd /Users/alex/library/Mobile\ Documents/iCloud~md~obsidian/Documents/ZazenCodes'
alias or='vim /Users/alex/library/Mobile\ Documents/iCloud~md~obsidian/Documents/ZazenCodes/inbox/*.md'

# App aliases
alias cat='bat -pp'
alias vue=/Users/alex/.yarn/bin/vue
alias httpx='/Users/alex/go/bin/httpx'
alias sqlj='java -jar /Applications/SQLWorkbenchJ.app/Contents/Java/sqlworkbench.jar </dev/null &>/dev/null &'

# App shortcuts
alias lg=lazygit
alias leet="nvim leetcode.nvim"

# Variables
export JUPYTER_NOTEBOOK_STYLE='from IPython.display import HTML;HTML("<style>div.text_cell_render{font-size:130%;padding-top:50px;padding-bottom:50px}</style>")'

# Zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git colored-man-pages colorize python macos zsh-syntax-highlighting)
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alex/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alex/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/completion.zsh.inc'; fi

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


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


