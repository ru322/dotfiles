{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.onlyoffice;
  fonts = pkgs.buildEnv {
    name = "onlyoffice-fonts";
    paths = cfg.fonts;
    pathsToLink = [ "/share/fonts" ];
    ignoreCollisions = true;
  };
in
{
  options.programs.onlyoffice.fonts = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ pkgs.noto-fonts-cjk-sans-static ];
    defaultText = lib.literalExpression "[ pkgs.noto-fonts-cjk-sans-static ]";
    description = ''
      Font packages exposed in ONLYOFFICE's FHS environment.
      Static fonts are preferable because ONLYOFFICE does not reliably
      discover variable TTC fonts.
    '';
  };

  config.programs.onlyoffice = {
    enable = lib.mkDefault true;
    package = lib.mkDefault (
      pkgs.onlyoffice-desktopeditors.override {
        noto-fonts-cjk-sans = fonts;
      }
    );
  };
}
