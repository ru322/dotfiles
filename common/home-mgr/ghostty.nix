{ ... }:
{
  programs.ghostty = {
    enable = true;
  };
  xdg.configFile."ghostty" = {
    source = ../.config/ghostty;
    recursive = true;
  };
}
