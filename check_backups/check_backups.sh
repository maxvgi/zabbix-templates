#!/bin/bash


backup_config=/backups/buckets.zabbix
DIR=.

if [[ "$1" != "" ]] ; then
	DIR=$1
	if [[ "$DIR" == "discovery" ]] ; then
		for bucket in `cat ` ; do
			if [[ "$buckets" != "$backup_config" ]] ; then
				buckets=$buckets','
			fi
			buckets=$buckets'{"{#BUCKET}":"'$bucket'"}'
		done
		echo '{"data":['$buckets']}'

		exit
	fi
fi

#checks if there are fresh files and each of them is not empty

last_files=`find $DIR -mtime -2 -exec echo {} \; | grep -ve "^$DIR$"`

if [[ "$last_files" == "" ]] ; then
	echo 1
	exit
fi

for file in $last_files ; do
	size=`stat -c%s $file`
	if [[ "$size" == "0" ]] ; then
		echo 2
		exit
	fi
done

echo 0
