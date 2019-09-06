#!/bin/sh

# Script launched by crond in order to check if lora-gateway-bridge is running
# since knetd seems failed to start the manifest.xml

# Add the following line with 'crontab -e'

# */2 * * * *  /mnt/fsuser-1/gps_pkt_fwd_2.0.0/cron.sh

if /usr/bin/pgrep  "gps_pkt_fwd" > /dev/null
then
    echo "gps_pkt_fwd is running"
else
    echo "gps_pkt_fwd is stopped. starting it ..."
    cd /mnt/fsuser-1/gps_pkt_fwd_2.0.0
    ./start.sh
fi
