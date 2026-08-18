{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unityhub
    dotnet-sdk_8
  ];
}
