#!/usr/bin/env bash
# quorum.sh - shows Proxmox cluster quorum status

CRT_GREEN="\e[92m"
RESET="\e[0m"

if command -v pvecm >/dev/null 2>&1; then
  quorum_status=$(pvecm status 2>/dev/null | awk -F': ' '/Quorate/ {print $2}')
  if [[ "$quorum_status" == "Yes" ]]; then
    echo -e "${CRT_GREEN}Cluster Quorum:${RESET} Online"
  else
    echo -e "${CRT_GREEN}Cluster Quorum:${RESET} Offline"
  fi
else
  echo -e "${CRT_GREEN}Cluster Quorum:${RESET} [pvecm not available]"
fi
