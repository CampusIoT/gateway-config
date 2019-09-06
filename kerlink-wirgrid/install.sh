#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# Check the number of parameters

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 MQTT_USERNAME MQTT_PASSWORD ANTENNA_GAIN_DBI"
    echo "Discarding installation ..."
    exit 1
fi

MQTT_USERNAME=$1
MQTT_PASSWORD=$2
ANTENNA_GAIN_DBI=$3

REPO=https://raw.githubusercontent.com/CampusIoT/gateway-config/master

# check if MQTT_USERNAME == gw-<LoRaNode EUI>
EXPECTED_USERNAME=gw-$(echo "$lora_eui_raw" | tr '[:upper:]' '[:lower:]')
if [ "$MQTT_USERNAME" = "$EXPECTED_USERNAME" ]; then
  echo "MQTT_USERNAME matchs with the expected MQTT username : $EXPECTED_USERNAME"
else
  echo "MQTT_USERNAME does NOT match with the expected MQTT username : $EXPECTED_USERNAME"
  echo "Discarding installation ..."
  exit 1
fi

# Install lora-gateway-bridge
echo "lora-gateway-bridge installing ..."

mkdir -p /mnt/fsuser-1/lora-gateway-bridge
cd /mnt/fsuser-1/lora-gateway-bridge
VERSION=2.6.2
REPO=https://artifacts.loraserver.io/downloads/lora-gateway-bridge/
BINTGZ=lora-gateway-bridge_${VERSION}_linux_armv5.tar.gz
#BINTGZ=lora-gateway-bridge_${VERSION}_linux_armv6.tar.gz
#BINTGZ=lora-gateway-bridge_${VERSION}_linux_armv7.tar.gz

wget $REPO/$BINTGZ
# Do not work since wget do not support https.
tar xvf $BINTGZ

echo "lora-gateway-bridge installed"

echo "lora-gateway-bridge configuring ..."

REPO=https://github.com/CampusIoT/gateway-config/tree/master/kerlink-wirgrid
cd /mnt/fsuser-1/lora-gateway-bridge
wget $REPO/lora-gateway-bridge/ca.crt -O ca.crt
wget $REPO/lora-gateway-bridge/start.sh -O start.sh
wget $REPO/lora-gateway-bridge/manifest.xml -O manifest.xml
wget $REPO/lora-gateway-bridge/lora-gateway-bridge.toml -O lora-gateway-bridge.toml
sed -i s/__MQTT_USERNAME__/$MQTT_USERNAME/g lora-gateway-bridge.toml
sed -i s/__MQTT_PASSWORD__/$MQTT_PASSWORD/g lora-gateway-bridge.toml


echo "lora-gateway-bridge configured"

# Install lora-packet-forwarder if not install by default
# TODO

# Configure lora-packet-forwarder
echo "lora-packet-forwarder configuring ..."

cd /mnt/fsuser-1/spf/etc
wget $REPO/multitech-mtcap/lora-packet-forwarder/local_conf.json -O local_conf.json
cp
sed -i s/__GWEUI__/$MQTT_PASSWORD/g local_conf.json
sed -i s/__GWEUI__/$MQTT_PASSWORD/g local_conf.json
sed -i s/__ANTENNA_GAIN_DBI__/$ANTENNA_GAIN_DBI/g local_conf.json


echo "lora-packet-forwarder configured"

# End

# TODO check if lora-gateway-bridge is running
ps ax | grep lora-gateway-bridge
# TODO check if lora-packet-forwarder is running
pgrep lora_pkt_fwd
