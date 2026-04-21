{ pkgs, ... }:
{
  programs.codex = {
    enable = true;
    package = pkgs.callPackage ../pkgs/codex.nix { };
  };
}
