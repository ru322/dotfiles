{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withRuby = true;
    extraPackages = with pkgs; [
      unzip
      cargo
      nodejs
      wl-clipboard
      ripgrep
    ];
  };

  xdg.configFile."nvim" = {
    source = ../.config/nvim;
    recursive = true;
  };

  xdg.configFile."clangd/config.yaml".source = ../.config/clangd/config.yaml;
}
