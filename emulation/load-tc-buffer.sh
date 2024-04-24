#!/bin/sh

[ $(id -u) -ne 0 ] && echo "must run as root" && exit 1

load() {
    ifname="$1"
    delay="$2"
    delayLimit="$3"
    rate="$4"
    bucketsz=$((${rate}/250))
    queuesz="$5"
    jitter="$6"
    tc qdisc del dev "${ifname}" root
    tc qdisc add dev "${ifname}" root handle 1:0 netem delay ${delay}ms ${jitter}ms limit ${delayLimit}
    tc qdisc add dev "${ifname}" parent 1:1 handle 10:0 tbf rate ${rate}bit burst ${bucketsz}b limit ${queuesz}b mtu 1500
    tc qdisc add dev "${ifname}" parent 10:1 handle 100:0 bfifo limit 1000000b
}

load2() {
    ifname="$1"
    delay="$2"
    delayLimit="$3"
    rate="$4"
    bucketsz=$((${rate}/250))
    queuesz="$5"
    jitter="$6"
    tc qdisc del dev "${ifname}" root
    tc qdisc add dev "${ifname}" root handle 1:0 netem delay ${delay}ms ${jitter}ms limit ${delayLimit}
    tc qdisc add dev "${ifname}" parent 1:1 handle 10:0 tbf rate ${rate}bit burst ${bucketsz}b limit ${queuesz}b mtu 1500
    # tc qdisc add dev "${ifname}" root handle 1:0 bfifo limit "${buffersz}"
}

case "$1" in
    # default load
    load)
        echo "Load tc rules"
        load veth0 75 10000 $((200*1000000)) $((128*1024)) 5 
        ;;
    *)
        echo "script load 2MB"
        exit 1
        ;;
esac
