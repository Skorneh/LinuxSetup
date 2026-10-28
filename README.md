# LinuxSetup

My Arch Linux setup, built from nothing: a minimal Arch install, the labwc
window manager (windows float like on Windows, no tiling), and only the pieces
I picked. Gaming (Steam, Lutris, World of Warcraft) on the real PC.

There's no settings app. Everything is a text file in this repo or a small
script I own.

## What's in here

| Path | What it does |
|---|---|
| `install.sh` | Installs everything, links the configs, applies the colors, sets up booting straight to the lock screen, debloats Firefox. Adds the guest agent in a Proxmox VM. |
| `gaming.sh` | Real PC only: enables `[multilib]`, detects your GPU and installs drivers, then Steam, Lutris, GameMode, MangoHud. |
| `packages/` | Package lists: `pkglist.txt` (official repos), `aurlist.txt` (AUR), `gaming.txt`. |
| `dotfiles/` | Config files, linked into `~` with GNU Stow. Each folder mirrors your home folder. |
| `dotfiles/rice/.config/rice/colors` | **The one file with all the colors.** |
| `theme/templates/` | Configs that use those colors. `rice-theme` fills them in. |
| `dotfiles/bin/.local/bin/` | Our own small tools (below). |
| `system/firefox-policies.json` | Firefox debloat settings. |
| `scripts/check-packages.sh` | Lists installed packages that aren't in the lists yet. |

All scripts are safe to run more than once.

## The desktop

| Piece | What it is | Config |
|---|---|---|
| Window manager | labwc | `dotfiles/labwc/.config/labwc/` (`rc.xml` = settings and shortcuts, `autostart` = what starts with it) |
| Taskbar | Waybar, bottom: search bar, pinned apps, open apps, hidden-icons tray, Recycle Bin, network, volume, clock, power | `dotfiles/waybar/…/config.jsonc` |
| Launcher | rofi | `dotfiles/rofi/…/config.rasi` |
| Terminal | kitty, Maple Mono NF | `dotfiles/kitty/…/kitty.conf` |
| Files | Nemo | |
| Notifications | dunst | `theme/templates/dunst/dunstrc` |
| Lock screen | hyprlock: black, clock, password box | `theme/templates/hypr/hyprlock.conf` |
| Login | greetd boots straight to the lock screen | `install.sh` step 6 |
| Background | solid color from the colors file | `dotfiles/labwc/…/autostart` |
| Idle | lock after 10 min, monitor off after 15 | `dotfiles/labwc/…/autostart` |

### Our own tools

Each one is a short script in `dotfiles/bin/.local/bin/` that uses rofi as its
window, so it matches the colors automatically.

| Tool | Opens with | Does |
|---|---|---|
| `spotlight` | Search bar on the taskbar, Ctrl+Space | Search apps and files in your home folder together, like Spotlight. Enter opens it. |
| `launcher` | Windows key | The app list, above the search bar. |
| `taskbar-pins` | Right-click the search bar | Pin or unpin apps. Pins live in `~/.config/rice/pins` (Files is pinned by default). |
| `recycle-bin` | Bin icon on the taskbar | Click to open it in Nemo, right-click to empty it. |
| `calendar-popup` | Click the clock | This month's calendar. |
| `force-quit` | Ctrl+Shift+Esc | Lists open apps with memory use. Pick one, confirm, it's closed. |
| `power-menu` | Ctrl+Alt+Delete, power icon on the taskbar | Lock, Log out, Restart, Shut down. |
| `sound-output` | Click the volume on the taskbar | Pick speakers, headset, etc. |
| `network-menu` | Click the network icon on the taskbar | Shows your connection, joins Wi-Fi, opens `nmtui` for anything else. |
| `screenshot` | Print Screen keys | Region or full screen to the clipboard, or save to a file. |
| `rice-theme` | Run it in a terminal | Applies the colors file everywhere. |

## Colors

All colors are in `~/.config/rice/colors` (Graphite: black and grays). Change
a value, then run:

```bash
rice-theme
```

It rewrites the taskbar, launcher, notifications, terminal, window borders and
lock screen, and reloads what's running. App windows like Nemo use the dark
`adw-gtk3-dark` theme.

## Setting up a machine

### 1. Install Arch

Boot the Arch ISO and run `archinstall`. Choose:

- **Profile:** Minimal
- **User:** create your user and give it sudo (superuser) rights
- **Network:** NetworkManager
- **Audio:** PipeWire

