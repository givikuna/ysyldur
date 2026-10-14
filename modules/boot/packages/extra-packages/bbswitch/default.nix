{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.extra-packages.bbswitch;
in
{
  options.ysyldur.boot.packages.extra-packages.bbswitch = {
    enable = lib.mkEnableOption "bbswitch kernel package";
    loadModule = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "automatically load the bbswitch kernel module.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.bbswitch ];
    boot.kernelModules = lib.optional cfg.loadModule "bbswitch";
  };
}
