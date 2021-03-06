#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# Documentation : https://www.loraserver.io/lora-gateway-bridge/install/gateway/multitech/

# Check the number of parameters

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 MQTT_USERNAME MQTT_PASSWORD ANTENNA_GAIN_DBI"
    echo "Discarding installation ..."
    exit 1
fi

MQTT_USERNAME=$1
MQTT_PASSWORD=$2

# The gain of the onboard antenna of the MTCDT is 3 dBi
ANTENNA_GAIN_DBI=$3

REPO=https://raw.githubusercontent.com/CampusIoT/gateway-config/master

# Display mLinux version
cat /etc/mlinux-version
mts-io-sysfs show lora/product-id
mts-io-sysfs show lora/hw-version

lora_eui=$(mts-io-sysfs show lora/eui 2> /dev/null)
lora_eui_raw=${lora_eui//:/}
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

# Remove default packages
opkg remove lora-network-server
opkg remove mosquitto
opkg remove node-red

# Install lora-gateway-bridge
echo "lora-gateway-bridge installing ..."

cd /tmp
IPK=lora-gateway-bridge_2.6.0-r1.1_arm926ejste.ipk
wget https://artifacts.loraserver.io/vendor/multitech/conduit/$IPK
opkg install $IPK
rm $IPK

echo "lora-gateway-bridge installed"

echo "lora-gateway-bridge configuring ..."

cd /var/config/lora-gateway-bridge
wget $REPO/lora-gateway-bridge/ca.crt -O ca.crt
wget $REPO/lora-gateway-bridge/lora-gateway-bridge.toml -O lora-gateway-bridge.toml
sed -i.bak s/__MQTT_USERNAME__/$MQTT_USERNAME/g lora-gateway-bridge.toml
sed -i.bak s/__MQTT_PASSWORD__/$MQTT_PASSWORD/g lora-gateway-bridge.toml

/etc/init.d/lora-gateway-bridge stop
/etc/init.d/lora-gateway-bridge start
update-rc.d lora-gateway-bridge defaults

echo "lora-gateway-bridge configured"

# Install lora-packet-forwarder if not install by default

# wget https://artifacts.loraserver.io/vendor/multitech/conduit/lora-packet-forwarder-usb_1.4.1-r2.0_arm926ejste.ipk
# opkg install lora-packet-forwarder-usb_1.4.1-r2.0_arm926ejste.ipk
# opkg flag hold lora-packet-forwarder-usb
# /etc/init.d/lora-packet-forwarder-usb start
# update-rc.d lora-packet-forwarder-usb defaults


# Configure lora-packet-forwarder-usb
echo "lora-packet-forwarder-usb configuring ..."

/etc/init.d/lora-packet-forwarder-usb stop
/etc/init.d/lora-packet-forwarder-usb start
update-rc.d lora-packet-forwarder-usb defaults

/etc/init.d/lora-packet-forwarder-usb stop
cd /var/config/lora/
wget $REPO/multitech-mtcdt-usb/lora-packet-forwarder/local_conf.json -O local_conf.json
sed -i.bak s/__ANTENNA_GAIN_DBI__/$ANTENNA_GAIN_DBI/g local_conf.json
/etc/init.d/lora-packet-forwarder-usb start

echo "lora-packet-forwarder configured"

# End

# TODO check if lora-gateway-bridge is running
ps ax | grep lora-gateway-bridge
# TODO check if lora-packet-forwarder is running
pgrep lora_pkt_fwd
