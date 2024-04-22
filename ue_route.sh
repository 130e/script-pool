# Run this in UE to set routing table
#!/bin/sh
brctl addbr br0
brctl addif br0 enp0s20f0u1
ip link set up dev br0
ip link add type veth
ip link add type veth
brctl addif br0 veth0
brctl addif br0 veth2
ip link set up dev veth0
ip link set up dev veth1
ip link set up dev veth2
ip link set up dev veth3
ip addr add 10.0.0.1/24 dev veth1
ip addr add 10.0.0.1/24 dev veth3

# reverse - UE IP
ip route add 192.168.64.0/24 dev br0

# UE side for some reason always reference the wlan0 table
# ip route add 10.0.0.0/24 dev rndis0 table wlan0
