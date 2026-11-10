{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.rustland;
in
{
  options.ysyldur.services.scx.scheduler.rustland.enable =
    lib.mkEnableOption "scx rustland scheduler";

  config = lib.mkIf cfg.enable {
    services.scx-loader.config.default_sched = "scx_rustland";
  };
}
