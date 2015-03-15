echo "loading .profile ..."

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

#where am i running out of?
dotfilesDir="$(dirname "$(readlink -f "$HOME/.profile")")"
dotfilesDir="${dotfilesDir%/symlinked}"
auxDir="$(dirname "$(readlink -f "$HOME/.profile")")/../aux"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes dotfiles bin if it exists
if [ -d "$dotfilesDir/bin" ] ; then
    PATH="$dotfilesDir/bin:$PATH"
fi

export HISTCONTROL=ignoreboth
export LESSHISTFILE=$HOME/.lesshst
export EDITOR=vim

export CVSROOT=":pserver:$USER@cooperstown:/export/home/cvs/cvsroot"

srcIfThere="$HOME/.profile.local" && test -r "$srcIfThere" && source "$srcIfThere" && unset srcIfThere

export PATH

