{ lib, config }:

let
  zones = config.router.zones;

  ifaceByZone = lib.mapAttrs (_: z: z.iface) zones;
in
{
  networking.firewall = {
    enable = true;

    interfaces =
      lib.mapAttrs
        (_: iface: {
          allowedTCPPorts = [ 53 80 443 ];
          allowedUDPPorts = [ 53 ];
        })
        ifaceByZone;
  };
}

