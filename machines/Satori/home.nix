{ pkgs, ... }:
{
  home = rec {
    username = "koyama";
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };
  programs.home-manager.enable = true;

  dconf.settings."org/gnome/desktop/interface".text-scaling-factor = 1.25;

  # GNOME stores per-monitor fractional scaling separately from dconf.
  xdg.configFile."monitors.xml" = {
    force = true;
    text = ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1.25</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>eDP-1</connector>
                <vendor>LGD</vendor>
                <product>0x0714</product>
                <serial>0x00000000</serial>
              </monitorspec>
              <mode>
                <width>1920</width>
                <height>1200</height>
                <rate>60.001</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    '';
  };

  imports = [
    ../../common/home-mgr/neovim.nix
    ../../common/home-mgr/dev.nix
    ../../common/home-mgr/desktop.nix
    ../../common/home-mgr/libreoffice.nix
    #../../common/home-mgr/sunshine.nix
    ../../common/home-mgr/wl-clipboard.nix
    ../../common/home-mgr/git.nix
    ../../common/home-mgr/tmux.nix
    ../../common/home-mgr/yazi.nix
    ../../common/home-mgr/yazi-gvfs.nix
    ../../common/home-mgr/zsh.nix
    #../../common/home-mgr/nixos-vscoder-server.nix
    #../../common/home-mgr/docker-cli.nix
    ../../common/home-mgr/codex.nix
    ../../common/home-mgr/chatgpt.nix
    ../../common/home-mgr/gnome.nix
    ../../common/home-mgr/discord.nix
    ../../common/home-mgr/steam.nix
    ../../common/home-mgr/obsidian.nix
    ../../common/home-mgr/unity.nix
  ];

  # Hyprland config
  #xdg.configFile."hypr" = {
  #  source = ../../common/.config/hypr;
  #  recursive = true;
  #};

  #home.packages = with pkgs; [
  #  vscode
  #];
}
