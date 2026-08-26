{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../pkgs/chatgpt.nix { })
  ];
}
