# router-lib

Stage-based, zone-oriented router library for NixOS.

## What is router-lib?

router-lib helps you declaratively define routers in NixOS using **zones** (network segments),
**stages** (deployment phases), and **presets** (common setups). It translates pure definitions into
NixOS configurations, making router roles reproducible and modular.

## About This Project

This project is part of my learning journey with NixOS and networking.
I’m building router-lib not just as a tool, but as a way to explore how modular, declarative design can make routers easier to understand and configure.

- Why? Most router setups in NixOS are either too complex or scattered across guides.
- Goal: Create an onboarding‑friendly library that learners (like me!) can use to grasp router concepts quickly.
- Approach: Start small with zones and stages, then grow into more advanced setups.

Feedback and contributions are welcome — they help me learn and improve this project.

## Key Concepts

- **Role**: Router is a role, not the system
- **Zone**: Named network segment (LAN / DMZ / GUEST)
- **Stage**: Deployment phase (stage-1 = internal test, stage-2 = WAN)
- **Translation**: Pure definitions → NixOS config

## Stages

Router-lib supports two stages: `stage-1` (internal testing) and `stage-2` (full deployment).
See [docs/stages.md](./docs/stages.md) for a detailed explanation and comparison.

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
{ lib, pkgs, ... }:

{
  router = {
    enable = true;
    stage  = "stage-1";

    zones = {
      lan = routerLib.lib.zone.mkZone {
        iface="enp3s0";
        cidr="192.168.0.0/24";
        role="trusted";
      };
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
- routerLib.lib.stage.mkStage – Define deployment stages (planned/experimental).
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
| router.nat.enable      | Enable NAT for outbound traffic  |

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

## Related Projects

### nixos-router

A framework for writing NixOS router configurations, similar in spirit to simple-nixos-mailserver.

- Features: multiple DHCP servers, network namespaces, dynamic interfaces.
- Scope: ambitious, aimed at advanced networking setups.

## How router-lib Differs

- Onboarding-friendly: Clear concepts like zones and stages make router roles easy to grasp.
- Modular: Start small (a single LAN zone) and grow into multi‑zone, multi‑stage setups.
- Declarative: Pure definitions → reproducible NixOS configs.
- Teaching-oriented: Annotated examples and presets help learners not just use routers, but understand them.

## TODO / Roadmap

- [ ] Consider replacing fixed `stage` model with user‑customizable **profiles**
  - Allow users to define arbitrary profiles (e.g. `lab`, `wan-test`, `production`)
  - `router.profile` selects which profile is active
  - Profiles can specify zones, firewall rules, NAT, and services

  ```nix
  { lib, pkgs, ... }:

  {
    router = {
      enable = true;

      # Select which profile to activate
      profile = "dev"; # switch between "dev", "lab", "production", "wan-test"

      profiles = {
        dev = {
          # Situation: Development machine connected to existing home LAN.
          # DHCP must be off to avoid conflict with the home router.
          zones = {
            lan = routerLib.lib.zone.mkZone {
              iface = "enp3s0";
              cidr  = "192.168.0.0/24";
              role  = "trusted";
            };
          };
          dhcp.enable     = false; # home router already provides DHCP
          firewall.enable = true;  # still test firewall rules internally
          nat.enable      = false; # no WAN in dev mode
        };

        lab = {
          # Situation: Isolated test network (no connection to home LAN).
          # Safe to run DHCP and test zone isolation.
          zones = {
            lan = routerLib.lib.zone.mkZone {
              iface = "enp3s0";
              cidr  = "192.168.0.0/24";
              role  = "trusted";
            };
            dmz = routerLib.lib.zone.mkZone {
              iface = "eth1";
              cidr  = "172.16.0.0/24";
              role  = "semi-trusted";
            };
          };
          dhcp.enable     = true;  # provide IPs to lab clients
          firewall.enable = true;  # test firewall rules between LAN and DMZ
          nat.enable      = false; # no WAN in lab mode
        };

        production = {
          # Situation: Full router deployment with WAN connectivity.
          # Provides DHCP internally, NAT for internet access, and firewall rules.
          zones = {
            lan = routerLib.lib.zone.mkZone {
              iface = "enp3s0";
              cidr  = "192.168.0.0/24";
              role  = "trusted";
            };
            dmz = routerLib.lib.zone.mkZone {
              iface = "eth1";
              cidr  = "172.16.0.0/24";
              role  = "semi-trusted";
            };
            wan = routerLib.lib.zone.mkZone {
              iface = "ppp0";
              role  = "external";
            };
          };
          dhcp.enable     = true;  # provide IPs internally
          firewall.enable = true;  # enforce LAN/DMZ/WAN rules
          nat.enable      = true;  # internet access via WAN
        };

        wan-test = {
          # Situation: Test router connected via WAN interface into existing home network.
          # NAT is enabled so test clients can reach the home LAN/internet,
          # but DHCP must be off to avoid conflict with the home router.
          zones = {
            lan = routerLib.lib.zone.mkZone {
              iface = "enp3s0";
              cidr  = "10.10.0.0/24";
              role  = "trusted";
            };
            wan = routerLib.lib.zone.mkZone {
              iface = "eth2"; # connected to home router's LAN
              role  = "external";
            };
          };
          dhcp.enable     = false; # home router already provides DHCP
          firewall.enable = true;  # test NAT/firewall rules with WAN traffic
          nat.enable      = true;  # NAT allows test LAN clients to reach home LAN/internet
        };
      };
    };
  }
  ```

## License

MIT License
