#!/bin/sh -e

LBT_OPTION='-l'
LOGGER="logger -p local1.notice"

modem_start() {
	wirma2hw p0_06 up
	usleep 1
	wirma2hw p0_07 up
	usleep 1	
	wirma2hw p0_07 down

	# Disable Loopback mode on HS UART
	[ -f /sys/class/tty/ttyTX1/device/loopback ] && echo 0 > /sys/class/tty/ttyTX1/device/loopback

	usleep 100
	# Check if LBT is enabled, load LoRa board FPGA code and extract versio|ns
	if grep -A 1 "lbt_cfg" global_conf.json|grep -q "false"; then
		util_fpga_start 2>/dev/null
	else
		util_fpga_start ${LBT_OPTION} 2>/dev/null
	fi
}


# Move to configuration directory
cd /mnt/fsuser-1/gps_pkt_fwd_2.0.0/

# Start packet forwarder
./gps_pkt_fwd 2>&1 | $LOGGER -t gps_pkt_fwd &

