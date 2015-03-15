echo "loading .bash_profile ..."

srcIfThere="$HOME/.profile" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

srcIfThere="$HOME/.bash_profile.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

