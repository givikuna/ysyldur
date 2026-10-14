{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    iommu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "pt"
          "on"
          "off"
          "force"
          "noforce"
        ]
      );
      default = null;
      description = "IOMMU mode (generic :3).";
    };

    intel_iommu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "on"
          "off"
          "igfx_off"
          "forcedac"
        ]
      );
      default = null;
      description = "Intel VT-d IOMMU parameter. T_T";
    };

    amd_iommu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "on"
          "off"
          "force_isolation"
          "pt"
        ]
      );
      default = null;
      description = "AMD-Vi IOMMU parameter. ^w^";
    };
  };

  config.boot.kernelParams =
    lib.optional (cfg.iommu != null) "iommu=${cfg.iommu}"
    ++ lib.optional (cfg.intel_iommu != null) "intel_iommu=${cfg.intel_iommu}"
    ++ lib.optional (cfg.amd_iommu != null) "amd_iommu=${cfg.amd_iommu}";
}
