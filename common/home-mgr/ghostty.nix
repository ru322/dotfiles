{ ... }:
{
  programs.ghostty = {
    enable = true;
  };
  xdg.configFile."ghostty" = {
    source = ../.config/ghostty;
    recursive = true;
  };
  xdg.configFile."ghostty/Top14.png".source = ../../resources/wallpapers/Top14.png;
}
