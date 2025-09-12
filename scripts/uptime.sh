#!/usr/bin/env bash
# uptime.sh - shows system uptime and load average

CRT_GREEN="\e[92m"
RESET="\e[0m"

uptime_info=$(uptime -p | sed 's/up //')
load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)

echo -e "${CRT_GREEN}Uptime:${RESET} $uptime_info"
echo -e "${CRT_GREEN}Load Avg:${RESET} $load_avg"
