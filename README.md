# SkorneX

A clean, Windows-style desktop for Arch Linux, set up with one command.

SkorneX starts from a minimal Arch install and adds only what a desktop needs:
the labwc window manager (windows float and snap like on Windows, no tiling),
a taskbar and desktop built for SkorneX, a small set of apps, and optional
gaming. Everything is dark (black and grays), and there's no settings app to
dig through: what you see is a handful of text files and small SkorneX tools.

- **Windows habits work:** Start-style search on the Windows key, a taskbar
  with pinned apps, Alt+Tab, Win+arrow snapping, Ctrl+Shift+Esc for Task
  Manager, Print Screen for screenshots, a Recycle Bin on the desktop.
- **Small:** no desktop environment, no background services you didn't ask for.
- **Gaming ready:** one extra command adds GPU drivers, Steam, Lutris (for
  Battle.net, Epic, GOG…), GameMode, MangoHud and Discord.
- **Starts at the lock screen:** turn the PC on, type your password, you're in.

> SkorneX is in alpha (version 0.x) and still in testing. Try it in a VM or on a spare PC
> first, and expect rough edges. Found one? See [Reporting problems](#reporting-problems).

## Contents

- [What you need](#what-you-need)
- [Install](#install)
- [Gaming](#gaming)
- [Using SkorneX](#using-skornex)
- [Settings](#settings)
- [Shortcuts](#shortcuts)
- [Keeping it up to date](#keeping-it-up-to-date)
- [Customizing](#customizing)
- [Troubleshooting](#troubleshooting)
- [Trying it in a VM](#trying-it-in-a-vm)
- [Reporting problems](#reporting-problems)
- [How the repo is laid out](#how-the-repo-is-laid-out)

## What you need

- A 64-bit PC (or VM) with at least 4 GB of RAM (8 GB for gaming) and 30 GB of
  disk. The install erases the disk you pick.
- Internet during the install (cable is easiest; Wi-Fi works too).
- A USB stick with the [Arch Linux ISO](https://archlinux.org/download/).
- Secure Boot turned off in the PC's firmware settings (the Arch ISO doesn't
  boot with it on).

## Install

### 1. Install Arch

Boot the Arch USB. On Wi-Fi, connect first with `iwctl` (see the
[Arch wiki](https://wiki.archlinux.org/title/Iwd#iwctl)). Then run
`archinstall` and choose:

- **Disk configuration:** the drive to install on. It gets erased.
- **Profile:** Minimal.
- **Authentication:** create your user and give it **sudo** (superuser)
  rights. A root password isn't needed.
- **Network:** NetworkManager (best). Anything that gets you online after the
  restart works; SkorneX switches it to NetworkManager. Don't pick "No network
  configuration", or you'll be offline.
- **Audio:** PipeWire (or anything; SkorneX installs PipeWire either way).

Leave everything else as it is, choose **Install**, and restart when it's done.
Take out the USB stick and log in with your user on the text screen.

### 2. Run the SkorneX setup

```bash
curl -fsSL https://raw.githubusercontent.com/Skorneh/LinuxSetup/main/bootstrap.sh | bash
```

It asks three things up front:

- **"Also install gaming?"** Answer **y** on a gaming PC: it also picks and
  installs the drivers for your graphics card. You can do it later instead,
  see [Gaming](#gaming).
- **Which settings modules you want** (Display, Sound, Mouse…). Type their
  names, `all`, or press Enter for none. See [Settings](#settings).
- **Your password**, once.

Then it runs by itself (10–30 minutes, depending on your internet) and
restarts into SkorneX. The PC starts at the lock screen: type your password
and you're on the desktop. Press Ctrl+C during the 10-second countdown at the
end if you'd rather not restart yet.

Running the command again is safe: it updates SkorneX and fixes anything that
went missing.

<details>
<summary>Prefer to do it by hand?</summary>

```bash
sudo pacman -S --needed git
git clone https://github.com/Skorneh/LinuxSetup.git ~/LinuxSetup
~/LinuxSetup/install.sh
~/LinuxSetup/gaming.sh      # optional
sudo reboot
```

The folder has to be `~/LinuxSetup`: your settings are links into it.
</details>

## Gaming

If you skipped gaming during setup, run this any time, then restart:

```bash
~/LinuxSetup/gaming.sh
```

It turns on Arch's 32-bit packages (`[multilib]`), finds your graphics card
(NVIDIA, AMD or Intel), shows you the driver packages it picked and asks before
installing them, then installs:

| App | What it's for |
|---|---|
| **Steam** | Steam games. Windows games run through Steam's Proton. |
| **Lutris** | Other launchers and games: Battle.net, Epic, GOG, Ubisoft, EA… |
| **Wine** (+ Mono, Gecko) | Runs Windows programs. Lutris uses it for you. |
| **Winetricks** | Adds Windows parts (fonts, DirectX…) to games. Lutris uses it for you, so it's hidden from search. |
| **GameMode** | Gives a game full CPU power while it runs. |
| **MangoHud** | On-screen FPS, CPU and GPU usage while you play. |
| **Discord** | Voice and chat. |

After restarting:

- **Steam:** Settings > Compatibility > turn on **"Enable Steam Play for all
  other titles"**, so Windows-only games show up as installable.
- **Battle.net, Epic, GOG…:** open Lutris, search for the launcher, install
  it, sign in, and install your games from there.
- **FPS counter:** in Steam, right-click a game > Properties > Launch options:
  `mangohud %command%`. Add GameMode with `gamemoderun mangohud %command%`.

In a VM, `gaming.sh` warns you, skips the drivers and installs the rest, so
you can check it works. Games will be slow without a real graphics card.

## Using SkorneX

### The taskbar (SkorneXBar)

- **Search** (far left), the **Windows key**, or **Ctrl+Space**: type to find
  apps and files in your home folder. With nothing typed, it lists all apps.
- **App buttons:** pinned and open apps share one row. Files is pinned to
  start with.
  - **Click** to open an app, switch to it, or minimize it if you're already
    in it.
  - **Right-click** for Pin/Unpin, Add to desktop, New window and Close.
  - **Drag** buttons left or right to reorder them.
- **Battery** (laptops only, right after the ^): charge level, and a
  charging icon when plugged in. Click it for the time left.
- **^ (hidden icons):** tray icons from apps like Discord and Steam. Click one
  to open the app, right-click for its menu (Mute, Quit…).
- **Network, volume, clock, power:** each opens a small panel in the
  bottom-right corner. Click outside it or press Esc to close it. Scroll on the
  volume icon to change the volume.

### The desktop (SkorneXDesktop)

The Recycle Bin, plus everything in your `~/Desktop` folder. Drag icons
anywhere (they snap to a grid and stay put), double-click to open, right-click
for options (Open, Rename, Delete…). Right-click the empty desktop for New
folder, New text document and Settings. Add app shortcuts from a taskbar button's right-click menu.

### Apps

| App | What it is |
|---|---|
| **Files** (Win+E) | Nemo file manager. |
| **Terminal** (Ctrl+Alt+T) | kitty. `nano` is there for quick edits. |
| **Notepad** | Mousepad: tabs, line numbers, syntax colors. Opens text files you double-click. |
| **Snipping Tool** | Screenshots from a window: Rectangle or Full screen, an optional delay, then Save, Copy or Edit in Paint. Print Screen still works too. |
| **Paint** | SkorneX Paint, laid out like Microsoft Paint. Take a screenshot, open Paint, press Ctrl+V, mark it up, Ctrl+S. |
| **Task Manager** (Ctrl+Shift+Esc) | Apps and background processes with CPU and memory. Select one and press End task. |
| **Firefox** | With Pocket, sponsored content, telemetry and the AI sidebar turned off. Check `about:policies` to see the settings. |

Older X11 apps (Steam, Wine games) run through Xwayland, which is included.

## Settings

Settings come as **modules**: each one is its own small app, with its own
entry in search, so you install only the ones you want and can change or
remove one without touching the others.

| Module | Search for | What it does |
|---|---|---|
| `display` | Display settings | Resolution, refresh rate, scale and orientation apply as soon as you pick them; drag the monitors into place (they snap edge to edge, no gaps) and press Apply; pick the main display for the taskbar, desktop icons and games. Asks "Keep these display settings?" and goes back after 15 seconds if you can't see anything. |
| `sound` | Sound settings | Speakers or headphones and their volume; your microphone with a boost up to 150%, a cap on how loud you can get (a limiter, like OBS's: drag the white line on the meter; peaks never go past it), a live level meter and a record-and-play-back test; each app's volume. |
| `mouse` | Mouse settings | Pointer speed, acceleration, scroll speed and direction, swap buttons, double-click speed, pointer size, touchpad tap-to-click. |
| `keyboard` | Keyboard settings | Keyboard layouts (languages) and the keys that switch them, key repeat, Num Lock. |
| `shortcuts` | Keyboard shortcuts | Every desktop-wide shortcut in one list: change its keys, turn it off, or add your own that opens an app, runs a command, presses other keys, or clicks the mouse (for example Alt+1 = left click). Shortcuts inside apps (Ctrl+C in Firefox) belong to each app. |
| `personalize` | Personalize | Color themes (Graphite, Midnight, Forest, Plum, Ember), or pick each color yourself (background, menus, text, accent, and more), and a desktop wallpaper. |
| `updates` | Updates | What's waiting to be updated (system, AUR apps, SkorneX itself), one button to install, and an optional reminder at login. |

**Settings** (search "Settings") shows every module you have in one window.
Its last page, **Add or remove settings**, turns modules on and off. From
Terminal it's `skornex-module` (list), `skornex-module add sound mouse`, or
`skornex-module remove display`. Removing a module keeps the settings it
already made.

## Shortcuts

| Keys | Action |
|---|---|
| Win, or Ctrl+Space | Search apps and files |
| Win+R | Run: an app by name ("settings"), a command, a folder ("~/Downloads") or a website |
| Win+V | Clipboard history: the last things you copied (text and pictures). Click one to paste it |
| Win+E | Files |
| Ctrl+Alt+T | Terminal |
| Win+L | Lock |
| Win+D | Show desktop |
| Win+Left / Win+Right | Snap to half the screen |
| Win+Up / Win+Down | Maximize / minimize |
| Win+Shift+Left / Right | Move the window to the monitor on that side (needs two monitors) |
| Win+Shift+Up / Down | Stretch the window to the full screen height / restore it |
| Alt+Tab | Switch windows, with previews (on the monitor you're working on) |
| Alt+F4 | Close the window |
| Ctrl+Alt+Q | Force-quit the window you're in |
| Ctrl+Shift+Esc | Task Manager |
| Ctrl+Alt+Delete | Power menu (Lock, Restart, Shut down) |
| Print Screen | Drag a box, copy it to the clipboard |
| Shift+Print Screen | Whole screen to the clipboard |
| Win+Print Screen | Whole screen, saved to Pictures/Screenshots |
| Volume keys | Volume up, down, mute, with a small volume bar above the sound icon |

Dragging a window to a screen edge snaps it to half the screen, to a corner
for a quarter, and to the top to maximize it. Mouse back/forward buttons work
in Firefox and Files.

## Keeping it up to date

| Command | Does |
|---|---|
| `update` | Updates all apps and the system (`paru -Syu`). Do this every week or two. |
| Updates > Update SkorneX, or `cd ~/LinuxSetup && git pull --autostash && ./install.sh` | Gets the latest SkorneX. Your settings stay as you set them (see [Your changes are kept](#your-changes-are-kept)). |
| `pkgcheck` | Lists apps you installed yourself that SkorneX doesn't know about. |

Install more apps with `sudo pacman -S <name>` (official repos) or
`paru -S <name>` (the [AUR](https://aur.archlinux.org/)). They show up in
search right away.

## Customizing

- **Colors and wallpaper:** the Personalize module. By hand: put your values
  in `~/.config/skornex/colors.user` (same format as
  `~/.config/skornex/colors`), then run `skornex-theme`. It updates the
  taskbar, desktop, notifications, terminal, window borders and lock screen.
- **Pinned apps:** right-click a taskbar button to pin or unpin it. The list
  lives in `~/.config/skornex/pins`.
- **Keyboard shortcuts and window behavior:** the Keyboard shortcuts, Mouse
  and Keyboard modules. By hand: labwc's settings
  ([docs](https://labwc.github.io/labwc-config.5.html)) are built by
  `skornex-labwc` from SkorneX's `~/.config/labwc/rc.base.xml` plus your
  changes in `~/.config/skornex/labwc/*.xml` (a file there only needs the
  parts it changes). Edit one of those, never `rc.xml`, then
  run `skornex-labwc` in Terminal to rebuild and reload.
- **Startup apps:** put a script in `~/.config/skornex/autostart.d/` (make it
  executable); it runs every time you log in.
- **Terminal:** your own settings in `~/.config/kitty/local.conf`, your own
  aliases in `~/.bashrc.local`.

### Your changes are kept

Updating SkorneX never undoes what you set:

- **Settings modules** (Display, Sound, Mouse, Keyboard, Shortcuts,
  Personalize, Updates) save in their own files in `~/.config/skornex/`.
- **Pinned apps, colors, wallpaper and window settings** are your own files
  (`pins`, `colors.user`, `wallpaper`, `labwc/*.xml`), separate from
  SkorneX's.
- **SkorneX's defaults** (dark theme, icon theme, Notepad's look, default
  apps, Files' sidebar) are applied once, on the first login. Change any of
  them and it stays changed. The list of what's been applied is
  `~/.local/share/skornex/once`; delete a line to get that default back at
  the next login or update.
- **Packages SkorneX stopped using** are removed once. Install one again
  yourself and it stays.
- **If you edited SkorneX's own files** in `~/LinuxSetup`, updating sets your
  edits aside, updates, and puts them back. If an update changed the same
  lines, your version is kept in `git stash` (`git -C ~/LinuxSetup stash list`).
  Files made from `theme/templates/` get rewritten by `skornex-theme`: edit
  the template instead.

## Troubleshooting

| Problem | Fix |
|---|---|
| Setup stopped with an error | Check your internet, then run the setup command again. It picks up where it left off. |
| "certificate is not yet valid" | The clock is wrong. The setup fixes it; just run it again. |
| The taskbar or desktop icons disappeared | They restart by themselves within a second. If it keeps happening, look at `~/.cache/skornex-bar.log` or `~/.cache/skornex-desktop.log` and include it in a bug report. |
| An app is frozen | Ctrl+Alt+Q force-quits the window you're in, or use Task Manager (Ctrl+Shift+Esc). |
| No sound | Click the volume icon and pick the right output (speakers, headset…). |
| No internet after setup | Click the network icon on the taskbar. On Wi-Fi, run `nmtui` in Terminal to connect. |
| A game won't start | Check that Steam Play is on (see [Gaming](#gaming)), and that you restarted after `gaming.sh`. |
| Print Screen does nothing in a VM | The VM window often catches the key. Run `skornex-screenshot region` in Terminal instead. |

## Trying it in a VM

A VM is the safest way to try SkorneX. Any of these work:

- **Proxmox:** machine q35, BIOS OVMF (UEFI), EFI disk with **"Pre-Enroll
  keys" unticked**, QEMU Agent ticked. CPU type `host`, 4 cores, 8 GB of
  memory, 40 GB of disk, display **VirtIO-GPU**.
- **virt-manager (QEMU/KVM):** 4 CPUs, 8 GB, 40 GB, video **Virtio**, firmware
  UEFI without Secure Boot.
- **VirtualBox:** 4 CPUs, 8 GB, 40 GB, enable EFI, graphics **VMSVGA** with 3D
  acceleration off. Expect it to be slower than the others.

Then follow [Install](#install). Take a snapshot after `archinstall` so you can
roll back and try again. In a VM, SkorneX also installs the QEMU guest agent so
the host can shut it down cleanly.

## Reporting problems

Open an [issue](https://github.com/Skorneh/LinuxSetup/issues/new/choose) and
include:

- What you did, what you expected, and what happened instead.
- Real PC or VM (which one), and your graphics card.
- A photo or screenshot if it's something you can see.
- For taskbar or desktop problems, the last lines of the log:
  `tail -50 ~/.cache/skornex-bar.log`

## How the repo is laid out

| Path | What it does |
|---|---|
| `bootstrap.sh` | The one-command setup: asks about gaming, downloads the repo, runs `install.sh` (and `gaming.sh`), restarts. |
| `VERSION` | SkorneX's version (still alpha, so 0.x). Updates shows it and the newest one online. |
| `install.sh` | Installs the packages, links the configs, applies the colors, sets up the lock screen login, debloats Firefox. Safe to run again. |
| `gaming.sh` | `[multilib]`, GPU drivers, and the gaming apps. Safe to run again. |
| `packages/` | Package lists: `pkglist.txt` (official repos), `aurlist.txt` (AUR), `gaming.txt`, and `removelist.txt` (packages older versions of SkorneX used, removed on update). |
| `dotfiles/` | Config files, linked into your home folder with GNU Stow. Each folder mirrors `~`. |
| `dotfiles/bin/.local/bin/` | The SkorneX tools: `skornex-bar` (taskbar and desktop), `skornex-taskmgr`, `skornex-paint`, `skornex-screenshot`, `skornex-theme`, `skornex-settings`, `skornex-module`, `skornex-labwc`. |
| `modules/` | The Settings modules, one folder each. Everything in a module's `files/` folder is linked into your home folder by `skornex-module add`; its `files/.local/share/skornex/settings/NAME.conf` describes it and lists the packages it needs. To make your own, copy a module folder and change it. |
| `dotfiles/apps/` | App list tweaks: kitty shown as Terminal, Mousepad as Notepad, Paint and Task Manager added, a few tools hidden from search. |
| `dotfiles/skornex/.config/skornex/` | `colors` (all the colors) and `pins` (taskbar pins). |
| `theme/templates/` | Configs that use the colors. `skornex-theme` fills them in. |
| `system/firefox-policies.json` | The Firefox settings. |
| `scripts/` | Shared helpers and `check-packages.sh` (`pkgcheck`). |

If you send changes: never commit passwords, SSH keys or tokens. `.gitignore`
blocks the common ones, but check `git status` first.

## License

[MIT](LICENSE). Use it, change it, share it; keep the copyright notice.
