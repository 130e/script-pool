#!/bin/sh
TIME=$(date +%Y-%m-%d-%H%M%S)
# unix time
# TIME=$(date +%s%N)
PORT=5257
SERVERIP=54.241.85.37
IPERF=./iperf3.10

udp_flood_test() {
    ./flood-receiver -addr ${SERVERIP}:${PORT}
}

tcp_test() {
    duration="$2"
    ${IPERF} -c ${SERVERIP} -R -i 0.1 -p ${PORT} -t ${duration} -J --logfile client-${TIME}.log
}

case "$1" in
    u)
        echo "Run udp flood"
        udp_flood_test "$@"
    ;;
    t)
        echo "Run iperf3 tcp"
        tcp_test "$@"
    ;;
    *)
        echo "script t/u [time]"
esac
