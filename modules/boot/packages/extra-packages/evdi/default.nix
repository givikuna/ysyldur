{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.extra-packages.evdi;
in
{
  options.ysyldur.boot.packages.extra-packages.evdi.enable =
    lib.mkEnableOption "EVDI DisplayLink kernel module";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
    boot.kernelModules = [ "evdi" ];
  };
}
