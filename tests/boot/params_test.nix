{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Kernel Command-Line Parameters" = {
    pos = __curPos;
    tests = [
      {
        name = "split_lock_detect sets split_lock_detect=<mode>";
        pos = __curPos;
        expected = [ "split_lock_detect=off" ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params.split_lock_detect = "off";
          }).config.boot.kernelParams;
      }
      {
        name = "CPU parameters (mitigations, preempt, amd_pstate, intel_pstate, nowatchdog)";
        pos = __curPos;
        expected = [
          "mitigations=off"
          "preempt=full"
          "amd_pstate=active"
          "intel_pstate=active"
          "nowatchdog"
          "nmi_watchdog=0"
          "tsc=nowatchdog"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              mitigations = "off";
              preempt = "full";
              amd_pstate = "active";
              intel_pstate = "active";
              nowatchdog = true;
            };
          }).config.boot.kernelParams;
      }
      {
        name = "graphics parameters (nvidia_drm_modeset, nvidia_drm_fbdev, quietSplash)";
        pos = __curPos;
        expected = [
          "nvidia-drm.modeset=1"
          "nvidia-drm.fbdev=0"
          "quiet"
          "splash"
          "loglevel=3"
          "rd.systemd.show_status=auto"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              nvidia_drm_modeset = true;
              nvidia_drm_fbdev = false;
              quietSplash = true;
            };
          }).config.boot.kernelParams;
      }
      {
        name = "IOMMU parameters (iommu, intel_iommu, amd_iommu)";
        pos = __curPos;
        expected = [
          "iommu=pt"
          "intel_iommu=on"
          "amd_iommu=force_isolation"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              iommu = "pt";
              intel_iommu = "on";
              amd_iommu = "force_isolation";
            };
          }).config.boot.kernelParams;
      }
      {
        name = "memory and zswap parameters";
        pos = __curPos;
        expected = [
          "transparent_hugepage=madvise"
          "zswap.enabled=1"
          "zswap.compressor=zstd"
          "zswap.max_pool_percent=25"
          "zswap.zpool=zsmalloc"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              transparent_hugepage = "madvise";
              zswap = {
                enable = true;
                compressor = "zstd";
                max_pool_percent = 25;
                zpool = "zsmalloc";
              };
            };
          }).config.boot.kernelParams;
      }
      {
        name = "power parameters (pcie_aspm, nvme_core_default_ps_max_latency_us)";
        pos = __curPos;
        expected = [
          "pcie_aspm=powersave"
          "nvme_core.default_ps_max_latency_us=0"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              pcie_aspm = "powersave";
              nvme_core_default_ps_max_latency_us = 0;
            };
          }).config.boot.kernelParams;
      }
      {
        name = "security parameters (lockdown, init_on_alloc, init_on_free, slab_nomerge, pti)";
        pos = __curPos;
        expected = [
          "lockdown=confidentiality"
          "init_on_alloc=1"
          "init_on_free=1"
          "slab_nomerge"
          "pti=on"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params = {
              lockdown = "confidentiality";
              init_on_alloc = true;
              init_on_free = true;
              slab_nomerge = true;
              pti = "on";
            };
          }).config.boot.kernelParams;
      }
      {
        name = "extra freeform kernel parameters";
        pos = __curPos;
        expected = [
          "tsc=reliable"
          "clocksource=tsc"
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.params.extra = [
              "tsc=reliable"
              "clocksource=tsc"
            ];
          }).config.boot.kernelParams;
      }
    ];
  };
}
