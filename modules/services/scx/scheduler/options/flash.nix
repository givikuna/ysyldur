{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.flash;
in
{
  options.ysyldur.services.scx.scheduler.flash.enable = lib.mkEnableOption "scx flash scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_flash";
  };
}
