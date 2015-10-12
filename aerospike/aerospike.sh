#!/bin/bash


DEFAULT_HOST=127.0.0.1
DEFAULT_PORT=3000
DEFAULT_KEY=objects


if [ "$1" != "" ] ; then
	DEFAULT_KEY=$1
fi

if [ "$2" != "" ] ; then
	DEFAULT_HOST=$2
fi

if [ "$3" != "" ] ; then
	OPT1=$3
fi

if [ "$4" != "" ] ; then
	OPT2=$4
fi

down=`asinfo -h $DEFAULT_HOST -p $DEFAULT_PORT -v version | grep error | wc -l`

if [ "$down" = "1" ] ; then
	echo "-1"
	exit
fi


case "$DEFAULT_KEY" in
	sets)
		if [ "$OPT1" != "" ] ; then
			if [ "$OPT2" = "" ] ;then
				OPT2="n_objects"
			fi
			asinfo -h $DEFAULT_HOST -p $DEFAULT_PORT  -v sets -l | grep "set_name=$OPT1:" | grep -oe "$OPT2=[^:]\+" | awk -F= '{print $2}'
		else
			sets=`asinfo -h $DEFAULT_HOST -p $DEFAULT_PORT  -v sets -l | grep -oe 'set_name=[^:]\+' | awk -F= '{print $2}'`
			for x in $sets ; do
				if [ "$res" != "" ] ; then
					res=$res','
				fi
				res=$res'{"{#SET}":"'$x'"}'
			done
			echo '{"data":['$res']}'
		fi
		;;
	keys)
		/usr/bin/asinfo -h $DEFAULT_HOST -p $DEFAULT_PORT  | head -n 4 | tail -n 1 |  tr ';' '\n' | awk -F '=' '{print $1;}' | xargs
		;;
	latency)
		case $OPT1 in
			8) OPT1='$5' ;;
			64) OPT1='$6' ;;
			*) OPT1='$4' ;;
		esac
		/usr/bin/asmonitor -d /var/lib/zabbix/.asmonitor -e "latency -v reads -h $DEFAULT_HOST -p $DEFAULT_PORT " | grep ":$DEFAULT_PORT" | awk "{print $OPT1}"
		;;
	stat_read_latency_gt100 | stat_read_latency_gt250 | stat_read_latency_gt50 | stat_write_latency_gt100 | stat_write_latency_gt250 | stat_write_latency_gt50 )
		/usr/bin/asmonitor -h $DEFAULT_HOST -p $DEFAULT_PORT -d /var/lib/zabbix/.asmonitor -e 'stat' | grep "$DEFAULT_KEY" | awk '{print $2}'
		;;
	*)
		res=`/usr/bin/asinfo -h $DEFAULT_HOST -p $DEFAULT_PORT  | head -n 4 | tail -n 1 | tr ';' '\n' | tr -d ' ' | grep "^$DEFAULT_KEY=" | awk -F '=' '{print $2;}'`
		if [[ "$res" == "" ]] ; then
			res='0'
		fi
		echo $res
		;;
esac
