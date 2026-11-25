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
    # kitty's font (common/home-mgr/kitty.nix). Home Manager's fontconfig
    # picks this up from the user profile.
    udev-gothic-nf
    godot
    remmina
    yuview
    kdePackages.kate
    kdePackages.dolphin
    moonlight-qt
    spotify-player
    zed-editor
    thorium-reader
  ];
}
