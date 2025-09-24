#!/usr/bin/env bash
# storage.sh - shows disk usage of root filesystem (matches df output)

CRT_GREEN="\e[92m"
RESET="\e[0m"

# Grab info directly from df
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_total=$(df -h / | awk 'NR==2 {print $2}')
disk_perc=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

echo -e "${CRT_GREEN}Disk Usage:${RESET} $disk_used / $disk_total (${disk_perc}%)"

# --- progress bar ---
draw_bar() {
  local percent=$1
  local width=${2:-30}

  local fill=$(( percent * width / 100 ))
  local empty=$(( width - fill ))

  printf "["
  for ((i=0; i<fill; i++)); do
    printf "%b█%b" "$CRT_GREEN" "$RESET"
  done
  for ((i=0; i<empty; i++)); do
    printf " "
  done
  printf "] %s%%\n" "$percent"
}

draw_bar "$disk_perc" 30

