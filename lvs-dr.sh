#!/bin/bash
# lvs of dr

VIP=172.16.0.10
RIP3=172.16.0.3
RIP4=172.16.0.4
# GW=172.16.0.1

. /etc/rc.d/init.d/functions

case "$1" in
start)
    echo "Start lvs of dr mode."

    # set vip address
    /usr/sbin/ifconfig eth0:0 $VIP broadcast $VIP netmask 255.255.255.255 up
    /usr/sbin/route add -host $VIP dev eth0:0
    echo "1" > /proc/sys/net/ipv4/ip_forward

    # clear ipvs table
    /usr/sbin/ipvsadm -C

    # set lvs
    /usr/sbin/ipvsadm -A -t $VIP:80 -s rr -p 600
    /usr/sbin/ipvsadm -a -t $VIP:80 -r $RIP3:80 -g
    /usr/sbin/ipvsadm -a -t $VIP:80 -r $RIP4:80 -g

    # run lvs
    /usr/sbin/ipvsadm
    ;;
stop)
    echo "Stop lvs of dr mode."
    echo "0" > /proc/sys/net/ipv4/ip_forward
    /usr/sbin/ipvsadm -C
    /usr/sbin/ifconfig eth0:0 down
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
esac
exit 0
