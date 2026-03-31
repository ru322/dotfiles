{pkgs, ...}:
{
  home.packages = with pkgs; [
    wl-clipboard
    cliphist  # Clipboard history manager
  ];

  # Clipboard history with cliphist (for Hyprland/Wayland)
  # Usage:
  #   cliphist list | wofi --dmenu | cliphist decode | wl-copy
  #
  # Add to Hyprland config:
  #   exec-once = wl-paste --type text --watch cliphist store
  #   exec-once = wl-paste --type image --watch cliphist store
  #   bind = $mainMod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
}
