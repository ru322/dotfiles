{ pkgs, ... }:
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "gimp";
      paths = [ pkgs.gimp ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for bin in $out/bin/gimp $out/bin/gimp-3.*; do
          wrapProgram "$bin" --set LANG ja_JP.UTF-8
        done
      '';
    })
  ];
}
