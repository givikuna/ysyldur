{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Sysctl Options & Profiles" = {
    pos = __curPos;
    tests = [
      {
        name = "sets all 21 individual sysctl parameters and extra freeform sysctls";
        pos = __curPos;
        expected = {
          "fs.inotify.max_user_watches" = 524288;
          "kernel.dmesg_restrict" = 1;
          "kernel.kptr_restrict" = 2;
          "kernel.nmi_watchdog" = 0;
          "kernel.split_lock_mitigate" = 0;
          "kernel.unprivileged_bpf_disabled" = 1;
          "kernel.yama.ptrace_scope" = 1;
          "net.core.default_qdisc" = "cake";
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;
          "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.ipv4.tcp_fastopen" = 3;
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "vm.dirty_background_ratio" = 5;
          "vm.dirty_ratio" = 15;
          "vm.max_map_count" = 2147483642;
          "vm.swappiness" = 10;
          "vm.vfs_cache_pressure" = 50;
          "custom.extra.sysctl" = 42;
        };
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl.params = {
              fs.inotify.max_user_watches = 524288;
              kernel = {
                dmesg_restrict = 1;
                kptr_restrict = 2;
                nmi_watchdog = 0;
                split_lock_mitigate = 0;
                unprivileged_bpf_disabled = 1;
                yama.ptrace_scope = 1;
              };
              net = {
                core.default_qdisc = "cake";
                ipv4 = {
                  conf.all.accept_redirects = 0;
                  conf.all.rp_filter = 1;
                  conf.default.rp_filter = 1;
                  icmp_echo_ignore_broadcasts = 1;
                  tcp_congestion_control = "bbr";
                  tcp_fastopen = 3;
                  tcp_syncookies = 1;
                };
                ipv6.conf.all.accept_redirects = 0;
              };
              vm = {
                dirty_background_ratio = 5;
                dirty_ratio = 15;
                max_map_count = 2147483642;
                swappiness = 10;
                vfs_cache_pressure = 50;
              };
              extra = {
                "custom.extra.sysctl" = 42;
              };
            };
          }).config.boot.kernel.sysctl;
      }
      {
        name = "automatically loads tcp_bbr kernel module when tcp_congestion_control is bbr";
        pos = __curPos;
        expected = [ "tcp_bbr" ];
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl.params.net.ipv4.tcp_congestion_control = "bbr";
          }).config.boot.kernelModules;
      }
      {
        name = "does not load tcp_bbr kernel module when tcp_congestion_control is cubic";
        pos = __curPos;
        expected = [ ];
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl.params.net.ipv4.tcp_congestion_control = "cubic";
          }).config.boot.kernelModules;
      }
      {
        name = "gaming-minotaur and gaming sysctl profiles set expected defaults";
        pos = __curPos;
        expected = {
          "vm.swappiness" = 10;
          "vm.vfs_cache_pressure" = 50;
          "kernel.split_lock_mitigate" = 0;
          "kernel.nmi_watchdog" = 0;
        };
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl.profiles.gaming-minotaur.enable = true;
          }).config.boot.kernel.sysctl;
      }
      {
        name = "security-nomad and security sysctl profiles set expected defaults";
        pos = __curPos;
        expected = {
          "vm.swappiness" = 100;
          "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "kernel.yama.ptrace_scope" = 1;
          "kernel.kptr_restrict" = 2;
          "kernel.dmesg_restrict" = 1;
          "kernel.unprivileged_bpf_disabled" = 1;
        };
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl.profiles.security-nomad.enable = true;
          }).config.boot.kernel.sysctl;
      }
      {
        name = "explicit sysctl parameter overrides profile mkDefault value";
        pos = __curPos;
        expected = 25;
        actual =
          (evalYsyldur {
            ysyldur.boot.sysctl = {
              profiles.gaming.enable = true;
              params.vm.swappiness = 25;
            };
          }).config.boot.kernel.sysctl."vm.swappiness";
      }
    ];
  };
}
