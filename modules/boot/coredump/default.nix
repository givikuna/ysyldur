{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.coredump;
in
{
  options.ysyldur.boot.coredump = {
    disable = lib.mkEnableOption "completely disable kernel and systemd core dumps";

    suidDumpable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          0
          1
          2
        ]
      );
      default = null;
      description = "fs.suid_dumpable sysctl value (0 forbids setuid programs from dumping core).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.disable {
      systemd.coredump.enable = false;
      boot.kernel.sysctl."kernel.core_pattern" = "|/bin/false";
      security.pam.loginLimits = [
        {
          domain = "*";
          type = "hard";
          item = "core";
          value = "0";
        }
      ];
    })

    (lib.mkIf (cfg.suidDumpable != null) {
      boot.kernel.sysctl."fs.suid_dumpable" = cfg.suidDumpable;
    })
  ];
}
