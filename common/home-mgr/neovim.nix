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
      fd
      tree-sitter
      gcc
      gnumake
      python3
    ];
  };

  xdg.configFile."nvim" = {
    source = ../.config/nvim;
    recursive = true;
  };

  # LazyVim lives side by side: launch with NVIM_APPNAME=lazyvim (fish abbr `lv`).
  xdg.configFile."lazyvim" = {
    source = ../.config/lazyvim;
    recursive = true;
  };

  xdg.configFile."clangd/config.yaml".source = ../.config/clangd/config.yaml;
}
