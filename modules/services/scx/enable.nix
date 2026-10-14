{ config, lib, ... }:
let
  cfg = config.ysyldur.services.scx;
in
{
  options.ysyldur.services.scx = {
    enable = lib.mkEnableOption "scx sched_ext framework";
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--autopower" ];
      description = "extra CLI flags passed to the active scx scheduler.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.scx.enable = true;
    services.scx.extraArgs = lib.mkIf (cfg.extraArgs != [ ]) cfg.extraArgs;
  };
}
