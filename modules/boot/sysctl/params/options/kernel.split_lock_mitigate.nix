{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.split_lock_mitigate;
in
{
  options.ysyldur.boot.sysctl.params.kernel.split_lock_mitigate = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "mitigate split locks at runtime via sysctl (0 disables penalty for gaming).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.split_lock_mitigate" = cfg;
  };
}
