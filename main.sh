#!/usr/bin/env bash
# Fallout MOTD - main.sh

# ----- Safety & env -----
# Require bash (dash/sh will break functions)
if [ -z "${BASH_VERSINFO:-}" ]; then
  echo "This script must be run with bash. Use: bash ./main.sh"
  exit 1
fi
export LANG="${LANG:-C.UTF-8}"

#!/usr/bin/env bash
# Fallout MOTD - main.sh

# -----------------------------
# Settings
# -----------------------------
# Resolve the directory of this script, even if called via symlink

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
MOTD_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CONFIG_FILE="$MOTD_DIR/config.json"
SCRIPTS_DIR="$MOTD_DIR/scripts"

# CRT green
CRT_GREEN='\033[92m'
RESET='\033[0m'

# Symbols (Unicode)
RAD=$'\u2622'    # ☢
WARN=$'\u26A0'   # ⚠
CHECK=$'\u2714'  # ✔
CROSS=$'\u2716'  # ✖

# ----- Functions -----
draw_header() {
  printf "%b" "${CRT_GREEN}"
  cat <<'EOF'
    ____  _       __                   _____ ____  ____  ____ 
   / __ \(_)___  / /_  ____  __  __   |__  // __ \/ __ \/ __ \
  / /_/ / / __ \/ __ \/ __ \/ / / /    /_ </ / / / / / / / / /
 / ____/ / /_/ / /_/ / /_/ / /_/ /   ___/ / /_/ / /_/ / /_/ / 
/_/   /_/ .___/_.___/\____/\__, /   /____/\____/\____/\____/  
       /_/                /____/                              
       VAULT-TEC TERMINAL SYSTEM
EOF
  printf "\t☢\t☢\t☢\t☢\t☢\t☢\t☢\n"
  printf "%b" "${RESET}"
}

list_modules() {
  # Prefer config.json via jq; otherwise run all *.sh in scripts/
  if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
    jq -r '.modules[] | select(.enabled==true) | .name' "$CONFIG_FILE"
  elif [ -d "$SCRIPTS_DIR" ]; then
    find "$SCRIPTS_DIR" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' \
      | sed 's/\.sh$//' | sort
  fi
}

run_module() {
  local module="$1"
  local script="${SCRIPTS_DIR}/${module}.sh"
  if [ -x "$script" ]; then
    printf "%b%s %s %s%b\n" "${CRT_GREEN}" "${RAD}" "${module^^}" "${RAD}" "${RESET}"
    "$script" || printf "%b${WARN}[WARN]%b Module '%s' exited non-zero.\n" "${CRT_GREEN}" "${RESET}" "$module"
    printf "\n"
  else
    printf "%b${WARN}[WARN]%b Module '%s' not found or not executable.\n" "${CRT_GREEN}" "${RESET}" "$module"
  fi
}

# ----- Main -----
main() {
  # TERM can be empty in PVE login hooks; set a safe default
  : "${TERM:=xterm-256color}"
  command -v tput >/dev/null 2>&1 && tput cols >/dev/null 2>&1 && clear || true

  draw_header
  printf "%bSystem Status: Nominal%b\n\n" "${CRT_GREEN}" "${RESET}"

  if [ ! -d "$SCRIPTS_DIR" ]; then
    printf "%b${WARN}[WARN]%b Scripts directory missing: %s\n" "${CRT_GREEN}" "${RESET}" "$SCRIPTS_DIR"
    return 0
  fi

  # Build module array
  mapfile -t MODULES < <(list_modules || true)

  if [ "${#MODULES[@]}" -eq 0 ]; then
    printf "%b${WARN}[WARN]%b No modules found/enabled.\n" "${CRT_GREEN}" "${RESET}"
    return 0
  fi

  for module in "${MODULES[@]}"; do
    run_module "$module"
  done
}

main "$@"
