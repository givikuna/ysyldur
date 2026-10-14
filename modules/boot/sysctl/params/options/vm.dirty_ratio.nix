{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.vm.dirty_ratio;
in
{
  options.ysyldur.boot.sysctl.params.vm.dirty_ratio = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "percentage of total system memory that can be filled with dirty pages before synchronous flush.";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."vm.dirty_ratio" = cfg;
  };
}
