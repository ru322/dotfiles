{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs
      wl-clipboard
    ];
  };

  xdg.configFile."nvim" = {
    source = ../.config/nvim;
    recursive = true;
  };
}
