{
  config,
  lib,
  chaotic ? null,
  ...
}:
let
  cfg = config.ysyldur.chaotic;
in
{
  options.ysyldur.chaotic = {
    autoOverlay = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "inject Chaotic-Nyx overlay so CachyOS kernel packages are available in pkgs.";
    };
  };

  config = lib.mkIf (cfg.autoOverlay && chaotic != null) {
    nixpkgs.overlays = [ chaotic.overlays.default ];
  };
}
