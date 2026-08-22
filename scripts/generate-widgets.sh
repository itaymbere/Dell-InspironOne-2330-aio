#!/bin/bash

# =========================================================
# generate-widgets.sh
# Auto Widget Generator for Conky
# Dell Inspiron One 2330 AIO
# =========================================================

BASE="/home/rod/.conky/Dell-InspironOne-2330_aio"
TEMP="$BASE/temp"
WIDGETS="$BASE"

mkdir -p "$TEMP"

echo "=================================================="
echo "CONKY AUTO WIDGET GENERATOR"
echo "=================================================="

# =========================================================
# CLEAN OLD AUTO WIDGETS
# =========================================================

find "$WIDGETS" -maxdepth 1 -type f -name "widget-*" -delete

# =========================================================
# CPU CORES
# =========================================================

CPU_CORES=$(nproc)

echo
echo "[+] Generating CPU widgets"

for ((i=0;i<CPU_CORES;i++)); do

cat > "$WIDGETS/widget-cpu-core$i" << EOF
\${cpu cpu$i}%
EOF

done

# =========================================================
# CPU TEMPERATURES
# =========================================================

if grep -q "Core 0" "$TEMP/detected-sensors.txt"; then

    echo "[+] Generating CPU temperature widgets"

    for ((i=0;i<CPU_CORES;i++)); do

cat > "$WIDGETS/widget-cpu-core$i-temp" << EOF
\${execi 2 awk '/Core $i/ {print \$3}' $TEMP/collect-sensors.txt}
EOF

    done

fi

# =========================================================
# CPU PACKAGE
# =========================================================

if grep -q "Package id 0" "$TEMP/detected-sensors.txt"; then

cat > "$WIDGETS/widget-cpu-package-temp" << EOF
\${execi 2 awk '/Package id 0/ {print \$4}' $TEMP/collect-sensors.txt}
EOF

fi

# =========================================================
# CPU FREQUENCY
# =========================================================

cat > "$WIDGETS/widget-cpu-frequency" << EOF
\${freq_g} GHz
EOF

# =========================================================
# CPU LOAD
# =========================================================

cat > "$WIDGETS/widget-cpu-loadavg" << EOF
\${loadavg}
EOF

# =========================================================
# MEMORY
# =========================================================

echo
echo "[+] Generating memory widgets"

cat > "$WIDGETS/widget-memory-ram-used" << EOF
\${mem}
EOF

cat > "$WIDGETS/widget-memory-ram-percent" << EOF
\${memperc}%
EOF

cat > "$WIDGETS/widget-memory-swap-used" << EOF
\${swap}
EOF

cat > "$WIDGETS/widget-memory-swap-percent" << EOF
\${swapperc}%
EOF

# =========================================================
# NETWORK
# =========================================================

echo
echo "[+] Detecting network interfaces"

grep -v LOOPBACK "$TEMP/detected-network.txt" | while read -r line; do

    IFACE=$(echo "$line" | awk '{print $1}')

    if [[ -n "$IFACE" ]]; then

        SAFE_IFACE=$(echo "$IFACE" | tr '.' '_')

        echo "    -> $IFACE"

cat > "$WIDGETS/widget-network-$SAFE_IFACE-ipv4" << EOF
\${addr $IFACE}
EOF

cat > "$WIDGETS/widget-network-$SAFE_IFACE-download" << EOF
\${downspeedf $IFACE} KB/s
EOF

cat > "$WIDGETS/widget-network-$SAFE_IFACE-upload" << EOF
\${upspeedf $IFACE} KB/s
EOF

cat > "$WIDGETS/widget-network-$SAFE_IFACE-totaldown" << EOF
\${totaldown $IFACE}
EOF

cat > "$WIDGETS/widget-network-$SAFE_IFACE-totalup" << EOF
\${totalup $IFACE}
EOF

    fi

done

# =========================================================
# SMART DEVICES
# =========================================================

echo
echo "[+] Detecting SMART devices"

while read -r line; do

    DEV=$(echo "$line" | awk '{print $1}')

    if [[ "$DEV" =~ /dev/ ]]; then

        DEVNAME=$(basename "$DEV")

        echo "    -> $DEVNAME"

cat > "$WIDGETS/widget-disk-$DEVNAME-health" << EOF
\${execi 600 awk '/result/ {print \$6}' $TEMP/collect-smart-health-$DEVNAME.txt}
EOF

