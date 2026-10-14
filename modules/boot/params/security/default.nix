{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    lockdown = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "none"
          "integrity"
          "confidentiality"
        ]
      );
      default = null;
      description = "kernel lockdown LSM mode.";
    };

    init_on_alloc = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "zero newly allocated pages/heap objects.";
    };

    init_on_free = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "zero freed pages/heap objects.";
    };

    slab_nomerge = lib.mkEnableOption "disables merging of similar kernel slab caches (slab_nomerge)";
    pti = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "on"
          "off"
          "auto"
        ]
      );
      default = null;
      description = "kernel page table isolation.";
    };
  };

  config.boot.kernelParams =
    lib.optional (cfg.lockdown != null) "lockdown=${cfg.lockdown}"
    ++
      lib.optional (cfg.init_on_alloc != null)
        "init_on_alloc=${if cfg.init_on_alloc then "1" else "0"}"
    ++ lib.optional (cfg.init_on_free != null) "init_on_free=${if cfg.init_on_free then "1" else "0"}"
    ++ lib.optional cfg.slab_nomerge "slab_nomerge"
    ++ lib.optional (cfg.pti != null) "pti=${cfg.pti}";
}
