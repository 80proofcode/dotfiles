#!/usr/bin/env bash 

set -e

[ $# -ge 3 ] && L2=$3
if [ $# -ge 2 ]; then
	L=$2
else
	echo "usage: $0 log_file request_line [response_line]"
	exit 1
fi

F=$1

[ -z "$L2" ] && L2=$((L+1))

t=$(mktemp -t /tmp/tmp.persh.XXXXX)

echo "using file ${t}"

echo -e "request:\n" > $t
sed -n "${L}{p;q}" ${F} | grep -Eo "<soap(-env)?:Envelope.*" | xmllint --format - >> $t
echo -e "\n\nresponse:\n" >> $t
sed -n "${L2}{p;q}" ${F} | grep -Eo "<soap(-env)?:Envelope.*" | xmllint --format - >> $t

cat $t 

echo "cleaning up"
rm -f $t