cat > "$WIDGETS/widget-disk-$DEVNAME-temperature" << EOF
\${execi 60 awk '/Temperature_Celsius/ {print \$10 "°C"}' $TEMP/collect-smart-$DEVNAME.txt}
EOF

cat > "$WIDGETS/widget-disk-$DEVNAME-poweronhours" << EOF
\${execi 300 awk '/Power_On_Hours/ {print \$10 "h"}' $TEMP/collect-smart-$DEVNAME.txt}
EOF

cat > "$WIDGETS/widget-disk-$DEVNAME-pendingsectors" << EOF
\${execi 300 awk '/Current_Pending_Sector/ {print \$10}' $TEMP/collect-smart-$DEVNAME.txt}
EOF

cat > "$WIDGETS/widget-disk-$DEVNAME-reallocatedsectors" << EOF
\${execi 300 awk '/Reallocated_Sector_Ct/ {print \$10}' $TEMP/collect-smart-$DEVNAME.txt}
EOF

cat > "$WIDGETS/widget-disk-$DEVNAME-crcerrors" << EOF
\${execi 300 awk '/UDMA_CRC_Error_Count/ {print \$10}' $TEMP/collect-smart-$DEVNAME.txt}
EOF

    fi

done < "$TEMP/detected-smart.txt"

# =========================================================
# RADEON GPU
# =========================================================

if [ -f "$TEMP/detected-radeon-pm-info.txt" ]; then

echo
echo "[+] Radeon GPU detected"

cat > "$WIDGETS/widget-gpu-radeon-temperature" << EOF
\${execi 3 awk -F: '/Temperature/ {print \$2}' $TEMP/collect-radeon.txt}
EOF

cat > "$WIDGETS/widget-gpu-radeon-coreclock" << EOF
\${execi 3 awk -F: '/sclk/ {print \$2}' $TEMP/collect-radeon.txt}
EOF

cat > "$WIDGETS/widget-gpu-radeon-memoryclock" << EOF
\${execi 3 awk -F: '/mclk/ {print \$2}' $TEMP/collect-radeon.txt}
EOF

fi

# =========================================================
# THERMAL ZONES
# =========================================================

echo
echo "[+] Generating thermal widgets"

ZONECOUNT=0

while read -r line; do

    if [[ "$line" =~ thermal_zone ]]; then

cat > "$WIDGETS/widget-thermal-zone$ZONECOUNT" << EOF
\${execi 5 awk -F'|' 'NR==$((ZONECOUNT+1)) {print \$3/1000 "°C"}' $TEMP/collect-thermal.txt}
EOF

        ((ZONECOUNT++))

    fi

done < "$TEMP/detected-thermal-zones.txt"

# =========================================================
# FAN SENSORS
# =========================================================

if [ -s "$TEMP/detected-fan-inputs.txt" ]; then

echo
echo "[+] Generating fan widgets"

FANCOUNT=0

while read -r line; do

cat > "$WIDGETS/widget-fan-$FANCOUNT" << EOF
\${execi 3 awk '/fan$((FANCOUNT+1))/ {print \$2 " RPM"}' $TEMP/collect-sensors.txt}
EOF

    ((FANCOUNT++))

done < "$TEMP/detected-fan-inputs.txt"

fi

# =========================================================
# SYSTEM
# =========================================================

echo
echo "[+] Generating system widgets"

cat > "$WIDGETS/widget-system-uptime" << EOF
\${uptime}
EOF

cat > "$WIDGETS/widget-system-kernel" << EOF
\${kernel}
EOF

cat > "$WIDGETS/widget-system-hostname" << EOF
\${nodename}
EOF

cat > "$WIDGETS/widget-system-processes" << EOF
\${processes}
EOF

cat > "$WIDGETS/widget-system-runningprocesses" << EOF
\${running_processes}
EOF

# =========================================================
# SUMMARY
# =========================================================

echo
echo "=================================================="
echo "WIDGET GENERATION COMPLETED"
echo "=================================================="

COUNT=$(find "$WIDGETS" -maxdepth 1 -type f -name "widget-*" | wc -l)

echo
echo "Widgets generated: $COUNT"
echo
echo "Location:"
echo "$WIDGETS"
echo
echo "=================================================="
echo
