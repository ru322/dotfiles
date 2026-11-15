{ config, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
        "--accept-routes=true"
        "--operator=koyama"
    ];
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # On Linux, Taildrop files are staged in tailscaled's root-only inbox
  # (/var/lib/tailscale/files/) and never delivered automatically.
  # This service drains the inbox into ~/Downloads as they arrive.
  systemd.services.tailscale-taildrop = {
    description = "Tailscale Taildrop receiver";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "koyama";
      Restart = "on-failure";
      RestartSec = "15s";
      ConditionPathIsDirectory = "%h/Downloads";
      ExecStart = "${config.services.tailscale.package}/bin/tailscale file get --loop --verbose --conflict=rename %h/Downloads";
    };
  };
}
