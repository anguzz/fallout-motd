#!/usr/bin/env bash
# install.sh - Setup Fallout MOTD into system login

MOTD_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="/etc/update-motd.d/10-fallout-motd"

echo "[*] Installing Fallout MOTD..."

#  dependencies
if ! command -v jq >/dev/null 2>&1; then
  echo "[-] Missing dependency: jq. Installing..."
  apt-get update && apt-get install -y jq
fi

# get rid of old symlink if exists
if [ -L "$TARGET" ] || [ -f "$TARGET" ]; then
  echo "[*] Removing existing MOTD entry..."
  rm -f "$TARGET"
fi

# create symlink
ln -s "$MOTD_DIR/main.sh" "$TARGET"
chmod +x "$MOTD_DIR/main.sh"

echo "[+] Fallout MOTD installed successfully!"
echo "[i] Test with: run-parts /etc/update-motd.d/"
