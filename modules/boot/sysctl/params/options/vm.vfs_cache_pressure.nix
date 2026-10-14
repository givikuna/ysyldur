{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.vm.vfs_cache_pressure;
in
{
  options.ysyldur.boot.sysctl.params.vm.vfs_cache_pressure = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "tendency of the kernel to reclaim memory used for caching directory and inode objects.";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."vm.vfs_cache_pressure" = cfg;
  };
}
