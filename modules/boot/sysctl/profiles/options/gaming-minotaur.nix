{ config, lib, ... }:
let
  cfgMinotaur = config.ysyldur.boot.sysctl.profiles.gaming-minotaur;
  cfgGeneric = config.ysyldur.boot.sysctl.profiles.gaming;
in
{
  options.ysyldur.boot.sysctl.profiles = {
    gaming-minotaur.enable = lib.mkEnableOption "gaming-minotaur sysctl profile";
    gaming.enable = lib.mkEnableOption "generic gaming sysctl profile";
  };

  config = lib.mkIf (cfgMinotaur.enable || cfgGeneric.enable) {
    ysyldur.boot.sysctl.params = {
      vm.swappiness = lib.mkDefault 10;
      vm.vfs_cache_pressure = lib.mkDefault 50;
      kernel.split_lock_mitigate = lib.mkDefault 0;
      kernel.nmi_watchdog = lib.mkDefault 0;
    };
  };
}
