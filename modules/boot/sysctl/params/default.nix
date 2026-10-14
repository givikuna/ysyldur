{ config, lib, ... }:
let
  extra = config.ysyldur.boot.sysctl.params.extra;
in
{
  imports = [
    ./options/kernel.yama.ptrace_scope.nix
    ./options/kernel.kptr_restrict.nix
    ./options/kernel.dmesg_restrict.nix
    ./options/kernel.unprivileged_bpf_disabled.nix
    ./options/kernel.nmi_watchdog.nix
    ./options/kernel.split_lock_mitigate.nix
    ./options/net.ipv4.conf.all.accept_redirects.nix
    ./options/net.ipv4.conf.all.rp_filter.nix
    ./options/net.ipv4.conf.default.rp_filter.nix
    ./options/net.ipv4.icmp_echo_ignore_broadcasts.nix
    ./options/net.ipv4.tcp_syncookies.nix
    ./options/net.ipv4.tcp_congestion_control.nix
    ./options/net.ipv4.tcp_fastopen.nix
    ./options/net.ipv6.conf.all.accept_redirects.nix
    ./options/net.core.default_qdisc.nix
    ./options/vm.max_map_count.nix
    ./options/vm.swappiness.nix
    ./options/vm.vfs_cache_pressure.nix
    ./options/vm.dirty_ratio.nix
    ./options/vm.dirty_background_ratio.nix
    ./options/fs.inotify.max_user_watches.nix
  ];

  options.ysyldur.boot.sysctl.params.extra = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.int
        lib.types.str
        lib.types.bool
      ]
    );
    default = { };
    description = "additional arbitrary sysctl key-value settings.";
  };

  config = lib.mkIf (extra != { }) {
    boot.kernel.sysctl = extra;
  };
}
