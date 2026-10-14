{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.vm.dirty_background_ratio;
in
{
  options.ysyldur.boot.sysctl.params.vm.dirty_background_ratio = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "percentage of total system memory at which background kernel flusher threads start writing out dirty data.";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."vm.dirty_background_ratio" = cfg;
  };
}
