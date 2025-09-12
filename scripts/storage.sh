#!/usr/bin/env bash
# storage.sh - shows disk usage of root filesystem

CRT_GREEN="\e[92m"
RESET="\e[0m"

disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_perc=$(df -h / | awk 'NR==2 {print $5}')

echo -e "${CRT_GREEN}Disk Usage:${RESET} $disk_used / $disk_total ($disk_perc)"
