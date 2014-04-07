#!/bin/sh


DEFAULT_HOST=127.0.0.1
DEFAULT_KEY=objects


if [ "$1" != "" ] ; then
    DEFAULT_KEY=$1
fi

if [ "$2" != "" ] ; then
    DEFAULT_HOST=$2
fi

down=`asinfo -h 10.0.0.1 -v version | grep error | wc -l`

if [ "$down" = "1" ] ; then
    echo "-1"
    exit
fi

if [ "$DEFAULT_KEY" = "keys" ] ; then
    /usr/bin/asinfo -h $DEFAULT_HOST | head -n 4 | tail -n 1 |  tr ';' '\n' | awk -F '=' '{print $1;}' | xargs
else
    /usr/bin/asinfo -h $DEFAULT_HOST | head -n 4 | tail -n 1 | tr ';' '\n' | tr -d ' ' | grep "^$DEFAULT_KEY=" | awk -F '=' '{print $2;}'
fi
