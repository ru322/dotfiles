# Common programs configuration
{ pkgs, ... }:

{
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0";
  };

  users.defaultUserShell = pkgs.zsh;

  programs = {
    firefox.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    starship.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
  };
}
