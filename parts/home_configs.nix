{
  self,
  nixpkgs,
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.nobbz.homeConfigurations;

  configs = builtins.mapAttrs (_: config: config.finalHome) cfg;
in {
  options = {
    nobbz.homeConfigurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          nixpkgs = lib.mkOption {
            type = lib.types.unspecified;
            default = inputs.nixpkgs;
          };

          system = lib.mkOption {type = lib.types.enum ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];};

          username = lib.mkOption {
            type = lib.types.str;
            default = builtins.elemAt (lib.strings.split "@" name) 0;
          };

          hostname = lib.mkOption {
            type = lib.types.str;
            default = builtins.elemAt (lib.strings.split "@" name) 2;
          };

          entryPoint = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };

          base = lib.mkOption {
            type = lib.types.str;
            readOnly = true;
          };

          homeDirectory = lib.mkOption {
            type = lib.types.str;
            readOnly = true;
          };

          modules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            default = [];
          };

          finalModules = lib.mkOption {
            type = lib.types.listOf lib.types.unspecified;
            readOnly = true;
          };

          finalHome = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };
        };

        config = {
          entryPoint = import "${self}/home/configurations/${config.username}@${config.hostname}.nix" (inputs // {inherit self;});
          base =
            if lib.strings.hasSuffix "-darwin" config.system
            then "Users"
            else "home";
          homeDirectory = "/${config.base}/${config.username}";

          finalModules =
            [
              config.entryPoint
              {home = {inherit (config) username homeDirectory;};}
            ]
            ++ config.modules
            ++ builtins.attrValues self.homeModules
            ++ builtins.attrValues self.mixedModules;

          finalHome = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = config.nixpkgs.legacyPackages.${config.system};
            modules = config.finalModules;
          };
        };
      }));
    };
  };

  config.flake.homeConfigurations = configs;
}
