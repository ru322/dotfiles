{ pkgs, ... }:
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
    [Behavior]
    ActiveByDefault=False

    [Hotkey/TriggerKeys]
    0=Zenkaku_Hankaku
    1=Control+space
  '';

  # GTK/libadwaita apps read the dark preference from dconf even outside GNOME.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
