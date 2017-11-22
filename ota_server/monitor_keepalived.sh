#!/bin/bash
A=`ps -C haproxy --no-header |wc -l`
if [ $A -eq 0 ];then
	/etc/init.d/haproxy start
	sleep 3
	if [ `ps -C haproxy --no-header |wc -l` -eq 0 ];then
		/etc/init.d/keepalived stop
	fi
fi
