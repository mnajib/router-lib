{ lib }:

let
  mkWan = { iface, vlan ? null, dhcp ? true }: {
    inherit iface vlan dhcp;
  };
in
{
  inherit mkWan;
}

