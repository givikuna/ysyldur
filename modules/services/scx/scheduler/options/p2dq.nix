{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.p2dq;
in
{
  options.ysyldur.services.scx.scheduler.p2dq.enable = lib.mkEnableOption "scx p2dq scheduler";

  config = lib.mkIf cfg.enable {
    services.scx-loader.config.default_sched = "scx_p2dq";
  };
}
