{ ... }:
{
  # fcitx5 profile: Japanese keyboard plus karukan as the default input method.
  # fcitx5 forwards keys with the group layout, so a "us" default makes
  # Xwayland apps (e.g. Unity) see a US keymap. Read-only: configtool can't save.
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      Name=Default
      Default Layout=jp
      DefaultIM=karukan

      [Groups/0/Items/0]
      Name=keyboard-jp
      Layout=

      [Groups/0/Items/1]
      Name=karukan
      Layout=jp

      [GroupOrder]
      0=Default
    '';
  };

  # Read-only: the file is regenerated on activation, so edit settings here.
  # Restart fcitx5 (`fcitx5 -r -d`) to pick up changes.
  xdg.configFile."karukan-im/config.toml" = {
    force = true;
    text = ''
      [conversion]
      # Convert on Space only, like the old hazkey setup.
      live_conversion = false
    '';
  };
}
