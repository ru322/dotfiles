{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withRuby = true;
    extraPackages = with pkgs; [
      nodejs
      wl-clipboard
      ripgrep
    ];
  };

  xdg.configFile."nvim" = {
    source = ../.config/nvim;
    recursive = true;
  };
}
