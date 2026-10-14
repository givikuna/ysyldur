{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Kernel Modules, Initrd, Blacklist & Modprobe" = {
    pos = __curPos;
    tests = [
      {
        name = "loads custom modules and all module presets";
        pos = __curPos;
        expected = [
          "custom_mod"
          "kvm-intel"
          "kvm-amd"
          "ntsync"
          "uhid"
          "uinput"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.modules = {
              load = [ "custom_mod" ];
              presets = {
                kvm-intel.enable = true;
                kvm-amd.enable = true;
                ntsync.enable = true;
                uhid.enable = true;
                uinput.enable = true;
              };
            };
          }).config.boot.kernelModules;
      }
      {
        name = "sets initrd available and early-loaded kernel modules";
        pos = __curPos;
        expected = {
          available = [
            "xhci_pci"
            "nvme"
          ];
          load = [
            "amdgpu"
            "dm-snapshot"
          ];
        };
        actual =
          let
            initrd =
              (evalYsyldur {
                ysyldur.boot.modules.initrd = {
                  available = [
                    "xhci_pci"
                    "nvme"
                  ];
                  load = [
                    "amdgpu"
                    "dm-snapshot"
                  ];
                };
              }).config.boot.initrd;
          in
          {
            available = initrd.availableKernelModules;
            load = initrd.kernelModules;
          };
      }
      {
        name = "blacklists custom modules and all blacklist presets";
        pos = __curPos;
        expected = [
          "custom_bad_mod"
          "pcspkr"
          "snd_pcsp"
          "nouveau"
          "firewire-core"
          "firewire-ohci"
          "firewire-sbp2"
          "ohci1394"
          "sbp2"
          "thunderbolt"
          "uvcvideo"
          "btusb"
          "bluetooth"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.modules.blacklist = {
              modules = [ "custom_bad_mod" ];
              presets = {
                pcspkr.enable = true;
                nouveau.enable = true;
                firewire.enable = true;
                thunderbolt.enable = true;
                webcam.enable = true;
                bluetooth.enable = true;
              };
            };
          }).config.boot.blacklistedKernelModules;
      }
      {
        name = "compiles structured modprobe options and raw extraConfig";
        pos = __curPos;
        expected = "options nvidia NVreg_PreserveVideoMemoryAllocations=1\noptions snd_hda_intel model=auto power_save=0\nsoftdep amdgpu pre: vfio-pci";
        actual =
          (evalYsyldur {
            ysyldur.boot.modules.modprobe = {
              options = {
                nvidia = {
                  NVreg_PreserveVideoMemoryAllocations = 1;
                };
                snd_hda_intel = {
                  power_save = 0;
                  model = "auto";
                };
              };
              extraConfig = "softdep amdgpu pre: vfio-pci";
            };
          }).config.boot.extraModprobeConfig;
      }
    ];
  };
}
