{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      keybind = [ "ctrl+d=new_split:right" ];
      font-family = "HackGen Console NF";
      # Translucency is for niri/Hyprland (which blur the wallpaper behind);
      # GNOME overrides these in machines/Satori/gnome.nix.
      background-opacity = 0.8;
      background-blur = true;
    };
  };
}
