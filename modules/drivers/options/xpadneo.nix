{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.xpadneo;
in
{
  options.ysyldur.drivers.xpadneo.enable =
    lib.mkEnableOption "xpadneo Xbox One wireless gamepad driver";

  config = lib.mkIf cfg.enable {
    hardware.xpadneo.enable = true;
  };
}
