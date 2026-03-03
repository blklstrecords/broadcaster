#!/usr/bin/env bash
set -euo pipefail

echo "This will remove the BLKLST broadcaster service, files, and user."
read -rp "Are you sure you want to continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 1
fi

# Stop and disable services/timers
sudo systemctl disable --now broadcaster.service || true
sudo systemctl disable --now dns-update.timer || true
sudo systemctl disable --now dns-update.service || true
sudo systemctl daemon-reload

# Remove systemd unit files
sudo rm -f /etc/systemd/system/broadcaster.service
sudo rm -f /etc/systemd/system/dns-update.service
sudo rm -f /etc/systemd/system/dns-update.timer
sudo systemctl daemon-reload

# Remove installed files and directories
sudo rm -rf /opt/broadcaster
sudo rm -rf /etc/broadcaster

# Remove the dedicated user (if not used elsewhere)
if id -u broadcaster >/dev/null 2>&1; then
	sudo userdel broadcaster || true
fi

echo "Uninstall complete."
