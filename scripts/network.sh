#!/usr/bin/env bash

echo "=== NETWORK STATUS ==="

printf "%-12s %-6s %-16s %-10s %-10s\n" "Interface" "State" "IP Address" "RX" "TX"
echo "-------------------------------------------------------------"

for iface in $(ls /sys/class/net); do

    state=$(cat /sys/class/net/$iface/operstate)

    ip=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)

    [ -z "$ip" ] && ip="-"

    rx=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$iface/statistics/tx_bytes)

    rx_h=$(numfmt --to=iec $rx)
    tx_h=$(numfmt --to=iec $tx)

    printf "%-12s %-6s %-16s %-10s %-10s\n" "$iface" "$state" "$ip" "$rx_h" "$tx_h"

done

echo