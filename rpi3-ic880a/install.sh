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

HOSTNAME=$(hostname)
GWEUI=0000$(ifconfig eth0 | awk '/HWaddr/ {print $5}' | sed 's/://g')

lora_eui_raw=${GWEUI}
echo "LoRaNode EUI : $lora_eui_raw"

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

cd /tmp
DEB=lora-gateway-bridge_2.5.1_armhf.deb
wget https://artifacts.loraserver.io/downloads/lora-gateway-bridge/$DEB
sudo dpkg -i /tmp/$DEB
rm $DEB

echo "lora-gateway-bridge installed"

echo "lora-gateway-bridge configuring ..."

cd /tmp
wget $REPO/lora-gateway-bridge/ca.crt -O ca.crt
wget $REPO/lora-gateway-bridge/lora-gateway-bridge.toml -O lora-gateway-bridge.toml
sed -i.bak s/__MQTT_USERNAME__/$MQTT_USERNAME/g lora-gateway-bridge.toml
sed -i.bak s/__MQTT_PASSWORD__/$MQTT_PASSWORD/g lora-gateway-bridge.toml
sed -i.bak s/var\/config/etc/g lora-gateway-bridge.toml

sudo -u gatewaybridge cp ca.crt /etc/lora-gateway-bridge/ca.crt
sudo -u gatewaybridge cp lora-gateway-bridge.toml /etc/lora-gateway-bridge/lora-gateway-bridge.toml

sudo service lora-gateway-bridge stop
sudo service lora-gateway-bridge start
sudo service lora-gateway-bridge status

echo "lora-gateway-bridge configured"

# Build lora-packet-forwarder if not install by default
echo "lora_pkt_fwd building ..."

mkdir -p  Lora-net
cd Lora-net
git clone https://github.com/Lora-net/lora_gateway.git
(cd lora_gateway; make clean; make)

git clone https://github.com/Lora-net/packet_forwarder.git
(cd packet_forwarder; make clean; make)

echo "lora_pkt_fwd built"

# Install lora-packet-forwarder
echo "lora-packet-forwarder installing ..."

mkdir -p /opt/lora-packet-forwarder
cp packet_forwarder/lora_pkt_fwd/lora_pkt_fwd /opt/lora-packet-forwarder
cp packet_forwarder/lora_pkt_fwd/cfg/global_conf.json.PCB_E286.EU868.basic /opt/lora-packet-forwarder/global_conf.LOCALHOST.json

cd /opt/lora-packet-forwarder
wget $REPO/rpi3-ic880a/lora-packet-forwarder/local_conf.json -O local_conf.LOCALHOST.json
sed -i.bak s/__ANTENNA_GAIN_DBI__/$ANTENNA_GAIN_DBI/g local_conf.LOCALHOST.json

wget $REPO/rpi3-ic880a/lora-packet-forwarder/start.sh -O start.sh
wget $REPO/rpi3-ic880a/lora-packet-forwarder/start.sh -O stop.sh
wget $REPO/rpi3-ic880a/lora-packet-forwarder/start.sh -O reset_lgw.sh
chmod +x *.sh

sudo apt install monit -y
wget $REPO/rpi3-ic880a/lora-packet-forwarder/monitrc -O monitrc
sudo cp monitrc /etc/monit/
sudo monit reload

echo "lora-packet-forwarder installed"

# End

# TODO check if lora-gateway-bridge is running
ps ax | grep lora-gateway-bridge
# TODO check if lora-packet-forwarder is running
pgrep lora_pkt_fwd
