{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.ipv4.icmp_echo_ignore_broadcasts;
in
{
  options.ysyldur.boot.sysctl.params.net.ipv4.icmp_echo_ignore_broadcasts = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "null means do not set";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = cfg;
  };
}
