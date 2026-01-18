{ lib, config }:

let
  stageName = config.router.stage;
  stageCfg  = config.router.stages.${stageName} or {};
in
{
  resolved = {
    wan.enable = stageCfg.wan.enable or false;
    nat.enable = stageCfg.nat.enable or false;
  };
}

