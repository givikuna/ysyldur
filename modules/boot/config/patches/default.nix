{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.config;

  structuredConfig =
    (lib.genAttrs cfg.yes (_: lib.kernel.yes))
    // (lib.genAttrs cfg.no (_: lib.kernel.no))
    // (lib.genAttrs cfg.module (_: lib.kernel.module))
    // (lib.mapAttrs (_: v: lib.kernel.freeform v) cfg.freeform);

  hasStructuredConfig = structuredConfig != { };
in
{
  options.ysyldur.boot.config = {
    yes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "NTSYNC"
        "LRU_GEN"
        "LRU_GEN_ENABLED"
      ];
      description = "kernel Kconfig symbols to set to =y.";
    };

    no = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "DEBUG_KERNEL" ];
      description = "kernel Kconfig symbols to set to =n.";
    };

    module = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "V4L2_LOOPBACK" ];
      description = "kernel Kconfig symbols to set to =m.";
    };

    freeform = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        HZ = "1000";
      };
      description = "freeform kernel Kconfig values.";
    };

    patches = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "additional patch items appended directly to boot.kernelPatches.";
    };
  };

  config = lib.mkIf (hasStructuredConfig || cfg.patches != [ ]) {
    boot.kernelPatches =
      (lib.optional hasStructuredConfig {
        name = "ysyldur-structured-kconfig";
        patch = null;
        extraStructuredConfig = structuredConfig;
      })
      ++ cfg.patches;
  };
}
