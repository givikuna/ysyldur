{ helpers, ... }:
let
  inherit (helpers) evalYsyldur;
in
{
  suites."Boot - Block I/O Schedulers" = {
    pos = __curPos;
    tests = [
      {
        name = "leaves udev extraRules empty when no I/O schedulers are set";
        pos = __curPos;
        expected = "";
        actual = (evalYsyldur { }).config.services.udev.extraRules;
      }
      {
        name = "generates udev rules for nvme, ssd, and hdd schedulers";
        pos = __curPos;
        expected = ''
          ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
          ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"'';
        actual =
          (evalYsyldur {
            ysyldur.boot.io-scheduler = {
              nvme = "none";
              ssd = "mq-deadline";
              hdd = "bfq";
            };
          }).config.services.udev.extraRules;
      }
    ];
  };
}
