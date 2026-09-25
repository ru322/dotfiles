{ pkgs, ... }:
{
  imports = [ ./vscode.nix ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    github-copilot-cli
    nodejs
    pre-commit
    nixfmt-rfc-style
    gcc
    gnumake
    gdb
    uv
    python314
    cargo
    cloudflare-warp
    docker-compose
    supabase-cli
    postgresql
    typst
    pnpm
    mise
    ripgrep
    tree
    flex
    qpdf
    poppler-utils
    bison
    tshark
    tmux
    bc
    ghq
    fzf
    ffmpeg
    gh
    unzip
    zip
  ];
}
