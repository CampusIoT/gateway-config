#!/bin/bash

# Copyright (C) CampusIoT,  - All Rights Reserved
# Written by CampusIoT Dev Team, 2016-2018

# List packages
opkg update

echo ==================================
echo List available packages
opkg list | grep -E '(mosquitto|lora|node)'

echo ==================================
echo List installed packages
opkg list-installed | grep -E '(mosquitto|lora|node)'

echo ==================================
echo List installed and upgradable packages
opkg list-upgradable | grep -E '(mosquitto|lora|node)'
