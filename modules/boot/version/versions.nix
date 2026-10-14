{ pkgs, ... }:
{
  "4_9" = pkgs.linuxPackages_4_9 or null;
  "4_14" = pkgs.linuxPackages_4_14 or null;
  "4_19" = pkgs.linuxPackages_4_19 or null;

  "5_4" = pkgs.linuxPackages_5_4 or null;
  "5_10" = pkgs.linuxPackages_5_10 or null;
  "5_15" = pkgs.linuxPackages_5_15 or null;
  "5_18" = pkgs.linuxPackages_5_18 or null;
  "5_19" = pkgs.linuxPackages_5_19 or null;

  "6_0" = pkgs.linuxPackages_6_0 or null;
  "6_1" = pkgs.linuxPackages_6_1 or null;
  "6_2" = pkgs.linuxPackages_6_2 or null;
  "6_3" = pkgs.linuxPackages_6_3 or null;
  "6_4" = pkgs.linuxPackages_6_4 or null;
  "6_5" = pkgs.linuxPackages_6_5 or null;
  "6_6" = pkgs.linuxPackages_6_6 or null;
  "6_7" = pkgs.linuxPackages_6_7 or null;
  "6_8" = pkgs.linuxPackages_6_8 or null;
  "6_9" = pkgs.linuxPackages_6_9 or null;
  "6_10" = pkgs.linuxPackages_6_10 or null;
  "6_11" = pkgs.linuxPackages_6_11 or null;
  "6_12" = pkgs.linuxPackages_6_12 or null;
  "6_13" = pkgs.linuxPackages_6_13 or null;
  "6_14" = pkgs.linuxPackages_6_14 or null;
  "6_15" = pkgs.linuxPackages_6_15 or null;
  "6_16" = pkgs.linuxPackages_6_16 or null;
  "6_17" = pkgs.linuxPackages_6_17 or null;
  "6_18" = pkgs.linuxPackages_6_18 or null;
  "6_19" = pkgs.linuxPackages_6_19 or null;

  "latest" = pkgs.linuxPackages_latest;
}
