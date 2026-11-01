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

      # Slideshow from ~/Pictures/Wallpapers.
      wallpaper.directory = "~/Pictures/Wallpapers";
      wallpaper.automation = {
        enabled = true;
        interval_seconds = 1800;
        order = "random";
      };

      # Blurred copy of the wallpaper; niri shows it instead of the sharp one
      # (see layer-rules in common/.config/niri/config.kdl).
      backdrop = {
        enabled = true;
        blur_intensity = 0.5;
        tint_intensity = 0.0;
      };

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
