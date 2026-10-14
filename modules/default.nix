{
  # self,
  chaotic,
  ...
}:
{
  _ableToUseChaotic = chaotic;

  imports = [
    ./chaotic
    ./boot
    ./drivers
    ./params
    ./services
  ];
}
