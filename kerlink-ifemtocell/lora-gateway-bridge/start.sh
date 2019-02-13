#!/bin/sh

LOGGER="logger -p local1.notice"

# mosquitto
iptables -A INPUT -p tcp --sport 8883 -j ACCEPT

cd /user/lora-gateway-bridge
./lora-gateway-bridge --config lora-gateway-bridge.toml  2>&1 | $LOGGER &
