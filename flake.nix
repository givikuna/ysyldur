{
  description = "ysyldur - nix flake for managing kernel variant, version, and options";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      chaotic,
      ...
    }:
    let
      ysyldur-mod = import ./modules/default.nix { inherit self chaotic; };
    in
    {
      nixosModules = {
        default = ysyldur-mod;
        ysyldur = ysyldur-mod;

        withChaotic = {
          imports = [
            chaotic.nixosModules.default
            ysyldur-mod
          ];
        };
      };

      overlays.default = chaotic.overlays.default;
    };
}
