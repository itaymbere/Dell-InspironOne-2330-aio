#!/bin/bash

BASE="/home/rod/.conky/Dell-InspironOne-2330_aio"
TEMP="$BASE/temp"

mkdir -p "$TEMP"

sensors > "$TEMP/detected-sensors.txt" 2>&1
ip -br addr > "$TEMP/detected-network.txt" 2>&1
lsblk -o NAME,SIZE,MODEL,TYPE,FSTYPE,MOUNTPOINT > "$TEMP/detected-disks.txt" 2>&1
smartctl --scan > "$TEMP/detected-smart.txt" 2>&1
lscpu > "$TEMP/detected-cpu.txt" 2>&1
free -m > "$TEMP/detected-memory.txt" 2>&1
find /sys/class/hwmon -name "temp*_input" > "$TEMP/detected-temp-inputs.txt" 2>&1
find /sys/class/hwmon -name "fan*_input" > "$TEMP/detected-fan-inputs.txt" 2>&1
find /sys/class/hwmon -name "in*_input" > "$TEMP/detected-voltage-inputs.txt" 2>&1
find /sys/class/drm -name hwmon > "$TEMP/detected-gpu-hwmon.txt" 2>&1

if [ -f /sys/kernel/debug/dri/0/radeon_pm_info ]; then
    cat /sys/kernel/debug/dri/0/radeon_pm_info > "$TEMP/detected-radeon-pm-info.txt" 2>&1
fi

for z in /sys/class/thermal/thermal_zone*; do
    echo "ZONE=$(basename "$z")"
    cat "$z/type" 2>/dev/null
    cat "$z/temp" 2>/dev/null
    echo
done > "$TEMP/detected-thermal-zones.txt" 2>&1
