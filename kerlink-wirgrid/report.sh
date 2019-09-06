#!/bin/sh

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# This script is executed on the Kerlink gateway

# Variables for the gateways
# 8.8.8.8 is Google DNS
HOSTS_TO_PING="8.8.8.8 lora.campusiot.imag.fr"

GATEWAY_MANAGERS="lora.campusiot.imag.fr"
GATEWAY_MANAGERS_SSHPORT=2222

# Beginning of the reporting script

export PATH=/bin:/sbin:/usr/bin:/usr/local/bin/

echo
echo "[date]"
echo

date -R

echo "[general]"
echo
echo "HOSTNAME=$(hostname)"
echo "GWEUI=0000$(ifconfig eth0 | awk '/HWaddr/ {print $5}' | sed 's/://g')"

echo
echo "[uname]"
echo
uname -a

echo
echo "[version]"
echo
cat /proc/version

echo
echo "[wirgrid_version]"
echo
/usr/local/bin/get_version

echo
echo "[uptime]"
echo
uptime
cat /proc/uptime

echo
echo "[df]"
echo
df
echo
df -i

echo
echo "[stat]"
echo
cat /proc/stat

echo
echo "[cpuinfo]"
echo
cat /proc/cpuinfo

echo
echo "[ifconfig]"
echo
ifconfig

echo
echo "[rxtx]"
echo
echo ppp0: $(ifconfig ppp0 | grep bytes)
echo eth0: $(ifconfig eth0 | grep bytes)

echo
echo "[route]"
echo
route

echo
echo "[netstat]"
echo
netstat

echo
echo "[meminfo]"
echo
cat /proc/meminfo

echo
echo "[diskstats]"
echo
cat /proc/diskstats

echo
echo "[crypto]"
echo
cat /proc/crypto


echo
echo "[lib]"
echo
ls -al /lib

echo
echo "[usrlib]"
echo
ls -al /usr/lib

echo
echo "[knet]"
echo

grep ACCESS_POINT /knet/knetd.xml


echo
echo "[sysconfig_network]"
echo

grep BEARERS_PRIORITY /etc/sysconfig/network
echo
grep DNS /etc/sysconfig/network


echo
echo "[dns]"
echo

cat /etc/resolv.conf

echo

nslookup lora.campusiot.imag.fr


echo
echo "[ping_eth0]"
echo

INTERFACE=eth0
for ho in $HOSTS_TO_PING
do
ping -I $INTERFACE -c 5 $ho
done

echo
echo "[ping_ppp0]"
echo

INTERFACE=ppp0
for ho in $HOSTS_TO_PING
do
ping -I $INTERFACE -c 5 $ho
done

# TODO traceroute (not available on Kerlink stations)

echo
echo "[gprs]"
echo

grep GPRS /etc/sysconfig/network
echo
grep BEARERS_PRIORITY /etc/sysconfig/network
echo
/etc/init.d/gprs status

echo
echo "[crontab]"
echo

crontab -l

echo
echo "[update]"
echo

echo "DATE=$(cat /mnt/fsuser-1/LASTUPDATE.txt)"

echo
echo "[gateway_managers]"
echo

for MANAGER in $GATEWAY_MANAGERS
do
nc -w10 $MANAGER $GATEWAY_MANAGERS_SSHPORT -e ls 2> /dev/null
status=$?
if [ $status -ne 0 ]; then
	echo "Connection to $MANAGER : $SSHPORT : Failed exitcode=$status"
else
	echo "Connection to $MANAGER : $SSHPORT : Success"
fi
done
