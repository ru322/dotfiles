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

  # fcitx5 forwards keys with the group layout, so a "us" default makes
  # Xwayland apps (e.g. Unity) see a US keymap. Read-only: configtool can't save.
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      Name=Default
      Default Layout=jp
      DefaultIM=mozc

      [Groups/0/Items/0]
      Name=keyboard-jp
      Layout=

      [Groups/0/Items/1]
      Name=mozc
      Layout=jp

      [GroupOrder]
      0=Default
    '';
  };

  # GTK/libadwaita apps read the dark preference from dconf even outside GNOME.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Used by xdg-desktop-portal-termfilechooser (enabled in common/nixos/niri.nix).
  # The wrapper opens yazi in `kitty --title termfilechooser`.
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    default_dir=$HOME
    open_mode=suggested
    save_mode=suggested
  '';
}
