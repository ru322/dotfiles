{ lib, pkgs, ... }:
let
  wallpaper = ../../resources/wallpapers/Top14.png;
  wallpaperUri = "file://${wallpaper}";

  # Pick a random wallpaper from ~/Pictures/Wallpapers (or ~/Pictures) and set
  # it for the desktop, dark-mode desktop and lock screen.
  randomWallpaper = pkgs.writeShellApplication {
    name = "gnome-random-wallpaper";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      glib
    ];
    text = ''
      dir=""
      for candidate in "$HOME/Pictures/Wallpapers" "$HOME/Pictures"; do
        if [ -d "$candidate" ]; then
          dir="$candidate"
          break
        fi
      done
      [ -n "$dir" ] || exit 0

      mapfile -t files < <(find "$dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
      [ "''${#files[@]}" -gt 0 ] || exit 0

      uri="file://''${files[RANDOM % ''${#files[@]}]}"
      gsettings set org.gnome.desktop.background picture-uri "$uri"
      gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
      gsettings set org.gnome.desktop.screensaver picture-uri "$uri"
    '';
  };
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.afterglow-cursors-recolored;
    name = "Afterglow-Recolored-Catppuccin-Pink";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Colloid theme/icons and the Afterglow Catppuccin cursor, following the
  # setup in OJII3's dotfiles. GTK4/libadwaita apps keep their own theme.
  gtk = {
    enable = true;
    theme = {
      package = pkgs.colloid-gtk-theme;
      name = "Colloid-Dark";
    };
    gtk4.theme = null;
    iconTheme = {
      package = pkgs.colloid-icon-theme;
      name = "Colloid-Dark";
    };
    cursorTheme = {
      package = pkgs.afterglow-cursors-recolored;
      name = "Afterglow-Recolored-Catppuccin-Pink";
      size = 24;
    };
  };

  xdg.configFile."fcitx5/config".text = ''
    [Behavior]
    ActiveByDefault=False

    [Hotkey/TriggerKeys]
    0=Zenkaku_Hankaku
    1=Control+space
  '';

  # Apply a wallpaper immediately on home-manager switch, and rotate it on a
  # timer afterwards.
  home.activation.gnomeWallpaper = lib.hm.dag.entryAfter [ "dconfSettings" ] ''
    run ${randomWallpaper}/bin/gnome-random-wallpaper || true
  '';

  systemd.user.services.gnome-wallpaper = {
    Unit.Description = "Set a random GNOME wallpaper from ~/Pictures";
    Service = {
      Type = "oneshot";
      ExecStart = "${randomWallpaper}/bin/gnome-random-wallpaper";
      # The user manager may not inherit the session bus address, but dconf
      # lives on it.
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
    };
  };

  systemd.user.timers.gnome-wallpaper = {
    Unit.Description = "Rotate the GNOME wallpaper every 30 minutes";
    Timer = {
      OnStartupSec = "30s";
      OnUnitActiveSec = "30m";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "jp"
        ])
      ];
    };

    "org/gnome/desktop/background" = {
      picture-uri = wallpaperUri;
      picture-uri-dark = wallpaperUri;
      picture-options = "zoom";
    };

    "org/gnome/desktop/interface" = {
      accent-color = "blue";
      clock-format = "24h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Afterglow-Recolored-Catppuccin-Pink";
      enable-hot-corners = false;
      gtk-theme = "Colloid-Dark";
      icon-theme = "Colloid-Dark";
      monospace-font-name = "HackGen Console NF 11";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/calendar".show-weekdate = true;

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      tap-and-drag = true;
      disable-while-typing = true;
      accel-profile = "adaptive";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = wallpaperUri;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Close with Super+Q in addition to Alt+F4.
      close = [
        "<Super>q"
        "<Alt>F4"
      ];
      # Match Windows' virtual desktop navigation shortcuts.
      switch-to-workspace-left = [ "<Super><Control>Left" ];
      switch-to-workspace-right = [ "<Super><Control>Right" ];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      default-sort-order = "name";
    };

    "org/gnome/settings-daemon/plugins/color".night-light-enabled = false;

    # Simple launch shortcuts: Super+Return for a terminal and Super+E for the
    # file manager.
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/files/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
      name = "Terminal";
      command = "kitty";
      binding = "<Super>Return";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/files" = {
      name = "Files";
      command = "nautilus";
      binding = "<Super>e";
    };

    # Tray icons for Steam, Discord and other AppIndicator/StatusNotifier
    # applications, plus the permanent left dock.
    "org/gnome/shell" = {
      # GNOME hides Log Out for a single local user with one session type;
      # keep it visible in the system menu.
      always-show-log-out = true;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "dash-to-dock@micxgx.gmail.com"
        "clipboard-indicator@tudmotu.com"
        "blur-my-shell@aunetx"
      ];
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "kitty.desktop"
        "org.gnome.Settings.desktop"
      ];
    };

    "org/gnome/shell/keybindings" = {
      # Do not launch or focus pinned applications with Super+1 through Super+9.
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
      # Free Super+V for the clipboard history (Super+M keeps the tray).
      toggle-message-tray = [ "<Super>m" ];
    };

    # Clipboard history on Super+V.
    "org/gnome/shell/extensions/clipboard-indicator" = {
      toggle-menu = [ "<Super>v" ];
      enable-keybindings = true;
      history-size = 50;
      show-search-bar = true;
    };

    # A fixed, full-height dock on the left, with the app grid button on top.
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "LEFT";
      dock-fixed = true;
      autohide = false;
      intellihide = false;
      extend-height = true;
      dash-max-icon-size = 24;
      show-apps-at-top = true;
      show-show-apps-button = true;
      show-trash = false;
      show-mounts = false;
      click-action = "focus-minimize-or-previews";
      scroll-action = "cycle-windows";
      running-indicator-style = "DOTS";
      # Flush, square edges against the screen (no rounded blur gaps).
      force-straight-corner = true;
    };

    "org/gnome/shell/extensions/blur-my-shell.dash-to-dock" = {
      corner-radius = 0;
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.blur-my-shell
  ];
}
