{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.sysctl.params.kernel.unprivileged_bpf_disabled;
in
{
  options.ysyldur.boot.sysctl.params.kernel.unprivileged_bpf_disabled = lib.mkOption {
    type = lib.types.nullOr lib.types.int;
    default = null;
    description = "disable unprivileged eBPF syscalls (0, 1, or 2).";
  };

  config = lib.mkIf (cfg != null) {
    boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = cfg;
  };
}
