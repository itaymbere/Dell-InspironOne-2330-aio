#!/bin/bash

BASE="/home/rod/.conky/Dell-InspironOne-2330_aio"
TEMP="$BASE/temp"

mkdir -p "$TEMP"

# 2s
sensors > "$TEMP/collect-sensors.txt" 2>/dev/null

# 3s
if [ -f /sys/kernel/debug/dri/0/radeon_pm_info ]; then
    cat /sys/kernel/debug/dri/0/radeon_pm_info > "$TEMP/collect-radeon.txt" 2>/dev/null
fi

# 5s
for z in /sys/class/thermal/thermal_zone*; do
    echo "$(basename "$z")|$(cat "$z/type" 2>/dev/null)|$(cat "$z/temp" 2>/dev/null)"
done > "$TEMP/collect-thermal.txt"

# 60s
smartctl -A /dev/sda > "$TEMP/collect-smart-sda.txt" 2>/dev/null

# 600s
smartctl -H /dev/sda > "$TEMP/collect-smart-health-sda.txt" 2>/dev/null

# 5s
ip -br addr > "$TEMP/collect-network.txt" 2>/dev/null

# 5s
free -m > "$TEMP/collect-memory.txt" 2>/dev/null
