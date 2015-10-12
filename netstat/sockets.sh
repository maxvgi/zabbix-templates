#!/bin/bash

PORT="$2"

CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/zabbix-sockets-status.$PORT.cache"

if [ -s "$CACHE" ]; then
    TIMECACHE=`stat -c"%Z" "$CACHE"`
else
    TIMECACHE=0
fi

TIMENOW=`date '+%s'`

if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    if [[ $PORT == "" ]] ; then
        ss -na | grep -v State | grep -v LISTEN | awk '{print $1;}' | sort | uniq -c > $CACHE
    else
	ss -na src $PORT | grep -v State | awk '{print $1;}' | sort | uniq -c > $CACHE
    fi
fi

res=`grep "$1" $CACHE | awk '{print $1;}'`
if [[ "$res" == "" ]] ; then
    echo 0
else
    echo $res
fi
