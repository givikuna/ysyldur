{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.packages.v4l2loopback;
in
{
  options.ysyldur.boot.packages.packages.v4l2loopback.enable =
    lib.mkEnableOption "v4l2loopback virtual camera kernel module";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
  };
}
