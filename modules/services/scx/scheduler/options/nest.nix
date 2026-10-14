{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.nest;
in
{
  options.ysyldur.services.scx.scheduler.nest.enable = lib.mkEnableOption "scx nest scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_nest";
  };
}
