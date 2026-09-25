# dotfiles

Personal dotfiles managed with environment-based symlinks.

## Structure

```
common/    # Shared across all environments (nvim, kitty, bashrc_common)
linux/     # Pure Linux settings (sway, bashrc_linux)
wsl/       # WSL-specific settings
windows/   # Windows-specific settings
bin/       # Custom scripts (added to PATH)
```

## Install

### Linux / WSL

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

### Windows (PowerShell as Administrator)

```powershell
git clone <repo> ~\dotfiles
cd ~\dotfiles
.\install.ps1
```

## How it works

`install.sh` detects the environment (linux/wsl/mac) and creates symlinks from `common/` and the environment-specific folder to `$HOME`. It also generates `~/.bashrc` that sources the appropriate bashrc files.

## Satori desktop

Satori uses GNOME with GDM, configured in `common/nixos/gnome.nix`.
Home Manager loads `common/home-mgr/gnome.nix` for the wallpaper, dark theme,
Japanese keyboard layout, and desktop shortcuts.

Apply both configurations from this directory (the `path:` reference also includes
new files before they are added to Git):

```bash
sudo nixos-rebuild switch --flake path:.#Satori
home-manager switch --flake path:.#Satori
```

Switching the display manager may end the current graphical session; save your
work before applying the system configuration. Log in to GNOME through GDM
after applying both configurations, or reboot if needed.
