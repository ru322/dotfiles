{pkgs, ...}:
{
  home = rec {
    username = "koyama";
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;
  imports = [
    ./neovim.nix
    ./dev.nix
  ];
}
