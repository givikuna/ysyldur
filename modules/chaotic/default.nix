{
  config,
  lib,
  pkgs,
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

      description = "inject Chaotic-Nyx overlay if CachyOS kernels are missing from pkgs";
    };
  };

  config =
    let
      has-cachy-in-pkgs = pkgs ? linuxPackages_cachyos;
    in
    lib.mkIf (cfg.autoOverlay && !has-cachy-in-pkgs && chaotic != null) {
      nixpkgs.overlays = [ chaotic.overlays.default ];
    };
}
