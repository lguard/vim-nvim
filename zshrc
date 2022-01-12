export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"

plugins=(zsh-autosuggestions git autojump fzf vagrant sudo timer)
source $ZSH/oh-my-zsh.sh
source /etc/zsh_command_not_found

export EDITOR='nvim'
unalias g
alias re="readlink -e"
alias vim="vim_func"
alias v="vim_func"
alias vimdiff="nvim -d"
alias ff="\$HOME/\`cd \$HOME ;~/.fzf/bin/fzf --height=35 --prompt='~/'\`"
alias vz="nvim $HOME/.zshrc"
alias bc="bc -q"
alias reset="stty sane"
alias woof="echo "http://$(ip route get 1.1.1.1 | grep -oP 'src \K\S+'):8080" | qrencode -t ansiutf8 & woof"

function vim_func() {
    echo $@ | sed -r "s/:([0-9]+)/ +\1/g" | xargs sh -c 'nvim "$@" < /dev/tty' nvim
}

if [[ -x $(command -v setxkbmap ) ]] ;then setxkbmap  -option caps:escape ; fi

if [[ ! -z $SSH_CONNECTION ]];then
 SSH_IP=$(echo $SSH_CONNECTION | cut -d\  -f3)
 PS1="[%{$fg[red]%}$SSH_IP%{$reset_color%}] $PS1"
fi

alias s="customSsh"

customSsh () {
    ssh -t $1 'bash  --rcfile <(cat ~/.bashrc \
        && echo "PS1=\"[$(echo $SSH_CONNECTION | cut -d\  -f3)] \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \""\
        && echo "bind '  "'\\\"\\e[A\\\": history-search-backward'"'" \
        && echo "bind '  "'\\\"\\e[B\\\": history-search-forward'"'" \
        && echo "bind '  "'set completion-ignore-case on'"'" \
        ) \
        -i'
}


export FZF_DEFAULT_OPTS="--height=35 --inline-info -m --history=\"$HOME/.local/share/fzf-history\" --bind=ctrl-x:toggle-sort,ctrl-h:previous-history,ctrl-l:next-history,ctrl-f:jump-accept,alt-j:preview-down,alt-k:preview-up --cycle"
export PATH=$HOME/.fzf/bin:$HOME/.local/bin:$PATH

swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

gcdev () {
    local h
    local dir
    local rd
    local cl
    [ $# -eq 1 ] && dir=$1  || dir=. 
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d) 
        if [ -d "$rd/.git" ]
        then
            branch="$(git --git-dir=$rd/.git --work-tree=$rd checkout devlop)" 
            printf "%s\n" "$branch"
        fi
    done
}

