echo "loading .bashrc ..."

auxDir="$(dirname "$(readlink -f "$HOME/.bashrc")")/../aux"

srcIfThere="$auxDir/shell.helper.sh" && test -r "$srcIfThere" && source $srcIfThere && unset srcIfThere

export PS1="\[\033[36m\]\t \[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] "

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000
#HISTFILESIZE=2000

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

which fortune >/dev/null 2>1 && (echo -e "\033[36mThis moment's fortune:\033[00m" && fortune -a)

srcIfThere="$HOME/.bashrc.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

