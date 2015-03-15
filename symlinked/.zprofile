echo "loading .zprofile ..."

srcIfThere="$HOME/.profile" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

export HISTSIZE=100000

srcIfThere="$HOME/.zprofile.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

srcIfThere="$HOME/.zshrc" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere
