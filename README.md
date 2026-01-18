# router-lib

Stage-based, zone-oriented router library for NixOS.

## Key Concepts

- **Role**: Router is a role, not the system
- **Zone**: Named network segment (LAN / DMZ / GUEST)
- **Stage**: Deployment phase (stage-1 = internal test, stage-2 = WAN)
- **Translation**: Pure definitions → NixOS config

## Usage

```nix
{ lib, pkgs, routerLib }:

let mkZone = routerLib.lib.zone.mkZone;
in
{
  router = {
    enable = true;
    stage  = "stage-1";

    zones = {
      lan = mkZone { iface="enp3s0"; cidr="192.168.0.0/24"; role="trusted"; };
    };

    dhcp.enable = true;
  };
}

