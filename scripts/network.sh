#!/usr/bin/env bash

echo "=== NETWORK STATUS ==="
printf "%-12s %-8s %-18s %-10s %-10s\n" "Interface" "State" "IP Address" "RX" "TX"
echo "-----------------------------------------------------------------"

for iface_path in /sys/class/net/*; do
    iface=$(basename "$iface_path")

    # Skip non-standard entries
    [[ ! -d "$iface_path" ]] && continue
    [[ ! -f "$iface_path/operstate" ]] && continue
    [[ ! -f "$iface_path/statistics/rx_bytes" ]] && continue
    [[ ! -f "$iface_path/statistics/tx_bytes" ]] && continue

    state=$(<"$iface_path/operstate")

    ip=$(ip -4 -o addr show dev "$iface" | awk '{print $4}' | cut -d/ -f1)
    [[ -z "$ip" ]] && ip="-"

    rx=$(<"$iface_path/statistics/rx_bytes")
    tx=$(<"$iface_path/statistics/tx_bytes")

    rx_h=$(numfmt --to=iec-i --suffix=B "$rx" 2>/dev/null || echo "${rx}B")
    tx_h=$(numfmt --to=iec-i --suffix=B "$tx" 2>/dev/null || echo "${tx}B")

    printf "%-12s %-8s %-18s %-10s %-10s\n" "$iface" "$state" "$ip" "$rx_h" "$tx_h"
done

echo