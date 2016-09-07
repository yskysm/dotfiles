### Set Language to English
LANG=en_US.UTF-8
#LANG=ja_JP.UTF-8

### Launch tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux

### Prompt Settings
autoload -U colors
colors

PS1=$'%{\e[0;38;5;075m%}%B%n%{\e[m%}@air%b%# '
#RPS1='[%~]'
RPS1="[%~][%{$fg[yellow]%}%T%{$reset_color%}]"
SPROMPT="%{$fg[red]%}correct: %R -> %r [nyae]? %{$reset_color%}"

# git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPS1=$RPS1'${vcs_info_msg_0_}'


### Alias
alias gcc='gcc -g -O0 -Wall'
alias ls='ls -FG'
alias ll='ls -l'
alias la='ls -A'
alias grep='grep --with-filename --line-number --color=always'
alias egrep='egrep --with-filename --line-number --color=always'
alias fgrep='fgrep --with-filename --line-number --color=always'
alias dirs='dirs -v'
alias ipython='ipython2-2.7'
alias memo='emacs ~/Dropbox/Memo.txt'
alias dl='cd ~/Downloads'
alias ds='cd ~/Desktop'

### Completion
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
eval $(gdircolors)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
setopt LIST_ROWS_FIRST

### History
SAVEHIST=100000000000000
HISTSIZE=100000000000000
HISTFILE=~/.zhistory
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_NO_STORE

### Setopt
setopt IGNORE_EOF
setopt NO_CLOBBER
setopt EXTENDED_GLOB
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt NOHUP

### Trash
del (){mv $* ~/.Trash/}
alias rm='del'
alias emptytrash='/bin/rm -rf ~/.Trash/*'

### Bindkey
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

### WORDCHARS
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

### man coloring
export MANPAGER='less -R'
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        man "$@"
}

### less coloring
export LESS='-RNIMSx4'
export LESSOPEN='| lessfilter %s'

### ffmp4-speedup
ffmp4-speedup-filter () {
  readonly local speed=$1
  local v="[0:v]setpts=PTS/${speed}[v]"
  if [ $speed -le 2 ]; then
    local a="[0:a]atempo=${speed}[a]"
  elif [ $speed -le 4 ]; then
    local a="[0:a]atempo=2,atempo=$speed/2[a]"
  elif [ $speed -le 8 ]; then
    local a="[0:a]atempo=2,atempo=2,atempo=$speed/4[a]"
  fi
  noglob echo -filter_complex "$v;$a" -map [v] -map [a]
}

ffmp4-speedup () {
  if [ $# -lt 2 ]; then
    echo "Usage: $0 file speed"
    echo "Convert movie(file) to nx playback mp4 file."
    echo "(ex.) $0 input.mov 2"
    echo "      will generate 2x playback mp4 file (input_x2.mp4)"
    return
  fi
  red=`tput setaf 1; tput bold`
  green=`tput setaf 2; tput bold`
  reset=`tput sgr0`
  readonly local src=$1
  readonly local speed=$2
  dst=${src:r}_x${speed}.mp4
  readonly local config="-crf 23 -c:a aac -ar 44100 -b:a 64k -c:v libx264 -qcomp 0.9 -preset slow -tune film -threads auto -strict -2"
  readonly local args="-v 0 -i $src $config $(ffmp4-speedup-filter $speed) $dst"
  echo -n "Converting $src to ${speed}x playback as $dst ... "
  ffmpeg `echo $args`
  if [[ $? = 0 ]]; then
    echo "${green}OK${reset}"
  else
    echo "${red}Failed${reset}"
  fi
}

### open in new window when ssh
ssh_tmux() {
    ssh_cmd="ssh $@"
    tmux new-window -n "$*" "$ssh_cmd"
}

if [ $TERM = "screen" ] ; then
    tmux lsw > /dev/null
    if [ $? -eq 0 ] ; then
        alias ssh=ssh_tmux
    fi
fi

### tmux Window name setting
HOSTNAME='air'  # only for MacBook Air
mypath=${PWD:t}
echo -ne "\ek$HOSTNAME:$mypath\e\\"

chpwd() {
    mypath=${PWD:t}
    echo -ne "\ek$HOSTNAME:$mypath\e\\"
}