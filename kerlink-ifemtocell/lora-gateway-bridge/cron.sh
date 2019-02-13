#!/bin/sh

# Script launched by crond in order to check if lora-gateway-bridge is running
# since knetd seems failed to start the manifest.xml

# Add the following line with 'crontab -e'

# */2 * * * *  /user/lora-gateway-bridge/cron.sh

if /usr/bin/pgrep  "lora-gateway-bridge" > /dev/null
then
    echo "lora-gateway-bridge is running"
else
    echo "lora-gateway-bridge is stopped. starting it ..."
    /user/lora-gateway-bridge/start.sh
fi
