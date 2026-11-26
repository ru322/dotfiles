# Japanese input method configuration (fcitx5 + karukan)
{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  karukan = pkgs.callPackage ../pkgs/karukan.nix {
    src = inputs.karukan;
    rev = inputs.karukan.rev or null;
  };
in
{
  # Installs the fcitx5-karukan addon.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # GNOME does not implement zwp_input_method_v2, so Satori opts out in its
    # own configuration.
    fcitx5.waylandFrontend = lib.mkDefault true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      karukan
    ];
  };
  environment.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
