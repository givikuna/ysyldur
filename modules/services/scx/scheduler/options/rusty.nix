{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.rusty;
in
{
  options.ysyldur.services.scx.scheduler.rusty.enable = lib.mkEnableOption "scx rusty scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_rusty";
  };
}
