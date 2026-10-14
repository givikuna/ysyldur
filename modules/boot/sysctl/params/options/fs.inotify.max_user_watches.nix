{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.fs.inotify.max_user_watches;
in
{
  options.ysyldur.boot.sysctl.params.fs.inotify.max_user_watches = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "maximum number of file watches per user (useful for IDEs and file indexers).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."fs.inotify.max_user_watches" = cfg;
  };
}
