{ lib }:

let
  mkAp = { iface, zone, ssid, psk }: {
    inherit iface zone ssid psk;
  };
in
{
  inherit mkAp;
}

