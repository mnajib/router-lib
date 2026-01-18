# router-lib

Stage-based, zone-oriented router library for NixOS.

## What is router-lib?

router-lib helps you declaratively define routers in NixOS using zones (network segments),
stages (deployment phases), and presets (common setups). It translates pure definitions into
NixOS configurations, making router roles reproducible and modular.

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

## Why Another Router Library?

When exploring NixOS as a router, you’ll quickly discover that there are already projects tackling this space:

- nixos-router (github.com in Bing) – a powerful framework that supports multiple DHCP servers, network namespaces, and dynamic interfaces. It’s ambitious and well-suited for complex, production-grade setups.
- nixos-routers (community configs) – collections of reproducible router configurations. These are practical examples but not reusable libraries.

### So why build router-lib?

Because most existing solutions are either too complex for newcomers or too rigid for learners who want to experiment. router-lib is designed to be:

- Onboarding-friendly – clear concepts like zones and stages make router roles easy to grasp.
- Modular – you can start small (a single LAN zone) and grow into multi-zone, multi-stage setups.
- Declarative – pure definitions translate directly into reproducible NixOS configs.
- Teaching-oriented – annotated examples and presets help learners not just use routers, but understand them.

### In short:

- nixos-router is the power tool for advanced networking.
- router-lib is the learning scaffold for anyone who wants to make routers modular, reproducible, and loveable.

## License

MIT License
