{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.nvidia_cachyos;
  hasCachyDriver = config.boot.kernelPackages.nvidiaPackages ? cachyos;
in
{
  options.ysyldur.drivers.nvidia_cachyos.enable =
    lib.mkEnableOption "drivers for NVIDIA through Chaotic-Nyx";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hasCachyDriver;
        message = "ysyldur: `ysyldur.drivers.nvidia_cachyos` requires `nvidiaPackages.cachyos` from Chaotic-Nyx.";
      }
    ];

    hardware.nvidia.package = lib.mkIf hasCachyDriver config.boot.kernelPackages.nvidiaPackages.cachyos;
  };
}
