{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.nvidia_cachyos;
in
{
  options.ysyldur.drivers.nvidia_cachyos.enable =
    lib.mkEnableOption "drivers for NVIDIA through Chaotic-Nyx";

  config = lib.mkIf cfg.enable {
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.cachyos;
  };
}
