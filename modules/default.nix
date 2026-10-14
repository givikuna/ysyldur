{
  chaotic ? null,
  ...
}:
{ lib, ... }:
{
  imports = [
    ./chaotic
    ./boot
    ./drivers
    ./services
  ];

  config._module.args.chaotic = lib.mkDefault chaotic;
}
