#!/usr/bin/env bash
set -euo pipefail

# update package index and install runtime dependencies
sudo apt update
sudo apt install -y ffmpeg curl jq locales

# create a dedicated system account for the broadcaster service if it doesn't exist
# this user will own the installation directories and will be used by the systemd units
if ! id -u broadcaster >/dev/null 2>&1; then
  sudo useradd --system --no-create-home \
    --shell /usr/sbin/nologin \
    --comment "Broadcaster service account" \
    broadcaster
fi

# prepare directories with restrictive permissions
sudo mkdir -p /opt/broadcaster/bin
sudo mkdir -p /etc/broadcaster

# make sure the service account owns the program directory and has execute access
sudo chown -R broadcaster:broadcaster /opt/broadcaster
sudo chmod -R 750 /opt/broadcaster

# configuration directory should be writable only by root but readable by the
# broadcaster group so the unprivileged service can load the environment file
sudo chown -R root:broadcaster /etc/broadcaster
sudo chmod 750 /etc/broadcaster

# install helper scripts
sudo cp -f bin/*.sh /opt/broadcaster/bin/
sudo chmod +x /opt/broadcaster/bin/*.sh

# default environment, keep it owned by root with group access for broadcaster
if [[ ! -f /etc/broadcaster/broadcaster.env ]]; then
  sudo cp etc/broadcaster.env.example /etc/broadcaster/broadcaster.env
  sudo chmod 640 /etc/broadcaster/broadcaster.env
  sudo chown root:broadcaster /etc/broadcaster/broadcaster.env
fi

# copy systemd unit files; they should already reference the broadcaster user
sudo cp -f systemd/*.service /etc/systemd/system/
sudo cp -f systemd/*.timer /etc/systemd/system/ || true

sudo systemctl daemon-reload
sudo systemctl enable --now broadcaster.service
sudo systemctl enable --now dns-update.timer

echo "Installed. Edit: sudo nano /etc/broadcaster/broadcaster.env"