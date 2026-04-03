{ pkgs, ... }:
{
  programs.git.enable = true;
  programs.git.settings = {
    #enable = true;
    user.name = "ru322";
    user.email = "168622173+ru322@users.noreply.github.com";
  };
}
