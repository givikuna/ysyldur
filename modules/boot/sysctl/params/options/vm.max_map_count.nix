{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.vm.max_map_count;
in
{
  options.ysyldur.boot.sysctl.params.vm.max_map_count = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "vm.max_map_count value (null means do not set)";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."vm.max_map_count" = cfg;
  };
}
