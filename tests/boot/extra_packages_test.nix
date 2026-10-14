{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Extra Module Packages" = {
    pos = __curPos;
    tests = [
      {
        name = "acpi_call adds package to extraModulePackages and loads acpi_call module";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:acpi_call" ];
          modules = [ "acpi_call" ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.acpi_call.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "bbswitch adds package and loads module by default";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:bbswitch" ];
          modules = [ "bbswitch" ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.bbswitch.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "bbswitch with loadModule = false adds package without loading module";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:bbswitch" ];
          modules = [ ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.bbswitch = {
                  enable = true;
                  loadModule = false;
                };
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "ddcci adds ddcci-driver package and loads ddcci + ddcci_backlight";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:ddcci-driver" ];
          modules = [
            "ddcci"
            "ddcci_backlight"
          ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.ddcci.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "evdi adds evdi package and loads evdi module";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:evdi" ];
          modules = [ "evdi" ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.evdi.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "v4l2loopback adds v4l2loopback package and loads v4l2loopback module";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:v4l2loopback" ];
          modules = [ "v4l2loopback" ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.v4l2loopback.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
          };
      }
      {
        name = "zenpower adds zenpower package, loads zenpower, and blacklists k10temp";
        pos = __curPos;
        expected = {
          extraPkgs = [ "linuxPackages:zenpower" ];
          modules = [ "zenpower" ];
          blacklist = [ "k10temp" ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.packages.extra-packages.zenpower.enable = true;
              }).config.boot;
          in
          {
            extraPkgs = map (p: p._id) cfg.extraModulePackages;
            modules = cfg.kernelModules;
            blacklist = cfg.blacklistedKernelModules;
          };
      }
      {
        name = "extraModulePackageNames resolves packages from the active kernelPackages set";
        pos = __curPos;
        expected = [
          "linuxPackages_cachyos-lts:v4l2loopback"
          "linuxPackages_cachyos-lts:acpi_call"
        ];
        actual =
          map (p: p._id)
            (evalYsyldur {
              ysyldur.boot.packages = {
                variant = "cachyos-lts";
                extraModulePackageNames = [
                  "v4l2loopback"
                  "acpi_call"
                ];
              };
            }).config.boot.extraModulePackages;
      }
    ];
  };
}
