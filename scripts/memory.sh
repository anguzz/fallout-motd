#!/usr/bin/env bash
# memory.sh - shows memory usage

CRT_GREEN="\e[92m"
RESET="\e[0m"

mem_total=$(free -h | awk '/Mem:/ {print $2}')
mem_used=$(free -h | awk '/Mem:/ {print $3}')
mem_free=$(free -h | awk '/Mem:/ {print $4}')

echo -e "${CRT_GREEN}Memory:${RESET} $mem_used / $mem_total (Free: $mem_free)"
