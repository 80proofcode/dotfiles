echo "loading .bashrc ..."

auxDir="$(dirname "$(readlink -f "$HOME/.bashrc")")/../aux"

srcIfThere="$auxDir/shell.helper.sh" && test -r "$srcIfThere" && source $srcIfThere && unset srcIfThere

export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] "

srcIfThere="$HOME/.bashrc.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

