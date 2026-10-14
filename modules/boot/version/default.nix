{
  config,
  lib,
  pkgs,
  ...
}:
let
  versions = import ./versions.nix { inherit pkgs; };
  versionNames = lib.attrNames versions;

  vCfg = config.ysyldur.boot.version;
  pCfg = config.ysyldur.boot.packages;

  version-opts = lib.mapAttrs (ver: pkg: {
    enable = lib.mkEnableOption "Linux kernel version ${ver}";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      readOnly = true;
      default = pkg;
      description = "the default linuxPackages_${ver} set from nixpkgs.";
    };
  }) versions;

  enabled-by-toggle = lib.filter (ver: vCfg.versions.${ver}.enable) versionNames;

  normalized-shorthand =
    if vCfg.version == null then null else builtins.replaceStrings [ "." ] [ "_" ] vCfg.version;

  selected-versions =
    enabled-by-toggle ++ lib.optional (normalized-shorthand != null) normalized-shorthand;

  unique-versions = lib.unique selected-versions;
  version-count = lib.length unique-versions;
  chosen-version = if version-count == 1 then lib.head unique-versions else null;

  chosen-variant = pCfg.selectedVariantName;

  resolved-attr-name =
    if chosen-version == null then
      null
    else if chosen-variant == null || chosen-variant == "default" then
      "linuxPackages_${chosen-version}"
    else if chosen-variant == "rt" then
      if chosen-version == "latest" then
        "linuxPackages-rt_latest"
      else
        "linuxPackages_rt_${chosen-version}"
    else if chosen-variant == "libre" && chosen-version == "latest" then
      "linuxPackages_latest-libre"
    else if chosen-variant == "xen_dom0" && chosen-version == "latest" then
      "linuxPackages_latest_xen_dom0"
    else if chosen-variant == "xanmod-default" && chosen-version == "latest" then
      "linuxPackages_xanmod_latest"
    else
      null;

  resolved-package-set =
    if chosen-version != null then
      if resolved-attr-name != null && (pkgs ? ${resolved-attr-name}) then
        let
          attempted = builtins.tryEval (
            builtins.seq pkgs.${resolved-attr-name}.kernel pkgs.${resolved-attr-name}
          );
        in
        if attempted.success then attempted.value else null
      else
        null
    else
      pCfg.resolvedBaseKernelPackages;

  is-active = chosen-variant != null || version-count > 0;
in
{
  options.ysyldur.boot.version = {
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "6.6";
      description = "kernel version series from nixpkgs (accepts \"6.6\", \"6_6\", \"5.15\", \"latest\", etc.).";
    };

    versions = version-opts;

    selectedVersion = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      internal = true;
      readOnly = true;
      default = chosen-version;
      description = "internal normalized version string (e.g. \"6_6\"), or null if unset.";
    };
  };

  config = lib.mkIf is-active {
    assertions = [
      {
        assertion = version-count <= 1;
        message = "ysyldur: only one kernel version can be enabled at a time (found: ${builtins.toJSON unique-versions}).";
      }
      {
        assertion = chosen-version == null || resolved-attr-name != null;
        message = "ysyldur: kernel variant '${toString chosen-variant}' does not support version pinning ('${toString chosen-version}') in nixpkgs.";
      }
      {
        assertion =
          chosen-version == null || (resolved-attr-name != null && (pkgs ? ${resolved-attr-name}));
        message = "ysyldur: kernel package set `pkgs.${toString resolved-attr-name}` does not exist in your current nixpkgs.";
      }
      {
        assertion = chosen-version == null || resolved-package-set != null;
        message =
          "ysyldur: kernel package set `pkgs.${toString resolved-attr-name}` is "
          + "not usable in your current nixpkgs. nixpkgs may expose the attribute "
          + "name but throw on evaluation.";
      }
    ];

    boot.kernelPackages = lib.mkIf (resolved-package-set != null) (lib.mkDefault resolved-package-set);
  };
}
