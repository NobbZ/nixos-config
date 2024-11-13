{
  self,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.nobbz.homeManagerModules;

  inherit (import ./module_helpers.nix lib inputs) submodule;

  modules = builtins.mapAttrs (_: config: config.wrappedModule) cfg;
in {
  options = {
    nobbz.homeManagerModules = lib.mkOption {
      type = lib.types.attrsOf submodule;
    };
  };

  config.flake.homeManagerModules = modules;
}
