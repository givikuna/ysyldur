{
  # lib,
  helpers,
  ...
}:
let
  inherit (helpers) evalYsyldur;

  allVersionKeys = [
    "4_9"
    "4_14"
    "4_19"
    "5_4"
    "5_10"
    "5_15"
    "5_18"
    "5_19"
    "6_0"
    "6_1"
    "6_2"
    "6_3"
    "6_4"
    "6_5"
    "6_6"
    "6_7"
    "6_8"
    "6_9"
    "6_10"
    "6_11"
    "6_12"
    "6_13"
    "6_14"
    "6_15"
    "6_16"
    "6_17"
    "6_18"
    "6_19"
    "latest"
  ];

  toggleVersionTests = map (verKey: {
    name = "toggle versions.\"${verKey}\".enable resolves linuxPackages_${verKey}";
    pos = __curPos;
    expected = "linuxPackages_${verKey}";
    actual =
      (evalYsyldur {
        ysyldur.boot.version.versions.${verKey}.enable = true;
      }).config.boot.kernelPackages._id;
  }) allVersionKeys;

  dotShorthandTests = map (
    verKey:
    let
      dotVer = builtins.replaceStrings [ "_" ] [ "." ] verKey;
    in
    {
      name = "shorthand version = \"${dotVer}\" resolves linuxPackages_${verKey}";
      pos = __curPos;
      expected = "linuxPackages_${verKey}";
      actual =
        (evalYsyldur {
          ysyldur.boot.version.version = dotVer;
        }).config.boot.kernelPackages._id;
    }
  ) allVersionKeys;
in
{
  suites."Boot - Kernel Versions" = {
    pos = __curPos;
    tests =
      toggleVersionTests
      ++ dotShorthandTests
      ++ [
        # {
        #   name = "combines hardened variant with numbered version (6.6 -> linuxPackages_6_6_hardened)";
        #   pos = __curPos;
        #   expected = "linuxPackages_6_6_hardened";
        #   actual =
        #     (evalYsyldur {
        #       ysyldur.boot.packages.variant = "hardened";
        #       ysyldur.boot.version.version = "6.6";
        #     }).config.boot.kernelPackages._id;
        # }
        # {
        #   name = "combines hardened variant with latest version (linuxPackages_latest_hardened)";
        #   pos = __curPos;
        #   expected = "linuxPackages_latest_hardened";
        #   actual =
        #     (evalYsyldur {
        #       ysyldur.boot.packages.variant = "hardened";
        #       ysyldur.boot.version.version = "latest";
        #     }).config.boot.kernelPackages._id;
        # }
        {
          name = "combines rt variant with numbered version (6.1 -> linuxPackages_rt_6_1)";
          pos = __curPos;
          expected = "linuxPackages_rt_6_1";
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "rt";
              ysyldur.boot.version.version = "6.1";
            }).config.boot.kernelPackages._id;
        }
        {
          name = "combines rt variant with latest version (linuxPackages-rt_latest)";
          pos = __curPos;
          expected = "linuxPackages-rt_latest";
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "rt";
              ysyldur.boot.version.version = "latest";
            }).config.boot.kernelPackages._id;
        }
        {
          name = "combines libre variant with latest version (linuxPackages_latest-libre)";
          pos = __curPos;
          expected = "linuxPackages_latest-libre";
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "libre";
              ysyldur.boot.version.version = "latest";
            }).config.boot.kernelPackages._id;
        }
        {
          name = "combines xen_dom0 variant with latest version (linuxPackages_latest_xen_dom0)";
          pos = __curPos;
          expected = "linuxPackages_latest_xen_dom0";
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "xen_dom0";
              ysyldur.boot.version.version = "latest";
            }).config.boot.kernelPackages._id;
        }
        # {
        #   name = "combines xen_dom0-hardened variant with latest version (linuxPackages_latest_xen_dom0_hardened)";
        #   pos = __curPos;
        #   expected = "linuxPackages_latest_xen_dom0_hardened";
        #   actual =
        #     (evalYsyldur {
        #       ysyldur.boot.packages.variant = "xen_dom0-hardened";
        #       ysyldur.boot.version.version = "latest";
        #     }).config.boot.kernelPackages._id;
        # }
        {
          name = "combines xanmod-default variant with latest version (linuxPackages_xanmod_latest)";
          pos = __curPos;
          expected = "linuxPackages_xanmod_latest";
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "xanmod-default";
              ysyldur.boot.version.version = "latest";
            }).config.boot.kernelPackages._id;
        }
        {
          name = "deduplicates when same version is set via both shorthand and toggle";
          pos = __curPos;
          expected = {
            passed = true;
            pkgId = "linuxPackages_6_6";
          };
          actual =
            let
              res = evalYsyldur {
                ysyldur.boot.version.version = "6.6";
                ysyldur.boot.version.versions."6_6".enable = true;
              };
            in
            {
              passed = res.assertionsPassed;
              pkgId = res.config.boot.kernelPackages._id;
            };
        }
        {
          name = "fails assertion when multiple versions are enabled simultaneously";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldur {
              ysyldur.boot.version.versions."6_6".enable = true;
              ysyldur.boot.version.versions."6_12".enable = true;
            }).assertionsPassed;
        }
        {
          name = "fails assertion when variant does not support version pinning (e.g. zen + 6.6)";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldur {
              ysyldur.boot.packages.variant = "zen";
              ysyldur.boot.version.version = "6.6";
            }).assertionsPassed;
        }
        {
          name = "fails assertion when requested version attribute does not exist in pkgs";
          pos = __curPos;
          expected = false;
          actual =
            (evalYsyldur {
              ysyldur.boot.version.version = "99.99";
            }).assertionsPassed;
        }
      ];
  };
}
