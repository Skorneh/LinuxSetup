# LinuxSetup

My Arch Linux setup: a minimal Arch install plus a lean, Windows-style KDE
Plasma desktop, with gaming (Steam, Lutris, World of Warcraft) on the real PC.

## What's in here

| Path | What it does |
|---|---|
| `install.sh` | Base setup: installs packages, paru, links dotfiles, sets up the login screen, debloats Firefox, enables services. Adds the guest agent when it's running in a Proxmox VM. |
| `kde-setup.sh` | Windows-style KDE settings: shortcuts, screenshot keys, window snapping, Start menu search. Run inside Plasma. |
| `gaming.sh` | Real PC only: enables `[multilib]`, detects your GPU and installs drivers, then Steam, Lutris, GameMode, MangoHud. |
| `packages/pkglist.txt` | Official-repo packages for the desktop. |
| `packages/aurlist.txt` | AUR packages (empty for now). |
| `packages/gaming.txt` | Gaming packages. |
| `system/firefox-policies.json` | Firefox debloat settings, installed to `/etc/firefox/policies/`. |
| `dotfiles/` | Config files, linked into `~` with GNU Stow. Each folder mirrors your home folder. |
| `scripts/check-packages.sh` | Lists installed packages that aren't in the lists yet. |

All scripts are safe to run more than once.

## Setting up a machine

### 1. Install Arch

Boot the Arch ISO and run `archinstall`. Choose:

- **Profile:** Minimal
- **User:** create your user and give it sudo (superuser) rights
- **Network:** NetworkManager
- **Audio:** PipeWire

Reboot into the new system and log in on the text console.

### 2. Run the base setup

```bash
sudo pacman -S --needed git
git clone https://github.com/Skorneh/LinuxSetup.git ~/LinuxSetup
cd ~/LinuxSetup
./install.sh
sudo reboot
```

The repo needs to live at `~/LinuxSetup`, because your dotfiles are symlinks
into it.

### 3. Apply the Windows-style settings

Log in to **Plasma (Wayland)**, open Konsole, and run:

```bash
~/LinuxSetup/kde-setup.sh
```

Then log out and back in.

### 4. Gaming (real PC only)

```bash
~/LinuxSetup/gaming.sh
sudo reboot
```

It shows the GPU it found and the driver packages it picked, and asks before
installing them. After rebooting:

- **Steam:** Settings > Compatibility > turn on "Enable Steam Play for all other titles".
- **WoW:** open Lutris, search for **Battle.net**, install it, log in, and install WoW from there.

## Shortcuts

| Keys | Action | Source |
|---|---|---|
| Win | Start menu | Plasma default |
| Win+E | File manager (Dolphin) | kde-setup.sh |
| Win+R | Run / search (KRunner) | kde-setup.sh |
| Win+I | Settings | kde-setup.sh |
| Win+L | Lock screen | kde-setup.sh |
| Win+D | Show desktop | Plasma default |
| Win+Left / Win+Right | Snap to half the screen | Plasma default |
| Win+Up / Win+Down | Maximize / minimize | kde-setup.sh |
| Win+Tab (or Win+W) | Overview of all windows, like Task View | kde-setup.sh |
| Print Screen | Screenshot a region, to clipboard | kde-setup.sh |
| Win+Shift+S | Screenshot a region, to clipboard | kde-setup.sh |
| Alt+Print Screen | Screenshot the current window, to clipboard | kde-setup.sh |
| Shift+Print Screen | Screenshot the whole screen, to clipboard | kde-setup.sh |
| Win+Print Screen | Screenshot the whole screen, saved to Pictures/Screenshots | kde-setup.sh |
| Ctrl+Shift+Esc | System Monitor (Task Manager) | kde-setup.sh |
| Ctrl+Alt+T | Terminal | kde-setup.sh |
| Alt+Tab | Switch windows (every window shown separately, with previews) | kde-setup.sh |

Dragging a window to a screen edge or corner snaps it, like Windows.

To pin an app to the taskbar, right-click it in the Start menu (or on the
taskbar while it's open) and choose **Pin to Task Manager**.

The Start menu and Win+R only search apps, settings and the calculator, and
run typed commands. Web search, browser history and file search are off.

## Day-to-day

- **Edit a config:** edit it in place (for example `~/.bashrc`). It's a symlink
  into the repo, so just commit the change.
- **Add a new config file to the repo:** move it into the matching place under
  `dotfiles/<name>/` (for example `dotfiles/kitty/.config/kitty/kitty.conf`),
  then run `./install.sh` again to link it.
- **Installed something new?** Run `pkgcheck` (or `scripts/check-packages.sh`)
  to see what isn't tracked, and add what you want to keep to the right list.
- **Update the system:** `update` (runs `paru -Syu`).

### Why KDE settings aren't symlinked

KDE rewrites its own config files when you change settings, which replaces
symlinks with normal files. So instead of tracking KDE's config files directly,
`kde-setup.sh` writes the specific settings that matter with `kwriteconfig6`.
To keep a new KDE setting, add a line for it there.

## Testing in a VM (Proxmox)

Try configs in a VM before touching the real PC. In Proxmox, create a VM with:

- **System:** q35, OVMF (UEFI), EFI disk with **"Pre-Enroll keys" unticked**
  (the Arch ISO won't boot with Secure Boot on), QEMU Agent ticked
- **CPU:** 4 cores, type `host`. **Memory:** 8 GB. **Disk:** 40+ GB
- **Display:** VirtIO-GPU

In `archinstall`, add `qemu-guest-agent` under **Additional packages**.
Otherwise Proxmox's Shutdown button hangs waiting for the agent. Keep the VM
out of HA and replication; it's temporary.

Run steps 1–3 only, and take a snapshot right after `archinstall` so you can
roll back. When you're done, Shutdown → More → Remove to free its resources. `gaming.sh` warns you if it detects a VM.

## Keep secrets out

Never commit passwords, SSH keys or tokens. `.gitignore` blocks the common
ones, but check `git status` before committing.
