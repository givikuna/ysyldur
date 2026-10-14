{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.packages.ddcci;
in
{
  options.ysyldur.boot.packages.packages.ddcci.enable =
    lib.mkEnableOption "ddcci-driver external monitor brightness kernel module";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    boot.kernelModules = [
      "ddcci"
      "ddcci_backlight"
    ];
  };
}
