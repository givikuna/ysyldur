{ lib, helpers, ... }:
let
  inherit (helpers) evalYsyldur evalYsyldurWith;

  expectedVariantMap = {
    default = "linuxPackages";
    # hardened = "linuxPackages_hardened";
    latest = "linuxPackages_latest";
    libre = "linuxPackages-libre";
    testing = "linuxPackages_testing";
    testing-bcachefs = "linuxPackages_testing_bcachefs";
    rt = "linuxPackages-rt";
    tinyconfig = "linuxPackages_custom_tinyconfig_kernel";

    zen = "linuxPackages_zen";
    lqx = "linuxPackages_lqx";

    rpi0 = "linuxPackages_rpi0";
    rpi02w = "linuxPackages_rpi02w";
    rpi1 = "linuxPackages_rpi1";
    rpi2 = "linuxPackages_rpi2";
    rpi3 = "linuxPackages_rpi3";
    rpi4 = "linuxPackages_rpi4";

    cachyos = "linuxPackages_cachyos";
    cachyos-gcc = "linuxPackages_cachyos-gcc";
    cachyos-lts = "linuxPackages_cachyos-lts";
    cachyos-server = "linuxPackages_cachyos-server";
    cachyos-hardened = "linuxPackages_cachyos-hardened";
    cachyos-rc = "linuxPackages_cachyos-rc";
    cachyos-lto = "linuxPackages_cachyos-lto";
    cachyos-bore = "linuxPackages_cachyos-bore";

    xanmod-default = "linuxPackages_xanmod";
    xanmod-latest = "linuxPackages_xanmod_latest";
    xanmod-stable = "linuxPackages_xanmod_stable";

    xen_dom0 = "linuxPackages_xen_dom0";
    # xen_dom0-hardened = "linuxPackages_xen_dom0_hardened";
  };

  toggleTests = lib.mapAttrsToList (variantName: expectedPkgAttr: {
    name = "toggle kernel-variant.${variantName}.enable resolves ${expectedPkgAttr}";
    pos = __curPos;
    expected = expectedPkgAttr;
    actual =
      (evalYsyldur {
        ysyldur.boot.packages.kernel-variant.${variantName}.enable = true;
      }).config.boot.kernelPackages._id;
  }) expectedVariantMap;

  shorthandTests = lib.mapAttrsToList (variantName: expectedPkgAttr: {
    name = "shorthand variant = \"${variantName}\" resolves ${expectedPkgAttr}";
    pos = __curPos;
    expected = expectedPkgAttr;
    actual =
      (evalYsyldur {
        ysyldur.boot.packages.variant = variantName;
      }).config.boot.kernelPackages._id;
  }) expectedVariantMap;
in
{
  suites."Boot - Kernel Variants" = {
    pos = __curPos;
    tests =
      toggleTests
      ++ shorthandTests
      ++ [
        {
          name = "defaults to standard linuxPackages when no variant or version is selected";
          pos = __curPos;
          expected = {
            selected = null;
            pkgId = "linuxPackages";
          };
          actual =
            let
              res = evalYsyldur { };
            in
            {
              selected = res.config.ysyldur.boot.packages.selectedVariantName;
              pkgId = res.config.boot.kernelPackages._id;
            };
        }
        {
          name = "exposes read-only .package on each kernel-variant option";
          pos = __curPos;
          expected = "linuxPackages_zen";
          actual = (evalYsyldur { }).config.ysyldur.boot.packages.kernel-variant.zen.package._id;
        }
        {
          name = "deduplicates when same variant is enabled via both toggle and shorthand";
          pos = __curPos;
          expected = {
            passed = true;
            pkgId = "linuxPackages_zen";
          };
          actual =
            let
              res = evalYsyldur {
                ysyldur.boot.packages.variant = "zen";
                ysyldur.boot.packages.kernel-variant.zen.enable = true;
              };
            in
            {
              passed = res.assertionsPassed;
              pkgId = res.config.boot.kernelPackages._id;
            };
        }
        {
          name = "fails assertion when two kernel variants are enabled via toggles";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.kernel-variant.zen.enable = true;
              ysyldur.boot.packages.kernel-variant.rt.enable = true;
            }).assertionsPassed;
        }
        {
          name = "fails assertion when conflicting toggle and shorthand variants are set";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "cachyos-lts";
              ysyldur.boot.packages.kernel-variant.zen.enable = true;
            }).assertionsPassed;
        }
        {
          name = "fails assertion when a cachyos variant is selected but missing from pkgs";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldurWith {
              withChaoticPackages = false;
              module = {
                ysyldur.boot.packages.kernel-variant.cachyos.enable = true;
              };
            }).assertionsPassed;
        }
      ];
  };
}
