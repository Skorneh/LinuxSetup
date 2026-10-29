#!/usr/bin/env bash
# Compare what's installed with the package lists in packages/.
# Prints packages you installed by hand that aren't tracked yet, so you can
# decide which ones to add (and to which list). It doesn't change any files.
set -euo pipefail

source "$(dirname "$0")/lib.sh"

tracked="$({
    cat "$REPO_DIR"/packages/*.txt | sed -e 's/#.*//' -e 's/[[:space:]]*$//'
    # Packages the Settings modules install (Packages= in each module's .conf).
    sed -n 's/^\(Packages\|Aur\)=//p' "$REPO_DIR"/modules/*/files/.local/share/skornex/settings/*.conf | tr ' ' '\n'
} | grep -v '^$' | sort -u)"
# Drivers and kernel headers are chosen by gaming.sh, so ignore them here.
ignore='^(nvidia|lib32-nvidia|linux|mesa|lib32-mesa|vulkan-|lib32-vulkan-|paru|qemu-guest-agent)'

untracked() {
    comm -23 <(sort -u) <(echo "$tracked") | grep -Ev "$ignore" || true
}

echo "Official-repo packages not in any list:"
pacman -Qqen | untracked | sed 's/^/    /'
echo
echo "AUR packages not in aurlist.txt:"
pacman -Qqem | untracked | sed 's/^/    /'
