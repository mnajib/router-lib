# Router-lib public contract

The API

## Public surface (what users are allowed to touch)

```nix
router = {
  enable = true;

  stage = "stage-1";

  stages = { ... };

  zones = { ... };

  wan = { ... };

  nat = { ... };

  dhcp = { ... };

  firewall = { ... };
};
```

Everything else is private implementation.

## Example (what users write)


```nix
router = {
  stage = "stage-1";
  stages = {
    stage-1 = {
      wan.enable = false;
      nat.enable = false;
    };

    stage-2 = {
      wan.enable = true;
      nat.enable = true;
    };
  };

  zones = {
    lan = mkZone {
      iface = "enp3s0";
      cidr  = "192.168.0.0/24";
      role  = "trusted";
    };

    guest = mkZone {
      iface = "enp4s0";
      cidr  = "192.168.50.0/24";
      role  = "guest";
    };

    dmz = mkZone {
      iface = "enp5s0";
      cidr  = "192.168.60.0/24";
      role  = "dmz";
    };
  };

  dhcp.enable = true;

  firewall.policy = {
    guest = {
      allow = [ "dns" "http" "https" ];
      deny  = [ "lan" ];
    };
  };
};
```
