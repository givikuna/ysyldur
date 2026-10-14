{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.nvidia_production;
in
{
  options.ysyldur.drivers.nvidia_production.enable =
    lib.mkEnableOption "production branch drivers for NVIDIA";

  config = lib.mkIf cfg.enable {
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
