{ lib }:

let
  mkNat = { enable ? true }: { inherit enable; };
in
{
  inherit mkNat;
}

