{ pkgs, ... }:
{
  home = rec {
    username = "koyama";
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  imports = [
    ../../common/home-mgr/neovim.nix
    ../../common/home-mgr/dev.nix
    ../../common/home-mgr/sunshine.nix
    ../../common/home-mgr/wl-clipboard.nix
    ../../common/home-mgr/git.nix
    ../../common/home-mgr/zsh.nix
  ];

  # Hyprland config
  xdg.configFile."hypr" = {
    source = ../../common/.config/hypr;
    recursive = true;
  };

  home.packages = with pkgs; [
    vscode
  ];
}
