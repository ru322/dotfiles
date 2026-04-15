{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    github-copilot-cli
    nodejs
    vscode
    pre-commit
    nixfmt-rfc-style
    gcc
    gnumake
    gdb
    uv
    docker-compose
    supabase-cli
    postgresql
    typst
    pnpm
  ];
}
