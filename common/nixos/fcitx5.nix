# Japanese input method configuration (fcitx5 + mozc)
{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs;[
      fcitx5-mozc 
      fcitx5-gtk 
    ];
  };
  environment.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "ibus";
  };
}
