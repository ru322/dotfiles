# MATLAB in a distrobox container.
# Nix manages only the container definition and the launcher; MATLAB itself is
# installed manually with mpm into $HOME (see README), so it survives container
# rebuilds. Requires podman on the host (common/nixos/podman.nix).
{ pkgs, config, ... }:
let
  release = "R2026b";
  matlabRoot = "${config.home.homeDirectory}/.local/opt/MATLAB/${release}";
  matlab = pkgs.writeShellScriptBin "matlab" ''
    exec ${config.programs.distrobox.package}/bin/distrobox enter matlab -- ${matlabRoot}/bin/matlab "$@"
  '';
in
{
  programs.distrobox = {
    enable = true;
    # ~/.config/distrobox/containers.ini; the distrobox-home-manager user unit
    # runs `distrobox assemble create` whenever it changes.
    containers.matlab = {
      # MathWorks' official image with only MATLAB's runtime dependencies
      image = "docker.io/mathworks/matlab-deps:r2026b-ubuntu24.04";
      additional_packages = "wget ca-certificates";
      entry = false;
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
