#!/usr/bin/env bash
set -euo pipefail

# Require sudo/root
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: this script must be run with sudo or as root." >&2
  exit 1
fi

# Defaults
SWAPFILE="/swapfile"
NEW_SIZE_GB=4   # default new size in GB

usage() {
  cat <<EOF
Usage: $0 [--file PATH] [--size GB]

Options:
  --file PATH   Swap file path (default: /swapfile)
  --size GB     New total swap size in gigabytes (default: 2)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --file) SWAPFILE="$2"; shift 2;;
    --size) NEW_SIZE_GB="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1" >&2; usage; exit 2;;
  esac
done

# Validate NEW_SIZE_GB is integer > 0
if ! [[ "$NEW_SIZE_GB" =~ ^[0-9]+$ ]] || [ "$NEW_SIZE_GB" -le 0 ]; then
  echo "Error: --size must be a positive integer (GB)." >&2
  exit 2
fi

NEW_SIZE_MB=$(( NEW_SIZE_GB * 1024 ))
NEW_SIZE_BYTES=$(( NEW_SIZE_MB * 1024 * 1024 ))

echo "Target swap file: $SWAPFILE"
echo "Target size: ${NEW_SIZE_GB} GB (${NEW_SIZE_MB} MB)"

# If swapfile active, turn off
if swapon --show=NAME | grep -q -F "$SWAPFILE"; then
  echo "Swapfile is active. Turning off swap on $SWAPFILE..."
  swapoff "$SWAPFILE"
fi

# Remove existing swap file if present
if [ -f "$SWAPFILE" ]; then
  echo "Removing existing swap file $SWAPFILE..."
  rm -f -- "$SWAPFILE"
fi

echo "Creating swap file..."
fallocate -l "$NEW_SIZE_BYTES" "$SWAPFILE" 2>/dev/null || dd if=/dev/zero of="$SWAPFILE" bs=1M count="$NEW_SIZE_MB" status=progress

chmod 600 "$SWAPFILE"

echo "Setting up swap area..."
mkswap "$SWAPFILE" >/dev/null

echo "Enabling swap..."
swapon "$SWAPFILE"

echo "Current swap:"
swapon --show

if ! grep -qsF "$SWAPFILE" /etc/fstab; then
  echo
  echo "To make swap persistent across reboots, add this line to /etc/fstab:"
  echo "$SWAPFILE none swap sw 0 0"
fi

echo "Done."
