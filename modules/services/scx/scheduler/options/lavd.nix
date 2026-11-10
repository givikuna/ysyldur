{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.lavd;
in
{
  options.ysyldur.services.scx.scheduler.lavd.enable = lib.mkEnableOption "scx lavd scheduler";

  config = lib.mkIf cfg.enable {
    services.scx-loader.config.default_sched = "scx_lavd";
  };
}
