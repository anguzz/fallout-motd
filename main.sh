#!/usr/bin/env bash
#
# Fallout MOTD - main.sh
# Entry script to generate a Pip-Boy style MOTD for Proxmox/Debian hosts
#

# -----------------------------
# Settings
# -----------------------------
MOTD_DIR="$(dirname "$0")"
CONFIG_FILE="$MOTD_DIR/config.json"
SCRIPTS_DIR="$MOTD_DIR/scripts"

# ANSI green (bright CRT look)
CRT_GREEN="\e[92m"
RESET="\e[0m"

# Symbols
RAD="\u2622"   # ☢
CHECK="\u2714" # ✔
CROSS="\u2716" # ✖
WARN="\u26A0"  # ⚠

# -----------------------------
# Functions
# -----------------------------

# Draw Pip-Boy style header
draw_header() {
  echo -e "${CRT_GREEN}"
  cat <<'EOF'
    ____  _       __                   _____ ____  ____  ____ 
   / __ \(_)___  / /_  ____  __  __   |__  // __ \/ __ \/ __ \
  / /_/ / / __ \/ __ \/ __ \/ / / /    /_ </ / / / / / / / / /
 / ____/ / /_/ / /_/ / /_/ / /_/ /   ___/ / /_/ / /_/ / /_/ / 
/_/   /_/ .___/_.___/\____/\__, /   /____/\____/\____/\____/  
       /_/                /____/                              
       VAULT-TEC TERMINAL SYSTEM
EOF
  echo -e "\n"
  echo -e "\t☢\t☢\t☢\t☢\t☢\t☢\t☢"
  echo -e "${RESET}"
}



# Load modules
load_modules() {
  jq -r '.modules[] | select(.enabled==true) | .name' "$CONFIG_FILE" 2>/dev/null
}

# Run a module safely with Fallout-style separator
run_module() {
  local module="$1"
  local script="$SCRIPTS_DIR/$module.sh"

  if [[ -x "$script" ]]; then
    echo -e "${CRT_GREEN}${RAD} ${module^^} ${RAD}${RESET}"   # ☢ UPTIME ☢
    "$script"
    echo ""
  else
    echo -e "${CRT_GREEN}${WARN}[WARN]${RESET} Module '$module' not found or not executable."
  fi
}

# -----------------------------
# Main 
# -----------------------------
clear
draw_header
echo -e "${CRT_GREEN}System Status: Nominal${RESET}\n"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo -e "${CRT_GREEN}${CROSS}[ERROR]${RESET} Config file not found: $CONFIG_FILE"
  exit 1
fi

for module in $(load_modules); do
  run_module "$module"
done
