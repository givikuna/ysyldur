{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.ipv4.tcp_congestion_control;
in
{
  options.ysyldur.boot.sysctl.params.net.ipv4.tcp_congestion_control = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "bbr";
    description = "TCP congestion control algorithm (e.g. bbr, cubic).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = cfg;
    boot.kernelModules = lib.optional (cfg == "bbr") "tcp_bbr";
  };
}
