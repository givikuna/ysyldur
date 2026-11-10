{ config, lib, ... }:
let
  schedCfg = config.ysyldur.services.scx.scheduler;
  schedNames = [
    "bpfland"
    "cosmos"
    "flash"
    "lavd"
    "layered"
    "nest"
    "p2dq"
    "rustland"
    "rusty"
    "tickless"
  ];
  enabledScheds = lib.filter (name: schedCfg.${name}.enable) schedNames;
  activeSched = if enabledScheds != [ ] then "scx_${lib.head enabledScheds}" else null;
  extraArgs = config.ysyldur.services.scx.extraArgs;
in
{
  imports = [
    ./options/bpfland.nix
    ./options/cosmos.nix
    ./options/flash.nix
    ./options/lavd.nix
    ./options/layered.nix
    ./options/nest.nix
    ./options/p2dq.nix
    ./options/rustland.nix
    ./options/rusty.nix
    ./options/tickless.nix
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = (lib.length enabledScheds) <= 1;
          message = "ysyldur: only one scx scheduler may be enabled at a time (enabled: ${builtins.toJSON enabledScheds}).";
        }
      ];
    }

    (lib.mkIf (activeSched != null && extraArgs != [ ]) {
      services.scx-loader.config.${activeSched}.auto_mode = extraArgs;
    })
  ];
}
