{ config, lib, pkgs, ... }:
let
  dimmedWallpaper = pkgs.runCommand "niri-wallpaper-dimmed.png" { } ''
    ${pkgs.imagemagick}/bin/magick \
      ${../../resources/wallpapers/Top14.png} \
      -evaluate Multiply 0.75 \
      $out
  '';
in
{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  # Battery widget in noctalia.
  services.upower.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    wl-clipboard
    setxkbmap
    wtype
    xwayland-satellite
  ];

  environment.etc."niri/config.kdl".source = ../.config/niri/config.kdl;
  environment.etc."niri/Top14.png".source = dimmedWallpaper;

  # File chooser runs yazi in a terminal (configured in common/home-mgr/niri.nix).
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce "termfilechooser";
}
