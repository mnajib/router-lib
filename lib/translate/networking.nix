{ lib, config }:

let
  zones = config.router.zones;
  wan   = config.router.wan;

  stage = import ../stages.nix { inherit lib config; };

  mkInterface = name: zone: {
    networking.interfaces.${zone.iface}.ipv4.addresses = [{
      address = lib.head (lib.splitString "/" zone.cidr);
      prefixLength = lib.toInt (lib.last (lib.splitString "/" zone.cidr));
    }];
  };

  mkZoneIface = _: z: {
    networking.interfaces.${z.iface}.ipv4.addresses = [{
      address = lib.head (lib.splitString "/" z.cidr);
      prefixLength = lib.toInt (lib.last (lib.splitString "/" z.cidr));
    }];
  };

  wanConfig =
    lib.mkIf stage.resolved.wan.enable (
      if wan.vlan != null then {
        networking.vlans.wan = {
          id = wan.vlan;
          interface = wan.iface;
        };
        networking.interfaces.wan.useDHCP = wan.dhcp;
      } else {
        networking.interfaces.${wan.iface}.useDHCP = wan.dhcp;
      }
    );
in
{
  networking.enableIPv4Forwarding = true;

  config = lib.mkMerge (lib.mapAttrsToList mkInterface zones);

  config = lib.mkMerge (
    (lib.mapAttrsToList mkZoneIface zones)
    ++ [ wanConfig ]
  );
}

