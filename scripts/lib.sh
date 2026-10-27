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

# Ask a yes/no question. Default is yes.
confirm() {
    local reply
    read -rp "$1 [Y/n] " reply
    [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

require_arch_user() {
    [[ -f /etc/arch-release ]] || die "This doesn't look like Arch Linux."
    [[ $EUID -ne 0 ]] || die "Run this as your normal user, not root. It uses sudo when needed."
    command -v sudo >/dev/null || die "sudo is not installed."
}
