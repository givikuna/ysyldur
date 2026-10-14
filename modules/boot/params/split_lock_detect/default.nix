{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.params.split_lock_detect;
  normalized = if cfg == "warm" then "warn" else cfg;
in
{
  options.ysyldur.boot.params.split_lock_detect = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "off"
        "warn"
        "fatal"
      ]
    );
    default = null;
    description = ''
      split lock detection mode:
      "off" helps avoid stuttering in games.
      leave at null to let the kernel decide.
    '';
  };

  config = lib.mkIf (cfg != null) {
    boot.kernelParams = [ "split_lock_detect=${normalized}" ];
  };
}
