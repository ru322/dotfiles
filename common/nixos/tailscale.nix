{ config, pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
        "--accept-routes=true"
    ];  
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
