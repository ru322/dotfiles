{ pkgs, ... }:
{
  home.packages = [
    (pkgs.steam-run.override {
      extraPkgs = pkgs: with pkgs; [
        libpulseaudio
        alsa-lib
        alsa-plugins
      ];
    })
  ];
}
