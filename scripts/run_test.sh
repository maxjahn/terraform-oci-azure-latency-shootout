#!/bin/sh

prefix=`hostname`"_${1}_"

echo "["`hostname`" -> ${1}]" `date` >> "${prefix}ping.log"
ping -qc 10 ${1} >> "${prefix}ping.log"

echo "["`hostname`" -> ${1}]" `date` >> "${prefix}qperf_tcp.log"
qperf ${1} -vv -uu  -t 10 -ip 19766 tcp_lat  >> "${prefix}qperf_tcp.log"

echo "["`hostname`" -> ${1}]" `date` >> "${prefix}qperf_udp.log"
qperf ${1} -vv -uu  -t 10 -ip 19766 udp_lat >> "${prefix}qperf_udp.log"



