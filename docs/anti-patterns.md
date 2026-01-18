# Router-lib Anti-Patterns

This document explains patterns we intentionally avoid.

router-lib is a *library*, not a router distribution.

---

## 1. "Router owns the system"

### Anti-pattern

```nix
networking.firewall.enable = true;
services.dnsmasq.enable = true;
```

### Why it's bad

- Router logic leaks everywhere
- Hard to reuse host for other roles
- Impossible to stage deployments

### router-lib solution

Router is a role, not an identity

## 2. Interface-first thinking

### Anti-pattern

```nix
interfaces.enp3s0.allowedTCPPorts = [ 22 80 ];
```

### Why it's bad

- Interface names change
- No semantic meaning
- Policy becomes unreadable

### router-lib solution

Zones are the unit of reasoning.

## 3. Copy-paste firewall rules

### Anti-pattern

- Forking nixos-router
- Editing iptables snippets
- Cargo-cult NAT rules

### Why it's bad

- No ownership
- No explanation
- No evolution path

### router-lib solution

Policy → translation → NixOS

## 4. One-shot router install

### Anti-pattern

- Fresh install
- Immediate WAN takeover

### Why it's bad

- Risky
- Hard to debug
- No rollback

### router-lib solution

Stage-1 → Stage-2 progression


