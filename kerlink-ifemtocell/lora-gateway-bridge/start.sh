#!/bin/sh

LOGGER="logger -p local1.notice -t lora-gateway-bridge"

# mosquitto
iptables -A OUTPUT -p tcp --dport 8883 -j ACCEPT

cd /user/lora-gateway-bridge
./lora-gateway-bridge --config lora-gateway-bridge.toml  2>&1 | $LOGGER &

# pid for monit
pidof lora-gateway-bridge > /var/run/lora-gateway-bridge.pid
