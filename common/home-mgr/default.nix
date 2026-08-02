# common/home-mgr default.nix
# Import this to get all common home-manager modules
{
  imports = [
    ./dev.nix
    ./direnv.nix
    ./git.nix
    ./neovim.nix
    ./sunshine.nix
    ./tmux.nix
    ./wl-clipboard.nix
    ./yazi.nix
    ./zsh.nix
  ];
}
