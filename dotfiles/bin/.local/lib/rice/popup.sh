# shellcheck shell=bash
# Shared by the taskbar menus. Clicking a button again closes its menu, and
# menus open as a small box just above the taskbar instead of mid-screen.
# Clicking anywhere outside a menu closes it (rofi's click-to-exit).

# If a menu is already open, close it and stop.
popup_toggle() {
    if pkill -x rofi; then exit 0; fi
}

# The taskbar is 34px tall; menus sit just above it.
POPUP_ABOVE_BAR="y-offset: -40px;"

# popup_menu <distance from right screen edge in px> <title> [rofi options]
# Reads the menu lines from stdin, prints the chosen one.
popup_menu() {
    local right="$1" title="$2"; shift 2
    rofi -dmenu -i -p "$title" -theme-str "
        window { location: south east; anchor: south east; x-offset: -${right}px; $POPUP_ABOVE_BAR width: 300px; }
        mainbox { children: [ message, listview ]; }
        listview { lines: 8; fixed-height: false; }" \
        -mesg "$title" "$@"
}

# popup_search <title> [rofi options]: the launcher-style box above the
# search bar, bottom left, with a live match count ("0 results").
popup_search_theme="
    window { location: south west; anchor: south west; x-offset: 8px; $POPUP_ABOVE_BAR width: 520px; }
    inputbar { children: [ prompt, entry, num-filtered-rows, textbox-results ]; }
    num-filtered-rows { expand: false; text-color: @muted; }
    textbox-results { expand: false; content: \" results\"; text-color: @muted; }"
