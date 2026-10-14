{ config, lib, ... }:
let
  cfgNomad = config.ysyldur.boot.sysctl.profiles.security-nomad;
  cfgGeneric = config.ysyldur.boot.sysctl.profiles.security;
in
{
  options.ysyldur.boot.sysctl.profiles = {
    security-nomad.enable = lib.mkEnableOption "security-nomad sysctl profile";
    security.enable = lib.mkEnableOption "generic hardened security sysctl profile";
  };

  config = lib.mkIf (cfgNomad.enable || cfgGeneric.enable) {
    ysyldur.boot.sysctl.params = {
      vm.swappiness = lib.mkDefault 100;
      net.ipv4.icmp_echo_ignore_broadcasts = lib.mkDefault 1;
      net.ipv4.tcp_syncookies = lib.mkDefault 1;
      net.ipv4.conf.all.rp_filter = lib.mkDefault 1;
      net.ipv4.conf.default.rp_filter = lib.mkDefault 1;
      net.ipv4.conf.all.accept_redirects = lib.mkDefault 0;
      net.ipv6.conf.all.accept_redirects = lib.mkDefault 0;
      kernel.yama.ptrace_scope = lib.mkDefault 1;
      kernel.kptr_restrict = lib.mkDefault 2;
      kernel.dmesg_restrict = lib.mkDefault 1;
      kernel.unprivileged_bpf_disabled = lib.mkDefault 1;
    };
  };
}
