{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.kptr_restrict;
in
{
  options.ysyldur.boot.sysctl.params.kernel.kptr_restrict = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "restrict exposure of kernel pointers in /proc (0, 1, or 2).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.kptr_restrict" = cfg;
  };
}
