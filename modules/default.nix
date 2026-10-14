{
  lib,
  chaotic ? null,
  ...
}:
{
  imports = [
    ./chaotic
    ./boot
    ./drivers
    ./services
  ];

  config._module.args.chaotic = lib.mkDefault chaotic;
}
