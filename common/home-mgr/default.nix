# common/home-mgr default.nix
# Import this to get all common home-manager modules
{
  imports = [
    ./dev.nix
    ./direnv.nix
    ./git.nix
    ./neovim.nix
    ./sunshine.nix
    ./wl-clipboard.nix
    ./zsh.nix
  ];
}
