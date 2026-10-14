{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.nvidia_stable;
in
{
  options.ysyldur.drivers.nvidia_stable.enable =
    lib.mkEnableOption "default stable drivers for NVIDIA";

  config = lib.mkIf cfg.enable {
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
