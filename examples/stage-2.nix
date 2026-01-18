{ lib, config, pkgs, routerLib }:

let mkZone = routerLib.lib.zone.mkZone;
let mkWan  = routerLib.lib.wan.mkWan;
in {
  router = {
    enable = true;
    stage  = "stage-2";

    zones = {
      lan   = mkZone { iface="enp3s0"; cidr="192.168.1.0/24"; role="trusted"; };
      guest = mkZone { iface="enp4s0"; cidr="192.168.50.0/24"; role="guest"; };
      dmz   = mkZone { iface="enp5s0"; cidr="192.168.60.0/24"; role="dmz"; };
    };

    dhcp.enable = true;

    wan = mkWan {
      iface = "enp2s0";
      vlan  = 500;
      dhcp  = true;
    };

    nat.enable = true;
  };
}

