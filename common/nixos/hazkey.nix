# Japanese input method configuration (fcitx5 + hazkey)
{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  hazkeyPkgs = inputs.nix-hazkey.packages.${pkgs.stdenv.system};
in
{
  imports = [ inputs.nix-hazkey.nixosModules.hazkey ];

  # Installs the fcitx5-hazkey addon and hazkey-settings, and runs
  # hazkey-server as a systemd user service.
  services.hazkey = {
    enable = true;
    # Zenzai on the GPU; pick the Vulkan device in hazkey-settings.
    server.package = hazkeyPkgs.hazkey-server.override { enableVulkan = true; };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # Compositors that implement zwp_input_method_v2 (niri, Hyprland) can use
    # the Wayland frontend; GNOME cannot, so it opts out in its own config.
    fcitx5.waylandFrontend = lib.mkDefault true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
    ];
  };
  environment.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
