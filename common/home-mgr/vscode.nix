{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        # VS Code still requests unpacked assets after nixpkgs extracts the ASAR.
        app="$out/lib/vscode/resources/app"
        if [ ! -e "$app/node_modules.asar.unpacked" ] && [ ! -L "$app/node_modules.asar.unpacked" ]; then
          ln -s node_modules "$app/node_modules.asar.unpacked"
        fi
      '';
    });
  };
}
