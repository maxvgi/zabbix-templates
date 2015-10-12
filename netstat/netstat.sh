#!/bin/bash


CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/zabbix-netstat-status.cache"

if [ -s "$CACHE" ]; then
    TIMECACHE=`stat -c"%Z" "$CACHE"`
else
    TIMECACHE=0
fi

TIMENOW=`date '+%s'`

if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    netstat -s > $CACHE
fi

if [[ "$1" == "" ]] ; then
    grep -e '[0-9]' $CACHE | sed 's/[0-9][0-9]*//g' | sed 's/\s\+/ /g' | sed 's/^ //' | grep -v :
    exit
fi

res=`grep "$1" $CACHE | sed 's/[^0-9]*[^0-9-]\(-\?[0-9]\+\).*/\1/g' | head -n 1`
if [[ "$res" == "" ]] ; then
    echo 0
else
    echo $res
fi

