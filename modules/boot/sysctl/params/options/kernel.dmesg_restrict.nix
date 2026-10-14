{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.dmesg_restrict;
in
{
  options.ysyldur.boot.sysctl.params.kernel.dmesg_restrict = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "restrict unprivileged access to kernel syslog/dmesg (0 or 1).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.dmesg_restrict" = cfg;
  };
}
