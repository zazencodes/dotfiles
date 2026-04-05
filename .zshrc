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
export PATH="$PATH:/opt/homebrew/bin:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH" # postgres version 16
export PATH="/Users/alex/.antigravity/antigravity/bin:$PATH"
export PATH=/Users/alex/.opencode/bin:$PATH
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
export FZF_CTRL_T_OPTS="--height 40% --no-scrollbar"
export FZF_CTRL_T_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_R_OPTS="--height=40% --reverse --no-scrollbar"

# Map Command+R (emitted by Alacritty as custom sequence) to classic history search
# This is for situations where you don't want to reveal terminal history (screen sharing)
# - Press Cmd+R repeatedly to keep searching BACKWARDS
# - Press Cmd+S repeatedly to keep searching FORWARDS (find newer queries if you went too far)
bindkey '\e[CmdR~' history-incremental-search-backward
bindkey '\e[CmdS~' history-incremental-search-forward

# cd widget using fd, ignore git and sort folders by depth (will fail for really large dirs, e.g. ~/)
# export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git . | awk -F'/' '{print NF-1, \$0}' | sort -n | cut -d' ' -f2-"
# Use cd widget with Ctrl+O (default is Alt+C)
bindkey '^G' fzf-cd-widget

# **<tab> using fd, ignore git and sort folders by depth (will fail for really large dirs, e.g. ~/)
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1" | awk -F'/' '{print NF-1, $0}' | sort -n | cut -d' ' -f2-
}


# eza
export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:oc=0:xa=0:uu=0:uR=0:un=0:gu=0:gR=0:gn=0:lc=0:lm=0:sn=0:nb=0:nk=0:nm=0:ng=0:nt=0"
alias ls="eza -1 --icons=always"
alias lr="eza --long --icons=always --sort=newest"
alias lt="eza -1 --icons=always -T"
alias ltt="eza -1 --icons=always -T -L=2"
alias lttt="eza -1 --icons=always -T -L=3"

# Tmux
alias t=tmux
# Alt-d (ESC d) delete forward word
bindkey -M viins '^[d' kill-word


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
alias cd_obsidian_cloud="cd '/Users/alex/Library/Mobile Documents/iCloud~md~obsidian/Documents'"

# Path shortcuts
alias nvc='cd $HOME/.config/nvim && vim'
alias zc='cd $HOME/pro/zazencodes-season-2/src'
alias cmcp='vim $HOME/Library/Application\ Support/Claude/claude_desktop_config.json'
alias gmcp='vim $HOME/.gemini/settings.json'
alias devlogs='vim $HOME/pro/devlogs'

# App aliases
alias cat='bat -pp'
# alias vue='$HOME/.yarn/bin/vue'
# alias httpx='$HOME/go/bin/httpx'
# alias sqlj='java -jar /Applications/SQLWorkbenchJ.app/Contents/Java/sqlworkbench.jar </dev/null &>/dev/null &'

# App shortcuts
alias lg=lazygit
# alias leet="nvim leetcode.nvim"

# Ollama
alias llm_gs="llm -m gemma3:4b "
alias llm_gm="llm -m gemma3:12b "
alias llm_gl="llm -m gemma3:27b "

# Local LLM tools
alias llm_cat_dir="find . -maxdepth 1 -type f | xargs -I {} sh -c 'echo \"\n=== {} ===\n\"; cat {}'"
# alias zc2git="mcphost --system-prompt ~/pro/zazencodes-season-2/src/mcphub/zc_season_2_git.json -m anthropic:claude-sonnet-4-0"
# alias fgemini="export GEMINI_MODEL='gemini-2.5-flash' && gemini"
alias a="aichat -e"
alias claude-zazencodes='CLAUDE_CONFIG_DIR="$HOME/.claude-zazencodes" claude'

# Dir list, nav
alias cl="clear"
alias z="cd"
# alias lr="ls -lrt"
# alias zr="cd $(ls -td -- $(pwd)/*/ | head -n 1)"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# cd to latest dir
zr() {
  # (*(/om[1]) → *    : all names
  #              /    : only directories
  #              o    : order by oldest first
  #              m    : use modification time
  #              [1]  : pick the 1st (i.e. newest) )
  local target
  target=(*(/om[1]))

  if [[ -d $target ]]; then
    cd -- "$target"
  else
    echo "cdr: no subdirectories found" >&2
    return 1
  fi
}


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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/alex/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/alex/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/alex/google-cloud-sdk/completion.zsh.inc'; fi

# Added by Windsurf
# export PATH="/Users/alex/.codeium/windsurf/bin:$PATH"

# Scripts
alias ayima_search_volumes="$HOME/virtualenvs/adhoc/bin/python $HOME/apro/ad-hoc-python-scripts/semrush-api/keyword-overview/get_keyword_overview.py"

# Workflow shortcuts
aura-sync() {
  cd /Users/alex/apro/aura
  echo "==> Local: pushing changes"
  git push || true
  echo "==> Remote: git pull on aura"
  ssh aura 'cd /root/aura && git pull'
}

