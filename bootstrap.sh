#!/usr/bin/env bash
# One command to set up SkorneX on a fresh Arch install. Log in as your user
# on the text console and run:
#
#   curl -fsSL https://raw.githubusercontent.com/Skorneh/LinuxSetup/claude/serene-babbage-p7zyak/bootstrap.sh | bash
#
# It installs git, downloads this repo to ~/LinuxSetup, runs install.sh,
# asks whether to run gaming.sh too, then offers to reboot.
set -euo pipefail

# Everything is inside main, so a half-downloaded script never runs.
main() {
    local repo=https://github.com/Skorneh/LinuxSetup.git
    local dir="$HOME/LinuxSetup"
    local reply

    if [[ $EUID -eq 0 ]]; then
        echo "Run this as your normal user, not root. It uses sudo when needed." >&2
        exit 1
    fi

    # The script itself arrives through the pipe, so everything that reads
    # the keyboard reads from the terminal instead.
    sudo pacman -S --needed --noconfirm git </dev/tty
    if [[ -d "$dir/.git" ]]; then
        git -C "$dir" pull --ff-only </dev/tty
    else
        git clone "$repo" "$dir" </dev/tty
    fi

    SKORNEX_BOOTSTRAP=1 "$dir/install.sh" </dev/tty

    echo
    read -rp "Also install gaming (GPU drivers, Steam, Lutris, Discord)? [y/N] " reply </dev/tty
    if [[ "$reply" =~ ^[Yy] ]]; then
        "$dir/gaming.sh" </dev/tty
    fi

    echo
    read -rp "Restart now to start SkorneX? [Y/n] " reply </dev/tty
    if [[ ! "$reply" =~ ^[Nn] ]]; then
        sudo reboot
    fi
}

main "$@"
