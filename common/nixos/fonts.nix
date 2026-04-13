# Common fonts configuration
{ pkgs, ... }:

let
  texliveFonts = pkgs.texliveInfraOnly.withPackages (ps: [ ps.haranoaji ]);
in

{
  fonts = {
    packages = with pkgs; [
      texliveFonts.fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      hack-font
    ];
    fontDir.enable = true;
  };
}
