{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.layered;
in
{
  options.ysyldur.services.scx.scheduler.layered.enable = lib.mkEnableOption "scx layered scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_layered";
  };
}
