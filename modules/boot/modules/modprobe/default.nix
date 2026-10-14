{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.modules.modprobe;

  renderModOptions =
    modName: opts:
    let
      kvList = lib.mapAttrsToList (k: v: "${k}=${toString v}") opts;
    in
    "options ${modName} ${lib.concatStringsSep " " kvList}";

  renderedLines = lib.mapAttrsToList renderModOptions cfg.options;
in
{
  options.ysyldur.boot.modules.modprobe = {
    options = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.str
            lib.types.int
            lib.types.bool
          ]
        )
      );
      default = { };
      example = {
        nvidia = {
          NVreg_PreserveVideoMemoryAllocations = 1;
          NVreg_UsePageAttributeTable = 1;
        };
        snd_hda_intel = {
          power_save = 0;
        };
      };
      description = "structured module options compiled into boot.extraModprobeConfig.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "raw modprobe lines appended to boot.extraModprobeConfig.";
    };
  };

  config = lib.mkIf (cfg.options != { } || cfg.extraConfig != "") {
    boot.extraModprobeConfig = lib.concatStringsSep "\n" (
      renderedLines ++ (lib.optional (cfg.extraConfig != "") cfg.extraConfig)
    );
  };
}
