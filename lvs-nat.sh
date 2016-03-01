#!/bin/sh
VIP=172.16.0.10
RIP3=172.16.0.3
RIP4=172.16.0.4

. /etc/rc.d/init.d/functions

case "$1" in

start)
    echo "Start lvs of nat mode."

    # set vip address
    echo "1" > /proc/sys/net/ipv4/ip_forward
    /usr/sbin/iptables -F
    /usr/sbin/iptables -X
    /usr/sbin/ifconfig eth0:0 $VIP netmask 255.255.255.0 up

    # clear ipvs table
    /usr/sbin/ipvsadm -C

    # set lvs
    /usr/sbin/ipvsadm -A -t $VIP:80 -s rr
    /usr/sbin/ipvsadm -a -t $VIP:80 -r $RIP3 -m
    /usr/sbin/ipvsadm -a -t $VIP:80 -r $RIP4 -m

    # run lvs
    /usr/sbin/ipvsadm
    ;;

stop)
    echo "Stop lvs of nat mode."
    echo "0" > /proc/sys/net/ipv4/ip_forward
    /usr/sbin/ipvsadm -C
    /usr/sbin/ifconfig eth0:0 down
    ;;

*)
    echo "Usage: $0 {start|stop}"
    exit 1
esac
exit 0
