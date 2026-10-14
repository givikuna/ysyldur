{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.net.core.default_qdisc;
in
{
  options.ysyldur.boot.sysctl.params.net.core.default_qdisc = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "cake";
    description = "Default packet queuing discipline (e.g. fq, fq_codel, cake).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."net.core.default_qdisc" = cfg;
  };
}
