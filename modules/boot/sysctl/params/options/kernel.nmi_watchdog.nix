{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.nmi_watchdog;
in
{
  options.ysyldur.boot.sysctl.params.kernel.nmi_watchdog = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "enable or disable the NMI lockup watchdog (0 or 1).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.nmi_watchdog" = cfg;
  };
}
