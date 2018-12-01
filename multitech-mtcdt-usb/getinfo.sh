#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# Display mLinux version
cat /etc/mlinux-version
mts-io-sysfs show lora/product-id
mts-io-sysfs show lora/hw-version

# Display LoRaNode EUI
lora_eui=$(mts-io-sysfs show lora/eui 2> /dev/null)
lora_eui_raw=${lora_eui//:/}
echo "LoRaNode EUI : $lora_eui_raw"

EXPECTED_USERNAME=gw-$(echo "$lora_eui_raw" | tr '[:upper:]' '[:lower:]')
echo "MQTT_USERNAME should be $EXPECTED_USERNAME"
