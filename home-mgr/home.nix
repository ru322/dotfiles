{ pkgs, ... }:
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
    ./sunshine.nix
    ./wl-clipboard.nix
    ./git.nix
    ./zsh.nix
  ];

  # Hyprland config
  xdg.configFile."hypr" = {
    source = ../linux/.config/hypr;
    recursive = true;
  };

  home.packages = with pkgs; [
    vscode
  ];
}
