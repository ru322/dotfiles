# Satori-only GNOME settings.
#
# The shared GNOME setup (themes, dock, clipboard history, wallpaper
# rotation, shortcuts) lives in common/home-mgr/gnome.nix. Keep only
# laptop-specific power behaviour here.
{ ... }:
{
  # Do not auto-suspend while on AC (long builds and agent runs are common);
  # on battery, suspend after 30 minutes.
  dconf.settings."org/gnome/settings-daemon/plugins/power" = {
    sleep-inactive-ac-type = "nothing";
    sleep-inactive-battery-type = "suspend";
    sleep-inactive-battery-timeout = 1800;
  };
}
