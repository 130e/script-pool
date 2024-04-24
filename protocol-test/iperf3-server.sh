#!/bin/bash
# date
TIME=$(date +%Y-%m-%d-%H%M%S)
# unix time
# TIME=$(date +%s%N)
PORT=5201
DURATION=60
UDPBUFSZ=16M
IPERF=iperf3
IF=enp1s0

iperf_only() {
	${IPERF} -s -p ${PORT} -1
}

iperf_run() {
	iperf3 -s -i 0.1 -p ${PORT} -1 -J --logfile "server-$1-${TIME}.log"
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
# server "$2" &
#pcap "$2" &

# counter=$(($2 * 10))
# while [ $counter -gt 0 ]
# do
#     ss -itH '( sport = :5257 )' >> ss-$1.log
#     sleep 0.1
#     counter=$(( $counter - 1 ))
# done

kill -- -$$
