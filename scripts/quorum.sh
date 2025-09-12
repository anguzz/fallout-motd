#!/usr/bin/env bash
# quorum.sh - Show Proxmox cluster quorum status

CRT_GREEN="\e[92m"
RESET="\e[0m"

if command -v pvecm >/dev/null 2>&1; then
  # Only grab the *first* Quorate line (avoid Flags: Quorate)
  quorum_status=$(pvecm status 2>/dev/null | grep -m1 -i "^Quorate" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')

  case "$quorum_status" in
    yes)
      echo -e "${CRT_GREEN}Cluster Quorum:${RESET} Online"
      ;;
    no)
      echo -e "${CRT_GREEN}Cluster Quorum:${RESET} Offline"
      ;;
    *)
      echo -e "${CRT_GREEN}Cluster Quorum:${RESET} Unknown"
      ;;
  esac
else
  echo -e "${CRT_GREEN}Cluster Quorum:${RESET} [pvecm not available]"
fi
