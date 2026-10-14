{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.ipv4.tcp_fastopen;
in
{
  options.ysyldur.boot.sysctl.params.net.ipv4.tcp_fastopen = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "TCP Fast Open bitmask (3 enables for both client and server).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.ipv4.tcp_fastopen" = cfg;
  };
}
