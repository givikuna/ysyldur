{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    transparent_hugepage = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "always"
          "madvise"
          "never"
        ]
      );
      default = null;
      description = "transparent Hugepages policy.";
    };

    zswap = {
      enable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "whether to enable zswap compressed RAM cache.";
      };
      compressor = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "zstd"
            "lz4"
            "lzo"
            "lz4hc"
            "deflate"
          ]
        );
        default = null;
        description = "compression algorithm for zswap.";
      };
      max_pool_percent = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "maximum percentage of RAM zswap pool may occupy.";
      };
      zpool = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "zsmalloc"
            "zbud"
            "z3fold"
          ]
        );
        default = null;
        description = "zswap memory allocator.";
      };
    };
  };

  config.boot.kernelParams =
    lib.optional (cfg.transparent_hugepage != null) "transparent_hugepage=${cfg.transparent_hugepage}"
    ++ lib.optional (cfg.zswap.enable != null) "zswap.enabled=${if cfg.zswap.enable then "1" else "0"}"
    ++ lib.optional (cfg.zswap.compressor != null) "zswap.compressor=${cfg.zswap.compressor}"
    ++ lib.optional (
      cfg.zswap.max_pool_percent != null
    ) "zswap.max_pool_percent=${toString cfg.zswap.max_pool_percent}"
    ++ lib.optional (cfg.zswap.zpool != null) "zswap.zpool=${cfg.zswap.zpool}";
}
