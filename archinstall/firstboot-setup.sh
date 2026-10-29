#!/usr/bin/env bash
# Runs once at the end of archinstall (its custom_commands), inside the new
# system, after your user account exists. It puts the repo in your home folder
# and turns on skornex-firstboot.service, which runs install.sh on the first
# boot and then restarts into the SkorneX lock screen.
set -euo pipefail

src="$(cd "$(dirname "$0")/.." && pwd)"
user="$(awk -F: '$3 >= 1000 && $3 < 60000 { print $1; exit }' /etc/passwd)"
if [[ -z "$user" ]]; then
    echo "SkorneX: no user account found, so first-boot setup is skipped." >&2
    exit 0
fi
home="$(getent passwd "$user" | cut -d: -f6)"

if [[ ! -d "$home/LinuxSetup" ]]; then
    cp -a "$src" "$home/LinuxSetup"
    chown -R "$user:$user" "$home/LinuxSetup"
fi

install -Dm755 "$src/archinstall/skornex-firstboot" /usr/local/bin/skornex-firstboot
cat > /etc/systemd/system/skornex-firstboot.service <<EOF
[Unit]
Description=SkorneX first-boot setup
Wants=network-online.target
After=network-online.target NetworkManager.service
# Hold the text login back until setup is done; progress shows on screen.
Before=getty@tty1.service
ConditionPathExists=/var/lib/skornex-firstboot

[Service]
Type=oneshot
ExecStart=/usr/local/bin/skornex-firstboot $user
StandardInput=null
StandardOutput=tty
StandardError=tty
TTYPath=/dev/tty1
TimeoutStartSec=90min

[Install]
WantedBy=multi-user.target
EOF
mkdir -p /var/lib
touch /var/lib/skornex-firstboot
systemctl enable skornex-firstboot.service
echo "SkorneX: first-boot setup is ready for $user."
