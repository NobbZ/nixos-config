{
  self,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.nobbz.nixosModules;

  inherit (import ./module_helpers.nix lib inputs) submodule;

  modules = builtins.mapAttrs (_: config: config.wrappedModule) cfg;
in {
  options = {
    nobbz.nixosModules = lib.mkOption {
      type = lib.types.attrsOf submodule;
    };
  };

  config.flake.nixosModules = modules;
}
