{ config, lib, ... }:
let
  cfg = config.ysyldur.boot.io-scheduler;

  schedTypes = lib.types.nullOr (
    lib.types.enum [
      "none"
      "mq-deadline"
      "kyber"
      "bfq"
    ]
  );

  rules =
    lib.optional (
      cfg.nvme != null
    ) ''ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="${cfg.nvme}"''
    ++
      lib.optional (cfg.ssd != null)
        ''ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.ssd}"''
    ++
      lib.optional (cfg.hdd != null)
        ''ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="${cfg.hdd}"'';
in
{
  options.ysyldur.boot.io-scheduler = {
    nvme = lib.mkOption {
      type = schedTypes;
      default = null;
      example = "none";
      description = "blk-mq I/O scheduler for NVMe drives.";
    };

    ssd = lib.mkOption {
      type = schedTypes;
      default = null;
      example = "mq-deadline";
      description = "blk-mq I/O scheduler for non-rotational SATA/eMMC SSDs.";
    };

    hdd = lib.mkOption {
      type = schedTypes;
      default = null;
      example = "bfq";
      description = "blk-mq I/O scheduler for rotational hard drives.";
    };
  };

  config = lib.mkIf (rules != [ ]) {
    services.udev.extraRules = lib.concatStringsSep "\n" rules;
  };
}
