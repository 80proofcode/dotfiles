echo "loading shell.helper.sh ..."

if [ ! -z "$beenHere" ]; then
	return
else
	beenHere=true
fi

## Aliases - start

alias view='vi -R'
alias ls='ls --color=auto'
alias sl='ls'
alias grep='grep --color=auto'
alias grepi='grep -i'
alias count='sort | uniq -c | sort -rn'
alias up='(sudo apt-get update ; sudo apt-get upgrade) 2>&1 | tee ~/up/up.log.$(date '+%Y_%m_%d__%H_%M_%S')'
alias inst='sudo apt-get install'
#alias qq='sudo ~/psh.sh restart'
alias cd-='cd -'
alias psa='ps auxww'
alias ncal='ncal -M'
alias t='cd /tmp'

#safety
alias rm='rm -i'

## Aliases - end

## Environment variables - start



## Environment variables - end

## Functions - start

function llt()
{
	inn="$1"
	ls -lArth $inn | tail
}

# open MAN pages as PDFs
# thanks reddit! http://www.reddit.com/r/linux/comments/27buyv/i_just_leaned_about_man_html/
pdfman()
{
    which evince > /dev/null 2>&1
    test $? -ne 0  && echo "not evince, no pdfman for you!" && return
    # Securely choose a tempfile name
    TMPFILE=$(mktemp evince-$USER.XXXXXXX --tmpdir)
    # Create the temp pdf 
    man -t "$1" | ps2pdf - "$TMPFILE"
    # Open with your choice of pdf viewer
    evince "$TMPFILE"
    # Remove the file in 2 seconds without locking up the terminal
    bash -c "sleep 2; rm $TMPFILE" &
}

## Functions - end
