#!/usr/bin/env bash

CRT_GREEN="\e[92m"
RESET="\e[0m"

#  values from free -h (human readable)
mem_total=$(free -h | awk '/Mem:/ {print $2}')
mem_used=$(free -h | awk '/Mem:/ {print $3}')
mem_free=$(free -h | awk '/Mem:/ {print $4}')

# gets percentage used (integer, like "free" reports)
mem_perc=$(free | awk '/Mem:/ {printf "%d", ($3/$2)*100}')

echo -e "${CRT_GREEN}Memory:${RESET} $mem_used / $mem_total (Free: $mem_free) (${mem_perc}%)"

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

draw_bar "$mem_perc" 30

