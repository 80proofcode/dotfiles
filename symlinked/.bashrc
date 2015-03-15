echo "loading .bashrc ..."

auxDir="$(dirname "$(readlink -f "$HOME/.bashrc")")/../aux"

srcIfThere="$auxDir/shell.helper.sh" && test -r "$srcIfThere" && source $srcIfThere && unset srcIfThere

srcIfThere="$HOME/.bashrc.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

