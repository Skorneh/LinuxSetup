#!/usr/bin/env bash
# Gaming setup for the real PC: [multilib], GPU drivers, Steam, Lutris,
# GameMode and MangoHud. Run after install.sh. Safe to run again.
set -euo pipefail

source "$(dirname "$0")/scripts/lib.sh"
require_arch_user

virt="$(systemd-detect-virt 2>/dev/null || true)"
if [[ -n "$virt" && "$virt" != none ]]; then
    warn "This looks like a VM ($virt). Gaming and GPU drivers only make sense on real hardware."
    confirm "Continue anyway?" || exit 0
fi

# --- 1. Enable [multilib] (32-bit libraries Steam and Wine need) ---
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    info "Enabling the [multilib] repo..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi
sudo pacman -Syu --noconfirm

# --- 2. GPU drivers ---
gpus="$(lspci -d ::0300; lspci -d ::0302; lspci -d ::0380)"
drivers=()
aur_drivers=()

if grep -qi nvidia <<<"$gpus"; then
    info "NVIDIA GPU detected."
    # GTX 10-series and older aren't supported by the current driver;
    # they need the 580xx legacy branch from the AUR.
    if grep -Eqi 'GTX (9[0-9]{2}|10[0-9]{2}|7[0-9]{2})|TITAN X|Quadro P' <<<"$gpus"; then
        warn "Older NVIDIA card (GTX 10-series or earlier). Using the legacy 580xx driver from the AUR."
        aur_drivers+=(nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
    else
        drivers+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings)
    fi
    # DKMS builds the driver for every installed kernel, so each needs headers.
    for kernel in linux linux-lts linux-zen; do
        pacman -Q "$kernel" &>/dev/null && drivers+=("$kernel-headers")
    done
fi
if grep -Eqi '\b(AMD|ATI)\b|Advanced Micro Devices' <<<"$gpus"; then
    info "AMD GPU detected."
    drivers+=(mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon)
fi
if grep -qi intel <<<"$gpus"; then
    info "Intel GPU detected."
    drivers+=(mesa lib32-mesa vulkan-intel lib32-vulkan-intel)
fi
((${#drivers[@]} + ${#aur_drivers[@]})) || warn "No NVIDIA, AMD or Intel GPU found. Skipping drivers."

echo "Your GPU(s):"
echo "$gpus" | sed 's/^/    /'
echo "Driver packages: ${drivers[*]:-none} ${aur_drivers[*]:-}"
confirm "Install these drivers?" || die "Stopped before installing drivers."

((${#drivers[@]})) && sudo pacman -S --needed --noconfirm "${drivers[@]}"
((${#aur_drivers[@]})) && paru -S --needed --noconfirm "${aur_drivers[@]}"

# --- 3. Gaming packages ---
info "Installing Steam, Lutris, GameMode and MangoHud..."
mapfile -t pkgs < <(read_list "$REPO_DIR/packages/gaming.txt")
sudo pacman -S --needed --noconfirm "${pkgs[@]}"

# Let the GameMode daemon adjust CPU settings without a password prompt.
sudo usermod -aG gamemode "$USER"

echo
info "Gaming setup done. Reboot so the GPU driver loads."
cat <<EOF
After rebooting:
  - Steam: open it, then Settings > Compatibility > "Enable Steam Play for all other titles".
  - WoW:   open Lutris, search "Battle.net", install it, log in, install WoW.
  - Optional: in Lutris, set Battle.net's launch options to use GameMode and MangoHud.
  - To pin an app to the taskbar: right-click it in the Start menu > Pin to Task Manager.
EOF
