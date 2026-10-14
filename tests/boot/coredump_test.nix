{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Coredump Management" = {
    pos = __curPos;
    tests = [
      {
        name = "coredump.disable disables systemd.coredump, sets core_pattern, and sets PAM hard limit";
        pos = __curPos;
        expected = {
          systemdCoredump = false;
          corePattern = "|/bin/false";
          pamLimits = [
            {
              domain = "*";
              type = "hard";
              item = "core";
              value = "0";
            }
          ];
        };
        actual =
          let
            cfg =
              (evalYsyldur {
                ysyldur.boot.coredump.disable = true;
              }).config;
          in
          {
            systemdCoredump = cfg.systemd.coredump.enable;
            corePattern = cfg.boot.kernel.sysctl."kernel.core_pattern";
            pamLimits = cfg.security.pam.loginLimits;
          };
      }
      {
        name = "coredump.suidDumpable sets fs.suid_dumpable sysctl";
        pos = __curPos;
        expected = 0;
        actual =
          (evalYsyldur {
            ysyldur.boot.coredump.suidDumpable = 0;
          }).config.boot.kernel.sysctl."fs.suid_dumpable";
      }
    ];
  };
}
