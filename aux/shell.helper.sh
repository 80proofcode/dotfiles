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
   [ -z "$1" ] && echo "usage: countdown <seconds>" && return
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

function weather()
{
	if [ "$*" = "-h" ]; then
		echo "usage: $0 [options] [location zip or name, defaults to location-by-IP]"
		echo "options are: n[arrow], w[ide], 1,2,or3 [days worth], C, F, h[ttp-only], d[ebug]"
		return
	fi

	# http://wttr.in/:help
	which curl >/dev/null 2>&1 || { echo "Weather Error: no CURL found" && return; }

	# starting default values
	local url_domain="www.wttr.in"
	local width=""
	local days="0"
	local units="u"
	local location=""
	local url_protocol="https"
	local print_debug="false"
	
	# adjust width to terminal size
	[ "$COLUMNS" -lt 125 ] && width="n"

	# because apparently you need to change the damn index manually for multiple executions
	OPTIND=1
	while getopts 'nw123CFhd' weather_option; do
		case "$weather_option" in
			n) width="n";; # narrow
			w) width="";; # wide
			[123]) days="$weather_option";;
			C) units="m";; # metric
			F) units="u";; # uscs
			h) url_protocol="http";;
			d) print_debug="true";;
		esac
	done
	shift "$(($OPTIND-1))"

	location="$*"
	echo "$location" | tr '[A-Z]' '[a-z]' | grep -iq "home\|ohm\|bk\|brooklyn" 
	[ $? -eq 0 ] && location="Brooklyn, NY"
	[ ! -z "$location" ] && location="~$location"
	
	# construct the URL
	local url_final="$url_protocol://$url_domain/$location?F$width$days$units"

	if [ "$print_debug" = "true" ]; then
		echo "Debug info: width=[$width] days=[$days] units=[$units] location=[$location]"
		echo "Debug info: url=[$url_final]"
	fi
	
	# --compressed
	curl "$url_final"
}

function trail()
{
	SECS_TO_WAIT=5
	local target f
	f="$1"
	[ ! -r $f ] && echo "no such file: $f" && return
	{ [ $2 -gt 0 ] 2>/dev/null && target=$2 } || echo "[$2] not acceptable numeric target, ignoring"
	s0=0
	av_size=10
	av_array=()
	while sleep 1; do
		s=$(wc -l $f | cut -d\  -f1)
		rate=$(($s-$s0))
		#if starting at zero, rate it at zero
		[[ $s0 -eq 0 ]] && rate=0
		if [[ $s0 -eq $s && s0 -ge 0 ]]; then
			if [[ $((SECS_TO_WAIT--)) -le 0 ]]; then
				return
			fi
		fi
		printf "$(basename $f) line count: %s, rate: %s/sec" "$s" "$rate"
		if [[ $rate -ne 0 && ! -z $target && $target -ge $s ]]; then
			eta="$((($target-$s)/$rate))"
			printf ", eta: %02d:%02d" "$(($eta/60))" "$(($eta%60))"
			# and now the running average ...
			av_array=("$s" "${av_array[@]}")
			av_array=("${av_array[@]:0:${av_size}}")
			if [[ "${#av_array[@]}" -ge $av_size ]]; then
#				echo "${av_array[@]}"
#				echo "${av_array[1]}-${av_array[${av_size}]} / $av_size"
				rate10sec=$(( (${av_array[1]}-${av_array[${av_size}]}) / ($av_size-1) ))
				eta10sec="$((($target-$s)/$rate10sec))"
				printf ", eta%ssec: %02d:%02d" "$av_size" "$(($eta10sec/60))" "$(($eta10sec%60))"
			fi
		fi
		#printf "\n"
		echo -ne "\033[K\r"
		s0=$s
	done
}

function cheat()
{
	if [ -z "$*" -o "$*" = "-h" ]; then
		echo "usage: $0 <command>"
		echo "usage: $0 <language> <command>"
		echo "usage: $0 {list|learn} <command>"
		return
	fi

	which curl > /dev/null 2>&1
	[ $? -ne 0 ] && echo "curl not found!" && return

	local HOSTNAME="https://cheat.sh"
	local QUERY_STRING=""
	local QUERY_ARGS="?Q"
	QUERY_ARGS=""

	# just a command by itself
	if [ "$#" -eq 1 ]; then
		QUERY_STRING="$1"
	# learning or listing for a given command
	elif [ "$1" = "learn" -o "$1" = "list" ]; then
		local action="$1"
		shift
		QUERY_STRING="$1"
		QUERY_ARGS=":$action"
	# command for a given language
	else
		local language="$1"
		shift
		local command_string="$*"
#		command_string=$(echo "$command_string"|sed 's/\s+/+/g')
		QUERY_STRING="$language/$command_string"
	fi

	echo using following URL: \"$HOSTNAME/${QUERY_STRING}/${QUERY_ARGS}\"
	curl "$HOSTNAME/${QUERY_STRING}/${QUERY_ARGS}"
}

## Functions - end

printf "done\n"
