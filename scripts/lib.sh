# shellcheck shell=bash
# Shared helpers, sourced by the other scripts.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==> WARNING:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m==> ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

# Print the packages in a list file, skipping comments and blank lines.
read_list() {
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' || true
}

# Ask a yes/no question. Default is yes. SKORNEX_YES=1 answers yes by itself
# (bootstrap.sh sets it after asking everything up front).
confirm() {
    local reply
    if [[ -n "${SKORNEX_YES:-}" ]]; then
        echo "$1 yes"
        return 0
    fi
    read -rp "$1 [Y/n] " reply
    [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

# Ask for the sudo password once. For the rest of the run, a temporary rule in
# /etc/sudoers.d lets sudo work without asking (building paru calls sudo from
# places sudo's 5-minute memory doesn't cover). The rule is removed when the
# script that made it ends, and replaced if a crash or power cut left it behind.
SUDO_RULE=/etc/sudoers.d/zz-skornex-setup
keep_sudo() {
    if [[ -n "${SKORNEX_SUDO_OWNER:-}" ]] && sudo -n true 2>/dev/null; then
        return 0  # a parent script (bootstrap.sh) made the rule and removes it
    fi
    sudo -v || die "This needs your password (sudo)."
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDO_RULE" >/dev/null
    sudo chmod 440 "$SUDO_RULE"
    export SKORNEX_SUDO_OWNER=$$
    trap 'sudo rm -f "$SUDO_RULE"' EXIT
    trap 'exit 130' INT TERM
}

require_arch_user() {
    [[ -f /etc/arch-release ]] || die "This doesn't look like Arch Linux."
    [[ $EUID -ne 0 ]] || die "Run this as your normal user, not root. It uses sudo when needed."
    command -v sudo >/dev/null || die "sudo is not installed."
}
