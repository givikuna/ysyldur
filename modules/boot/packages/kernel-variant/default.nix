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
  normalizedShorthand = if shorthand == null then null else lib.removeSuffix "-kernel" shorthand;

  selectedVariants =
    enabledByToggle ++ lib.optional (normalizedShorthand != null) normalizedShorthand;

  uniqueSelected = lib.unique selectedVariants;
  count = lib.length uniqueSelected;
in
{
  options.ysyldur.boot.packages = {
    variant = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum (variantNames ++ map (name: "${name}-kernel") variantNames)
      );
      default = null;
      description = "shorthand kernel variant selector (e.g. \"cachyos-lts\" or \"zen\").";
    };

    kernel-variant = variantOpts;

    resolvedBaseKernelPackages = lib.mkOption {
      type = lib.types.raw;
      internal = true;
      default = if count == 1 then variants.${lib.head uniqueSelected} else variants.default;
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
