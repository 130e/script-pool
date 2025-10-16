#!/bin/sh
set -e

[ "$(id -u)" -ne 0 ] && echo "Must be run as root." && exit 1

validate() {
    local ifname="$1" rate="$2" lat="$3" delay="$4" jitter="$5" loss="$6"

    ip link show "$ifname" >/dev/null 2>&1 || {
        echo "Interface '$ifname' not found."
        exit 1
    }

    for v in "$rate" "$lat" "$delay" "$jitter"; do
        case "$v" in
        *[!0-9]*)
            echo "Invalid numeric value: $v"
            exit 1
            ;;
        esac
    done

    case "$loss" in
    *[!0-9.]* | "")
        echo "Invalid loss value: $loss"
        exit 1
        ;;
    esac
}

apply_tc() {
    local action="$1" ifname="$2" rate="$3" lat="$4" delay="$5" jitter="$6" loss="$7"
    validate "$ifname" "$rate" "$lat" "$delay" "$jitter" "$loss"

    # Compute burst: minimum 32KB
    local burstsz=$((rate / 250)) # bytes
    [ "$burstsz" -lt 32768 ] && burstsz=32768

    echo "Running: tc qdisc $action dev $ifname (rate=${rate}bit, burst=${burstsz}b, delay=${delay}ms ±${jitter}ms, loss=${loss}%)"

    tc qdisc "$action" dev "$ifname" root handle 1: tbf rate "${rate}bit" burst "${burstsz}b" latency "${lat}ms"
    tc qdisc "$action" dev "$ifname" parent 1:1 handle 10: netem delay "${delay}ms" "${jitter}ms" loss "${loss}%"

    echo "Result:"
    tc qdisc show dev "$ifname"
}

delete_tc() {
    local ifname="$1"
    echo "🧹 Deleting TC rules on $ifname"
    tc qdisc del dev "$ifname" root 2>/dev/null || echo "(no existing qdisc)"
}

usage() {
    echo "Usage:"
    echo "  $0 {add|change|replace|del} <if> [<rate_bits> <tbf_lat_ms> <delay_ms> <jitter_ms> <loss_pct>]"
    echo "Example:"
    echo "  $0 add eth0 2000000 400 100 20 5"
}

# --- NEW: Support direct tc actions (add/change/replace) ---
case "$1" in
add | change | replace)
    [ $# -ne 7 ] && usage && exit 1
    apply_tc "$1" "$2" "$3" "$4" "$5" "$6" "$7"
    exit 0
    ;;
del)
    [ $# -ne 2 ] && echo "Usage: $0 del <if>" && exit 1
    delete_tc "$2"
    ;;
*)
    usage && exit 1
    ;;
esac
