{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.yama.ptrace_scope;
in
{
  options.ysyldur.boot.sysctl.params.kernel.yama.ptrace_scope = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "null means do not set";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = cfg;
  };
}
