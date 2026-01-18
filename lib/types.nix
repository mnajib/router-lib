{ lib }:

with lib.types;

{
  enable = lib.mkEnableOption "router-lib";

  stage = mkOption {
    type = str;
    description = "Active router deployment stage";
  };

  stages = mkOption {
    type = attrsOf (submodule {
      options = {
        wan.enable = lib.mkEnableOption "WAN in this stage";
        nat.enable = lib.mkEnableOption "NAT in this stage";
      };
    });
    default = {};
  };

  zones = mkOption {
    type = attrsOf (submodule {
      options = {
        iface = mkOption { type = str; };
        cidr  = mkOption { type = str; };
        role  = mkOption {
          type = enum [ "trusted" "guest" "dmz" ];
          default = "trusted";
        };
      };
    });
  };

  wan = mkOption {
    type = nullOr (submodule {
      options = {
        iface = mkOption { type = str; };
        vlan  = mkOption { type = nullOr int; default = null; };
        dhcp  = mkOption { type = bool; default = true; };
      };
    });
    default = null;
  };

  nat.enable = lib.mkEnableOption "NAT";

  dhcp.enable = lib.mkEnableOption "DHCP";

  firewall.policy = mkOption {
    type = attrs;
    default = {};
  };
}

