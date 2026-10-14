{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.amdgpu;
in
{
  options.ysyldur.drivers.amdgpu = {
    enable = lib.mkEnableOption "AMDGPU early KMS and kernel module support";
    overdrive = lib.mkEnableOption "unlock AMDGPU voltage/clock control (amdgpu.ppfeaturemask=0xffffffff)";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];
    boot.kernelParams = lib.optional cfg.overdrive "amdgpu.ppfeaturemask=0xffffffff";
  };
}
