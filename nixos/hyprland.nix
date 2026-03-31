# Hyprland configuration
{ config, pkgs, lib, ... }:

let
  hyprlandConfigDir = ../linux/.config/hypr;
in
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Required packages for Hyprland
  environment.systemPackages = with pkgs; [
    kitty           # Terminal
    wofi            # App launcher
    waybar          # Status bar
    dunst           # Notifications
    hyprpaper       # Wallpaper
    wl-clipboard    # Clipboard
    grim            # Screenshot
    slurp           # Screen area selection
    swaylock        # Screen lock
    brightnessctl   # Brightness control
    pamixer         # Audio control
  ];

  # XDG portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Enable polkit for authentication dialogs
  security.polkit.enable = true;

  # Session variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

}
