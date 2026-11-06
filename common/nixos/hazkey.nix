# Japanese input method configuration (fcitx5 + hazkey)
{ pkgs, inputs, ... }:
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
    fcitx5.waylandFrontend = true;
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
