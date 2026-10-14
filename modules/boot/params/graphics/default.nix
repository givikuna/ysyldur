{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params;
in
{
  options.ysyldur.boot.params = {
    nvidia_drm_modeset = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "set nvidia-drm.modeset=1/0.";
    };
    nvidia_drm_fbdev = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "set nvidia-drm.fbdev=1/0.";
    };
    quietSplash = lib.mkEnableOption "Quiet boot with splash and loglevel=3";
  };

  config.boot.kernelParams =
    lib.optional (cfg.nvidia_drm_modeset != null)
      "nvidia-drm.modeset=${if cfg.nvidia_drm_modeset then "1" else "0"}"
    ++
      lib.optional (cfg.nvidia_drm_fbdev != null)
        "nvidia-drm.fbdev=${if cfg.nvidia_drm_fbdev then "1" else "0"}"
    ++ lib.optionals cfg.quietSplash [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=auto"
    ];
}
