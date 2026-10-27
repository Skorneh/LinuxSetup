#!/usr/bin/env bash
# Base setup: KDE Plasma desktop, apps, audio, configs and services.
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
if ! command -v paru >/dev/null; then
    info "Installing paru..."
    tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
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

# --- 5. Login screen theme ---
info "Setting the SDDM login screen to Breeze..."
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=breeze\n' | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null

# --- 6. Firefox debloat ---
# Turns off Pocket, sponsored content, telemetry, studies and the AI sidebar.
# Every setting stays changeable in Firefox. Check it at about:policies.
info "Installing the Firefox policy file..."
sudo install -Dm644 "$REPO_DIR/system/firefox-policies.json" /etc/firefox/policies/policies.json

# --- 7. Helper commands ---
sudo install -Dm755 "$REPO_DIR/system/screenshot-full" /usr/local/bin/screenshot-full

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
sudo systemctl enable NetworkManager.service sddm.service
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
    || warn "Couldn't enable PipeWire user services now; they normally start on their own at login."

echo
info "Base setup done."
cat <<EOF
Next steps:
  1. Reboot:  sudo reboot
  2. Log in to "Plasma (Wayland)" on the login screen.
  3. Open Konsole and run:  $REPO_DIR/kde-setup.sh
  4. On the real PC only:   $REPO_DIR/gaming.sh
EOF
