{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.ipv4.conf.default.rp_filter;
in
{
  options.ysyldur.boot.sysctl.params.net.ipv4.conf.default.rp_filter = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "null means do not set";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = cfg;
  };
}
