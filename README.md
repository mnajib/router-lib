# router-lib

Stage-based, zone-oriented router library for NixOS.

## What is router-lib?

router-lib helps you declaratively define routers in NixOS using zones (network segments),
stages (deployment phases), and presets (common setups). It translates pure definitions into
NixOS configurations, making router roles reproducible and modular.

## About This Project

This project is part of my learning journey with NixOS and networking.
I’m building router-lib not just as a tool, but as a way to explore how modular, declarative design can make routers easier to understand and configure.

- Why? Most router setups in NixOS are either too complex or scattered across guides.
- Goal: Create an onboarding‑friendly library that learners (like me!) can use to grasp router concepts quickly.
- Approach: Start small with zones and stages, then grow into more advanced setups.

I welcome feedback, suggestions, and contributions — they help me learn and improve this project.

## Key Concepts

- **Role**: Router is a role, not the system
- **Zone**: Named network segment (LAN / DMZ / GUEST)
- **Stage**: Deployment phase (stage-1 = internal test, stage-2 = WAN)
- **Translation**: Pure definitions → NixOS config

## Quickstart / Usage

### Directory Structure

Place your configs under (for example) /etc/nixos/

```
/etc/nixos/
├── flake.nix
├── configuration.nix
└── router/
    ├── zones.nix
    └── presets.nix
```

### Add router-lib to flake.nix

```nix
{
  description = "My NixOS system with router-lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    router-lib.url = "github:mnajib/router-lib";
  };

  outputs = { self, nixpkgs, router-lib, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.my-router = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          router-lib.nixosModules.default
        ];
      };
    };
}
```

### Configure in configuration.nix

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
```

### Apply Your Configuration

```
sudo nixos-rebuild switch --flake /etc/nixos#my-router
```

## API Overview

### Core Functions

- routerLib.lib.zone.mkZone – Define a zone (interface, CIDR, role).
- routerLib.lib.stage.mkStage – Define deployment stages.
- routerLib.lib.preset.* – Use presets for common router setups.

### Module Options

When you import 'router-lib.nixosModules.default', you gain:

| Option                 | Purpose                          |
| ---------------------- | ---------------------------------|
| router.enable          | Enable router role               |
| router.stage           | Select deployment stage          |
| router.zones           | Define zones via mkZone          |
| router.dhcp.enable     | Enable DHCP service              |
| router.firewall.enable | Enable firewall rules per zone   |
| router.nat.enable      | Enable NAT for outbound traffice |

### Example: Multi-Zone Router

```nix
{
  router = {
    enable = true;
    stage = "stage-2";

    zones = {
      lan = routerLib.lib.zone.mkZone {
        iface = "enp3s0";
        cidr  = "192.168.0.0/24";
        role  = "trusted";
      };
      guest = routerLib.lib.zone.mkZone {
        iface = "wlan0";
        cidr  = "10.0.0.0/24";
        role  = "untrusted";
      };
    };

    dhcp.enable = true;
    firewall.enable = true;
    nat.enable = true;
  };
}
```

## Why Use router-lib?

- Modular: Define zones and stages separately.
- Declarative: Pure definitions → reproducible configs.
- Flexible: Mix presets with custom zones.
- NixOS-native: Integrates directly with flakes and modules.

## License

MIT License
