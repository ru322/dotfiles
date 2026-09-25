{ pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
    python3
    networkmanager
    fuzzel
  ];

  xdg.configFile."quickshell" = {
    source = ../.config/quickshell;
    recursive = true;
  };
}
