{ lib, pkgs, ... }:
let
  wallpaper = ../../resources/wallpapers/Top14.png;
  wallpaperUri = "file://${wallpaper}";
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile."fcitx5/config".text = ''
    [Hotkey/TriggerKeys]
    0=Zenkaku_Hankaku
    1=Control+space
  '';

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
      clock-format = "24h";
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Adwaita";
      enable-hot-corners = false;
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = wallpaperUri;
      picture-options = "zoom";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Match Windows' virtual desktop navigation shortcuts.
      switch-to-workspace-left = [ "<Super><Control>Left" ];
      switch-to-workspace-right = [ "<Super><Control>Right" ];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
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
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.appindicator
  ];
}
