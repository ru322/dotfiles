{ pkgs, ... }:
{
  home.packages = [
    (pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libpulseaudio
        alsa-lib
        alsa-plugins
      ];
    }).run
  ];
}
