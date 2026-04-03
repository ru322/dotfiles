# common/nixos default.nix
# Import this to get all common NixOS modules
{
  imports = [
    ./fcitx5.nix
    ./fonts.nix
    ./hyprland.nix
    ./programs.nix
    ./ssh.nix
    ./tailscale.nix
  ];
}
