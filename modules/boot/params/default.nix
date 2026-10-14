{ config, lib, ... }:
let
  extra = config.ysyldur.boot.params.extra;
in
{
  imports = [
    ./split_lock_detect
    ./cpu
    ./iommu
    ./memory
    ./power
    ./graphics
    ./security
  ];

  options.ysyldur.boot.params.extra = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "tsc=reliable"
      "clocksource=tsc"
    ];
    description = "arbitrary extra kernel command-line parameters.";
  };

  config = lib.mkIf (extra != [ ]) {
    boot.kernelParams = extra;
  };
}
