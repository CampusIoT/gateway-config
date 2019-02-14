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

mkdir -p /user/lora-gateway-bridge
cd /user/lora-gateway-bridge
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

REPO=https://raw.githubusercontent.com/CampusIoT/gateway-config/master/kerlink-ifemtocell
cd /user/lora-gateway-bridge
wget $REPO/lora-gateway-bridge/ca.crt -O ca.crt
wget $REPO/lora-gateway-bridge/start.sh -O start.sh
wget $REPO/lora-gateway-bridge/lora-gateway-bridge.monitrc -O lora-gateway-bridge.monitrc
cp lora-gateway-bridge.monitrc /etc/monit.d/
wget $REPO/lora-gateway-bridge/lora-gateway-bridge.toml -O lora-gateway-bridge.toml
sed -i s/__MQTT_USERNAME__/$MQTT_USERNAME/g lora-gateway-bridge.toml
sed -i s/__MQTT_PASSWORD__/$MQTT_PASSWORD/g lora-gateway-bridge.toml
chmod +x *.sh
monit reload
sleep 1
monit status lora-gateway-bridge

echo "lora-gateway-bridge configured"

# Install lora-packet-forwarder if not install by default

# Configure lora-packet-forwarder
echo "lora-packet-forwarder configuring ..."

cd /user/spf/etc
wget $REPO/lora-packet-forwarder/local_conf.json -O local_conf.json
sed -i s/__GWEUI__/$MQTT_PASSWORD/g local_conf.json
sed -i s/__GWEUI__/$MQTT_PASSWORD/g local_conf.json
sed -i s/__ANTENNA_GAIN_DBI__/$ANTENNA_GAIN_DBI/g local_conf.json
sleep 1
monit status spf

echo "lora-packet-forwarder configured"

# End
