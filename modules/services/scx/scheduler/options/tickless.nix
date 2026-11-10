{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.tickless;
in
{
  options.ysyldur.services.scx.scheduler.tickless.enable =
    lib.mkEnableOption "scx tickless scheduler";

  config = lib.mkIf cfg.enable {
    services.scx-loader.config.default_sched = "scx_tickless";
  };
}
