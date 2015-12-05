#!/usr/bin/env bash

dotfilesDir="$(readlink -f $(dirname $0))"

syms="${dotfilesDir}/symlinked"

declare -a fns
declare -a ffns

co_off="\033[0m"
co_red="\033[1;31m"
co_yellow="\033[1;33m"
co_green="\033[1;32m"
co_blue="\033[1;34m"

ffns=($(find ${syms} -type f -exec echo '{}' \;))
for f in "${ffns[@]}"; do
	fns=("${fns[@]}" "${f#${syms}/}")
done

function usage
{
	echo "$0 {status|install|uninstall|update}" 
	exit 1
}

function header()
{
	echo "===/"
	echo "==> $@"
	echo "===\\"
}

function getLinkedTo()
{
	if [ $# -ne 1 ]; then
		echo ""
	elif [ ! -L "$1" ]; then
		echo ""
	else
		echo "$(readlink -f "$1")"
	fi	
}

function log()
{
	echo -e "${co_blue}meh${co_off}: $@"
	#echo -e "meh : $@"
}
function good()
{
	echo -e "${co_green}great news everyone!${co_off}: $@"
	#echo -e ">great news everyone< : $@"
}
function warn()
{
	echo -e "${co_yellow}ummm${co_off}, be aware: $@"
	#echo -e ">>>ummm<<< be aware: $@"
}
function bad()
{
	echo -e "${co_red}nope${co_off}, because: $@"
	#echo -e ">>>nope<<< fix before trying again: $@"
}

echo "dotfiles project running out of [$dotfilesDir]"

function printStatus
{
	header "checking status of current dotfiles"
	for f in "${fns[@]}"; do
		fileName="$f"
		homeFile="$HOME/${fileName}"
		fileOutput="$(file $homeFile 2> /dev/null)"
		if [ $? -ne 0 ]; then
			fileOutput="error file'ing file"
		fi
		fileType="${fileOutput#${homeFile}: }"
		printf "~/${co_green}%-15s${co_off} -- %s\n" "${fileName}" "${fileType}"
		test -r ${homeFile}.local && printf "    also ~/$f.local exists\n"
	done
}

function updateForceSelf
{
	cd "$dotfilesDir"
	git reset --hard
	if [ $? -eq 0 ]; then
		good "reset all local changes successfully"
	else
		bad "error forcing the reset self!"
	fi
	updateSelf
}

function updateSelf
{
	cd "$dotfilesDir"
	git pull origin master
	if [ $? -eq 0 ]; then
		good "updated successfully"
	else
		bad "error updating self!"
	fi
}

function uninstallSelf
{
	for f in "${fns[@]}"; do
		hf="$HOME/$f"
		hfl="$HOME/$f.local"
		sf="${syms}/$f"
		linkedTo="$(getLinkedTo "$hf")"
		if [ "$linkedTo" == "$sf" ]; then
			unlink "$hf"
			good "unlinked [$hf] from [$linkedTo]"
			if [ -e "$hfl" ]; then
				mv "$hfl" "$hf"
				good "restored [$hfl] to [$hf]"
			fi
		fi
	done
}

function installSelf
{
	problems=false
	header "final set of files: ${fns[@]}"
	#stamp="$(date '+%Y%m%dT%H%M%S')"
	#echo "using timestamp [$stamp] for backups"

	# lets get ready, and bail if current setup isn't up to it
	header "stating installation readiness verification"	
	test ! -r "$HOME" && bad "home directory [$HOME] isn't readable, dafuq??" && problems=true
	test ! -w "$HOME" && bad "home directory [$HOME] isn't writable, dafuq??" && problems=true

	for f in "${fns[@]}"; do
		hf="$HOME/$f"
		hfl="$HOME/$f.local"
		sf="${syms}/$f"
		echo ""
		log "dealing with $hf:"
		if [ ! -e $hf ]; then
			warn "[$hf] doesn't exists"
			if [ -e "$hfl" ]; then
				good "but [$hfl] already exists"
			else
				warn "and [$hfl] doesn't exist either, will *not* be created"
			fi
		else
			if [ -L "$hf" ]; then
				linkedTo="$(getLinkedTo "$hf")"
				if [ "${linkedTo}" == "${sf}" ]; then
					good "already symlinked to dotfiles @[$linkedTo]"
				else
					bad "symlinked elsewhere, specifcally [$linkedTo]"
					problems=true
				fi
			elif [ ! -r "$hf" ]; then
				 warn "[$hf] is not readable"
			elif [ ! -w "$hf" ]; then
				bad "[$hf] is not writable"
				problems=true
			else
				good "[$hf] exists and is a replaceable file" 
				if [ -e "$hfl" ]; then
					bad "but [$hfl] already exists, please consolidate first"
					problems=true
				else
					good "and will be moved to [$hfl]"
				fi
			fi
		fi
	done

	echo "encountered problems?: $problems"
	
	if [ $problems == true ]; then
		header "fix problems first!"
		bad "fix the above problems first, bye bye ..."
		return 0
	else
		good "no problems, good to go"
	fi

	header "executive decision needed"
	read -p "looks like it's all set, proceed? [yes or anything else]: " goAhead
	if [ "$goAhead" != "yes" ]; then
		bad "you decided to quit by entering [$goAhead], bye bye ..."
		return 0
	fi

	# lets start installing onto a good setup
	header "stating installation"	
	for f in "${fns[@]}"; do
		hf="$HOME/$f"
		hfl="$HOME/$f.local"
		sf="${syms}/$f"
		log "installing $f ..."
		if [ -L "$hf" ]; then
			unlink "$hf"
			good "removed old link"
		elif [ -e "$hf" ]; then
			mv "$hf" "$hfl"
			good "moved [$hf] to [$hfl]"
		fi
		ln -s "$sf" "$hf"
		good "symlinked [$hf] -> [$sf]"
		
		#groom all config files
		#test in/unstallation elsewhere
		#push to git
		#test updating
		#try irl
	done
}

#some basic input validation
if [ $# -lt 1 ]; then
	usage
fi

case "$1" in
	status)
		printStatus
		;;
	update)
		updateSelf
		;;
	updateForce)
		updateForceSelf
		;;
	install)
		installSelf
		;;
	uninstall)
		uninstallSelf
		;;
	*)
		usage
		;;
esac