Reboot into the new system and log in on the text console.

### 2. Run the setup

```bash
sudo pacman -S --needed git
git clone https://github.com/Skorneh/LinuxSetup.git ~/LinuxSetup
cd ~/LinuxSetup
./install.sh
sudo reboot
```

The repo needs to live at `~/LinuxSetup`, because your configs are symlinks
into it. After the reboot, the PC starts at your lock screen. Type your
password and you're on the desktop.

### 3. Gaming (real PC only)

```bash
~/LinuxSetup/gaming.sh
sudo reboot
```

It shows the GPU it found and the driver packages it picked, and asks before
installing them. After rebooting:

- **Steam:** Settings > Compatibility > turn on "Enable Steam Play for all other titles".
- **WoW:** open Lutris, search for **Battle.net**, install it, log in, and install WoW from there.

## Shortcuts

| Keys | Action |
|---|---|
| Win | App launcher |
| Ctrl+Space | Search apps and files (Spotlight) |
| Win+R | Run a command |
| Win+E | Files (Nemo) |
| Ctrl+Alt+T | Terminal |
| Win+L | Lock |
| Win+V | Clipboard history (text and images) |
| Win+D | Show desktop |
| Win+Left / Win+Right | Snap to half the screen |
| Win+Up / Win+Down | Maximize / minimize |
| Win+Shift+Left / Right | Move window to the other monitor |
| Alt+Tab | Switch windows, with previews |
| Alt+F4 | Close window |
| Ctrl+Alt+Q | Force-quit the window you're in |
| Ctrl+Shift+Esc | Force Quit list |
| Ctrl+Alt+Delete | Power menu |
| Print Screen, Win+Shift+S, Alt+Print Screen | Drag a box, copy to clipboard |
| Shift+Print Screen | Whole screen, copy to clipboard |
| Win+Print Screen | Whole screen, saved to Pictures/Screenshots |
| Win+Shift+R | Reload labwc after editing `rc.xml` |

Dragging a window to a screen edge snaps it to half the screen, a corner to a
quarter, the top to maximize. Clicking the empty desktop does nothing.

### The taskbar

- **Search bar** (far left): search apps and files. Right-click it to pin or
  unpin apps.
- **App buttons** start on the left: pinned apps first, then other open apps.
  Each has three looks, like Windows: pinned but closed (plain), open (thin
  line under it), and the one you're using (highlighted, bright line). Click
  the app you're using to minimize it.
- **^** (right side) shows hidden icons, such as Discord and Steam when
  they're closed to the tray.
- **Menus** (network, volume, clock, power) open as a small box above their
  button. Click the button again, or anywhere else, to close it.

Mouse side buttons (back/forward) work in Firefox and Nemo on their own.

Alt+Print Screen can't grab just the current window on labwc, so it works like
Print Screen (drag a box around it).

## Day-to-day

- **Edit a config:** edit it in place (for example `~/.config/labwc/rc.xml`).
  It's a symlink into the repo, so just commit the change.
- **Edit a themed config** (anything in `theme/templates/`): edit the template
  in the repo, then run `rice-theme`. The file in `~/.config` gets overwritten.
- **Add a new config file to the repo:** move it into the matching place under
  `dotfiles/<name>/`, then run `./install.sh` again to link it.
- **Installed something new?** Run `pkgcheck` to see what isn't tracked, and
  add what you want to keep to the right list.
- **Update the system:** `update` (runs `paru -Syu`).

## Testing in a VM (Proxmox)

Try configs in a VM before touching the real PC. In Proxmox, create a VM with:

- **System:** q35, OVMF (UEFI), EFI disk with **"Pre-Enroll keys" unticked**
  (the Arch ISO won't boot with Secure Boot on), QEMU Agent ticked
- **CPU:** 4 cores, type `host`. **Memory:** 8 GB. **Disk:** 40+ GB
- **Display:** VirtIO-GPU

In `archinstall`, add `qemu-guest-agent` under **Additional packages**.
Otherwise Proxmox's Shutdown button hangs waiting for the agent. Keep the VM
out of HA and replication; it's temporary.

Run steps 1–2 only, and take a snapshot right after `archinstall` so you can
roll back. When you're done, Shutdown → More → Remove to free its resources.
`gaming.sh` warns you if it detects a VM.

## Keep secrets out

Never commit passwords, SSH keys or tokens. `.gitignore` blocks the common
ones, but check `git status` before committing.
