#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# This script is executed on the RPI+iC880a gateway by monit

MODE="LOCALHOST"

COMPONENT="lora-packet-forwarder"
DIST_ROOT_DIR="/opt"
BASE="$DIST_ROOT_DIR/$COMPONENT"
EXEC="${BASE}/lora_pkt_fwd"
EXEC_NEW_VERSION="${EXEC}_NEW_VERSION"
LOGFILE=/dev/null
# LOGFILE=nohup.out

cd ${BASE}
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/lib

# First time, update or the executable
if [ -f "$EXEC_NEW_VERSION" ]; then
logger -t ${COMPONENT} "Replace $EXEC by $EXEC_NEW_VERSION"
# echo "Replace $EXEC by $EXEC_NEW_VERSION"
mv $EXEC_NEW_VERSION $EXEC
fi

# copy files according to the mode
[ -f "local_conf.$MODE.json" ] && cp -f local_conf.$MODE.json local_conf.json
[ -f "global_conf.$MODE.json" ] && cp -f global_conf.$MODE.json global_conf.json

# configure the config.cfg with the eth0 mac address
GWEUI=0000$(/sbin/ifconfig eth0 | /usr/bin/awk '/HWaddr/ {print $5}' | /bin/sed 's/://g')
GWEUI_LSBF=$(echo $GWEUI | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\8\7\6\5\4\3\2\1/')
sed -i s/GWEUI/$GWEUI/g local_conf.json

logger -t ${COMPONENT}  "Starting $COMPONENT with gweui=$GWEUI_LSBF (mode $MODE) : Output is $LOGFILE"
nohup $EXEC > $LOGFILE 2>&1  &
echo $! > pid.txt

# check traces with tail -f /var/log/messages
