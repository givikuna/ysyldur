{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.packages.zenpower;
in
{
  options.ysyldur.boot.packages.packages.zenpower.enable =
    lib.mkEnableOption "zenpower AMD Ryzen sensor kernel module (blacklists k10temp)";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
    boot.kernelModules = [ "zenpower" ];
    boot.blacklistedKernelModules = [ "k10temp" ];
  };
}
