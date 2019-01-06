#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

HOSTNAME=$(hostname)
GWEUI=0000$(ifconfig eth0 | awk '/HWaddr/ {print $5}' | sed 's/://g')

lora_eui_raw=${GWEUI}
echo "LoRaNode EUI : $lora_eui_raw"

EXPECTED_USERNAME=gw-$(echo "$lora_eui_raw" | tr '[:upper:]' '[:lower:]')
echo "MQTT_USERNAME should be $EXPECTED_USERNAME"
