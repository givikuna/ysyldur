{ pkgs, ... }:
{
  # standard nixpkgs
  default = pkgs.linuxPackages;
  hardened = pkgs.linuxPackages_hardened;
  latest = pkgs.linuxPackages_latest;
  libre = pkgs.linuxPackages-libre;
  testing = pkgs.linuxPackages_testing;
  testing-bcachefs = pkgs.linuxPackages_testing_bcachefs;
  rt = pkgs.linuxPackages-rt;

  # zen
  zen = pkgs.linuxPackages_zen;

  # cachyos (chaotic-nyx)
  cachyos = pkgs.linuxPackages_cachyos;
  cachyos-gcc = pkgs.linuxPackages_cachyos-gcc;
  cachyos-lts = pkgs.linuxPackages_cachyos-lts;
  cachyos-server = pkgs.linuxPackages_cachyos-server;
  cachyos-hardened = pkgs.linuxPackages_cachyos-hardened;
  cachyos-rc = pkgs.linuxPackages_cachyos-rc;
  cachyos-lto = pkgs.linuxPackages_cachyos-lto;
  cachyos-bore = pkgs.linuxPackages_cachyos-bore;

  # xanmod
  xanmod-default = pkgs.linuxPackages_xanmod;
  xanmod-latest = pkgs.linuxPackages_xanmod_latest;
  xanmod-stable = pkgs.linuxPackages_xanmod_stable;

  # xen_dom0
  xen_dom0 = pkgs.linuxPackages_xen_dom0;
  xen_dom0-hardened = pkgs.linuxPackages_xen_dom0_hardened;
}
