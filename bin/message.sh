#!/bin/bash

cat > /tmp/aa <<EOF
1 1 e test
2 3 se moore
1 1 s to
4 2 e another
2 3 s maptop
4 3 N map
EOF

cat > /tmp/bb <<EOF
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
EOF

fb="$(tput bold)"
fu="$(tput smul)"
fo="$(tput sgr0)"

usage() { echo "Usage: $0 [-s(quare grid)] [word file] [message file] [minx] [miny]" 1>&2; exit 1; }

force_square=0

while getopts ":s" o; do
    case "${o}" in
        s)
		force_square=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo "checking if minx [$3] is a valid number ..."
[[ ! "${3:-0}" =~ ^[0-9]+$ ]] && echo "nope" && exit 10

echo "checking if miny [$4] is a valid number ..."
[[ ! "${4:-0}" =~ ^[0-9]+$ ]] && echo "nope" && exit 10

echo "checking if [$1] contains valid data ..."
errors_found=0
good_found=0
reg="^[0-9]+\ +[0-9]+\ +([ns]|[ew]|[ns][ew])\ +[a-z]+$"
while read line
do
	line="$(echo $line | tr '[A-Z' '[a-z]')"
	l=($line)
	if [[ ! "$line" =~ $reg ]]; then
		echo "bad line [$line]"
		((errors_found++))
		continue
	fi
	if [[ ( ${l[2]} =~ w && ${l[0]} -lt ${#l[3]} ) || ( ${l[2]} =~ n && ${l[1]} -lt ${#l[3]} ) ]]; then
		echo "$fb${l[3]}$fo won't fit $fb${l[2]}$fo"
		((errors_found++))
		continue
	fi
	#echo "good line"
	((good_found++))
done < "$1"

echo "errors found: $errors_found"
[ "$errors_found" -gt 0 ] && echo "nope" && exit 2

echo "good found: $good_found"
[ "$good_found" -eq 0 ] && echo "nope" && exit 3

echo "storing input as array"
in_max=0
declare -A inf
while read line
do
	line="$(echo $line | tr '[A-Z' '[a-z]')"
	tlist=($line)
	for((i=0; i<4; i++)); do
		inf[$in_max,$i]=${tlist[$i]}
	done
	((in_max++))
done < "$1"

echo "calculating max grid size"
xmax=$((${3:-0}+1))
ymax=$((${4:-0}+1))
sqmax=0
for((i=0; i<$in_max; i++)); do
	thismx=${inf[$i,0]}
	thismy=${inf[$i,1]}
	len=${#inf[$i,3]}
	[[ ${inf[$i,2]} =~ e ]] && ((thismx+=len))
	[ $thismx -gt $xmax ] && xmax=$thismx
	[[ ${inf[$i,2]} =~ s ]] && ((thismy+=len))
	[ $thismy -gt $ymax ] && ymax=$thismy
done
sqmax=$xmax
[ $ymax -gt $xmax ] && sqmax=$ymax

((xmax--))
((ymax--))
((sqmax--))

echo "found max: x=$xmax, y=$ymax, sq=$sqmax"

if [ $force_square -eq 1 ]; then
	echo "force changing to square size"
	xmax=sqmax
	ymax=sqmax
fi

echo "generating blank grid"
declare -A arr

rows=$xmax
columns=$ymax

for ((i=1;i<=rows;i++)) do
    for ((j=1;j<=columns;j++)) do
        arr[$i,$j]="-"
    done
done

echo "populating words..."
conflicts_found=0
dups_found=0
for ((k=0;k<$in_max;k++)) do
	x0=${inf[$k,0]}
	y0=${inf[$k,1]}
	for ((i=0;i<${#inf[$k,3]};i++)) do
		pre=""
		[[ ${arr[$x0,$y0]} == *${inf[$k,3]:$i:1}* ]] && ((dups_found++))
		# just had to go showing off with styles like that
		if [[ ${arr[$x0,$y0]} != "-" && ${arr[$x0,$y0]} != *${inf[$k,3]:$i:1}* ]]; then
			echo "conflict at [$x0,$y0] of [${inf[$k,3]:$i:1}] with [${arr[$x0,$y0]}]"
			pre="$fu${arr[$x0,$y0]}"
			((conflicts_found++))
		fi
		arr[$x0,$y0]="$pre$fb${inf[$k,3]:$i:1}$fo"
		[[ ${inf[$k,2]} =~ e ]] && ((x0++))
		[[ ${inf[$k,2]} =~ w ]] && ((x0--))
		[[ ${inf[$k,2]} =~ n ]] && ((y0--))
		[[ ${inf[$k,2]} =~ s ]] && ((y0++))
	done
done

for ((j=1;j<=columns;j++)) do
    for ((i=1;i<=rows;i++)) do
        printf " %s" ${arr[$i,$j]}
    done
    echo
done

echo "conflicts found: $conflicts_found"
[ "$conflicts_found" -gt 0 ] && echo "nope" && exit 4

echo "checking if [$2] is a valid file ..."
[ ! -r "$2" -o ! -s "$2" ] && echo "nope" && exit 1

rstr="$(cat $2|tr '[:upper:]' '[:lower:]'|sed 's/./&\n/g'|grep "[a-z]"|shuf|tr -d '\n')"

words_total=0
for ((k=0;k<$in_max;k++)) do
	((words_total+=${#inf[$k,3]}))
done
wc $2
echo "usable size: ${#rstr}, grid size: $((xmax*ymax)), words length: $words_total, dup spots: $dups_found"

echo "input message over/under: $(( ${#rstr} - (xmax*ymax - words_total + dups_found) ))"

rind=0
for ((j=1;j<=columns;j++)) do
    for ((i=1;i<=rows;i++)) do
        if [ "${arr[$i,$j]}" == "-" -a $rind -lt ${#rstr} ]; then
        	arr[$i,$j]=${rstr:$rind:1}
        	((rind++))
        fi
        printf " %s" ${arr[$i,$j]}
    done
    echo
done

