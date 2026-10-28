#!/usr/bin/env bash
# Base setup: labwc desktop, apps, audio, configs and services.
# Safe to run again; it only installs what's missing.
# Gaming and GPU drivers live in gaming.sh (real PC only).
set -euo pipefail

source "$(dirname "$0")/scripts/lib.sh"
require_arch_user

# --- 1. Official packages ---
info "Updating system and installing base packages..."
mapfile -t pkgs < <(read_list "$REPO_DIR/packages/pkglist.txt")
sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"

# --- 2. paru (AUR helper) ---
# Built from source. The prebuilt paru-bin can lag behind pacman and then
# fails with "libalpm.so.15: cannot open shared object file", so a paru that
# won't start gets replaced too.
if ! paru --version >/dev/null 2>&1; then
    for old in paru-bin-debug paru-bin; do
        if pacman -Qq "$old" &>/dev/null; then sudo pacman -Rns --noconfirm "$old"; fi
    done
    info "Installing paru (compiles from source, takes a few minutes)..."
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru.git "$tmp/paru"
    (cd "$tmp/paru" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

# --- 3. AUR packages ---
mapfile -t aur < <(read_list "$REPO_DIR/packages/aurlist.txt")
if ((${#aur[@]})); then
    info "Installing AUR packages..."
    paru -S --needed --noconfirm "${aur[@]}"
fi

# --- 4. Dotfiles ---
# Every folder in dotfiles/ is a stow package whose contents mirror $HOME.
# Existing files that would block a symlink are moved to ~/.dotfiles-backup.
info "Linking dotfiles..."
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
for pkg_dir in "$REPO_DIR"/dotfiles/*/; do
    pkg="$(basename "$pkg_dir")"
    while IFS= read -r -d '' file; do
        rel="${file#"$pkg_dir"}"
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]]; then
            mkdir -p "$backup/$(dirname "$rel")"
            mv "$target" "$backup/$rel"
            warn "Moved existing ~/$rel to $backup/"
        fi
    done < <(find "$pkg_dir" -type f -print0)
    stow --dir="$REPO_DIR/dotfiles" --target="$HOME" --no-folding --restow "$pkg"
done
# Remove links left behind by files that were deleted from the repo.
find "$HOME/.config" "$HOME/.local" -xtype l -lname '*LinuxSetup/dotfiles/*' -delete 2>/dev/null || true

# --- 5. Colors ---
info "Applying colors..."
"$HOME/.local/bin/skornex-theme"

# --- 6. Boot straight to the lock screen ---
# greetd logs you in once at boot and starts labwc with LOCK_ON_START set, so
# the first thing you see is hyprlock. After logging out you get a plain text
# login (agreety) instead.
info "Setting up login..."
sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[initial_session]
command = "env LOCK_ON_START=1 labwc"
user = "$USER"

[default_session]
command = "agreety --cmd labwc"
user = "greeter"
EOF

# --- 7. Firefox debloat ---
# Turns off Pocket, sponsored content, telemetry, studies and the AI sidebar.
# Every setting stays changeable in Firefox. Check it at about:policies.
info "Installing the Firefox policy file..."
sudo install -Dm644 "$REPO_DIR/system/firefox-policies.json" /etc/firefox/policies/policies.json

# --- 8. Proxmox/QEMU guest agent (VMs only) ---
# Lets Proxmox shut the VM down cleanly and show its IP address.
if [[ "$(systemd-detect-virt 2>/dev/null || true)" == kvm ]]; then
    info "Running in a KVM/Proxmox VM: installing the guest agent..."
    sudo pacman -S --needed --noconfirm qemu-guest-agent
    sudo systemctl start qemu-guest-agent.service \
        || warn "Guest agent didn't start. Turn on \"QEMU Guest Agent\" in the VM's Options in Proxmox."
fi

# --- 9. Services ---
info "Enabling services..."
sudo systemctl enable NetworkManager.service greetd.service
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
    || warn "Couldn't enable PipeWire user services now; they normally start on their own at login."

echo
info "Base setup done."
cat <<EOF
Next steps:
  1. Reboot:  sudo reboot
  2. The PC starts at your lock screen. Type your password.
  3. On the real PC only:   $REPO_DIR/gaming.sh
EOF
