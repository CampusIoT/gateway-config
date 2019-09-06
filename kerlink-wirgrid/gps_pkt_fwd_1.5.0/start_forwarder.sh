#!/bin/sh

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by Didier DONSEZ and Vivien QUEMA, 2016-2018

# This script is executed on the Kerlink gateway. It is launched by knetd.

# LOCAL or CAMPUSIOT
MODE=CAMPUSIOT

CF_BAND=eu868-867

BASE="/mnt/fsuser-1/gps_pkt_fwd"
cd ${BASE}

EXEC=${BASE}/gps_pkt_fwd
EXEC_NEW_VERSION="${EXEC}_NEW_VERSION"


# First time, update or the executable
if [ -f "$EXEC_NEW_VERSION" ]; then
logger -t xnet "Replace $EXEC by $EXEC_NEW_VERSION"
# echo "Replace $EXEC by $EXEC_NEW_VERSION"
mv $EXEC_NEW_VERSION $EXEC
fi

# start GSM modem
modem_on.sh

# copy the global_conf.json
cp -f global_conf.$CF_BAND.json global_conf.json

# copy the local_conf.json
cp -f local_conf.$MODE.json local_conf.json

# configure the local_conf.json with the eth0 mac address
GWEUI=0000$(ifconfig eth0 | awk '/HWaddr/ {print $5}' | sed 's/://g')
sed -i s/GWEUI/$GWEUI/g local_conf.json

# remove current logFile and logFile created 60 sec after xnet_forwarder startup
#rm -f ./logFile
#(sleep 60; rm logFile) &

logger -t gps_pkt_fwd  "Starting gps_pkt_fwd with gweui=$GWEUI (mode $MODE)"
# check with tail -f /var/log/messages

$EXEC

logger -t gps_pkt_fwd  "gps_pkt_fwd stopped gweui=$GWEUI (mode $MODE)"
