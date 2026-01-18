{
  description = "Router library for NixOS – stage-based, zone-oriented, reusable";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages.${system} = {};

    nixosModules.router-lib = { config, lib, ... }:
      let
        stages    = import ./lib/stages.nix { inherit lib config; };
        networking = import ./lib/translate/networking.nix { inherit lib config; };
        firewall  = import ./lib/translate/firewall.nix { inherit lib config; };
        services  = import ./lib/translate/services.nix { inherit lib config; };
      in
      {
        options = import ./lib/types.nix { inherit lib; };

        config = lib.mkMerge [
          networking.config
          firewall
          services
        ];
      };
  };
}

