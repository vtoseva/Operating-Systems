#!/bin/bash

if [[ $# -ne 1 ]] ; then
    echo "Expected 1 argument - username"
    exit 1
fi

if [[ "$EUID" -ne 0 ]] ; then
    echo "Script must be executed as root"
    exit 1
fi

foo=${1}

fooPsCount=$(ps -u "$foo" | tail -n +2 | wc -l)
ps -e -o user | sort | uniq -c | awk -v count=$fooPsCount '$1 > count {print $0}'

times=$(ps -e -o time | tail -n +2)
sum=0
count=0
for time in $times; do
	seconds=$(echo "$time" | awk -F ':' '{print 3600*$1 + 60*$2 +$3}'
	sum=$((sum+seconds))
	((count++))
done

avgTime=0
if [[ $count -ne 0 ]]; then
	avgTime=$((sum/count))
fi
echo $(date -u -d "@$avgTime" +'%H:%M:%S')

while read line; do
	time=$(echo "$line" | awk 'print $2')
	seconds=$(echo "$line" | awk -F ':' '{print 3600*$1 + 60*$2 +$3}')
	pid=$(echo "$line" | awk 'print $1')
	if [[ $seconds-gt $((2*avgTime)) ]]; then
		echo $pid
	fi
done < <(ps -e -0 pid,time | tail -n +2)