{ ... }:
{
  # Started from niri's spawn-at-startup (see common/.config/niri/config.kdl).
  programs.noctalia = {
    enable = true;
    settings = {
      theme.mode = "dark";

      bar.default.background_opacity = 0.5;

      # Installed by common/nixos/niri.nix.
      wallpaper.default.path = "/etc/niri/Top14.png";

      idle.behavior = {
        lock = {
          enabled = true;
          timeout = 3000;
          action = "lock";
        };
        screen-off = {
          enabled = true;
          timeout = 3060;
          action = "screen_off";
        };
      };
    };
  };
}
