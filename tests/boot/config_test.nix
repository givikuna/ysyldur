{ lib, helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Kconfig & Kernel Patches" = {
    pos = __curPos;
    tests = [
      {
        name = "leaves boot.kernelPatches empty when no config options or patches are set";
        pos = __curPos;
        expected = [ ];
        actual = (evalYsyldur { }).config.boot.kernelPatches;
      }
      {
        name = "generates structured Kconfig patch for yes, no, module, and freeform options";
        pos = __curPos;
        expected = [
          {
            name = "ysyldur-structured-kconfig";
            patch = null;
            extraStructuredConfig = {
              NTSYNC = lib.kernel.yes;
              DEBUG_KERNEL = lib.kernel.no;
              V4L2_LOOPBACK = lib.kernel.module;
              HZ = lib.kernel.freeform "1000";
            };
          }
          {
            name = "custom-patch";
            patch = "dummy.patch";
          }
        ];
        actual =
          (evalYsyldur {
            ysyldur.boot.config = {
              yes = [ "NTSYNC" ];
              no = [ "DEBUG_KERNEL" ];
              module = [ "V4L2_LOOPBACK" ];
              freeform = {
                HZ = "1000";
              };
              patches = [
                {
                  name = "custom-patch";
                  patch = "dummy.patch";
                }
              ];
            };
          }).config.boot.kernelPatches;
      }
    ];
  };
}
