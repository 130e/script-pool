#!/bin/sh

[ $(id -u) -ne 0 ] && echo "must run as root" && exit 1

load() {
    ifname="$1"
    buffersz="$2"
    tc qdisc del dev "${ifname}" root
    tc qdisc add dev "${ifname}" root handle 1:0 pfifo limit "${buffersz}"
}

case "$1" in
    load)
        echo "Load tc rules"
        load "$2" "$3"
        ;;
    *)
        echo "$1"
        exit 1
        ;;
esac
