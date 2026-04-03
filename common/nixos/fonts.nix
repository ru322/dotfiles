# Common fonts configuration
{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      hack-font
    ];
    fontDir.enable = true;
  };
}