gitinfo () {
    local branch
    local h
    local dir
    local rd
    [ $# -eq 1 ] && dir=$1  || dir=. 
    printf "%s                                    : %s %s (%s) \x1b[33m%s\x1b[0m, \x1b[32m%s\x1b[0m, \x1b[31m%s\x1b[0m\n\n" "repo" "branch" "        " " hash " "  M" "  +" "  -"
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d) 
        if [ -d "$rd/.git" ]
        then
            branch="$(git --git-dir=$rd/.git --work-tree=$rd branch | grep \* | cut -d\  -f2-)" 
            h=$(echo $branch | md5sum | cut -d\  -f1 | head -c 2) 
            h=$(( 40 + (16#$h % 80) * 2 )) 
            changed="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) files? changed.' | grep -Eo '[0-9]+')" 
            added="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) insertion' | grep -Eo '[0-9]+')" 
            deleted="$(git --git-dir=$rd/.git --work-tree=$rd diff --shortstat | grep -Eo '([0-9]+) deletion' | grep -Eo '[0-9]+')" 
            printf "%-40s: \x1b[38;5;%dm%-30s\x1b[0m%s (%.6s) \x1b[33m%3d\x1b[0m, \x1b[32m%3d\x1b[0m, \x1b[31m%3d\x1b[0m\n" "$(basename $rd)" "$h" "$branch" " " "$(git --git-dir=$rd/.git rev-parse HEAD)" "$changed" "$added" "$deleted"
        fi
    done
}

colorize() {
    word=$(cat)
    h=$(echo $word | md5sum | head -c 2)
    h=$(( 40 + (16#$h % 80) * 2))
    printf "\x1b[38;5;%dm%s\x1b[0m" "$h" "$word"
}

colorize2() {
    h=$(echo $1 | md5sum | head -c 2)
    h=$(( 40 + (16#$h % 80) * 2))
    printf "\x1b[38;5;%dm%s\x1b[0m" "$h" "$1"
}

#fetch
gfall () {
    local h
    local dir
    local rd
    local cl
    [ $# -eq 1 ] && dir=$1  || dir=. 
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d) 
        if [ -d "$rd/.git" ]
        then
            cl=$(echo $(basename $rd) | md5sum | cut -d\  -f1 | head -c 2) 
            cl=$(( 40 + (16#$cl % 80) * 2 )) 
            printf "\x1b[38;5;%dm%s\x1b[0m\n" "$cl" "$(basename $rd)"
            h="$(git --git-dir=$rd/.git --work-tree=$rd fetch --all)"
            printf "\x1b[33m%s\x1b[0m\n" "$h"
            printf "=============\n"
        fi
    done
}

#compare distant and local branch
grpall () {
    local head
    local dist
    local dir
    local rd
    local ha
    local cl
    [ $# -eq 1 ] && dir=$1  || dir=. 
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d) 
        if [ -d "$rd/.git" ]
        then
            ha="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse --abbrev-ref HEAD)"
            cl=$(echo $ha | md5sum | cut -d\  -f1 | head -c 2) 
            cl=$(( 40 + (16#$cl % 80) * 2 )) 
            printf "%-30s \x1b[38;5;%dm%-20s\x1b[0m" "$(basename $rd)" "$cl" "$ha"
            head="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse --short $ha)"
            if [ $(git --git-dir=$rd/.git --work-tree=$rd branch --all | grep "remotes/origin/$ha") ] ;then
                dist="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse --short origin/$ha)"
                if [ "$head" = "$dist" ]; then
                    printf "Up to date %13s\n" "- $head"
                else
                    printf "\x1b[31mNOPE       \x1b[0m- \x1b[32m%s \x1b[31m%s\x1b[0m\n" "$dist" "$head"
                fi
            else
                printf "No Dist Branch - %s\n" "$head"
            fi
        fi
    done
}

#compare root branch
gddall () {
    local root
    local last
    local dir
    local rd
    local ha
    [ $# -eq 1 ] && dir=$1  || dir=. 
    for d in $dir/*(/)
    do
        rd=$(readlink -f $d) 
        if [ -d "$rd/.git" ]; then
            ha="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse --abbrev-ref HEAD)"
            cl=$(echo $ha | md5sum | cut -d\  -f1 | head -c 2) 
            cl=$(( 40 + (16#$cl % 80) * 2 )) 
            printf "%-30s \x1b[38;5;%dm%-20s\x1b[0m" "$(basename $rd)" "$cl" "$ha"
            exists="$(git --git-dir=$rd/.git --work-tree=$rd show-ref refs/heads/develop)"
            if [ -n "$exists" ]; then
                root="$(git --git-dir=$rd/.git --work-tree=$rd merge-base origin/develop $ha)"
                last="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse origin/develop)"
                if [ "$root" = "$last" ]; then
                    printf "\x1b[32m OK\x1b[0m\n"
                else
                    printf "\x1b[31m Rebase from develop\x1b[0m\n"
                fi
            else
                root="$(git --git-dir=$rd/.git --work-tree=$rd merge-base origin/master $ha)"
                last="$(git --git-dir=$rd/.git --work-tree=$rd rev-parse origin/master)"
                if [ "$root" = "$last" ]; then
                    printf "\x1b[32m OK\x1b[0m\n"
                else
                    printf "\x1b[31m Rebase from master\x1b[0m\n"
                fi
            fi
        fi
    done
}

gmb () {
if [ "$#" -eq 2 ];then
    local revHead
    local l1
    local l2
    local len1
    local len2
    local mb1
    local mb2
    local mb1s
    local mb2s
    local hash1
    local hash2

    l1=$(git rev-list $1)
    l2=$(git rev-list $2)

    len1=$(echo $l1 | wc -l)
    len2=$(echo $l2 | wc -l)


    mergeBase=$(git merge-base $1 $2)
    i=0
    git rev-list $1 | 
    while read CMD; do
        if [ $CMD = $mergeBase ];then
            mb1=$i
        fi
        i=$(($i + 1))
    done
    i=0
    git rev-list $2 | 
    while read CMD; do
        if [ $CMD = $mergeBase ];then
            mb2=$i
        fi
        i=$(($i + 1))
    done
    mb1s=$mb1
    mb2s=$mb2
    if [ $mb1 -gt $mb2 ];then
        mb2=$(($mb2 - $mb1))
        mb1=$(($mb1 - $mb1))
    else
        mb1=$(($mb1 - $mb2))
        mb2=$(($mb2 - $mb2))
    fi
    i=0
    while :
    do
        hash1="                                        ";hash2="                                        "
        if [ $mb1 -ge 0 ];then 
            hash1=$(echo -n $(echo $l1 | sed -n $(echo $(($mb1 + 1)))p))
            #echo -n $hash1
        fi
        if [ $mb2 -ge 0 ];then 
            hash2=$(echo -n $(echo $l2 | sed -n $(echo $(($mb2 + 1)))p))
            #echo -n $hash2
        fi
        if [ $hash1 = $hash2 ];then; printf "\x1b[32m%s = %s\x1b[0m\n" "$hash1" "$hash2"
        else printf "\x1b[33m%s ~ %s\x1b[0m\n" "$hash1" "$hash2";fi
        mb1=$(($mb1 + 1)); mb2=$(($mb2 + 1))
        if [ $mb1 -gt $len1 ] && [ $mb2 -gt $len2 ];then; break; fi
    done
fi
}
#tibi stuff
function up-line-or-search-prefix () # smart up search (search in history anything matching before the cursor)
{
    local CURSOR_before_search=$CURSOR
    zle up-line-or-search "$LBUFFER"
    CURSOR=$CURSOR_before_search
}; zle -N up-line-or-search-prefix

function down-line-or-search-prefix () # same with down
{
    local CURSOR_before_search=$CURSOR
    zle down-line-or-search "$LBUFFER"
    CURSOR=$CURSOR_before_search
}; zle -N down-line-or-search-prefix

function c()                    # simple calculator
{
    echo $(($@));
}

function d2h()                  # decimal to hexa
{
    echo $(( [#16]$1 ));
}

function h2d()                  # hexa to decimal
{
    echo $(( 16#$1 ));
}

function d2b()                  # decimal to binary
{
    echo $(( [#2]$1 ));
}

function b2d()                  # binary to decimal
{
    echo $(( 2#$1 ));
}

function h2b()                  # hexa to binary
{
    echo $(( [#2]16#$1 ));
}

function b2h()                  # binary to hexa
{
    for i in $@;do
        echo $(( [#16]2#$i ));
    done
}

function h2o(){
  echo "ibase=16\nobase=8\n$1" | bc
}

function winshared()
{
    sudo mount -t vboxsf linux ~/shared
}

function cdf() {
   local file
   local dir
   file=$(fzf -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

function cif() {
    local dir
    dir=$(
        find ${1:-$HOME} d -print 2> /dev/null |
        fzf -1 --preview="ls -l --color=always  {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    ) && cd "$dir"
}

function cf() {
    local dir
    dir=$(
        find ${2:-$HOME} \( ! -regex '.*/\..*' \) -type d -print 2> /dev/null |
        fzf -1 --preview="ls -l --color=always  {-1}" --header-lines=1 --ansi --prompt="${2:-$HOME}" -q "${1:-}"
    ) && cd "$dir"
}

function vif() {
    local dir
    dir=$(
        find ${1:-$HOME} -type f -print 2> /dev/null |
        fzf -1 --preview="cat {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    )
    if [ -n "$dir" ]; then
        local cmd="nvim -O "$(echo "$dir" | sed ':a;N;$!ba;s/\n/ /g')
        print -s "$cmd"
        eval $cmd
    fi
}


function lf() {
    local dir
    dir=$(
        find ${1:-$HOME} -type d -print 2> /dev/null |
        fzf -1 --preview="ls -l --color=always  {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    ) && ls -l "$dir"
}

function caf() {
    local dir
    dir=$(
        find ${1:-$HOME} -type f -print 2> /dev/null |
        fzf -1 --preview="cat {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    ) && cat "$dir"
}

function astash() {
	stash=$(git --no-pager stash list | fzf --preview "git --no-pager stash show -p --color \$(echo {} | cut -d: -f1)");
	if [ "$stash" != "" ];then
		if read -q "?Do you realy want to apply: $stash
y/n ?";then
			git stash apply "$(echo $stash | cut -d: -f1)";
		fi;
	fi
}

# fbr - checkout git branch
function fbr() {
  local branches branch
  branches=$(git branch --all -vv --color=always) &&
  branch=$(echo "$branches" | fzf --ansi --reverse --height=20 +m) &&
  if [ "$1" = "-f" ]; then
      git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //") --force
  else
      git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
  fi
}

function vf() {
    local dir
    dir=$(
        find ${2:-./} \( ! -regex '.*/\..*' \) -type f -print 2> /dev/null |
        fzf -1 --preview="cat {-1}" --header-lines=1 --ansi --prompt="${2:-$HOME}" -q "${1:-}"
    )
    if [ -n "$dir" ]; then
        local cmd="nvim -O "$(echo "$dir" | sed ':a;N;$!ba;s/\n/ /g')
        print -s "$cmd"
        eval $cmd
    fi
}


function lf() {
    local dir
    dir=$(
        find ${1:-$HOME} -type d -print 2> /dev/null |
        fzf -1 --preview="ls -l --color=always  {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    ) && ls -l "$dir"
}

function caf() {
    local dir
    dir=$(
        find ${1:-$HOME} -type f -print 2> /dev/null |
        fzf -1 --preview="cat {-1}" --header-lines=1 --ansi --prompt="${1:-$HOME}"
    ) && cat "$dir"
}

function astash() {
	stash=$(git --no-pager stash list | fzf --preview "git --no-pager stash show -p --color \$(echo {} | cut -d: -f1)");
	if [ "$stash" != "" ];then
		if read -q "?Do you realy want to apply: $stash
y/n ?";then
			git stash apply "$(echo $stash | cut -d: -f1)";
		fi;
	fi
}

# fbr - checkout git branch
function fbr() {
  local branches branch
  branches=$(git branch --all -vv --color=always) &&
  branch=$(echo "$branches" | fzf --ansi --reverse --height=20 +m) &&
  if [ "$1" = "-f" ]; then
      git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //") --force
  else
      git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
  fi
}

# fshow - git commit browser
function fshowa() {
  git log --all --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --no-mouse --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {} FZF-EOF"
}

# fshow - git commit browser
function fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --no-mouse --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {} FZF-EOF"
}

# fshow - git commit browser
function gv() {
    gerp "$@" |
        fzf --no-mouse --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:reload(rg --vimgrep --color=always -S -M $(tput cols) -g '!.git/' -- '$@')" --bind 'ctrl-m:execute:
            echo {} | sed -e "s/\x1b\[.\{1,5\}m//g"| perl -ne '"'/(.*?):(\d+)/ && exec \"nvim\", \"\$1\", \"+\$2\"'"
}

function vg() {
	if [[ $# -ge 1 ]];then
		VAR=$(find ${2:-./} -type f -exec grep -i --color=always -nH $1 {} + | fzf --ansi --preview="LINR=\$(echo {} | cut -d: -f2);MINLIN=\$(echo \"\$LINR - 4\" | bc);MAXLIN=\$(echo \"\$LINR + 4\" | bc);if [[ \$MINLIN < 1 ]];then MINLIN=1;fi;sed -n \"\$MINLIN,\${MAXLIN}p\" < \$(echo {} | cut -d: -f1) | awk '{ if (NR == 5) print \"\\x1b[44m\"\$0\"\\x1b[0m\"; else print \$0}'");
		if [[ $VAR != "" ]];then
			LINR=$(echo $VAR | cut -d: -f2);
			MINLIN=$(echo "$LINR - 4" | bc);
			MAXLIN=$(echo "$LINR + 4" | bc);
			if [[ $MINLIN < 1 ]];then
			MINLIN=1;
			fi
			FILE=$(echo $VAR | cut -d: -f1)
			nvim $FILE +$LINR
		fi
	fi
}

function vd() {
    nvim -p $(git status --short | grep " M "| cut -d\  -f3)
}

function gob() {
    if [[ $(git rev-parse --abbrev-ref HEAD) == "develop" ]];then
       firefox "https://opsise.atlassian.net/issues/?filter=-1"
    elif [[ $(git rev-parse --abbrev-ref HEAD) == "master" ]];then
       firefox "https://opsise.atlassian.net/issues/?filter=-1"
    else
       firefox "https://opsise.atlassian.net/browse/$(git rev-parse --abbrev-ref HEAD | cut -d\/ -f 2)?filter=-1"
    fi
}

function randpers() {
    VAR=$(echo $(($(echo $(( 16#$(sha1sum  <(head -c 10 /dev/urandom)  | cut -d\  -f1 | head -c 5) ))) % $#)))

    i=0
    for name in "$@"
    do
        if [[ $i == $VAR ]];then
            echo "$name"
        fi
        let i=i+1
    done
}

function gerp() {
    if [[ $# -lt 1 ]];then
        echo "Usage: gerp [to_search] [optional:path]"
        return 1
    fi
    DEFAULT="--color=always"
    while getopts "h:l" arg; do
        case $arg in
            h)
                echo "Usage: gerp [to_search] [optional:path]"
                return 0
                ;;
            l)
                DEFAULT="-l"
                ;;
        esac
    done
    if [[ -x $(command -v rg ) ]] ;then
            rg --vimgrep "$DEFAULT" -S -M $(tput cols) -g "!.git/"-- $1 ${2:-./}
    else
        str="$(echo -n $1 | grep -o '[A-Z]')"
        if [[ $str == "" ]];then
            find ${2:-./} -type f -not -path "./git/*" -exec grep -i --line-number "$DEFAULT" -nH $1 {} +
        else
            find ${2:-./} -type f -not -path "./git/*" -exec grep --line-number "$DEFAULT" -nH $1 {} +
        fi
    fi
}

function g() {
    gerp "$*"
}

function ctrlz()
{
	if [[ $#BUFFER -ne 0 ]]; then
		zle push-input
	fi
	BUFFER=fg
	zle accept-line
}; zle -N ctrlz
function race()					# race between tokens given in parameters
{
	cat /dev/urandom | tr -dc "0-9A-Za-z" | command egrep --line-buffered -ao "$(echo $@ | sed "s/[^A-Za-z0-9]/\|/g")" | nl
}

function work()					# work simulation
{
	clear;
	text="$(cat $(find ~ -type f -name "*.cpp" 2>/dev/null | head -n25) | sed ':a;$!N;$!ba;s/\/\*[^​*]*\*\([^/*​][^*]*\*\|\*\)*\///g')"
	arr=($(echo $text))
	i=0
	cat /dev/zero | head -c $COLUMNS | tr '\0' '='
	while true
	do
		read -sk;
		echo -n ${text[$i]};
		i=$(( i + 1 ))
	done
	echo
}

function hi()
{
    read foo
    echo $foo | sed -r "s/($1)/\x1b[31;1m\1\x1b[0m/g" 
}

function ma()
{
    var=$(find . -maxdepth 1 -type d | grep build)
    if [[ $var == "./build" ]];then
        make -C build
    else
        make
    fi
}

function mad()
{
    var=$(find . -maxdepth 1 -type d | grep build)
    if [[ $var == "./build" ]];then
        make -C build distclean
    else
        make distclean
    fi
}

function mai()
{
    var=$(find . -maxdepth 1 -type d | grep build)
    if [[ $var == "./build" ]];then
        make -C build install
    else
        make install
    fi
}

git_prompt_info () {
	local ref
	if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]
	then
		ref=$(command git symbolic-ref HEAD 2> /dev/null)  || ref=$(command git describe --tags HEAD 2> /dev/null)|| ref=$(command git rev-parse --short HEAD 2> /dev/null)  || return 0
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history

unsetopt listambiguous
bindkey "^Z" ctrlz
bindkey "^[[1;5A" up-line-or-search-prefix
bindkey "^[[1;5B" down-line-or-search-prefix
bindkey "^K" up-line-or-search-prefix
bindkey "^J" down-line-or-search-prefix
bindkey -M menuselect '^H' vi-backward-char
bindkey -M menuselect '^K' vi-up-line-or-history
bindkey -M menuselect '^L' vi-forward-char
bindkey -M menuselect '^J' vi-down-line-or-history

alias zz="source $HOME/.zshrc"

typeset -ga precmd_functions
rehash-last-install() { fc -l -1 |grep -q install && { echo "rehash-ing"; rehash } }
precmd_functions+=rehash-last-install

#0 -- vanilla completion (abc => abc)
#1 -- smart case completion (abc => Abc)
#2 -- word flex completion (abc => A-big-Car)
#3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

#zstyle ':completion:*' completer _complete
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
#autoload -Uz compinit
#compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/bin/xcape ] && xcape -e 'Shift_L=Escape;Control_L=Control_L|O'
if [ -e /home/leo/.nix-profile/etc/profile.d/nix.sh ]; then . /home/leo/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
