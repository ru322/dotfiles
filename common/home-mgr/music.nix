{ pkgs, ... }:
{
  # /mnt/nas is a CIFS automount (no inotify), so rescan with `mpc update` after adding music.
  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/nas/Music";
    extraConfig = ''
      auto_update "no"
      restore_paused "yes"

      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  # Expose MPD over MPRIS for noctalia's media widget and media keys
  services.mpd-mpris.enable = true;

  programs.rmpc.enable = true;

  home.packages = with pkgs; [
    mpc
  ];
}
