#!/usr/bin/env bash
# Windows-style KDE settings: shortcuts, screenshots, snapping, Start menu search.
# Run from inside a Plasma session (open Konsole after logging in).
# Safe to run again. Log out and back in afterwards so shortcuts reload.
set -euo pipefail

source "$(dirname "$0")/scripts/lib.sh"
require_arch_user
[[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* ]] || die "Run this from inside a KDE Plasma session."

kw() { kwriteconfig6 "$@"; }
shortcut() {  # shortcut <desktop-file> <action> <keys...>
    local desktop="$1" action="$2"; shift 2
    local IFS=$'\t'
    kw --file kglobalshortcutsrc --group services --group "$desktop" --key "$action" "$*"
}
builtin_shortcut() {  # builtin_shortcut <component> <action> <label> <keys...>
    local component="$1" action="$2" label="$3"; shift 3
    local IFS=$'\t'
    kw --file kglobalshortcutsrc --group "$component" --key "$action" "$*,$*,$label"
}

# --- Shortcuts ---
# Plasma already has: Win+D show desktop, Win+Left/Right snap, Win+V clipboard,
# Win+. emoji, Win opens the Start menu, Ctrl+Alt+Del logout screen.
info "Setting Windows-style shortcuts..."
shortcut org.kde.dolphin.desktop               _launch Meta+E
shortcut systemsettings.desktop                _launch Meta+I
shortcut org.kde.krunner.desktop               _launch Alt+Space Alt+F2 Search Meta+R
shortcut org.kde.plasma-systemmonitor.desktop  _launch Ctrl+Shift+Esc
shortcut org.kde.konsole.desktop               _launch Ctrl+Alt+T

builtin_shortcut ksmserver   "Lock Session"             "Lock Session"     Meta+L Screensaver
# Win+Up maximizes and Win+Down minimizes, instead of snapping to the top/bottom half.
builtin_shortcut kwin        "Window Maximize"          "Maximize Window"  Meta+Up Meta+PgUp
builtin_shortcut kwin        "Window Minimize"          "Minimize Window"  Meta+Down Meta+PgDown
builtin_shortcut kwin        "Window Quick Tile Top"    "Quick Tile Window to the Top"    none
builtin_shortcut kwin        "Window Quick Tile Bottom" "Quick Tile Window to the Bottom" none
# Win+Tab opens the Overview (like Task View); Win+W keeps working too.
builtin_shortcut kwin        "Overview"                 "Toggle Overview"  Meta+W Meta+Tab
builtin_shortcut plasmashell "next activity"            "Walk through activities"         none

# --- Alt+Tab ---
# Every window shows separately with a preview, even several from one app.
info "Setting up Alt+Tab..."
kw --file kwinrc --group TabBox --key LayoutName thumbnail_grid
kw --file kwinrc --group TabBox --key ApplicationsMode 0   # 0 = all windows, not one per app
kw --file kwinrc --group TabBox --key ShowDesktopMode 0

# --- Screenshots (Spectacle) ---
# Print = drag a box, Alt+Print = current window, Shift+Print = whole screen,
# Win+Shift+S = drag a box. All go straight to the clipboard, no editor window.
# Win+Print saves the whole screen to ~/Pictures/Screenshots instead.
info "Setting up screenshot keys..."
shortcut org.kde.spectacle.desktop _launch                     none
shortcut org.kde.spectacle.desktop RectangularRegionScreenShot Print Meta+Shift+S
shortcut org.kde.spectacle.desktop ActiveWindowScreenShot      Alt+Print
shortcut org.kde.spectacle.desktop FullScreenScreenShot        Shift+Print
shortcut screenshot-full.desktop   _launch                     Meta+Print
kw --file spectaclerc --group General --key clipboardGroup PostScreenshotCopyImage
kw --file spectaclerc --group General --key autoSaveImage false
kw --file spectaclerc --group General --key useReleaseToCapture true

# --- Window snapping ---
info "Turning on edge and corner snapping..."
kw --file kwinrc --group Windows --key ElectricBorderMaximize true
kw --file kwinrc --group Windows --key ElectricBorderTiling true

# --- Misc ---
info "Turning Num Lock on at login..."
kw --file kcminputrc --group Keyboard --key NumLock 0   # 0 = on

# --- Start menu / Win+R search ---
# Only apps, settings, the calculator and typed commands. No web shortcuts,
# browser history, bookmarks, files or recent documents.
info "Trimming Start menu search..."
for plugin in krunner_webshortcuts browserhistory browsertabs krunner_bookmarksrunner \
              baloosearch krunner_recentdocuments locations krunner_placesrunner \
              krunner_appstream krunner_dictionary krunner_spellcheck krunner_charrunner \
              krunner_katesessions krunner_konsoleprofiles krunner_kill helprunner \
              org.kde.datetime org.kde.activities2 unitconverter windows; do
    kw --file krunnerrc --group Plugins --key "${plugin}Enabled" false
done

dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure 2>/dev/null || true

echo
info "KDE setup done. Log out and back in so the new shortcuts take effect."
