{ config, lib, ... }:
let
  cfg = config.ysyldur.drivers.xone;
in
{
  options.ysyldur.drivers.xone.enable =
    lib.mkEnableOption "xone Xbox One wired/dongle controller driver";

  config = lib.mkIf cfg.enable {
    hardware.xone.enable = true;
  };
}
