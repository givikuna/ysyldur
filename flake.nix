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
      ...
    }@inputs:
    let
      chaotic = inputs.chaotic or null;
      ysyldur-mod = import ./modules/default.nix { inherit self chaotic; };
    in
    {
      nixosModules = {
        default = ysyldur-mod;
        ysyldur = ysyldur-mod;
      }
      // nixpkgs.lib.optionalAttrs (chaotic != null) {
        withChaotic = {
          imports = [
            chaotic.nixosModules.default
            ysyldur-mod
          ];
        };
      };

      overlays = nixpkgs.lib.optionalAttrs (chaotic != null) {
        default = chaotic.overlays.default;
      };
    };
}
