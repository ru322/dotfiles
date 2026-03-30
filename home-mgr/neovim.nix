{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs
    ];
  };

  xdg.configFile."nvim" = {
    source = ../common/.config/nvim;
    recursive = true;
  };
}
