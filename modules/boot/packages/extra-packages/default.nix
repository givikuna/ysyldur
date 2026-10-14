{
  config,
  lib,
  ...
}:
let
  extraNames = config.ysyldur.boot.packages.extraModulePackageNames;
in
{
  imports = [
    ./bbswitch
    ./acpi_call
    ./v4l2loopback
    ./ddcci
    ./zenpower
    ./evdi
  ];

  options.ysyldur.boot.packages.extraModulePackageNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "v4l2loopback"
      "acpi_call"
    ];
    description = "names of attributes on config.boot.kernelPackages to append to boot.extraModulePackages.";
  };

  config = lib.mkIf (extraNames != [ ]) {
    boot.extraModulePackages = map (name: config.boot.kernelPackages.${name}) extraNames;
  };
}
