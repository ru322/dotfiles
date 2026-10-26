{ config, lib, ... }:
{
  programs.firefox = {
    enable = true;
    # Installed by common/nixos/programs.nix; only the profile is managed here.
    package = null;
    configPath = "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      id = 0;
      isDefault = true;
      # Existing profile directory, so history and logins are kept.
      path = "ykx3zsb2.default";
      settings = {
        # Always go through xdg-desktop-portal so the file chooser is yazi
        # (termfilechooser, see common/nixos/niri.nix).
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
