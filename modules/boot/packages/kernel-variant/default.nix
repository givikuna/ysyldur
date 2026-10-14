{
  config,
  lib,
  pkgs,
  ...
}:
let
  variants = import ./variants.nix { inherit pkgs; };
  variantNames = lib.attrNames variants;

  variantOpts = lib.mapAttrs (name: pkg: {
    enable = lib.mkEnableOption "the ${name} kernel variant";
    package = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      default = pkg;
      description = "the kernel package set for ${name}.";
    };
  }) variants;

  enabledByToggle = lib.filter (
    name: config.ysyldur.boot.packages.kernel-variant.${name}.enable
  ) variantNames;

  shorthand = config.ysyldur.boot.packages.variant;

  selectedVariants = enabledByToggle ++ lib.optional (shorthand != null) shorthand;

  uniqueSelected = lib.unique selectedVariants;
  count = lib.length uniqueSelected;
  chosenName = if count == 1 then lib.head uniqueSelected else null;
in
{
  options.ysyldur.boot.packages = {
    variant = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum variantNames);
      default = null;
      example = "cachyos-lts";
      description = "shorthand kernel variant selector (e.g. \"cachyos-lts\" or \"zen\").";
    };

    kernel-variant = variantOpts;

    selectedVariantName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      internal = true;
      readOnly = true;
      default = chosenName;
      description = "internal resolved name of the active variant, or null if none was explicitly chosen.";
    };

    resolvedBaseKernelPackages = lib.mkOption {
      type = lib.types.raw;
      internal = true;
      readOnly = true;
      default = if chosenName != null then variants.${chosenName} else variants.default;
      description = "internal resolved base kernelPackages set before version overrides.";
    };
  };

  config = {
    assertions = [
      {
        assertion = count <= 1;
        message = "ysyldur: only one kernel variant can be enabled at a time (found: ${builtins.toJSON uniqueSelected}).";
      }
    ];
  };
}
