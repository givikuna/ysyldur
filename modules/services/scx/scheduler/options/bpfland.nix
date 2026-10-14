{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx.scheduler.bpfland;
in
{
  options.ysyldur.services.scx.scheduler.bpfland.enable = lib.mkEnableOption "scx bpfland scheduler";

  config = lib.mkIf cfg.enable {
    services.scx.scheduler = "scx_bpfland";
  };
}
