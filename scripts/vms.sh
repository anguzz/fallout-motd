#!/usr/bin/env bash
# vms.sh - shows running Proxmox VMs

CRT_GREEN="\e[92m"
RESET="\e[0m"

if command -v qm >/dev/null 2>&1; then
  vm_count=$(qm list | awk 'NR>1 && $3=="running"' | wc -l)
  echo -e "${CRT_GREEN}Running VMs:${RESET} $vm_count"
else
  echo -e "${CRT_GREEN}Running VMs:${RESET} [qm not available]"
fi
