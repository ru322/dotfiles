{ config, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "ru322";
      user.email = "168622173+ru322@users.noreply.github.com";
      ghq.root = "${config.home.homeDirectory}/src";
    };
  };
}
