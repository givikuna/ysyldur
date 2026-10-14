{
  description = "ysyldur - nix flake for kernel mgmt";

  inputs = {
    # prod
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # dev
    mk-script.url = "github:givikuna/nix-mkScript";
    nixtest.url = "gitlab:TECHNOFAB/nixtest?dir=lib";
  };

  outputs =
    {
      self,
      nixpkgs,

      nixtest,
      mk-script,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      chaotic = inputs.chaotic or null;
      ysyldur-mod = import ./modules/default.nix { inherit self chaotic; };

      nixtestRunner = import ./tests/default.nix {
        inherit
          inputs
          pkgs
          self
          chaotic
          ;
      };

      mkScript = mk-script.lib.mkScript pkgs {
        src = ./.;
        env = {
          NIXTEST_BIN = "${nixtestRunner}/bin/nixtest";
        };
      };
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

      packages.${system} = {
        tests = mkScript "tests" "scripts/ysyldur-test.sh";
      };

      checks.${system} = {
        tests = pkgs.runCommand "ysyldur-tests" { } ''
          ${nixtestRunner}/bin/nixtest
          touch $out
        '';
      };
    };
}
