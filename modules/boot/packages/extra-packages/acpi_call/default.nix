{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.packages.extra-packages.acpi_call;
in
{
  options.ysyldur.boot.packages.extra-packages.acpi_call.enable =
    lib.mkEnableOption "acpi_call kernel module";

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    boot.kernelModules = [ "acpi_call" ];
  };
}
