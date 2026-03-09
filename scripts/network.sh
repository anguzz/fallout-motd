#!/usr/bin/env bash

echo "=== NETWORK STATUS ==="
printf "%-12s %-8s %-16s %-10s %-10s\n" "Interface" "State" "IP Address" "RX" "TX"
echo "-------------------------------------------------------------"

for path in /sys/class/net/*; do
    iface=$(basename "$path")

    # Skip non-interface entries and noisy Proxmox devices
    case "$iface" in
        bonding_masters|tap*|fwbr*|fwln*|fwpr*)
            continue
            ;;
    esac

    # Skip if required files do not exist
    [ ! -f "$path/operstate" ] && continue
    [ ! -f "$path/statistics/rx_bytes" ] && continue
    [ ! -f "$path/statistics/tx_bytes" ] && continue

    state=$(<"$path/operstate")

    ip=$(ip -4 -o addr show "$iface" | awk '{print $4}' | cut -d/ -f1)
    [ -z "$ip" ] && ip="-"

    rx=$(<"$path/statistics/rx_bytes")
    tx=$(<"$path/statistics/tx_bytes")

    rx_h=$(numfmt --to=iec "$rx")
    tx_h=$(numfmt --to=iec "$tx")

    printf "%-12s %-8s %-16s %-10s %-10s\n" "$iface" "$state" "$ip" "$rx_h" "$tx_h"
done

echo