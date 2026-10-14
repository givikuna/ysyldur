{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.ipv6.conf.all.accept_redirects;
in
{
  options.ysyldur.boot.sysctl.params.net.ipv6.conf.all.accept_redirects = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "null means do not set";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = cfg;
  };
}
