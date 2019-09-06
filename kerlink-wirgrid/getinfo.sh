#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# Display wirgrid version

# Display LoRaNode EUI
lora_eui_raw=${lora_eui//:/}
echo "LoRaNode EUI : $lora_eui_raw"

EXPECTED_USERNAME=gw-$(echo "$lora_eui_raw" | tr '[:upper:]' '[:lower:]')
echo "MQTT_USERNAME should be $EXPECTED_USERNAME"
