{
  self,
  inputs,
  config,
  lib,
  npins,
  ...
}: let
  cfg = config.nobbz.homeConfigurations;

  configs = builtins.mapAttrs (_: config: config.finalHome) cfg;

  packages = builtins.attrValues (builtins.mapAttrs (_: config: config.packageModule) cfg);
in {
  _file = ./home_configs.nix;

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

          packageName = lib.mkOption {
            type = lib.types.str;
            readOnly = true;
          };

          finalPackage = lib.mkOption {
            type = lib.types.package;
            readOnly = true;
          };

          finalHome = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };

          packageModule = lib.mkOption {
            type = lib.types.unspecified;
            readOnly = true;
          };
        };

        config = {
          entryPoint = import "${self}/home/configurations/${config.username}_at_${config.hostname}.nix" (inputs // {inherit self;});
          base =
            if lib.strings.hasSuffix "-darwin" config.system
            then "Users"
            else "home";
          homeDirectory = "/${config.base}/${config.username}";

          finalModules =
            [
              config.entryPoint
              {home = {inherit (config) username homeDirectory;};}
              {systemd.user.startServices = "legacy";}
              inputs.nixos-vscode-server.nixosModules.home
              inputs.sops-nix.homeManagerModules.sops
            ]
            ++ config.modules
            ++ builtins.attrValues self.homeModules
            ++ builtins.attrValues self.mixedModules;

          packageName = "home/config/${name}";
          finalPackage = config.finalHome.activationPackage;

          packageModule = {${config.system}.${config.packageName} = config.finalPackage;};

          finalHome = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = config.nixpkgs.legacyPackages.${config.system};
            extraSpecialArgs.npins = npins;
            modules = config.finalModules;
          };
        };
      }));
    };
  };

  config.flake.homeConfigurations = configs;
  config.flake.packages = lib.mkMerge packages;
}
