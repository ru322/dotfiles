{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unityhub
    dotnet-sdk_8
    jetbrains.rider
  ];
}
