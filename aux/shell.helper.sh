printf "loading shell.helper.sh ... "

if [ ! -z "$beenHere" ]; then
	printf "skipping\n"
	return
else
	beenHere=true
fi

## Aliases - start

alias view='vi -R'

alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -la'
alias lh='ls -lh'
alias llr='ls -lArth'

alias grep='grep --color=auto'
alias grepi='grep -i'

#typos
alias sl='ls'
alias grpe='grep'
alias pdw='pwd'

alias count='sort | uniq -c | sort -rn'
alias up='(sudo apt-get update ; sudo apt-get upgrade) 2>&1 | tee ~/up/up.log.$(date '+%Y_%m_%d__%H_%M_%S')'
alias inst='sudo apt-get install'
#alias qq='sudo ~/psh.sh restart'
alias psa='ps auxww'

#get the best calendar available
if which ncal &>/dev/null && \ncal -MC &>/dev/null; then
	alias cal='ncal -MC'
elif which cal &>/dev/null && \cal -m &>/dev/null; then
	alias cal='cal -m'
fi
alias c3='cal -3'

alias t='cd /tmp'
alias cd-='cd -'

alias ptree='ps -auxwwwf|less -i'

alias le='less -is'
alias len='less -isN'

alias rl='readlink -f'

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

# shamelessly plagirized from SU
function countdown(){
   date1=$((`date +%s` + $1)); 
   while [ "$date1" -ge `date +%s` ]; do 
     echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
     sleep 0.1
   done
}

function stopwatch(){
  date1=`date +%s`; 
   while true; do 
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r"; 
    sleep 0.1
   done
}

## Functions - end

printf "done\n"
