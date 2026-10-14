{ pkgs, ... }:
{
  # standard nixpkgs
  default = pkgs.linuxPackages;
  hardened = pkgs.linuxPackages_hardened;
  latest = pkgs.linuxPackages_latest;
  libre = pkgs.linuxPackages-libre;
  testing = pkgs.linuxPackages_testing;
  testing-bcachefs = pkgs.linuxPackages_testing_bcachefs or null;
  rt = pkgs.linuxPackages-rt;
  tinyconfig = pkgs.linuxPackages_custom_tinyconfig_kernel;

  # zen / lqx
  zen = pkgs.linuxPackages_zen;
  lqx = pkgs.linuxPackages_lqx;

  # raspberry pi
  rpi0 = pkgs.linuxPackages_rpi0;
  rpi02w = pkgs.linuxPackages_rpi02w;
  rpi1 = pkgs.linuxPackages_rpi1;
  rpi2 = pkgs.linuxPackages_rpi2;
  rpi3 = pkgs.linuxPackages_rpi3;
  rpi4 = pkgs.linuxPackages_rpi4;

  # cachyos (chaotic-nyx) (optional)
  cachyos = pkgs.linuxPackages_cachyos or null;
  cachyos-gcc = pkgs.linuxPackages_cachyos-gcc or null;
  cachyos-lts = pkgs.linuxPackages_cachyos-lts or null;
  cachyos-server = pkgs.linuxPackages_cachyos-server or null;
  cachyos-hardened = pkgs.linuxPackages_cachyos-hardened or null;
  cachyos-rc = pkgs.linuxPackages_cachyos-rc or null;
  cachyos-lto = pkgs.linuxPackages_cachyos-lto or null;
  cachyos-bore = pkgs.linuxPackages_cachyos-bore or null;

  # xanmod
  xanmod-default = pkgs.linuxPackages_xanmod;
  xanmod-latest = pkgs.linuxPackages_xanmod_latest;
  xanmod-stable = pkgs.linuxPackages_xanmod_stable;

  # xen_dom0
  xen_dom0 = pkgs.linuxPackages_xen_dom0;
  xen_dom0-hardened = pkgs.linuxPackages_xen_dom0_hardened;
}
