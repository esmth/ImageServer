#!/bin/bash
INTERFACE='enp3s0'

ip addr flush $INTERFACE
ip link set $INTERFACE up
ip addr add 10.200.200.199/24 dev $INTERFACE
dnsmasq -d -n -C configs/dnsmasq.conf
