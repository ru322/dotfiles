# common/nixos default.nix
# Import this to get all common NixOS modules
{
  imports = [
    ./hyprland.nix
    ./ssh.nix
    ./tailscale.nix
  ];
}
