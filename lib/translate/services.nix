{ lib, config }:

let

  aps   = config.router.wifi.aps or {};
  zones = config.router.zones;

  stage = import ../stages.nix { inherit lib config; };

  internalIfaces = map (z: z.iface) (lib.attrValues zones);

  wanIface =
    if wan.vlan != null then "wan" else wan.iface;

in
{

  #------------------------------------
  # NAT
  #------------------------------------

  networking.nat = lib.mkIf stage.resolved.nat.enable {
    enable = true;
    externalInterface = wanIface;
    internalInterfaces = internalIfaces;
  };

  #------------------------------------
  # DHCP
  #------------------------------------

  services.dnsmasq = lib.mkIf config.router.dhcp.enable {
    enable = true;
    settings = {
      interface = map (z: z.iface) (lib.attrValues zones);
      dhcp-range =
        map
          (z:
            "${z.iface},${lib.head (lib.splitString "/" z.cidr)},static,12h"
          )
          (lib.attrValues zones);
    };
  };

  #------------------------------------
  # AP
  #------------------------------------

  services.hostapd = lib.mkIf (aps != {}) {
    enable = true;

    radios = lib.mapAttrs
      (_: ap: {
        interface = ap.iface;
        ssid = ap.ssid;
        wpa2.enable = true;
        wpa2.psk = ap.psk;
        bridge = zones.${ap.zone}.iface;
      })
      aps;
  };
}

