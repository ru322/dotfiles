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
