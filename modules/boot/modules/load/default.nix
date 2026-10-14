{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.modules;
in
{
  options.ysyldur.boot.modules = {
    load = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "kvm-intel"
        "ntsync"
        "tcp_bbr"
      ];
      description = "kernel modules to load at boot (appended to boot.kernelModules).";
    };

    presets = {
      kvm-intel.enable = lib.mkEnableOption "kvm-intel virtualization module";
      kvm-amd.enable = lib.mkEnableOption "kvm-amd virtualization module";
      ntsync.enable = lib.mkEnableOption "ntsync Windows NT synchronization primitive driver for Wine/Proton";
      uhid.enable = lib.mkEnableOption "uhid user-space HID driver";
      uinput.enable = lib.mkEnableOption "uinput user-space input driver";
    };
  };

  config = {
    boot.kernelModules =
      cfg.load
      ++ lib.optional cfg.presets.kvm-intel.enable "kvm-intel"
      ++ lib.optional cfg.presets.kvm-amd.enable "kvm-amd"
      ++ lib.optional cfg.presets.ntsync.enable "ntsync"
      ++ lib.optional cfg.presets.uhid.enable "uhid"
      ++ lib.optional cfg.presets.uinput.enable "uinput";
  };
}
