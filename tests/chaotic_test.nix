{ helpers, ... }:
let
  inherit (helpers) evalYsyldur evalYsyldurWith;
in
{
  suites."Chaotic-Nyx Integration" = {
    pos = __curPos;
    tests = [
      {
        name = "does not inject overlay by default when no cachyos kernel or driver is selected";
        pos = __curPos;
        expected = [ ];
        actual = (evalYsyldur { }).config.nixpkgs.overlays;
      }
      {
        name = "does not inject overlay when a standard nixpkgs variant (zen) is selected";
        pos = __curPos;
        expected = [ ];
        actual =
          (evalYsyldur {
            ysyldur.boot.packages.variant = "zen";
          }).config.nixpkgs.overlays;
      }
      {
        name = "auto-injects overlay when a cachyos kernel variant is selected via toggle";
        pos = __curPos;
        expected = [ "mock-chaotic-overlay" ];
        actual =
          (evalYsyldur {
            ysyldur.boot.packages.kernel-variant.cachyos-lts.enable = true;
          }).config.nixpkgs.overlays;
      }
      {
        name = "auto-injects overlay when a cachyos kernel variant is selected via shorthand";
        pos = __curPos;
        expected = [ "mock-chaotic-overlay" ];
        actual =
          (evalYsyldur {
            ysyldur.boot.packages.variant = "cachyos-bore";
          }).config.nixpkgs.overlays;
      }
      {
        name = "auto-injects overlay when nvidia_cachyos driver is enabled";
        pos = __curPos;
        expected = [ "mock-chaotic-overlay" ];
        actual =
          (evalYsyldur {
            ysyldur.drivers.nvidia_cachyos.enable = true;
          }).config.nixpkgs.overlays;
      }
      {
        name = "injects overlay unconditionally when ysyldur.chaotic.enable = true";
        pos = __curPos;
        expected = [ "mock-chaotic-overlay" ];
        actual =
          (evalYsyldur {
            ysyldur.chaotic.enable = true;
          }).config.nixpkgs.overlays;
      }
      {
        name = "does not auto-inject overlay when autoOverlay = false even with cachyos variant";
        pos = __curPos;
        expected = [ ];
        actual =
          (evalYsyldur {
            ysyldur.chaotic.autoOverlay = false;
            ysyldur.boot.packages.variant = "cachyos";
          }).config.nixpkgs.overlays;
      }
      {
        name = "fails assertion when chaotic overlay is needed but chaotic input is null";
        pos = __curPos;
        expected = false;
        actual =
          (evalYsyldurWith {
            chaoticInput = null;
            module = {
              ysyldur.chaotic.enable = true;
            };
          }).assertionsPassed;
      }
    ];
  };
}
