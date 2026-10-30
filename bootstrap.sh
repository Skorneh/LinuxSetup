#!/usr/bin/env bash
# One command to set up SkorneX on a fresh Arch install. Log in as your user
# on the text console and run:
#
#   curl -fsSL https://raw.githubusercontent.com/Skorneh/LinuxSetup/main/bootstrap.sh | bash
#
# It asks its questions first (gaming, settings modules, your password), then runs
# without needing you: installs git, downloads this repo to ~/LinuxSetup, runs
# install.sh (and gaming.sh if you said yes), and restarts into SkorneX.
set -euo pipefail

# Everything is inside main, so a half-downloaded script never runs.
main() {
    local repo=https://github.com/Skorneh/LinuxSetup.git
    local dir="$HOME/LinuxSetup"
    local reply gaming=0 modules=""

    if [[ $EUID -eq 0 ]]; then
        echo "Run this as your normal user, not root. It uses sudo when needed." >&2
        exit 1
    fi

    echo "=== SkorneX setup ==="
    echo "A few questions, then it runs by itself (10-30 minutes) and restarts"
    echo "into SkorneX when it's done."
    echo
    # The script itself arrives through the pipe, so everything that reads
    # the keyboard reads from the terminal instead.
    read -rp "Also install gaming (graphics drivers, Steam, Lutris, Discord)? [y/N] " reply </dev/tty
    if [[ "$reply" =~ ^[Yy] ]]; then gaming=1; fi
    echo
    cat <<'EOF'
Settings modules. Each one is its own small app; pick only the ones you want
(you can add or remove them later in Settings):
  display      Resolution, refresh rate, scale, monitor layout
  sound        Speakers, headphones, microphone, each app's volume
  power        Lock, screen off and sleep times; power button and lid
  mouse        Pointer speed, scrolling, button swap, touchpad
  keyboard     Keyboard layouts (languages), key repeat, Num Lock
  shortcuts    Change, turn off or add keyboard shortcuts
  personalize  Color themes, accent color, wallpaper
  updates      See and install updates
EOF
    read -rp "Which ones? (names with spaces between, 'all', or Enter for none) " modules </dev/tty
    echo "Now your password, once:"
    sudo -v </dev/tty

    sudo pacman -S --needed --noconfirm git </dev/tty
    if [[ -d "$dir/.git" ]]; then
        git -C "$dir" pull --ff-only --autostash </dev/tty
    else
        git clone "$repo" "$dir" </dev/tty
    fi

    # shellcheck source=scripts/lib.sh
    source "$dir/scripts/lib.sh"
    keep_sudo </dev/tty

    SKORNEX_BOOTSTRAP=1 SKORNEX_MODULES="$modules" "$dir/install.sh" </dev/tty
    if ((gaming)); then
        SKORNEX_YES=1 "$dir/gaming.sh" </dev/tty
    fi

    echo
    for i in 10 9 8 7 6 5 4 3 2 1; do
        printf '\rSkorneX is set up. Restarting in %2d seconds (Ctrl+C to stay here)... ' "$i"
        sleep 1
    done
    echo
    # Remove the temporary sudo rule and restart in one step, so it can't be
    # left behind.
    sudo sh -c "rm -f '$SUDO_RULE' && systemctl reboot"
}

main "$@"
