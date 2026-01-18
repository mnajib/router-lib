{ lib }:

let
  mkZone = { iface, cidr, role ? "trusted" }: {
    inherit iface cidr role;
  };
in
{
  inherit mkZone;
}

