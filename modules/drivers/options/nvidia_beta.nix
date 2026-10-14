{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.nvidia_beta;
in
{
  options.ysyldur.drivers.nvidia_beta.enable = lib.mkEnableOption "beta drivers for NVIDIA";

  config = lib.mkIf cfg.enable {
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
}
