# MATLAB in a distrobox container.
# Nix manages only the container definition and the launcher; MATLAB itself is
# installed manually with mpm into $HOME (see README), so it survives container
# rebuilds. Requires podman on the host (common/nixos/podman.nix).
{ pkgs, config, ... }:
let
  release = "R2026b";
  matlabRoot = "${config.home.homeDirectory}/.local/opt/MATLAB/${release}";
  # MATLABWindow (the Qt/CEF window used for sign-in and the desktop) ships
  # only the xcb platform plugin, so override niri's QT_QPA_PLATFORM=wayland.
  # QT_PLUGIN_PATH points at the host's Nix Qt plugins, which must not be loaded.
  # MATLAB bundles no fcitx Qt plugin, only ibus; fcitx5's IBus frontend serves
  # it through org.freedesktop.portal.IBus on the session bus (the address-file
  # lookup fails because the container has its own /var/lib/dbus/machine-id).
  matlab = pkgs.writeShellScriptBin "matlab" ''
    exec ${config.programs.distrobox.package}/bin/distrobox enter matlab -- \
      env -u QT_PLUGIN_PATH QT_QPA_PLATFORM=xcb QT_IM_MODULE=ibus IBUS_USE_PORTAL=1 \
      ${matlabRoot}/bin/matlab "$@"
  '';
in
{
  programs.distrobox = {
    enable = true;
    # ~/.config/distrobox/containers.ini; the distrobox-home-manager user unit
    # runs `distrobox assemble create` whenever it changes, and `replace`
    # recreates the container so package changes take effect.
    containers.matlab = {
      # MathWorks' official image with only MATLAB's runtime dependencies
      image = "docker.io/mathworks/matlab-deps:r2026b-ubuntu24.04";
      # The image has no CJK fonts, so Japanese text renders as tofu
      additional_packages = "wget ca-certificates fonts-noto-cjk";
      entry = false;
      replace = true;
    };
  };

  home.packages = [ matlab ];

  xdg.desktopEntries.matlab = {
    name = "MATLAB ${release}";
    exec = "${matlab}/bin/matlab -desktop";
    categories = [ "Development" "Science" ];
    terminal = false;
  };
}
