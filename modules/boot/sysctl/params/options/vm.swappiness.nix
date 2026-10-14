{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.vm.swappiness;
in
{
  options.ysyldur.boot.sysctl.params.vm.swappiness = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "vm.swappiness value (null means do not set)";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."vm.swappiness" = cfg;
  };
}
