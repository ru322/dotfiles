# Hyprland configuration
{ pkgs, ... }:

let
  # Noctalia's backdrop layer (the blurred wallpaper used by niri) is
  # niri-only. Hyprland gets a pre-blurred, dimmed wallpaper instead.
  blurredWallpaper = pkgs.runCommand "hyprland-wallpaper-blurred.png" { } ''
    ${pkgs.imagemagick}/bin/magick \
      ${../../resources/wallpapers/Top14.png} \
      -blur 0x20 \
      -evaluate Multiply 0.75 \
      $out
  '';
in
{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Required packages for Hyprland
  environment.systemPackages = with pkgs; [
    kitty # Terminal
    wofi # App launcher
    quickshell # Status bar
    dunst # Notifications
    hyprpaper # Wallpaper
    wl-clipboard # Clipboard
    grim # Screenshot
    slurp # Screen area selection
    grimblast # Screenshot helper (area/output/active window)
    swaylock # Screen lock
    brightnessctl # Brightness control
    pamixer # Audio control
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

  environment.etc."hypr/Top14-blurred.png".source = blurredWallpaper;
}
