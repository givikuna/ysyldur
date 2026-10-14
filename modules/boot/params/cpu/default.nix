{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    mitigations = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "off"
          "auto"
          "auto,nosmt"
        ]
      );
      default = null;
      description = "CPU vulnerability mitigations setting.";
    };

    preempt = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "none"
          "voluntary"
          "full"
        ]
      );
      default = null;
      description = "kernel preemption model.";
    };

    amd_pstate = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "active"
          "passive"
          "guided"
          "disable"
        ]
      );
      default = null;
      description = "AMD P-State scaling driver mode.";
    };

    intel_pstate = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "active"
          "passive"
          "disable"
          "no_hwp"
        ]
      );
      default = null;
      description = "intel P-State scaling driver mode.";
    };

    nowatchdog = lib.mkEnableOption "disable CPU lockup watchdogs (nowatchdog, nmi_watchdog=0, tsc=nowatchdog)";
  };

  config.boot.kernelParams =
    lib.optional (cfg.mitigations != null) "mitigations=${cfg.mitigations}"
    ++ lib.optional (cfg.preempt != null) "preempt=${cfg.preempt}"
    ++ lib.optional (cfg.amd_pstate != null) "amd_pstate=${cfg.amd_pstate}"
    ++ lib.optional (cfg.intel_pstate != null) "intel_pstate=${cfg.intel_pstate}"
    ++ lib.optionals cfg.nowatchdog [
      "nowatchdog"
      "nmi_watchdog=0"
      "tsc=nowatchdog"
    ];
}
