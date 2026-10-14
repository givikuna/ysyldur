{ config, lib, ... }:
let
  drvCfg = config.ysyldur.drivers;
  nvidiaBranches = [
    "nvidia_cachyos"
    "nvidia_stable"
    "nvidia_beta"
    "nvidia_production"
  ];
  enabledNvidia = lib.filter (name: drvCfg.${name}.enable) nvidiaBranches;
in
{
  imports = [
    ./options/nvidia_cachyos.nix
    ./options/nvidia_stable.nix
    ./options/nvidia_beta.nix
    ./options/nvidia_production.nix
    ./options/amdgpu.nix
    ./options/xpadneo.nix
    ./options/xone.nix
  ];

  config.assertions = [
    {
      assertion = (lib.length enabledNvidia) <= 1;
      message = "ysyldur: only one NVIDIA driver package branch can be enabled at a time (enabled: ${builtins.toJSON enabledNvidia}).";
    }
  ];
}
