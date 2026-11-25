{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.noctalia;

  # Noctalia's own backdrop layer is niri-only. On Hyprland, keep a blurred
  # copy of every wallpaper and let Noctalia's slideshow pick from that cache.
  wallpaperCache = "${config.home.homeDirectory}/.cache/noctalia-wallpapers-blurred";
  blurWallpapers = pkgs.writeShellScript "noctalia-blur-wallpapers" ''
    set -eu
    src="$HOME/Pictures/Wallpapers"
    dst="$HOME/.cache/noctalia-wallpapers-blurred"
    version="blur-0x20-darken-0.75"
    [ -d "$src" ] || exit 0
    mkdir -p "$dst"
    if [ "$(cat "$dst/.version" 2>/dev/null || true)" != "$version" ]; then
      find "$dst" -maxdepth 1 -type f -name '*.png' -delete
      printf '%s\n' "$version" > "$dst/.version"
    fi
    find "$src" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      -print | while IFS= read -r f; do
        out="$dst/$(basename "$f").png"
        if [ ! -e "$out" ] || [ "$f" -nt "$out" ]; then
          ${pkgs.imagemagick}/bin/magick "$f" -blur 0x20 -evaluate Multiply 0.75 "$out" || true
        fi
      done
  '';
in
{
  options.my.noctalia.blurWallpaper = lib.mkEnableOption "blurred wallpaper for compositors that don't support Noctalia's niri backdrop";

  config = {
    # Started from the compositor (niri spawn-at-startup or Hyprland exec-once).
    programs.noctalia = {
      enable = true;
      settings = {
        theme.mode = "dark";

        bar.default.background_opacity = 0.5;

        # Installed by common/nixos/niri.nix (niri) or hyprland.nix (Hyprland).
        wallpaper.default.path =
          if cfg.blurWallpaper then "/etc/hypr/Top14-blurred.png" else "/etc/niri/Top14.png";

        # Slideshow from ~/Pictures/Wallpapers, or blurred copies on Hyprland.
        wallpaper.directory = if cfg.blurWallpaper then wallpaperCache else "~/Pictures/Wallpapers";
        wallpaper.automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
        };

        # Blurred copy of the wallpaper for niri's overview. Hyprland uses the
        # pre-blurred wallpaper above instead.
        backdrop = {
          enabled = true;
          blur_intensity = 0.5;
          tint_intensity = 0.0;
        };

        # Community plugin that shows a searchable cheatsheet of the active
        # compositor's keybinds (the closest equivalent to niri's hotkey overlay).
        plugins.enabled = [ "kenn/keybind-cheatsheet" ];

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

    home.activation.noctaliaBlurWallpapers = lib.mkIf cfg.blurWallpaper (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${blurWallpapers}
      ''
    );

    systemd.user.services.noctalia-blur-wallpapers = lib.mkIf cfg.blurWallpaper {
      Unit.Description = "Blur Noctalia wallpapers";
      Service = {
        Type = "oneshot";
        ExecStart = "${blurWallpapers}";
        Path = [
          pkgs.findutils
          pkgs.coreutils
        ];
      };
    };

    systemd.user.timers.noctalia-blur-wallpapers = lib.mkIf cfg.blurWallpaper {
      Unit.Description = "Refresh blurred Noctalia wallpapers";
      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "30m";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
