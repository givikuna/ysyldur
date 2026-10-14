{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.modules.initrd;
in
{
  options.ysyldur.boot.modules.initrd = {
    available = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      description = "modules made available in initrd (boot.initrd.availableKernelModules).";
    };

    load = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "amdgpu"
        "dm-snapshot"
      ];
      description = "modules unconditionally loaded in early initrd (boot.initrd.kernelModules).";
    };
  };

  config = {
    boot.initrd.availableKernelModules = cfg.available;
    boot.initrd.kernelModules = cfg.load;
  };
}
