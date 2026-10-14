{ lib, helpers, ... }:
let
  inherit (helpers) evalYsyldur;

  schedulers = [
    "bpfland"
    "cosmos"
    "flash"
    "lavd"
    "layered"
    "nest"
    "p2dq"
    "rustland"
    "rusty"
    "tickless"
  ];

  schedulerTests = map (sched: {
    name = "scx.scheduler.${sched}.enable sets services.scx.scheduler = \"scx_${sched}\"";
    pos = __curPos;
    expected = {
      enable = true;
      scheduler = "scx_${sched}";
    };
    actual =
      let
        scx =
          (evalYsyldur {
            ysyldur.services.scx = {
              enable = true;
              scheduler.${sched}.enable = true;
            };
          }).config.services.scx;
      in
      {
        inherit (scx) enable scheduler;
      };
  }) schedulers;
in
{
  suites."Services - sched_ext (scx)" = {
    pos = __curPos;
    tests = schedulerTests ++ [
      {
        name = "scx.extraArgs forwards CLI flags when non-empty";
        pos = __curPos;
        expected = [
          "--autopower"
          "--slice-us=5000"
        ];
        actual =
          (evalYsyldur {
            ysyldur.services.scx = {
              enable = true;
              extraArgs = [
                "--autopower"
                "--slice-us=5000"
              ];
            };
          }).config.services.scx.extraArgs;
      }
      {
        name = "fails assertion when more than one scx scheduler is enabled";
        pos = __curPos;
        expected = false;
        actual =
          (evalYsyldur {
            ysyldur.services.scx = {
              enable = true;
              scheduler = {
                bpfland.enable = true;
                lavd.enable = true;
              };
            };
          }).assertionsPassed;
      }
    ];
  };
}
