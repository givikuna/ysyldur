{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    pcie_aspm = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "default"
          "powersave"
          "powersupersave"
          "performance"
          "off"
          "force"
        ]
      );
      default = null;
      description = "PCIe Active State Power Management policy.";
    };

    nvme_core_default_ps_max_latency_us = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "NVMe APST power saving max latency in microseconds (0 disables APST to fix NVMe freezes).";
    };
  };

  config.boot.kernelParams =
    lib.optional (cfg.pcie_aspm != null) "pcie_aspm=${cfg.pcie_aspm}"
    ++ lib.optional (
      cfg.nvme_core_default_ps_max_latency_us != null
    ) "nvme_core.default_ps_max_latency_us=${toString cfg.nvme_core_default_ps_max_latency_us}";
}
