#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# This script is executed on the RPI+iC880a gateway

COMPONENT="lora-packet-forwarder"

DIST_ROOT_DIR="/opt"
EXEC_DIR="$DIST_ROOT_DIR/$COMPONENT"
PIDFILE=$EXEC_DIR/pid.txt

IOT_SK_SX1301_RESET_PIN=17

if [ -f "$PIDFILE" ]; then
  kill $(cat $PIDFILE)
fi

./reset_lgw.sh stop $IOT_SK_SX1301_RESET_PIN

exit 0
