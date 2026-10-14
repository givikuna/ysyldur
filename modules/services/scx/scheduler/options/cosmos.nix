{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.cosmos;
in
{
  options.ysyldur.services.scx.scheduler.cosmos.enable = lib.mkEnableOption "scx cosmos scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_cosmos";
  };
}
