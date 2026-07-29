{ config, pkgs, ... }:
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
  security.pam.services.swaylock = { };
  services.gnome.gnome-keyring.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    fuzzel
    mako
    swaybg
    swayidle
    swaylock
    waybar
    wl-clipboard
    xwayland-satellite
  ];

  environment.etc."niri/config.kdl".source = ../.config/niri/config.kdl;

  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = "gtk";
}
