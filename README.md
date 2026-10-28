# SkorneX

My own Arch Linux desktop, built from nothing: a minimal Arch install, the
labwc window manager (windows float like on Windows, no tiling), and only the
pieces I picked. Gaming (Steam, Lutris, World of Warcraft) on the real PC.

There's no settings app. Everything is a text file in this repo or a SkorneX
tool I own.

## What's in here

| Path | What it does |
|---|---|
| `install.sh` | Installs everything, links the configs, applies the colors, sets up booting straight to the lock screen, debloats Firefox. Adds the guest agent in a Proxmox VM. |
| `gaming.sh` | Real PC only: enables `[multilib]`, detects your GPU and installs drivers, then Steam, Lutris, GameMode, MangoHud. |
| `packages/` | Package lists: `pkglist.txt` (official repos), `aurlist.txt` (AUR), `gaming.txt`, and `removelist.txt` (old packages to remove). |
| `dotfiles/apps/` | App list tweaks: kitty shown as Terminal, Mousepad as Notepad, Paint and Task Manager added, and two broken webcam test tools (from ffmpeg) hidden. |
| `dotfiles/` | Config files, linked into `~` with GNU Stow. Each folder mirrors your home folder. |
| `dotfiles/skornex/.config/skornex/colors` | **The one file with all the colors.** |
| `dotfiles/skornex/.config/skornex/pins` | Apps pinned to the taskbar. |
| `dotfiles/bin/.local/bin/` | The SkorneX tools (below). |
| `theme/templates/` | Configs that use the colors. `skornex-theme` fills them in. |
| `system/firefox-policies.json` | Firefox debloat settings. |
| `scripts/check-packages.sh` | Lists installed packages that aren't in the lists yet. |

All scripts are safe to run more than once.

## SkorneX tools

| Tool | Opens with | Does |
|---|---|---|
| `skornex-bar` (**SkorneXBar**) | Starts with the desktop | The taskbar. See below. |
| `skornex-desktop` (**SkorneXDesktop**) | Starts with the desktop | Desktop icons: the Recycle Bin plus everything in `~/Desktop`. Drag them anywhere (they snap to a grid and stay put), double-click to open, right-click for options. Add app shortcuts from the taskbar's right-click menu. |
| `skornex-taskmgr` (**Task Manager**) | Ctrl+Shift+Esc, or search "Task Manager" | Apps and background processes with CPU and memory. Select one and press End task (or right-click it). |
| `skornex-paint` (**Paint**) | Search "Paint" | Works like Microsoft Paint: take a screenshot, open Paint, Ctrl+V, drag it into place, draw on it, Ctrl+S. Pencil, brush, fill, text, eraser, color picker, shapes, crop, resize and rotate, left click for Color 1 and right click for Color 2. Saves PNG, JPEG or BMP. |
| `skornex-theme` | Run it in a terminal | Applies the colors file everywhere. |
| `skornex-screenshot` | Print Screen keys | Region or full screen to the clipboard, or save to a file. |

### SkorneXBar

Works like the Windows taskbar:

- **Search box** (far left), or the **Windows key** or **Ctrl+Space**: type to
  find apps and files in your home folder. Shows "No results" when nothing
  matches. With nothing typed, it lists all apps.
- **App buttons** start on the left: pinned and open apps in one row (Files is
  pinned by default). Three looks: pinned but closed (plain), open
  (line under it), the app you're using (highlighted, brighter line).
  - Click: open it, switch to it, or minimize it if you're already using it.
  - Right-click: **Pin to taskbar** / **Unpin from taskbar**, **Add to
    desktop**, new window, close.
  - Drag any button left or right, pinned or not. Pinned order is saved.
- **^**: hidden icons in a small pop-up. Apps that have a tray icon (Discord,
  Steam…) put it here while they're running, including after you close their
  window. Click one to open the app, right-click for its menu.
- **Win+R** (Run) opens a SkorneXBar pop-up too.
- **Network, volume, clock, power**: each opens a small panel in the
  bottom-right corner. Click the button again, click anywhere else, or press
  Esc to close it. Volume has a slider and the output list (speakers,
  headset…); scrolling on the volume changes it.

## Apps

- **Files:** Nemo (Win+E).
- **Terminal:** kitty, shown as Terminal (Ctrl+Alt+T).
- **Notepad:** Mousepad, shown as Notepad. Tabs, line numbers and syntax
  colors; opens `.sh`, `.md` and other text files when you double-click them.
- **Firefox** (debloated), **Discord**.
- **Xwayland** runs older X11 apps (Steam, Wine games) inside labwc.

## Colors

All colors are in `~/.config/skornex/colors` (Graphite: black and grays).
Change a value, then run:

```bash
skornex-theme
```

It rewrites SkorneXBar, the desktop background, notifications, terminal, window
borders and lock screen, and reloads what's running. App windows like Nemo use
the dark `adw-gtk3-dark` theme.

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
| Win, or Ctrl+Space | Search apps and files |
| Win+R | Run a command (SkorneXBar pop-up) |
| Win+E | Files (Nemo) |
| Ctrl+Alt+T | Terminal |
| Win+L | Lock |
| Win+D | Show desktop |
| Win+Left / Win+Right | Snap to half the screen |
| Win+Up / Win+Down | Maximize / minimize |
| Win+Shift+Left / Right | Move window to the other monitor |
| Alt+Tab | Switch windows, with previews |
| Alt+F4 | Close window |
| Ctrl+Alt+Q | Force-quit the window you're in |
| Ctrl+Shift+Esc | Task Manager |
| Ctrl+Alt+Delete | Power menu |
| Print Screen, Win+Shift+S, Alt+Print Screen | Drag a box, copy to clipboard |
| Shift+Print Screen | Whole screen, copy to clipboard |
| Win+Print Screen | Whole screen, saved to Pictures/Screenshots |
| Win+Shift+R | Reload labwc after editing `rc.xml` |

Dragging a window to a screen edge snaps it to half the screen, a corner to a
quarter, the top to maximize. Clicking the empty desktop does nothing.

Alt+Print Screen can't grab just the current window on labwc, so it works like
Print Screen (drag a box around it). Mouse side buttons (back/forward) work in
Firefox and Nemo on their own.

## Day-to-day

- **Edit a config:** edit it in place (for example `~/.config/labwc/rc.xml`).
  It's a symlink into the repo, so just commit the change.
- **Edit a themed config** (anything in `theme/templates/`): edit the template
  in the repo, then run `skornex-theme`. The file in `~/.config` gets overwritten.
- **Change SkorneXBar:** edit `dotfiles/bin/.local/bin/skornex-bar` (Python),
  then run `pkill -f skornex-bar`. It restarts by itself a second later.
- **SkorneXBar or SkorneXDesktop crashed?** They restart by themselves. What
  went wrong is in `~/.cache/skornex-bar.log` or `~/.cache/skornex-desktop.log`
  (`tail -50 ~/.cache/skornex-bar.log`).
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
`gaming.sh` also runs in a VM to check that it installs: it warns you, skips
the GPU drivers, and installs Steam and the rest. Games will be slow there.

## Keep secrets out

Never commit passwords, SSH keys or tokens. `.gitignore` blocks the common
ones, but check `git status` before committing.
