{
  inputs,
  pkgs,
  self,
  chaotic,
  ...
}:
let
  lib = pkgs.lib;
  ntlib = inputs.nixtest.lib { inherit pkgs; };
  helpers = import ./helpers.nix {
    inherit
      lib
      pkgs
      self
      chaotic
      ;
  };

  all-files = lib.filesystem.listFilesRecursive ./.;
  test-mods = builtins.filter (f: lib.hasSuffix "_test.nix" (toString f)) all-files;
in
ntlib.mkNixtest {
  modules = test-mods;

  args = {
    inherit
      pkgs
      lib
      ntlib
      inputs
      self
      chaotic
      helpers
      ;
  };
}
