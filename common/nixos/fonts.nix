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
      hackgen-nf-font
      nerd-fonts."m+"
    ];
    fontDir.enable = true;
    fontconfig.defaultFonts = {
      serif = [ "Harano Aji Mincho" ];
      sansSerif = [ "Harano Aji Gothic" ];
      monospace = [ "HackGen Console NF" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
