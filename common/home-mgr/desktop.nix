{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    gimp
    godot
    yuview
    kdePackages.kate
  ];
}
