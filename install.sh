#!/usr/bin/env bash
# Base setup: labwc desktop, apps, audio, configs and services.
# Safe to run again; it only installs what's missing.
# Gaming and GPU drivers live in gaming.sh.
set -euo pipefail

source "$(dirname "$0")/scripts/lib.sh"
require_arch_user
keep_sudo

# --- 0. Correct clock ---
# Downloads fail ("certificate is not yet valid") if the clock is wrong. That
# happens after rolling a VM back to a snapshot that includes its memory: the
# clock resumes at the snapshot's time and still claims to be synced. So
# compare against a web server's clock, fix it if it's off, then keep syncing.
info "Checking the clock..."
web_time="$(curl -sI --max-time 10 http://archlinux.org | sed -n 's/^[Dd]ate: //p' | tr -d '\r')"
if [[ -n "$web_time" ]]; then
    drift=$(( $(date -d "$web_time" +%s) - $(date +%s) ))
    if (( ${drift#-} > 60 )); then
        warn "Clock was off by ${drift#-} seconds; fixing it."
        sudo date -s "$web_time" >/dev/null
    fi
else
    warn "Couldn't check the clock online; if downloads fail with a certificate error, fix the time and run this again."
fi
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd 2>/dev/null || true

# --- 1. Official packages ---
# SkorneX uses PipeWire for sound. If archinstall set up PulseAudio or JACK
# instead, remove them first: they conflict with PipeWire's replacements and
# the install would stop.
mapfile -t old_audio < <(pacman -Qq pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-jack \
    pulseaudio-equalizer pulseaudio-zeroconf pulseaudio-lirc pulseaudio-rtp jack2 2>/dev/null || true)
if ((${#old_audio[@]})); then
    info "Replacing ${old_audio[*]} with PipeWire..."
    sudo pacman -Rdd --noconfirm "${old_audio[@]}"
fi

mapfile -t pkgs < <(read_list "$REPO_DIR/packages/pkglist.txt")
# Updating SkorneX from the Updates module (SKORNEX_ONLY=1) leaves your other
# apps alone: "Install updates" is for those. Only when SkorneX needs a new
# package is a full update unavoidable (Arch doesn't support installing new
# packages without updating the rest).
mapfile -t missing < <(pacman -T "${pkgs[@]}" || true)
if [[ -z "${SKORNEX_ONLY:-}" ]] || ((${#missing[@]})); then
    info "Updating system and installing base packages..."
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
fi

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
    (cd "$tmp/paru" && makepkg -sir --noconfirm)   # -r: drop build-only tools (Rust) after
    rm -rf "$tmp"
fi

# --- 3. AUR packages ---
mapfile -t aur < <(read_list "$REPO_DIR/packages/aurlist.txt")
if ((${#aur[@]})); then
    info "Installing AUR packages..."
    paru -S --needed --noconfirm "${aur[@]}"
fi

# --- 3b. Packages SkorneX no longer uses ---
mapfile -t old < <(read_list "$REPO_DIR/packages/removelist.txt")
for pkg in "${old[@]}"; do
    if pacman -Qq "$pkg" &>/dev/null; then
        info "Removing $pkg (no longer used)..."
        sudo pacman -Rns --noconfirm "$pkg" || warn "Couldn't remove $pkg; something else still needs it."
    fi
done

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
find "$HOME/.config" "$HOME/.local" -xtype l \( -lname '*LinuxSetup/dotfiles/*' -o -lname '*LinuxSetup/modules/*' \) \
    -delete 2>/dev/null || true
# An icon cache left here by another app (Steam, Wine…) hides the SkorneX
# icons from labwc, which then shows its own logo in the title bar. Without a
# cache, labwc and GTK read the folder directly.
rm -f "$HOME/.local/share/icons/hicolor/icon-theme.cache"

# --- 4b. Settings modules ---
# Each one (Display, Sound, Mouse...) is its own small app; see modules/ and
# skornex-module. This updates the ones you have and adds the ones picked
# during setup (SKORNEX_MODULES, from bootstrap.sh).
mapfile -t modules < <("$HOME/.local/bin/skornex-module" installed)
read -ra wanted <<<"${SKORNEX_MODULES:-}"
modules+=("${wanted[@]}")
if ((${#modules[@]})); then
    info "Installing settings modules: ${modules[*]}"
    "$HOME/.local/bin/skornex-module" add "${modules[@]}"
fi

# --- 4c. Window manager settings ---
# labwc's rc.xml and environment are built from SkorneX's base files plus the
# changes Settings modules saved (skornex-labwc).
"$HOME/.local/bin/skornex-labwc" --no-reload

# --- 5. Colors ---
info "Applying colors..."
"$HOME/.local/bin/skornex-theme"

# --- 5b. Reload the running desktop ---
# Works over SSH too. labwc rereads its settings and its app list on SIGHUP
# (without that, new apps get labwc's own logo as their title bar icon until
# you log out), and SkorneXBar and SkorneXDesktop restart with the new code.
if pgrep -x -u "$USER" labwc >/dev/null; then
    info "Reloading the desktop..."
    pkill -HUP -x -u "$USER" labwc
    pkill -u "$USER" -f '\.local/bin/skornex-bar( desktop)?$' || true
fi

# --- 6. Boot straight to the lock screen ---
# greetd logs you in once at boot and starts labwc with LOCK_ON_START set, so
# the first thing you see is hyprlock. After logging out you get a plain text
# login (agreety) instead.
info "Setting up login..."
sudo install -Dm755 "$REPO_DIR/system/skornex-session" /usr/local/bin/skornex-session
# Apps like Files open files through skornex-open (Notepad uses it to come to
# the front). A copy here works even where ~/.local/bin isn't on PATH.
sudo install -Dm755 "$REPO_DIR/dotfiles/bin/.local/bin/skornex-open" /usr/local/bin/skornex-open
sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[initial_session]
command = "env LOCK_ON_START=1 skornex-session"
user = "$USER"

[default_session]
command = "agreety --cmd skornex-session"
user = "greeter"
EOF

# --- 6b. Default apps ---
# Notepad (Mousepad) opens notes and other text files. Scripts (.sh) keep
# their normal behavior; an earlier SkorneX version sent them to Notepad too.
xdg-mime default org.xfce.mousepad.desktop text/plain text/markdown text/x-markdown \
    application/json text/x-log
sed -i '/^\(application\|text\)\/x-shellscript=org.xfce.mousepad.desktop/d' "$HOME/.config/mimeapps.list" 2>/dev/null || true

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
# NetworkManager runs the network from the next boot on. If archinstall set up
# a different network service, turn it off then so they don't fight. It keeps
# running until the restart, so the install doesn't lose its connection.
for svc in systemd-networkd.service iwd.service dhcpcd.service; do
    if systemctl is-enabled -q "$svc" 2>/dev/null; then
        info "Switching from $svc to NetworkManager after the restart..."
        sudo systemctl disable "$svc"
    fi
done
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
    || warn "Couldn't enable PipeWire user services now; they normally start on their own at login."

# Remember what's installed (not just downloaded), for the Updates module:
# the version, then the exact commit.
mkdir -p "$HOME/.local/share/skornex"
printf '%s\n%s\n' "$(cat "$REPO_DIR/VERSION")" "$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null)" \
    > "$HOME/.local/share/skornex/installed"

echo
info "SkorneX $(cat "$REPO_DIR/VERSION") is installed."
# On a first install from a text console (not through bootstrap.sh, which
# restarts by itself), say how to get to the desktop.
if [[ -z "${SKORNEX_BOOTSTRAP:-}" ]] && ! pgrep -x -u "$USER" labwc >/dev/null; then
    echo "Restart to start SkorneX:  sudo reboot"
fi
