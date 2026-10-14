{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.modules.blacklist;
in
{
  options.ysyldur.boot.modules.blacklist = {
    modules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "nouveau"
        "pcspkr"
      ];
      description = "List of kernel modules to blacklist.";
    };

    presets = {
      pcspkr.enable = lib.mkEnableOption "Blacklist motherboard speaker beep (pcspkr, snd_pcsp)";
      nouveau.enable = lib.mkEnableOption "Blacklist open-source nouveau driver";
      firewire.enable = lib.mkEnableOption "Blacklist legacy FireWire stack (firewire-core, ohci1394, sbp2)";
      thunderbolt.enable = lib.mkEnableOption "Blacklist thunderbolt module against DMA attacks";
      webcam.enable = lib.mkEnableOption "Blacklist uvcvideo webcam driver";
      bluetooth.enable = lib.mkEnableOption "Blacklist btusb and bluetooth kernel modules";
    };
  };

  config = {
    boot.blacklistedKernelModules =
      cfg.modules
      ++ lib.optionals cfg.presets.pcspkr.enable [
        "pcspkr"
        "snd_pcsp"
      ]
      ++ lib.optional cfg.presets.nouveau.enable "nouveau"
      ++ lib.optionals cfg.presets.firewire.enable [
        "firewire-core"
        "firewire-ohci"
        "firewire-sbp2"
        "ohci1394"
        "sbp2"
      ]
      ++ lib.optional cfg.presets.thunderbolt.enable "thunderbolt"
      ++ lib.optional cfg.presets.webcam.enable "uvcvideo"
      ++ lib.optionals cfg.presets.bluetooth.enable [
        "btusb"
        "bluetooth"
      ];
  };
}
