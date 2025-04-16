#!/bin/bash
TIME=$(date +%Y-%m-%d-%H%M%S)
# unix time
# TIME=$(date +%s%N)
PORT=5257
DURATION=60
UDPBUFSZ=16M
IPERF=iperf3
IF=enp1s0

iperf_only() {
	${IPERF} -s -p ${PORT} -1
}

iperf_run() {
	${IPERF} -s -i 0.1 -p ${PORT} -1 -J --logfile "server-$1-${TIME}.log"
}

pcap() {
	tcpdump -i ${IF} port ${PORT} -n -B 10240 -w sender-$1-${TIME}.pcap
}

case "$1" in
c)
	echo "cubic iperf"
	sysctl -w net.ipv4.tcp_congestion_control=cubic
	;;
b)
	echo "bbr iperf"
	sysctl -w net.ipv4.tcp_congestion_control=bbr
	;;
*)
	echo "script c/b [run_id]"
	exit
	;;
esac

# Start
echo "Iperf server type $1, Run $2"

iperf_run "$2" &
# pcap "$2" &

# kill -- -$$
