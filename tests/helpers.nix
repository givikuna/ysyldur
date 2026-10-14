{
  lib,
  # pkgs,
  # self,
  # chaotic,
  ...
}:
let
  mkFakeKernelSet =
    id:
    {
      includeCachyNvidia ? true,
    }:
    {
      _id = id;
      kernel = {
        _id = "${id}-kernel";
        version = id;
      };
      acpi_call = {
        _id = "${id}:acpi_call";
      };
      bbswitch = {
        _id = "${id}:bbswitch";
      };
      ddcci-driver = {
        _id = "${id}:ddcci-driver";
      };
      evdi = {
        _id = "${id}:evdi";
      };
      v4l2loopback = {
        _id = "${id}:v4l2loopback";
      };
      zenpower = {
        _id = "${id}:zenpower";
      };
      nvidiaPackages = {
        stable = {
          _id = "${id}:nvidia-stable";
        };
        beta = {
          _id = "${id}:nvidia-beta";
        };
        production = {
          _id = "${id}:nvidia-production";
        };
      }
      // lib.optionalAttrs includeCachyNvidia {
        cachyos = {
          _id = "${id}:nvidia-cachyos";
        };
      };
    };

  baseKernelAttrs = [
    # basic bitches
    "linuxPackages"
    # "linuxPackages_hardened"
    "linuxPackages_latest"
    "linuxPackages-libre"
    "linuxPackages_testing"
    "linuxPackages_testing_bcachefs"
    "linuxPackages-rt"
    "linuxPackages_custom_tinyconfig_kernel"
    "linuxPackages_zen"
    "linuxPackages_lqx"
    "linuxPackages_rpi0"
    "linuxPackages_rpi02w"
    "linuxPackages_rpi1"
    "linuxPackages_rpi2"
    "linuxPackages_rpi3"
    "linuxPackages_rpi4"
    "linuxPackages_xanmod"
    "linuxPackages_xanmod_latest"
    "linuxPackages_xanmod_stable"
    "linuxPackages_xen_dom0"
    # "linuxPackages_xen_dom0_hardened"

    # combined variant + version attributes in nixpkgs
    # "linuxPackages_latest_hardened"
    "linuxPackages-rt_latest"
    "linuxPackages_latest-libre"
    "linuxPackages_latest_xen_dom0"
    # "linuxPackages_latest_xen_dom0_hardened"
    # "linuxPackages_4_19_hardened"
    # "linuxPackages_5_4_hardened"
    # "linuxPackages_5_10_hardened"
    # "linuxPackages_5_15_hardened"
    # "linuxPackages_6_1_hardened"
    # "linuxPackages_6_6_hardened"
    "linuxPackages_rt_5_4"
    "linuxPackages_rt_5_10"
    "linuxPackages_rt_5_15"
    "linuxPackages_rt_6_1"

    # numbered versions
    "linuxPackages_4_9"
    "linuxPackages_4_14"
    "linuxPackages_4_19"
    "linuxPackages_5_4"
    "linuxPackages_5_10"
    "linuxPackages_5_15"
    "linuxPackages_5_18"
    "linuxPackages_5_19"
    "linuxPackages_6_0"
    "linuxPackages_6_1"
    "linuxPackages_6_2"
    "linuxPackages_6_3"
    "linuxPackages_6_4"
    "linuxPackages_6_5"
    "linuxPackages_6_6"
    "linuxPackages_6_7"
    "linuxPackages_6_8"
    "linuxPackages_6_9"
    "linuxPackages_6_10"
    "linuxPackages_6_11"
    "linuxPackages_6_12"
    "linuxPackages_6_13"
    "linuxPackages_6_14"
    "linuxPackages_6_15"
    "linuxPackages_6_16"
    "linuxPackages_6_17"
    "linuxPackages_6_18"
    "linuxPackages_6_19"
  ];

  cachyKernelAttrs = [
    "linuxPackages_cachyos"
    "linuxPackages_cachyos-gcc"
    "linuxPackages_cachyos-lts"
    "linuxPackages_cachyos-server"
    "linuxPackages_cachyos-hardened"
    "linuxPackages_cachyos-rc"
    "linuxPackages_cachyos-lto"
    "linuxPackages_cachyos-bore"
  ];

  mkMockPkgs =
    {
      withChaoticPackages ? true,
      withCachyNvidia ? withChaoticPackages,
    }:
    (lib.genAttrs baseKernelAttrs (
      attr: mkFakeKernelSet attr { includeCachyNvidia = withCachyNvidia; }
    ))
    // (lib.optionalAttrs withChaoticPackages (
      lib.genAttrs cachyKernelAttrs (attr: mkFakeKernelSet attr { includeCachyNvidia = withCachyNvidia; })
    ));

  mockChaotic = {
    overlays.default = "mock-chaotic-overlay";
  };

  nixosOptionStubs =
    {
      lib,
      # config,
      pkgs,
      ...
    }:
    {
      options = {
        assertions = lib.mkOption {
          type = lib.types.listOf lib.types.unspecified;
          default = [ ];
        };
        nixpkgs.overlays = lib.mkOption {
          type = lib.types.listOf lib.types.unspecified;
          default = [ ];
        };
        boot = {
          kernelPackages = lib.mkOption {
            type = lib.types.unspecified;
            default = pkgs.linuxPackages;
          };
          extraModulePackages = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            default = [ ];
          };
          kernelModules = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          blacklistedKernelModules = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          extraModprobeConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          kernelParams = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          kernelPatches = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [ ];
          };
          kernel.sysctl = lib.mkOption {
            type = lib.types.attrsOf lib.types.unspecified;
            default = { };
          };
          initrd = {
            availableKernelModules = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
            kernelModules = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
        };
        hardware = {
          nvidia.package = lib.mkOption {
            type = lib.types.unspecified;
            default = null;
          };
          xone.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          xpadneo.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
        services = {
          xserver.videoDrivers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          udev.extraRules = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          scx = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            scheduler = lib.mkOption {
              type = lib.types.str;
              default = "scx_lavd";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
        };
        systemd.coredump.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        security.pam.loginLimits = lib.mkOption {
          type = lib.types.listOf lib.types.attrs;
          default = [ ];
        };
      };
    };

  evalYsyldurWith =
    {
      module ? { },
      withChaoticPackages ? true,
      withCachyNvidia ? withChaoticPackages,
      chaoticInput ? mockChaotic,
    }:
    let
      testPkgs = mkMockPkgs { inherit withChaoticPackages withCachyNvidia; };
      evaluated = lib.evalModules {
        modules = [
          nixosOptionStubs
          (import ../modules/default.nix { chaotic = chaoticInput; })
          module
        ];
        specialArgs = {
          pkgs = testPkgs;
        };
      };
      failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) evaluated.config.assertions);
    in
    {
      inherit (evaluated) config options;
      inherit failedAssertions;
      assertionsPassed = failedAssertions == [ ];
    };

  evalYsyldur = module: evalYsyldurWith { inherit module; };
in
{
  inherit
    evalYsyldur
    evalYsyldurWith
    mockChaotic
    baseKernelAttrs
    cachyKernelAttrs
    ;
}
