echo "loading .zprofile ..."

srcIfThere="$HOME/.profile" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

srcIfThere="$HOME/.zprofile.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere
