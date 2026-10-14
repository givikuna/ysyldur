{
  config,
  lib,
  chaotic ? null,
  ...
}:
let
  cfg = config.ysyldur.chaotic;
  select-variant = config.ysyldur.boot.packages.select-variantName;

  uses-cachy-variant = select-variant != null && lib.hasPrefix "cachyos" select-variant;

  uses-cachy-nvidia = config.ysyldur.drivers.nvidia_cachyos.enable;

  should-apply-overlay = cfg.enable || (cfg.autoOverlay && (uses-cachy-variant || uses-cachy-nvidia));

  has-chaotic-overlay = chaotic != null && (chaotic ? overlays) && (chaotic.overlays ? default);
in
{
  options.ysyldur.chaotic = {
    enable = lib.mkEnableOption "Chaotic-Nyx overlay unconditionally";

    autoOverlay = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "automatically inject the Chaotic-Nyx overlay when a cachyos kernel or driver is enabled.";
    };
  };

  config = lib.mkIf should-apply-overlay {
    assertions = [
      {
        assertion = has-chaotic-overlay;
        message = "ysyldur: a CachyOS kernel/driver or `ysyldur.chaotic.enable` was requested, but the `chaotic` flake input is not available.";
      }
    ];

    nixpkgs.overlays = lib.optional has-chaotic-overlay chaotic.overlays.default;
  };
}
